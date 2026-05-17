-- Простой скрипт для Slime RNG: Кнопка сбора лута
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "LootCollectorGUI"

-- Создаём кнопку
local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, -25) -- Позиция по центру внизу
button.Text = "Собрать лут"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 22

-- Функция сбора лута
local function collectLoot()
    local lootFolder = workspace:FindFirstChild("Loot")
    if lootFolder then
        local collected = 0
        -- Перебираем все объекты в папке "Loot"
        for _, item in ipairs(lootFolder:GetChildren()) do
            -- Простая попытка "подобрать" предмет
            -- Эффективность может зависеть от структуры игры
            if item:IsA("BasePart") or item:FindFirstChild("ClickDetector") then
                -- Перемещаем предмет к игроку или пытаемся его активировать
                firetouchinterest(item, player.Character and player.Character:FindFirstChild("HumanoidRootPart") or nil, 0)
                firetouchinterest(item, player.Character and player.Character:FindFirstChild("HumanoidRootPart") or nil, 1)
                collected = collected + 1
            end
        end
        print("Попытка сбора лута: обработано " .. collected .. " предметов.")
    else
        print("Папка 'Loot' не найдена. Возможно, она находится в другом месте.")
    end
end

-- Привязываем функцию к кнопке
button.MouseButton1Click:Connect(collectLoot)
