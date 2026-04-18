--[[
    ESP для Bite By Night - Corner Box + поддержка Model + Speed 40 + Infinite Stamina
    Зелёные уголки = Убийца, Красные уголки = Выжившие
    ОПТИМИЗИРОВАННАЯ ВЕРСИЯ С ОБХОДОМ АНТИЧИТА
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Хранилище ESP
local ESPObjects = {}

-- Настройки
local Settings = {
    -- ESP
    Enabled = true,
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    Thickness = 2.5,
    CornerSize = 12,
    MaxDistance = 1500, -- Уменьшено для оптимизации
    
    -- Speed
    SpeedEnabled = false,
    SpeedValue = 40, -- Увеличено до 40
    
    -- Stamina
    StaminaEnabled = false
}

-- ==================== ОПТИМИЗИРОВАННЫЕ ФУНКЦИИ ДЛЯ МОДЕЛЕЙ ====================

local function GetRootPart(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    return model.PrimaryPart
end

local function GetHead(model)
    if not model then return nil end
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    return nil
end

local function GetHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ (ОПТИМИЗИРОВАНО) ====================

local CurrentKiller = nil
local lastKillerCheck = 0

local function FindKiller()
    -- Проверяем не чаще раза в секунду
    if tick() - lastKillerCheck < 1 then
        return CurrentKiller
    end
    lastKillerCheck = tick()
    
    -- Быстрая проверка через PlayerGui
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pgui = p:FindFirstChild("PlayerGui")
            if pgui then
                for _, g in ipairs(pgui:GetDescendants()) do
                    if g:IsA("TextLabel") and g.Text:lower():find("killer") then
                        CurrentKiller = p
                        return p
                    end
                end
            end
        end
    end
    return CurrentKiller
end

-- ==================== DRAWING ОБЪЕКТЫ (ОПТИМИЗИРОВАНО) ====================

local function CreateDrawing(className, properties)
    local s, d = pcall(function()
        return Drawing.new(className)
    end)
    if s and d then
        for k, v in pairs(properties) do
            pcall(function() d[k] = v end)
        end
        return d
    end
    return nil
end

local function ClearESP(player)
    if ESPObjects[player] then
        for _, d in pairs(ESPObjects[player]) do
            pcall(function() d:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- ==================== СОЗДАНИЕ CORNER BOX (ОПТИМИЗИРОВАНО) ====================

local function CreateCornerBox(player, isKiller)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    ClearESP(player)
    
    local color = isKiller and Settings.KillerColor or Settings.SurvivorColor
    local thick = isKiller and Settings.Thickness + 1 or Settings.Thickness
    
    local drawings = {}
    
    -- Создаём только 4 линии вместо 8 для оптимизации
    drawings.TL = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.TR = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.BL = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.BR = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    
    ESPObjects[player] = drawings
end

-- ==================== ОБНОВЛЕНИЕ ВСЕХ КОНТУРОВ ====================

local function UpdateAllOutlines()
    CurrentKiller = FindKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            CreateCornerBox(p, p == CurrentKiller)
        end
    end
end

-- ==================== ОБНОВЛЕНИЕ ПОЗИЦИЙ (ОПТИМИЗИРОВАНО) ====================

local function UpdatePositions()
    if not Settings.Enabled then
        for _, data in pairs(ESPObjects) do
            for _, d in pairs(data) do d.Visible = false end
        end
        return
    end
    
    local cameraPos = Camera.CFrame.Position
    
    for player, data in pairs(ESPObjects) do
        local model = player.Character
        if not model then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local root = GetRootPart(model)
        local head = GetHead(model)
        if not root or not head then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        -- Быстрая проверка дистанции
        if (cameraPos - root.Position).Magnitude > Settings.MaxDistance then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
        local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2, 0))
        
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height / 2.2
        local x = rootPos.X - width/2
        local y = headPos.Y
        local cs = Settings.CornerSize
        
        -- Упрощённые уголки (L-образные)
        data.TL.Visible = true
        data.TL.From = Vector2.new(x, y + cs)
        data.TL.To = Vector2.new(x, y)
        
        data.TR.Visible = true
        data.TR.From = Vector2.new(x + width - cs, y)
        data.TR.To = Vector2.new(x + width, y)
        
        data.BL.Visible = true
        data.BL.From = Vector2.new(x, y + height - cs)
        data.BL.To = Vector2.new(x, y + height)
        
        data.BR.Visible = true
        data.BR.From = Vector2.new(x + width - cs, y + height)
        data.BR.To = Vector2.new(x + width, y + height)
    end
end

-- ==================== ОБХОД АНТИЧИТА ДЛЯ СКОРОСТИ ====================
local speedBypass = nil

local function UpdateSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    if not humanoid then return end
    
    if Settings.SpeedEnabled then
        humanoid.WalkSpeed = Settings.SpeedValue
        
        if not speedBypass then
            speedBypass = hookmetamethod(game, "__index", function(self, key)
                if self == humanoid and key == "WalkSpeed" then
                    return 16
                end
                return speedBypass(self, key)
            end)
        end
    else
        if speedBypass then
            pcall(function() speedBypass = nil end)
        end
        humanoid.WalkSpeed = 16
    end
end

-- ==================== ОБХОД АНТИЧИТА ДЛЯ СТАМИНЫ ====================
local staminaBypass = nil
local staminaLoop = nil

local function EnableInfiniteStamina()
    if staminaBypass then pcall(function() staminaBypass = nil end) end
    if staminaLoop then staminaLoop:Disconnect() end
    
    staminaBypass = hookmetamethod(game, "__index", function(self, key)
        if self == LocalPlayer and (key == "Stamina" or key == "stamina" or key == "Energy" or key == "energy") then
            return 100
        end
        return staminaBypass(self, key)
    end)
    
    staminaLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("Energy", 100)
        end)
    end)
end

local function DisableInfiniteStamina()
    if staminaLoop then staminaLoop:Disconnect(); staminaLoop = nil end
    if staminaBypass then pcall(function() staminaBypass = nil end) end
end

local function UpdateStamina()
    if Settings.StaminaEnabled then
        EnableInfiniteStamina()
    else
        DisableInfiniteStamina()
    end
end

-- ==================== ОПТИМИЗИРОВАННЫЙ ЗАПУСК ====================

-- Медленное обновление (раз в 2 секунды)
task.spawn(function()
    while true do
        UpdateAllOutlines()
        task.wait(2)
    end
end)

-- Среднее обновление скорости
task.spawn(function()
    while true do
        if Settings.SpeedEnabled then
            UpdateSpeed()
        end
        task.wait(0.5)
    end
end)

-- Быстрое обновление ESP позиций
RunService.RenderStepped:Connect(UpdatePositions)

-- Обработчики игроков
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() 
        task.wait(0.5) 
        UpdateAllOutlines() 
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
    if p == CurrentKiller then CurrentKiller = nil end
end)

-- Запуск для текущих
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character then 
        task.wait(0.5) 
        UpdateAllOutlines() 
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateSpeed()
    if Settings.StaminaEnabled then
        EnableInfiniteStamina()
    end
end)

-- ==================== GUI ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Speed_Stamina_Opt"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 190)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "ESP + Speed 40 + Stamina"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Killer: Searching..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

-- Кнопка ESP
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.8, 0, 0, 30)
EspBtn.Position = UDim2.new(0.1, 0, 0, 65)
EspBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
EspBtn.Text = "ESP: ON"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.TextSize = 13
EspBtn.Font = Enum.Font.Gotham
EspBtn.AutoButtonColor = false
EspBtn.Parent = Frame

Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

EspBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    EspBtn.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
    EspBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Кнопка Speed
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.8, 0, 0, 30)
SpeedBtn.Position = UDim2.new(0.1, 0, 0, 105)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
SpeedBtn.Text = "Speed: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 13
SpeedBtn.Font = Enum.Font.Gotham
SpeedBtn.AutoButtonColor = false
SpeedBtn.Parent = Frame

Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Settings.SpeedEnabled = not Settings.SpeedEnabled
    SpeedBtn.Text = Settings.SpeedEnabled and "Speed: 40" or "Speed: OFF"
    SpeedBtn.BackgroundColor3 = Settings.SpeedEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    UpdateSpeed()
end)

-- Кнопка Stamina
local StaminaBtn = Instance.new("TextButton")
StaminaBtn.Size = UDim2.new(0.8, 0, 0, 30)
StaminaBtn.Position = UDim2.new(0.1, 0, 0, 145)
StaminaBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StaminaBtn.Text = "Stamina: OFF"
StaminaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StaminaBtn.TextSize = 13
StaminaBtn.Font = Enum.Font.Gotham
StaminaBtn.AutoButtonColor = false
StaminaBtn.Parent = Frame

Instance.new("UICorner", StaminaBtn).CornerRadius = UDim.new(0, 6)

StaminaBtn.MouseButton1Click:Connect(function()
    Settings.StaminaEnabled = not Settings.StaminaEnabled
    StaminaBtn.Text = Settings.StaminaEnabled and "Stamina: ON" or "Stamina: OFF"
    StaminaBtn.BackgroundColor3 = Settings.StaminaEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    UpdateStamina()
end)

-- Информация
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 20)
Info.Position = UDim2.new(0, 0, 0, 180)
Info.BackgroundTransparency = 1
Info.Text = "🟢 Killer  |  🔴 Survivor"
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 11
Info.Font = Enum.Font.Gotham
Info.Parent = Frame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Frame

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function()
    DisableInfiniteStamina()
    ScreenGui:Destroy()
end)

Status.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpdateAllOutlines()
    end
end)

task.spawn(function()
    while true do
        if CurrentKiller then
            Status.Text = "Killer: " .. CurrentKiller.Name
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            Status.Text = "Killer: Searching..."
            Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        task.wait(1)
    end
end)

print("ESP + Speed 40 + Infinite Stamina loaded! (Optimized + Anti-Cheat Bypass)")
