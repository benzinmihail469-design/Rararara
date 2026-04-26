-- ============================================
-- BITE BY NIGHT v12.8 — Infinite Sprint + ESP Генераторы
-- Улучшенный Anti-Cheat Bypass + Работа в Лобби
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Настройки
local InfiniteStaminaEnabled = true
local NoClipEnabled = false
local AutoRepairEnabled = false

local ESP_Generators = true
local ESP_Killer = true
local ESP_Survivors = true

local espObjects = {}
local staminaConnection = nil
local noclipConnection = nil
local autoRepairConnection = nil
local firingConnection = nil
local lastFireTime = 0

-- ========== УЛУЧШЕННЫЙ ANTI-CHEAT BYPASS ==========
local function killAntiCheatScripts()
    local containers = {LocalPlayer.PlayerScripts, LocalPlayer.Character, workspace, ReplicatedStorage, CoreGui, game:GetService("StarterPlayer").StarterPlayerScripts}
    
    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    local name = (obj.Name or ""):lower()
                    if name:find("anti") or name:find("cheat") or name:find("bite") or name:find("detect") or 
                       name:find("ac_") or name:find("ban") or name:find("kick") or name:find("stamina") or name:find("speed") then
                        pcall(function() 
                            obj:Destroy() 
                            if obj.Parent then obj.Parent = nil end
                        end)
                    end
                end
            end
        end
    end
    
    -- Дополнительно отключаем возможные Remote Events античита
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                if n:find("anti") or n:find("cheat") or n:find("detect") then
                    v:Destroy()
                end
            end
        end
    end)
end

-- ========== INFINITE SPRINT (Celeron Style) ==========
local function applyInfiniteStamina()
    if staminaConnection then staminaConnection:Disconnect() end
    if not InfiniteStaminaEnabled then return end

    staminaConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            -- Агрессивный сброс всех возможных значений стамины
            for _, name in ipairs({"Stamina", "SprintStamina", "Energy", "Fatigue", "StaminaValue", "SprintEnergy", "RunStamina"}) do
                if hum:GetAttribute(name) ~= nil then
                    hum:SetAttribute(name, 100)
                end
            end

            for _, v in ipairs(char:GetDescendants()) do
                if (v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("FloatValue")) and 
                   (v.Name:lower():find("stamina") or v.Name:lower():find("energy") or v.Name:lower():find("fatigue")) then
                    v.Value = 100
                end
            end

            if hum:GetAttribute("IsSprinting") ~= nil then hum:SetAttribute("IsSprinting", true) end
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
            local genGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Gen")
            if genGui and genGui:FindFirstChild("GeneratorMain") then
                if not firingConnection then
                    firingConnection = RunService.Heartbeat:Connect(function()
                        if not AutoRepairEnabled then return end
                        if tick() - lastFireTime >= 0.08 then
                            pcall(function()
                                local args = {{Wires = true, Switches = true, Lever = true}}
                                genGui.GeneratorMain.Event:FireServer(unpack(args))
                            end)
                            lastFireTime = tick()
                        end
                    end)
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
    local nameLower = (char.Name or ""):lower()
    if nameLower:find("springtrap") or nameLower:find("mimic") or nameLower:find("ennard") or nameLower:find("rotten") or 
       nameLower:find("doppel") or nameLower:find("animatronic") or nameLower:find("killer") then
        return true
    end
    return false
end

local function updateESP()
    for obj, _ in pairs(espObjects) do
        if not obj or not obj.Parent then removeESP(obj) end
    end

    if ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj.Parent then continue end
            local n = obj.Name:lower()
            if (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Part")) and 
               (n:find("generator") or n:find("gen") or n:find("battery") or n:find("power")) and not espObjects[obj] then
                createESP(obj, Color3.fromRGB(0, 255, 100), "⚡ GENERATOR")
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
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

-- ========== GUI (без изменений по высоте) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "BiteByNight_Hack"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 270, 0, 460)
mainFrame.Position = UDim2.new(1, -290, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 160)
Instance.new("UIStroke", mainFrame).Thickness = 2

-- (Остальная часть GUI остаётся такой же, как в предыдущей версии — минимизация, drag, тогглы и т.д.)

local minimized = false
local fullSize = mainFrame.Size
local collapsibleElements = {}

local function addCollapsible(element)
    table.insert(collapsibleElements, element)
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

-- Drag (оставлен без изменений)
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

-- Тогглы
addLabel("Infinite Sprint (Celeron Style)", Color3.fromRGB(0, 255, 120))
addToggle("INFINITE SPRINT", InfiniteStaminaEnabled, function(s) InfiniteStaminaEnabled = s applyInfiniteStamina() end)
addToggle("NOCLIP", NoClipEnabled, function(s) NoClipEnabled = s applyNoClip() end)
addToggle("ESP Генераторы", ESP_Generators, function(s) ESP_Generators = s refreshESP() end)
addToggle("ESP Убийца", ESP_Killer, function(s) ESP_Killer = s refreshESP() end)
addToggle("ESP Выжившие", ESP_Survivors, function(s) ESP_Survivors = s refreshESP() end)
addToggle("AUTO REPAIR", AutoRepairEnabled, function(s) AutoRepairEnabled = s applyAutoRepair() end)

-- ========== ЗАПУСК (работает в лобби + при респавне) ==========
killAntiCheatScripts()  -- сразу при загрузке

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    killAntiCheatScripts()
    applyInfiniteStamina()
    applyNoClip()
    applyAutoRepair()
    refreshESP()
end)

-- Запуск в лобби и при первом появлении
task.spawn(function()
    task.wait(0.8)
    killAntiCheatScripts()
    applyInfiniteStamina()
    applyNoClip()
    applyAutoRepair()
    refreshESP()
end)

-- Постоянное обновление ESP
task.spawn(function()
    while task.wait(0.8) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v12.8 загружен | Улучшенный Anti-Cheat Bypass + Работа в Лобби")
