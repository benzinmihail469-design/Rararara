-- DARK HUB - РАБОЧАЯ ВЕРСИЯ
-- Полностью переписан, без конфликтов

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Удаляем старый GUI, если есть (чтобы не было конфликта)
local oldGui = LocalPlayer.PlayerGui:FindFirstChild("DarkHub")
if oldGui then oldGui:Destroy() end

-- ============ СОЗДАЁМ НОВЫЙ GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkHub"
screenGui.ResetOnSpawn = false          -- НЕ пропадает после смерти
screenGui.DisplayOrder = 9999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = LocalPlayer.PlayerGui

-- ============ ГЛАВНОЕ ОКНО ============
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 520)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
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
titleBar.Size = UDim2.new(1, 0, 0, 55)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Клиппер для скругления (только сверху)
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

-- Текст DARK HUB (без эмодзи, красивый шрифт)
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -20, 1, 0)
titleText.Position = UDim2.new(0.02, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DARK HUB"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 24
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
subText.TextSize = 11
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

-- ============ КНОПКА ЗАКРЫТИЯ ============

local closeBtn = Instance.new("ImageButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundTransparency = 1
closeBtn.Image = "rbxassetid://7072725342"
closeBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Parent = titleClip

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ============ КОНТЕНТ (скроллинг) ============

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -55)
scrollFrame.Position = UDim2.new(0, 0, 0, 55)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 200)
scrollFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = scrollFrame

-- ============ ПРИМЕРЫ ЭЛЕМЕНТОВ ============

-- Текст "Добро пожаловать"
local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(0.94, 0, 0, 40)
welcomeLabel.Position = UDim2.new(0.03, 0, 0, 0)
welcomeLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
welcomeLabel.Text = "Добро пожаловать в Dark Hub!"
welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeLabel.TextSize = 14
welcomeLabel.Font = Enum.Font.Gotham
welcomeLabel.Parent = scrollFrame

local welcomeCorner = Instance.new("UICorner")
welcomeCorner.CornerRadius = UDim.new(0, 8)
welcomeCorner.Parent = welcomeLabel

-- Кнопка Kill Aura
local killAuraBtn = Instance.new("TextButton")
killAuraBtn.Size = UDim2.new(0.94, 0, 0, 50)
killAuraBtn.Position = UDim2.new(0.03, 0, 0, 50)
killAuraBtn.Text = "KILL AURA"
killAuraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killAuraBtn.TextSize = 16
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
    task.delay(1.5, function()
        killAuraBtn.Text = "KILL AURA"
        killAuraBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
    end)
    print("[Dark Hub] Kill Aura активирована!")
end)

-- Кнопка ESP
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0.94, 0, 0, 50)
espBtn.Position = UDim2.new(0.03, 0, 0, 110)
espBtn.Text = "ESP PLAYERS"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 16
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
    task.delay(1.5, function()
        espBtn.Text = "ESP PLAYERS"
        espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    print("[Dark Hub] ESP включён!")
end)

-- Информационная строка
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.94, 0, 0, 30)
infoLabel.Position = UDim2.new(0.03, 0, 0, 170)
infoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
infoLabel.Text = "⚡ Dark Hub | Работает после смерти"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
infoLabel.TextSize = 11
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = scrollFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoLabel

-- ============ ОБНОВЛЕНИЕ РАЗМЕРА СКРОЛЛА ============

local function updateCanvas()
    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.wait()
updateCanvas()

-- ============ АНИМАЦИЯ ПОЯВЛЕНИЯ ============

mainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.3), {
    Size = UDim2.new(0, 420, 0, 520)
}):Play()

-- ============ ВЫВОД В КОНСОЛЬ ============

print("=" .. string.rep("=", 50))
print("✅ DARK HUB ЗАГРУЖЕН!")
print("📱 Название: Dark Hub")
print("🔒 Защита от смерти: ВКЛЮЧЕНА")
print("=" .. string.rep("=", 50))
