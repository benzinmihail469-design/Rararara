-- Kill Aura - ПОИСК СИСТЕМЫ ЗДОРОВЬЯ (БЕЗ ПОВРЕЖДЕНИЙ)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

print("🔍 РЕЖИМ ПОИСКА ЗДОРОВЬЯ ЗОМБИ | Ничего не ломает")

local scannedZombies = {}

-- Функция для безопасного сканирования (ТОЛЬКО ПРОСМОТР, БЕЗ ИЗМЕНЕНИЙ)
local function scanZombie(zombie)
    if scannedZombies[zombie] then return end
    scannedZombies[zombie] = true
    
    print("\n📋 ===== СКАНИРУЮ: " .. zombie.Name .. " =====")
    
    -- Смотрим всех потомков
    for _, child in pairs(zombie:GetDescendants()) do
        -- Ищем значения с цифрами (здоровье обычно число)
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            if child.Name:lower():find("health") or child.Name:lower():find("hp") or child.Name:lower():find("life") then
                print("💚 НАЙДЕНО ЗДОРОВЬЕ: " .. child.Name .. " = " .. child.Value)
            end
        end
        
        -- Ищем атрибуты
        local attrs = zombie:GetAttributes()
        for name, value in pairs(attrs) do
            if name:lower():find("health") or name:lower():find("hp") then
                print("💚 АТРИБУТ ЗДОРОВЬЯ: " .. name .. " = " .. tostring(value))
            end
        end
        
        -- Ищем Humanoid
        if child:IsA("Humanoid") then
            print("💚 HUMANODI НАЙДЕН: Health = " .. child.Health)
        end
        
        -- Ищем скрипты управления здоровьем
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
            if child.Name:lower():find("health") or child.Name:lower():find("damage") or child.Name:lower():find("zombie") then
                print("📜 СКРИПТ ЗДОРОВЬЯ: " .. child.Name)
            end
        end
        
        -- Ищем Remote события для урона
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            if child.Name:lower():find("damage") or child.Name:lower():find("hit") then
                print("📡 REMOTE ДЛЯ УРОНА: " .. child.Name)
            end
        end
    end
    
    print("===== КОНЕЦ СКАНИРОВАНИЯ =====\n")
end

-- Главный цикл (ТОЛЬКО СКАНИРОВАНИЕ, БЕЗ УРОНА)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local myPos = rootPart.Position
        
        local zombiesFolder = Workspace:FindFirstChild("Zombies_Local")
        if not zombiesFolder then return end
        
        for _, zombie in pairs(zombiesFolder:GetChildren()) do
            if zombie:IsA("Model") then
                local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
                if zombieRoot then
                    local distance = (zombieRoot.Position - myPos).Magnitude
                    
                    if distance <= 200 and not scannedZombies[zombie] then
                        scanZombie(zombie) -- Только сканируем, НЕ наносим урон
                    end
                end
            end
        end
    end)
end)

print("✅ СКРИПТ СКАНИРУЕТ ЗОМБИ | Смотри консоль")
print("⏳ Подойди к зомби и он покажет где хранится здоровье")
