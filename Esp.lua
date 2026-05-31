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

-- Этот способ даёт более плавное управление
local flying = false
local flySpeed = 50
local bodyPos, bodyGyro

local function enableFly()
    local char = game.Players.LocalPlayer.Character
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    
    humanoid.PlatformStand = true
    
    bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyPos.P = 2000
    bodyPos.D = 500
    bodyPos.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    bodyGyro.P = 2000
    bodyGyro.D = 500
    bodyGyro.Parent = root
    
    local runConn
    runConn = RunService.RenderStepped:Connect(function()
        if not flying then 
            runConn:Disconnect()
            return 
        end
        
        local camera = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end
        
        local newPos = root.Position + (camera.CFrame.LookVector * moveDir.Z + 
                                        camera.CFrame.RightVector * moveDir.X + 
                                        camera.CFrame.UpVector * moveDir.Y) * flySpeed
        
        bodyPos.Position = newPos
        bodyGyro.CFrame = camera.CFrame
    end)
end
