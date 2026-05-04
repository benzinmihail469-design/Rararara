local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/Zentrix"))()
local V = "V.0.52"
local selectedTheme = "Dark Fantasy"

library:CreateWindow({
    Title = "Dark fantasy hub",
    Theme = selectedTheme,
    Icon = 0,
    Intro = false,
    IntroTitle = "BBN by Iliankytb",
    KeyPC = Enum.KeyCode.K,
    CustomSize = UDim2.new(0, 600, 0, 500),
    Data = {
        EnableSavingData = true,
        DisableNotifyingLoadedData = false,
        FolderName = "SaverBBN",
        FileName = "Iliankytb",
    },
    Discord = {
        Enabled = true,
        DiscordLink = "https://discord.gg/E2TqYRsRP4",
        RememberJoin = true,
        Duration = 10,
    },
    Notifications = {
        NoSound = false,
        CustomSound = false,
        CustomSoundId = "rbxassetid://106553517979212",
    },
    KeySystem = false,
    KeySettings = {
        Title = "Zentrix Library Testing Key System",
        Note = "the key is Zentrix",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Zentrix"},
        Url = "",
        AddGetKeyButton = false,
        AddDiscordButton = true,
        DiscordLink = "NoInviteLink",
        GetKeyLink = "NoKeyLink",
    },
}, function(window)
    local InfoTab = window:CreateTab("Info", 0)
    local MainTab = window:CreateTab("Main", 0)
    local PlayerTab = window:CreateTab("Player", 0)
    local EspTab = window:CreateTab("Esp", 0)
    local DiscordTab = window:CreateTab("Discord", 0)
    local SettingsTab = window:CreateTab("Settings", 0)
    local ParagraphInfoServer = InfoTab:AddParagraph({ Title = "", Content = "Loading", Name = "Paragraph1" })
    local MarketplaceService = game:GetService("MarketplaceService")
    local infoGameName = MarketplaceService:GetProductInfo(game.PlaceId)
    local ActiveNoCooldownPrompt, ActiveDistanceEsp, ActiveBigPrompt, DisableLimitRangerEsp = false, false, false, false
    local LimitRangerEsp = 100
    local ValueRunSpeed = 24
    local ActiveSpeedBoost = false
    local ValueWalkSpeed = 15
    local ActiveSpeedBoost2 = false
    local ActiveEspKillers = false
    local ActiveEspSurvivors = false
    local ActiveEspGen = false
    local AutoEscape = false
    local AutoGen = false
    local ActiveEspFuseBoxes = false
    local FighterAutoParry = false
    local ActiveEspBattery = false
    local AutoBarricade = false
    local AutoSafeSpot = false
    local HitboxExpender = false
    local ValueHE = 15
    local ActiveEspTraps = false
    local ActiveEspWireEyes = false
    local AutoShakeWireEyes = false
    local ActiveInfiniteStamina = false
    local CanShake = true
    local NoBlindness = false
    local CanGenerator = true
    local ShakeTime = 0.5
    local SizeBoxBarricade = 0.3
    local InvisibilityKiller = false
    local ActiveNoclip = false
    local ActivateFly = false
    local AutoFarm = false
    local CanGo = true
    local UserInputService = game:GetService("UserInputService")
    local ActivateJumping = false
    local JumpPowerValue = 50
    local State = "Idle"
    local TimeForGenerator = 1.25
    local AutoHighlightKillerCamera = false
    local AutoPhase = false

    local Version = InfoTab:AddText({
        Text = "Version:" .. V,
        Name = "VersionScript"
    })
    
    local Notif = window:Notify({
        Title = "Script Version",
        Message = V,
        Duration = 7.5,
        UseSound = true,
    })

    local IYMouse = game.Players.LocalPlayer:GetMouse()
    local FLYING = false
    local QEfly = true
    local iyflyspeed = 1
    local vehicleflyspeed = 1

    local function sFLY(vfly)
        repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        repeat wait() until IYMouse
        if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

        local T = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        local CONTROL = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
        local lCONTROL = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
        local SPEED = 0

        local function FLY()
            FLYING = true
            local BG = Instance.new('BodyGyro')
            local BV = Instance.new('BodyVelocity')
            BG.P = 9e4
            BG.Parent = T
            BV.Parent = T
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = T.CFrame
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            task.spawn(function()
                repeat wait()
                    if not vfly and game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                    end
                    if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                        SPEED = 50
                    elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                        SPEED = 0
                    end
                    if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                        BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                        lCONTROL = { F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R }
                    elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                        BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                    end
                    BG.CFrame = workspace.CurrentCamera.CoordinateFrame
                until not FLYING
                CONTROL = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
                lCONTROL = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
                SPEED = 0
                BG:Destroy()
                BV:Destroy()
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
                end
            end)
        end
        flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
            if KEY:lower() == 'w' then
                CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
            elseif KEY:lower() == 's' then
                CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
            elseif KEY:lower() == 'a' then
                CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
            elseif KEY:lower() == 'd' then
                CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
            elseif QEfly and KEY:lower() == 'e' then
                CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed) * 2
            elseif QEfly and KEY:lower() == 'q' then
                CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed) * 2
            end
            pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
        end)
        flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
            if KEY:lower() == 'w' then
                CONTROL.F = 0
            elseif KEY:lower() == 's' then
                CONTROL.B = 0
            elseif KEY:lower() == 'a' then
                CONTROL.L = 0
            elseif KEY:lower() == 'd' then
                CONTROL.R = 0
            elseif KEY:lower() == 'e' then
                CONTROL.Q = 0
            elseif KEY:lower() == 'q' then
                CONTROL.E = 0
            end
        end)
        FLY()
    end

    local function NOFLY()
        FLYING = false
        if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
        if game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
            game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
    end

    local velocityHandlerName = "BodyVelocity"
    local gyroHandlerName = "BodyGyro"
    local mfly1, mfly2

    local function UnMobileFly()
        pcall(function()
            FLYING = false
            local root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            root:FindFirstChild(velocityHandlerName):Destroy()
            root:FindFirstChild(gyroHandlerName):Destroy()
            game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
            mfly1:Disconnect()
            mfly2:Disconnect()
        end)
    end

    local function MobileFly()
        UnMobileFly()
        FLYING = true
        local root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera
        local v3none = Vector3.new()
        local v3zero = Vector3.new(0, 0, 0)
        local v3inf = Vector3.new(9e9, 9e9, 9e9)
        local controlModule = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = v3zero
        bv.Velocity = v3zero
        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 50
        mfly1 = game.Players.LocalPlayer.CharacterAdded:Connect(function()
            local bv = Instance.new("BodyVelocity")
            bv.Name = velocityHandlerName
            bv.Parent = root
            bv.MaxForce = v3zero
            bv.Velocity = v3zero
            local bg = Instance.new("BodyGyro")
            bg.Name = gyroHandlerName
            bg.Parent = root
            bg.MaxTorque = v3inf
            bg.P = 1000
            bg.D = 50
        end)
        mfly2 = game:GetService("RunService").RenderStepped:Connect(function()
            root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            camera = workspace.CurrentCamera
            if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                local VelocityHandler = root:FindFirstChild(velocityHandlerName)
                local GyroHandler = root:FindFirstChild(gyroHandlerName)
                VelocityHandler.MaxForce = v3inf
                GyroHandler.MaxTorque = v3inf
                humanoid.PlatformStand = true
                GyroHandler.CFrame = camera.CoordinateFrame
                VelocityHandler.Velocity = v3none
                local direction = controlModule:GetMoveVector()
                if direction.X > 0 then VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((iyflyspeed) * 50)) end
                if direction.X < 0 then VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((iyflyspeed) * 50)) end
                if direction.Z > 0 then VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((iyflyspeed) * 50)) end
                if direction.Z < 0 then VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((iyflyspeed) * 50)) end
            end
        end)
    end

    local function doShake(wireyesUI)
        task.spawn(function()
            local wireyesClient = wireyesUI:WaitForChild("WireyesClient")
            if wireyesClient then
                local remote = wireyesClient:WaitForChild("WireyesEvent")
                if remote then
                    CanShake = false
                    task.spawn(function() task.wait(ShakeTime) CanShake = true end)
                    pcall(function() remote:FireServer("Shaking") end)
                    task.wait(0.05)
                    pcall(function() remote:FireServer("TakeOff", workspace:GetServerTimeNow()) end)
                end
            end
        end)
    end

    local function getCheckParts(maskClient)
        local module = maskClient:FindFirstChild("CheckParts")
        if not module then return nil end
        local ok, result = pcall(require, module)
        if not ok or type(result) ~= "table" then return nil end
        return result
    end

    local function getPhaseables(checkParts)
        local other = workspace.MAPS and workspace.MAPS:FindFirstChild("GAME MAP") and workspace.MAPS["GAME MAP"]:FindFirstChild("Other")
        if not other then return nil end
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local nearest, nearestDist = nil, math.huge
        for _, part in next, other:GetDescendants() do
            if part:IsA("BasePart") then
                local lower = part.Name:lower()
                for _, v in next, checkParts do
                    if type(v) == "string" and lower:find(v:lower(), nil, true) then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist < nearestDist then nearestDist = dist nearest = part end
                        break
                    end
                end
            end
        end
        return nearest, nearestDist
    end

    local function getLungeFunc(maskClient)
        local activeLunge = maskClient:FindFirstChild("ActiveLunge")
        if not activeLunge then return nil end
        for _, conn in next, getconnections(activeLunge.OnClientEvent) do return conn.Function end
    end

    local function getServerInfo()
        local Players = game:GetService("Players")
        local playerCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        local isStudio = game:GetService("RunService"):IsStudio()
        return { PlaceId = game.PlaceId, JobId = game.JobId, IsStudio = isStudio, CurrentPlayers = playerCount, MaxPlayers = maxPlayers }
    end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local ESPs = {}
    local Camera = nil
    local LineESPEnabled = false
    local SavedCFrame = nil

    task.spawn(function() Camera = workspace.CurrentCamera end)
    local Teleported = false

    local function getNewestDot()
        local newest = nil
        for _, child in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
            if child.Name == "Dot" then newest = child end
        end
        return newest
    end

    local function CreateEsp(Char, Color, Text, Parent)
        if not Char or not Parent then return end
        if Char:FindFirstChild("ESP") and Char:FindFirstChildOfClass("Highlight") then return end
        local highlight = Char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = Char
        highlight.FillColor = Color
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false
        highlight.Parent = Char
        local billboard = Char:FindFirstChild("ESP") or Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Size = UDim2.new(10, 0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, -2, 0)
        billboard.Adornee = Parent
        billboard.Enabled = false
        billboard.Parent = Parent
        local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = Text
        label.TextColor3 = Color
        label.TextScaled = true
        label.Parent = billboard
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color
        line.Thickness = 1.5
        line.Transparency = 1
        table.insert(ESPs, { Char = Char, Highlight = highlight, Billboard = billboard, Label = label, Part = Parent, Line = line, Text = Text, Color = Color })
    end

    local LastAction = 0
    local Cooldown = 0.5
    local TweenService = game:GetService("TweenService")
    local SPEED = 30
    local CanPhase = true

    local function TweenTo(character, cf)
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if not root then return end
        local distance = (root.Position - cf.Position).Magnitude
        local time = distance / SPEED
        local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), { CFrame = cf })
        tween:Play()
        tween.Completed:Wait()
    end

    RunService.RenderStepped:Connect(function()
        task.spawn(function()
            local updatedInfo = getServerInfo()
            local updatedContent = string.format("🎮 Game: %s\n📌 PlaceId: %s\n🔑 JobId: %s\n🧪 IsStudio: %s\n👥 Players: %d/%d", infoGameName.Name, updatedInfo.PlaceId, updatedInfo.JobId, tostring(updatedInfo.IsStudio), updatedInfo.CurrentPlayers, updatedInfo.MaxPlayers)
            ParagraphInfoServer:Set({ Title = "Info", Content = updatedContent })
        end)
        task.spawn(function()
            if Camera then
                local cameraPosition = Camera.CFrame.Position
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                for _, esp in ipairs(ESPs) do
                    local char = esp.Char
                    local part = esp.Part
                    local highlight = esp.Highlight
                    local billboard = esp.Billboard
                    local label = esp.Label
                    local line = esp.Line
                    if not part or not highlight or not billboard or not label or not line then return end
                    if part and part.Parent and highlight and billboard then
                        local distance = (cameraPosition - part.Position).Magnitude
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        local withinRange = DisableLimitRangerEsp or distance <= LimitRangerEsp
                        highlight.Enabled = withinRange and onScreen
                        billboard.Enabled = withinRange and onScreen
                        if ActiveDistanceEsp then label.Text = esp.Text .. " (" .. math.floor(distance + 0.5) .. " m)" else label.Text = esp.Text end
                        if char:FindFirstChildOfClass("Humanoid") then label.Text = label.Text .. "|" .. math.floor(char:FindFirstChildOfClass("Humanoid").Health) .. "/" .. char:FindFirstChildOfClass("Humanoid").MaxHealth .. " HP" end
                        if LineESPEnabled then if onScreen and withinRange then line.Visible = true line.From = screenCenter line.To = Vector2.new(screenPos.X, screenPos.Y) else line.Visible = false end else line.Visible = false end
                    else if line then line.Visible = false end end
                end
            else task.spawn(function() if workspace:FindFirstChild("CurrentCamera") then Camera = workspace.CurrentCamera end end) end
        end)
        if game.Players.LocalPlayer.Character then
            if AutoBarricade then
                local dot = getNewestDot()
                if dot then
                    local container = dot:FindFirstChild("Container")
                    if container then
                        local frame = container:FindFirstChild("Frame")
                        local box = container:FindFirstChild("Box")
                        if frame and box then
                            local boxAbs = box.AbsolutePosition
                            local boxSize = box.AbsoluteSize
                            local conAbs = container.AbsolutePosition
                            frame.Position = UDim2.new(0, (boxAbs.X + boxSize.X * 0.5) - conAbs.X, 0, (boxAbs.Y + boxSize.Y * 0.5) - conAbs.Y)
                            box.Size = UDim2.new(SizeBoxBarricade, 0, SizeBoxBarricade, 0)
                        end
                    end
                end
            end
            if ActiveInfiniteStamina then
                local mx = game.Players.LocalPlayer.Character:GetAttribute("MaxStamina") or 100
                if (game.Players.LocalPlayer.Character:GetAttribute("Stamina") or mx) < mx then game.Players.LocalPlayer.Character:SetAttribute("Stamina", mx) end
            end
            if AutoShakeWireEyes and CanShake then
                local existing = game.Players.LocalPlayer.PlayerGui:FindFirstChild("WireyesUI")
                if existing then doShake(existing) end
            end
            if NoBlindness then
                if game:GetService("ReplicatedStorage").Modules.BlindnessModule:FindFirstChildOfClass("Atmosphere") then game:GetService("ReplicatedStorage").Modules.BlindnessModule:FindFirstChildOfClass("Atmosphere"):Destroy() end
            end
            if AutoFarm then
                task.spawn(function()
                    local Character = game.Players.LocalPlayer.Character
                    if tick() - LastAction >= Cooldown then
                        if Character and Character.PrimaryPart and Character.Parent == workspace.PLAYERS.ALIVE then
                            if CanGo then
                                if not LocalPlayer.PlayerGui:FindFirstChild("Gen") then
                                    if not Character:FindFirstChild("Battery") then
                                        for _, child in pairs(workspace.IGNORE:GetChildren()) do
                                            if child.Name == "Battery" and child:IsA("BasePart") then
                                                local attachment = child:FindFirstChild("Attachment")
                                                local prompt = attachment and attachment:FindFirstChildOfClass("ProximityPrompt")
                                                if prompt then
                                                    CanGo = false State = "Battery" LastAction = tick()
                                                    TweenTo(Character, child.CFrame)
                                                    task.wait(0.1)
                                                    fireproximityprompt(prompt)
                                                    task.spawn(function() task.wait(prompt.HoldDuration + 0.25) CanGo = true State = "Idle" end)
                                                    break
                                                end
                                            end
                                        end
                                    else
                                        if CanGo then
                                            local map = workspace.MAPS:FindFirstChild("GAME MAP")
                                            if map and not LocalPlayer.PlayerGui:FindFirstChild("Gen") then
                                                local fuseFolder = map:FindFirstChild("FuseBoxes")
                                                if fuseFolder then
                                                    for _, fuse in pairs(fuseFolder:GetChildren()) do
                                                        if fuse:IsA("Model") then
                                                            local root = fuse:FindFirstChild("HumanoidRootPart")
                                                            local pos = fuse:FindFirstChild("Position")
                                                            if root and pos then
                                                                local attachment = root:FindFirstChildOfClass("Attachment")
                                                                local prompt = attachment and attachment:FindFirstChildOfClass("ProximityPrompt")
                                                                if prompt and prompt.Enabled then
                                                                    CanGo = false State = "Fuse" LastAction = tick()
                                                                    TweenTo(Character, pos.CFrame + Vector3.new(0, 2.5, 0))
                                                                    task.wait(0.5)
                                                                    fireproximityprompt(prompt)
                                                                    task.spawn(function() task.wait(prompt.HoldDuration + 0.25) CanGo = true State = "Idle" end)
                                                                    break
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if CanGo and workspace.GAME.Tasks.Gens.Enabled.Value then
                                    local gens = workspace.MAPS["GAME MAP"]:FindFirstChild("Generators")
                                    if gens and not LocalPlayer.PlayerGui:FindFirstChild("Gen") then
                                        for _, gen in pairs(gens:GetChildren()) do
                                            if gen.Name == "Generator" and gen:GetAttribute("Progress") < 100 then
                                                local root = gen:FindFirstChild("RootPart")
                                                if root then
                                                    for _, atch in ipairs(root:GetChildren()) do
                                                        if atch:IsA("Attachment") then
                                                            local prompt = atch:FindFirstChildOfClass("ProximityPrompt")
                                                            if prompt and prompt.Enabled then
                                                                local point = gen:FindFirstChild(atch.Name)
                                                                if point then
                                                                    CanGo = false State = "Gen" LastAction = tick()
                                                                    TweenTo(Character, point.CFrame)
                                                                    task.wait(1)
                                                                    fireproximityprompt(prompt)
                                                                    task.spawn(function() task.wait(prompt.HoldDuration + 0.75) CanGo = true State = "Idle" end)
                                                                    break
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            if not CanGo then break end
                                        end
                                    end
                                end
                                if CanGo and workspace.GAME.CAN_ESCAPE.Value then
                                    local escapes = workspace.MAPS["GAME MAP"]:FindFirstChild("Escapes")
                                    if escapes then
                                        for _, part in pairs(escapes:GetChildren()) do
                                            if part:IsA("BasePart") and part:GetAttribute("Enabled") then
                                                CanGo = false State = "Escape" LastAction = tick()
                                                TweenTo(Character, part.CFrame)
                                                task.spawn(function() task.wait(1) CanGo = true State = "Idle" end)
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            if ActivateJumping then
                local Character = game:GetService("Players").LocalPlayer.Character
                if Character and Character:FindFirstChildOfClass("Humanoid") then
                    local HUMM = Character:FindFirstChildOfClass("Humanoid")
                    if HUMM then HUMM.UseJumpPower = ActivateJumping HUMM.JumpPower = JumpPowerValue end
                end
            end
            if AutoPhase and CanPhase then
                local maskClient = game.Players.LocalPlayer.Character:FindFirstChild("MaskClient")
                if maskClient then
                    local lungeFunc = getLungeFunc(maskClient)
                    local checkParts = getCheckParts(maskClient)
                    if lungeFunc and checkParts then
                        local nearest, nearestDist = getPhaseables(checkParts)
                        if nearest and nearestDist <= 10 then CanPhase = false lungeFunc() task.wait(0.3) CanPhase = true end
                    end
                end
            end
            if AutoSafeSpot and not AutoFarm then
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 35 then SavedCFrame = game.Players.LocalPlayer.Character.PrimaryPart.CFrame end
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health <= 35 then game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(0, 500, 0) end
            end
            if ActiveSpeedBoost then game.Players.LocalPlayer.Character:SetAttribute("RunSpeed", ValueRunSpeed) end
            if ActiveSpeedBoost2 then game.Players.LocalPlayer.Character:SetAttribute("WalkSpeed", ValueWalkSpeed) end
            if AutoEscape and not Teleported and workspace.GAME.CAN_ESCAPE.Value == true and not AutoFarm then
                if workspace.MAPS:FindFirstChild("GAME MAP") then
                    if game.Players.LocalPlayer.Character.Parent == workspace.PLAYERS.ALIVE then
                        for _, Part in pairs(workspace.MAPS:FindFirstChild("GAME MAP"):FindFirstChild("Escapes"):GetChildren()) do
                            if Part and Part:IsA("BasePart") and Part:GetAttribute("Enabled") and Part:FindFirstChildOfClass("Highlight") and Part:FindFirstChildOfClass("Highlight").Enabled then
                                if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    Teleported = true
                                    game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Anchored = true
                                    game.Players.LocalPlayer.Character.PrimaryPart.CFrame = Part.CFrame
                                    task.spawn(function() wait(0.15) game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Anchored = false end)
                                    wait(10)
                                    Teleported = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local TimeAutoHighlight = 0.1

    LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "Camera" and AutoHighlightKillerCamera then
            local main = child:WaitForChild("Main")
            if main then
                local locateRemote = main:WaitForChild("Locate")
                if locateRemote then
                    task.wait(TimeAutoHighlight)
                    local killerFolder = workspace:WaitForChild("PLAYERS"):WaitForChild("KILLER")
                    local killer = killerFolder:FindFirstChildOfClass("Model")
                    if killer then
                        local root = killer:FindFirstChild("HumanoidRootPart")
                        if root then locateRemote:FireServer(killer) end
                    end
                end
            end
        end
        if child.Name == "Gen" then
            if (AutoGen or AutoFarm) then
                task.wait(TimeForGenerator)
                if child and child:FindFirstChild("GeneratorMain") then
                    child.GeneratorMain.Event:FireServer({ Wires = true, Switches = true, Lever = true })
                end
            end
        end
    end)

    local CollectionService = game:GetService("CollectionService")
    local AntiConfusion = false

    CollectionService:GetInstanceAddedSignal("Confusion"):Connect(function(instance)
        if AntiConfusion then
            local character = LocalPlayer.Character
            if instance == character then CollectionService:RemoveTag(character, "Confusion") end
        end
    end)

    local function KeepEsp(Char, Parent)
        if not Char or not Char:FindFirstChildOfClass("Highlight") then return end
        if not Parent or not Parent:FindFirstChildOfClass("BillboardGui") then return end
        for i = #ESPs, 1, -1 do
            local esp = ESPs[i]
            if esp.Char == Char then
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Billboard then esp.Billboard:Destroy() end
                if esp.Line then esp.Line:Destroy() end
                table.remove(ESPs, i)
            end
        end
    end

    local function SetupCharacter(child, Map, Part)
        if not child:IsA("Model") then return end
        child.AncestryChanged:Connect(function(_, newParent)
            if not child:IsDescendantOf(Map) then KeepEsp(child, Part) end
        end)
    end

    -- ESP Survivors
    EspTab:AddToggle({
        Text = "Esp Survivors", Name = "EspSurvivorsToggle", Default = false, Flag = "EspSurvivors",
        Callback = function(Value)
            ActiveEspSurvivors = Value
            if ActiveEspSurvivors then
                for _, p in pairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                    if p:IsA("Model") and p.PrimaryPart and not p.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                        if p:FindFirstChildOfClass("Highlight") then p:FindFirstChildOfClass("Highlight"):Destroy() end
                        SetupCharacter(p, workspace.PLAYERS.ALIVE, p.PrimaryPart)
                        CreateEsp(p, Color3.fromRGB(0, 255, 0), p.Name .. " " .. p:GetAttribute("Character"), p.PrimaryPart)
                    end
                end
            else
                for _, p in pairs(workspace
