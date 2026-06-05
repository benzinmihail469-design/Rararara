-- НАСТРОЙКА ИНТЕРФЕЙСА (ORION ДЛЯ ТЕЛЕФОНОВ)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Kick a Lucky Block (MOBILE)", HidePremium = false, SaveConfig = false, IntroText = "Загрузка мобильного фармера..."})

-- Переменные
local Player = game.Players.LocalPlayer
local VirtualInputService = game:GetService("VirtualInputService")
local RunService = game:GetService("RunService")

_G.AutoKick = false
_G.Magnet = false
_G.AutoCollect = false

-- Находим плот (базу) игрока
local function getMyPlot()
    for _, plot in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == Player then
            return plot
        end
    end
    return nil
end

-- ВКЛАДКА ФАРМА
local FarmTab = Window:MakeTab({Name = "Автофарм", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- 1. АВТО-ПИНОК (Симуляция тапов)
FarmTab:AddToggle({
    Name = "Авто-Пинок (Кликер)",
    Default = false,
    Callback = function(Value)
        _G.AutoKick = Value
        task.spawn(function()
            while _G.AutoKick do
                task.wait(0.01) -- Максимально быстрый спам клика
                pcall(function()
                    -- Эмуляция нажатия на экран для мобильных устройств
                    VirtualInputService:ClickButton1(Vector2.new(0, 0))
                end)
            end
        end)
    end    
})

-- 2. МАГНИТ ДЛЯ ЛУТА (Притягивает все блоки к тебе)
FarmTab:AddToggle({
    Name = "Магнит Блоков / Лута",
    Default = false,
    Callback = function(Value)
        _G.Magnet = Value
        task.spawn(function()
            while _G.Magnet do
                task.wait(0.2)
                pcall(function()
                    local char = Player.Character or Player.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    
                    -- Собираем все брейнироты и лакиблоки, которые выпали на карте
                    for _, obj in pairs(workspace:GetChildren()) do
                        if obj.Name == "Brainrot" or obj:FindFirstChild("Handle") or obj:IsA("Tool") then
                            if obj:IsA("BasePart") then
                                obj.CFrame = hrp.CFrame
                            elseif obj:FindFirstChild("Handle") then
                                obj.Handle.CFrame = hrp.CFrame
                            end
                        end
                    end
                end)
            end
        end)
    end    
})

-- 3. АВТО-СДАЧА НА БАЗУ (Телепорт денег)
FarmTab:AddToggle({
    Name = "Авто-Сбор денег на базе",
    Default = false,
    Callback = function(Value)
        _G.AutoCollect = Value
        task.spawn(function()
            while _G.AutoCollect do
                task.wait(0.5)
                pcall(function()
                    local char = Player.Character or Player.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    local plot = getMyPlot()
                    
                    -- Если нашли плиту "CollectPad" на нашей базе — наступаем на нее удаленно
                    if plot and plot:FindFirstChild("CollectPad") then
                        firetouchinterest(hrp, plot.CollectPad, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, plot.CollectPad, 1)
                    end
                end)
            end
        end)
    end    
})

-- ВКЛАДКА НАСТРОЕК ИГРОКА
local PlayerTab = Window:MakeTab({Name = "Игрок", Icon = "rbxassetid://4483345998", PremiumOnly = false})

PlayerTab:AddSlider({
    Name = "Скорость бега",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        pcall(function()
            Player.Character:WaitForChild("Humanoid").WalkSpeed = Value
        end)
    end    
})

PlayerTab:AddSlider({
    Name = "Высота прыжка",
    Min = 50,
    Max = 250,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Jump",
    Callback = function(Value)
        pcall(function()
            local hum = Player.Character:WaitForChild("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end)
    end    
})

OrionLib:Init()
