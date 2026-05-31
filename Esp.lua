local Players = game:GetService("Players")
local localplayer = Players.LocalPlayer
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local speed = 1000000

while true do
    if humanoid.WalkSpeed ~= speed then
        humanoid.WalkSpeed = speed
        print("Скорость установлена на " .. speed)
    else
        print("Скорость уже " .. humanoid.WalkSpeed)
    end
    task.wait(0.05)
end
