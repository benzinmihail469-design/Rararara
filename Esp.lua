-- [[ Kick A Lucky Block: Auto Perfect + Smooth Tween Magnet ]] --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

getgenv().AutoFarm = true
getgenv().Magnet = true

-- 1. АВТО-УДАР (Perfect)
task.spawn(function()
    while getgenv().AutoFarm do
        task.wait(0.1)
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("KickEvent") or 
                       game:GetService("ReplicatedStorage"):FindFirstChild("HitRemote")
        if remote then
            remote:FireServer("Kick", "Perfect") -- Попытка идеального удара
        end
    end
end)

-- 2. ПЛАВНЫЙ МАГНИТ (Скорость 150)
task.spawn(function()
    while getgenv().Magnet do
        task.wait(0.2) -- Интервал сканирования предметов
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            
            for _, obj in ipairs(Workspace:GetChildren()) do
                -- Условие: ищем предмет (замени "Brainrot" на точное имя из игры, если другое)
                if obj:IsA("BasePart") and (obj.Name:lower():find("brainrot") or obj.Name:lower():find("drop")) then
                    
                    -- Вычисляем время пути: Distance / Speed
                    local distance = (hrp.Position - obj.Position).Magnitude
                    local speed = 150
                    local timeToTravel = distance / speed
                    
                    -- Создаем плавную анимацию (Tween)
                    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(obj, tweenInfo, {CFrame = hrp.CFrame})
                    
                    tween:Play()
                end
            end
        end
    end
end)

print("[Script]: Плавный магнит (150 speed) и Perfect Kick активированы!")
