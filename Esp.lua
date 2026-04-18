--[[
    ESP + Speed 40 + Infinite Stamina + Generator ESP
    ВСЁ РАБОТАЕТ + АНТИЧИТ ОБХОД
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
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

-- ==================== ОБХОД АНТИЧИТА (ИЗ УКАЗАННОГО СКРИПТА) ====================

local function setupAntiCheat()
    -- Удаление античит-скриптов
    for _, v in ipairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect") or v.Name:find("Ban") then
            v:Destroy()
        end
    end
    
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect") or v.Name:find("Ban") then
            v:Destroy()
        end
    end
    
    -- Hook для обхода проверок
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Блокировка kick-событий
        if method == "FireServer" and self.Name == "Kick" then
            return nil
        end
        
        -- Блокировка бан-событий
        if method == "FireServer" and (self.Name:find("Ban") or self.Name:find("Kick")) then
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Hook для защиты свойств
    local oldIndex = hookmetamethod(game, "__index", function(self, key)
        if self == LocalPlayer then
            if key == "Stamina" or key == "stamina" or key == "Energy" or key == "energy" or key == "WalkSpeed" then
                if key == "WalkSpeed" then
                    return 16
                end
                return 100
            end
        end
        return oldIndex(self, key)
    end)
end

setupAntiCheat()

-- ==================== ФУНКЦИИ ДЛЯ РАБОТЫ С МОДЕЛЯМИ ====================

local function GetRootPart(model)
    if not model then return nil end
    
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("torso") then
            return part
        end
    end
    
    local biggest = nil
    local biggestSize = 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local size = part.Size.X + part.Size.Y + part.Size.Z
            if size > biggestSize then
                biggestSize = size
                biggest = part
            end
        end
    end
    return biggest or model.PrimaryPart
end

local function GetHead(model)
    if not model then return nil end
    
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("head") then
            return part
        end
    end
    
    local highest = nil
    local highestY = -math.huge
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Position.Y > highestY then
                highestY = part.Position.Y
                highest = part
            end
        end
    end
    return highest
end

local function GetHealth(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then return humanoid.Health, humanoid.MaxHealth end
    
    local healthVal = model:FindFirstChild("Health") or model:FindFirstChild("HP")
    if healthVal and (healthVal:IsA("IntValue") or healthVal:IsA("NumberValue")) then
        return healthVal.Value, healthVal.Value
    end
    
    return 100, 100
end

local function GetHumanoid(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then return humanoid end
    
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("Humanoid") then
            return child
        end
    end
    
    return nil
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ ====================

local function FindKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local model = p.Character
            if model then
                local _, maxHP = GetHealth(model)
                if maxHP > 500 then return p end
                
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("Tool") then
                        local n = child.Name:lower()
                        if n:find("remnant") or n:find("cleaver") or n:find("beartrap") then
                            return p
                        end
                    end
                end
            end
        end
    end
    return nil
end

local CurrentKiller = nil

-- ==================== ПОИСК ГЕНЕРАТОРОВ (МОДЕЛЬКИ) ====================

local function FindGenerators()
    local generators = {}
    
    -- Ищем модели с генераторами
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("generator") or name:find("gen") then
                table.insert(generators, obj)
            end
        end
    end
    
    -- Ищем по ProximityPrompt
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent then
                local name = parent.Name:lower()
                if name:find("generator") or name:find("gen") then
                    local found = false
                    for _, g in ipairs(generators) do
                        if g == parent then found = true; break end
                    end
                    if not found then
                        table.insert(generators, parent)
                    end
                end
            end
        end
    end
    
    return generators
end

-- ==================== DRAWING ОБЪЕКТЫ ====================

local function CreateDrawing(className, properties)
    local s, d = pcall(function()
        local dr = Drawing.new(className)
        for k, v in pairs(properties) do pcall(function() dr[k] = v end) end
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

local function ClearGeneratorESP(id)
    if GeneratorESPList[id] then
        for _, d in pairs(GeneratorESPList[id]) do
            pcall(function() d:Remove() end)
        end
        GeneratorESPList[id] = nil
    end
end

-- ==================== СОЗДАНИЕ CORNER BOX ДЛЯ ИГРОКОВ ====================

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

-- ==================== СОЗДАНИЕ ESP ДЛЯ ГЕНЕРАТОРА ====================

local function CreateGeneratorESP(generator)
    local id = generator:GetFullName()
    
    local box = CreateDrawing("Square", {
        Visible = false,
        Color = Settings.GeneratorColor,
        Thickness = 2,
        Filled = false
    })
    
    local name = CreateDrawing("Text", {
        Visible = false,
        Text = "GENERATOR",
        Color = Settings.GeneratorColor,
        Size = 14,
        Center = true,
        Outline = true
    })
    
    if box and name then
        GeneratorESPList[id] = {Box = box, Name = name, Generator = generator}
    end
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

-- ==================== ОБНОВЛЕНИЕ ПОЗИЦИЙ ESP ====================

local function UpdatePositions()
    if not Settings.Enabled then
        for _, data in pairs(ESPObjects) do
            for _, d in pairs(data) do d.Visible = false end
        end
        for _, data in pairs(GeneratorESPList) do
            data.Box.Visible = false
            data.Name.Visible = false
        end
        return
    end
    
    -- Обновление ESP игроков
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
        
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y/2, 0))
        local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, root.Size.Y/2, 0))
        
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
    
    -- Обновление ESP генераторов
    if Settings.GeneratorESP then
        local generators = FindGenerators()
        
        -- Создаём ESP для новых генераторов
        for _, gen in ipairs(generators) do
            local id = gen:GetFullName()
            if not GeneratorESPList[id] then
                CreateGeneratorESP(gen)
            end
        end
        
        -- Обновляем позиции
        for id, data in pairs(GeneratorESPList) do
            local gen = data.Generator
            if not gen or not gen.Parent then
                data.Box.Visible = false
                data.Name.Visible = false
                continue
            end
            
            -- Находим корневую часть
            local root = gen:FindFirstChild("Base") or gen:FindFirstChildOfClass("BasePart") or gen.PrimaryPart
            if not root then
                for _, part in ipairs(gen:GetDescendants()) do
                    if part:IsA("BasePart") then
                        root = part
                        break
                    end
                end
            end
            
            if not root then
                data.Box.Visible = false
                data.Name.Visible = false
                continue
            end
            
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if dist > Settings.MaxDistance then
                data.Box.Visible = false
                data.Name.Visible = false
                continue
            end
            
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then
                data.Box.Visible = false
                data.Name.Visible = false
                continue
            end
            
            local size = root.Size
            local height = size.Y * 150 / dist
            local width = size.X * 150 / dist
            
            data.Box.Visible = true
            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
            
            data.Name.Visible = true
            data.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 20)
        end
    else
        -- Скрываем все генераторы если ESP выключен
        for _, data in pairs(GeneratorESPList) do
            data.Box.Visible = false
            data.Name.Visible = false
        end
    end
end

-- ==================== ФУНКЦИЯ ИЗМЕНЕНИЯ СКОРОСТИ ====================

local function UpdateSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    if humanoid then
        if Settings.SpeedEnabled then
            humanoid.WalkSpeed = Settings.SpeedValue
        else
            humanoid.WalkSpeed = 16
        end
    end
end

-- ==================== ФУНКЦИЯ БЕСКОНЕЧНОЙ СТАМИНЫ ====================

local StaminaLoop = nil

local function EnableInfiniteStamina()
    if StaminaLoop then StaminaLoop:Disconnect() end
    
    StaminaLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("stamina", 100)
            LocalPlayer:SetAttribute("Energy", 100)
            LocalPlayer:SetAttribute("energy", 100)
            LocalPlayer:SetAttribute("Endurance", 100)
            LocalPlayer:SetAttribute("endurance", 100)
        end)
    end)
end

local function DisableInfiniteStamina()
    if StaminaLoop then
        StaminaLoop:Disconnect()
        StaminaLoop = nil
    end
end

local function UpdateStamina()
    if Settings.StaminaEnabled then
        EnableInfiniteStamina()
    else
        DisableInfiniteStamina()
    end
end

-- ==================== ЗАПУСК ====================

task.spawn(function()
    while true do
        UpdateAllOutlines()
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if Settings.SpeedEnabled then
            UpdateSpeed()
        end
        task.wait(0.5)
    end
end)

RunService.RenderStepped:Connect(UpdatePositions)

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
ScreenGui.Name = "ESP_Speed_Stamina_Gen"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 220)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "ESP + Speed + Stamina"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Killer: Searching..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

-- Кнопка ESP
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.8, 0, 0, 28)
EspBtn.Position = UDim2.new(0.1, 0, 0, 60)
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

-- Кнопка Generator ESP
local GenBtn = Instance.new("TextButton")
GenBtn.Size = UDim2.new(0.8, 0, 0, 28)
GenBtn.Position = UDim2.new(0.1, 0, 0, 93)
GenBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
GenBtn.Text = "Generator: OFF"
GenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GenBtn.TextSize = 12
GenBtn.Font = Enum.Font.Gotham
GenBtn.AutoButtonColor = false
GenBtn.Parent = Frame

Instance.new("UICorner", GenBtn).CornerRadius = UDim.new(0, 6)

GenBtn.MouseButton1Click:Connect(function()
    Settings.GeneratorESP = not Settings.GeneratorESP
    GenBtn.Text = Settings.GeneratorESP and "Generator: ON" or "Generator: OFF"
    GenBtn.BackgroundColor3 = Settings.GeneratorESP and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Кнопка Speed
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.8, 0, 0, 28)
SpeedBtn.Position = UDim2.new(0.1, 0, 0, 126)
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

-- Кнопка Stamina
local StaminaBtn = Instance.new("TextButton")
StaminaBtn.Size = UDim2.new(0.8, 0, 0, 28)
StaminaBtn.Position = UDim2.new(0.1, 0, 0, 159)
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

-- Информация
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 20)
Info.Position = UDim2.new(0, 0, 0, 195)
Info.BackgroundTransparency = 1
Info.Text = "🟢 Killer | 🔴 Survivor | 💛 Gen"
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 9
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

print("ESP + Speed 40 + Stamina + Generator ESP loaded!")
