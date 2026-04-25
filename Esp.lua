-- ============================================
-- BITE BY NIGHT v12.6 — ESP ПО МОДЕЛИ + ЛИДЕРБОРДУ
-- Убийца определяется надёжно, ESP снова работает
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Настройки
local SpeedEnabled = true
local SpeedValue = 35
local MaxSpeed = 50
local StaminaEnabled = true
local NoClipEnabled = false

local ESP_Generators = true
local ESP_Killer = true
local ESP_Survivors = true

local espObjects = {}

local speedConnection = nil
local noclipConnection = nil
local staminaConnection = nil

-- ========== Античит (оставлено) ==========
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

-- ========== Stamina, Speed, NoClip (без изменений) ==========
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
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("stamina") or v.Name:lower():find("energy")) then
                    v.Value = 100
                end
            end
        end)
    end)
end

local function applySpeed()
    if speedConnection then speedConnection:Disconnect() end
    if not SpeedEnabled then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = SpeedValue
    speedConnection = RunService.Heartbeat:Connect(function(dt)
        if not SpeedEnabled or not hum or not root then return end
        hum.WalkSpeed = SpeedValue
        if hum.MoveDirection.Magnitude > 0 then
            root.CFrame += hum.MoveDirection * SpeedValue * dt * 1.05
        end
    end)
end

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

-- ========== ESP ==========
local function createESP(obj, color, text)
    if espObjects[obj] then return end
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local bg = Instance.new("BillboardGui")
    bg.Adornee = root
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset
