-- ПОЛНОЦЕННЫЙ МОБИЛЬНЫЙ ХАК С ПЛАВНЫМ ЗАКРЫТИЕМ ПОДАННЫМ ВАМИ КОДОМ
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Очистка старых версий, чтобы не наслаивались
if playerGui:FindFirstChild("MyUltimateGui") then
    playerGui["MyUltimateGui"]:Destroy()
end

-- Создаём GUI (По вашей структуре)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyUltimateGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главная панель (Размеры из вашего шаблона: 400x300)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

-- Скрипт перетаскивания панели пальцем для мобилок
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

-- Заголовок меню (Добавлен внутрь фрейма для стиля)
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

-- Кнопка закрытия из вашего кода (✕, 40x40, позиция 1, -45, 0, 5)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextSize = 24
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame

-- Функция создания кнопок функций внутри панели
local function CreateHackButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 360, 0, 45)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = frame
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.3, 0.3, 0.3)
        callback(state)
    end)
end

-- Добавление рабочих чит-функций в панель
CreateHackButton("Fly (Полет)", 65, function(s) 
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = s
    end
end)

CreateHackButton("Infinite Jump (Бесконечный прыжок)", 125, function(s)
    getgenv().InfJump = s
    UIS.JumpRequest:Connect(function()
        if getgenv().InfJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then 
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
        end
    end)
end)

CreateHackButton("Auto-Farm (Тестовый режим)", 185, function(s)
    getgenv().farming = s
end)

-- Ваша логика закрытия с Твин-анимацией плавного исчезновения
closeBtn.MouseButton1Click:Connect(function()
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {BackgroundTransparency = 1, TextTransparency = 1}
    
    -- Анимируем исчезновение всех дочерних элементов (кнопок и текста)
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("ImageLabel") then
            tweenService:Create(child, tweenInfo, goal):Play()
        end
    end
    
    -- Анимируем растворение самой панели
    tweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.3)
    screenGui:Destroy() -- Полное удаление структуры из игры
end)
