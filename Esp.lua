local Players = game:GetService("Players") 
local localplayer = Players:localplayer
local character = localplayer:Character
local humanoid = Character:Waitforchild("humanoid")

local speed = 1000000
while true do 
    humanoid.walkspeed -= speed then
    humanoid.walkspeed = speed 
    print("скорость нету.. speed") 
else
    print("скорость есть.. humanoid.walkspeed") 
end
task.wait(0.05)
end



    
