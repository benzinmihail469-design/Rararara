--[=[
MODERN DARK/NEON ROBLOX GUI (500x300)
Особенности:
- Фиксированный размер 500x300
- Поддержка перетаскивания (ПК / Смартфоны)
- Готовые элементы: Кнопки, Слайдеры, Переключатели (Toggles)
--]=]
​local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
​-- Защита от дублирования интерфейса
if PlayerGui:FindFirstChild("AdvancedMenuGui") then
PlayerGui.AdvancedMenuGui:Destroy()
end
​local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui
​-- ==========================================
-- ГЛАВНОЕ ОКНО (Строго 500x300)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150) -- Центрирование на экране
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
​-- Красивое скругление углов
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame
​-- Фиолетовая неоновая обводка
local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Color = Color3.fromRGB(168, 85, 247) -- Neon Purple
FrameStroke.Transparency = 0.1
FrameStroke.Parent = MainFrame
​-- ==========================================
-- СИСТЕМА ПЕРЕТАСКИВАНИЯ (Драг на ПК и Телефонах)
-- ==========================================
local dragging, dragInput, dragStart, startPos
​local function updateDrag(input)
local delta = input.Position - dragStart
-- Плавное перемещение фрейма по экрану
local targetPos = UDim2.new(
startPos.X.Scale,
startPos.X.Offset + delta.X,
startPos.Y.Scale,
startPos.Y.Offset + delta.Y
)
TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {Position = targetPos}):Play()
end
​MainFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = MainFrame.Position
​input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
​MainFrame.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
​UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
updateDrag(input)
end
end)
​-- ==========================================
-- ШАПКА ОКНА (Заголовок)
-- ==========================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
​local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header
​-- Текст заголовка
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ PREMIER HUB v2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header
​-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 16
CloseBtn.Parent = Header
​CloseBtn.MouseButton1Click:Connect(function()
ScreenGui:Destroy()
end)
​-- ==========================================
-- КОНТЕЙНЕР ДЛЯ ЭЛЕМЕНТОВ (Скролл)
-- ==========================================
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
Container.Parent = MainFrame
​local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container
​-- Скрипт авторазмера под контент
local function updateScrollSize()
Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSize)
​-- ==========================================
-- БИБЛИОТЕКА ЭЛЕМЕНТОВ (API)
-- ==========================================
local Library = {}
​-- 1. Создание обычной кнопки
function Library:CreateButton(text, callback)
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -5, 0, 38)
Button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Button.BorderSizePixel = 0
Button.Font = Enum.Font.GothamSemibold
Button.Text = "   " .. text
Button.TextColor3 = Color3.fromRGB(220, 220, 220)
Button.TextSize = 13
Button.TextXAlignment = Enum.TextXAlignment.Left
Button.Parent = Container
​local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = Button
​-- Эффекты
Button.MouseEnter:Connect(function()
TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(38, 38, 48), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
Button.MouseLeave:Connect(function()
TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38), TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
end)
Button.MouseButton1Click:Connect(callback)
end
​-- 2. Создание переключателя (Toggle / "Кнопка плюс")
function Library:CreateToggle(text, defaultState, callback)
local state = defaultState or false
​local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(1, -5, 0, 40)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
ToggleFrame.BorderSizePixel = 0
ToggleFrame.Parent = Container
​local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = ToggleFrame
​local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(0.7, 0, 1, 0)
Label.Position = UDim2.new(0, 12, 0, 0)
Label.BackgroundTransparency = 1
Label.Font = Enum.Font.GothamSemibold
Label.Text = text
Label.TextColor3 = Color3.fromRGB(200, 200, 200)
Label.TextSize = 13
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = ToggleFrame
​-- Кнопка-переключатель (чекбокс)
local Switch = Instance.new("TextButton")
Switch.Size = UDim2.new(0, 42, 0, 22)
Switch.Position = UDim2.new(1, -54, 0.5, -11)
Switch.BackgroundColor3 = state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(48, 48, 58)
Switch.Text = ""
Switch.Parent = ToggleFrame
​local SwitchCorner = Instance.new("UICorner")
SwitchCorner.CornerRadius = UDim.new(1, 0) -- Круглый переключатель
SwitchCorner.Parent = Switch
​-- Внутренний кружок переключателя
local Indicator = Instance.new("Frame")
Indicator.Size = UDim2.new(0, 16, 0, 16)
Indicator.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Indicator.BorderSizePixel = 0
Indicator.Parent = Switch
​local IndicatorCorner = Instance.new("UICorner")
IndicatorCorner.CornerRadius = UDim.new(1, 0)
IndicatorCorner.Parent = Indicator
​-- Логика переключения
local function toggle()
state = not state
local targetColor = state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(48, 48, 58)
local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
​TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
​callback(state)
end
​Switch.MouseButton1Click:Connect(toggle)
​-- Делаем так, чтобы клик по всей строке тоже переключал
local InvisibleTrigger = Instance.new("TextButton")
InvisibleTrigger.Size = UDim2.new(0.8, 0, 1, 0)
InvisibleTrigger.BackgroundTransparency = 1
InvisibleTrigger.Text = ""
InvisibleTrigger.Parent = ToggleFrame
InvisibleTrigger.MouseButton1Click:Connect(toggle)
end
​-- 3. Создание интерактивного Слайдера
function Library:CreateSlider(text, min, max, default, callback)
local value = default or min
​local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -5, 0, 50)
SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = Container
​local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = SliderFrame
​-- Текст названия
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(0.6, 0, 0, 25)
Label.Position = UDim2.new(0, 12, 0, 2)
Label.BackgroundTransparency = 1
Label.Font = Enum.Font.GothamSemibold
Label.Text = text
Label.TextColor3 = Color3.fromRGB(200, 200, 200)
Label.TextSize = 13
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = SliderFrame
​-- Текст текущего значения
local ValLabel = Instance.new("TextLabel")
ValLabel.Size = UDim2.new(0.3, 0, 0, 25)
ValLabel.Position = UDim2.new(1, -112, 0, 2)
ValLabel.BackgroundTransparency = 1
ValLabel.Font = Enum.Font.GothamBold
ValLabel.Text = tostring(value)
ValLabel.TextColor3 = Color3.fromRGB(168, 85, 247)
ValLabel.TextSize = 13
ValLabel.TextXAlignment = Enum.TextXAlignment.Right
ValLabel.Parent = SliderFrame
​-- Полоска слайдера (задний фон)
local Track = Instance.new("TextButton")
Track.Size = UDim2.new(1, -24, 0, 6)
Track.Position = UDim2.new(0, 12, 1, -14)
Track.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
Track.Text = ""
Track.AutoButtonColor = false
Track.Parent = SliderFrame
​local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = Track
​-- Заполненная часть полоски
local Fill = Instance.new("Frame")
Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
Fill.BorderSizePixel = 0
Fill.Parent = Track
​local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = Fill
​-- Логика движения ползунка
local isSliding = false
​local function updateSlider(input)
local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.Width, 0, 1)
local rawValue = min + (max - min) * percentage
-- Округление до целого для красоты
value = math.floor(rawValue + 0.5)
​Fill.Size = UDim2.new(percentage, 0, 1, 0)
ValLabel.Text = tostring(value)
callback(value)
end
​Track.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
isSliding = true
updateSlider(input)
end
end)
​UserInputService.InputChanged:Connect(function(input)
if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
updateSlider(input)
end
end)
​UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
isSliding = false
end
end)
end
​-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ ТВОИХ ФУНКЦИЙ СЮДА
-- ==========================================
​-- 1. Обычная кнопка
Library:CreateButton("Телепорт к случайному игроку", function()
local players = Players:GetPlayers()
if #players > 1 then
local randomPlayer = players[math.random(1, #players)]
if randomPlayer ~= LocalPlayer and randomPlayer.Character and randomPlayer.Character:FindFirstChild("HumanoidRootPart") then
LocalPlayer.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame
end
end
end)
​-- 2. Слайдер Скорости
Library:CreateSlider("Скорость ходьбы (WalkSpeed)", 16, 150, 16, function(value)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
end
end)
​-- 3. Слайдер Высоты Прыжка
Library:CreateSlider("Сила Прыжка (JumpPower)", 50, 250, 50, function(value)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = value
LocalPlayer.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
end
end)
​-- 4. Переключатель на Бесконечный прыжок
local infiniteJumpConnection
Library:CreateToggle("Бесконечный прыжок", false, function(enabled)
if enabled then
infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end
end)
else
if infiniteJumpConnection then
infiniteJumpConnection:Disconnect()
infiniteJumpConnection = nil
end
end
end)
​-- 5. Переключатель на Ночное видение (Fullbright)
Library:CreateToggle("Супер-яркость (Fullbright)", false, function(enabled)
if enabled then
game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
else
game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128) -- Дефолт
end
end)
​updateScrollSize()
