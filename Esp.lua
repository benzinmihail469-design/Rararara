-- ============================================
-- BITE BY NIGHT v13.1 — Fixed ESP + Mobile Slider + Better Stamina + Auto Farm + Fly
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ==================== НАСТРОЙКИ ====================
local SpeedEnabled = true
local SpeedValue = 18
local MaxSpeed = 60

local StaminaEnabled = true
local NoClipEnabled = false
local FlyEnabled = false
local GodmodeEnabled = false
local AutoRepairEnabled = false

local ESP_Generators = true
local ESP_Killer = true
local ESP_Survivors = true
local ESP_Items = true

local espObjects = {}
local speedConnection = nil
local noclipConnection = nil
local staminaConnection = nil
local flyConnection = nil
local autoRepairConnection = nil
local firingConnection = nil
local lastFireTime = 0

local flyVelocity = 50

-- ========== GODMODE ==========
local function applyGodmode()
    if not GodmodeEnabled then return end
    task.spawn(function()
        while GodmodeEnabled and task.wait(0.3) do
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                end
            end)
        end
    end)
end

-- ========== INFINITE STAMINA (улучшено) ==========
local function applyInfiniteStamina()
    if staminaConnection then staminaConnection:Disconnect() end
    if not StaminaEnabled then return end

    staminaConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            -- Атрибуты
            for _, name in ipairs({"Stamina", "SprintStamina", "Energy", "StaminaValue", "RunStamina", "SprintEnergy", "Fatigue"}) do
                if hum:GetAttribute(name) ~= nil then
                    hum:SetAttribute(name, 100)
                end
            end

            -- Value объекты
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("FloatValue") then
                    local n = v.Name:lower()
                    if n:find("stamina") or n:find("energy") or n:find("sprint") or n:find("fatigue") then
                        v.Value = 100
                    end
                end
            end
        end)
    end)
end

-- ========== SPEED + BETTER MOVEMENT ==========
local function applySpeed()
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    
    if not SpeedEnabled then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
        return
    end

    speedConnection = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end

            hum.WalkSpeed = SpeedValue

            if hum.MoveDirection.Magnitude > 0 then
                local moveVec = hum.MoveDirection * SpeedValue * dt * 1.08
                root.CFrame += moveVec
                root.Velocity = Vector3.new(moveVec.X * 30, root.Velocity.Y, moveVec.Z * 30)
            end
        end)
    end)
end

-- ========== FLY ==========
local function applyFly()
    if flyConnection then flyConnection:Disconnect() end
    if not FlyEnabled then 
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(0,0,0) end
        end)
        return 
    end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)

    flyConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end

            local cam = Workspace.CurrentCamera
            local move = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

            bv.Parent = root
            bv.Velocity = move.Unit * flyVelocity
        end)
    end)
end

-- ========== NOCLIP ==========
local function applyNoClip()
    if noclipConnection then noclipConnection:Disconnect() end
    if NoClipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end)
    end
end

-- ========== AUTO REPAIR (улучшенный) ==========
local function applyAutoRepair()
    if autoRepairConnection then autoRepairConnection:Disconnect() end
    if firingConnection then firingConnection:Disconnect() end
    lastFireTime = 0

    if not AutoRepairEnabled then return end

    autoRepairConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local genGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Gen")
            if genGui and genGui:FindFirstChild("GeneratorMain") then
                if not firingConnection then
                    firingConnection = RunService.Heartbeat:Connect(function()
                        if not AutoRepairEnabled then return end
                        if tick() - lastFireTime < 0.08 then return end

                        pcall(function()
                            local args = {{Wires = true, Switches = true, Lever = true}}
                            genGui.GeneratorMain.Event:FireServer(unpack(args))
                        end)
                        lastFireTime = tick()
                    end)
                end
            else
                if firingConnection then
                    firingConnection:Disconnect()
                    firingConnection = nil
                end
            end
        end)
    end)
end

-- ========== ANTI-CHEAT KILLER ==========
local function killAntiCheatScripts(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local n = (obj.Name or ""):lower()
            if n:find("anti") or n:find("cheat") or n:find("detect") or n:find("bite") or 
               n:find("stamina") or n:find("ac_") or n:find("security") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- ========== ESP ==========
local function createESP(obj, color, text)
    if espObjects[obj] then return end
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local bg = Instance.new("BillboardGui")
    bg.Adornee = root
    bg.Size = UDim2.new(0, 220, 0, 60)
    bg.StudsOffset = Vector3.new(0, 4, 0)
    bg.AlwaysOnTop = true
    bg.Parent = CoreGui

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.3
    lbl.TextSize = 17
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bg

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 0.15
    hl.Parent = obj

    espObjects[obj] = {billboard = bg, highlight = hl}
end

local function removeESP(obj)
    if espObjects[obj] then
        pcall(function()
            espObjects[obj].billboard:Destroy()
            espObjects[obj].highlight:Destroy()
        end)
        espObjects[obj] = nil
    end
end

local function clearAllESP()
    for obj in pairs(espObjects) do removeESP(obj) end
end

local function isKiller(player)
    if not player or not player.Character then return false end
    local char = player.Character
    local name = char.Name:lower()

    local killerNames = {"springtrap", "mimic", "ennard", "rotten", "doppel", "animatronic", "killer", "project", "freddy", "bonnie", "chica", "foxy"}
    for _, k in ipairs(killerNames) do
        if name:find(k) then return true end
    end

    for _, part in ipairs(char:GetChildren()) do
        local n = part.Name:lower()
        for _, k in ipairs(killerNames) do
            if n:find(k) then return true end
        end
    end
    return false
end

local function updateESP()
    for obj, _ in pairs(espObjects) do
        if not obj or not obj.Parent then removeESP(obj) end
    end

    -- Generators
    if ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj.Parent then continue end
            local n = obj.Name:lower()
            if (obj:IsA("Model") or obj:IsA("Folder")) and 
               (n:find("generator") or n:find("gen") or n:find("powerbox") or n:find("fusebox") or n:find("battery")) and
               not n:find("door") and not n:find("gate") and not n:find("light") then
                
                if not espObjects[obj] then
                    createESP(obj, Color3.fromRGB(0, 255, 100), "⚡ GENERATOR")
                end
            end
        end
    end

    -- Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local char = player.Character

        if ESP_Killer and isKiller(player) then
            createESP(char, Color3.fromRGB(255, 40, 40), "🔪 KILLER")
        elseif ESP_Survivors and not isKiller(player) then
            createESP(char, Color3.fromRGB(80, 180, 255), player.Name)
        else
            removeESP(char)
        end
    end

    -- Items (простая версия)
    if ESP_Items then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if n:find("key") or n:find("battery") or n:find("fuse") or n:find("exit") or n:find("door") then
                if not espObjects[obj] and (obj:IsA("Model") or obj:IsA("Part")) then
                    createESP(obj, Color3.fromRGB(255, 215, 0), "🔑 ITEM")
                end
            end
        end
    end
end

local function refreshESP()
    clearAllESP()
    updateESP()
end

-- ========== GUI (твой старый код + новые тогглы) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "BiteByNight_Hack_v13_1"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 580)
mainFrame.Position = UDim2.new(1, -300, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 255, 160)
stroke.Thickness = 2

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "BITE BY NIGHT v13.1"
title.TextColor3 = Color3.fromRGB(0, 255, 160)
title.TextSize = 22
title.Font = Enum.Font.GothamBlack
title.Parent = mainFrame

local yOffset = 65

local function addLabel(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.92, 0, 0, 28)
    lbl.Position = UDim2.new(0.04, 0, 0, yOffset)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(0, 255, 140)
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = mainFrame
    yOffset += 32
    return lbl
end

local function addToggle(text, default, callback)
    local enabled = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.Position = UDim2.new(0.04, 0, 0, yOffset)
    btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(140, 0, 0)
    btn.Text = text .. (enabled and " : ON" or " : OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(140, 0, 0)
        btn.Text = text .. (enabled and " : ON" or " : OFF")
        if callback then callback(enabled) end
    end)

    yOffset += 46
    return btn
end

-- Speed Slider
local speedLabel = addLabel("⚡ Скорость: " .. SpeedValue)

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.92, 0, 0, 16)
sliderBg.Position = UDim2.new(0.04, 0, 0, yOffset)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
sliderBg.Parent = mainFrame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(SpeedValue / MaxSpeed, 1, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 130)
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 26, 0, 26)
sliderKnob.Position = UDim2.new(SpeedValue / MaxSpeed, -8, 0.5, -13)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 160)
sliderKnob.Text = ""
sliderKnob.Parent = sliderBg
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local function updateSlider()
    local percent = SpeedValue / MaxSpeed
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, -8, 0.5, -13)
    speedLabel.Text = "⚡ Скорость: " .. math.floor(SpeedValue)
end

local function handleSliderMove(input)
    local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
    SpeedValue = math.floor(percent * MaxSpeed)
    updateSlider()
    if SpeedEnabled then applySpeed() end
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        handleSliderMove(input)
        local moving = true
        local moveConn = UserInputService.InputChanged:Connect(function(move)
            if moving and (move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch) then
                handleSliderMove(move)
            end
        end)
        local endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                moving = false
                moveConn:Disconnect()
                endConn:Disconnect()
            end
        end)
    end
end)

yOffset += 55

-- ========== ТОГГЛЫ ==========
addToggle("SPEED + AUTO SPRINT", SpeedEnabled, function(s) SpeedEnabled = s applySpeed() end)
addToggle("INFINITE STAMINA", StaminaEnabled, function(s) StaminaEnabled = s applyInfiniteStamina() end)
addToggle("FLY (F2)", FlyEnabled, function(s) FlyEnabled = s applyFly() end)
addToggle("NOCLIP", NoClipEnabled, function(s) NoClipEnabled = s applyNoClip() end)
addToggle("GODMODE", GodmodeEnabled, function(s) GodmodeEnabled = s applyGodmode() end)
addToggle("ESP Генераторы", ESP_Generators, function(s) ESP_Generators = s refreshESP() end)
addToggle("ESP Убийца", ESP_Killer, function(s) ESP_Killer = s refreshESP() end)
addToggle("ESP Выжившие", ESP_Survivors, function(s) ESP_Survivors = s refreshESP() end)
addToggle("ESP Предметы", ESP_Items, function(s) ESP_Items = s refreshESP() end)
addToggle("AUTO REPAIR", AutoRepairEnabled, function(s) AutoRepairEnabled = s applyAutoRepair() end)

-- ========== HOTKEYS ==========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        gui.Enabled = not gui.Enabled
    elseif input.KeyCode == Enum.KeyCode.F2 then
        FlyEnabled = not FlyEnabled
        applyFly()
        -- можно обновить текст кнопки, если хочешь
    elseif input.KeyCode == Enum.KeyCode.F3 then
        SpeedEnabled = not SpeedEnabled
        applySpeed()
    end
end)

-- ========== ЗАПУСК ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(killAntiCheatScripts, LocalPlayer.Character)
    pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
    applySpeed()
    applyInfiniteStamina()
    applyFly()
    applyNoClip()
    applyGodmode()
    applyAutoRepair()
    refreshESP()
end)

task.spawn(function()
    task.wait(1.2)
    pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
    applySpeed()
    applyInfiniteStamina()
    applyFly()
    applyNoClip()
    applyGodmode()
    applyAutoRepair()
    refreshESP()
end)

task.spawn(function()
    while task.wait(1.1) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v13.1 успешно загружен!")
print("   Горячие клавиши: F1 - GUI | F2 - Fly | F3 - Speed")
