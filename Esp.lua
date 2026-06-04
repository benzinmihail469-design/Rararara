-- ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ СКРИПТ: БЕЗ ОШИБОК И СБОЕВ
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Ожидание полной загрузки игрока
local player = Players.LocalPlayer
if not player then
    Players.PlayerAdded:Wait()
    player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui")

-- Очистка старых версий GUI
local existingGui = playerGui:FindFirstChild("MyUltimateGui")
if existingGui then
    existingGui:Destroy()
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
frame.Size = UDim2.new(0, 400, 0, 180)
frame.Position = UDim2.new(0.5, -200, 0.5, -90)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

-- ЗАКРУГЛЕНИЕ УГЛОВ ДЛЯ ГЛАВНОЙ ПАНЕЛИ
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Скрипт перетаскивания панели (исправлен для мобильных устройств)
local dragToggle = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
        
        -- Отслеживание окончания перетаскивания
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
                conn:Disconnect()
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle and dragStart and startPos then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
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
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Кнопка: Бесконечный прыжок
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, 360, 0, 50)
jumpBtn.Position = UDim2.new(0, 20, 0, 80)
jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
jumpBtn.BackgroundTransparency = 0
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "Бесконечный прыжок: ВЫКЛ"
jumpBtn.TextSize = 18
jumpBtn.TextColor3 = Color3.new(1, 1, 1)
jumpBtn.Font = Enum.Font.SourceSans
jumpBtn.Parent = frame

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 8)
jumpCorner.Parent = jumpBtn

-- Состояние бесконечного прыжка
local jumpState = false

-- Обновление текста и цвета кнопки
local function updateJumpButton()
    if jumpState then
        jumpBtn.Text = "Бесконечный прыжок: ВКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    else
        jumpBtn.Text = "Бесконечный прыжок: ВЫКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    end
end

jumpBtn.MouseButton1Click:Connect(function()
    jumpState = not jumpState
    updateJumpButton()
end)

-- ИСПРАВЛЕННАЯ обработка прыжка (работает на всех устройствах)
-- Метод 1: через JumpRequest (ПК)
UIS.JumpRequest:Connect(function()
    if jumpState then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Метод 2: для мобильных устройств (ИСПРАВЛЕНО - убран ViewSizeY)
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    -- ПРОВЕРКА НАЖАТИЯ ПРЫЖКА ДЛЯ МОБИЛЬНЫХ УСТРОЙСТВ
    -- Просто проверяем клавишу Space или любой тач (упрощённая версия без ошибок)
    if input.KeyCode == Enum.KeyCode.Space then
        if jumpState then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                task.spawn(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
    end
    
    -- Для мобильных: определяем нажатие на экран в нижней части (примерно там кнопка прыжка)
    -- НЕ ИСПОЛЬЗУЕМ ViewSizeY, используем ViewportSize из camera
    if input.UserInputType == Enum.UserInputType.Touch then
        local camera = Workspace.CurrentCamera
        if camera then
            local screenHeight = camera.ViewportSize.Y
            -- Если нажали в нижней трети экрана (вероятно кнопка прыжка)
            if input.Position.Y > screenHeight * 0.7 then
                if jumpState then
                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        task.spawn(function()
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end)
                    end
                end
            end
        end
    end
end

UIS.InputBegan:Connect(onInputBegan)

-- Слежение за сменой персонажа (чтобы избежать ошибок при смерти)
player.CharacterAdded:Connect(function(character)
    -- Персонаж обновлён, ничего дополнительно не требуется
    -- Humanoid будет найден при следующем прыжке
end)

-- Плавное закрытие с анимацией
closeBtn.MouseButton1Click:Connect(function()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Анимация для всех дочерних элементов
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            local goal = {BackgroundTransparency = 1, TextTransparency = 1}
            TweenService:Create(child, tweenInfo, goal):Play()
        end
    end
    
    -- Анимация для главного фрейма
    local frameGoal = {BackgroundTransparency = 1}
    TweenService:Create(frame, tweenInfo, frameGoal):Play()
    
    -- Ожидание завершения анимации и удаление GUI
    task.wait(0.35)
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end)

-- Инициализация внешнего вида кнопки
updateJumpButton()
