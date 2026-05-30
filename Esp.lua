-- Kill Aura для зомби - ТОЛЬКО УРОН (С ЛОГАМИ)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

print("🧟 KILL AURA (ТОЛЬКО ZOMBIES_LOCAL) АКТИВИРОВАНА! Урон 1000, Радиус 200")

-- Счётчик для логов
local tickCount = 0

while true do
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local myPos = rootPart.Position
            
            -- Получаем папку с зомби
            local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
            
            if zombiesFolder then
                -- Логируем раз в 100 тиков (примерно раз в 0.5 секунды)
                tickCount = tickCount + 1
                if tickCount % 100 == 0 then
                    local zombieCount = #zombiesFolder:GetChildren()
                    print("🔍 Поиск зомби... Найдено моделек в Zombies_Local: " .. zombieCount)
                    
                    -- Выводим имена всех моделек в папке
                    for _, child in pairs(zombiesFolder:GetChildren()) do
                        print("   - Моделька: " .. child.Name)
                    end
                end
                
                -- Перебираем всех детей в папке Zombies_Local
                for _, zombie in pairs(zombiesFolder:GetChildren()) do
                    print("📌 Проверяю: " .. zombie.Name)
                    
                    -- Проверяем, что это именно зомби (по имени или наличию Humanoid)
                    if zombie.Name == "Zombie" or zombie:FindFirstChild("Humanoid") then
                        print("   ✅ Это зомби! (Имя: " .. zombie.Name .. ")")
                        
                        local humanoid = zombie:FindFirstChild("Humanoid")
                        
                        if humanoid then
                            print("   ❤️ Humanoid найден, HP: " .. humanoid.Health)
                            
                            if humanoid.Health > 0 then
                                local objPart = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
                                
                                if objPart then
                                    local distance = (objPart.Position - myPos).Magnitude
                                    print("   📏 Расстояние до зомби: " .. math.floor(distance))
                                    
                                    if distance <= 200 then
                                        -- Наносим урон 1000
                                        humanoid:TakeDamage(1000)
                                        print("💥 Урон 1000 по " .. zombie.Name .. "! Осталось HP: " .. humanoid.Health)
                                    else
                                        print("   ⭕ Слишком далеко (>200)")
                                    end
                                else
                                    print("   ⚠️ Нет HumanoidRootPart или Head!")
                                end
                            else
                                print("   💀 Зомби уже мёртв (HP = " .. humanoid.Health .. ")")
                            end
                        else
                            print("   ❌ Нет Humanoid у " .. zombie.Name)
                        end
                    else
                        print("   ❌ Не зомби (имя не 'Zombie' и нет Humanoid) - " .. zombie.Name)
                    end
                end
            else
                print("⚠️ Папка 'Zombies_Local' не найдена в Workspace!")
                print("📁 Доступные папки в Workspace:")
                for _, child in pairs(Workspace:GetChildren()) do
                    print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
    end
    task.wait(0.005)
end
