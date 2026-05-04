-- ============================================
-- BITE BY NIGHT v13.9 — Улучшенный ESP + Полный GUI
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

-- ==================== УЛУЧШЕННЫЙ МЕТОД ОПРЕДЕЛЕНИЯ УБИЙЦЫ ====================
local function isKiller(character)
    if not character then return false end
    
    local nameLower = character.Name:lower()
    local modelName = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Parent.Name:lower() or ""

    local killerKeywords = {
        "springtrap", "mimic", "ennard", "rotten", "doppel", "animatronic", 
        "killer", "project", "theproject", "mistake", "doppelganger", 
        "nightmare", "monster", "beast", "scary", "jason", "freddy", "chucky"
    }

    for _, keyword in ipairs(killerKeywords) do
        if nameLower:find(keyword) or modelName:find(keyword) then
            return true
        end
    end

    -- Проверка по особым частям модели (часто используется в таких играх)
    for _, part in ipairs(character:GetChildren()) do
        local pName = part.Name:lower()
        if pName:find("mask") or pName:find("knife") or pName:find("claws") or pName:find("hook") then
            return true
        end
    end

    return false
end

-- ==================== УЛУЧШЕННЫЙ ПОИСК ГЕНЕРАТОРОВ ====================
local function isGenerator(obj)
    if not obj or not obj:IsA("Model") then return false end
    local name = obj.Name:lower()

    if name:find("generator") or name:find("^gen") or name:find("powergen") or name == "gen" then
        if name:find("door") or name:find("gate") or name:find("light") or name:find("lamp") or name:find("battery") then
            return false
        end
        return true
    end
    return false
end

-- ==================== СТАМИНА ====================
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
                    val.Value = 97 + math.random(0, 2)
                end
            end

            for _, name in ipairs({"Stamina", "SprintStamina", "Energy", "Fatigue", "Exhaustion"}) do
                if hum:GetAttribute(name) ~= nil then
                    hum:SetAttribute(name, 97 + math.random(0, 3))
                end
            end
        end)
    end)
end

-- ==================== SPEED ====================
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
                local moveVec = hum.MoveDirection * Settings.SpeedValue * dt * 1.1
                root.CFrame += moveVec
                root.AssemblyLinearVelocity = Vector3.new(moveVec.X * 35, root.AssemblyLinearVelocity.Y, moveVec.Z * 35)
            end
        end)
    end)
end

-- ==================== FLY ====================
local bodyVelocity = nil
local function applyFly()
    if connections.fly then connections.fly:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if not Settings.FlyEnabled then return end

    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = root

    connections.fly = RunService.Heartbeat:Connect(function()
        if not Settings.FlyEnabled or not bodyVelocity then return end
        local cam = Workspace.CurrentCamera
        local move = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        bodyVelocity.Velocity = move.Unit * (Settings.SpeedValue * 2.3) or Vector3.zero
    end)
end

-- ==================== NOCLIP ====================
local function applyNoClip()
    if connections.noclip then connections.noclip:Disconnect() end
    if not Settings.NoClipEnabled then return end

    connections.noclip = RunService.Stepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end

-- ==================== AUTO REPAIR ====================
local function applyAutoRepair()
    if connections.firing then connections.firing:Disconnect() end
    if not Settings.AutoRepairEnabled then return end

    connections.firing = RunService.Heartbeat:Connect(function()
        if tick() - lastFireTime < 0.12 then return end
        pcall(function()
            local gui = LocalPlayer.PlayerGui:FindFirstChild("Gen") or LocalPlayer.PlayerGui:FindFirstChild("Generator")
            if not gui then return end
            local event = gui:FindFirstChild("Event", true) or gui:FindFirstChildWhichIsA("RemoteEvent")
            if event then
                event:FireServer({Wires = true, Switches = true, Lever = true})
                lastFireTime = tick()
            end
        end)
    end)
end

-- ==================== ESP ====================
local function createESP(obj, color, text)
    if espObjects[obj] then return end

    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local bg = Instance.new("BillboardGui")
    bg.Adornee = root
    bg.Size = UDim2.new(0, 210, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3.8, 0)
    bg.AlwaysOnTop = true
    bg.Parent = CoreGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.35
    label.TextSize = 15.5
    label.Font = Enum.Font.GothamBold
    label.Parent = bg

    local highlight = Instance.new("Highlight")
    highlight.Adornee = obj
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0.2
    highlight.Parent = obj

    espObjects[obj] = {billboard = bg, highlight = highlight}
end

local function updateESP()
    -- Очистка старых ESP
    for obj, data in pairs(espObjects) do
        if not obj or not obj.Parent then
            pcall(function()
                data.billboard:Destroy()
                data.highlight:Destroy()
            end)
            espObjects[obj] = nil
        end
    end

    -- Генераторы (улучшенный поиск)
    if Settings.ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isGenerator(obj) and not espObjects[obj] then
                createESP(obj, Color3.fromRGB(0, 255, 110), "⚡ GENERATOR")
            end
        end
    end

    -- Игроки
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local char = plr.Character

        if Settings.ESP_Killer and isKiller(char) then
            createESP(char, Color3.fromRGB(255, 45, 45), "🔪 KILLER")
        elseif Settings.ESP_Survivors and not isKiller(char) then
            local distText = ""
            if Settings.ESP_Distance and char:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                distText = " [" .. dist .. "]"
            end
            createESP(char, Color3.fromRGB(100, 180, 255), plr.Name .. distText)
        end
    end
end

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "BiteByNight_v39"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 285, 0, 590)
mainFrame.Position = UDim2.new(1, -305, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 170)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -75, 0, 45)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🦇 BITE BY NIGHT v13.9"
title.TextColor3 = Color3.fromRGB(0, 255, 170)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 50, 0, 35)
minButton.Position = UDim2.new(1, -65, 0, 8)
minButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
minButton.Text = "−"
minButton.TextColor3 = Color3.new(1,1,1)
minButton.TextSize = 26
minButton.Font = Enum.Font.GothamBold
minButton.Parent = mainFrame
Instance.new("UICorner", minButton).CornerRadius = UDim.new(0, 8)

minButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 285, 0, 55) or UDim2.new(0, 285, 0, 590)
    minButton.Text = minimized and "＋" or "−"
end)

-- Drag GUI
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
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local yOffset = 65

local function addToggle(text, key, func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 40)
    btn.Position = UDim2.new(0.04, 0, 0, yOffset)
    btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    btn.Text = text .. (Settings[key] and " : ON" or " : OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        btn.Text = text .. (Settings[key] and " : ON" or " : OFF")
        if func then func() end
    end)

    yOffset += 48
end

-- Ползунок скорости
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.92, 0, 0, 28)
speedLabel.Position = UDim2.new(0.04, 0, 0, yOffset)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Скорость: " .. Settings.SpeedValue
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = mainFrame
yOffset += 35

-- Слайдер (оставлен упрощённым, но рабочим)
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.92, 0, 0, 18)
sliderBg.Position = UDim2.new(0.04, 0, 0, yOffset)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
sliderBg.Parent = mainFrame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(Settings.SpeedValue / Settings.MaxSpeed, 1, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

local knob = Instance.new("TextButton")
knob.Size = UDim2.new(0, 26, 0, 26)
knob.Position = UDim2.new(Settings.SpeedValue / Settings.MaxSpeed, -13, 0.5, -13)
knob.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
knob.Text = ""
knob.Parent = sliderBg
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- Логика слайдера
local sliderDrag = false
knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliderDrag = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliderDrag = false end end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDrag then
        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        Settings.SpeedValue = math.floor(percent * Settings.MaxSpeed)
        speedLabel.Text = "⚡ Скорость: " .. Settings.SpeedValue
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -13, 0.5, -13)
        if Settings.SpeedEnabled then applySpeed() end
    end
end)

yOffset += 55

-- Тогглы
addToggle("Speed", "SpeedEnabled", applySpeed)
addToggle("Stamina", "StaminaEnabled", applyStamina)
addToggle("Fly", "FlyEnabled", applyFly)
addToggle("NoClip", "NoClipEnabled", applyNoClip)
addToggle("Anti Stun", "AntiStunEnabled", nil)
addToggle("Infinite Jump", "InfiniteJumpEnabled", nil)
addToggle("Auto Repair", "AutoRepairEnabled", applyAutoRepair)
addToggle("ESP Генераторы", "ESP_Generators", updateESP)
addToggle("ESP Убийца", "ESP_Killer", updateESP)
addToggle("ESP Выжившие", "ESP_Survivors", updateESP)

-- Запуск
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
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
    while task.wait(0.9) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v13.9 загружен | ESP улучшен")
