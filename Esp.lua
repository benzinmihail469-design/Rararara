local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")

-- Максимальный приоритет
screenGui.DisplayOrder = 9999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

mainFrame.Parent = screenGui

-- Размер и позиция (ТВОИ РАЗМЕРЫ)
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

-- ============ ДОБАВЛЯЕМ ЗАГОЛОВОК "DARK HUB" ============
-- (Всё остальное НЕ ТРОГАЮ)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleClip = Instance.new("Frame")
titleClip.Size = UDim2.new(1, 0, 1, 12)
titleClip.BackgroundTransparency = 1
titleClip.ClipsDescendants = true
titleClip.Parent = titleBar

-- Акцентная полоска
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
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleClip

-- Подзаголовок
local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(1, -20, 0.4, 0)
subText.Position = UDim2.new(0.02, 0, 0.55, 0)
subText.BackgroundTransparency = 1
subText.Text = "Dark Hub Script"
subText.TextColor3 = Color3.fromRGB(150, 150, 160)
subText.TextSize = 9
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

-- НЕМНОГО СДВИГАЕМ КОНТЕНТ ВНИЗ (ЧТОБЫ НЕ ПЕРЕКРЫВАЛ ЗАГОЛОВОК)
-- ТВОЙ СТАРЫЙ mainFrame ОСТАЁТСЯ, ПРОСТО ДОБАВЛЯЕМ ОТСТУП

-- Добавляем ScrollingFrame для контента (чтобы кнопки не перекрывались)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -40)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

-- ТВОЙ СТАРЫЙ ТЕКСТ (переносим в scrollFrame)
local text = Instance.new("TextLabel")
text.Size = UDim2.new(0.94, 0, 0, 50)
text.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
text.Text = "✅ Dark Hub загружен!\nНе пропадает после смерти!"
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextSize = 14
text.TextWrapped = true
text.Parent = scrollFrame

local textCorner = Instance.new("UICorner")
textCorner.CornerRadius = UDim.new(0, 8)
textCorner.Parent = text

-- Обновляем размер скролла
local function updateSize()
    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
updateSize()

print("✅ Моё окно теперь поверх ВСЕХ других GUI и с заголовком Dark Hub!")

-- ============ ЗАЩИТА ОТ ПРОПАДАНИЯ ============

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
        
        print("✅ GUI был восстановлен!")
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
print("=" .. string.rep("=", 50))
