-- ============================================
-- SPEEDHACK v12.1 – BiteByNight Edition (Fixed 2026)
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
local UseCFrameFallback = true  -- Самый стабильный метод в 2026

local connections = {}

-- ========== 1. Убийство подозрительных античит-скриптов ==========
local function killAntiCheatScripts(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local nameLow = (obj.Name or ""):lower()
            local src = (obj.Source or ""):lower()
            if nameLow:find("anti") or nameLow:find("cheat") or nameLow:find("bite") or
               nameLow:find("speedcheck") or src:find("walkspeed") or src:find("checkspeed") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- ========== 2. Простая блокировка подозрительных Remote ==========
local function hijackAntiCheatRemotes()
    for _, service in ipairs({ReplicatedStorage, LocalPlayer:WaitForChild("PlayerScripts", 5)}) do
        if not service then continue end
        for _, remote in ipairs(service:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local nameLow = (remote.Name or ""):lower()
                if nameLow:find("check") or nameLow:find("speed") or nameLow:find("validate") or nameLow:find("antihack") then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote.OnClientEvent:Connect(function(...) 
                                -- просто игнорируем speed-проверки
                            end)
                        elseif remote:IsA("RemoteFunction") then
                            local old = remote.OnClientInvoke
                            remote.OnClientInvoke = function(...)
                                local args = {...}
                                if tostring(args[1]):find("speed") or tostring(args[1]):find("getwalk") then
                                    return 16
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

-- ========== 3. Основная скорость (Heartbeat + CFrame fallback) ==========
local lastPos = nil
local speedConnection = nil

local function applySpeed()
    -- Отключаем старое соединение
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

    if not humanoid or not root then return end

    -- Классический способ (если античит слабый)
    pcall(function()
        humanoid.WalkSpeed = SpeedValue
    end)

    -- Основной цикл
    speedConnection = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            if not humanoid or not root or not SpeedEnabled then return end

            humanoid.WalkSpeed = SpeedValue

            -- CFrame fallback — работает когда WalkSpeed не помогает
            if UseCFrameFallback and humanoid.MoveDirection.Magnitude > 0 then
                if not lastPos then lastPos = root.Position end

                local moveVector = humanoid.MoveDirection * SpeedValue * dt * 1.05
                root.CFrame = root.CFrame + moveVector

                lastPos = root.Position
            end
        end)
    end)

    table.insert(connections, speedConnection)
end

-- ========== 4. Маскировка GUI (более тихая) ==========
local gui = Instance.new("ScreenGui")
gui.Name = "System_" .. math.random(10000, 99999)
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 90)
frame.Position = UDim2.new(1, -210, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 120)
stroke.Thickness = 1.5

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚡ SPEED: " .. SpeedValue
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.TextSize = 19
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 70, 0, 32)
toggle.Position = UDim2.new(0.5, -35, 0, 48)
toggle.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
toggle.Text = "ВКЛ"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextSize = 15
toggle.Font = Enum.Font.GothamBold
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

-- Плавное появление
TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.15}):Play()

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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Toggle
toggle.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    toggle.Text = SpeedEnabled and "ВКЛ" or "ВЫКЛ"
    toggle.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(140, 0, 0)
    statusLabel.Text = SpeedEnabled and "⚡ SPEED: " .. SpeedValue or "⛔ SPEED: OFF"
    statusLabel.TextColor3 = SpeedEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(180, 180, 180)

    applySpeed()
end)

-- ========== 5. Респавн + защита ==========
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    pcall(killAntiCheatScripts, char)
    pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
    pcall(hijackAntiCheatRemotes)
    applySpeed()
end)

-- Инициализация
task.spawn(function()
    task.wait(1)
    pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
    pcall(hijackAntiCheatRemotes)
    applySpeed()
end)

-- Фоновый cleaner (реже, чтобы не спамить)
task.spawn(function()
    while task.wait(4) do
        pcall(killAntiCheatScripts, LocalPlayer.PlayerScripts)
        pcall(killAntiCheatScripts, LocalPlayer.Character)
        pcall(hijackAntiCheatRemotes)
    end
end)

print("✅ erafox v12.1 BiteByNight — SpeedHack активирован (CFrame fallback включён)")
