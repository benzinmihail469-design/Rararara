local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkFantasy_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Цветовая палитра Dark Fantasy
local colors = {
    bg = Color3.fromRGB(15, 5, 20),
    titleBg = Color3.fromRGB(25, 10, 35),
    tabBg = Color3.fromRGB(20, 8, 30),
    tabActive = Color3.fromRGB(80, 20, 100),
    tabInactive = Color3.fromRGB(30, 12, 45),
    accent = Color3.fromRGB(180, 50, 220),
    gold = Color3.fromRGB(255, 180, 50),
    text = Color3.fromRGB(220, 200, 230),
    textDark = Color3.fromRGB(150, 130, 160),
    close = Color3.fromRGB(180, 30, 30),
    stroke = Color3.fromRGB(100, 50, 130),
    toggleOn = Color3.fromRGB(100, 30, 160),
    toggleOff = Color3.fromRGB(35, 15, 55),
    toggleCircle = Color3.fromRGB(220, 180, 255),
    buttonBg = Color3.fromRGB(50, 20, 80),
    buttonHover = Color3.fromRGB(70, 30, 110),
}

-- Основной фрейм (520x360)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = colors.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local corner = Instance.new("UICorner", Main)
corner.CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = colors.stroke
Stroke.Transparency = 0.4
Stroke.Thickness = 1.5

-- Градиентный акцент сверху
local AccentLine = Instance.new("Frame", Main)
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.BackgroundColor3 = colors.accent
AccentLine.BorderSizePixel = 0
Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(0, 12)

local Gradient = Instance.new("UIGradient", AccentLine)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 30, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 180))
}

-- Заголовок
local TitleBar = Instance.new("Frame", Main)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 2)
TitleBar.BackgroundColor3 = colors.titleBg
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

-- Заголовок текст
local Title = Instance.new("TextLabel", TitleBar)
Title.Name = "Title"
Title.Text = "Темный Fantasy"
Title.Size = UDim2.new(0, 110, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка сворачивания
local MinimizeBtn = Instance.new("TextButton", Main)
MinimizeBtn.Text = "—"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -52, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 10
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)
MinimizeBtn.AutoButtonColor = false

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 5)
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.AutoButtonColor = false

-- Контейнер для контента
local CollapsibleContent = Instance.new("Frame", Main)
CollapsibleContent.Name = "CollapsibleContent"
CollapsibleContent.Size = UDim2.new(1, 0, 1, -32)
CollapsibleContent.Position = UDim2.new(0, 0, 0, 32)
CollapsibleContent.BackgroundTransparency = 1
CollapsibleContent.BorderSizePixel = 0

-- Контейнер для вкладок
local TabButtonsFrame = Instance.new("Frame", CollapsibleContent)
TabButtonsFrame.Name = "TabButtons"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 26)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 0)
TabButtonsFrame.BackgroundColor3 = colors.tabBg
TabButtonsFrame.BackgroundTransparency = 0.3
TabButtonsFrame.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", TabButtonsFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 2)

-- Контейнер для контента вкладок
local ContentContainer = Instance.new("Frame", CollapsibleContent)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -16, 1, -32)
ContentContainer.Position = UDim2.new(0, 8, 0, 30)
ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 3, 15)
ContentContainer.BackgroundTransparency = 0.5
ContentContainer.BorderSizePixel = 0
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 8)

-- Функция создания Toggle кнопки (рабочая)
local function createToggle(parent, name, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    -- Кнопка с названием
    local button = Instance.new("TextButton", container)
    button.Text = name
    button.Size = UDim2.new(1, -50, 0, 24)
    button.Position = UDim2.new(0, 8, 0, 3)
    button.BackgroundColor3 = Color3.fromRGB(30, 12, 45)
    button.TextColor3 = colors.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.ZIndex = 5
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    
    -- Сам переключатель
    local toggleFrame = Instance.new("Frame", container)
    toggleFrame.Size = UDim2.new(0, 36, 0, 18)
    toggleFrame.Position = UDim2.new(1, -42, 0, 6)
    toggleFrame.BackgroundColor3 = colors.toggleOff
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 6
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 9)
    
    local toggleCircle = Instance.new("Frame", toggleFrame)
    toggleCircle.Size = UDim2.new(0, 14, 0, 14)
    toggleCircle.Position = UDim2.new(0, 2, 0, 2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(100, 80, 120)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 7
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(0, 7)
    
    local isOn = default
    
    local function updateToggle()
        if isOn then
            toggleFrame.BackgroundColor3 = colors.toggleOn
            toggleCircle.BackgroundColor3 = colors.toggleCircle
            TweenService:Create(toggleCircle, TweenInfo.new(0.15), {
                Position = UDim2.new(1, -16, 0, 2)
            }):Play()
        else
            toggleFrame.BackgroundColor3 = colors.toggleOff
            toggleCircle.BackgroundColor3 = Color3.fromRGB(100, 80, 120)
            TweenService:Create(toggleCircle, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
        end
    end
    
    updateToggle()
    
    -- Клик по кнопке
    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggle()
        if callback then callback(isOn) end
    end)
    
    -- Клик по переключателю
    local toggleButton = Instance.new("TextButton", toggleFrame)
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.BorderSizePixel = 0
    toggleButton.ZIndex = 8
    
    toggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggle()
        if callback then callback(isOn) end
    end)
    
    return container
end

-- Функция создания обычной кнопки (рабочая)
local function createButton(parent, name, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    local button = Instance.new("TextButton", container)
    button.Text = name
    button.Size = UDim2.new(1, -16, 0, 28)
    button.Position = UDim2.new(0, 8, 0, 2)
    button.BackgroundColor3 = colors.buttonBg
    button.TextColor3 = colors.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.ZIndex = 5
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    
    -- Эффект при наведении
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = colors.buttonHover
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = colors.buttonBg
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return container
end

-- Вкладки
local tabs = {}
local tabButtons = {}
local tabNames = {"Main", "Player", "Esp", "Info", "Discord", "Настройки"}
local isMinimized = false

local function createTab(name)
    local tabContent = Instance.new("Frame", ContentContainer)
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    
    if name == "Main" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
        
        -- Все функции как кнопки
        local y = 5
        local spacing = 33
        
        -- Toggle кнопки
        createToggle(scrollFrame, "⚡ Auto Farm", false, function(val) print("Auto Farm:", val) end)
        
        local t2 = createToggle(scrollFrame, "🎯 Auto Parry", false, function(val) print("Auto Parry:", val) end)
        t2.Position = UDim2.new(0, 0, 0, y + spacing)
        
        local t3 = createToggle(scrollFrame, "🔧 Auto Generator", false, function(val) print("Auto Generator:", val) end)
        t3.Position = UDim2.new(0, 0, 0, y + spacing*2)
        
        local t4 = createToggle(scrollFrame, "🚪 Auto Escape", false, function(val) print("Auto Escape:", val) end)
        t4.Position = UDim2.new(0, 0, 0, y + spacing*3)
        
        local t5 = createToggle(scrollFrame, "📦 Auto Barricade", false, function(val) print("Auto Barricade:", val) end)
        t5.Position = UDim2.new(0, 0, 0, y + spacing*4)
        
        local t6 = createToggle(scrollFrame, "👁️ Invisible Killer", false, function(val) print("Invisible Killer:", val) end)
        t6.Position = UDim2.new(0, 0, 0, y + spacing*5)
        
        local t7 = createToggle(scrollFrame, "💥 Hitbox Expender", false, function(val) print("Hitbox Expender:", val) end)
        t7.Position = UDim2.new(0, 0, 0, y + spacing*6)
        
        -- Обычные кнопки
        local b1 = createButton(scrollFrame, "🚪 Delete Doors", function() print("Delete Doors clicked!") end)
        b1.Position = UDim2.new(0, 0, 0, y + spacing*7 + 10)
        
        local b2 = createButton(scrollFrame, "🎬 Skip Cutscene", function() print("Skip Cutscene clicked!") end)
        b2.Position = UDim2.new(0, 0, 0, y + spacing*8 + 10)
        
        local b3 = createButton(scrollFrame, "⚡ Instant Win", function() print("Instant Win clicked!") end)
        b3.Position = UDim2.new(0, 0, 0, y + spacing*9 + 10)
        
    elseif name == "Player" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
        
        local y = 5
        local spacing = 33
        
        createToggle(scrollFrame, "🚫 Noclip", false, function(val) print("Noclip:", val) end)
        
        local p2 = createToggle(scrollFrame, "✈️ Fly", false, function(val) print("Fly:", val) end)
        p2.Position = UDim2.new(0, 0, 0, y + spacing)
        
        local p3 = createToggle(scrollFrame, "🦘 Infinity Jump", false, function(val) print("Infinity Jump:", val) end)
        p3.Position = UDim2.new(0, 0, 0, y + spacing*2)
        
        local p4 = createToggle(scrollFrame, "⚡ Infinite Stamina", false, function(val) print("Infinite Stamina:", val) end)
        p4.Position = UDim2.new(0, 0, 0, y + spacing*3)
        
        local p5 = createToggle(scrollFrame, "🏃 Speed Boost", false, function(val) print("Speed Boost:", val) end)
        p5.Position = UDim2.new(0, 0, 0, y + spacing*4)
        
    elseif name == "Esp" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 270)
        
        local y = 5
        local spacing = 33
        
        createToggle(scrollFrame, "👁️ ESP Survivors", false, function(val) print("ESP Survivors:", val) end)
        
        local e2 = createToggle(scrollFrame, "🔴 ESP Killers", false, function(val) print("ESP Killers:", val) end)
        e2.Position = UDim2.new(0, 0, 0, y + spacing)
        
        local e3 = createToggle(scrollFrame, "⚡ ESP Generators", false, function(val) print("ESP Generators:", val) end)
        e3.Position = UDim2.new(0, 0, 0, y + spacing*2)
        
        local e4 = createToggle(scrollFrame, "📦 ESP Fuse Boxes", false, function(val) print("ESP Fuse Boxes:", val) end)
        e4.Position = UDim2.new(0, 0, 0, y + spacing*3)
        
        local e5 = createToggle(scrollFrame, "🔋 ESP Battery", false, function(val) print("ESP Battery:", val) end)
        e5.Position = UDim2.new(0, 0, 0, y + spacing*4)
        
        local e6 = createToggle(scrollFrame, "🪤 ESP Traps", false, function(val) print("ESP Traps:", val) end)
        e6.Position = UDim2.new(0, 0, 0, y + spacing*5)
        
        local e7 = createToggle(scrollFrame, "👁️ ESP Wire Eyes", false, function(val) print("ESP Wire Eyes:", val) end)
        e7.Position = UDim2.new(0, 0, 0, y + spacing*6)
        
    elseif name == "Info" then
        local serverInfo = Instance.new("TextLabel", tabContent)
        serverInfo.Text = "🌙 Texac, США\n⚔️ Пинг: 415 | ФПС: 17\n📜 Версия: 14808\n🏰 Сервер античного\n⏳ Время: 12:33:03\n👥 Plutonium Dancer - 7894\n🔢 6,658"
        serverInfo.Size = UDim2.new(1, -8, 1, 0)
        serverInfo.Position = UDim2.new(0, 4, 0, 10)
        serverInfo.BackgroundTransparency = 1
        serverInfo.TextColor3 = colors.text
        serverInfo.Font = Enum.Font.Gotham
        serverInfo.TextSize = 11
        serverInfo.TextWrapped = true
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Discord" then
        local content = Instance.new("TextLabel", tabContent)
        content.Text = "🎮 Discord Server\n📋 Copy Link\n\n🔗 discord.gg/E2TqYRsRP4"
        content.Size = UDim2.new(1, 0, 1, 0)
        content.Position = UDim2.new(0, 4, 0, 10)
        content.BackgroundTransparency = 1
        content.TextColor3 = colors.text
        content.Font = Enum.Font.Gotham
        content.TextSize = 11
        content.TextWrapped = true
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Настройки" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 150)
        
        local s1 = createButton(scrollFrame, "🎨 Change Theme", function() print("Change Theme clicked!") end)
        s1.Position = UDim2.new(0, 0, 0, 5)
        
        local s2 = createButton(scrollFrame, "🔄 Unload Script", function() ScreenGui:Destroy() end)
        s2.Position = UDim2.new(0, 0, 0, 40)
        
        local version = Instance.new("TextLabel", scrollFrame)
        version.Text = "⚜️ Version: 0.52"
        version.Size = UDim2.new(1, 0, 0, 20)
        version.Position = UDim2.new(0, 0, 0, 80)
        version.BackgroundTransparency = 1
        version.TextColor3 = colors.gold
        version.Font = Enum.Font.GothamBlack
        version.TextSize = 10
    end
    
    return tabContent
end

local function switchTab(tabName)
    for name, content in pairs(tabs) do
        content.Visible = (name == tabName)
    end
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = colors.tabActive
            button.TextColor3 = colors.gold
        else
            button.BackgroundColor3 = colors.tabInactive
            button.TextColor3 = colors.textDark
        end
    end
end

-- Сворачивание
local function toggleMinimize()
    isMinimized = not isMinimized
    local currentPos = Main.Position
    
    if isMinimized then
        Main.Size = UDim2.new(0, 220, 0, 32)
        Main.Position = currentPos
        Title.TextSize = 12
        Title.Size = UDim2.new(1, -56, 1, 0)
        Title.Position = UDim2.new(0, 28, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Center
        MinimizeBtn.Position = UDim2.new(1, -52, 0, 4)
        MinimizeBtn.Text = "+"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 80)
        CloseBtn.Position = UDim2.new(1, -26, 0, 4)
        CollapsibleContent.Visible = false
        AccentLine.Visible = false
    else
        Main.Size = UDim2.new(0, 520, 0, 360)
        Main.Position = currentPos
        Title.TextSize = 13
        Title.Size = UDim2.new(0, 110, 1, 0)
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        MinimizeBtn.Position = UDim2.new(1, -52, 0, 5)
        MinimizeBtn.Text = "—"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
        CloseBtn.Position = UDim2.new(1, -26, 0, 5)
        CollapsibleContent.Visible = true
        AccentLine.Visible = true
    end
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Создаём вкладки
for _, name in ipairs(tabNames) do
    local tabButton = Instance.new("TextButton", TabButtonsFrame)
    tabButton.Name = name
    tabButton.Text = name
    tabButton.Size = UDim2.new(0, 80, 1, 0)
    tabButton.BackgroundColor3 = colors.tabInactive
    tabButton.TextColor3 = colors.textDark
    tabButton.Font = Enum.Font.GothamBlack
    tabButton.TextSize = 9
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 5)
    
    tabs[name] = createTab(name)
    tabButtons[name] = tabButton
    
    tabButton.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Main")

-- Перетаскивание
local UIS = game:GetService("UserInputService")
local frame = TitleBar
local dragging, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Анимация появления
Main.Position = UDim2.new(0.5, -260, 0.8, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    Position = UDim2.new(0.5, -260, 0.5, -180)
}):Play()

print("Темный Fantasy GUI загружен! Все кнопки рабочие.")
