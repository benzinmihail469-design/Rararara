local Players = game:GetService("Services")
local player = Players.LocalPlayer

-- Ждём персонажа
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Ищем папку с лутом (проверяем несколько вариантов)
local LOOT_FOLDER = workspace:FindFirstChild("Loot")
if not LOOT_FOLDER then
    LOOT_FOLDER = workspace:FindFirstChild("loot")
end
if not LOOT_FOLDER then
    LOOT_FOLDER = workspace:FindFirstChild("Gameplay128")
    if LOOT_FOLDER then
        LOOT_FOLDER = LOOT_FOLDER:FindFirstChild("Loot")
    end
end

if not LOOT_FOLDER then
    warn("Не найдена папка с лутом! Доступные папки в workspace:")
    for _, v in pairs(workspace:GetChildren()) do
        print(" -", v.Name)
    end
    return
end

print("Папка найдена:", LOOT_FOLDER.Name)

-- Функция телепортации к объекту
local function teleportToLoot(lootModel)
    task.wait(0.05)
    
    -- Ищем часть, к которой телепортироваться
    local targetPart = lootModel.PrimaryPart
    if not targetPart then
        targetPart = lootModel:FindFirstChildWhichIsA("BasePart")
    end
    if not targetPart then
        targetPart = lootModel:FindFirstChild("HumanoidRootPart")
    end
    
    if targetPart and humanoidRootPart then
        local targetPos = targetPart.Position
        local currentPos = humanoidRootPart.Position
        local distance = (currentPos - targetPos).Magnitude
        
        if distance > 3 then  -- телепортируемся, если не стоим уже вплотную
            humanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
            print("Телепорт к:", lootModel.Name)
        end
    end
end

-- Следим за новым лутом
LOOT_FOLDER.ChildAdded:Connect(teleportToLoot)

-- Телепортируемся к уже существующему луту
for _, loot in pairs(LOOT_FOLDER:GetChildren()) do
    task.spawn(function() teleportToLoot(loot) end)
end

print("Скрипт работает. Ждём появления лута в папке", LOOT_FOLDER.Name)
