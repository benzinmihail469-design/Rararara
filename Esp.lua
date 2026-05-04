-- ============================================
-- BITE BY NIGHT v13.9 — Улучшенная версия (более скрытная + новые фичи)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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

-- ========== УЛУЧШЕННЫЙ МЕТОД СТАМИНЫ ==========
local function applyStamina()
    if connections.stamina then connections.stamina:Disconnect() end
    if not Settings.StaminaEnabled then return end

    connections.stamina = RunService.RenderStepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            -- Основные значения
            for _, name in ipairs({"Stamina", "SprintStamina", "Energy", "RunStamina", "CurrentStamina"}) do
                local val = hum:FindFirstChild(name) or char:FindFirstChild(name, true)
                if val and (val:IsA("NumberValue") or val:IsA("IntValue")) then
                    val.Value = 96 + math.random(0, 3)
                end
            end

            -- Атрибуты
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

-- ========== SPEED + FLY ==========
local bodyVelocity = nil

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

local function applyFly()
    if connections.fly then connections.fly:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end

    if not Settings.FlyEnabled then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
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

            bodyVelocity.Velocity = move.Unit * (Settings.SpeedValue * 2) or Vector3.new()
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
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end

-- ========== ANTI STUN + INFINITE JUMP ==========
local function applyAntiStun()
    if not Settings.AntiStunEnabled then return end
    task.spawn(function()
        while Settings.AntiStunEnabled and task.wait(0.3) do
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum:GetAttribute("Stunned") then hum:SetAttribute("Stunned", false) end
                    if hum.PlatformStand then hum.PlatformStand = false end
                end
            end)
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJumpEnabled then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- ========== AUTO REPAIR (умнее) ==========
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
                        if tick() - lastFireTime >= 0.12 then -- чуть реже
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

-- ========== ESP (оптимизированный) ==========
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
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bg

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 0.25
    hl.Parent = obj

    espObjects[obj] = {billboard = bg, highlight = hl, label = lbl}
end

local function updateESP()
    for obj, data in pairs(espObjects) do
        if not obj or not obj.Parent then
            pcall(function() data.billboard:Destroy() data.highlight:Destroy() end)
            espObjects[obj] = nil
        end
    end

    -- Generators
    if Settings.ESP_Generators then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("generator") or n:find("gen")) and not n:find("door") and not espObjects[obj] then
                createESP(obj, Color3.fromRGB(0, 255, 100), "⚡ GENERATOR")
            end
        end
    end

    -- Players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local char = plr.Character

        local isKiller = false
        local nameLower = (char.Name or ""):lower()
        local keywords = {"springtrap", "mimic", "ennard", "rotten", "doppel", "animatronic", "killer", "project"}

        for _, kw in ipairs(keywords) do
            if nameLower:find(kw) then isKiller = true break end
        end

        if Settings.ESP_Killer and isKiller then
            createESP(char, Color3.fromRGB(255, 40, 40), "🔪 KILLER")
        elseif Settings.ESP_Survivors and not isKiller then
            local dist = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            local txt = plr.Name
            if Settings.ESP_Distance then txt = txt .. string.format(" [%.0f]", dist) end
            createESP(char, Color3.fromRGB(80, 180, 255), txt)
        end
    end
end

-- ========== GUI (улучшенный) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "BiteByNight_v39"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 290, 0, 560)
mainFrame.Position = UDim2.new(1, -310, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 255, 170)
stroke.Thickness = 2.5

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 45)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🦇 BITE BY NIGHT v13.9"
title.TextColor3 = Color3.fromRGB(0, 255, 170)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Здесь добавь остальные элементы GUI (toggle, slider) аналогично твоему старому коду, но с использованием Settings.

-- Пример toggle функции (сокращённо)
local function addToggle(text, default, callback)
    -- ... (твой старый код, только вместо enabled используй Settings[ключ])
end

-- Запуск
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
    applyStamina()
    applyFly()
    applyNoClip()
    applyAntiStun()
    applyAutoRepair()
end)

task.defer(function()
    applySpeed()
    applyStamina()
    applyFly()
    applyNoClip()
    applyAntiStun()
    applyAutoRepair()
end)

task.spawn(function()
    while task.wait(0.8) do
        updateESP()
    end
end)

print("✅ BITE BY NIGHT v13.9 успешно загружен | Улучшенная скрытность и стабильность")

-- Чтобы добавить Fly, Anti-Stun, Infinite Jump — создай соответствующие toggles и привязывай к Settings.FlyEnabled = s; applyFly() и т.д.
