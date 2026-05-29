-- Survive Zombie Arena - FoxName Hub
local player = game.Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FoxNameHub"
screenGui.DisplayOrder = 999
screenGui.Parent = player.PlayerGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 550)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- ============ ЗАГОЛОВОК ============

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 85)
header.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Обрезаем нижние углы
local headerClip = Instance.new("Frame")
headerClip.Size = UDim2.new(1, 0, 1, 12)
headerClip.Position = UDim2.new(0, 0, 0, 0)
headerClip.BackgroundTransparency = 1
headerClip.ClipsDescendants = true
headerClip.Parent = header

-- Цветная полоска
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 4, 1, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
accentBar.BorderSizePixel = 0
accentBar.Parent = headerClip

-- Название
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0.45, 0)
title.Position = UDim2.new(0.02, 0, 0.15, 0)
title.BackgroundTransparency = 1
title.Text = "Foxname - SZA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = headerClip

-- Описание
local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, -20, 0.3, 0)
description.Position = UDim2.new(0.02, 0, 0.55, 0)
description.BackgroundTransparency = 1
description.Text = "Survive Zombie Arena | Best Script"
description.TextColor3 = Color3.fromRGB(160, 160, 170)
description.TextSize = 12
description.TextXAlignment = Enum.TextXAlignment.Left
description.Font = Enum.Font.Gotham
description.Parent = headerClip

-- Версия
local version = Instance.new("Frame")
version.Size = UDim2.new(0, 65, 0, 24)
version.Position = UDim2.new(1, -75, 0.15, 0)
version.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
version.BackgroundTransparency = 0.15
version.BorderSizePixel = 0
version.Parent = headerClip

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(0, 6)
versionCorner.Parent = version

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(1, 0, 1, 0)
versionText.BackgroundTransparency = 1
versionText.Text = "v1.0.0"
versionText.TextColor3 = Color3.fromRGB(255, 80, 120)
versionText.TextSize = 12
versionText.Font = Enum.Font.GothamBold
versionText.Parent = version

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -16, 0, 1)
divider.Position = UDim2.new(0.02, 0, 1, -30)
divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
divider.BorderSizePixel = 0
divider.Parent = headerClip

-- Discord
local discordBar = Instance.new("Frame")
discordBar.Size = UDim2.new(1, -16, 0, 25)
discordBar.Position = UDim2.new(0.02, 0, 1, -28)
discordBar.BackgroundTransparency = 1
discordBar.Parent = headerClip

local discordText = Instance.new("TextLabel")
discordText.Size = UDim2.new(1, -55, 1, 0)
discordText.BackgroundTransparency = 1
discordText.Text = "discord.gg/Foxname"
discordText.TextColor3 = Color3.fromRGB(100, 100, 200)
discordText.TextSize = 11
discordText.TextXAlignment = Enum.TextXAlignment.Left
discordText.Font = Enum.Font.Gotham
discordText.Parent = discordBar

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 45, 0, 18)
copyBtn.Position = UDim2.new(1, -50, 0.5, -9)
copyBtn.Text = "Copy"
copyBtn.TextSize = 10
copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
copyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
copyBtn.BorderSizePixel = 0
copyBtn.Parent = discordBar

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 4)
copyCorner.Parent = copyBtn

-- ============ КОНТЕНТ (скролл) ============

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -85)
scrollFrame.Position = UDim2.new(0, 0, 0, 85)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 120)
scrollFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = scrollFrame

-- ============ ПРИМЕР КНОПКИ ============

local killAuraBtn = Instance.new("TextButton")
killAuraBtn.Size = UDim2.new(0.94, 0, 0, 45)
killAuraBtn.Position = UDim2.new(0.03, 0, 0, 10)
killAuraBtn.Text = "🔪 Kill Aura"
killAuraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killAuraBtn.TextSize = 14
killAuraBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
killAuraBtn.BorderSizePixel = 0
killAuraBtn.Parent = scrollFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = killAuraBtn

-- Обновляем canvas
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end)

task.wait()
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)

print("✅ FoxName Hub загружен!")
