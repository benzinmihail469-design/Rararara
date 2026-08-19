-- Полностью рабочий код библиотеки NeverLose со всеми элементами GUI
local NeverLose = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
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
    
    -- Простая палитра цветов
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

-- Функция для создания контейнера с методами
function NeverLose:CreateHandler(container)
    local handler = {}
    handler.Container = container
    
    -- Создаем методы для элементов
    handler.AddToggle = function(self, Config)
        return self:AddToggle(Config)
    end
    
    handler.AddSlider = function(self, Config)
        return self:AddSlider(Config)
    end
    
    handler.AddKeybind = function(self, Config)
        return self:AddKeybind(Config)
    end
    
    handler.AddColorPicker = function(self, Config)
        return self:AddColorPicker(Config)
    end
    
    handler.AddTextInput = function(self, Config)
        return self:AddTextInput(Config)
    end
    
    handler.AddOption = function(self, GearIcon)
        return self:AddOption(GearIcon)
    end
    
    return handler
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
        IsMobile = IsMobile,
        MainWidth = MainWidth,
        MainHeight = MainHeight,
        SidebarWidth = SidebarWidth,
        HeaderHeight = HeaderHeight,
        FooterHeight = FooterHeight
    }
end

-- ========== GUI ЭЛЕМЕНТЫ ==========

-- Toggle (Переключатель)
function NeverLose:AddToggle(Handler, Config) 
    Config = NeverLose:ProcessParams(Config , { 
        Default = false, 
        Flag = nil, 
        Callback = EmptyFunction, 
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local Toggle = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local Circle = Instance.new("Frame") 
    local UICorner_2 = Instance.new("UICorner") 
    
    Toggle.Name = NeverLose.RandomString(); 
    Toggle.Parent = Handler.Container or Handler
    Toggle.BackgroundColor3 = Color3.fromRGB(10, 13, 21) 
    Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Toggle.BorderSizePixel = 0 
    Toggle.ClipsDescendants = true 
    Toggle.Size = UDim2.new(0, 30, 0, 18) 
    Toggle.ZIndex = ZINdex + 13 
    Toggle.LayoutOrder = -(#(Handler.Container or Handler):GetChildren() + 5); 
    
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
    Slider.Parent = Handler.Container or Handler
    Slider.BackgroundColor3 = Color3.fromRGB(26, 28, 36) 
    Slider.BackgroundTransparency = 1.000 
    Slider.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Slider.BorderSizePixel = 0 
    Slider.ClipsDescendants = false 
    Slider.Size = UDim2.new(0, Config.Size, 0, 18) 
    Slider.ZIndex = ZINdex + 13 
    Slider.LayoutOrder = -(#(Handler.Container or Handler):GetChildren() + 5); 
    
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
        Flag = nil 
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local KeybindLib = {}; 
    local Keybind = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local UIStroke = Instance.new("UIStroke") 
    local ValueLabel = Instance.new("TextLabel") 
    
    Keybind.Name = NeverLose.RandomString(); 
    Keybind.Parent = Handler.Container or Handler
    Keybind.BackgroundColor3 = Color3.fromRGB(26, 28, 36) 
    Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Keybind.BorderSizePixel = 0 
    Keybind.ClipsDescendants = true 
    Keybind.Size = UDim2.new(0, 45, 0, 18) 
    Keybind.ZIndex = ZINdex + 13 
    Keybind.LayoutOrder = -(#(Handler.Container or Handler):GetChildren() + 5); 
    
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
        Flag = nil
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    if typeof(Config.Default) == 'string' then 
        Config.Default = Color3.fromHex(Config.Default:gsub('#','')); 
    end; 
    
    local ColorPickerLib = {}; 
    local ColorPicker = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local UIStroke = Instance.new("UIStroke") 
    local ImageLabel = Instance.new("ImageLabel") 
    local UICorner_2 = Instance.new("UICorner") 
    
    ColorPicker.Name = NeverLose.RandomString(); 
    ColorPicker.Parent = Handler.Container or Handler
    ColorPicker.BackgroundColor3 = Config.Default; 
    ColorPicker.BackgroundTransparency = 0 
    ColorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    ColorPicker.BorderSizePixel = 0 
    ColorPicker.ClipsDescendants = true 
    ColorPicker.Size = UDim2.new(0, 18, 0, 18) 
    ColorPicker.ZIndex = ZINdex + 13 
    ColorPicker.LayoutOrder = -(#(Handler.Container or Handler):GetChildren() + 5); 
    
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

-- Option Window & Button (Кнопка доп. настроек / Окно опций)
function NeverLose:AddOption(Handler, GearIcon) 
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local Option = Instance.new("Frame") 
    local Icon = Instance.new("TextLabel") 
    local UICorner = Instance.new("UICorner") 
    
    Option.Name = NeverLose.RandomString(); 
    Option.Parent = Handler.Container or Handler
    Option.BackgroundColor3 = Color3.fromRGB(39, 40, 49) 
    Option.BackgroundTransparency = 1.000 
    Option.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    Option.BorderSizePixel = 0 
    Option.ClipsDescendants = true 
    Option.Size = UDim2.new(0, 20, 0, 18) 
    Option.ZIndex = ZINdex + 13 
    Option.LayoutOrder = -(#(Handler.Container or Handler):GetChildren() + 5); 
    
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
    }); 
    
    local Signal = Handler.Signal or {GetValue = function() return true end, Connect = function() return {Disconnect = function() end} end}
    
    local TextBoxLib = {}; 
    local TextInput = Instance.new("Frame") 
    local UICorner = Instance.new("UICorner") 
    local UIStroke = Instance.new("UIStroke") 
    local TextBox = Instance.new("TextBox") 
    
    TextInput.Name = NeverLose.RandomString(); 
    TextInput.Parent = Handler.Container or Handler
    TextInput.BackgroundColor3 = Color3.fromRGB(26, 28, 36) 
    TextInput.BorderColor3 = Color3.fromRGB(0, 0, 0) 
    TextInput.BorderSizePixel = 0 
    TextInput.ClipsDescendants = true 
    TextInput.Size = UDim2.new(0, Config.Size, 0, 18) 
    TextInput.ZIndex = ZINdex + 13 
    TextInput.LayoutOrder = -(#(Handler.Container or Handler):GetChildren() + 5); 
    
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

-- ========== АВТОМАТИЧЕСКОЕ СОЗДАНИЕ GUI ==========

-- Создаем окно
local MainWindow = NeverLose:CreateWindow({
    Title = "Мой ГУИ",
    SubTitle = "Пример",
    ToggleKey = Enum.KeyCode.RightShift
})

-- Создаем контейнер для элементов с методами
local Handler = {}
Handler.Container = MainWindow.PageContainer
Handler.Signal = { 
    GetValue = function() return true end,
    Connect = function() return {Disconnect = function() end} end,
    SetValue = function() end
}

-- Создаем различные GUI элементы
local toggle = NeverLose:AddToggle(Handler, {
    Default = true,
    Flag = "Toggle1",
    Callback = function(value)
        print("Toggle: " .. tostring(value))
    end
})

local slider = NeverLose:AddSlider(Handler, {
    Default = 50,
    Min = 0,
    Max = 100,
    Type = "%",
    Rounding = 0,
    Flag = "Slider1",
    Callback = function(value)
        print("Slider: " .. tostring(value))
    end
})

local keybind = NeverLose:AddKeybind(Handler, {
    Default = "F",
    Blacklist = {"Escape", "P"},
    Flag = "Keybind1",
    Callback = function(key)
        print("Keybind: " .. tostring(key))
    end
})

local colorpicker = NeverLose:AddColorPicker(Handler, {
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "Color1",
    Callback = function(color)
        print("Color selected")
    end
})

local textinput = NeverLose:AddTextInput(Handler, {
    Default = "Hello",
    Placeholder = "Type here...",
    Flag = "Text1",
    Size = 150,
    Callback = function(text)
        print("Text: " .. text)
    end
})

print("Библиотека NeverLose успешно загружена!")
print("Нажмите RightShift, чтобы показать/скрыть окно")
