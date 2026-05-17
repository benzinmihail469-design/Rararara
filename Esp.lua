-- Автоматический телепорт к луту при появлении модели в папке
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- 🔧 НАСТРОЙКИ (измени под себя)
local LOOT_FOLDER_PATH = workspace:WaitForChild("Loot")  -- папка где появляются модели лута
local CHECK_INTERVAL = 0.5  -- секунд между проверками
local TELEPORT_OFFSET = Vector3.new(0, 2, 0)  -- смещение при телепортации (чтобы не застревать)
local DISTANCE_THRESHOLD = 3  -- если уже ближе этого расстояния, не телепортироваться снова

-- Следим за появлением новых моделей в папке
local function onChildAdded(newLoot)
    if not newLoot:IsA("Model") then return end  -- только модели
    
    task.wait(0.1)  -- даём игре прогрузиться
    
    -- Телепортируемся к луту
    if humanoidRootPart and newLoot.PrimaryPart then
        local lootPos = newLoot.PrimaryPart.Position
        local currentPos = humanoidRootPart.Position
        local distance = (currentPos - lootPos).Magnitude
        
        if distance > DISTANCE_THRESHOLD then
            humanoidRootPart.CFrame = CFrame.new(lootPos + TELEPORT_OFFSET)
            print("Телепорт к луту:", newLoot.Name)
        end
    end
end

-- Также обрабатываем лут, который уже есть в папке при запуске
local function teleportToExistingLoot()
    for _, loot in pairs(LOOT_FOLDER_PATH:GetChildren()) do
        if loot:IsA("Model") and loot.PrimaryPart then
            humanoidRootPart.CFrame = CFrame.new(loot.PrimaryPart.Position + TELEPORT_OFFSET)
            task.wait(0.2)
        end
    end
end

-- Запуск
LOOT_FOLDER_PATH.ChildAdded:Connect(onChildAdded)
teleportToExistingLoot()

print("Скрипт запущен. Ожидание лута в папке:", LOOT_FOLDER_PATH.Name)
