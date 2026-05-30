-- Kill Aura для зомби - БЕЗ HUMANODI (УДАР ПО ЧАСТЯМ ТЕЛА)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

print("🧟 KILL AURA - РЕЖИМ УДАРОВ ПО ЧАСТЯМ ТЕЛА | Радиус 200")

while true do
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local myPos = rootPart.Position
            
            local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
            
            if zombiesFolder then
                for _, zombie in pairs(zombiesFolder:GetChildren()) do
                    -- Проверяем, что это модель
                    if zombie:IsA("Model") then
                        
                        -- Берём HumanoidRootPart зомби
                        local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
                        
                        if zombieRoot then
                            local distance = (zombieRoot.Position - myPos).Magnitude
                            
                            if distance <= 200 then
                                print("💥 БЬЮ ПО " .. zombie.Name .. "! Расстояние: " .. math.floor(distance))
                                
                                -- 1. Наносим урон через TouchInterest (как рукопашная)
                                local touch = Instance.new("TouchInterest")
                                touch.Parent = rootPart
                                wait(0.01)
                                touch:Destroy()
                                
                                -- 2. Пытаемся вызвать кастомную функцию урона
                                if zombie:FindFirstChild("TakeDamage") then
                                    zombie:TakeDamage(1000)
                                end
                                
                                -- 3. Пытаемся изменить атрибут здоровья (если есть)
                                if zombie:GetAttribute("Health") then
                                    local currentHealth = zombie:GetAttribute("Health")
                                    zombie:SetAttribute("Health", currentHealth - 1000)
                                    print("⚔️ Атрибут Health изменён: " .. (currentHealth - 1000))
                                end
                                
                                -- 4. Пытаемся ударить по всем частям тела
                                for _, part in pairs(zombie:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        -- Создаём эффект удара
                                        local touch2 = Instance.new("TouchInterest")
                                        touch2.Parent = rootPart
                                        wait(0.005)
                                        touch2:Destroy()
                                    end
                                end
                            end
                        else
                            print("⚠️ У " .. zombie.Name .. " нет HumanoidRootPart")
                        end
                    end
                end
            else
                print("⚠️ Папка Zombies_Local не найдена!")
            end
        end
    end
    task.wait(0.02)
end
