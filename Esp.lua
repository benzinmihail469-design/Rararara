-- DARK HUB - РАБОЧАЯ ВЕРСИЯ (ОРИГИНАЛЬНЫЙ РАЗМЕР 500x300)
-- Полностью переписан, размер как в старом скрипте

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Удаляем старый GUI, если есть
local oldGui = LocalPlayer.PlayerGui:FindFirstChild("DarkHub")
if oldGui then oldGui:Destroy() end

-- ============ СОЗДАЁМ НОВЫЙ GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkHub"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = LocalPlayer.PlayerGui

-- ============ ГЛАВНОЕ ОКНО (РАЗМЕР 500x300 КАК В СТАРОМ) ============
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 300)     -- ← ТОЧНО КАК В СТАРОМ СКРИПТЕ!
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 9999
mainFrame.Parent = screenGui

-- Скругление углов
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Тень
local mainShadow = Instance.new("UIStroke")
mainShadow.Thickness = 2
mainShadow.Color = Color3.fromRGB(0, 0, 0)
mainShadow.Transparency = 0.5
mainShadow.Parent = mainFrame

-- ============ ЗАГОЛОВОК DARK HUB ============

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)        -- Уменьшил под размер окна
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Клиппер для скругления
local titleClip = Instance.new("Frame")
titleClip.Size = UDim2.new(1, 0, 1, 12)
titleClip.BackgroundTransparency = 1
titleClip.ClipsDescendants = true
titleClip.Parent = titleBar

-- Фиолетовая полоска слева
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 4, 1, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
accentBar.BorderSizePixel = 0
accentBar.Parent = titleClip

-- Текст DARK HUB
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -20, 1, 0)
titleText.Position = UDim2.new(0.02, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DARK HUB"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleClip

-- Подзаголовок
local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(1, -20, 0.4, 0)
subText.Position = UDim2.new(0.02, 0, 0.55, 0)
subText.BackgroundTransparency = 1
subText.Text = "Persistent GUI | Never Dies"
subText.TextColor3 = Color3.fromRGB(150, 150, 160)
subText.TextSize = 10
subText.Font = Enum.Font.Gotham
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.Parent = titleClip

-- Разделительная линия
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.96, 0, 0, 1)
divider.Position = UDim2.new(0.02, 0, 1, -5)
divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
divider.BorderSizePixel = 0
divider.Parent = titleClip

-- ============ КОНТЕНТНАЯ ОБЛАСТЬ ============

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 200)
scrollFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = scrollFrame

-- ============ ПРИМЕРЫ ЭЛЕМЕНТОВ ============

-- Приветственный текст
local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(0.94, 0, 0, 35)
welcomeText.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
welcomeText.Text = "Добро пожаловать в Dark Hub!"
welcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeText.TextSize = 13
welcomeText.Font = Enum.Font.Gotham
welcomeText.Parent = scrollFrame

local welcomeCorner = Instance.new("UICorner")
welcomeCorner.CornerRadius = UDim.new(0, 8)
welcomeCorner.Parent = welcomeText

-- Кнопка Kill Aura
local killAuraBtn = Instance.new("TextButton")
killAuraBtn.Size = UDim2.new(0.94, 0, 0, 40)
killAuraBtn.Text = "KILL AURA"
killAuraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killAuraBtn.TextSize = 14
killAuraBtn.Font = Enum.Font.GothamBold
killAuraBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
killAuraBtn.BorderSizePixel = 0
killAuraBtn.Parent = scrollFrame

local killCorner = Instance.new("UICorner")
killCorner.CornerRadius = UDim.new(0, 8)
killCorner.Parent = killAuraBtn

killAuraBtn.MouseButton1Click:Connect(function()
    killAuraBtn.Text = "АКТИВИРОВАНО!"
    killAuraBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 100)
    task.delay(1, function()
        killAuraBtn.Text = "KILL AURA"
        killAuraBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
    end)
    print("[Dark Hub] Kill Aura активирована!")
end)

-- Кнопка ESP
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0.94, 0, 0, 40)
espBtn.Text = "ESP PLAYERS"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 14
espBtn.Font = Enum.Font.GothamBold
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
espBtn.BorderSizePixel = 0
espBtn.Parent = scrollFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espBtn

espBtn.MouseButton1Click:Connect(function()
    espBtn.Text = "ESP ВКЛЮЧЁН!"
    espBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 100)
    task.delay(1, function()
        espBtn.Text = "ESP PLAYERS"
        espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    print("[Dark Hub] ESP включён!")
end)

-- Информация о защите
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(0.94, 0, 0, 30)
infoText.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
infoText.Text = "🔒 GUI защищён | Не исчезает после смерти"
infoText.TextColor3 = Color3.fromRGB(150, 150, 160)
infoText.TextSize = 10
infoText.Font = Enum.Font.Gotham
infoText.Parent = scrollFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoText

-- ============ ОБНОВЛЕНИЕ РАЗМЕРА СКРОЛЛА ============

local function updateCanvas()
    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- ============ АНИМАЦИЯ ПОЯВЛЕНИЯ ============

mainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.3), {
    Size = UDim2.new(0, 500, 0, 300)
}):Play()

print("=" .. string.rep("=", 50))
print("✅ DARK HUB ЗАГРУЖЕН!")
print("📐 Размер окна: 500x300 (как в старом скрипте)")
print("🔒 Защита от смерти: ВКЛЮЧЕНА")
print("=" .. string.rep("=", 50))
