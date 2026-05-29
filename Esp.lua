local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

function speed(a, b) 
    return a + b
end   
    

while true do 
    local result = speed(100, 100) 
    print (result) 
    task.wait (5) 
    
