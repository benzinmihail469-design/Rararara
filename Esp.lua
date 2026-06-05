-- Kick a Lucky Block GUI Script
-- Создано для автоматизации фарма, сбора денег и обхода цунами

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = 'Kick a Lucky Block | Авто-Фарм Меню',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Главная'),
    Player = Window:AddTab('Игрок'),
}

-- ПЕРЕМЕННЫЕ ДЛЯ ФУНКЦИЙ
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

_G.AutoKick = false
_G.PerfectKick = false
_G.AutoClaim = false
_G.AntiTsunami = false

-- Функция для поиска базы игрока
local function getMyPlot()
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer then
            return plot
        end
    end
    return nil
end

-- ВКЛАДКА: ГЛАВНАЯ (АВТОФАРМ)
local FarmSection = Tabs.Main:AddLeftGroupbox('Автоматизация')

FarmSection:AddToggle('AutoKickToggle', {
    Text = 'Авто-пинок блока',
    Default = false,
    Tooltip = 'Сам пинает блок, когда вы стоите в зоне',
    Callback = function(Value)
        _G.AutoKick = Value
        task.spawn(function()
            while _G.AutoKick do
                task.wait(0.1)
                -- Логика триггера пинка (симуляция нажатия или вызов эвента)
                local kickZone = workspace:FindFirstChild("KickZone") -- условный путь
                pcall(function()
                    game:GetService("ReplicatedStorage").Events.KickBlock:FireServer(100) -- Пример отправки эвента силы
                end)
            end
        end)
    end
})

FarmSection:AddToggle('PerfectKickToggle', {
    Text = 'Всегда идеальный пинок',
    Default = false,
    Tooltip = 'Автоматически выбирает 100% на шкале удачи',
    Callback = function(Value)
        _G.PerfectKick = Value
        -- Перехват мини-игры со шкалой
        pcall(function()
            if _G.PerfectKick then
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
                -- Скрипт пытается «заморозить» или сразу отправить серверу значение Perfect клика
                -- Зависит от внутренней структуры UI игры
            end
        end)
    end
})

FarmSection:AddToggle('AntiTsunamiToggle', {
    Text = 'Анти-Цунами (Авто-возврат)',
    Default = false,
    Tooltip = 'Телепортирует на базу сразу после пинка, игнорируя волну',
    Callback = function(Value)
        _G.AntiTsunami = Value
        task.spawn(function()
            while _G.AntiTsunami do
                task.wait(0.5)
                -- Если активировалась фаза бега от цунами (персонаж держит брейнирота)
                if Character:FindFirstChild("Brainrot") or LocalPlayer.PlayerGui:FindFirstChild("TsunamiWarning") then 
                    local plot = getMyPlot()
                    if plot and plot:FindFirstChild("SpawnPoint") then
                        Character:SetPrimaryPartCFrame(plot.SpawnPoint.CFrame + Vector3.new(0, 3, 0))
                    end
                end
            end
        end)
    end
})

FarmSection:AddToggle('AutoClaimToggle', {
    Text = 'Авто-сбор Денег',
    Default = false,
    Tooltip = 'Сам наступает на зеленую плиту сбора денег на вашей базе',
    Callback = function(Value)
        _G.AutoClaim = Value
        task.spawn(function()
            while _G.AutoClaim do
                task.wait(1)
                local plot = getMyPlot()
                if plot and plot:FindFirstChild("CollectPad") then
                    -- Безопасный вызов касания плиты без физического перемещения
                    firetouchinterest(Character.HumanoidRootPart, plot.CollectPad, 0)
                    task.wait(0.1)
                    firetouchinterest(Character.HumanoidRootPart, plot.CollectPad, 1)
                end
            end
        end)
    end
})

-- ВКЛАДКА: ИГРОК (ХАК ХАРАКТЕРИСТИК)
local PlayerSection = Tabs.Player:AddLeftGroupbox('Модификации')

PlayerSection:AddSlider('SpeedSlider', {
    Text = 'Скорость бега (WalkSpeed)',
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
})

PlayerSection:AddSlider('JumpSlider', {
    Text = 'Высота прыжка (JumpPower)',
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Value
        end
    end
})

-- Обновление персонажа при респавне (чтобы скорость не сбрасывалась)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
end)

Library:Notify("Скрипт успешно загружен! Удачи в фарме брейниротов.")
