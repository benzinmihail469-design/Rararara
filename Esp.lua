-- Мобильный скрипт для Kick a Lucky Block (Kavo UI)
local KavoUiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = KavoUiLib.CreateLib("Lucky Block Hub (Mobile)", "Midnight")

-- ВКЛАДКИ
local MainTab = Window:NewTab("Автофарм")
local PlayerTab = Window:NewTab("Игрок")

local MainSection = MainTab:NewSection("Основные функции")
local PlayerSection = PlayerTab:NewSection("Характеристики")

-- ПЕРЕМЕННЫЕ
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

_G.AutoKick = false
_G.AutoCollect = false
_G.AntiTsunami = false

-- Функция для поиска своей базы
local function getMyPlot()
    for _, plot in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == Player then
            return plot
        end
    end
    return nil
end

-- 1. АВТО-ПИНОК
MainSection:NewToggle("Авто-Пинок Блока", "Сам бьет блок на платформе", function(state)
    _G.AutoKick = state
    task.spawn(function()
        while _G.AutoKick do
            task.wait(0.1)
            pcall(function()
                -- Отправка сигнала удара на сервер с максимальной силой
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Kick") or game:GetService("ReplicatedStorage"):FindFirstChild("KickBlock")
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer(true, 100)
                end
            end)
        end
    end)
end)

-- 2. АВТО-СБОР ДЕНЕГ И БРЕЙНИРОТОВ
MainSection:NewToggle("Авто-Сбор (Магнит/Плита)", "Собирает лут и относит на базу", function(state)
    _G.AutoCollect = state
    task.spawn(function()
        while _G.AutoCollect do
            task.wait(0.5)
            pcall(function()
                local plot = getMyPlot()
                -- Тянем выпавший лут к себе (Магнит)
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Tool") or obj.Name == "Brainrot" or obj:SetAttribute("Type") == "Loot" then
                        if obj:FindFirstChild("Handle") then
                            obj.Handle.CFrame = Character.HumanoidRootPart.CFrame
                        elseif obj:IsA("BasePart") then
                            obj.CFrame = Character.HumanoidRootPart.CFrame
                        end
                    end
                end
                -- Наступаем на плиту сбора, если мы на базе
                if plot and plot:FindFirstChild("CollectPad") then
                    firetouchinterest(Character.HumanoidRootPart, plot.CollectPad, 0)
                    task.wait(0.05)
                    firetouchinterest(Character.HumanoidRootPart, plot.CollectPad, 1)
                end
            end)
        end
    end)
end)

-- 3. АНТИ-ЦУНАМИ (ТЕЛЕПОРТ НА БАЗУ)
MainSection:NewToggle("Анти-Цунами", "Спасает от волны сразу на спавн базы", function(state)
    _G.AntiTsunami = state
    task.spawn(function()
        while _G.AntiTsunami do
            task.wait(0.3)
            pcall(function()
                -- Проверяем, идет ли цунами (по названию или предупреждению на экране)
                local tsunamiZone = workspace:FindFirstChild("Tsunami") or workspace:FindFirstChild("Water")
                if tsunamiZone or Player.PlayerGui:FindFirstChild("TsunamiGui") then
                    local plot = getMyPlot()
                    if plot and plot:FindFirstChild("SpawnPoint") then
                        Character.HumanoidRootPart.CFrame = plot.SpawnPoint.CFrame + Vector3.new(0, 3, 0)
                        task.wait(2) -- Задержка, чтобы не спамило ТП
                    end
                end
            end)
        end
    end)
end)

-- ХАК НА СКОРОСТЬ
PlayerSection:NewSlider("Скорость бега", "Меняет WalkSpeed", 150, 16, function(s)
    pcall(function()
        Character:WaitForChild("Humanoid").WalkSpeed = s
    end)
end)

-- ХАК НА ПРЫЖОК
PlayerSection:NewSlider("Высота прыжка", "Меняет JumpPower", 200, 50, function(s)
    pcall(function()
        local hum = Character:WaitForChild("Humanoid")
        hum.UseJumpPower = true
        hum.JumpPower = s
    end)
end)

-- Корректный сброс при смерти на телефоне
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
end)
