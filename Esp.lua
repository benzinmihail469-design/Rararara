local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BBN_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основной фрейм (650x380)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 650, 0, 380)
Main.Position = UDim2.new(0.5, -325, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Stroke
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(50, 50, 60)
Stroke.Transparency = 0.6
Stroke.Thickness = 1

-- Заголовок с кнопками управления
local TitleBar = Instance.new("Frame", Main)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

-- Заголовок текст
local Title = Instance.new("TextLabel", TitleBar)
Title.Name = "Title"
Title.Text = "BBN"
Title.Size = UDim2.new(0, 50, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка сворачивания
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Text = "—"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -54, 0, 2)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 12
MinimizeBtn.BorderSizePixel = 0
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 12)
MinimizeBtn.AutoButtonColor = false

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 12)
CloseBtn.AutoButtonColor = false

-- Контейнер для всего кроме заголовка (сворачиваемая часть)
local CollapsibleContent = Instance.new("Frame", Main)
CollapsibleContent.Name = "CollapsibleContent"
CollapsibleContent.Size = UDim2.new(1, 0, 1, -28)
CollapsibleContent.Position = UDim2.new(0, 0, 0, 28)
CollapsibleContent.BackgroundTransparency = 1
CollapsibleContent.BorderSizePixel = 0

-- Контейнер для вкладок
local TabButtonsFrame = Instance.new("Frame", CollapsibleContent)
TabButtonsFrame.Name = "TabButtons"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 28)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 0)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TabButtonsFrame.BorderSizePixel = 0

-- UIListLayout для автоматического расположения
local layout = Instance.new("UIListLayout", TabButtonsFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 3)

-- Контейнер для контента вкладок
local ContentContainer = Instance.new("Frame", CollapsibleContent)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -16, 1, -34)
ContentContainer.Position = UDim2.new(0, 8, 0, 32)
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentContainer.BorderSizePixel = 0

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
    
    if name == "Info" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 250)
        
        local serverInfo = Instance.new("TextLabel", scrollFrame)
        serverInfo.Text = "🌍 North Holland, NL\n📊 Пинг: 407 | ФПС: 29\n📊 Версия: 14806\n🎮 Сервер антивидов\n⏱️ Время: 08:12:35\n👥 Игроков: 6,658\n📌 Distorted Report - 4638"
        serverInfo.Size = UDim2.new(1, -8, 1, 0)
        serverInfo.Position = UDim2.new(0, 4, 0, 0)
        serverInfo.BackgroundTransparency = 1
        serverInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        serverInfo.Font = Enum.Font.Gotham
        serverInfo.TextSize = 12
        serverInfo.TextWrapped = true
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Main" then
        local scrollFrame = Instance.new("ScrollingFrame", tabContent)
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 220)
        
        local placeholder = Instance.new("TextLabel", scrollFrame)
        placeholder.Text = "⚡ Auto Farm\n🎯 Auto Parry\n🚪 Delete Doors\n🎬 Skip Cutscene\n🔧 Auto Generator\n📦 Auto Barricade\n👁️ Invisible Killer\n💥 Hitbox Expender\n⚡ Instant Prompt"
        placeholder.Size = UDim2.new(1, -8, 1, 0)
        placeholder.Position = UDim2.new(0, 4, 0, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 12
        placeholder.TextWrapped = true
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Player" then
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = "🏃 Run Speed\n🚶 Walk Speed\n🦘 Jump Power\n✈️ Fly\n🚫 Noclip\n⚡ Infinite Stamina"
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 12
        placeholder.TextWrapped = true
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Esp" then
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = "👁️ ESP Survivors\n🔴 ESP Killers\n⚡ ESP Generators\n📦 ESP Fuse Boxes\n🔋 ESP Battery\n🪤 ESP Traps\n👁️ ESP Wire Eyes"
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 12
        placeholder.TextWrapped = true
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Discord" then
        local content = Instance.new("TextLabel", tabContent)
        content.Text = "🎮 Discord Server\n📋 Copy Link\n\ndiscord.gg/E2TqYRsRP4"
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.TextColor3 = Color3.fromRGB(200, 200, 200)
        content.Font = Enum.Font.Gotham
        content.TextSize = 12
        content.TextWrapped = true
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Settings" then
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = "🎨 Change Theme\n📏 ESP Distance\n📐 Line ESP\n🔄 Unload Cheat\n\nVersion: 0.52"
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 12
        placeholder.TextWrapped = true
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.TextYAlignment = Enum.TextYAlignment.Top
    end
    
    return tabContent
end

local function switchTab(tabName)
    for name, content in pairs(tabs) do
        content.Visible = (name == tabName)
    end
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
end

-- Функция сворачивания/разворачивания
local function toggleMinimize()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Анимация сворачивания до маленького заголовка
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 180, 0, 30)
        }):Play()
        
        -- Заголовок по центру
        Title.TextSize = 11
        Title.Size = UDim2.new(1, -50, 1, 0)  -- На всю ширину минус кнопки
        Title.Position = UDim2.new(0, 25, 0, 0)  -- Центрируем
        Title.TextXAlignment = Enum.TextXAlignment.Center  -- Текст по центру
        
        -- Кнопки компактнее
        MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
        MinimizeBtn.Position = UDim2.new(1, -44, 0, 5)
        MinimizeBtn.TextSize = 10
        CloseBtn.Size = UDim2.new(0, 20, 0, 20)
        CloseBtn.Position = UDim2.new(1, -22, 0, 5)
        CloseBtn.TextSize = 12
        
        MinimizeBtn.Text = "+"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        CollapsibleContent.Visible = false
    else
        -- Анимация разворачивания
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 650, 0, 380)
        }):Play()
        
        -- Возвращаем заголовок
        Title.TextSize = 13
        Title.Size = UDim2.new(0, 50, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Left  -- Текст слева
        
        -- Возвращаем кнопки
        MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
        MinimizeBtn.Position = UDim2.new(1, -54, 0, 2)
        MinimizeBtn.TextSize = 12
        CloseBtn.Size = UDim2.new(0, 24, 0, 24)
        CloseBtn.Position = UDim2.new(1, -28, 0, 2)
        CloseBtn.TextSize = 14
        
        MinimizeBtn.Text = "—"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        CollapsibleContent.Visible = true
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
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 12
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    
    tabs[name] = createTab(name)
    tabButtons[name] = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- Показываем вкладку Main первой
switchTab("Main")

-- ===== ТВОЙ КОМПАКТНЫЙ СКРИПТ ПЕРЕТАСКИВАНИЯ =====
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
-- =================================================

-- Анимация появления
Main.Position = UDim2.new(0.5, -325, 0.8, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    Position = UDim2.new(0.5, -325, 0.5, -190)
}):Play()

print("BBN GUI 650x380 loaded! BBN centered when minimized")
