local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")

-- 👑 МАКСИМАЛЬНЫЙ ПРИОРИТЕТ
screenGui.DisplayOrder = 9999  -- Максимальное значение
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global  -- Глобальные слои
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

mainFrame.Parent = screenGui

-- Размер и позиция
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- 🛡️ Защита от перекрытия (максимальный слой)
mainFrame.ZIndex = 9999
mainFrame.BackgroundTransparency = 0  -- Непрозрачный

-- Скругли углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Добавим тень для красоты
local shadow = Instance.new("UIStroke")
shadow.Thickness = 2
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Transparency = 0.5
shadow.Parent = mainFrame

print("✅ Моё окно теперь поверх ВСЕХ других GUI!")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyPersistentGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

-- Защита от случайного удаления
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

-- Автоматическое восстановление, если GUI вдруг пропал
local function protectGUI()
    if not screenGui or not screenGui.Parent then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MyPersistentGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game.Players.LocalPlayer.PlayerGui
        print("🛡️ GUI был восстановлен!")
    end
end

-- Проверяем каждую секунду
game:GetService("RunService").Stepped:Connect(protectGUI)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Parent = screenGui

print("✅ Защищённый GUI работает!")
