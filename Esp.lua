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
    bg = Color3.fromRGB(15, 5, 20),          -- Тёмно-фиолетовый фон
    titleBg = Color3.fromRGB(25, 10, 35),     -- Заголовок
    tabBg = Color3.fromRGB(20, 8, 30),        -- Фон вкладок
    tabActive = Color3.fromRGB(80, 20, 100),  -- Активная вкладка
    tabInactive = Color3.fromRGB(30, 12, 45), -- Неактивная вкладка
    accent = Color3.fromRGB(180, 50, 220),    -- Акцентный фиолетовый
    gold = Color3.fromRGB(255, 180, 50),      -- Золотой для заголовка
    text = Color3.fromRGB(220, 200, 230),     -- Светло-фиолетовый текст
    textDark = Color3.fromRGB(150, 130, 160), -- Тёмный текст
    close = Color3.fromRGB(120, 20, 20),      -- Кнопка закрытия
    stroke = Color3.fromRGB(100, 50, 130),    -- Обводка
}

-- Основной фрейм (560x340 - компактнее для мобильных)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 560, 0, 340)
Main.Position = UDim2.new(0.5, -280, 0.5, -170)
Main.BackgroundColor3 = colors.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

-- UICorner с скруглением
local corner = Instance.new("UICorner", Main)
corner.CornerRadius = UDim.new(0, 12)

-- Stroke с фиолетовым оттенком
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = colors.stroke
Stroke.Transparency = 0.4
Stroke.Thickness = 1.5

-- Градиентный акцент сверху
local AccentLine = Instance.new("Frame", Main)
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, 0, 0, 3)
AccentLine.BackgroundColor3 = colors.accent
AccentLine.BorderSizePixel = 0
Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(0, 12)

local Gradient = Instance.new("UIGradient", AccentLine)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 30, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 180))
}

-- Декоративные звёзды (точки)
for i = 1, 5 do
    local star = Instance.new("Frame", Main)
    star.Size = UDim2.new(0, 2, 0, 2)
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
    star.BorderSizePixel = 0
    star.BackgroundTransparency = math.random(3, 7) / 10
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 1)
end

-- Заголовок с кнопками управления
local TitleBar = Instance.new("Frame", Main)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.Position = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundColor3 = colors.titleBg
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

-- Заголовок текст "Dark Fantasy"
local Title = Instance.new("TextLabel", TitleBar)
Title.Name = "Title"
Title.Text = "Dark Fantasy"
Title.Size = UDim2.new(0, 100, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Тень заголовка
local TitleShadow = Instance.new("TextLabel", TitleBar)
TitleShadow.Name = "TitleShadow"
TitleShadow.Text = "Dark Fantasy"
TitleShadow.Size = UDim2.new(0, 100, 1, 0)
TitleShadow.Position = UDim2.new(0, 13, 0, 1)
TitleShadow.BackgroundTransparency = 1
TitleShadow.TextColor3 = Color3.fromRGB(80, 20, 120)
TitleShadow.Font = Enum.Font.GothamBlack
TitleShadow.TextSize = 13
TitleShadow.TextXAlignment = Enum.TextXAlignment.Left
TitleShadow.ZIndex = 0

-- Кнопка сворачивания
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Text = "━"
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(1, -48, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 10
MinimizeBtn.BorderSizePixel = 0
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)
MinimizeBtn.AutoButtonColor = false

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -24, 0, 5)
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.AutoButtonColor = false

-- Контейнер для всего кроме заголовка (сворачиваемая часть)
local CollapsibleContent = Instance.new("Frame", Main)
CollapsibleContent.Name = "CollapsibleContent"
CollapsibleContent.Size = UDim2.new(1, 0, 1, -35)
CollapsibleContent.Position = UDim2.new(0, 0, 0, 35)
CollapsibleContent.BackgroundTransparency = 1
CollapsibleContent.BorderSizePixel = 0

-- Контейнер для вкладок
local TabButtonsFrame = Instance.new("Frame", CollapsibleContent)
TabButtonsFrame.Name = "TabButtons"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 28)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 0)
TabButtonsFrame.BackgroundColor3 = colors.tabBg
TabButtonsFrame.BackgroundTransparency = 0.3
TabButtonsFrame.BorderSizePixel = 0

-- UIListLayout для автоматического расположения
local layout = Instance.new("UIListLayout", TabButtonsFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 2)

-- Контейнер для контента вкладок
local ContentContainer = Instance.new("Frame", CollapsibleContent)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -16, 1, -34)
ContentContainer.Position = UDim2.new(0, 8, 0, 32)
ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 3, 15)
ContentContainer.BackgroundTransparency = 0.5
ContentContainer.BorderSizePixel = 0
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 8)

-- Вкладки и контент
local tabs = {}
local tabButtons = {}
local tabNames = {"Info", "Main", "Player", "Esp", "Discord", "Settings"}
local isMinimized = false

local function createTab(name)
    local tabContent = Instance.new("Frame", ContentContainer)
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    
    -- Заголовок вкладки с иконкой
    local tabTitle = Instance.new("TextLabel", tabContent)
    tabTitle.Text = "✦ " .. name .. " ✦"
    tabTitle.Size = UDim2.new(1, 0, 0, 20)
    tabTitle.Position = UDim2.new(0, 0, 0, 5)
    tabTitle.BackgroundTransparency = 1
    tabTitle.TextColor3 = colors.gold
    tabTitle.Font = Enum.Font.GothamBlack
    tabTitle.TextSize = 11
    
    if name == "Info" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, -30)
        scrollFrame.Position = UDim2.new(0, 0, 0, 28)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 220)
        
        local serverInfo = Instance.new("TextLabel", scrollFrame)
        serverInfo.Text = "🌙 North Holland, NL\n\n⚔️ Пинг: 407 | ФПС: 29\n📜 Версия: 14806\n\n🏰 Сервер антивидов\n⏳ Время: 08:12:35\n👥 Игроков: 6,658\n\n🔮 Distorted Report - 4638"
        serverInfo.Size = UDim2.new(1, -8, 1, 0)
        serverInfo.Position = UDim2.new(0, 4, 0, 0)
        serverInfo.BackgroundTransparency = 1
        serverInfo.TextColor3 = colors.text
        serverInfo.Font = Enum.Font.Gotham
        serverInfo.TextSize = 11
        serverInfo.TextWrapped = true
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Main" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, -30)
        scrollFrame.Position = UDim2.new(0, 0, 0, 28)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 2
        scrollFrame.ScrollBarImageColor3 = colors.accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
        
        local features = Instance.new("TextLabel", scrollFrame)
        features.Text = "⚡ Auto Farm\n🎯 Auto Parry\n🚪 Delete Doors\n🎬 Skip Cutscene\n🔧 Auto Generator\n📦 Auto Barricade\n👁️ Invisible Killer\n💥 Hitbox Expender\n⚡ Instant Prompt"
        features.Size = UDim2.new(1, -8, 1, 0)
        features.Position = UDim2.new(0, 4, 0, 0)
        features.BackgroundTransparency = 1
        features.TextColor3 = colors.text
        features.Font = Enum.Font.Gotham
        features.TextSize = 11
        features.TextWrapped = true
        features.TextXAlignment = Enum.TextXAlignment.Left
        features.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Player" then
        local features = Instance.new("TextLabel", tabContent)
        features.Text = "🏃 Run Speed\n🚶 Walk Speed\n🦘 Jump Power\n✈️ Fly\n🚫 Noclip\n⚡ Infinite Stamina"
        features.Size = UDim2.new(1, 0, 1, -30)
        features.Position = UDim2.new(0, 4, 0, 28)
        features.BackgroundTransparency = 1
        features.TextColor3 = colors.text
        features.Font = Enum.Font.Gotham
        features.TextSize = 11
        features.TextWrapped = true
        features.TextXAlignment = Enum.TextXAlignment.Left
        features.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Esp" then
        local features = Instance.new("TextLabel", tabContent)
        features.Text = "👁️ ESP Survivors\n🔴 ESP Killers\n⚡ ESP Generators\n📦 ESP Fuse Boxes\n🔋 ESP Battery\n🪤 ESP Traps\n👁️ ESP Wire Eyes"
        features.Size = UDim2.new(1, 0, 1, -30)
        features.Position = UDim2.new(0, 4, 0, 28)
        features.BackgroundTransparency = 1
        features.TextColor3 = colors.text
        features.Font = Enum.Font.Gotham
        features.TextSize = 11
        features.TextWrapped = true
        features.TextXAlignment = Enum.TextXAlignment.Left
        features.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Discord" then
        local content = Instance.new("TextLabel", tabContent)
        content.Text = "🎮 Discord Server\n📋 Copy Link\n\n🔗 discord.gg/E2TqYRsRP4"
        content.Size = UDim2.new(1, 0, 1, -30)
        content.Position = UDim2.new(0, 4, 0, 28)
        content.BackgroundTransparency = 1
        content.TextColor3 = colors.text
        content.Font = Enum.Font.Gotham
        content.TextSize = 11
        content.TextWrapped = true
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Settings" then
        local features = Instance.new("TextLabel", tabContent)
        features.Text = "🎨 Change Theme\n📏 ESP Distance\n📐 Line ESP\n🔄 Unload Cheat\n\n⚜️ Version: 0.52"
        features.Size = UDim2.new(1, 0, 1, -30)
        features.Position = UDim2.new(0, 4, 0, 28)
        features.BackgroundTransparency = 1
        features.TextColor3 = colors.text
        features.Font = Enum.Font.Gotham
        features.TextSize = 11
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

-- Функция сворачивания/разворачивания
local function toggleMinimize()
    isMinimized = not isMinimized
    local currentPos = Main.Position
    
    if isMinimized then
        Main.Size = UDim2.new(0, 160, 0, 32)
        Main.Position = currentPos
        
        Title.TextSize = 11
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Position = UDim2.new(0, 25, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Center
        TitleShadow.Visible = false
        
        MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
        MinimizeBtn.Position = UDim2.new(1, -44, 0, 6)
        MinimizeBtn.TextSize = 9
        CloseBtn.Size = UDim2.new(0, 20, 0, 20)
        CloseBtn.Position = UDim2.new(1, -22, 0, 6)
        CloseBtn.TextSize = 10
        
        MinimizeBtn.Text = "✦"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 80)
        CollapsibleContent.Visible = false
        AccentLine.Visible = false
    else
        Main.Size = UDim2.new(0, 560, 0, 340)
        Main.Position = currentPos
        
        Title.TextSize = 13
        Title.Size = UDim2.new(0, 100, 1, 0)
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        TitleShadow.Visible = true
        
        MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
        MinimizeBtn.Position = UDim2.new(1, -48, 0, 5)
        MinimizeBtn.TextSize = 10
        CloseBtn.Size = UDim2.new(0, 22, 0, 22)
        CloseBtn.Position = UDim2.new(1, -24, 0, 5)
        CloseBtn.TextSize = 11
        
        MinimizeBtn.Text = "━"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
        CollapsibleContent.Visible = true
        AccentLine.Visible = true
    end
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Создаём кнопки вкладок
for _, name in ipairs(tabNames) do
    local tabButton = Instance.new("TextButton", TabButtonsFrame)
    tabButton.Name = name
    tabButton.Text = name
    tabButton.Size = UDim2.new(0, 85, 1, 0)
    tabButton.BackgroundColor3 = colors.tabInactive
    tabButton.TextColor3 = colors.textDark
    tabButton.Font = Enum.Font.GothamBlack
    tabButton.TextSize = 10
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 5)
    
    tabs[name] = createTab(name)
    tabButtons[name] = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- Показываем вкладку Main первой
switchTab("Main")

-- ===== СКРИПТ ПЕРЕТАСКИВАНИЯ =====
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
-- =====================================

-- Анимация появления
Main.Position = UDim2.new(0.5, -280, 0.8, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    Position = UDim2.new(0.5, -280, 0.5, -170)
}):Play()

print("Dark Fantasy GUI 560x340 loaded!")
