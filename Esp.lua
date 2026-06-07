--[=[
    MODERN & MOBILE-FRIENDLY ROBLOX GUI
    Особенности: Адаптивный дизайн (ПК/Мобилки), Твин-анимации, Скругленные углы.
--]=]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старую версию, если она была, чтобы не спамить UI
if PlayerGui:FindFirstChild("ModernMenuGui") then
    PlayerGui.ModernMenuGui:Destroy()
end

-- КОРЕНЬ ИНТЕРФЕЙСА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ГЛАВНЫЙ ФРЕЙМ (Адаптивный размер через Scale)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
-- Используем Scale: 35% ширины экрана на ПК, 80% на мобилках (универсальный вариант 0.4, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, -0.5, 0) -- Начальная позиция сверху (для анимации появления)
MainFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28) -- Глубокий темный
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Адаптация под телефоны (если экран маленький, делаем меню шире)
local UIAspectRatio = Instance.new("UIAspectRatioConstraint")
UIAspectRatio.AspectRatio = 1.4
UIAspectRatio.DominantAxis = Enum.DominantAxis.Width
UIAspectRatio.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Боковое свечение / Обводка (Неон акцент)
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 162, 255) -- Ярко-голубой неон
Stroke.Transparency = 0.2
Stroke.Parent = MainFrame

-- ШАПКА МЕНЮ (Заголовок)
local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0.15, 0)
Header.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
Header.BorderSizePixel = 0
Header.Font = Enum.Font.GothamBold
Header.Text = "⚡ PREMIER HUB"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 18
Header.TextXAlignment = Enum.TextXAlignment.Center
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- КНОПКА ЗАКРЫТИЯ (Крестик)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0.1, 0, 0.8, 0)
CloseBtn.Position = UDim2.new(0.88, 0, 0.1, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 18
CloseBtn.Parent = Header

-- КОНТЕНТ (Скролл для функций)
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Size = UDim2.new(0.92, 0, 0.78, 0)
Container.Position = UDim2.new(0.04, 0, 0.18, 0)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ СОВРЕМЕННЫХ КНОПОК
local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 45) -- Фиксированная высота кнопки удобна для пальцев на мобилке
    Btn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    -- Эффекты при наведении и нажатии (Анимация)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(48, 48, 56), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(38, 38, 44), TextColor3 = Color3.fromRGB(230, 230, 230)}):Play()
    end)
    Btn.MouseButton1Down:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, -6, 0, 43)}):Play()
        callback()
    end)
    Btn.MouseButton1Up:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -6, 0, 45)}):Play()
    end)
end

-- ==========================================
-- ТУТ НАСТРАИВАЮТСЯ ФУНКЦИИ ТВОИХ КНОПОК
-- ==========================================

CreateButton("Fly (Полет)", function()
    print("Активирован Fly")
    -- Сюда вставляй код для полета
end)

CreateButton("Speed Hack (Скорость)", function()
    LocalPlayer.Character.Humanoid.WalkSpeed = 50
end)

CreateButton("Infinite Jump (Бесконечный прыжок)", function()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

CreateButton("Reset Character (Ресет)", function()
    LocalPlayer.Character:BreakJoints()
end)

-- Обновление размера скролла под количество кнопок автоматически
Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- ==========================================
-- ЛОГИКА ОТКРЫТИЯ / ЗАКРЫТИЯ МЕНЮ (ЛОКАЛЬНАЯ)
-- ==========================================

local function OpenMenu()
    MainFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
end

local function CloseMenu()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, -0.5, 0)})
    tween:Play()
end

CloseBtn.MouseButton1Click:Connect(CloseMenu)

-- КНОПКА-ПЕРЕКЛЮЧАТЕЛЬ ДЛЯ ТЕЛЕФОНОВ (Будет висеть на экране)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "MenuToggle"
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 50) -- Делаем круглым
ToggleCorner.Parent = ToggleButton

local menuOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        OpenMenu()
    else
        CloseMenu()
    end
end)

-- Автоматический старт с анимацией появления
OpenMenu()
menuOpen = true
