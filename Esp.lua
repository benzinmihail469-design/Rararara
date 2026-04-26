-- ============================================
-- BITE BY NIGHT v12.8 — ESP Генераторы из Celeron + Speed + Auto Sprint
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Настройки
local SpeedEnabled = true
local SpeedValue = 24
local MaxSpeed = 55
local StaminaEnabled = true
local NoClipEnabled = false
local AutoRepairEnabled = false
local AutoSprintEnabled = true

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
local autoSprintConnection = nil

-- ========== AUTO SPRINT (даже в лобби) ==========
local function applyAutoSprint()
    if autoSprintConnection then 
        autoSprintConnection:Disconnect() 
        autoSprintConnection = nil 
    end
    
    if not (SpeedEnabled and AutoSprintEnabled) then return end

    autoSprintConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        end)
    end)
end

-- ========== Античит ==========
local function killAntiCheatScripts(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local n = (obj.Name or ""):lower()
            if n:find("anti") or n:find("cheat") or n:find("bite") or n:find("speed") or n:find("stamina") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- ========== WalkSpeed ==========
local function applySpeed()
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    
    if not SpeedEnabled then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
        applyAutoSprint()
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
                root.CFrame += hum.MoveDirection * SpeedValue * dt * 0.95
            end
        end)
    end)

    applyAutoSprint()
end

-- ========== Stamina ==========
local function applyInfiniteStamina()
    if staminaConnection then staminaConnection:Disconnect() end
    if not StaminaEnabled then return end
    staminaConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, name in ipairs({"Stamina", "SprintStamina", "Energy", "Fatigue", "StaminaValue"}) do
                    if hum:GetAttribute(name) ~= nil then hum:SetAttribute(name, 100) end
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
                        if part:IsA("BasePart") then part.CanCollide = false end
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
            local genGui = LocalPlayer.PlayerGui:FindFirstChild("Gen")
            if genGui and genGui:FindFirstChild("GeneratorMain") then
                if not firingConnection then
                    firingConnection = RunService.Heartbeat:Connect(function()
                        if not AutoRepairEnabled then return end
                        local currentTime = tick()
                        if currentTime - lastFireTime >= 0 then
                            pcall(function()
                                local args = {{ Wires = true, Switches = true, Lever = true }}
                                LocalPlayer.PlayerGui.Gen.GeneratorMain.Event:FireServer(unpack(args))
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

-- ========== ESP (улучшенный из Celeron's Loader) ==========
local function createESP(obj, color, text)
    if espObjects[obj] then return end

    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local bg = Instance.new("BillboardGui")
    bg.Adornee = root
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3.5, 0)
    bg.AlwaysOnTop = true
    bg.LightInfluence = 0
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
    local nameLower = char.Name:lower()
    if nameLower:find("springtrap") or nameLower:find("mimic") or nameLower:find("ennard") or 
       nameLower:find("rotten") or nameLower:find("doppel") or nameLower:find("animatronic") or 
       nameLower:find("killer") or nameLower:find("project") then
        return true
    end

    for _, part in ipairs(char:GetChildren()) do
        local n = part.Name:lower()
        if n:find("springtrap") or n:find("mimic") or n:find("ennard") or n:find("animatronic") or n:find("killer") then
            return true
        end
    end
    return false
end

-- ========== УЛУЧШЕННЫЙ ПОИСК ГЕНЕРАТОРОВ ИЗ CELERON ==========
local function updateESP()
    -- Очистка удалённых объектов
    for obj, _ in pairs(espObjects) do
        if not obj or not obj.Parent then removeESP(obj) end
    end

    -- ESP Генераторов (улучшенная версия из Celeron's Loader)
    if ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj.Parent then continue end
            local lowerName = obj.Name:lower()
            
            -- Расширенный поиск генераторов
            if (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Part") or obj:IsA("MeshPart")) and
               (lowerName:find("generator") or lowerName:find("gen") or lowerName:find("battery") or 
                lowerName:find("power") or lowerName:find("fuse") or lowerName:find("box") or 
                lowerName:find("panel") or lowerName:find("electric")) and 
               not espObjects[obj] and not lowerName:find("door") and not lowerName:find("gate") then
                
                createESP(obj, Color3.fromRGB(0, 255, 100), "⚡ GENERATOR")
            end
        end
    end

    -- ESP игроков (без изменений)
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

-- ========== GUI (кнопка SPEED + AUTO SPRINT) ==========
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
title.Text = "🦇 BITE BY NIGHT v12.8"
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

-- Drag
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
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

-- Slider скорости
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.92, 0, 0, 12)
sliderBg.Position = UDim2.new(0.04, 0, 0, yOffset)
sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
sliderBg.Parent = mainFrame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
addCollapsible(sliderBg)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((SpeedValue-16)/(MaxSpeed-16), 1, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 130)
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 20, 0, 20)
sliderKnob.Position = UDim2.new((SpeedValue-16)/(MaxSpeed-16), -5, 0.5, -10)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 160)
sliderKnob.Text = ""
sliderKnob.Parent = sliderBg
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local function updateSlider()
    local percent = (SpeedValue - 16) / (MaxSpeed - 16)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, -5, 0.5, -10)
    if speedLabel then speedLabel.Text = "⚡ Скорость: " .. math.floor(SpeedValue) end
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local moving = true
        local moveConn = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement and moving then
                local percent = math.clamp((move.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                SpeedValue = 16 + math.floor(percent * (MaxSpeed - 16))
                updateSlider()
                if SpeedEnabled then applySpeed() end
            end
        end)
        UserInputService.InputEnded:Connect(function() moving = false; moveConn:Disconnect() end)
    end
end)

yOffset += 48

-- ========== ТОГГЛЫ ==========
addToggle("SPEED + AUTO SPRINT", SpeedEnabled, function(s) 
    SpeedEnabled = s 
    applySpeed() 
end)
addToggle("STAMINA", StaminaEnabled, function(s) StaminaEnabled = s applyInfiniteStamina() end)
addToggle("NOCLIP", NoClipEnabled, function(s) NoClipEnabled = s applyNoClip() end)
addToggle("ESP Генераторы", ESP_Generators, function(s) ESP_Generators = s refreshESP() end)
addToggle("ESP Убийца", ESP_Killer, function(s) ESP_Killer = s refreshESP() end)
addToggle("ESP Выжившие", ESP_Survivors, function(s) ESP_Survivors = s refreshESP() end)
addToggle("AUTO REPAIR", AutoRepairEnabled, function(s) AutoRepairEnabled = s applyAutoRepair() end)

-- ========== Запуск ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    pcall(killAntiCheatScripts, LocalPlayer.Character)
    applySpeed()
    applyInfiniteStamina()
    applyNoClip()
    applyAutoRepair()
    refreshESP()
end)

task.spawn(function()
    task.wait(1)
    pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
    applySpeed()
    applyInfiniteStamina()
    applyNoClip()
    applyAutoRepair()
    refreshESP()
end)

-- Обновление ESP каждую секунду
task.spawn(function()
    while task.wait(1) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v12.8 загружен | Улучшенный ESP Генераторов из Celeron + Auto Sprint")
