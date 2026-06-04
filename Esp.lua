-- ФИНАЛЬНЫЙ СКРИПТ: ОБХОД АНТИ-ЧИТА FORSAKEN + ПЕРЕТАСКИВАЕМАЯ КНОПКА ПРЫЖКА
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- Очистка старых версий GUI
if playerGui:FindFirstChild("MyUltimateGui") then
    playerGui["MyUltimateGui"]:Destroy()
end

-- Создаём основной ScreenGui для меню
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyUltimateGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 10

-- Главная панель (500x300)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 500, 0, 300)
frame.Position = UDim2.new(0.5, -250, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Скрипт перетаскивания ГЛАВНОЙ панели
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

-- Кнопка закрытия (X)
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

-- Кнопка-переключатель Infinite Jump в меню
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, 440, 0, 60)
jumpBtn.Position = UDim2.new(0, 30, 0, 120)
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

-- Переменные состояния
local jumpState = false
local jumpButtonGui = nil
local mobileJumpButton = nil
local lastJump = 0
local jumpCooldown = 0.15 -- Защитная задержка между прыжками для обхода проверок пакетов

-- СКРИПТ ОБХОДА АНТИ-ЧИТА FORSAKEN (Физический импульс вместо спама стейтов)
local function doBypassJump()
    if tick() - lastJump < jumpCooldown then return end -- Защита от слишком быстрого спама
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if rootPart and humanoid and humanoid.Health > 0 then
        lastJump = tick()
        
        -- Сбрасываем старую вертикальную скорость падения, чтобы анти-чит не залагал от резкого изменения
        local currentVelocity = rootPart.AssemblyLinearVelocity
        rootPart.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
        
        -- Даем плавный физический импульс вверх (имитируем силу прыжка игры)
        -- Используем стандартную силу прыжка персонажа или фиксированное значение 50
        local jumpPower = humanoid.JumpPower > 0 and humanoid.JumpPower or 50
        rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, jumpPower, rootPart.AssemblyLinearVelocity.Z)
        
        -- Локально меняем стейт на Freefall, чтобы анимация выглядела плавно, а анти-чит на сервере думал, что мы просто падаем/летим
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
end

-- Функция создания перетаскиваемой кнопки прыжка поверх всех
local function toggleMobileJumpButton(enable)
    if enable then
        if jumpButtonGui then return end
        
        jumpButtonGui = Instance.new("ScreenGui")
        jumpButtonGui.Name = "InfJumpButtonGui"
        jumpButtonGui.Parent = playerGui
        jumpButtonGui.ResetOnSpawn = false
        jumpButtonGui.DisplayOrder = 999999
        
        mobileJumpButton = Instance.new("TextButton")
        mobileJumpButton.Name = "MobileInfJumpButton"
        mobileJumpButton.Parent = jumpButtonGui
        mobileJumpButton.Size = UDim2.new(0, 70, 0, 70)
        mobileJumpButton.Position = UDim2.new(0.85, -35, 0.7, -35)
        mobileJumpButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        mobileJumpButton.Text = "JUMP"
        mobileJumpButton.TextSize = 18
        mobileJumpButton.TextColor3 = Color3.new(1, 1, 1)
        mobileJumpButton.Font = Enum.Font.SourceSansBold
        mobileJumpButton.ZIndex = 10
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = mobileJumpButton
        
        -- Перетаскивание (Drag) мобильной кнопки
        local bDragToggle = false
        local bDragStart = nil
        local bStartPos = nil
        
        mobileJumpButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                bDragToggle = true
                bDragStart = input.Position
                bStartPos = mobileJumpButton.Position
                
                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        bDragToggle = false
                        conn:Disconnect()
                    end
                end)
            end
        end)
        
        mobileJumpButton.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and bDragToggle and bDragStart and bStartPos then
                local delta = input.Position - bDragStart
                mobileJumpButton.Position = UDim2.new(bStartPos.X.Scale, bStartPos.X.Offset + delta.X, bStartPos.Y.Scale, bStartPos.Y.Offset + delta.Y)
            end
        end)
        
        -- Активация обхода при нажатии на мобильную кнопку
        mobileJumpButton.MouseButton1Click:Connect(function()
            if jumpState then
                doBypassJump()
            end
        end)
    else
        if jumpButtonGui then
            jumpButtonGui:Destroy()
            jumpButtonGui = nil
            mobileJumpButton = nil
        end
    end
end

-- Обновление кнопки в меню
local function updateJumpButton()
    if jumpState then
        jumpBtn.Text = "Бесконечный прыжок: ВКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        if UIS.TouchEnabled then
            toggleMobileJumpButton(true)
        end
    else
        jumpBtn.Text = "Бесконечный прыжок: ВЫКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        toggleMobileJumpButton(false)
    end
end

jumpBtn.MouseButton1Click:Connect(function()
    jumpState = not jumpState
    updateJumpButton()
end)

-- Прыжок для ПК (Пробел) с обходом анти-чита
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and jumpState then
        doBypassJump()
    end
end)

-- Плавное закрытие основного меню
closeBtn.MouseButton1Click:Connect(function()
    toggleMobileJumpButton(false)
    
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

-- Старт настройки
updateJumpButton()
