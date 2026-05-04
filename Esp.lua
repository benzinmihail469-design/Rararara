-- ============================================
-- BITE BY NIGHT v13.9 — Полная версия с GUI
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Настройки
local Settings = {
    SpeedEnabled = true,
    SpeedValue = 18,
    MaxSpeed = 60,
    StaminaEnabled = true,
    FlyEnabled = false,
    NoClipEnabled = false,
    AntiStunEnabled = true,
    InfiniteJumpEnabled = false,
    AutoRepairEnabled = false,

    ESP_Generators = true,
    ESP_Killer = true,
    ESP_Survivors = true,
    ESP_Distance = true
}

local espObjects = {}
local connections = {}
local lastFireTime = 0
local minimized = false

-- ========== СТАМИНА ==========
local function applyStamina()
    if connections.stamina then connections.stamina:Disconnect() end
    if not Settings.StaminaEnabled then return end

    connections.stamina = RunService.RenderStepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            for _, name in ipairs({"Stamina", "SprintStamina", "Energy", "RunStamina", "CurrentStamina"}) do
                local val = hum:FindFirstChild(name) or char:FindFirstChild(name, true)
                if val and (val:IsA("NumberValue") or val:IsA("IntValue")) then
                    val.Value = 96 + math.random(0, 3)
                end
            end

            for _, name in ipairs({"Stamina", "SprintStamina", "Energy", "Fatigue", "Exhaustion"}) do
                if hum:GetAttribute(name) ~= nil then
                    hum:SetAttribute(name, 96 + math.random(0, 4))
                end
            end

            if hum:GetAttribute("Fatigue") then hum:SetAttribute("Fatigue", 0) end
            if hum:GetAttribute("Exhaustion") then hum:SetAttribute("Exhaustion", 0) end
        end)
    end)
end

-- ========== SPEED ==========
local function applySpeed()
    if connections.speed then connections.speed:Disconnect() end
    if not Settings.SpeedEnabled then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
        return
    end

    connections.speed = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end

            hum.WalkSpeed = Settings.SpeedValue

            if hum.MoveDirection.Magnitude > 0 then
                local moveVec = hum.MoveDirection * Settings.SpeedValue * dt * 1.12
                root.CFrame += moveVec
                root.AssemblyLinearVelocity = Vector3.new(moveVec.X * 35, root.AssemblyLinearVelocity.Y, moveVec.Z * 35)
            end
        end)
    end)
end

-- ========== FLY ==========
local bodyVelocity = nil

local function applyFly()
    if connections.fly then connections.fly:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end

    if not Settings.FlyEnabled then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new()
    bodyVelocity.Parent = root

    connections.fly = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not Settings.FlyEnabled or not bodyVelocity then return end
            local cam = Workspace.CurrentCamera
            local move = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

            local speed = Settings.SpeedValue * 2.2
            bodyVelocity.Velocity = move.Unit * speed
        end)
    end)
end

-- ========== NOCLIP ==========
local function applyNoClip()
    if connections.noclip then connections.noclip:Disconnect() end
    if not Settings.NoClipEnabled then return end

    connections.noclip = RunService.Stepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end)
end

-- ========== AUTO REPAIR ==========
local function applyAutoRepair()
    if connections.autoRepair then connections.autoRepair:Disconnect() end
    if connections.firing then connections.firing:Disconnect() end

    if not Settings.AutoRepairEnabled then return end

    connections.autoRepair = RunService.Heartbeat:Connect(function()
        pcall(function()
            local gui = LocalPlayer.PlayerGui:FindFirstChild("Gen") or LocalPlayer.PlayerGui:FindFirstChild("Generator")
            if not gui then return end

            local main = gui:FindFirstChild("GeneratorMain") or gui:FindFirstChild("Main")
            if main then
                if not connections.firing then
                    connections.firing = RunService.Heartbeat:Connect(function()
                        if tick() - lastFireTime >= 0.11 then
                            pcall(function()
                                local event = main:FindFirstChild("Event") or gui:FindFirstChild("Event")
                                if event then
                                    event:FireServer({Wires = true, Switches = true, Lever = true})
                                end
                            end)
                            lastFireTime = tick()
                        end
                    end)
                end
            else
                if connections.firing then 
                    connections.firing:Disconnect() 
                    connections.firing = nil 
                end
            end
        end)
    end)
end

-- ========== ESP ==========
local function createESP(obj, color, text)
    if espObjects[obj] then return end
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local bg = Instance.new("BillboardGui")
    bg.Adornee = root
    bg.Size = UDim2.new(0, 220, 0, 55)
    bg.StudsOffset = Vector3.new(0, 4, 0)
    bg.AlwaysOnTop = true
    bg.Parent = CoreGui

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.4
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bg

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.68
    hl.OutlineTransparency = 0.25
    hl.Parent = obj

    espObjects[obj] = {billboard = bg, highlight = hl}
end

local function updateESP()
    for obj, data in pairs(espObjects) do
        if not obj or not obj.Parent then
            pcall(function()
                data.billboard:Destroy()
                data.highlight:Destroy()
            end)
            espObjects[obj] = nil
        end
    end

    if Settings.ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("generator") or n:find("^gen")) and not n:find("door") and not n:find("light") and not espObjects[obj] then
                createESP(obj, Color3.fromRGB(0, 255, 100), "⚡ GENERATOR")
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local char = plr.Character

        local isKiller = false
        local nameLower = char.Name:lower()
        local keywords = {"springtrap","mimic","ennard","rotten","doppel","animatronic","killer","project"}

        for _, kw in ipairs(keywords) do
            if nameLower:find(kw) then isKiller = true break end
        end

        if Settings.ESP_Killer and isKiller then
            createESP(char, Color3.fromRGB(255, 50, 50), "🔪 KILLER")
        elseif Settings.ESP_Survivors and not isKiller then
            local dist = (char:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                and math.floor((char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
            local txt = plr.Name
            if Settings.ESP_Distance then txt = txt .. " [" .. dist .. "]" end
            createESP(char, Color3.fromRGB(80, 180, 255), txt)
        end
    end
end

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "BiteByNight_v39"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 580)
mainFrame.Position = UDim2.new(1, -300, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 255, 160)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 45)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🦇 BITE BY NIGHT v13.9"
title.TextColor3 = Color3.fromRGB(0, 255, 160)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Кнопка сворачивания
local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 50, 0, 35)
minButton.Position = UDim2.new(1, -65, 0, 8)
minButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
minButton.Text = "−"
minButton.TextColor3 = Color3.new(1,1,1)
minButton.TextSize = 24
minButton.Font = Enum.Font.GothamBold
minButton.Parent = mainFrame
Instance.new("UICorner", minButton).CornerRadius = UDim.new(0, 8)

minButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 280, 0, 55) or UDim2.new(0, 280, 0, 580)
    minButton.Text = minimized and "＋" or "−"
end)

-- Drag
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local y = 60

local function addToggle(name, settingKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.Position = UDim2.new(0.04, 0, 0, y)
    btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    btn.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        btn.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
        if callback then callback(Settings[settingKey]) end
    end)

    y += 48
    return btn
end

local function addLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.92, 0, 0, 30)
    lbl.Position = UDim2.new(0.04, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(0, 255, 140)
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = mainFrame
    y += 35
end

-- ========== Ползунок скорости ==========
addLabel("⚡ Скорость: " .. Settings.SpeedValue)

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.92, 0, 0, 20)
sliderBg.Position = UDim2.new(0.04, 0, 0, y)
sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
sliderBg.Parent = mainFrame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(Settings.SpeedValue / Settings.MaxSpeed, 1, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 30, 0, 30)
sliderKnob.Position = UDim2.new(Settings.SpeedValue / Settings.MaxSpeed, -15, 0.5, -15)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
sliderKnob.Text = ""
sliderKnob.Parent = sliderBg
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local function updateSlider()
    local percent = math.clamp(Settings.SpeedValue / Settings.MaxSpeed, 0, 1)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, -15, 0.5, -15)
end

local draggingSlider = false
sliderKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        Settings.SpeedValue = math.floor(percent * Settings.MaxSpeed + 0.5)
        updateSlider()
        if Settings.SpeedEnabled then applySpeed() end
    end
end)

y += 55

-- ========== Тогглы ==========
addToggle("Speed + Auto Sprint", "SpeedEnabled", applySpeed)
addToggle("Stamina (RenderStepped)", "StaminaEnabled", applyStamina)
addToggle("Fly (WASD + Space)", "FlyEnabled", applyFly)
addToggle("NoClip", "NoClipEnabled", applyNoClip)
addToggle("Anti Stun", "AntiStunEnabled", nil)
addToggle("Infinite Jump", "InfiniteJumpEnabled", nil)
addToggle("Auto Repair", "AutoRepairEnabled", applyAutoRepair)
addToggle("ESP Генераторы", "ESP_Generators", updateESP)
addToggle("ESP Убийца", "ESP_Killer", updateESP)
addToggle("ESP Выжившие + Дистанция", "ESP_Survivors", updateESP)

-- ========== Запуск ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
    applyStamina()
    applyFly()
    applyNoClip()
    applyAutoRepair()
end)

task.wait(1)
applySpeed()
applyStamina()
applyFly()
applyNoClip()
applyAutoRepair()

task.spawn(function()
    while task.wait(1) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v13.9 загружен успешно | GUI полностью рабочий")
