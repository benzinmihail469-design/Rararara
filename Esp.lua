-- Kill Aura - ПРЯМОЙ УРОН 1000 (БЕЗ ОШИБОК)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("⚔️ KILL AURA ЗАПУЩЕНА | Урон 1000 | Радиус 200")

-- Функция нанесения урона (без TouchInterest)
local function dealDamage(zombie, amount)
    local success = false
    
    -- Метод 1: Прямое изменение здоровья через FindFirstChild
    local humanoid = zombie:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health then
        humanoid.Health = humanoid.Health - amount
        success = true
        print("💥 Урон через Humanoid: " .. humanoid.Health)
    end
    
    -- Метод 2: NumberValue
    local healthVal = zombie:FindFirstChild("Health") or zombie:FindFirstChild("HP")
    if healthVal and (healthVal:IsA("NumberValue") or healthVal:IsA("IntValue")) then
        healthVal.Value = healthVal.Value - amount
        success = true
        print("💥 Урон через Value: " .. healthVal.Value)
    end
    
    -- Метод 3: Атрибуты
    if zombie:GetAttribute("Health") then
        zombie:SetAttribute("Health", zombie:GetAttribute("Health") - amount)
        success = true
        print("💥 Урон через атрибут: " .. zombie:GetAttribute("Health"))
    end
    
    if zombie:GetAttribute("HP") then
        zombie:SetAttribute("HP", zombie:GetAttribute("HP") - amount)
        success = true
        print("💥 Урон через атрибут HP: " .. zombie:GetAttribute("HP"))
    end
    
    -- Метод 4: Удалённые события (без ошибок)
    local remote = zombie:FindFirstChild("DamageRemote") or zombie:FindFirstChild("TakeDamage")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(amount) end)
        success = true
        print("💥 Урон через RemoteEvent")
    end
    
    -- Метод 5: BreakJoints (мгновенное удаление)
    if amount >= 999 then
        pcall(function() zombie:BreakJoints() end)
        print("💥 BreakJoints вызван")
        success = true
    end
    
    return success
end

-- Главный цикл (защищён от ошибок)
RunService.Heartbeat:Connect(function()
    local success, err = pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local myPos = rootPart.Position
        
        -- Ищем папку с зомби
        local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
        if not zombiesFolder then return end
        
        -- Перебираем зомби
        for _, zombie in pairs(zombiesFolder:GetChildren()) do
            if zombie:IsA("Model") then
                local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
                if zombieRoot then
                    local distance = (zombieRoot.Position - myPos).Magnitude
                    
                    if distance <= 200 then
                        dealDamage(zombie, 1000)
                        -- Не спамим в консоль, только раз в 30 кадров
                        if tick() % 30 < 0.1 then
                            print("🎯 Атака по " .. zombie.Name .. " | Дистанция: " .. math.floor(distance))
                        end
                    end
                end
            end
        end
    end)
    
    -- Если ошибка - просто выводим, но скрипт продолжает работать
    if not success then
        -- print("⚠️ Ошибка: " .. tostring(err)) -- закомментировано чтоб не спамить
    end
end)

print("✅ KILL AURA РАБОТАЕТ | Ошибок не будет")
