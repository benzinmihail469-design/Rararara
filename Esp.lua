-- Speed 35 + Обход античита (Bite By Night)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Обход античита
pcall(function()
    -- Удаляем античит-скрипты
    for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") then v:Destroy() end
    end
    
    -- Подмена WalkSpeed при проверке
    local old = hookmetamethod(game, "__index", function(self, k)
        if k == "WalkSpeed" then return 16 end
        return old(self, k)
    end)
end)

-- Обычный цикл установки скорости 35
RunService.Heartbeat:Connect(function()
    pcall(function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 35
            end
        end
    end)
end)

-- При новом персонаже
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
end)

print("Speed 35 activated!")
