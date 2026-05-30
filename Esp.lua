-- Kill Aura для зомби - ТОЛЬКО УРОН (НЕ ТРОГАЕТ ИГРОКОВ)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

print("🧟 KILL AURA (ТОЛЬКО ЗОМБИ) АКТИВИРОВАНА! Урон 1000, Радиус 200")

while true do
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local myPos = rootPart.Position
            
            -- Ищем всех с Humanoid в Workspace
            for _, obj in pairs(Workspace:GetDescendants()) do
                local humanoid = obj:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    
                    -- ПРОВЕРКА: это НЕ игрок?
                    local isPlayer = false
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character == obj or (player.Character and obj:IsDescendantOf(player.Character)) then
                            isPlayer = true
                            break
                        end
                    end
                    
                    -- Атакуем ТОЛЬКО если это не игрок
                    if not isPlayer and not obj:IsDescendantOf(character) then
                        local objPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                        
                        if objPart then
                            local distance = (objPart.Position - myPos).Magnitude
                            
                            if distance <= 200 then
                                humanoid:TakeDamage(1000)
                                print("💀 Урон 1000 по зомби | Расстояние: " .. math.floor(distance))
                            end
                        end
                    end
                end
            end
        end
    end
    task.wait(0.005)
end
