-- ============================================
-- BITE BY NIGHT v13.4 — Улучшенный мобильный ползунок + ESP Mimic Fix + Скрытная стамина
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Настройки
local SpeedEnabled = true
local SpeedValue = 12
local MaxSpeed = 50
local StaminaEnabled = true
local NoClipEnabled = false
local AutoRepairEnabled = false

local ESP_Generators = true
local ESP_Killer = true
local ESP_Survivors = true

local espObjects = {}
local speedConnection = nil
local noclipConnection = nil
local staminaConnection = nil
local autoRepairConnection = nil
local firingConnection = nil
local lastFireTime = 0

-- ========== СКРЫТНАЯ БЕСКОНЕЧНАЯ СТАМИНА ==========
local function applyInfiniteStamina()
    if staminaConnection then staminaConnection:Disconnect() end
    if not StaminaEnabled then return end

    staminaConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            if math.random(1, 3) ~= 1 then return end

            for _, name in ipairs({
                "Stamina", "SprintStamina", "Energy", "StaminaValue", 
                "RunStamina", "SprintEnergy", "StaminaRegen", "Fatigue",
                "CurrentStamina", "MaxStamina", "Exhaustion"
            }) do
                if hum:GetAttribute(name) ~= nil then
                    local randomValue = 97 + math.random(0, 3)
                    hum:SetAttribute(name, randomValue)
                end
            end

            if hum:GetAttribute("Fatigue") then hum:SetAttribute("Fatigue", 0) end
            if hum:GetAttribute("Exhaustion") then hum:SetAttribute("Exhaustion", 0) end

            for _, v in ipairs(char:GetDescendants()) do
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and math.random(1, 5) == 1 then
                    local n = v.Name:lower()
                    if n:find("stamina") or n:find("energy") or n:find("sprint") or n:find("run") or n:find("fatigue") then
                        v.Value = 97 + math.random(0, 3)
                    end
                end
            end
        end)
    end)
end

-- ========== SPEED ==========
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

-- ========== NoClip ==========
local function applyNoClip()
    if noclipConnection then noclipConnection:Disconnect() end
    if NoClipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
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

-- ========== AUTO REPAIR ==========
local function applyAutoRepair()
    if autoRepairConnection then autoRepairConnection:Disconnect() end
    if firingConnection then firingConnection:Disconnect() end
    lastFireTime = 0

    if not AutoRepairEnabled then return end

    autoRepairConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local genGui = LocalPlayer.PlayerGui:FindFirstChild("Gen") or LocalPlayer.PlayerGui:FindFirstChild("Generator")
            if genGui and (genGui:FindFirstChild("GeneratorMain") or genGui:FindFirstChild("Main")) then
                if not firingConnection then
                    firingConnection = RunService.Heartbeat:Connect(function()
                        if not AutoRepairEnabled then return end
                        local currentTime = tick()
                        if currentTime - lastFireTime >= 0.08 then
                            pcall(function()
                                local args = {{ Wires = true, Switches = true, Lever = true }}
                                local event = genGui:FindFirstChild("GeneratorMain") and genGui.GeneratorMain.Event or genGui:FindFirstChild("Event")
                                if event then
                                    event:FireServer(unpack(args))
                                end
                            end)
                            lastFireTime = currentTime
                        end
                    end)
                end
            else
                if firingConnection then
                    firingConnection:Disconnect()
                    firingConnection = nil
                end
                lastFireTime = 0
            end
        end)
    end)
end

-- ========== ESP с исправлением Mimic ==========
local function createESP(obj, color, text)
    if espObjects[obj] then return end
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local bg = Instance.new("BillboardGui")
    bg.Adornee = root
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3.5, 0)
    bg.AlwaysOnTop = true
    bg.Parent = CoreGui

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.4
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bg

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.65
    hl.OutlineTransparency = 0.2
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
    local nameLower = (char.Name or ""):lower()

    local keywords = {
        "springtrap", "mimic", "ennard", "rotten", "doppel", 
        "animatronic", "killer", "project", "m2", "theproject", 
        "the project", "doppelganger", "mistake"
    }

    for _, kw in ipairs(keywords) do
        if nameLower:find(kw) then return true end
    end

    for _, part in ipairs(char:GetChildren()) do
        local n = part.Name:lower()
        for _, kw in ipairs(keywords) do
            if n:find(kw) then return true end
        end
    end
    return false
end

local function updateESP()
    for obj, _ in pairs(espObjects) do
        if not obj or not obj.Parent then removeESP(obj) end
    end

    if ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not (obj:IsA("Model") or obj:IsA("Folder")) then continue end
            local n = obj.Name:lower()

            if (n:find("^generator") or n:find("generator%d") or n == "gen" or n:find("powergen") or n:find("main generator")) 
               and not n:find("door") and not n:find("gate") and not n:find("light") 
               and not n:find("lamp") and not n:find("battery") and not n:find("fuse") 
               and not n:find("box") and not espObjects[obj] then
                
                createESP(obj, Color3.fromRGB(0, 255, 100), "⚡ GENERATOR")
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end

        local char = player.Character
        if ESP_Killer and isKiller(player) then
            createESP(char, Color3.fromRGB(255, 50, 50), "🔪 KILLER")
        elseif ESP_Survivors and not isKiller(player) then
            createESP(char, Color3.fromRGB(80, 180, 255), player.Name)
        else
            removeESP(char)
        end
    end
end

local function refreshESP()
    clearAllESP()
    updateESP()
end

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "BiteByNight_Hack"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 270, 0, 520)
mainFrame.Position = UDim2.new(1, -290, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 160)
Instance.new("UIStroke", mainFrame).Thickness = 2

local minimized = false
local fullSize = mainFrame.Size
local collapsibleElements = {}

local function addCollapsible(element)
    if element then table.insert(collapsibleElements, element) end
end

local function updateMinimizedState()
    if minimized then
        mainFrame.Size = UDim2.new(0, 270, 0, 45)
        for _, el in ipairs(collapsibleElements) do if el then el.Visible = false end end
        minButton.Text = "＋"
    else
        mainFrame.Size = fullSize
        for _, el in ipairs(collapsibleElements) do if el then el.Visible = true end end
        minButton.Text = "−"
    end
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🦇 BITE BY NIGHT v13.4"
title.TextColor3 = Color3.fromRGB(0, 255, 160)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 50, 0, 30)
minButton.Position = UDim2.new(1, -65, 0, 5)
minButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
minButton.Text = "−"
minButton.TextColor3 = Color3.new(1,1,1)
minButton.TextSize = 24
minButton.Font = Enum.Font.GothamBold
minButton.Parent = mainFrame
Instance.new("UICorner", minButton).CornerRadius = UDim.new(0, 8)

minButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    updateMinimizedState()
end)

-- Drag главного окна
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = false 
    end
end)

local yOffset = 55

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
    addCollapsible(lbl)
    yOffset += 32
    return lbl
end

local function addToggle(text, defaultEnabled, callback)
    local enabled = defaultEnabled
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 36)
    btn.Position = UDim2.new(0.04, 0, 0, yOffset)
    btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(140, 0, 0)
    btn.Text = text .. (enabled and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
    addCollapsible(btn)

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(140, 0, 0)
        btn.Text = text .. (enabled and ": ON" or ": OFF")
        if callback then callback(enabled) end
    end)

    yOffset += 42
    return btn
end

local speedLabel = addLabel("⚡ Скорость: " .. SpeedValue, Color3.fromRGB(0, 255, 120))

-- ========== УЛУЧШЕННЫЙ ПОЛЗУНОК (на основе твоего примера) ==========
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.92, 0, 0, 18)
sliderBg.Position = UDim2.new(0.04, 0, 0, yOffset)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
sliderBg.Parent = mainFrame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
addCollapsible(sliderBg)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((SpeedValue / MaxSpeed), 1, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 130)
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("TextButton")  -- handle
sliderKnob.Size = UDim2.new(0, 28, 0, 28)
sliderKnob.Position = UDim2.new((SpeedValue / MaxSpeed), -14, 0.5, -14)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 160)
sliderKnob.Text = ""
sliderKnob.Parent = sliderBg
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local function updateSlider()
    local percent = math.clamp(SpeedValue / MaxSpeed, 0, 1)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, -14, 0.5, -14)
    speedLabel.Text = "⚡ Скорость: " .. math.floor(SpeedValue)
end

local function handleSliderMove(input)
    if not sliderBg or not sliderBg.AbsoluteSize then return end
    local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
    SpeedValue = math.floor(percent * MaxSpeed + 0.5)
    if SpeedValue < 0 then SpeedValue = 0 end
    if SpeedValue > MaxSpeed then SpeedValue = MaxSpeed end
    updateSlider()
    if SpeedEnabled then applySpeed() end
end

-- Улучшенная логика перетаскивания (на основе твоего примера)
local sliderDragging = false

sliderKnob.InputBegan:Connect(function(input)  -- или sliderBg, если хочешь цеплять весь бар
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        handleSliderMove(input)
    end
end)

yOffset += 55

-- ========== ТОГГЛЫ ==========
addToggle("SPEED + AUTO SPRINT", SpeedEnabled, function(s) SpeedEnabled = s applySpeed() end)
addToggle("STAMINA (Скрытная)", StaminaEnabled, function(s) StaminaEnabled = s applyInfiniteStamina() end)
addToggle("NOCLIP", NoClipEnabled, function(s) NoClipEnabled = s applyNoClip() end)
addToggle("ESP Генераторы", ESP_Generators, function(s) ESP_Generators = s refreshESP() end)
addToggle("ESP Убийца", ESP_Killer, function(s) ESP_Killer = s refreshESP() end)
addToggle("ESP Выжившие", ESP_Survivors, function(s) ESP_Survivors = s refreshESP() end)
addToggle("AUTO REPAIR", AutoRepairEnabled, function(s) AutoRepairEnabled = s applyAutoRepair() end)

-- ========== Запуск ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    applySpeed()
    applyInfiniteStamina()
    applyNoClip()
    applyAutoRepair()
    refreshESP()
end)

task.spawn(function()
    task.wait(1)
    applySpeed()
    applyInfiniteStamina()
    applyNoClip()
    applyAutoRepair()
    refreshESP()
end)

task.spawn(function()
    while task.wait(1.1) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v13.4 загружен | Ползунок сильно улучшен для телефона | ESP Mimic + скрытная стамина")
