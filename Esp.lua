-- Полностью рабочий код библиотеки NeverLose с поддержкой мобильных устройств
local NeverLose = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

-- Определение мобильного устройства
local IsMobile = UserInputService.TouchEnabled

-- Размеры для мобильной и десктопной версии
local MainWidth = IsMobile and 530 or 570
local MainHeight = IsMobile and 320 or 340
local SidebarWidth = IsMobile and 140 or 150
local HeaderHeight = 36
local FooterHeight = 42

-- Основные настройки анимации
local SlowyTween = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Вспомогательные функции
function NeverLose:ProcessParams(provided, defaults)
    provided = provided or {}
    for k, v in pairs(defaults) do
        if provided[k] == nil then
            provided[k] = v
        end
    end
    return provided
end

function NeverLose.RandomString()
    local str = ""
    for i = 1, 12 do
        str = str .. string.char(math.random(97, 122))
    end
    return str
end

function NeverLose.PlayAnimate(instance, tweenInfo, goals)
    if instance then
        TweenService:Create(instance, tweenInfo or SlowyTween, goals):Play()
    end
end

function NeverLose:IsMouseOverFrame(frame)
    local mouse = UserInputService:GetMouseLocation()
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return mouse.X >= pos.X and mouse.X <= pos.X + size.X and 
           mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y
end

function NeverLose:CreateInput(frame, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Система сохранения/загрузки
function NeverLose:SaveConfig(name)
    local data = {}
    for flag, elem in pairs(NeverLose.Flags) do
        if elem.GetValue then
            local val = elem:GetValue()
            if typeof(val) == "Color3" then
                data[flag] = { R = val.R, G = val.G, B = val.B, Type = "Color3" }
            elseif typeof(val) == "EnumItem" then
                data[flag] = { Name = val.Name, Type = "Enum" }
            else
                data[flag] = val
            end
        end
    end
    local json = HttpService:JSONEncode(data)
    if writefile then
        writefile(name .. ".json", json)
    end
end

function NeverLose:LoadConfig(name)
    if not readfile or not isfile or not isfile(name .. ".json") then
        return
    end
    local raw = readfile(name .. ".json")
    local data = HttpService:JSONDecode(raw)
    for flag, val in pairs(data) do
        if NeverLose.Flags[flag] and NeverLose.Flags[flag].SetValue then
            if typeof(val) == "table" and val.Type == "Color3" then
                NeverLose.Flags[flag]:SetValue(Color3.new(val.R, val.G, val.B))
            else
                NeverLose.Flags[flag]:SetValue(val)
            end
        end
    end
end

-- Настройки
NeverLose.AccentColor = Color3.fromRGB(0, 150, 255)
NeverLose.Flags = {}
NeverLose.Tabs = {}

-- Функция создания главного окна
function NeverLose:CreateWindow(Config)
    Config = NeverLose:ProcessParams(Config, {
        Title = "Neverlose.cc",
        SubTitle = "Roblox Edition",
        Size = Vector2.new(MainWidth, MainHeight),
        ToggleKey = Enum.KeyCode.RightShift,
    })

    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local TopBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local Sidebar = Instance.new("Frame")
    local PageContainer = Instance.new("Frame")

    MainFrame.Name = NeverLose.RandomString()
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, Config.Size.X, 0, Config.Size.Y)
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 13, 19)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    UIStroke.Transparency = 0.750
    UIStroke.Color = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent = MainFrame

    -- TopBar
    TopBar.Name = NeverLose.RandomString()
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, HeaderHeight)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
    TopBar.BorderSizePixel = 0

    TitleLabel.Parent = TopBar
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Config.Title .. " <font color=\"rgb(130,135,150)\">| " .. Config.SubTitle .. "</font>"
    TitleLabel.RichText = true
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = IsMobile and 10 or 12
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar (Tabs Container)
    Sidebar.Name = NeverLose.RandomString()
    Sidebar.Parent = MainFrame
    Sidebar.Position = UDim2.new(0, 0, 0, HeaderHeight)
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -(HeaderHeight + FooterHeight))
    Sidebar.BackgroundColor3 = Color3.fromRGB(13, 15, 21)
    Sidebar.BorderSizePixel = 0

    -- Page Container
    PageContainer.Name = NeverLose.RandomString()
    PageContainer.Parent = MainFrame
    PageContainer.Position = UDim2.new(0, SidebarWidth + 5, 0, HeaderHeight + 5)
    PageContainer.Size = UDim2.new(1, -(SidebarWidth + 10), 1, -(HeaderHeight + FooterHeight + 10))
    PageContainer.BackgroundTransparency = 1

    -- Dragging Logic
    local Dragging, DragInput, DragStart, StartPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    -- Toggle UI Visibility Key
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Config.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    return {
        MainFrame = MainFrame,
        Sidebar = Sidebar,
        PageContainer = PageContainer,
        IsMobile = IsMobile,
        MainWidth = MainWidth,
        MainHeight = MainHeight,
        SidebarWidth = SidebarWidth,
        HeaderHeight = HeaderHeight,
        FooterHeight = FooterHeight
    }
end

-- Пример использования
local Window = NeverLose:CreateWindow({
    Title = "Мой ГУИ",
    SubTitle = "Пример",
    ToggleKey = Enum.KeyCode.RightShift
})

print("Библиотека NeverLose успешно загружена!")
print("Режим: " .. (IsMobile and "Мобильный" or "Десктопный"))
print("Размеры окна: " .. MainWidth .. "x" .. MainHeight)
print("Нажмите RightShift, чтобы показать/скрыть окно")
