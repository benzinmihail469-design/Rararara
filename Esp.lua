-- Скопируйте этот код и вставьте его в ваш эксплойт для Roblox

local Library = loadstring(game:HttpGet("https://githubusercontent.com"))()

local Window = Library.CreateLib("Kick a Lucky Block | Hub", "Sentinel")

local Tab = Window:NewTab("Автофарм")

Tab:NewToggle("Авто-сбор (Auto Claim)", "Автоматически собирает награды", function(state)
    getgenv().autoClaim = state
    while getgenv().autoClaim do
        -- Основной цикл сбора блоков и наград
        for _, v in pairs(game:GetService("Workspace").LuckyBlocks:GetDescendants()) do
            if v:IsA("ClickDetector") and getgenv().autoClaim then
                fireclickdetector(v)
            end
        end
        task.wait(0.5)
    end
end)

Tab:NewToggle("Идеальный удар (Perfect Kick)", "Автоматически бьет с максимальной силой", function(state)
    getgenv().perfectKick = state
    while getgenv().perfectKick do
        -- Логика идеального тайминга для шкалы удара
        local args = {
            [1] = "Perfect"
        }
        game:GetService("ReplicatedStorage").Remotes.KickBlock:FireServer(unpack(args))
        task.wait(0.1)
    end
end)

local MiscTab = Window:NewTab("Дополнительно")

MiscTab:NewToggle("Режим Бога (Godmode)", "Защита от урона", function(state)
    local player = game.Players.LocalPlayer
    if state then
        player.Character.Humanoid.MaxHealth = math.huge
        player.Character.Humanoid.Health = math.huge
    else
        player.Character.Humanoid.MaxHealth = 100
        player.Character.Humanoid.Health = 100
    end
end)
