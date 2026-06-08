-- Защита от раннего запуска: ждем, пока игра полностью прогрузится
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- Безопасное получение сервисов
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

if not PlayerGui then return end

-- Удаление старой копии GUI
if PlayerGui:FindFirstChild("ModernMenuGui") then
    PlayerGui.ModernMenuGui:Destroy()
end

-- ГЛОБАЛЬНЫЕ НАСТРОЙКИ ФУНКЦИЙ
local Flying = false
local FlySpeed = 40 -- Оптимальная скорость для плавной работы
local FlyConnection = nil
local NoclipConnection = nil
local FlyPlatform = nil 

-- СОЗДАНИЕ ИНТЕРФЕЙСА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ГЛАВНОЕ ОКНО (Строго 500x300)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 162, 255)
Stroke.Transparency = 0.2
Stroke.Parent = MainFrame

-- ШАПКА
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "MM2 PERFECT FLY HUB (500x300)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- КНОПКА СВОРАЧИВАНИЯ (Minimize)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 14
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- КНОПКА ЗАКРЫТИЯ (Close)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- КОНТЕНТ (Скролл-зона)
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

-- СКРИПТ ПЕРЕТАСКИВАНИЯ Меню
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- ЛОГИКА СВОРАЧИВАНИЯ
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 300)
    MinBtn.Text = isMinimized and "+" or "—"
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЕЙ (Toggle)
local function CreateToggle(text, default, callback)
    local TglFrame = Instance.new("Frame")
    TglFrame.Size = UDim2.new(1, -6, 0, 40)
    TglFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    TglFrame.Parent = Container
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)

    local TglLabel = Instance.new("TextLabel")
    TglLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TglLabel.Position = UDim2.new(0, 10, 0, 0)
    TglLabel.BackgroundTransparency = 1
    TglLabel.Font = Enum.Font.GothamSemibold
    TglLabel.Text = text
    TglLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TglLabel.TextSize = 14
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left
    TglLabel.Parent = TglFrame

    local TglBtn = Instance.new("TextButton")
    TglBtn.Size = UDim2.new(0, 45, 0, 22)
    TglBtn.Position = UDim2.new(1, -55, 0.5, -11)
    TglBtn.BackgroundColor3 = default and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(50, 50, 55)
    TglBtn.Text = ""
    TglBtn.Parent = TglFrame
    Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 11)

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 16, 0, 16)
    Switch.Position = default and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    Switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Switch.Parent = TglBtn
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 8)

    local state = default
    TglBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(50, 50, 55)
        local targetPos = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        
        TweenService:Create(TglBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2), {Position = targetPos}):Play()
        callback(state)
    end)
end

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ ПОЛЗУНКОВ (Slider)
local function CreateSlider(text, min, max, default, callback)
    local SldFrame = Instance.new("Frame")
    SldFrame.Size = UDim2.new(1, -6, 0, 50)
    SldFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    SldFrame.Parent = Container
    Instance.new("UICorner", SldFrame).CornerRadius = UDim.new(0, 6)

    local SldLabel = Instance.new("TextLabel")
    SldLabel.Size = UDim2.new(0.6, 0, 0, 25)
    SldLabel.Position = UDim2.new(0, 10, 0, 2)
    SldLabel.BackgroundTransparency = 1
    SldLabel.Font = Enum.Font.GothamSemibold
    SldLabel.Text = text
    SldLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    SldLabel.TextSize = 13
    SldLabel.TextXAlignment = Enum.TextXAlignment.Left
    SldLabel.Parent = SldFrame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValLabel.Position = UDim2.new(0.7, -10, 0, 2)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
    ValLabel.TextSize = 13
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = SldFrame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 34)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Text = ""
    SliderBar.Parent = SldFrame
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0, 3)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 3)

    local function MoveSlider(input)
        local totalWidth = SliderBar.AbsoluteSize.X
        local clickX = input.Position.X - SliderBar.AbsolutePosition.X
        local scale = math.clamp(clickX / totalWidth, 0, 1)
        
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        local value = math.floor(min + (max - min) * scale)
        ValLabel.Text = tostring(value)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            MoveSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            MoveSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- ==========================================
-- ИСПРАВЛЕННЫЙ ВЕКТОРНЫЙ ПОЛЕТ (БЕЗ КОНФЛИКТОВ)
-- ==========================================

local function StartPlatformFly()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Создаем опорный блок под ногами персонажа
    FlyPlatform = Instance.new("Part")
    FlyPlatform.Size = Vector3.new(4, 1, 4)
    FlyPlatform.CFrame = CFrame.new(root.Position - Vector3.new(0, 3.5, 0))
    FlyPlatform.Transparency = 1 
    FlyPlatform.Anchored = true
    FlyPlatform.Parent = workspace

    local cam = workspace.CurrentCamera

    FlyConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not Flying or not FlyPlatform or not LocalPlayer.Character then return end
        local curChar = LocalPlayer.Character
        local curRoot = curChar:FindFirstChild("HumanoidRootPart")
        local curHum = curChar:FindFirstChildOfClass("Humanoid")
        
        if curRoot and curHum then
            local moveDir = Vector3.new(0, 0, 0)
            
            -- Чтение ввода на ПК (Классические WASD)
            if UserInputService.KeyboardEnabled then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                -- Кнопки высоты на ПК
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            end
            
            -- Чтение ввода на ТЕЛЕФОНЕ (Идеальный перевод вектора джойстика в камеру)
            if moveDir.Magnitude == 0 and curHum.MoveDirection.Magnitude > 0 then
                local joystickDir = curHum.MoveDirection
                -- Накладываем направление джойстика на оси камеры в 3D пространстве
                moveDir = (cam.CFrame.LookVector * -joystickDir.Z) + (cam.CFrame.RightVector * joystickDir.X)
            end
            
            -- Вычисляем новую позицию платформы
            local newPosition = FlyPlatform.Position
            if moveDir.Magnitude > 0 then
                newPosition = FlyPlatform.Position + (moveDir.Unit * (FlySpeed * deltaTime))
            end
            
            -- Угол взгляда по горизонтали (чтобы персонаж не заваливался на бок и не застревал)
            local camLookXZ = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
            
            -- Обновляем платформу
            FlyPlatform.CFrame = CFrame.new(newPosition, newPosition + camLookXZ)
            
            -- Переносим игрока на платформу, заставляя его смотреть ровно туда же, куда и камера
            curRoot.CFrame = CFrame.new(FlyPlatform.Position + Vector3.new(0, 3.5, 0), FlyPlatform.Position + Vector3.new(cam.CFrame.LookVector.X, 3.5, cam.CFrame.LookVector.Z))
            curRoot.Velocity = Vector3.new(0, 0, 0) 
        end
    end)
end

-- 1. ТУМБЛЕР ПОЛЕТА
CreateToggle("Bypass Fly (Полет MM2)", false, function(state)
    Flying = state
    if state then
        StartPlatformFly()
    else
        if FlyConnection then FlyConnection:Disconnect() end
        if FlyPlatform then FlyPlatform:Destroy(); FlyPlatform = nil end
    end
end)

-- 2. СЛАЙДЕР СКОРОСТИ ПОЛЕТА
CreateSlider("Скорость полета", 10, 80, 35, function(value)
    FlySpeed = value
end)

-- 3. ТУМБЛЕР ПРОХОДА СКВОЗЬ СТЕНЫ
CreateToggle("Noclip (Сквозь стены)", false, function(state)
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConnection then NoclipConnection:Disconnect() end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

-- 4. БЕСКОНЕЧНЫЙ ПРЫЖОК
CreateToggle("Inf Jump (Бесконечный прыжок)", false, function(state)
    _G.InfJump = state
    if state then
        UserInputService.JumpRequest:Connect(function()
            if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- 5. СЛАЙДЕР СКОРОСТИ ХОДЬБЫ
CreateSlider("Скорость бега (WalkSpeed)", 16, 60, 16, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

-- Автоматическая подгонка CanvasSize
Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- Закрытие меню
CloseBtn.MouseButton1Click:Connect(function()
    if FlyConnection then FlyConnection:Disconnect() end
    if NoclipConnection then NoclipConnection:Disconnect() end
    if FlyPlatform then FlyPlatform:Destroy() end
    ScreenGui:Destroy()
end)
