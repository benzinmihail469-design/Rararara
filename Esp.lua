--[[
    Dark Hub - Persistent GUI
    Скрипт с защитой от пропадания после смерти
    Автор: для обучения
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- ============ СОЗДАЁМ ГЛАВНЫЙ GUI ============

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkHub"                    -- Название GUI
screenGui.DisplayOrder = 9999                 -- Максимальный приоритет (поверх всех)
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false                -- НЕ сбрасывать при смерти (ВАЖНО!)
screenGui.Parent = LocalPlayer.PlayerGui

-- ============ ГЛАВНОЕ ОКНО ============

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 550)    -- Ширина 450, высота 550
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)  -- Центр экрана
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)  -- Тёмный фон
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 9999
mainFrame.Parent = screenGui

-- Скругление углов главного окна
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)     -- Радиус скругления 12 пикселей
mainCorner.Parent = mainFrame

-- Тень для главного окна (красиво)
local mainShadow = Instance.new("UIStroke")
mainShadow.Thickness = 2
mainShadow.Color = Color3.fromRGB(0, 0, 0)
mainShadow.Transparency = 0.5
mainShadow.Parent = mainFrame

-- ============ КРАСИВЫЙ ЗАГОЛОВОК "DARK HUB" ============

-- Верхняя панель заголовка
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)        -- Во всю ширину, высота 60
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)  -- Чуть темнее фона
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Скругление верхней панели (только сверху)
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Отрезаем нижнее скругление (чтобы углы были только сверху)
local titleClip = Instance.new("Frame")
titleClip.Size = UDim2.new(1, 0, 1, 12)
titleClip.BackgroundTransparency = 1
titleClip.ClipsDescendants = true
titleClip.Parent = titleBar

-- Цветная полоска в левой части заголовка (акцент)
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 4, 1, 0)        -- Тонкая полоска шириной 4px
accentBar.BackgroundColor3 = Color3.fromRGB(100, 80, 200)  -- Фиолетовый акцент
accentBar.BorderSizePixel = 0
accentBar.Parent = titleClip

-- ============ ТЕКСТ ЗАГОЛОВКА "DARK HUB" ============

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -20, 1, 0)      -- На всю ширину с отступом
titleText.Position = UDim2.new(0.02, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DARK HUB"                   -- Название (без эмодзи)
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Белый цвет
titleText.TextSize = 26                       -- Размер шрифта
titleText.TextScaled = false
titleText.Font = Enum.Font.GothamBold         -- Красивый жирный шрифт
titleText.TextXAlignment = Enum.TextXAlignment.Left  -- По левому краю
titleText.Parent = titleClip

-- Подзаголовок (необязательно, но красиво)
local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(1, -20, 0.4, 0)
subText.Position = UDim2.new(0.02, 0, 0.55, 0)
subText.BackgroundTransparency = 1
subText.Text = "Persistent GUI | Never Dies"
subText.TextColor3 = Color3.fromRGB(150, 150, 160)  -- Светло-серый
subText.TextSize = 12
subText.Font = Enum.Font.Gotham
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.Parent = titleClip

-- Разделительная линия под заголовком
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.96, 0, 0, 1)
divider.Position = UDim2.new(0.02, 0, 1, -5)
divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
divider.BorderSizePixel = 0
divider.Parent = titleClip

-- ============ КОНТЕНТНАЯ ОБЛАСТЬ (скроллинг) ============

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -60)     -- На всю высоту под заголовком
scrollFrame.Position = UDim2.new(0, 0, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 200)  -- Цвет скролла
scrollFrame.Parent = mainFrame

-- Автоматическое расположение элементов
local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)        -- Отступ между элементами 10px
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = scrollFrame

-- ============ ПРИМЕРЫ ЭЛЕМЕНТОВ ============

-- Приветственный текст
local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(0.94, 0, 0, 45)
welcomeText.Position = UDim2.new(0.03, 0, 0, 0)
welcomeText.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
welcomeText.BackgroundTransparency = 0
welcomeText.Text = "Добро пожаловать в Dark Hub!"
welcomeText.TextColor3 = Color3.fromRGB(200, 200, 200)
welcomeText.TextSize = 14
welcomeText.Font = Enum.Font.Gotham
welcomeText.Parent = scrollFrame

local welcomeCorner = Instance.new("UICorner")
welcomeCorner.CornerRadius = UDim.new(0, 8)
welcomeCorner.Parent = welcomeText

-- Кнопка для теста
local testButton = Instance.new("TextButton")
testButton.Size = UDim2.new(0.94, 0, 0, 50)
testButton.Position = UDim2.new(0.03, 0, 0, 55)
testButton.Text = "ТЕСТОВАЯ КНОПКА"
testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
testButton.TextSize = 14
testButton.Font = Enum.Font.GothamSemibold
testButton.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
testButton.BorderSizePixel = 0
testButton.Parent = scrollFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = testButton

-- Эффект при нажатии на кнопку
testButton.MouseButton1Click:Connect(function()
    testButton.Text = "Нажато!"
    testButton.BackgroundColor3 = Color3.fromRGB(60, 150, 100)
    task.delay(1, function()
        testButton.Text = "ТЕСТОВАЯ КНОПКА"
        testButton.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
    end)
    print("Кнопка нажата!")
end)

-- Информация о защите GUI
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(0.94, 0, 0, 35)
infoText.Position = UDim2.new(0.03, 0, 0, 115)
infoText.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
infoText.Text = "🔒 GUI защищён | Не исчезает после смерти"
infoText.TextColor3 = Color3.fromRGB(150, 150, 160)
infoText.TextSize = 11
infoText.Font = Enum.Font.Gotham
infoText.Parent = scrollFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoText

-- ============ ОБНОВЛЕНИЕ РАЗМЕРА СКРОЛЛА ============

local function updateCanvasSize()
    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
updateCanvasSize()

-- ============ АНИМАЦИЯ ПОЯВЛЕНИЯ ============

mainFrame.Size = UDim2.new(0, 0, 0, 0)  -- Начинаем с нулевого размера
TweenService:Create(mainFrame, TweenInfo.new(0.3), {
    Size = UDim2.new(0, 450, 0, 550)
}):Play()

print("✅ Dark Hub загружен! GUI не пропадает после смерти!")

-- ============ ЗАЩИТА ОТ ПРОПАДАНИЯ ПОСЛЕ СМЕРТИ ============

local function protectGUI()
    if not screenGui or not screenGui.Parent then
        print("🔄 GUI пропал! Восстанавливаем Dark Hub...")
        
        -- Восстанавливаем ScreenGui
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DarkHub"
        screenGui.DisplayOrder = 9999
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        screenGui.ResetOnSpawn = false
        screenGui.Parent = LocalPlayer.PlayerGui
        
        -- Восстанавливаем mainFrame
        mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 450, 0, 550)
        mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        mainFrame.ZIndex = 9999
        mainFrame.Parent = screenGui
        
        local newCorner = Instance.new("UICorner")
        newCorner.CornerRadius = UDim.new(0, 12)
        newCorner.Parent = mainFrame
        
        print("✅ Dark Hub восстановлен!")
    end
end

-- Проверяем каждые 3 секунды
spawn(function()
    while true do
        task.wait(3)
        protectGUI()
    end
end)

-- При возрождении персонажа проверяем
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    protectGUI()
end)

print("=" .. string.rep("=", 50))
print("🔒 ЗАЩИТА АКТИВИРОВАНА!")
print("✅ DARK HUB НЕ ИСЧЕЗАЕТ ПОСЛЕ СМЕРТИ")
print("=" .. string.rep("=", 50))
