-- Проверяем, загружена ли игра, чтобы не было сбоев
if not game:IsLoaded() then game.Loaded:Wait() end

-- Подключаем визуальную библиотеку (стиль Hoshi Hub / Modern Dark)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Создаём главное окно
local Window = OrionLib:MakeWindow({
    Name = "🌌 Hoshi Hub | Murder Mystery 2", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "HoshiMM2",
    IntroText = "Loading Hoshi Hub..."
})

-- Переменные для функций
local AutoFarmCoins = false
local KillAura = false

-- ================= ТАБЫ (ВКЛАДКИ) =================
local MainTab = Window:MakeTab({ Name = "Главная", Icon = "rbxassetid://4483345998" })
local EspTab = Window:MakeTab({ Name = "ESP (Подсветка)", Icon = "rbxassetid://4483345998" })
local MiscTab = Window:MakeTab({ Name = "Разное", Icon = "rbxassetid://4483345998" })

-- ================= ФУНКЦИИ: ГЛАВНАЯ =================
MainTab:AddSection({ Name = "Автоматизация" })

MainTab:AddToggle({
    Name = "Авто-фарм монет (Телепорт)",
    Default = false,
    Callback = function(Value)
        AutoFarmCoins = Value
        spawn(function()
            while AutoFarmCoins do
                task.wait(0.1)
                -- Логика сбора монет (ищет контейнеры с монетами на карте)
                local Container = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("CoinContainer")
                if Container then
                    for _, coin in pairs(Container:GetChildren()) do
                        if AutoFarmCoins and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            if coin:IsA("BasePart") or coin:FindFirstChild("TouchInterest") then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                                task.wait(0.3) -- Задержка, чтобы античит не кикнул сразу
                            end
                        end
                    end
                end
            end
        end)
    end    
})

-- ================= ФУНКЦИИ: ESP =================
EspTab:AddSection({ Name = "Видеть сквозь стены" })

-- Простенький, но рабочий трекер ролей
local function CreateESP(player)
    if player == game.Players.LocalPlayer then return end
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if not char:FindFirstChild("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "MM2_ESP"
            highlight.Parent = char
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            
            -- Проверка роли
            if player.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Убийца (Красный)
            elseif player.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
                highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Шериф (Синий)
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Мирный (Зелёный)
            end
        end
    end)
end

EspTab:AddToggle({
    Name = "Включить ESP на роли",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, p in pairs(game.Players:GetPlayers()) do
                CreateESP(p)
            end
            game.Players.PlayerAdded:Connect(CreateESP)
        else
            -- Удаляем ESP при выключении
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("MM2_ESP") then
                    p.Character.MM2_ESP:Destroy()
                end
            end
        end
    end
})

-- ================= ФУНКЦИИ: РАЗНОЕ =================
MiscTab:AddSection({ Name = "Характеристики персонажа" })

MiscTab:AddSlider({
    Name = "Скорость бега (WalkSpeed)",
    Min = 16,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(140, 0, 255),
    Increment = 1,
    ValueName = "скорость",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

MiscTab:AddButton({
    Name = "Режим Бога (Godmode)",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
            OrionLib:MakeNotification({
                Name = "Hoshi Hub",
                Content = "Режим бога активирован! (Работает до первой перезагрузки)",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

-- Инициализация интерфейса
OrionLib:Init()
