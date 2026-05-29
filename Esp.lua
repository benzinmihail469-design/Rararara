-- Kill Aura для зомби - 1000 урона в радиусе 200

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Ищем папку с зомби
local zombieFolder = Workspace:FindFirstChild("Zombes_Local")

if not zombieFolder then
    print("❌ Папка Zombes_Local не найдена, ищу везде...")
    zombieFolder = Workspace  -- Если папки нет, ищем во всём Workspace
end

print("✅ Kill Aura активирована! Радиус 200, урон 1000")

while true do
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local playerPos = rootPart.Position
            
            -- Ищем всех с Humanoid (зомби/врагов)
            local enemies = Workspace:GetDescendants()
            
            for _, enemy in pairs(enemies) do
                local humanoid = enemy:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    -- Проверяем, не является ли враг самим игроком
                    if enemy ~= character and not enemy:IsDescendantOf(character) then
                        local enemyPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head")
                        
                        if enemyPart then
                            local distance = (enemyPart.Position - playerPos).Magnitude
                            
                            if distance <= 200 then
                                humanoid.Health = humanoid.Health - 1000
                                print("💀 Урон 1000! | Расстояние: " .. math.floor(distance))
                            end
                        end
                    end
                end
            end
        end
    end
    
    task.wait(0.005)
end
