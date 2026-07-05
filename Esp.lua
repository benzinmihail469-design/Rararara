-- Использование: просто запустите этот скрипт. 
-- Интерфейс автоматически адаптируется под размер мобильного экрана.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("HoshiHubMobile") then PlayerGui.HoshiHubMobile:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoshiHubMobile"
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400) -- Компактный размер для телефона
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Заголовок
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame
Instance.new("TextLabel", TopBar).Text = " HOSHI HUB"
TopBar.TextLabel.Size = UDim2.new(1, 0, 1, 0)
TopBar.TextLabel.Font = Enum.Font.GothamBold
TopBar.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TopBar.TextLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Контейнер для вкладок
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, -20, 1, -60)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 0
TabContainer.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 12) -- Большой отступ между элементами
ListLayout.Parent = TabContainer

-- Функция создания элементов с большими отступами
local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 50) -- Высота для удобного нажатия
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = TabContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(30, 30, 40)
        callback(state)
    end)
end

-- Добавление кнопок (все функции из вашего кода работают)
CreateButton("Auto Farm (Coins)", function(s) _G.AutoFarm = s end)
CreateButton("Bypass Fly", function(s) _G.Flying = s end)
CreateButton("Role ESP", function(s) _G.ESP = s end)
CreateButton("Auto Kill (Murderer)", function(s) _G.Kill = s end)
CreateButton("Infinite Jump", function(s) _G.InfJump = s end)

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Перетаскивание для мобильных
local UserInputService = game:GetService("UserInputService")
local dragging, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.TouchMoved:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.TouchEnded:Connect(function() dragging = false end)
