-- МОДИФИЦИРОВАННЫЙ GUI: ТОЛЬКО INF JUMP И ЗА КРУГЛЕННЫЕ УГЛЫ
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Очистка старых версий
if playerGui:FindFirstChild("MyUltimateGui") then
    playerGui["MyUltimateGui"]:Destroy()
end

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyUltimateGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главная панель (Скругленная)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 400, 0, 180) -- Уменьшил высоту, так как кнопок меньше
frame.Position = UDim2.new(0.5, -200, 0.5, -90)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

-- ЗАКРУГЛЕНИЕ УГЛОВ ДЛЯ ГЛАВНОЙ ПАНЕЛИ
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12) -- Радиус скругления углов
frameCorner.Parent = frame

-- Скрипт перетаскивания панели пальцем
local UIS = game:GetService("UserInputService")
local dragToggle, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragToggle then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Заголовок меню
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 5)
titleLabel.Text = "PRO HUB MOBILE"
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = frame

-- Кнопка закрытия (X) с закруглением
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextSize = 24
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8) -- Скругление для кнопки закрытия
closeCorner.Parent = closeBtn

-- Единственная оставшаяся кнопка: Бесконечный прыжок
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, 360, 0, 50)
jumpBtn.Position = UDim2.new(0, 20, 0, 80) -- Размещена по центру
jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "Infinite Jump (Бесконечный прыжок)"
jumpBtn.TextSize = 18
jumpBtn.TextColor3 = Color3.new(1, 1, 1)
jumpBtn.Font = Enum.Font.SourceSansBold
jumpBtn.Parent = frame

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 8) -- Скругление для кнопки чита
jumpCorner.Parent = jumpBtn

local jumpState = false
jumpBtn.MouseButton1Click:Connect(function()
    jumpState = not jumpState
    jumpBtn.BackgroundColor3 = jumpState and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.3, 0.3, 0.3)
end)

UIS.JumpRequest:Connect(function()
    if jumpState and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then 
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
    end
end)

-- Плавное закрытие с анимацией
closeBtn.MouseButton1Click:Connect(function()
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {BackgroundTransparency = 1, TextTransparency = 1}
    
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("ImageLabel") then
            tweenService:Create(child, tweenInfo, goal):Play()
        end
    end
    
    tweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.3)
    screenGui:Destroy()
end)
