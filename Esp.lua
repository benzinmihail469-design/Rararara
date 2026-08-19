-- Полностью рабочий код библиотеки NeverLose со всеми компонентами
local NeverLose = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
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
local ManualTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Пустые функции
local EmptyFunction = function() end
local ZINdex = 0

-- ========== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ==========

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
    if not frame then return false end
    local mouse = UserInputService:GetMouseLocation()
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return mouse.X >= pos.X and mouse.X <= pos.X + size.X and 
           mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y
end

function NeverLose:CreateInput(frame, callback)
    if not frame then return end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function NeverLose.Rounding(num, places)
    local mult = 10 ^ (places or 0)
    return math.floor(num * mult + 0.5) / mult
end

function NeverLose:ParseInput(text, numeric)
    if numeric then
        return tonumber(text)
    end
    return text
end

function NeverLose:KeyCodeToStr(key)
    if key == "M1B" then return "LMB" end
    if key == "M2B" then return "RMB" end
    if key == "None" then return "None" end
    return key or "None"
end

function NeverLose:CreateColorPicker(parent)
    local ColorPicker = {}
    ColorPicker.Root = Instance.new("Frame")
    ColorPicker.Root.Parent = parent
    ColorPicker.Root.Size = UDim2.new(0, 200, 0, 150)
    ColorPicker.Root.Position = UDim2.new(0, 0, 1, 5)
    ColorPicker.Root.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    ColorPicker.Root.BorderSizePixel = 0
    ColorPicker.Root.Visible = false
    ColorPicker.Root.ZIndex = 100
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = ColorPicker.Root
    
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(0, 0, 0)
    }
    
    for i, color in ipairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 20, 0, 20)
        btn.Position = UDim2.new(0, (i-1) * 25, 0, 10)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(45, 48, 58)
        btn.Text = ""
        btn.Parent = ColorPicker.Root
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 2)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            ColorPicker.Callback(color)
            ColorPicker.Root.Visible = false
        end)
    end
    
    ColorPicker.SetRender = function(value)
        ColorPicker.Root.Visible = value
    end
    
    ColorPicker.SetValue = function(color)
        parent.BackgroundColor3 = color
    end
    
    return ColorPicker
end

function NeverLose:CreateOptionWindow(parent, zindex)
    local Window = {}
    Window.Root = Instance.new("Frame")
    Window.Root.Parent = parent
    Window.Root.Size = UDim2.new(0, 150, 0, 100)
    Window.Root.Position = UDim2.new(1, 5, 0, 0)
    Window.Root.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    Window.Root.BorderSizePixel = 0
    Window.Root.Visible = false
    Window.Root.ZIndex = zindex or 100
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Window.Root
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Transparency = 0.650
    UIStroke.Color = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent = Window.Root
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Option Window"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = Window.Root
    
    Window.Signal = {
        SetValue = function(value)
            Window.Root.Visible = value
        end
    }
    
    return Window
end

function NeverLose:AddSignal(connection)
    return connection
end

-- ========== СИСТЕМА СОХРАНЕНИЯ/ЗАГРУЗКИ ==========

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

-- ========== НАСТРОЙКИ ==========

NeverLose.AccentColor = Color3.fromRGB(0, 150, 255)
NeverLose.Flags = {}
NeverLose.Tabs = {}

-- ========== ЛОКАЛИЗАЦИЯ ==========

NeverLose.CurrentLang = "EN"
NeverLose.Translations = {
    EN = {
        Legitbot = "Legitbot",
        Visuals = "Visuals",
        Settings = "Settings",
        Configs = "Configs",
        Enabled = "Enabled",
        FOV = "Field of View",
        MainSettings = "Main Settings",
        Targeting = "Targeting",
        Configuration = "Configuration",
        SaveConfig = "Save Config",
        LoadConfig = "Load Config",
        Saved = "Saved successfully!",
        Loaded = "Loaded successfully!",
        Config = "Config",
        Hitbox = "Hitbox",
        AccentColor = "Accent Color",
        Welcome = "Welcome",
        LoadedMessage = "NeverLose library loaded!",
    },
    RU = {
        Legitbot = "Легитбот",
        Visuals = "Визуалы",
        Settings = "Настройки",
        Configs = "Конфиги",
        Enabled = "Включено",
        FOV = "Угол обзора",
        MainSettings = "Основные настройки",
        Targeting = "Прицеливание",
        Configuration = "Конфигурация",
        SaveConfig = "Сохранить конфиг",
        LoadConfig = "Загрузить конфиг",
        Saved = "Успешно сохранено!",
        Loaded = "Успешно загружено!",
        Config = "Конфиг",
        Hitbox = "Хитбокс",
        AccentColor = "Акцентный цвет",
        Welcome = "Добро пожаловать",
        LoadedMessage = "Библиотека NeverLose загружена!",
    }
}

function NeverLose:SetLanguage(lang)
    if NeverLose.Translations[lang] then
        NeverLose.CurrentLang = lang
    end
end

function NeverLose:GetText(key)
    local dict = NeverLose.Translations[NeverLose.CurrentLang] or NeverLose.Translations["EN"]
    return dict[key] or key
end

-- ========== ГРАФИЧЕСКИЕ ЭФФЕКТЫ ==========

-- UI Blur Effect (Эффект размытия заднего фона)
function NeverLose:ToggleBlur(state, intensity)
    local Blur = Lighting:FindFirstChild("NeverLose_Blur")
    if state then
        if not Blur then
            Blur = Instance.new("BlurEffect")
            Blur.Name = "NeverLose_Blur"
            Blur.Parent = Lighting
        end
        TweenService:Create(Blur, SlowyTween, { Size = intensity or 16 }):Play()
    else
        if Blur then
            local tween = TweenService:Create(Blur, SlowyTween, { Size = 0 })
            tween:Play()
            tween.Completed:Connect(function()
                if Blur.Size == 0 then Blur:Destroy() end
            end)
        end
    end
end

-- FOV Circle Overlay (Индикация радиуса Аимбота)
function NeverLose:CreateFOVCircle(Config)
    Config = NeverLose:ProcessParams(Config, {
        Radius = 100,
        Color = NeverLose.AccentColor,
        Visible = false,
        Thickness = 1.5,
    })

    if not Drawing then 
        warn("Drawing library not available")
        return nil 
    end

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = Config.Thickness
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Config.Radius
    FOVCircle.Filled = false
    FOVCircle.Visible = Config.Visible
    FOVCircle.Color = Config.Color
    FOVCircle.Transparency = 1

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if FOVCircle.Visible then
            local MousePos = UserInputService:GetMouseLocation()
            FOVCircle.Position = Vector2.new(MousePos.X, MousePos.Y)
        end
    end)

    return {
        Circle = FOVCircle,
        SetVisible = function(visible)
            FOVCircle.Visible = visible
        end,
        SetRadius = function(radius)
            FOVCircle.Radius = radius
        end,
        Destroy = function()
            Connection:Disconnect()
            FOVCircle:Remove()
        end
    }
end

-- ========== ФУНКЦИЯ СОЗДАНИЯ ГЛАВНОГО ОКНА ==========

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
    local TabContainer = Instance.new("Frame")

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

    -- Tab Container
    TabContainer.Name = NeverLose.RandomString()
    TabContainer.Parent = Sidebar
    TabContainer.Size = UDim2.new(1, 0, 1, 0)
    TabContainer.BackgroundTransparency = 1

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)

    -- Page Container
    PageContainer.Name = NeverLose.RandomString()
    PageContainer.Parent = MainFrame
    PageContainer.Position = UDim2.new(0, SidebarWidth + 5, 0, HeaderHeight + 5)
    PageContainer.Size = UDim2.new(1, -(SidebarWidth + 10), 1, -(HeaderHeight + FooterHeight + 10))
    PageContainer.BackgroundTransparency = 1

    -- Dragging Logic
    local Dragging, DragStart, StartPos
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
        TabContainer = TabContainer,
        IsMobile = IsMobile,
        MainWidth = MainWidth,
        MainHeight = MainHeight,
        SidebarWidth = SidebarWidth,
        HeaderHeight = HeaderHeight,
        FooterHeight = FooterHeight
    }
end

-- ========== СТРУКТУРНЫЕ МОДУЛИ ==========

-- Tab System (Система вкладок)
function NeverLose:AddTab(Handler, Config)
    Config = NeverLose:ProcessParams(Config, {
        Name = "Tab",
        Icon = "",
    })

    local TabButton = Instance.new("Frame")
    local TabTitle = Instance.new("TextLabel")
    local TabIcon = Instance.new("ImageLabel")

    TabButton.Name = NeverLose.RandomString()
    TabButton.Parent = Handler.TabContainer
    TabButton.Size = UDim2.new(1, 0, 0, 28)
    TabButton.BackgroundTransparency = 1

    TabIcon.Name = NeverLose.RandomString()
    TabIcon.Parent = TabButton
    TabIcon.Position = UDim2.new(0, 8, 0.5, -7)
    TabIcon.Size = UDim2.new(0, 14, 0, 14)
    TabIcon.Image = Config.Icon
    TabIcon.ImageColor3 = Color3.fromRGB(120, 125, 140)
    TabIcon.BackgroundTransparency = 1

    TabTitle.Name = NeverLose.RandomString()
    TabTitle.Parent = TabButton
    TabTitle.Position = UDim2.new(0, 28, 0, 0)
    TabTitle.Size = UDim2.new(1, -28, 1, 0)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = Config.Name
    TabTitle.Font = Enum.Font.GothamMedium
    TabTitle.TextSize = 11
    TabTitle.TextColor3 = Color3.fromRGB(120, 125, 140)
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left

    local Page = Instance.new("ScrollingFrame")
    Page.Name = NeverLose.RandomString()
    Page.Parent = Handler.PageContainer
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = NeverLose.AccentColor

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 5)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local TabLib = { Page = Page }

    NeverLose:CreateInput(TabButton, function()
        for _, tab in ipairs(NeverLose.Tabs) do
            if tab.Page then
                tab.Page.Visible = false
            end
        end
        Page.Visible = true
        for _, tab in ipairs(NeverLose.Tabs) do
            if tab.TabButton then
                tab.TabButton.BackgroundTransparency = 1
            end
        end
        TabButton.BackgroundTransparency = 0.5
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    end)

    TabLib.TabButton = TabButton
    table.insert(NeverLose.Tabs, TabLib)
    return TabLib
end

-- Section / Groupbox (Секция-контейнер)
function NeverLose:AddSection(Handler, Config)
    Config = NeverLose:ProcessParams(Config, {
        Name = "Section",
    })

    local Section = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local Title = Instance.new("TextLabel")
    local Container = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")

    Section.Name = NeverLose.RandomString()
    Section.Parent = Handler.Page
    Section.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(0.95, 0, 0, 30)
    Section.ZIndex = ZINdex + 10

    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Section

    UIStroke.Transparency = 0.800
    UIStroke.Color = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent = Section

    Title.Name = NeverLose.RandomString()
    Title.Parent = Section
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.Size = UDim2.new(1, -20, 0, 14)
    Title.BackgroundTransparency = 1
    Title.Text = string.upper(Config.Name)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 10
    Title.TextColor3 = Color3.fromRGB(150, 155, 170)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = ZINdex + 11

    Container.Name = NeverLose.RandomString()
    Container.Parent = Section
    Container.Position = UDim2.new(0, 10, 0, 28)
    Container.Size = UDim2.new(1, -20, 0, 0)
    Container.BackgroundTransparency = 1
    Container.ZIndex = ZINdex + 11

    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 4)

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.Size = UDim2.new(1, -20, 0, UIListLayout.AbsoluteContentSize.Y)
        Section.Size = UDim2.new(0.95, 0, 0, UIListLayout.AbsoluteContentSize.Y + 36)
    end)

    return Container
end

-- ========== GUI ЭЛЕМЕНТЫ ==========

-- Toggle (Переключатель)
function NeverLose:AddToggle(Handler, Config) 
    Config = NeverLose:ProcessParams(Config , { 
        Default = false, 
        Flag = nil, 
        Callback = EmptyFunction,
        Label = "Toggle"
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local ElementContainer = Instance.new("Frame")
    ElementContainer.Parent = Handler.Container
    ElementContainer.Size = UDim2.new(1, 0, 0, 25)
    ElementContainer.BackgroundTransparency = 1
    
    local Toggle = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local Circle = Instance.new("Frame") 
    local UICorner_2 = Instance.new("UICorner") 
    
    Toggle.Name = NeverLose.RandomString(); 
    Toggle.Parent = ElementContainer
    Toggle.AnchorPoint = Vector2.new(0, 0.5)
    Toggle.Position = UDim2.new(0, 0, 0.5, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(10, 13, 21) 
    Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Toggle.BorderSizePixel = 0 
    Toggle.ClipsDescendants = true 
    Toggle.Size = UDim2.new(0, 30, 0, 18) 
    Toggle.ZIndex = ZINdex + 13 
    
    UICorner.CornerRadius = UDim.new(1, 0) 
    UICorner.Parent = Toggle 
    
    Circle.Name = NeverLose.RandomString(); 
    Circle.Parent = Toggle 
    Circle.AnchorPoint = Vector2.new(0.5, 0.5) 
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    Circle.BackgroundTransparency = 0.500 
    Circle.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Circle.BorderSizePixel = 0 
    Circle.Position = UDim2.new(0.300000012, 0, 0.5, 0) 
    Circle.Size = UDim2.new(0, 16, 0, 16) 
    Circle.ZIndex = ZINdex + 14 
    
    UICorner_2.CornerRadius = UDim.new(1, 0) 
    UICorner_2.Parent = Circle 
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ElementContainer
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Config.Label
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleLib = { Root = Toggle }; 
    
    ToggleLib.SetUI = function(value) 
        if value then 
            NeverLose.PlayAnimate(Toggle,SlowyTween,{ BackgroundTransparency = 0, BackgroundColor3 = NeverLose.AccentColor }) 
            NeverLose.PlayAnimate(Circle,SlowyTween,{ BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0, Position = UDim2.new(0.7, 0, 0.5, 0) }) 
        else 
            NeverLose.PlayAnimate(Toggle,SlowyTween,{ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(10, 13, 21) }) 
            NeverLose.PlayAnimate(Circle,SlowyTween,{ BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.500, Position = UDim2.new(0.300000012, 0, 0.5, 0) }) 
        end; 
    end; 
    
    ToggleLib.SetVisible = function(value) 
        if value then 
            ToggleLib.SetUI(Config.Default); 
        else 
            NeverLose.PlayAnimate(Toggle,SlowyTween,{ BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(10, 13, 21) }) 
            NeverLose.PlayAnimate(Circle,SlowyTween,{ BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Position = UDim2.new(0.300000012, 0, 0.5, 0) }) 
        end; 
    end; 
    
    ToggleLib.SetUI(Config.Default); 
    ToggleLib.SetVisible(Signal:GetValue()); 
    
    NeverLose:CreateInput(Toggle , function() 
        Config.Default = not Config.Default; 
        ToggleLib.SetUI(Config.Default); 
        Config.Callback(Config.Default) 
    end) 
    
    ToggleLib.Signal = Signal:Connect(ToggleLib.SetVisible); 
    
    function ToggleLib:GetValue() 
        return Config.Default; 
    end; 
    
    function ToggleLib:SetValue(v) 
        Config.Default = v; 
        if Signal:GetValue() then 
            ToggleLib.SetUI(Config.Default); 
        end; 
        Config.Callback(Config.Default) 
    end; 
    
    if Config.Flag then 
        NeverLose.Flags[Config.Flag] = ToggleLib; 
    end; 
    
    return ToggleLib; 
end; 

-- Slider (Ползунок)
function NeverLose:AddSlider(Handler, Config) 
    Config = NeverLose:ProcessParams(Config , { 
        Default = 50, 
        Min = 0, 
        Max = 10, 
        Type = "", 
        Rounding = 0, 
        Nums = {}, 
        Flag = nil, 
        Size = 125, 
        Callback = EmptyFunction, 
        Label = "Slider"
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local SliderLib = {}; 
    SliderLib.GetSize = function() 
        return (Config.Default - Config.Min) / (Config.Max - Config.Min); 
    end; 
    
    local FullNumSize = TextService:GetTextSize(string.rep("0",(Config.Rounding + #tostring(Config.Max))+1)..tostring(Config.Type),10,Enum.Font.GothamMedium,Vector2.new(math.huge,math.huge)); 
    SliderLib.MaximumSize = FullNumSize.X; 
    
    if Config.Nums then 
        local nszie = 0; 
        for i,ns in next , Config.Nums do 
            local size = TextService:GetTextSize(string.rep("m",string.len(tostring(ns))),10,Enum.Font.GothamMedium,Vector2.new(math.huge,math.huge)); 
            if nszie < size.X then 
                nszie = size.X; 
            end 
        end; 
        if SliderLib.MaximumSize < nszie then 
            SliderLib.MaximumSize = nszie; 
        end; 
    end; 
    
    local ElementContainer = Instance.new("Frame")
    ElementContainer.Parent = Handler.Container
    ElementContainer.Size = UDim2.new(1, 0, 0, 25)
    ElementContainer.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ElementContainer
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -Config.Size - 50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Config.Label
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Slider = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local ValueFrame = Instance.new("Frame") 
    local UICorner_2 = Instance.new("UICorner") 
    local UIStroke = Instance.new("UIStroke") 
    local ValueLabel = Instance.new("TextBox") 
    local SlideMain = Instance.new("Frame") 
    local SlideFrame = Instance.new("Frame") 
    local UICorner_3 = Instance.new("UICorner") 
    local SlideMoving = Instance.new("Frame") 
    local UICorner_4 = Instance.new("UICorner") 
    local Frame = Instance.new("Frame") 
    local UICorner_5 = Instance.new("UICorner") 
    local boxSize = 2; 
    
    Slider.Name = NeverLose.RandomString(); 
    Slider.Parent = ElementContainer
    Slider.AnchorPoint = Vector2.new(1, 0.5)
    Slider.Position = UDim2.new(1, 0, 0.5, 0)
    Slider.BackgroundColor3 = Color3.fromRGB(26, 28, 36) 
    Slider.BackgroundTransparency = 1.000 
    Slider.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Slider.BorderSizePixel = 0 
    Slider.ClipsDescendants = false 
    Slider.Size = UDim2.new(0, Config.Size, 0, 18) 
    Slider.ZIndex = ZINdex + 13 
    
    UICorner.CornerRadius = UDim.new(0, 4) 
    UICorner.Parent = Slider 
    
    ValueFrame.Name = NeverLose.RandomString(); 
    ValueFrame.Parent = Slider 
    ValueFrame.AnchorPoint = Vector2.new(1, 0) 
    ValueFrame.BackgroundColor3 = Color3.fromRGB(26, 28, 36) 
    ValueFrame.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    ValueFrame.BorderSizePixel = 0 
    ValueFrame.ClipsDescendants = true 
    ValueFrame.Position = UDim2.new(1, 0, 0, 0) 
    ValueFrame.Size = UDim2.new(0, SliderLib.MaximumSize + boxSize, 0, 18) 
    ValueFrame.ZIndex = ZINdex + 13 
    
    UICorner_2.CornerRadius = UDim.new(0, 4) 
    UICorner_2.Parent = ValueFrame 
    
    UIStroke.Transparency = 0.650 
    UIStroke.Color = Color3.fromRGB(45, 48, 58) 
    UIStroke.Parent = ValueFrame 
    
    ValueLabel.Name = NeverLose.RandomString(); 
    ValueLabel.Parent = ValueFrame 
    ValueLabel.AnchorPoint = Vector2.new(0.5, 0.5) 
    ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    ValueLabel.BackgroundTransparency = 1.000 
    ValueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    ValueLabel.BorderSizePixel = 0 
    ValueLabel.Position = UDim2.new(0.5, 0, 0.5, 0) 
    ValueLabel.Size = UDim2.new(1, 0, 1, 0) 
    ValueLabel.ZIndex = ZINdex + 14 
    ValueLabel.Font = Enum.Font.GothamMedium 
    ValueLabel.Text = tostring(Config.Default)..tostring(Config.Type); 
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
    ValueLabel.TextSize = 10.000 
    ValueLabel.ClearTextOnFocus = false; 
    ValueLabel.TextTransparency = 0.350 
    
    SlideMain.Name = NeverLose.RandomString(); 
    SlideMain.Parent = Slider 
    SlideMain.AnchorPoint = Vector2.new(0, 0.5) 
    SlideMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    SlideMain.BackgroundTransparency = 1.000 
    SlideMain.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    SlideMain.BorderSizePixel = 0 
    SlideMain.Position = UDim2.new(0, 0, 0.5, 0) 
    SlideMain.Size = UDim2.new(1, -((SliderLib.MaximumSize + 11)), 0, 18) 
    SlideMain.ZIndex = ZINdex + 13 
    
    SlideFrame.Name = NeverLose.RandomString(); 
    SlideFrame.Parent = SlideMain 
    SlideFrame.AnchorPoint = Vector2.new(0, 0.5) 
    SlideFrame.BackgroundColor3 = Color3.fromRGB(30, 29, 36) 
    SlideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    SlideFrame.BorderSizePixel = 0 
    SlideFrame.Position = UDim2.new(0, 0, 0.5, 0) 
    SlideFrame.Size = UDim2.new(1, 0, 0, 5) 
    SlideFrame.ZIndex = ZINdex + 13 
    
    UICorner_3.CornerRadius = UDim.new(1, 0) 
    UICorner_3.Parent = SlideFrame 
    
    SlideMoving.Name = NeverLose.RandomString(); 
    SlideMoving.Parent = SlideFrame 
    SlideMoving.BackgroundColor3 = NeverLose.AccentColor 
    SlideMoving.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    SlideMoving.BorderSizePixel = 0 
    SlideMoving.Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) 
    SlideMoving.ZIndex = ZINdex + 14 
    
    UICorner_4.CornerRadius = UDim.new(1, 0) 
    UICorner_4.Parent = SlideMoving 
    
    Frame.Parent = SlideMoving 
    Frame.AnchorPoint = Vector2.new(1, 0.5) 
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    Frame.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Frame.BorderSizePixel = 0 
    Frame.Position = UDim2.new(1, 5, 0.5, 0) 
    Frame.Size = UDim2.new(0, 10, 0, 10) 
    Frame.ZIndex = ZINdex + 15 
    
    UICorner_5.CornerRadius = UDim.new(1, 0) 
    UICorner_5.Parent = Frame 
    
    local LoadText = function() 
        if Config.Nums[Config.Default] then 
            ValueLabel.Text = Config.Nums[Config.Default] 
        else 
            ValueLabel.Text = tostring(Config.Default)..tostring(Config.Type); 
        end; 
    end; 
    
    ValueLabel.FocusLost:Connect(function() 
        local OutVal = NeverLose:ParseInput(ValueLabel.Text , true); 
        if OutVal then 
            local rx = math.clamp(OutVal , Config.Min , Config.Max); 
            local Value = NeverLose.Rounding(rx,Config.Rounding); 
            if Value then 
                Config.Default = Value; 
                TweenService:Create(SlideMoving , ManualTween ,{ Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) }):Play(); 
                LoadText(); 
                Config.Callback(Config.Default) 
            else 
                LoadText(); 
            end; 
        else 
            LoadText() 
        end; 
    end); 
    
    SliderLib.SetRender = function(value) 
        if value then 
            NeverLose.PlayAnimate(ValueFrame,SlowyTween,{ BackgroundTransparency = 0, Size = UDim2.new(0, SliderLib.MaximumSize + boxSize, 0, 18) }); 
            NeverLose.PlayAnimate(UIStroke,SlowyTween,{ Transparency = 0.650 }); 
            NeverLose.PlayAnimate(ValueLabel,SlowyTween,{ TextTransparency = 0.350 }); 
            NeverLose.PlayAnimate(SlideFrame,SlowyTween,{ BackgroundTransparency = 0 }); 
            NeverLose.PlayAnimate(SlideMoving,SlowyTween,{ BackgroundTransparency = 0, Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) }); 
            NeverLose.PlayAnimate(Frame,SlowyTween,{ BackgroundTransparency = 0 }); 
        else 
            NeverLose.PlayAnimate(ValueFrame,SlowyTween,{ BackgroundTransparency = 1 }); 
            NeverLose.PlayAnimate(UIStroke,SlowyTween,{ Transparency = 1 }); 
            NeverLose.PlayAnimate(ValueLabel,SlowyTween,{ TextTransparency = 1 }); 
            NeverLose.PlayAnimate(SlideFrame,SlowyTween,{ BackgroundTransparency = 1 }); 
            NeverLose.PlayAnimate(SlideMoving,SlowyTween,{ BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0) }); 
            NeverLose.PlayAnimate(Frame,SlowyTween,{ BackgroundTransparency = 1 }); 
        end; 
    end; 
    
    SliderLib.SetRender(Signal:GetValue()); 
    SliderLib.Signal = Signal:Connect(SliderLib.SetRender); 
    
    local Update = function(Input) 
        local SizeScale = math.clamp((((Input.Position.X) - SlideMain.AbsolutePosition.X) / SlideMain.AbsoluteSize.X), 0, 1); 
        local Main = ((Config.Max - Config.Min) * SizeScale) + Config.Min; 
        local Value = NeverLose.Rounding(Main,Config.Rounding); 
        Config.Default = Value; 
        TweenService:Create(SlideMoving , ManualTween ,{ Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) }):Play(); 
        LoadText() 
        Config.Callback(Value) 
    end; 
    
    local IsHold = false; 
    SlideMain.InputBegan:Connect(function(Input) 
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
            IsHold = true 
            Update(Input) 
        end 
    end) 
    
    SlideMain.InputEnded:Connect(function(Input) 
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
            IsHold = false 
        end 
    end) 
    
    UserInputService.InputChanged:Connect(function(Input) 
        if IsHold and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then 
            Update(Input) 
        end; 
    end); 
    
    function SliderLib:GetValue() 
        return Config.Default; 
    end; 
    
    function SliderLib:SetValue(v) 
        Config.Default = v; 
        if Signal:GetValue() then 
            NeverLose.PlayAnimate(SlideMoving,SlowyTween,{ BackgroundTransparency = 0, Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0) }); 
        end; 
        LoadText() 
        Config.Callback(Config.Default); 
    end; 
    
    if Config.Flag then 
        NeverLose.Flags[Config.Flag] = SliderLib; 
    end; 
    
    return SliderLib; 
end; 

-- Keybind (Назначение клавиш)
function NeverLose:AddKeybind(Handler, Config) 
    Config = NeverLose:ProcessParams(Config,{ 
        Default = nil, 
        Blacklist = {}, 
        Callback = EmptyFunction, 
        Flag = nil,
        Label = "Keybind"
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local KeybindLib = {}; 
    
    local ElementContainer = Instance.new("Frame")
    ElementContainer.Parent = Handler.Container
    ElementContainer.Size = UDim2.new(1, 0, 0, 25)
    ElementContainer.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ElementContainer
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Config.Label
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Keybind = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local UIStroke = Instance.new("UIStroke") 
    local ValueLabel = Instance.new("TextLabel") 
    
    Keybind.Name = NeverLose.RandomString(); 
    Keybind.Parent = ElementContainer
    Keybind.AnchorPoint = Vector2.new(1, 0.5)
    Keybind.Position = UDim2.new(1, 0, 0.5, 0)
    Keybind.BackgroundColor3 = Color3.fromRGB(26, 28, 36) 
    Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Keybind.BorderSizePixel = 0 
    Keybind.ClipsDescendants = true 
    Keybind.Size = UDim2.new(0, 45, 0, 18) 
    Keybind.ZIndex = ZINdex + 13 
    
    UICorner.CornerRadius = UDim.new(0, 4) 
    UICorner.Parent = Keybind 
    
    UIStroke.Transparency = 0.650 
    UIStroke.Color = Color3.fromRGB(45, 48, 58) 
    UIStroke.Parent = Keybind 
    
    ValueLabel.Name = NeverLose.RandomString(); 
    ValueLabel.Parent = Keybind 
    ValueLabel.AnchorPoint = Vector2.new(0.5, 0.5) 
    ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    ValueLabel.BackgroundTransparency = 1.000 
    ValueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    ValueLabel.BorderSizePixel = 0 
    ValueLabel.ClipsDescendants = true 
    ValueLabel.Position = UDim2.new(0.5, 0, 0.5, 0) 
    ValueLabel.Size = UDim2.new(1, 0, 1, 0) 
    ValueLabel.ZIndex = ZINdex + 14 
    ValueLabel.Font = Enum.Font.GothamMedium 
    ValueLabel.Text = NeverLose:KeyCodeToStr(Config.Default or "None") 
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
    ValueLabel.TextSize = 10.000 
    ValueLabel.TextTransparency = 0.500 
    
    KeybindLib.SetRender = function(value) 
        if value then 
            NeverLose.PlayAnimate(Keybind,SlowyTween, { BackgroundTransparency = 0 }) 
            NeverLose.PlayAnimate(UIStroke,SlowyTween, { Transparency = 0.650 }) 
            NeverLose.PlayAnimate(ValueLabel,SlowyTween, { TextTransparency = 0.500 }) 
        else 
            NeverLose.PlayAnimate(Keybind,SlowyTween, { BackgroundTransparency = 1 }) 
            NeverLose.PlayAnimate(UIStroke,SlowyTween, { Transparency = 1 }) 
            NeverLose.PlayAnimate(ValueLabel,SlowyTween, { TextTransparency = 1 }) 
        end; 
    end; 
    
    function KeybindLib:Update() 
        local size = TextService:GetTextSize(ValueLabel.Text,ValueLabel.TextSize,ValueLabel.Font,Vector2.new(math.huge,math.huge)); 
        NeverLose.PlayAnimate(Keybind , SlowyTween , { Size = UDim2.new(0, size.X + 7, 0, 18) }) 
    end; 
    
    local IsBlacklist = function(v) 
        return Config.Blacklist and (Config.Blacklist[v] or table.find(Config.Blacklist,v)) 
    end; 
    
    KeybindLib:Update() 
    KeybindLib.SetRender(Signal:GetValue()); 
    Signal:Connect(KeybindLib.SetRender); 
    
    local IsBinding = false; 
    NeverLose:CreateInput(Keybind , function() 
        if IsBinding then return; end; 
        IsBinding = true; 
        ValueLabel.Text = "..."; 
        KeybindLib:Update(); 
        local Selected = nil; 
        while not Selected do 
            local Key = UserInputService.InputBegan:Wait(); 
            if Key.KeyCode ~= Enum.KeyCode.Unknown and not IsBlacklist(Key.KeyCode) and not IsBlacklist(Key.KeyCode.Name) then 
                Selected = Key.KeyCode; 
            else 
                if Key.UserInputType == Enum.UserInputType.MouseButton1 and not IsBlacklist(Enum.UserInputType.MouseButton1) and not IsBlacklist("M1B") then 
                    Selected = "M1B"; 
                elseif Key.UserInputType == Enum.UserInputType.MouseButton2 and not IsBlacklist(Enum.UserInputType.MouseButton2) and not IsBlacklist("M2B") then 
                    Selected = "M2B"; 
                end; 
            end; 
        end; 
        IsBinding = false; 
        local KeyName = typeof(Selected) == "string" and Selected or Selected.Name; 
        Config.Default = KeyName; 
        ValueLabel.Text = NeverLose:KeyCodeToStr(KeyName); 
        KeybindLib:Update(); 
        Config.Callback(KeyName) 
    end) 
    
    function KeybindLib:GetValue() 
        return Config.Default; 
    end; 
    
    function KeybindLib:SetValue(v) 
        Config.Default = v; 
        ValueLabel.Text = NeverLose:KeyCodeToStr(v); 
        KeybindLib:Update(); 
        Config.Callback(Config.Default); 
    end; 
    
    if Config.Flag then 
        NeverLose.Flags[Config.Flag] = KeybindLib; 
    end; 
    
    return KeybindLib; 
end; 

-- ColorPicker (Палитра цвета)
function NeverLose:AddColorPicker(Handler, Config) 
    Config = NeverLose:ProcessParams(Config , { 
        Default = Color3.fromRGB(255, 255, 255), 
        Callback = EmptyFunction, 
        Flag = nil,
        Label = "Color"
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    if typeof(Config.Default) == 'string' then 
        Config.Default = Color3.fromHex(Config.Default:gsub('#','')); 
    end; 
    
    local ColorPickerLib = {}; 
    
    local ElementContainer = Instance.new("Frame")
    ElementContainer.Parent = Handler.Container
    ElementContainer.Size = UDim2.new(1, 0, 0, 25)
    ElementContainer.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ElementContainer
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -25, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Config.Label
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ColorPicker = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local UIStroke = Instance.new("UIStroke") 
    local ImageLabel = Instance.new("ImageLabel") 
    local UICorner_2 = Instance.new("UICorner") 
    
    ColorPicker.Name = NeverLose.RandomString(); 
    ColorPicker.Parent = ElementContainer
    ColorPicker.AnchorPoint = Vector2.new(1, 0.5)
    ColorPicker.Position = UDim2.new(1, 0, 0.5, 0)
    ColorPicker.BackgroundColor3 = Config.Default; 
    ColorPicker.BackgroundTransparency = 0 
    ColorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    ColorPicker.BorderSizePixel = 0 
    ColorPicker.ClipsDescendants = true 
    ColorPicker.Size = UDim2.new(0, 18, 0, 18) 
    ColorPicker.ZIndex = ZINdex + 13 
    
    UICorner.CornerRadius = UDim.new(0, 4) 
    UICorner.Parent = ColorPicker 
    
    UIStroke.Transparency = 0.650 
    UIStroke.Color = Color3.fromRGB(45, 48, 58) 
    UIStroke.Parent = ColorPicker 
    
    ImageLabel.Parent = ColorPicker 
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    ImageLabel.BorderSizePixel = 0 
    ImageLabel.Size = UDim2.new(1, 0, 1, 0) 
    ImageLabel.ZIndex = ZINdex + 11 
    ImageLabel.Image = "rbxasset://textures/meshPartFallback.png" 
    ImageLabel.ImageTransparency = 0.9 
    ImageLabel.BackgroundTransparency = 1; 
    ImageLabel.ScaleType = Enum.ScaleType.Crop 
    
    UICorner_2.CornerRadius = UDim.new(0, 4) 
    UICorner_2.Parent = ImageLabel 
    
    local BackendM = NeverLose:CreateColorPicker(ColorPicker); 
    BackendM:SetValue(Config.Default) 
    BackendM.Callback = function(color) 
        ColorPicker.BackgroundColor3 = color; 
        Config.Default = color; 
        Config.Callback(Config.Default); 
    end; 
    
    local signal; 
    NeverLose:CreateInput(ColorPicker , function() 
        if signal then signal:Disconnect(); signal = nil; end; 
        BackendM.SetRender(true); 
        signal = UserInputService.InputBegan:Connect(function(Input) 
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                if not NeverLose:IsMouseOverFrame(ColorPicker) and not NeverLose:IsMouseOverFrame(BackendM.Root) then 
                    if signal then signal:Disconnect(); signal = nil; end; 
                    BackendM.SetRender(false); 
                end; 
            end; 
        end) 
    end); 
    
    ColorPickerLib.SetRender = function(value) 
        if value then 
            NeverLose.PlayAnimate(ColorPicker , SlowyTween , { BackgroundTransparency = 0 }) 
            NeverLose.PlayAnimate(UIStroke , SlowyTween , { Transparency = 0.650 }) 
            NeverLose.PlayAnimate(ImageLabel , SlowyTween , { ImageTransparency = 0.9 }) 
        else 
            NeverLose.PlayAnimate(ColorPicker , SlowyTween , { BackgroundTransparency = 1 }) 
            NeverLose.PlayAnimate(UIStroke , SlowyTween , { Transparency = 1 }) 
            NeverLose.PlayAnimate(ImageLabel , SlowyTween , { ImageTransparency = 1 }) 
        end; 
    end; 
    
    ColorPickerLib.SetRender(Signal:GetValue()); 
    Signal:Connect(ColorPickerLib.SetRender); 
    
    function ColorPickerLib:GetValue() 
        return Config.Default; 
    end; 
    
    function ColorPickerLib:SetValue(v) 
        Config.Default = v; 
        BackendM:SetValue(Config.Default) 
    end; 
    
    if Config.Flag then 
        NeverLose.Flags[Config.Flag] = ColorPickerLib; 
    end; 
    
    return ColorPickerLib; 
end; 

-- Dropdown (Выпадающий список)
function NeverLose:AddDropdown(Handler, Config)
    Config = NeverLose:ProcessParams(Config, {
        Default = nil,
        Options = {},
        Multi = false,
        Flag = nil,
        Size = 150,
        Label = "Dropdown",
        Callback = EmptyFunction,
    });

    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local DropdownLib = { Values = Config.Multi and (Config.Default or {}) or Config.Default };
    local Open = false;
    
    local ElementContainer = Instance.new("Frame")
    ElementContainer.Parent = Handler.Container
    ElementContainer.Size = UDim2.new(1, 0, 0, 25)
    ElementContainer.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ElementContainer
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -(Config.Size + 5), 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Config.Label
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Dropdown = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local SelectedText = Instance.new("TextLabel")
    local Icon = Instance.new("TextLabel")
    local Container = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")

    Dropdown.Name = NeverLose.RandomString();
    Dropdown.Parent = ElementContainer
    Dropdown.AnchorPoint = Vector2.new(1, 0.5)
    Dropdown.Position = UDim2.new(1, 0, 0.5, 0)
    Dropdown.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Dropdown.BorderSizePixel = 0
    Dropdown.Size = UDim2.new(0, Config.Size, 0, 18)
    Dropdown.ZIndex = ZINdex + 13

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Dropdown

    UIStroke.Transparency = 0.650
    UIStroke.Color = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent = Dropdown

    SelectedText.Name = NeverLose.RandomString();
    SelectedText.Parent = Dropdown
    SelectedText.Position = UDim2.new(0, 6, 0, 0)
    SelectedText.Size = UDim2.new(1, -22, 1, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectedText.Font = Enum.Font.GothamMedium
    SelectedText.TextSize = 10
    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
    SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
    SelectedText.ZIndex = ZINdex + 14

    Icon.Name = NeverLose.RandomString();
    Icon.Parent = Dropdown
    Icon.Position = UDim2.new(1, -16, 0, 0)
    Icon.Size = UDim2.new(0, 12, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = "▼"
    Icon.TextColor3 = Color3.fromRGB(200, 200, 200)
    Icon.TextSize = 12
    Icon.ZIndex = ZINdex + 14

    Container.Name = NeverLose.RandomString();
    Container.Parent = Dropdown
    Container.Position = UDim2.new(0, 0, 1, 4)
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    Container.ClipsDescendants = true
    Container.Visible = false
    Container.ZIndex = ZINdex + 25

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 4)
    ContainerCorner.Parent = Container

    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function UpdateText()
        if Config.Multi then
            local selected = {}
            for k, v in pairs(DropdownLib.Values) do
                if v then table.insert(selected, k) end
            end
            SelectedText.Text = #selected > 0 and table.concat(selected, ", ") or "None"
        else
            SelectedText.Text = tostring(DropdownLib.Values or "None")
        end
    end

    function DropdownLib:Refresh(newOptions)
        Config.Options = newOptions or Config.Options
        for _, child in ipairs(Container:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        for i, opt in ipairs(Config.Options) do
            local Item = Instance.new("Frame")
            Item.Size = UDim2.new(1, 0, 0, 18)
            Item.BackgroundTransparency = 1
            Item.Parent = Container

            local ItemText = Instance.new("TextLabel")
            ItemText.Parent = Item
            ItemText.Size = UDim2.new(1, -10, 1, 0)
            ItemText.Position = UDim2.new(0, 5, 0, 0)
            ItemText.BackgroundTransparency = 1
            ItemText.Text = tostring(opt)
            ItemText.Font = Enum.Font.GothamMedium
            ItemText.TextSize = 10
            ItemText.TextColor3 = Color3.fromRGB(180, 180, 180)
            ItemText.TextXAlignment = Enum.TextXAlignment.Left

            NeverLose:CreateInput(Item, function()
                if Config.Multi then
                    DropdownLib.Values[opt] = not DropdownLib.Values[opt]
                    ItemText.TextColor3 = DropdownLib.Values[opt] and NeverLose.AccentColor or Color3.fromRGB(180, 180, 180)
                else
                    DropdownLib.Values = opt
                    Open = false
                    Container.Visible = false
                end
                UpdateText()
                Config.Callback(DropdownLib.Values)
            end)
        end
    end

    DropdownLib:Refresh(Config.Options)
    UpdateText()

    NeverLose:CreateInput(Dropdown, function()
        Open = not Open
        Container.Visible = Open
        Container.Size = Open and UDim2.new(1, 0, 0, math.min(#Config.Options * 18, 120)) or UDim2.new(1, 0, 0, 0)
    end)

    function DropdownLib:GetValue() return DropdownLib.Values end
    function DropdownLib:SetValue(val)
        DropdownLib.Values = val
        UpdateText()
        Config.Callback(DropdownLib.Values)
    end

    if Config.Flag then NeverLose.Flags[Config.Flag] = DropdownLib end
    return DropdownLib
end

-- Button (Кнопка)
function NeverLose:AddButton(Handler, Config)
    Config = NeverLose:ProcessParams(Config, {
        Text = "Button",
        Callback = EmptyFunction,
    });

    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}

    local Button = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local TextLabel = Instance.new("TextLabel")

    Button.Name = NeverLose.RandomString();
    Button.Parent = Handler.Container
    Button.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Button.BorderSizePixel = 0
    Button.ClipsDescendants = true
    Button.Size = UDim2.new(1, 0, 0, 22)
    Button.ZIndex = ZINdex + 13

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Button

    UIStroke.Transparency = 0.650
    UIStroke.Color = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent = Button

    TextLabel.Parent = Button
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = Config.Text
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.GothamMedium
    TextLabel.TextSize = 10
    TextLabel.ZIndex = ZINdex + 14

    local ButtonLib = {}

    ButtonLib.SetRender = function(value)
        if value then
            NeverLose.PlayAnimate(Button, SlowyTween, { BackgroundTransparency = 0 })
            NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 0.650 })
            NeverLose.PlayAnimate(TextLabel, SlowyTween, { TextTransparency = 0 })
        else
            NeverLose.PlayAnimate(Button, SlowyTween, { BackgroundTransparency = 1 })
            NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 1 })
            NeverLose.PlayAnimate(TextLabel, SlowyTween, { TextTransparency = 1 })
        end
    end

    ButtonLib.SetRender(Signal:GetValue())
    Signal:Connect(ButtonLib.SetRender)

    local input = NeverLose:CreateInput(Button, function()
        Config.Callback()
    end)

    NeverLose:AddSignal(input.MouseEnter:Connect(function()
        NeverLose.PlayAnimate(Button, SlowyTween, { BackgroundColor3 = Color3.fromRGB(35, 38, 48) })
    end))

    NeverLose:AddSignal(input.MouseLeave:Connect(function()
        NeverLose.PlayAnimate(Button, SlowyTween, { BackgroundColor3 = Color3.fromRGB(26, 28, 36) })
    end))

    return ButtonLib
end

-- Label (Текстовая надпись)
function NeverLose:AddLabel(Handler, Config)
    local Text = typeof(Config) == "string" and Config or (Config.Text or "")

    local Label = Instance.new("Frame")
    local TextLabel = Instance.new("TextLabel")

    Label.Name = NeverLose.RandomString();
    Label.Parent = Handler.Container
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.ZIndex = ZINdex + 13

    TextLabel.Parent = Label
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = Text
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.Font = Enum.Font.GothamMedium
    TextLabel.TextSize = 10
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.ZIndex = ZINdex + 14

    local LabelLib = {}
    function LabelLib:SetText(newText)
        TextLabel.Text = newText
    end

    return LabelLib
end

-- Divider (Линия-разделитель)
function NeverLose:AddDivider(Handler)
    local Divider = Instance.new("Frame")
    local Line = Instance.new("Frame")

    Divider.Name = NeverLose.RandomString();
    Divider.Parent = Handler.Container
    Divider.BackgroundTransparency = 1
    Divider.Size = UDim2.new(1, 0, 0, 8)
    Divider.ZIndex = ZINdex + 13

    Line.Parent = Divider
    Line.AnchorPoint = Vector2.new(0.5, 0.5)
    Line.Position = UDim2.new(0.5, 0, 0.5, 0)
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
    Line.BorderSizePixel = 0
    Line.ZIndex = ZINdex + 14

    return Divider
end

-- Option Window & Button
function NeverLose:AddOption(Handler, GearIcon) 
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local Option = Instance.new("Frame") 
    local Icon = Instance.new("TextLabel") 
    local UICorner = Instance.new("UICorner") 
    
    Option.Name = NeverLose.RandomString(); 
    Option.Parent = Handler.Container
    Option.BackgroundColor3 = Color3.fromRGB(39, 40, 49) 
    Option.BackgroundTransparency = 1.000 
    Option.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Option.BorderSizePixel = 0 
    Option.ClipsDescendants = true 
    Option.Size = UDim2.new(0, 20, 0, 18) 
    Option.ZIndex = ZINdex + 13 
    
    Icon.Name = NeverLose.RandomString(); 
    Icon.Parent = Option 
    Icon.AnchorPoint = Vector2.new(0.5, 0.5) 
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    Icon.BackgroundTransparency = 1.000 
    Icon.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Icon.BorderSizePixel = 0 
    Icon.Position = UDim2.new(0.5, 0, 0.5, 0) 
    Icon.Size = UDim2.new(1, 0, 1, 0) 
    Icon.ZIndex = ZINdex + 14 
    Icon.Font = Enum.Font.GothamBold 
    Icon.Text = (GearIcon == 1 and '⚙') or (GearIcon == 2 and '▶') or "⋮"; 
    Icon.TextColor3 = Color3.fromRGB(223, 223, 223) 
    Icon.TextSize = 16.000 
    Icon.TextTransparency = 0.400 
    Icon.TextWrapped = true 
    
    UICorner.CornerRadius = UDim.new(0, 4) 
    UICorner.Parent = Option 
    
    local Window = NeverLose:CreateOptionWindow(Option , ZINdex + 13); 
    local reciveSignal; 
    Window.SetRender = function(value) 
        if value then 
            NeverLose.PlayAnimate(Icon , SlowyTween , { TextTransparency = 0.400 }) 
        else 
            NeverLose.PlayAnimate(Icon , SlowyTween , { TextTransparency = 1 }) 
        end; 
    end; 
    Window.SetRender(Signal:GetValue()); 
    Signal:Connect(Window.SetRender); 
    
    local bthg = NeverLose:CreateInput(Option , function() 
        if reciveSignal then reciveSignal:Disconnect(); reciveSignal = nil; end; 
        Window.Signal:SetValue(true); 
        reciveSignal = UserInputService.InputBegan:Connect(function(Input) 
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                if not NeverLose:IsMouseOverFrame(Window.Root) and not NeverLose:IsMouseOverFrame(Option) then 
                    if reciveSignal then reciveSignal:Disconnect(); reciveSignal = nil; end; 
                    Window.Signal:SetValue(false); 
                end 
            end 
        end) 
    end); 
    
    NeverLose:AddSignal(bthg.MouseEnter:Connect(function() 
        NeverLose.PlayAnimate(Option , SlowyTween , { BackgroundTransparency = 0.5 }) 
        NeverLose.PlayAnimate(Icon , SlowyTween , { TextTransparency = 0.25 }) 
    end)); 
    
    NeverLose:AddSignal(bthg.MouseLeave:Connect(function() 
        NeverLose.PlayAnimate(Option , SlowyTween , { BackgroundTransparency = 1.000 }) 
        NeverLose.PlayAnimate(Icon , SlowyTween , { TextTransparency = 0.400 }) 
    end)); 
    
    return Window; 
end; 

-- TextInput (Поле ввода текста)
function NeverLose:AddTextInput(Handler, Config) 
    Config = NeverLose:ProcessParams(Config , { 
        Default = "", 
        Placeholder = "Placeholder", 
        Callback = print, 
        Flag = nil, 
        Size = 100, 
        Numeric = false,
        Label = "Text Input"
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local TextBoxLib = {}; 
    
    local ElementContainer = Instance.new("Frame")
    ElementContainer.Parent = Handler.Container
    ElementContainer.Size = UDim2.new(1, 0, 0, 25)
    ElementContainer.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ElementContainer
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -(Config.Size + 5), 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Config.Label
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local TextInput = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local UIStroke = Instance.new("UIStroke") 
    local TextBox = Instance.new("TextBox") 
    
    TextInput.Name = NeverLose.RandomString(); 
    TextInput.Parent = ElementContainer
    TextInput.AnchorPoint = Vector2.new(1, 0.5)
    TextInput.Position = UDim2.new(1, 0, 0.5, 0)
    TextInput.BackgroundColor3 = Color3.fromRGB(26, 28, 36) 
    TextInput.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    TextInput.BorderSizePixel = 0 
    TextInput.ClipsDescendants = true 
    TextInput.Size = UDim2.new(0, Config.Size, 0, 18) 
    TextInput.ZIndex = ZINdex + 13 
    
    UICorner.CornerRadius = UDim.new(0, 4) 
    UICorner.Parent = TextInput 
    
    UIStroke.Transparency = 0.650 
    UIStroke.Color = Color3.fromRGB(45, 48, 58) 
    UIStroke.Parent = TextInput 
    
    TextBox.Name = NeverLose.RandomString() 
    TextBox.Parent = TextInput 
    TextBox.Size = UDim2.new(1, -10, 1, 0) 
    TextBox.Position = UDim2.new(0, 5, 0, 0) 
    TextBox.BackgroundTransparency = 1 
    TextBox.Text = Config.Default 
    TextBox.PlaceholderText = Config.Placeholder 
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255) 
    TextBox.Font = Enum.Font.GothamMedium 
    TextBox.TextSize = 10 
    TextBox.ClearTextOnFocus = false 
    TextBox.ZIndex = ZINdex + 14 
    
    TextBoxLib.SetRender = function(value) 
        if value then 
            NeverLose.PlayAnimate(TextInput, SlowyTween, { BackgroundTransparency = 0 }) 
            NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 0.650 }) 
            NeverLose.PlayAnimate(TextBox, SlowyTween, { TextTransparency = 0 }) 
        else 
            NeverLose.PlayAnimate(TextInput, SlowyTween, { BackgroundTransparency = 1 }) 
            NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 1 }) 
            NeverLose.PlayAnimate(TextBox, SlowyTween, { TextTransparency = 1 }) 
        end 
    end 
    
    TextBoxLib.SetRender(Signal:GetValue()) 
    Signal:Connect(TextBoxLib.SetRender) 
    
    TextBox.FocusLost:Connect(function() 
        if Config.Numeric then 
            local num = tonumber(TextBox.Text) 
            if num then 
                Config.Default = tostring(num) 
            else 
                TextBox.Text = Config.Default 
            end 
        else 
            Config.Default = TextBox.Text 
        end 
        Config.Callback(Config.Default) 
    end) 
    
    function TextBoxLib:GetValue() 
        return Config.Default 
    end 
    
    function TextBoxLib:SetValue(val) 
        Config.Default = tostring(val) 
        TextBox.Text = Config.Default 
        Config.Callback(Config.Default) 
    end 
    
    if Config.Flag then 
        NeverLose.Flags[Config.Flag] = TextBoxLib 
    end 
    
    return TextBoxLib 
end 

-- ========== СИСТЕМНЫЕ ОКНА И HUD ==========

-- Notifications (Система всплывающих уведомлений)
function NeverLose:Notification(Config)
    Config = NeverLose:ProcessParams(Config, {
        Title = "Notification",
        Text = "Message",
        Duration = 3,
    })

    if not NotificationHolder then
        NotificationHolder = Instance.new("Frame")
        NotificationHolder.Name = "NotificationHolder"
        NotificationHolder.Parent = ScreenGui
        NotificationHolder.Size = UDim2.new(0, 240, 0, 0)
        NotificationHolder.Position = UDim2.new(1, -250, 0, 10)
        NotificationHolder.BackgroundTransparency = 1
        
        local NotifLayout = Instance.new("UIListLayout")
        NotifLayout.Parent = NotificationHolder
        NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
        NotifLayout.Padding = UDim.new(0, 5)
        NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end

    local Notif = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local TitleLabel = Instance.new("TextLabel")
    local TextLabel = Instance.new("TextLabel")
    local Bar = Instance.new("Frame")

    Notif.Name = NeverLose.RandomString()
    Notif.Parent = NotificationHolder
    Notif.Size = UDim2.new(0, 220, 0, 50)
    Notif.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
    Notif.BorderSizePixel = 0

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Notif

    TitleLabel.Parent = Notif
    TitleLabel.Position = UDim2.new(0, 10, 0, 6)
    TitleLabel.Size = UDim2.new(1, -20, 0, 14)
    TitleLabel.Text = Config.Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 11
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1

    TextLabel.Parent = Notif
    TextLabel.Position = UDim2.new(0, 10, 0, 22)
    TextLabel.Size = UDim2.new(1, -20, 0, 20)
    TextLabel.Text = Config.Text
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 10
    TextLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1

    Bar.Parent = Notif
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.Size = UDim2.new(1, 0, 0, 2)
    Bar.BackgroundColor3 = NeverLose.AccentColor
    Bar.BorderSizePixel = 0

    TweenService:Create(Bar, TweenInfo.new(Config.Duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

    task.delay(Config.Duration, function()
        TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
        task.delay(0.3, function()
            Notif:Destroy()
        end)
    end)
end

-- Watermark (Информационный оверлей)
function NeverLose:SetWatermark(Text)
    local Watermark = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local Label = Instance.new("TextLabel")

    Watermark.Name = NeverLose.RandomString()
    Watermark.Parent = ScreenGui
    Watermark.Position = UDim2.new(0, 15, 0, 15)
    Watermark.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
    Watermark.Size = UDim2.new(0, 180, 0, 24)

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Watermark

    UIStroke.Transparency = 0.700
    UIStroke.Color = Color3.fromRGB(45, 48, 58)
    UIStroke.Parent = Watermark

    Label.Parent = Watermark
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text or "Neverlose.cc | User | FPS: 60"
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 10
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
end

-- Keybind List Display (Окно активных биндов)
function NeverLose:CreateKeybindList()
    local KeyList = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local Container = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")

    KeyList.Name = NeverLose.RandomString()
    KeyList.Parent = ScreenGui
    KeyList.Position = UDim2.new(0, 15, 0.4, 0)
    KeyList.Size = UDim2.new(0, 160, 0, 30)
    KeyList.BackgroundColor3 = Color3.fromRGB(15, 17, 23)

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = KeyList

    Title.Name = NeverLose.RandomString()
    Title.Parent = KeyList
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.Text = "Keybinds"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 10
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1

    Container.Name = NeverLose.RandomString()
    Container.Parent = KeyList
    Container.Position = UDim2.new(0, 5, 0, 25)
    Container.Size = UDim2.new(1, -10, 0, 0)
    Container.BackgroundTransparency = 1

    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    return KeyList
end

-- ========== ПОЛНЫЙ ПРИМЕР СБОРКИ МЕНЮ ==========

-- Инициализация окна
local Window = NeverLose:CreateWindow({
    Title = "Neverlose",
    SubTitle = "Roblox v2.0",
    Size = Vector2.new(620, 420),
    ToggleKey = Enum.KeyCode.RightShift
})

-- Размытие заднего плана
NeverLose:ToggleBlur(true, 18)

-- Создаем Handler для вкладок
local Handler = {}
Handler.PageContainer = Window.PageContainer
Handler.TabContainer = Window.TabContainer

-- Добавление вкладок
local LegitTab = NeverLose:AddTab(Handler, { 
    Name = NeverLose:GetText("Legitbot"), 
    Icon = "rbxassetid://0" 
})
local VisualsTab = NeverLose:AddTab(Handler, { 
    Name = NeverLose:GetText("Visuals"), 
    Icon = "rbxassetid://0" 
})
local ConfigsTab = NeverLose:AddTab(Handler, { 
    Name = NeverLose:GetText("Configs"), 
    Icon = "rbxassetid://0" 
})

-- Активируем первую вкладку
for _, tab in ipairs(NeverLose.Tabs) do
    if tab.Page then
        tab.Page.Visible = false
    end
end
LegitTab.Page.Visible = true

-- Создаем секции для Legitbot
local ElementHandler = {}
ElementHandler.Page = LegitTab.Page
ElementHandler.Signal = { 
    GetValue = function() return true end,
    Connect = function() return {Disconnect = function() end} end,
    SetValue = function() end
}

local MainSection = {}
MainSection.Container = NeverLose:AddSection(ElementHandler, { 
    Name = NeverLose:GetText("MainSettings")
})

local TargetSection = {}
TargetSection.Container = NeverLose:AddSection(ElementHandler, { 
    Name = NeverLose:GetText("Targeting")
})

-- Добавление элементов управления в MainSection
MainSection.Signal = ElementHandler.Signal

NeverLose:AddToggle(MainSection, {
    Default = false,
    Flag = "Legit_Enabled",
    Label = NeverLose:GetText("Enabled"),
    Callback = function(state)
        print("Aimbot:", state)
        if state and FOVCircle then
            FOVCircle:SetVisible(true)
        elseif FOVCircle then
            FOVCircle:SetVisible(false)
        end
    end
})

NeverLose:AddSlider(MainSection, {
    Default = 90,
    Min = 0,
    Max = 300,
    Type = "°",
    Flag = "Legit_FOV",
    Label = NeverLose:GetText("FOV"),
    Callback = function(val)
        print("FOV:", val)
        if FOVCircle then
            FOVCircle:SetRadius(val)
        end
    end
})

-- Добавление элементов управления в TargetSection
TargetSection.Signal = ElementHandler.Signal

NeverLose:AddDropdown(TargetSection, {
    Default = "Head",
    Options = { "Head", "Torso", "HumanoidRootPart" },
    Multi = false,
    Flag = "Legit_Hitbox",
    Label = NeverLose:GetText("Hitbox"),
    Callback = function(selected)
        print("Hitbox:", selected)
    end
})

NeverLose:AddColorPicker(TargetSection, {
    Default = Color3.fromRGB(0, 150, 255),
    Flag = "Accent_Color",
    Label = NeverLose:GetText("AccentColor"),
    Callback = function(color)
        NeverLose.AccentColor = color
        if FOVCircle then
            FOVCircle.Circle.Color = color
        end
    end
})

-- Создаем FOV Circle
local FOVCircle = NeverLose:CreateFOVCircle({
    Radius = 90,
    Color = NeverLose.AccentColor,
    Visible = false,
    Thickness = 1.5
})

-- Секция сохранения конфигов
local ConfigSection = {}
ConfigSection.Container = NeverLose:AddSection({ Page = ConfigsTab.Page }, { 
    Name = NeverLose:GetText("Configuration")
})
ConfigSection.Signal = ElementHandler.Signal

NeverLose:AddButton(ConfigSection, {
    Text = NeverLose:GetText("SaveConfig"),
    Callback = function()
        NeverLose:SaveConfig("default")
        NeverLose:Notification({ 
            Title = NeverLose:GetText("Config"), 
            Text = NeverLose:GetText("Saved"), 
            Duration = 3 
        })
    end
})

NeverLose:AddButton(ConfigSection, {
    Text = NeverLose:GetText("LoadConfig"),
    Callback = function()
        NeverLose:LoadConfig("default")
        NeverLose:Notification({ 
            Title = NeverLose:GetText("Config"), 
            Text = NeverLose:GetText("Loaded"), 
            Duration = 3 
        })
    end
})

-- Кнопка смены языка
NeverLose:AddButton(ConfigSection, {
    Text = "Switch to RU / EN",
    Callback = function()
        if NeverLose.CurrentLang == "EN" then
            NeverLose:SetLanguage("RU")
        else
            NeverLose:SetLanguage("EN")
        end
        NeverLose:Notification({
            Title = "Language",
            Text = "Switched to " .. NeverLose.CurrentLang,
            Duration = 2
        })
    end
})

-- Установка водяного знака
NeverLose:SetWatermark("Neverlose.cc | User: Dev | 60 FPS")

-- Отправка приветственного уведомления
task.delay(1, function()
    NeverLose:Notification({
        Title = NeverLose:GetText("Welcome"),
        Text = NeverLose:GetText("LoadedMessage"),
        Duration = 4
    })
end)

print("NeverLose библиотека полностью загружена!")
print("Доступны все компоненты:")
print("✓ Вкладки, Секции")
print("✓ Toggle, Slider, Keybind, ColorPicker, Dropdown, Button, Label, Divider, TextInput, Option")
print("✓ Уведомления, Водяной знак, Список биндов")
print("✓ Размытие фона, FOV круг")
print("✓ Локализация EN/RU")
print("✓ Сохранение/загрузка конфигов")
print("Нажмите RightShift для показа/скрытия меню")
