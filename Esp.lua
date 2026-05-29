local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local isActive = true  -- Включение/выключение атаки

function damageAroundPlayer(damage, radius)
    if not isActive then return end
    
    local character = LocalPlayer.Character
    if not character or not character.Parent then
        print("Ждём появления персонажа...")
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    
    local center = humanoidRootPart.Position
    local enemiesHit = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local enemyChar = player.Character
            if enemyChar and enemyChar:FindFirstChild("HumanoidRootPart") then
                local enemyRoot = enemyChar.HumanoidRootPart
                local humanoid = enemyChar:FindFirstChild("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    local distance = (enemyRoot.Position - center).Magnitude
                    if distance <= radius then
                        humanoid.Health = math.max(0, humanoid.Health - damage)
                        enemiesHit = enemiesHit + 1
                    end
                end
            end
        end
    end
    
    if enemiesHit > 0 then
        print("⚡ Атака " .. damage .. " урона | Задето: " .. enemiesHit .. " | Радиус: " .. radius)
    end
end

-- При возрождении персонажа
LocalPlayer.CharacterAdded:Connect(function()
    print("Персонаж появился, атака активна!")
    task.wait(1)
end)

-- Запускаем атаку
while true do
    damageAroundPlayer(1000, 50)
    task.wait(0.005)
end
