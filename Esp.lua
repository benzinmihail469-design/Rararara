-- ============================================
-- SPEEDHACK + INFINITE STAMINA v12.2 – BiteByNight Edition (2026)
-- erafox private protocol
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local SpeedEnabled = true
local SpeedValue = 35
local StaminaEnabled = true
local UseCFrameFallback = true

local connections = {}

-- ========== 1. Убийство античит-скриптов ==========
local function killAntiCheatScripts(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local nameLow = (obj.Name or ""):lower()
            local src = (obj.Source or ""):lower()
            if nameLow:find("anti") or nameLow:find("cheat") or nameLow:find("bite") or
               nameLow:find("speedcheck") or src:find("walkspeed") or src:find("stamina") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- ========== 2. Блокировка подозрительных Remote ==========
local function hijackAntiCheatRemotes()
    for _, service in ipairs({ReplicatedStorage, LocalPlayer:WaitForChild("PlayerScripts", 5)}) do
        if not service then continue end
        for _, remote in ipairs(service:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local nameLow = (remote.Name or ""):lower()
                if nameLow:find("check") or nameLow:find("speed") or nameLow:find("stamina") or nameLow:find("validate") then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote.OnClientEvent:Connect(function() end)
                        elseif remote:IsA("RemoteFunction") then
                            local old = remote.OnClientInvoke
                            remote.OnClientInvoke = function(...)
                                local args = {...}
                                if tostring(args[1]):find("stamina") or tostring(args[1]):find("speed") then
                                    return 100
                                end
                                return old and old(...) or nil
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- ========== 3. Бесконечная стамина ==========
local staminaConnection = nil

local function applyInfiniteStamina()
    if staminaConnection then
        pcall(function() staminaConnection:Disconnect() end)
    end

    if not StaminaEnabled then return end

    staminaConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end

            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Основные возможные названия атрибутов в Bite By Night
                for _, attrName in ipairs({"Stamina", "SprintStamina", "Energy", "Fatigue", "StaminaValue"}) do
                    if humanoid:GetAttribute(attrName) then
                        humanoid:SetAttribute(attrName, 100)
                    end
                end
            end

            -- Проверка внутри Character (Values / NumberValues)
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local nameLow = v.Name:lower()
                    if nameLow:find("stamina") or nameLow:find("energy") or nameLow:find("fatigue") then
                        v.Value = 100
                    end
                end
            end
        end)
    end)

    table.insert(connections, staminaConnection)
end

-- ========== 4. Скорость (оставил как в прошлой версии) ==========
local function applySpeed()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
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

    local speedConn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            if not humanoid or not root or not SpeedEnabled then return end
            humanoid.WalkSpeed = SpeedValue

            if UseCFrameFallback and humanoid.MoveDirection.Magnitude > 0 then
                local moveVector = humanoid.MoveDirection * SpeedValue * dt * 1.05
                root.CFrame = root.CFrame + moveVector
            end
        end)
    end)

    table.insert(connections, speedConn)
end

-- ========== 5. GUI (добавлены кнопки для стамины) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "System_" .. math.random(10000,99999)
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 130)
frame.Position = UDim2.new(1, -230, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 140)
stroke.Thickness = 1.6

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🦇 BITE BY NIGHT HACK"
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 35)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ SPEED: " .. SpeedValue
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
speedLabel.TextSize = 18
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = frame

local staminaLabel = Instance.new("TextLabel")
staminaLabel.Size = UDim2.new(1, 0, 0, 25)
staminaLabel.Position = UDim2.new(0, 0, 0, 60)
staminaLabel.BackgroundTransparency = 1
staminaLabel.Text = "♾️ STAMINA: ON"
staminaLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
staminaLabel.TextSize = 18
staminaLabel.Font = Enum.Font.GothamBold
staminaLabel.Parent = frame

-- Кнопка скорости
local btnSpeed = Instance.new("TextButton")
btnSpeed.Size = UDim2.new(0.45, 0, 0, 32)
btnSpeed.Position = UDim2.new(0.03, 0, 0, 90)
btnSpeed.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
btnSpeed.Text = "SPEED ON"
btnSpeed.TextColor3 = Color3.new(1,1,1)
btnSpeed.TextSize = 14
btnSpeed.Font = Enum.Font.GothamBold
btnSpeed.Parent = frame
Instance.new("UICorner", btnSpeed).CornerRadius = UDim.new(0, 8)

-- Кнопка стамины
local btnStamina = Instance.new("TextButton")
btnStamina.Size = UDim2.new(0.45, 0, 0, 32)
btnStamina.Position = UDim2.new(0.52, 0, 0, 90)
btnStamina.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
btnStamina.Text = "STAMINA ON"
btnStamina.TextColor3 = Color3.new(1,1,1)
btnStamina.TextSize = 14
btnStamina.Font = Enum.Font.GothamBold
btnStamina.Parent = frame
Instance.new("UICorner", btnStamina).CornerRadius = UDim.new(0, 8)

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

-- Логика кнопок
btnSpeed.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    btnSpeed.Text = SpeedEnabled and "SPEED ON" or "SPEED OFF"
    btnSpeed.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(140, 0, 0)
    speedLabel.Text = SpeedEnabled and "⚡ SPEED: " .. SpeedValue or "⚡ SPEED: OFF"
    applySpeed()
end)

btnStamina.MouseButton1Click:Connect(function()
    StaminaEnabled = not StaminaEnabled
    btnStamina.Text = StaminaEnabled and "STAMINA ON" or "STAMINA OFF"
    btnStamina.BackgroundColor3 = StaminaEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(140, 0, 0)
    staminaLabel.Text = StaminaEnabled and "♾️ STAMINA: ON" or "♾️ STAMINA: OFF"
    staminaLabel.TextColor3 = StaminaEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(180, 180, 180)
    applyInfiniteStamina()
end)

-- ========== 6. Респавн и запуск ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)
    pcall(killAntiCheatScripts, LocalPlayer.Character)
    pcall(hijackAntiCheatRemotes)
    applySpeed()
    applyInfiniteStamina()
end)

task.spawn(function()
    task.wait(1)
    pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
    pcall(hijackAntiCheatRemotes)
    applySpeed()
    applyInfiniteStamina()
end)

-- Фоновый cleaner
task.spawn(function()
    while task.wait(5) do
        pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
        pcall(killAntiCheatScripts, LocalPlayer.Character)
        pcall(hijackAntiCheatRemotes)
    end
end)

print("✅ erafox v12.2 | Speed + Infinite Stamina для Bite By Night — активировано")
