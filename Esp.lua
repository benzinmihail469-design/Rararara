local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Настройки
local FOLDER_NAME = "Zombes_Local"  -- Название папки
local RADIUS = 200                   -- Радиус атаки
local DAMAGE = 1000                  -- Урон

-- Функция поиска папки с зомби
local function findZombieFolder()
    -- Ищем папку в Workspace
    local folder = Workspace:FindFirstChild(FOLDER_NAME)
    
    if folder then
        print("✅ Папка найдена: " .. folder.Name)
        return folder
    else
        print("❌ Папка " .. FOLDER_NAME .. " не найдена в Workspace!")
        return nil
    end
end

-- Функция получения всех зомби из папки
local function getAllZombies()
    local zombieFolder = findZombieFolder()
    if not zombieFolder then return {} end
    
    local zombies = {}
    
    -- Проходим по всем детям папки
    for _, child in pairs(zombieFolder:GetChildren()) do
        -- Проверяем, является ли объект моделью (имеет Humanoid)
        local humanoid = child:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            table.insert(zombies, child)
        end
    end
    
    return zombies
end

-- Функция нанесения урона по зомби в радиусе
local function damageZombiesInRadius(damage, radius)
    local character = LocalPlayer.Character
    if not character then
        print("❌ Персонаж не найден!")
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        print("❌ HumanoidRootPart не найден!")
        return
    end
    
    local playerPosition = humanoidRootPart.Position
    local zombies = getAllZombies()
    local zombiesHit = 0
    
    for _, zombie in pairs(zombies) do
        -- Ищем часть тела зомби для расчёта расстояния
        local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
        if not zombieRoot then
            zombieRoot = zombie:FindFirstChild("Head")
        end
        
        if zombieRoot then
            local distance = (zombieRoot.Position - playerPosition).Magnitude
            
            if distance <= radius then
                local humanoid = zombie:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.Health = humanoid.Health - damage
                    zombiesHit = zombiesHit + 1
                    print("⚔️ Урон " .. damage .. " по зомби! | Осталось здоровья: " .. humanoid.Health)
                end
            end
        end
    end
    
    if zombiesHit > 0 then
        print("🔥 Уничтожено зомби в радиусе " .. radius .. ": " .. zombiesHit)
    end
    
    return zombiesHit
end

-- Основной цикл (проверяет каждые 0.5 секунды)
local function startAutoKill()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("⚔️ АВТОУБИЙСТВО ЗОМБИ АКТИВИРОВАНО!")
    print("📁 Папка: " .. FOLDER_NAME)
    print("📡 Радиус: " .. RADIUS)
    print("💥 Урон: " .. DAMAGE)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    while true do
        -- Ждём появления персонажа
        if LocalPlayer.Character then
            damageZombiesInRadius(DAMAGE, RADIUS)
        end
        task.wait(0.5) -- Проверяем каждые 0.5 секунды
    end
end

-- Запускаем
startAutoKill()
