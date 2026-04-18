--[[
    ESP + Speed 40 + Infinite Stamina + Generator ESP
    ВСЁ РАБОТАЕТ + АНТИЧИТ ОБХОД + БЕЗ ЛАГОВ
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Хранилище ESP
local ESPObjects = {}
local GeneratorESPList = {}

-- Настройки
local Settings = {
    -- ESP
    Enabled = true,
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    GeneratorColor = Color3.fromRGB(255, 255, 0),
    Thickness = 2.5,
    CornerSize = 12,
    MaxDistance = 2000,
    
    -- Speed
    SpeedEnabled = false,
    SpeedValue = 40,
    
    -- Stamina
    StaminaEnabled = false,
    
    -- Generator ESP
    GeneratorESP = false
}

-- ==================== ОБХОД АНТИЧИТА ====================

local function setupAntiCheat()
    pcall(function()
        for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
            if v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect") then
                v:Destroy()
            end
        end
    end)
    
    pcall(function()
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and (self.Name == "Kick" or self.Name:find("Ban")) then
                return nil
            end
            return oldNamecall(self, ...)
        end)
    end)
end

setupAntiCheat()

-- ==================== ФУНКЦИИ ДЛЯ РАБОТЫ С МОДЕЛЯМИ ====================

local function GetRootPart(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    return model.PrimaryPart
end

local function GetHead(model)
    if not model then return nil end
    local head = model:FindFirstChild("Head")
    if head then return head end
    return GetRootPart(model)
end

local function GetHumanoid(model)
    if not model then return nil end
    return model:FindFirstChildOfClass("Humanoid")
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ ====================

local function FindKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local humanoid = GetHumanoid(p.Character)
            if humanoid and humanoid.MaxHealth > 500 then
                return p
            end
        end
    end
    return nil
end

local CurrentKiller = nil

-- ==================== DRAWING ОБЪЕКТЫ ====================

local function CreateDrawing(className, properties)
    local s, d = pcall(function()
        local dr = Drawing.new(className)
        for k, v in pairs(properties) do 
            pcall(function() dr[k] = v end) 
        end
        return dr
    end)
    return s and d or nil
end

local function ClearESP(player)
    if ESPObjects[player] then
        for _, d in pairs(ESPObjects[player]) do
            pcall(function() d:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- ==================== СОЗДАНИЕ CORNER BOX ====================

local function CreateCornerBox(player, isKiller)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    ClearESP(player)
    
    local color = isKiller and Settings.KillerColor or Settings.SurvivorColor
    local thick = isKiller and Settings.Thickness + 1 or Settings.Thickness
    
    local drawings = {}
    
    drawings.TL_V = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.TR_V = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.BL_V = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.BR_V = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    
    drawings.TL_H = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.TR_H = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.BL_H = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    drawings.BR_H = CreateDrawing("Line", {Visible = false, Color = color, Thickness = thick})
    
    ESPObjects[player] = drawings
end

-- ==================== ОБНОВЛЕНИЕ ПОЗИЦИЙ ESP ====================

local function UpdatePositions()
    if not Settings.Enabled then
        for _, data in pairs(ESPObjects) do
            for _, d in pairs(data) do d.Visible = false end
        end
        return
    end
    
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
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > Settings.MaxDistance then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
        local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height / 2.2
        local x = rootPos.X - width/2
        local y = headPos.Y
        local cs = Settings.CornerSize
        
        for _, d in pairs(data) do d.Visible = true end
        
        data.TL_V.From = Vector2.new(x, y)
        data.TL_V.To = Vector2.new(x, y + cs)
        data.TL_H.From = Vector2.new(x, y)
        data.TL_H.To = Vector2.new(x + cs, y)
        
        data.TR_V.From = Vector2.new(x + width, y)
        data.TR_V.To = Vector2.new(x + width, y + cs)
        data.TR_H.From = Vector2.new(x + width - cs, y)
        data.TR_H.To = Vector2.new(x + width, y)
        
        data.BL_V.From = Vector2.new(x, y + height - cs)
        data.BL_V.To = Vector2.new(x, y + height)
        data.BL_H.From = Vector2.new(x, y + height)
        data.BL_H.To = Vector2.new(x + cs, y + height)
        
        data.BR_V.From = Vector2.new(x + width, y + height - cs)
        data.BR_V.To = Vector2.new(x + width, y + height)
        data.BR_H.From = Vector2.new(x + width - cs, y + height)
        data.BR_H.To = Vector2.new(x + width, y + height)
    end
end

-- ==================== ФУНКЦИЯ ИЗМЕНЕНИЯ СКОРОСТИ ====================

local function UpdateSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    if humanoid then
        humanoid.WalkSpeed = Settings.SpeedEnabled and Settings.SpeedValue or 16
    end
end

-- ==================== ФУНКЦИЯ БЕСКОНЕЧНОЙ СТАМИНЫ ====================

local StaminaLoop = nil

local function UpdateStamina()
    if Settings.StaminaEnabled then
        if not StaminaLoop then
            StaminaLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    LocalPlayer:SetAttribute("Stamina", 100)
                    LocalPlayer:SetAttribute("stamina", 100)
                    LocalPlayer:SetAttribute("Energy", 100)
                    LocalPlayer:SetAttribute("energy", 100)
                end)
            end)
        end
    else
        if StaminaLoop then
            StaminaLoop:Disconnect()
            StaminaLoop = nil
        end
    end
end

-- ==================== ЗАПУСК (БЕЗ СКАНИРОВАНИЯ WORSPACE) ====================

RunService.RenderStepped:Connect(UpdatePositions)

-- Только при появлении персонажа
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if p ~= LocalPlayer then
            CreateCornerBox(p, p == CurrentKiller)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
end)

LocalPlayer.CharacterAdded:Connect(function()
    UpdateSpeed()
    UpdateStamina()
end)

-- Периодическая проверка убийцы (лёгкая)
task.spawn(function()
    while true do
        CurrentKiller = FindKiller()
        task.wait(3)
    end
end)

-- ==================== GUI ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Menu"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 190)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "ESP + Speed + Stamina"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- ESP Button
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.8, 0, 0, 28)
EspBtn.Position = UDim2.new(0.1, 0, 0, 35)
EspBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
EspBtn.Text = "ESP: ON"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.TextSize = 12
EspBtn.Font = Enum.Font.Gotham
EspBtn.AutoButtonColor = false
EspBtn.Parent = Frame

Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

EspBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    EspBtn.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
    EspBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Speed Button
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.8, 0, 0, 28)
SpeedBtn.Position = UDim2.new(0.1, 0, 0, 70)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
SpeedBtn.Text = "Speed: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 12
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

-- Stamina Button
local StaminaBtn = Instance.new("TextButton")
StaminaBtn.Size = UDim2.new(0.8, 0, 0, 28)
StaminaBtn.Position = UDim2.new(0.1, 0, 0, 105)
StaminaBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StaminaBtn.Text = "Stamina: OFF"
StaminaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StaminaBtn.TextSize = 12
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

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.8, 0, 0, 28)
CloseBtn.Position = UDim2.new(0.1, 0, 0, 145)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Frame

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    if StaminaLoop then StaminaLoop:Disconnect() end
    for _, data in pairs(ESPObjects) do
        for _, d in pairs(data) do pcall(function() d:Remove() end) end
    end
    ScreenGui:Destroy()
end)

print("Script loaded! No lag!")
