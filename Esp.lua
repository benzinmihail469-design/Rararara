local Players = game:GetServirs("Players") 
local localplayer = players:localplayer
local character = localplayer:character
local humanoid = character:waitforchild("humanoid")

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



    
