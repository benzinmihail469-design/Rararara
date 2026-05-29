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

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Пример: показываем death screen после смерти
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.Died:Connect(function()
        -- Здесь логика после смерти
        local deathGui = playerGui:FindFirstChild("DeathScreen") -- или твой GUI
        if deathGui then
            deathGui.Enabled = true
            -- или deathGui.Frame.Visible = true
        end
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)

-- На случай, если персонаж уже загружен
if player.Character then
    onCharacterAdded(player.Character)
end
