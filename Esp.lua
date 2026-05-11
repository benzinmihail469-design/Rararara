local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BBN_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основной фрейм (360x380)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 360, 0, 380)
Main.Position = UDim2.new(0.5, -180, 0.5, -190)
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

-- Заголовок
local Title = Instance.new("TextLabel", Main)
Title.Name = "Title"
Title.Text = "BBN"
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BorderSizePixel = 0

-- Кнопка закрытия (мини)
local CloseBtn = Instance.new("TextButton", Main)
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

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Контейнер для вкладок
local TabButtonsFrame = Instance.new("Frame", Main)
TabButtonsFrame.Name = "TabButtons"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 26)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 28)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TabButtonsFrame.BorderSizePixel = 0

-- UIListLayout для автоматического расположения
local layout = Instance.new("UIListLayout", TabButtonsFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 1)

-- Контейнер для контента вкладок
local ContentContainer = Instance.new("Frame", Main)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -16, 1, -60)
ContentContainer.Position = UDim2.new(0, 8, 0, 56)
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentContainer.BorderSizePixel = 0

-- Вкладки и контент
local tabs = {}
local tabButtons = {}
local tabNames = {"Info", "Main", "Player", "Esp", "Discord", "Settings"}

local function createTab(name)
    local tabContent = Instance.new("Frame", ContentContainer)
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    
    if name == "Info" then
        local serverInfo = Instance.new("TextLabel", tabContent)
        serverInfo.Text = "Сервер антивидов\nВремя работы: 08:12:35\nВерсия: 14806\nDistorted Report - 4638\n\nПинг: 407 | ФПС: 29\nNorth Holland, NL\n\nИгроков: 6,658"
        serverInfo.Size = UDim2.new(1, 0, 1, 0)
        serverInfo.BackgroundTransparency = 1
        serverInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        serverInfo.Font = Enum.Font.Gotham
        serverInfo.TextSize = 11
        serverInfo.TextWrapped = true
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Main" then
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = "⚡ Auto Farm\n🎯 Auto Parry\n🚪 Delete Doors\n🎬 Skip Cutscene\n🔧 Auto Generator\n📦 Auto Barricade"
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 11
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
        placeholder.TextSize = 11
        placeholder.TextWrapped = true
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Esp" then
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = "👁️ ESP Survivors\n🔴 ESP Killers\n⚡ ESP Generators\n📦 ESP Fuse Boxes\n🔋 ESP Battery\n🪤 ESP Traps"
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 11
        placeholder.TextWrapped = true
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Discord" then
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = "🎮 Discord Server\n📋 Copy Link\n\ndiscord.gg/E2TqYRsRP4"
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 11
        placeholder.TextWrapped = true
        placeholder.TextXAlignment = Enum.TextXAlignment.Left
        placeholder.TextYAlignment = Enum.TextYAlignment.Top
    elseif name == "Settings" then
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = "🎨 Change Theme\n📏 ESP Distance\n📐 Line ESP\n🔄 Unload Cheat\n\nVersion: 0.52"
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200, 200, 200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 11
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

-- Создаём кнопки вкладок
for _, name in ipairs(tabNames) do
    local tabButton = Instance.new("TextButton", TabButtonsFrame)
    tabButton.Name = name
    tabButton.Text = name
    tabButton.Size = UDim2.new(0, 58, 1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 10
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

-- Перетаскивание
local dragging = false
local dragInput
local dragStart
local startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Анимация появления
Main.Position = UDim2.new(0.5, -180, 0.8, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    Position = UDim2.new(0.5, -180, 0.5, -190)
}):Play()

print("BBN Compact GUI loaded!")
