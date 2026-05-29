-- ТВОЙ СТАРЫЙ СКРИПТ + ЗАГОЛОВОК Dark Hub + КНОПКИ

local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")

-- Максимальный приоритет
screenGui.DisplayOrder = 9999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

mainFrame.Parent = screenGui

-- Размер и позиция (500x300)
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Защита от перекрытия
mainFrame.ZIndex = 9999
mainFrame.BackgroundTransparency = 0

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Тень
local shadow = Instance.new("UIStroke")
shadow.Thickness = 2
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Transparency = 0.5
shadow.Parent = mainFrame

-- ============ ЗАГОЛОВОК DARK HUB ============

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Скругление только сверху
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleClip = Instance.new("Frame")
titleClip.Size = UDim2.new(1, 0, 1, 12)
titleClip.BackgroundTransparency = 1
titleClip.ClipsDescendants = true
titleClip.Parent = titleBar

-- Фиолетовая полоска
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 4, 1, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
accentBar.BorderSizePixel = 0
accentBar.Parent = titleClip

-- Текст DARK HUB (красивый шрифт, без эмодзи)
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0.02, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DARK HUB"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleClip

-- ============ КНОПКА СВОРАЧИВАНИЯ ============

local minimizeBtn = Instance.new("ImageButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Image = "rbxassetid://7072725342"
minimizeBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.Parent = titleClip

-- Переменная для состояния окна
local isMinimized = false
local oldSize = mainFrame.Size
local oldHeight = 300

minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        -- Разворачиваем
        mainFrame.Size = UDim2.new(0, 500, 0, oldHeight)
        minimizeBtn.Image = "rbxassetid://7072725342"
        minimizeBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
        isMinimized = false
    else
        -- Сворачиваем (оставляем только заголовок)
        oldHeight = mainFrame.Size.Y.Offset
        mainFrame.Size = UDim2.new(0, 500, 0, 35)
        minimizeBtn.Image = "rbxassetid://7072706620"
        minimizeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
        isMinimized = true
    end
end)

-- ============ КНОПКА ЗАКРЫТИЯ (ЗАКРЫВАЕТ ВЕСЬ СКРИПТ) ============

local closeBtn = Instance.new("ImageButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
closeBtn.BackgroundTransparency = 1
closeBtn.Image = "rbxassetid://7072725342"
closeBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Parent = titleClip

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()  -- Полностью закрывает GUI
    print("Dark Hub закрыт!")
end)

-- ============ ТВОЙ СТАРЫЙ ТЕКСТ (немного сдвинут вниз) ============

local text = Instance.new("TextLabel")
text.Size = UDim2.new(0.9, 0, 0, 50)
text.Position = UDim2.new(0.05, 0, 0.15, 0)
text.BackgroundTransparency = 1
text.Text = "✅ Dark Hub загружен!\nНе пропадает после смерти!"
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextSize = 16
text.TextWrapped = true
text.Parent = mainFrame

print("✅ Dark Hub загружен! Есть кнопка свернуть и закрыть!")

-- ============ ЗАЩИТА ОТ ПРОПАДАНИЯ (ТВОЙ КОД) ============

local function protectGUI()
    if not screenGui or not screenGui.Parent then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DarkHub"
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 9999
        screenGui.Parent = game.Players.LocalPlayer.PlayerGui
        
        mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 500, 0, 300)
        mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.Parent = screenGui
        
        print("GUI был восстановлен!")
    end
end

game:GetService("RunService").Stepped:Connect(protectGUI)
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    protectGUI()
end)

print("=" .. string.rep("=", 50))
print("🔒 ЗАЩИТА АКТИВИРОВАНА!")
print("✅ DARK HUB НЕ ИСЧЕЗАЕТ ПОСЛЕ СМЕРТИ")
print("✅ ЕСТЬ КНОПКА СВЕРНУТЬ И ЗАКРЫТЬ")
print("=" .. string.rep("=", 50))
