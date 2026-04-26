-- ============================================
-- BITE BY NIGHT v12.9 — Speed как в Ringta + Auto Sprint
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Настройки
local SpeedEnabled = true
local SpeedValue = 28          -- стартовое значение (можно поднять до 40-55)
local MaxSpeed = 55
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

-- ========== SPEED КАК В RINGTA (улучшенный wall speed) ==========
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

            -- Улучшенное движение (более плавное и "wall-friendly" как в Ringta)
            if hum.MoveDirection.Magnitude > 0 then
                local moveVec = hum.MoveDirection * SpeedValue * dt * 1.05   -- чуть сильнее, чем раньше
                root.CFrame = root.CFrame + moveVec
                
                -- Дополнительный boost для прохождения стен (wall speed эффект)
                if NoClipEnabled then
                    root.Velocity = moveVec * 50   -- помогает "проталкиваться" сквозь стены
                end
            end
        end)
    end)
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

-- ========== AUTO REPAIR (без изменений) ==========
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
                        if currentTime - lastFireTime >= 0.1 then
                            pcall(function()
                                local args = {{ Wires = true, Switches = true, Lever = true }}
                                LocalPlayer.PlayerGui.Gen.GeneratorMain.Event:FireServer(unpack(args))
                            end)
                            lastFireTime = currentTime
                        end
                    end)
                end
            else
                if firingConnection then firingConnection:Disconnect() firingConnection = nil end
                lastFireTime = 0
            end
        end)
    end)
end

-- ========== ESP (исправленный) ==========
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

local function updateESP()
    for obj, _ in pairs(espObjects) do
        if not obj or not obj.Parent then removeESP(obj) end
    end

    if ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not obj.Parent then continue end
            local lowerName = obj.Name:lower()

            local isPotentialGen = lowerName:find("generator") or lowerName:find("gen") or lowerName:find("battery") or lowerName:find("powerbox") or lowerName:find("fusebox")

            if (obj:IsA("Model") or obj:IsA("Folder")) and isPotentialGen and not espObjects[obj] then
                local hasGenParts = obj:FindFirstChild("Wires") or obj:FindFirstChild("Lever") or obj:FindFirstChild("Switch") or lowerName:find("generator")
                if hasGenParts and not lowerName:find("door") and not lowerName:find("gate") and not lowerName:find("light") then
                    createESP(obj, Color3.fromRGB(0, 255, 100), "⚡ GENERATOR")
                end
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

-- ========== GUI (без изменений) ==========
-- ... (весь твой GUI код от создания ScreenGui до конца тогглов остаётся прежним)

-- (Чтобы не делать сообщение слишком длинным, вставь сюда весь GUI блок из своего последнего скрипта — от local gui = Instance.new("ScreenGui") до конца тогглов)

-- ========== ТОГГЛ SPEED (совмещённый) ==========
addToggle("SPEED + AUTO SPRINT (Ringta Style)", SpeedEnabled, function(s) 
    SpeedEnabled = s 
    applySpeed() 
end)

-- Остальные тогглы без изменений
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

task.spawn(function()
    while task.wait(1.2) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v12.9 загружен | Speed как в Ringta (улучшенный wall speed)")
