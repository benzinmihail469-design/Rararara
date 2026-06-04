-- ОБНОВЛЕННЫЙ GUI: РАЗМЕР 500х300, СКРУГЛЕНИЕ И МОБИЛЬНАЯ КНОПКА ПРЫЖКА
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- Очистка старых версий GUI
if playerGui:FindFirstChild("MyUltimateGui") then
    playerGui["MyUltimateGui"]:Destroy()
end

-- Создаём основной ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyUltimateGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главная панель (Размер изменен на 500x300)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 500, 0, 300)
frame.Position = UDim2.new(0.5, -250, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

-- ЗАКРУГЛЕНИЕ УГЛОВ ДЛЯ ГЛАВНОЙ ПАНЕЛИ
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Скрипт перетаскивания панели пальцем/мышкой
local dragToggle = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
        
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
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Заголовок меню
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 250, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 10)
titleLabel.Text = "PRO HUB MOBILE"
titleLabel.TextSize = 22
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = frame

-- Кнопка закрытия (X) со скруглением
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -55, 0, 10)
closeBtn.Text = "✕"
closeBtn.TextSize = 24
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Кнопка-переключатель функции Infinite Jump в меню
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, 440, 0, 60)
jumpBtn.Position = UDim2.new(0, 30, 0, 120) -- Размещена красиво по центру экрана 500x300
jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "Бесконечный прыжок: ВЫКЛ"
jumpBtn.TextSize = 20
jumpBtn.TextColor3 = Color3.new(1, 1, 1)
jumpBtn.Font = Enum.Font.SourceSansBold
jumpBtn.Parent = frame

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 8)
jumpCorner.Parent = jumpBtn

-- Глобальные переменные состояния и кнопки прыжка
local jumpState = false
local mobileJumpButton = nil

-- Функция самого прыжка (Инфинити логика)
local function doInfiniteJump()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- Функция создания/удаления мобильной GUI-кнопки прыжка
local function toggleMobileJumpButton(enable)
    if enable then
        -- Если кнопка уже создана, не дублируем
        if mobileJumpButton then return end
        
        -- Создаем круглую кнопку прыжка для телефона
        mobileJumpButton = Instance.new("TextButton")
        mobileJumpButton.Name = "MobileInfJumpButton"
        mobileJumpButton.Parent = screenGui
        -- Позиционируем в правой нижней части экрана, чуть выше стандартного прыжка
        mobileJumpButton.Size = UDim2.new(0, 70, 0, 70)
        mobileJumpButton.Position = UDim2.new(0.85, -35, 0.7, -35)
        mobileJumpButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255) -- Синяя, заметная кнопка
        mobileJumpButton.Text = "JUMP"
        mobileJumpButton.TextSize = 18
        mobileJumpButton.TextColor3 = Color3.new(1, 1, 1)
        mobileJumpButton.Font = Enum.Font.SourceSansBold
        mobileJumpButton.ZIndex = 10
        
        -- Закругляем полностью (делаем круг)
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = mobileJumpButton
        
        -- Обработка нажатия на мобильную кнопку
        mobileJumpButton.MouseButton1Click:Connect(function()
            if jumpState then
                doInfiniteJump()
            end
        end)
    else
        -- Удаляем кнопку, если функцию выключили
        if mobileJumpButton then
            mobileJumpButton:Destroy()
            mobileJumpButton = nil
        end
    end
end

-- Обновление интерфейса при переключении
local function updateJumpButton()
    if jumpState then
        jumpBtn.Text = "Бесконечный прыжок: ВКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        -- Если это мобильное устройство или включен Touch, создаем кнопку
        if UIS.TouchEnabled then
            toggleMobileJumpButton(true)
        end
    else
        jumpBtn.Text = "Бесконечный прыжок: ВЫКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        toggleMobileJumpButton(false) -- Удаляем кнопку
    end
end

jumpBtn.MouseButton1Click:Connect(function()
    jumpState = not jumpState
    updateJumpButton()
end)

-- Обработка прыжка для ПК (Кнопка Space/Пробел)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and jumpState then
        doInfiniteJump()
    end
end)

-- Плавное закрытие всего GUI с анимацией растворения
closeBtn.MouseButton1Click:Connect(function()
    toggleMobileJumpButton(false) -- Сразу убираем мобильную кнопку прыжка, если она была
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {BackgroundTransparency = 1, TextTransparency = 1}
    
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            TweenService:Create(child, tweenInfo, goal):Play()
        end
    end
    
    TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.35)
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end)

-- Первоначальная настройка
updateJumpButton()
