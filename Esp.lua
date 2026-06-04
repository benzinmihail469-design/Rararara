-- ПОЛНОСТЬЮ ПЕРЕПИСАННЫЙ МОБИЛЬНЫЙ GUI (ФИКС ОТОБРАЖЕНИЯ КНОПОК)
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старые копии, если они зависли
if playerGui:FindFirstChild("ProMobileHubUltimate") then
    playerGui["ProMobileHubUltimate"]:Destroy()
end

-- Создаем основу интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProMobileHubUltimate"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главное черное окно (как на скриншоте)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 280, 0, 300)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
MainFrame.Active = true
MainFrame.ZIndex = 1

-- Скрипт перетаскивания панели пальцем
local UIS = game:GetService("UserInputService")
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragToggle then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Верхняя панель заголовка (Серая полоса)
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Parent = MainFrame
HeaderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
HeaderFrame.ZIndex = 2

-- Текст заголовка PRO HUB
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = HeaderFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "PRO HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.CodeBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

-- ЯРКО-КРАСНАЯ КНОПКА ЗАКРЫТИЯ 'X' (Жесткое позиционирование в верхнем правом углу)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = HeaderFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69) -- Красный цвет
CloseBtn.BorderSizePixel = 0
CloseBtn.Size = UDim2.new(0, 50, 0, 40) -- Фиксированный размер кнопки
CloseBtn.Position = UDim2.new(1, -50, 0, 0) -- В самом углу серой полосы
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 22
CloseBtn.ZIndex = 10 -- Поверх абсолютно всего
CloseBtn.Visible = true

CloseBtn.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
end)

-- КНОПКА 1: Полет (Fly)
local FlyBtn = Instance.new("TextButton")
FlyBtn.Name = "FlyBtn"
FlyBtn.Parent = MainFrame
FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyBtn.Size = UDim2.new(0, 240, 0, 40)
FlyBtn.Position = UDim2.new(0, 20, 0, 60)
FlyBtn.Text = "Fly (Полет)"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.Font = Enum.Font.SourceSansBold
FlyBtn.TextSize = 16
FlyBtn.ZIndex = 4

local flyState = false
FlyBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        flyState = not flyState
        FlyBtn.BackgroundColor3 = flyState and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(60, 60, 60)
        player.Character.Humanoid.PlatformStand = flyState
    end
end)

-- КНОПКА 2: Бесконечный прыжок (Inf Jump)
local JumpBtn = Instance.new("TextButton")
JumpBtn.Name = "JumpBtn"
JumpBtn.Parent = MainFrame
JumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
JumpBtn.Size = UDim2.new(0, 240, 0, 40)
JumpBtn.Position = UDim2.new(0, 20, 0, 115)
JumpBtn.Text = "Infinite Jump"
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.Font = Enum.Font.SourceSansBold
JumpBtn.TextSize = 16
JumpBtn.ZIndex = 4

local jumpState = false
JumpBtn.MouseButton1Click:Connect(function()
    jumpState = not jumpState
    JumpBtn.BackgroundColor3 = jumpState and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(60, 60, 60)
end)

UIS.JumpRequest:Connect(function()
    if jumpState and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then 
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
    end
end)

-- КНОПКА 3: Тестовый Автофарм (Auto-Farm)
local FarmBtn = Instance.new("TextButton")
FarmBtn.Name = "FarmBtn"
FarmBtn.Parent = MainFrame
FarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FarmBtn.Size = UDim2.new(0, 240, 0, 40)
FarmBtn.Position = UDim2.new(0, 20, 0, 170)
FarmBtn.Text = "Auto-Farm (Тест)"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Font = Enum.Font.SourceSansBold
FarmBtn.TextSize = 16
FarmBtn.ZIndex = 4

local farmState = false
FarmBtn.MouseButton1Click:Connect(function()
    farmState = not farmState
    FarmBtn.BackgroundColor3 = farmState and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(60, 60, 60)
end)
