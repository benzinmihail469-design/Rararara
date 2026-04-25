-- ============================================
-- SPEEDHACK v12 – BiteByNight Edition
-- Обход античита + плавный GUI с дрейфом
-- erafox private protocol / tg @erafox
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Настройки
local SpeedEnabled = true
local SpeedValue = 35
local AntiCheatBlocked = true

-- Глобальный список нейтрализованных удалённых событий
local blockedRemotes = {}

-- ========== 1. Функция уничтожения античит-скриптов по маске ==========
local function killAntiCheatScripts(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local nameLow = (obj.Name or ""):lower()
            local src = (obj.Source or ""):lower()
            if nameLow:find("anti") or nameLow:find("cheat") or nameLow:find("bite") or
               src:find("walkspeed") or src:find("checkspeed") or src:find("speedhack") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- ========== 2. Блокировка RemoteEvent/Function, используемых для проверки ==========
local function hijackAntiCheatRemotes()
    local allRemotes = {}
    for _, service in ipairs({ReplicatedStorage, LocalPlayer:WaitForChild("PlayerScripts")}) do
        for _, remote in ipairs(service:GetDescendants()) do
            if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                table.insert(allRemotes, remote)
            end
        end
    end
    
    for _, remote in ipairs(allRemotes) do
        local remoteNameLow = (remote.Name or ""):lower()
        if remoteNameLow:find("check") or remoteNameLow:find("speed") or remoteNameLow:find("validate") or remoteNameLow:find("antihack") then
            blockedRemotes[remote] = true
            if remote:IsA("RemoteEvent") then
                -- Перехват вызова OnClientEvent
                local oldEvent = remote.OnClientEvent
                remote.OnClientEvent = function(self, ...)
                    -- Игнорируем проверки скорости
                    local args = {...}
                    if args[1] == "WalkSpeedCheck" or tostring(args[1]):find("speed") then
                        return
                    end
                    if oldEvent then oldEvent(...) end
                end
            elseif remote:IsA("RemoteFunction") then
                local oldInvoke = remote.OnClientInvoke
                remote.OnClientInvoke = function(...)
                    local args = {...}
                    if args[1] == "GetWalkSpeed" then return 16 end
                    if oldInvoke then return oldInvoke(...) else return nil end
                end
            end
        end
    end
end

-- ========== 3. Глобальный метатабличный перехват WalkSpeed ==========
pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    setreadonly(mt, false)
    
    -- Перехват чтения (для серверных проверок через GetPropertyChangedSignal)
    mt.__index = function(self, key)
        if key == "WalkSpeed" and type(self) == "userdata" and self:IsA("Humanoid") then
            return 16
        end
        return oldIndex(self, key)
    end
    
    -- Перехват записи (если античит пытается сбросить на 16)
    mt.__newindex = function(self, key, value)
        if key == "WalkSpeed" and type(self) == "userdata" and self:IsA("Humanoid") then
            if SpeedEnabled then
                -- Разрешаем установку от нашего кода
                rawset(self, key, value)
            else
                rawset(self, key, 16)
            end
            return
        end
        oldNewIndex(self, key, value)
    end
    
    setreadonly(mt, true)
end)

-- ========== 4. Основной цикл удержания скорости ==========
local speedConnection = nil
local function applySpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if not SpeedEnabled then
        pcall(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                end
            end
        end)
        return
    end
    
    speedConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= SpeedValue then
                    hum.WalkSpeed = SpeedValue
                end
                -- Дополнительно блокируем изменение от других скриптов
                if hum and hum:FindFirstChild("AntiSpeedReset") then
                    hum.AntiSpeedReset:Destroy()
                end
                local bind = Instance.new("BindableEvent")
                bind.Name = "AntiSpeedReset"
                bind.Parent = hum
                bind.Event:Connect(function()
                    hum.WalkSpeed = SpeedValue
                end)
                hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if hum.WalkSpeed ~= SpeedValue and hum.WalkSpeed ~= 16 then
                        hum.WalkSpeed = SpeedValue
                    end
                end)
            end
        end)
    end)
end

-- ========== 5. Маскировка GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "Erafox_SpeedPanel"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Прячем от стандартных детекторов: меняем имя каждый кадр (имитация динамики)
task.spawn(function()
    while gui and gui.Parent do
        task.wait(0.5)
        pcall(function()
            gui.Name = "Sys_" .. math.random(1000,9999)
        end)
    end
end)

-- Панель управления
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 80)
frame.Position = UDim2.new(1, -190, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 255, 100)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 8)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚡ SPEED: 35"
statusLabel.TextColor3 = Color3.fromRGB(0, 230, 0)
statusLabel.TextSize = 18
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 60, 0, 28)
toggle.Position = UDim2.new(0.5, -30, 0, 44)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggle.Text = "ВКЛ"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextSize = 14
toggle.Font = Enum.Font.GothamBold
toggle.AutoButtonColor = false
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Плавное появление
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
    BackgroundTransparency = 0.2
}):Play()

-- Перетаскивание (мышь/тач)
local dragging = false
local dragStart, startPos
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

-- Логика кнопки
toggle.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    toggle.Text = SpeedEnabled and "ВКЛ" or "ВЫКЛ"
    toggle.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(120, 0, 0)
    statusLabel.Text = SpeedEnabled and "⚡ SPEED: " .. SpeedValue or "⛔ SPEED: OFF"
    statusLabel.TextColor3 = SpeedEnabled and Color3.fromRGB(0, 230, 0) or Color3.fromRGB(200, 200, 200)
    applySpeed()
    TweenService:Create(toggle, TweenInfo.new(0.15), {Size = UDim2.new(0, 58, 0, 28)}):Play()
    task.wait(0.1)
    TweenService:Create(toggle, TweenInfo.new(0.1), {Size = UDim2.new(0, 60, 0, 28)}):Play()
end)

-- ========== 6. Обработка респавна и постоянная защита ==========
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    pcall(function()
        killAntiCheatScripts(character)
        killAntiCheatScripts(LocalPlayer.PlayerScripts)
        killAntiCheatScripts(game:GetService("StarterGui"))
        hijackAntiCheatRemotes()
        -- Повторное применение хуков на нового Humanoid
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SpeedEnabled and SpeedValue or 16
        end
    end)
    applySpeed()
end)

-- Первоначальный запуск
killAntiCheatScripts(LocalPlayer.PlayerScripts)
killAntiCheatScripts(game:GetService("StarterGui"))
hijackAntiCheatRemotes()
applySpeed()

-- Фоновый сканер (каждые 3 секунды чистим новые античит скрипты)
task.spawn(function()
    while true do
        task.wait(3)
        if AntiCheatBlocked then
            pcall(function()
                killAntiCheatScripts(LocalPlayer.PlayerScripts)
                killAntiCheatScripts(LocalPlayer.Character)
                hijackAntiCheatRemotes()
            end)
        end
    end
end)

print("erafox v12: BiteByNight anti-cheat bypass ACTIVE. Скорость удерживается.")
