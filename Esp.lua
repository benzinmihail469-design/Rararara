-- Kill Aura - ПРЯМОЙ УРОН (без оружия)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

print("⚔️ KILL AURA - ПРЯМОЙ УРОН 1000 | Радиус 200")

-- Функция поиска скриптов урона
local function damageZombie(zombie, amount)
    local damaged = false
    
    -- 1. Пробуем найти NumberValue с здоровьем
    local healthValue = zombie:FindFirstChild("Health") or zombie:FindFirstChild("HP")
    if healthValue and healthValue:IsA("NumberValue") then
        healthValue.Value = healthValue.Value - amount
        print("💚 Урон через NumberValue: " .. healthValue.Value)
        damaged = true
    end
    
    -- 2. Пробуем найти IntValue
    local intHealth = zombie:FindFirstChild("Health") or zombie:FindFirstChild("HP")
    if intHealth and intHealth:IsA("IntValue") then
        intHealth.Value = intHealth.Value - amount
        print("💚 Урон через IntValue: " .. intHealth.Value)
        damaged = true
    end
    
    -- 3. Пробуем атрибуты
    if zombie:GetAttribute("Health") then
        local current = zombie:GetAttribute("Health")
        zombie:SetAttribute("Health", current - amount)
        print("💚 Урон через атрибут: " .. (current - amount))
        damaged = true
    end
    
    if zombie:GetAttribute("HP") then
        local current = zombie:GetAttribute("HP")
        zombie:SetAttribute("HP", current - amount)
        print("💚 Урон через атрибут HP: " .. (current - amount))
        damaged = true
    end
    
    -- 4. Пробуем вызвать удалённые события
    local remote = zombie:FindFirstChild("TakeDamage") or zombie:FindFirstChild("Damage")
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(amount)
        print("💚 Урон через RemoteEvent")
        damaged = true
    end
    
    -- 5. Пробуем ударить по частям тела (для скриптов на OnTouch)
    for _, part in pairs(zombie:GetChildren()) do
        if part:IsA("BasePart") then
            -- Создаём эффект удара (через Velocity для триггера)
            local character = LocalPlayer.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Быстро двигаем часть игрока к зомби и обратно (триггерит OnTouch)
                    local oldPos = root.Position
                    root.CFrame = part.CFrame
                    task.wait(0.01)
                    root.CFrame = CFrame.new(oldPos)
                    print("💚 Физический удар по " .. part.Name)
                    damaged = true
                end
            end
        end
    end
    
    return damaged
end

-- Выводим структуру зомби для отладки
local function showZombieStructure(zombie)
    print("🔍 Структура " .. zombie.Name .. ":")
    for _, child in pairs(zombie:GetChildren()) do
        print("   - " .. child.Name .. " (" .. child.ClassName .. ")")
        
        -- Показываем атрибуты
        local attributes = zombie:GetAttributes()
        for attrName, attrValue in pairs(attributes) do
            print("      ⚙️ Атрибут [" .. attrName .. "] = " .. tostring(attrValue))
        end
    end
end

local shownStructures = {}

while true do
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local myPos = rootPart.Position
            
            local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
            
            if zombiesFolder then
                for _, zombie in pairs(zombiesFolder:GetChildren()) do
                    if zombie:IsA("Model") then
                        local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
                        
                        if zombieRoot then
                            local distance = (zombieRoot.Position - myPos).Magnitude
                            
                            if distance <= 200 then
                                -- Показываем структуру первого зомби (один раз)
                                if not shownStructures[zombie.Name] then
                                    showZombieStructure(zombie)
                                    shownStructures[zombie.Name] = true
                                end
                                
                                -- Наносим урон
                                local success = damageZombie(zombie, 1000)
                                
                                if success then
                                    print("✅ Урон нанесён по " .. zombie.Name .. " | Дистанция: " .. math.floor(distance))
                                else
                                    print("❌ Не удалось нанести урон " .. zombie.Name)
                                end
                            end
                        end
                    end
                end
            else
                print("⚠️ Папка Zombies_Local не найдена!")
                task.wait(2)
            end
        end
    end
    task.wait(0.1)
end
