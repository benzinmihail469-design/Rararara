-- Исправленный скрипт - GUI не пропадает после смерти

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyPersistentGUI"
screenGui.DisplayOrder = 9999              -- Максимальный приоритет (поверх всех)
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false             -- НЕ сбрасывать при смерти (ВАЖНО!)
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0
mainFrame.ZIndex = 9999                    -- Максимальный слой
mainFrame.Parent = screenGui

-- Скругление углов (ИСПРАВЛЕНО: UICorner, а не UITCorner)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Тень для красоты
local shadow = Instance.new("UIStroke")
shadow.Thickness = 2
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Transparency = 0.5
shadow.Parent = mainFrame

-- Текст для проверки
local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "✅ GUI РАБОТАЕТ!\nНе пропадает после смерти!"
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextSize = 18
text.TextWrapped = true
text.Parent = mainFrame

print("✅ Моё окно теперь поверх ВСЕХ других GUI и не пропадает после смерти!")

-- ============ ЗАЩИТА ОТ ПРОПАДАНИЯ ============

local function protectGUI()
    -- Проверяем, существует ли GUI
    if not screenGui or not screenGui.Parent then
        print("🔄 GUI пропал! Восстанавливаем...")
        
        -- Восстанавливаем ScreenGui
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MyPersistentGUI"
        screenGui.DisplayOrder = 9999
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game.Players.LocalPlayer.PlayerGui
        
        -- Восстанавливаем mainFrame
        mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 500, 0, 300)
        mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.BackgroundTransparency = 0
        mainFrame.ZIndex = 9999
        mainFrame.Parent = screenGui
        
        -- Восстанавливаем скругление
        local newCorner = Instance.new("UICorner")
        newCorner.CornerRadius = UDim.new(0, 12)
        newCorner.Parent = mainFrame
        
        -- Восстанавливаем текст
        local newText = Instance.new("TextLabel")
        newText.Size = UDim2.new(1, 0, 1, 0)
        newText.BackgroundTransparency = 1
        newText.Text = "✅ GUI ВОССТАНОВЛЕН!\nНе пропадает после смерти!"
        newText.TextColor3 = Color3.fromRGB(255, 255, 255)
        newText.TextSize = 18
        newText.TextWrapped = true
        newText.Parent = mainFrame
        
        print("✅ GUI восстановлен!")
    end
end

-- Проверяем каждые 2 секунды
spawn(function()
    while true do
        task.wait(2)
        protectGUI()
    end
end)

-- При возрождении персонажа тоже проверяем
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    protectGUI()
end)

print("=" .. string.rep("=", 50))
print("🔒 ЗАЩИТА АКТИВИРОВАНА!")
print("✅ GUI НЕ ИСЧЕЗАЕТ ПОСЛЕ СМЕРТИ")
print("=" .. string.rep("=", 50))
