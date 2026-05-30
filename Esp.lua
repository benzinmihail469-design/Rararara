-- Kill Aura для зомби - ТОЛЬКО УРОН (ТОЛЬКО Zombies_Local)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

print("🧟 KILL AURA (ТОЛЬКО ZOMBIES_LOCAL) АКТИВИРОВАНА! Урон 1000, Радиус 200")

while true do
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local myPos = rootPart.Position
            
            -- Получаем папку с зомби
            local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
            
            if zombiesFolder then
                -- Перебираем всех детей в папке Zombies_Local
                for _, zombie in pairs(zombiesFolder:GetChildren()) do
                    -- Проверяем, что это именно зомби (по имени или наличию Humanoid)
                    if zombie.Name == "Zombie" or zombie:FindFirstChild("Humanoid") then
                        local humanoid = zombie:FindFirstChild("Humanoid")
                        
                        if humanoid and humanoid.Health > 0 then
                            local objPart = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
                            
                            if objPart then
                                local distance = (objPart.Position - myPos).Magnitude
                                
                                if distance <= 200 then
                                    -- Наносим урон 1000
                                    humanoid:TakeDamage(1000)
                                    print("💀 Урон 1000 по Zombie | Расстояние: " .. math.floor(distance))
                                end
                            end
                        end
                    end
                end
            else
                warn("Папка Zombies_Local не найдена в Workspace!")
            end
        end
    end
    task.wait(0.005)
end
