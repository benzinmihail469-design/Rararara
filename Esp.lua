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

-- Основной фрейм (уменьшенный)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 320, 0, 420)
Main.Position = UDim2.new(0.5, -160, 0.5, -210)
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
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0

-- Контейнер для вкладок
local TabContainer = Instance.new("Frame", Main)
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 28)
TabContainer.Position = UDim2.new(0, 0, 0, 32)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TabContainer.BorderSizePixel = 0

-- Контейнер для контента вкладок
local ContentContainer = Instance.new("Frame", Main)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -16, 1, -68)
ContentContainer.Position = UDim2.new(0, 8, 0, 64)
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentContainer.BorderSizePixel = 0

-- Вкладки и контент
local tabs = {}
local tabButtons = {}
local tabNames = {"Info", "Main", "Player", "Esp", "Discord", "Settings"}
local currentTab = nil

local function createTab(name)
    local tabContent = Instance.new("Frame", ContentContainer)
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    
    -- Пример контента для Info
    if name == "Info" then
        local serverInfo = Instance.new("TextLabel", tabContent)
        serverInfo.Text = "North Holland, NL\nПинг: 407\nФПС: 29\n\nСервер антивидов\nВремя: 06:54:20\nВерсия: 14806\nDistant Night - 6386"
        serverInfo.Size = UDim2.new(1, 0, 1, 0)
        serverInfo.BackgroundTransparency = 1
        serverInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        serverInfo.Font = Enum.Font.Gotham
        serverInfo.TextSize = 12
        serverInfo.TextWrapped = true
        serverInfo.TextXAlignment = Enum.TextXAlignment.Left
        serverInfo.TextYAlignment = Enum.TextYAlignment.Top
    else
        local placeholder = Instance.new("TextLabel", tabContent)
        placeholder.Text = name .. " Tab"
        placeholder.Size = UDim2.new(1, 0, 0, 20)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(150, 150, 150)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 12
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
local buttonWidth = 1 / #tabNames
for i, name in ipairs(tabNames) do
    local tabButton = Instance.new("TextButton", TabContainer)
    tabButton.Name = name
    tabButton.Text = name
    tabButton.Size = UDim2.new(buttonWidth, -2, 1, 0)
    tabButton.Position = UDim2.new((i-1) * buttonWidth, 1, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 11
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    
    -- Создаём контент вкладки
    tabs[name] = createTab(name)
    tabButtons[name] = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- Показываем первую вкладку
switchTab("Info")

-- Возможность перетаскивать окно
local dragging = false
local dragInput
local dragStart
local startPos

local function startDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = Main.Position
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
    end
end)

-- Для мобильных - свайп по заголовку
Title.TouchPan:Connect(function(touchPositions, totalTranslation, velocity, state)
    if state == Enum.TouchState.Moving then
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + totalTranslation.X,
            startPos.Y.Scale,
            startPos.Y.Offset + totalTranslation.Y
        )
    elseif state == Enum.TouchState.Began then
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
Main.Position = UDim2.new(0.5, -160, 0.8, 0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    Position = UDim2.new(0.5, -160, 0.5, -210)
}):Play()

print("BBN Mobile GUI loaded!")
