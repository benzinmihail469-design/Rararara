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
    sliderBg = Color3.fromRGB(40, 15, 60),
    sliderFill = Color3.fromRGB(120, 40, 180),
    buttonBg = Color3.fromRGB(50, 20, 80),
    buttonHover = Color3.fromRGB(80, 30, 120),
}

-- Основной фрейм (520x340 - чуть выше для слайдеров)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
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

-- Контейнер для всего кроме заголовка
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

-- Функция создания кнопки+слайдера
local function createButtonWithSlider(parent, name, min, max, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    -- Кнопка-лейбл
    local button = Instance.new("TextButton", container)
    button.Text = name
    button.Size = UDim2.new(0, 100, 0, 22)
    button.Position = UDim2.new(0, 0, 0, 3)
    button.BackgroundColor3 = colors.buttonBg
    button.TextColor3 = colors.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 9
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    
    -- Значение
    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Text = tostring(default)
    valueLabel.Size = UDim2.new(0, 35, 0, 22)
    valueLabel.Position = UDim2.new(1, -35, 0, 3)
    valueLabel.BackgroundColor3 = Color3.fromRGB(30, 12, 45)
    valueLabel.TextColor3 = colors.gold
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 9
    valueLabel.BorderSizePixel = 0
    Instance.new("UICorner", valueLabel).CornerRadius = UDim.new(0, 4)
    
    -- Слайдер
    local sliderFrame = Instance.new("Frame", container)
    sliderFrame.Size = UDim2.new(1, -145, 0, 14)
    sliderFrame.Position = UDim2.new(0, 105, 0, 7)
    sliderFrame.BackgroundColor3 = colors.sliderBg
    sliderFrame.BorderSizePixel = 0
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 7)
    
    local fill = Instance.new("Frame", sliderFrame)
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = colors.sliderFill
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 7)
    
    local knob = Instance.new("TextButton", sliderFrame)
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new((default - min) / (max - min), -9, 0, -2)
    knob.BackgroundColor3 = colors.accent
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.AutoButtonColor = false
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 9)
    
    -- Логика слайдера
    local dragging = false
    
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderFrame.AbsolutePosition.X
            local sliderWidth = sliderFrame.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
            local value = min + (max - min) * percent
            value = math.floor(value / 1) * 1 -- шаг 1
            knob.Position = UDim2.new(percent, -9, 0, -2)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderFrame.AbsolutePosition.X
            local sliderWidth = sliderFrame.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
            local value = min + (max - min) * percent
            value = math.floor(value / 1) * 1
            knob.Position = UDim2.new(percent, -9, 0, -2)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
    
    -- Кнопка быстрого сброса
    button.MouseButton1Click:Connect(function()
        local midValue = math.floor((min + max) / 2)
        local percent = (midValue - min) / (max - min)
        knob.Position = UDim2.new(percent, -9, 0, -2)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(midValue)
        if callback then callback(midValue) end
    end)
    
    return container
end

-- Вкладки
local tabs = {}
local tabButtons = {}
local tabNames = {"Discord", "Esp", "Info", "Main", "Player", "Настройки"}
local isMinimized = false

local function createTab(name)
    local tabContent = Instance.new("Frame", ContentContainer)
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    
    if name == "Player" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 250)
        
        local yPos = 5
        
        -- Run Speed
        createButtonWithSlider(scrollFrame, "🏃 Run Speed", 0, 50, 24, function(val)
            print("Run Speed:", val)
        end)
        
        -- Walk Speed
        local walkSlider = createButtonWithSlider(scrollFrame, "🚶 Walk Speed", 0, 30, 15, function(val)
            print("Walk Speed:", val)
        end)
        walkSlider.Position = UDim2.new(0, 0, 0, 35)
        
        -- Jump Power
        local jumpSlider = createButtonWithSlider(scrollFrame, "🦘 Jump Power", 0, 100, 50, function(val)
            print("Jump Power:", val)
        end)
        jumpSlider.Position = UDim2.new(0, 0, 0, 65)
        
        -- Fly Speed
        local flySlider = createButtonWithSlider(scrollFrame, "✈️ Fly Speed", 0, 10, 1, function(val)
            print("Fly Speed:", val)
        end)
        flySlider.Position = UDim2.new(0, 0, 0, 95)
        
        -- FOV
        local fovSlider = createButtonWithSlider(scrollFrame, "🔭 FOV", 30, 120, 70, function(val)
            print("FOV:", val)
        end)
        fovSlider.Position = UDim2.new(0, 0, 0, 125)
        
    elseif name == "Main" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
        
        -- Hitbox Size
        createButtonWithSlider(scrollFrame, "💥 Hitbox Size", 0, 30, 15, function(val)
            print("Hitbox:", val)
        end)
        
        -- Speed Boost
        local speedSlider = createButtonWithSlider(scrollFrame, "⚡ Speed Boost", 0, 100, 50, function(val)
            print("Speed Boost:", val)
        end)
        speedSlider.Position = UDim2.new(0, 0, 0, 35)
        
        -- Auto Farm Speed
        local farmSlider = createButtonWithSlider(scrollFrame, "🚜 Farm Speed", 1, 10, 5, function(val)
            print("Farm Speed:", val)
        end)
        farmSlider.Position = UDim2.new(0, 0, 0, 65)
        
        -- ESP Distance
        local espSlider = createButtonWithSlider(scrollFrame, "📏 ESP Distance", 50, 1000, 100, function(val)
            print("ESP Range:", val)
        end)
        espSlider.Position = UDim2.new(0, 0, 0, 95)
        
    elseif name == "Info" then
        local serverInfo = Instance.new("TextLabel", tabContent)
        serverInfo.Text = "🌙 Île-de-France, FR\n⚔️ Пинг: 111 | ФПС: 25\n📜 Версия: 14806\n🏰 Темный Fantasy\n⏳ Время работы сервера\n👥 Watching Aftermath - 5777\n🔢 60,658"
        serverInfo.Size = UDim2.new(1, -8, 1, 0)
        serverInfo.Position = UDim2.new(0, 4, 0, 10)
        serverInfo.BackgroundTransparency = 1
        serverInfo.TextColor3 = colors.text
        serverInfo.Font = Enum.Font.Gotham
        serverInfo.TextSize = 10
        serverInfo.TextWrapped = true
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Esp" then
        local features = Instance.new("TextLabel", tabContent)
        features.Text = "👁️ ESP Survivors\n🔴 ESP Killers\n⚡ ESP Generators\n📦 ESP Fuse Boxes\n🔋 ESP Battery\n🪤 ESP Traps\n👁️ ESP Wire Eyes"
        features.Size = UDim2.new(1, 0, 1, 0)
        features.Position = UDim2.new(0, 4, 0, 10)
        features.BackgroundTransparency = 1
        features.TextColor3 = colors.text
        features.Font = Enum.Font.Gotham
        features.TextSize = 10
        features.TextWrapped = true
        features.TextXAlignment = Enum.TextXAlignment.Left
        features.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Discord" then
        local content = Instance.new("TextLabel", tabContent)
        content.Text = "🎮 Discord Server\n📋 Copy Link\n\n🔗 discord.gg/E2TqYRsRP4"
        content.Size = UDim2.new(1, 0, 1, 0)
        content.Position = UDim2.new(0, 4, 0, 10)
        content.BackgroundTransparency = 1
        content.TextColor3 = colors.text
        content.Font = Enum.Font.Gotham
        content.TextSize = 10
        content.TextWrapped = true
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
        
    elseif name == "Настройки" then
        local features = Instance.new("TextLabel", tabContent)
        features.Text = "🎨 Change Theme\n📏 ESP Distance\n📐 Line ESP\n🔄 Unload Cheat\n\n⚜️ Version: 0.52"
        features.Size = UDim2.new(1, 0, 1, 0)
        features.Position = UDim2.new(0, 4, 0, 10)
        features.BackgroundTransparency = 1
        features.TextColor3 = colors.text
        features.Font = Enum.Font.Gotham
        features.TextSize = 10
        features.TextWrapped = true
        features.TextXAlignment = Enum.TextXAlignment.Left
        features.TextYAlignment = Enum.TextYAlignment.Top
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
        Main.Size = UDim2.new(0, 520, 0, 340)
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
    Position = UDim2.new(0.5, -260, 0.5, -170)
}):Play()

print("Темный Fantasy GUI с кнопками+слайдерами загружен!")
