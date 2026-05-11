local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BBN_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Основной фрейм
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 600, 0, 500)
Main.Position = UDim2.new(0.5, -300, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Stroke
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(60, 60, 70)
Stroke.Transparency = 0.5

-- Заголовок
local Title = Instance.new("TextLabel", Main)
Title.Name = "Title"
Title.Text = "Bite by night by Iliankytb"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BorderSizePixel = 0

-- Контейнер для вкладок
local TabContainer = Instance.new("Frame", Main)
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TabContainer.BorderSizePixel = 0

-- Контейнер для контента вкладок
local ContentContainer = Instance.new("Frame", Main)
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -20, 1, -85)
ContentContainer.Position = UDim2.new(0, 10, 0, 80)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
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
    
    local titleLabel = Instance.new("TextLabel", tabContent)
    titleLabel.Text = name .. " Tab"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    
    return tabContent
end

local function switchTab(tabName)
    for name, content in pairs(tabs) do
        content.Visible = (name == tabName)
    end
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        else
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
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
    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 14
    tabButton.BorderSizePixel = 0
    
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

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Анимация появления
Main.Position = UDim2.new(0.5, -300, 0.7, 0)
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
    Position = UDim2.new(0.5, -300, 0.5, -250)
}):Play()

print("BBN GUI loaded! Only tabs with no Zentrix library.")
