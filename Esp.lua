-- ============================================
-- SPEEDHACK + INF STAMINA + ESP + NOCLIP v12.4 – BiteByNight Edition (2026)
-- erafox private protocol
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local SpeedEnabled = true
local SpeedValue = 35
local MaxSpeed = 50
local StaminaEnabled = true
local NoClipEnabled = false

local ESP_Enabled = true
local ESP_Generators = true
local ESP_Killer = true
local ESP_Survivors = true

local connections = {}
local espObjects = {}

-- ========== 1. Убийство античит-скриптов ==========
local function killAntiCheatScripts(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local nameLow = (obj.Name or ""):lower()
            if nameLow:find("anti") or nameLow:find("cheat") or nameLow:find("bite") or
               nameLow:find("speed") or nameLow:find("stamina") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- ========== 2. Бесконечная стамина ==========
local function applyInfiniteStamina()
    for _, c in connections do pcall(function() c:Disconnect() end) end
    if not StaminaEnabled then return end

    local conn = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, attr in ipairs({"Stamina", "SprintStamina", "Energy", "Fatigue", "StaminaValue"}) do
                    if hum:GetAttribute(attr) ~= nil then
                        hum:SetAttribute(attr, 100)
                    end
                end
            end
            for _, v in ipairs(char:GetDescendants()) do
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and 
                   (v.Name:lower():find("stamina") or v.Name:lower():find("energy")) then
                    v.Value = 100
                end
            end
        end)
    end)
    table.insert(connections, conn)
end

-- ========== 3. Скорость с ползунком ==========
local function applySpeed()
    for _, c in connections do pcall(function() c:Disconnect() end) end
    connections = {}

    if not SpeedEnabled then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
        return
    end

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 3)
    local root = character:WaitForChild("HumanoidRootPart", 3)

    if humanoid then humanoid.WalkSpeed = SpeedValue end

    local conn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            if not humanoid or not root or not SpeedEnabled then return end
            humanoid.WalkSpeed = SpeedValue

            if humanoid.MoveDirection.Magnitude > 0 then
                local move = humanoid.MoveDirection * SpeedValue * dt * 1.05
                root.CFrame += move
            end
        end)
    end)
    table.insert(connections, conn)
end

-- ========== 4. NoClip ==========
local function applyNoClip()
    if NoClipEnabled then
        local conn = RunService.Stepped:Connect(function()
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
        table.insert(connections, conn)
    else
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
end

-- ========== 5. ESP ==========
local function createESP(obj, color, labelText)
    if espObjects[obj] then return end
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 180, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = CoreGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = labelText
    text.TextColor3 = color
    text.TextStrokeTransparency = 0.6
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.Adornee = obj
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0.3
    highlight.Parent = obj

    espObjects[obj] = {billboard = billboard, highlight = highlight}
end

local function updateESP()
    -- Очистка удалённых
    for obj, data in pairs(espObjects) do
        if not obj or not obj.Parent then
            pcall(function() data.billboard:Destroy() data.highlight:Destroy() end)
            espObjects[obj] = nil
        end
    end

    if not ESP_Enabled then return end

    -- Генераторы и батареи
    if ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local nameLow = obj.Name:lower()
            if (obj:IsA("Model") or obj:IsA("Folder")) and 
               (nameLow:find("generator") or nameLow:find("gen") or nameLow:find("battery")) and not espObjects[obj] then
                createESP(obj, Color3.fromRGB(0, 255, 120), "⚡ GENERATOR / BATTERY")
            end
        end
    end

    -- Выжившие
    if ESP_Survivors then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                if char:FindFirstChildOfClass("Humanoid") and not espObjects[char] then
                    createESP(char, Color3.fromRGB(100, 200, 255), plr.Name)
                end
            end
        end
    end

    -- Убийца (по высокой скорости или специальному имени)
    if ESP_Killer then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and (hum.WalkSpeed > 20 or hum.Health > 1500) and not espObjects[plr.Character] then
                    createESP(plr.Character, Color3.fromRGB(255, 60, 60), "🔪 KILLER")
                end
            end
        end
    end
end

-- ========== 6. GUI с ползунком и сворачиванием ==========
local gui = Instance.new("ScreenGui")
gui.Name = "System_" .. math.random(10000,99999)
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 340)
frame.Position = UDim2.new(1, -260, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.12
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 1.8

local minimized = false
local originalSize = frame.Size

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🦇 BITE BY NIGHT v12.4"
title.TextColor3 = Color3.fromRGB(0, 255, 140)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local btnMinimize = Instance.new("TextButton")
btnMinimize.Size = UDim2.new(0, 45, 0, 28)
btnMinimize.Position = UDim2.new(1, -55, 0, 4)
btnMinimize.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
btnMinimize.Text = "−"
btnMinimize.TextColor3 = Color3.new(1,1,1)
btnMinimize.TextSize = 20
btnMinimize.Font = Enum.Font.Gotham
btnMinimize.Parent = frame
Instance.new("UICorner", btnMinimize).CornerRadius = UDim.new(0, 6)

btnMinimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    frame.Size = minimized and UDim2.new(0, 240, 0, 40) or originalSize
    btnMinimize.Text = minimized and "+" or "−"
end)

-- Drag
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- === Кнопки и ползунок (размещены ниже) ===
local y = 45

-- Speed Label + Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, y)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ Speed: " .. SpeedValue
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = frame
y += 30

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, -20, 0, 8)
sliderFrame.Position = UDim2.new(0, 10, 0, y)
sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
sliderFrame.Parent = frame
Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(1,0)

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new((SpeedValue-16)/(MaxSpeed-16), 0, 1, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
sliderBar.Parent = sliderFrame
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1,0)

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 16, 0, 16)
sliderButton.Position = UDim2.new((SpeedValue-16)/(MaxSpeed-16), -4, 0.5, -8)
sliderButton.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
sliderButton.Text = ""
sliderButton.Parent = sliderFrame
Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(1,0)

-- Slider logic
local function updateSlider()
    local ratio = (SpeedValue - 16) / (MaxSpeed - 16)
    sliderBar.Size = UDim2.new(ratio, 0, 1, 0)
    sliderButton.Position = UDim2.new(ratio, -8, 0.5, -8)
    speedLabel.Text = "⚡ Speed: " .. math.floor(SpeedValue)
    if SpeedEnabled then applySpeed() end
end

sliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn
        conn = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = math.clamp((move.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                SpeedValue = 16 + relX * (MaxSpeed - 16)
                updateSlider()
            end
        end)
        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                conn:Disconnect()
            end
        end)
    end
end)

y += 25

-- Кнопки
local function createToggleButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 32)
    btn.Position = UDim2.new(0.04, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local btnSpeed = createToggleButton("SPEED: ON", y, function()
    SpeedEnabled = not SpeedEnabled
    btnSpeed.Text = "SPEED: " .. (SpeedEnabled and "ON" or "OFF")
    btnSpeed.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(140,0,0)
    applySpeed()
end)
y += 40

local btnStamina = createToggleButton("STAMINA: ON", y, function()
    StaminaEnabled = not StaminaEnabled
    btnStamina.Text = "STAMINA: " .. (StaminaEnabled and "ON" or "OFF")
    btnStamina.BackgroundColor3 = StaminaEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(140,0,0)
    applyInfiniteStamina()
end)
y += 40

local btnNoClip = createToggleButton("NOCLIP: OFF", y, function()
    NoClipEnabled = not NoClipEnabled
    btnNoClip.Text = "NOCLIP: " .. (NoClipEnabled and "ON" or "OFF")
    btnNoClip.BackgroundColor3 = NoClipEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(140,0,0)
    applyNoClip()
end)
y += 40

local btnESP = createToggleButton("ESP: ON", y, function()
    ESP_Enabled = not ESP_Enabled
    btnESP.Text = "ESP: " .. (ESP_Enabled and "ON" or "OFF")
    btnESP.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(140,0,0)
    updateESP()
end)
y += 40

-- Дополнительные ESP тогглы (можно выключать по отдельности)
local btnGen = createToggleButton("ESP Generators: ON", y, function()
    ESP_Generators = not ESP_Generators
    btnGen.Text = "ESP Generators: " .. (ESP_Generators and "ON" or "OFF")
    updateESP()
end)
y += 40

local btnKiller = createToggleButton("ESP Killer: ON", y, function()
    ESP_Killer = not ESP_Killer
    btnKiller.Text = "ESP Killer: " .. (ESP_Killer and "ON" or "OFF")
    updateESP()
end)
y += 40

local btnSurv = createToggleButton("ESP Survivors: ON", y, function()
    ESP_Survivors = not ESP_Survivors
    btnSurv.Text = "ESP Survivors: " .. (ESP_Survivors and "ON" or "OFF")
    updateESP()
end)

-- ========== 7. Запуск ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    pcall(killAntiCheatScripts, LocalPlayer.Character)
    applySpeed()
    applyInfiniteStamina()
    applyNoClip()
    task.wait(1)
    updateESP()
end)

task.spawn(function()
    task.wait(1.2)
    pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
    applySpeed()
    applyInfiniteStamina()
    applyNoClip()
    updateESP()
end)

task.spawn(function()
    while task.wait(1.8) do
        updateESP()
    end
end)

print("✅ erafox v12.4 | Speed + Inf Stamina + ESP + NoClip для Bite By Night — загружено")
