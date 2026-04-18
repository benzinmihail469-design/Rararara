--[[
    ESP для Bite By Night - Поддержка Model (моделек)
    Зелёный контур = Убийца
    Красный контур = Выжившие
    Работает с любым типом персонажа (Model, R6, R15)
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Хранилище ESP
local ESPObjects = {}

-- Настройки
local Settings = {
    Enabled = true,
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    Thickness = 3,
    MaxDistance = 2000
}

-- Функция получения "корневой" части модели (любой тип персонажа)
local function GetRootPart(model)
    if not model then return nil end
    
    -- Стандартный HumanoidRootPart
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    
    -- Для моделек: ищем самую большую Part или Torso
    local biggestPart = nil
    local biggestSize = 0
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local size = part.Size.X + part.Size.Y + part.Size.Z
            if size > biggestSize then
                biggestSize = size
                biggestPart = part
            end
            
            -- Приоритет частям с именем Torso, UpperTorso, LowerTorso
            if part.Name:lower():find("torso") then
                return part
            end
        end
    end
    
    -- Если есть голова, берём её родителя как корень
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        return head.Parent:FindFirstChild("Torso") or head.Parent:FindFirstChild("UpperTorso") or biggestPart
    end
    
    return biggestPart or model.PrimaryPart
end

-- Функция получения "головы" модели
local function GetHead(model)
    if not model then return nil end
    
    -- Стандартная голова
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    
    -- Для моделек: ищем часть с именем Head
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("head") then
            return part
        end
    end
    
    -- Fallback: часть выше всех остальных
    local highestPart = nil
    local highestY = -math.huge
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local y = part.Position.Y
            if y > highestY then
                highestY = y
                highestPart = part
            end
        end
    end
    
    return highestPart
end

-- Функция проверки здоровья модели
local function GetHealth(model)
    -- Стандартный Humanoid
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health, humanoid.MaxHealth
    end
    
    -- Для моделек: ищем Health в атрибутах или IntValue
    local healthValue = model:FindFirstChild("Health") or model:FindFirstChild("HP")
    if healthValue then
        if healthValue:IsA("IntValue") or healthValue:IsA("NumberValue") then
            return healthValue.Value, healthValue.Value
        end
    end
    
    -- Проверяем атрибуты
    local health = model:GetAttribute("Health") or model:GetAttribute("HP")
    if health then
        return tonumber(health) or 100, tonumber(health) or 100
    end
    
    return 100, 100
end

-- Определение убийцы
local function FindKiller()
    -- Способ 1: Поиск через PlayerList GUI
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, element in ipairs(gui:GetDescendants()) do
                if element:IsA("TextLabel") then
                    local text = element.Text:lower()
                    if text:find("killer") or text:find("(killer)") then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if text:find(player.Name:lower()) then
                                return player
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Способ 2: Проверка каждого игрока
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local model = player.Character
            if model then
                -- Проверка по здоровью (убийца имеет больше HP)
                local health, maxHealth = GetHealth(model)
                if maxHealth > 500 or health > 500 then
                    return player
                end
                
                -- Проверка по оружию в модели
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("Tool") then
                        local name = child.Name:lower()
                        if name:find("remnant") or name:find("cleaver") or name:find("beartrap") or name:find("wire") or name:find("grab") then
                            return player
                        end
                    end
                end
                
                -- Проверка GUI убийцы у игрока
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetDescendants()) do
                        if gui:IsA("TextLabel") then
                            local text = gui.Text:lower()
                            if text:find("killer") or text:find("scream") or text:find("charge") then
                                return player
                            end
                        end
                    end
                end
            end
            
            -- Проверка рюкзака
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    local name = tool.Name:lower()
                    if name:find("remnant") or name:find("cleaver") or name:find("beartrap") then
                        return player
                    end
                end
            end
        end
    end
    
    return nil
end

local CurrentKiller = nil

-- Функция создания Drawing
local function CreateDrawing(className, properties)
    local success, drawing = pcall(function()
        local d = Drawing.new(className)
        for prop, value in pairs(properties) do
            pcall(function() d[prop] = value end)
        end
        return d
    end)
    return success and drawing or nil
end

-- Очистка ESP
local function ClearESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            pcall(function() drawing:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- Создание контура
local function CreateOutline(player, isKiller)
    if player == LocalPlayer then return end
    
    local model = player.Character
    if not model then return end
    
    ClearESP(player)
    
    local color = isKiller and Settings.KillerColor or Settings.SurvivorColor
    
    local box = CreateDrawing("Square", {
        Visible = false,
        Color = color,
        Thickness = isKiller and 4 or Settings.Thickness,
        Filled = false
    })
    
    if box then
        ESPObjects[player] = {Box = box, IsKiller = isKiller}
    end
end

-- Обновление всех контуров
local function UpdateAllOutlines()
    CurrentKiller = FindKiller()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local isKiller = (player == CurrentKiller)
            CreateOutline(player, isKiller)
        end
    end
end

-- Обновление позиций контуров (работает с любыми моделями)
local function UpdatePositions()
    if not Settings.Enabled then
        for _, data in pairs(ESPObjects) do
            if data.Box then data.Box.Visible = false end
        end
        return
    end
    
    for player, data in pairs(ESPObjects) do
        local box = data.Box
        if not box then continue end
        
        local model = player.Character
        if not model then
            box.Visible = false
            continue
        end
        
        local root = GetRootPart(model)
        local head = GetHead(model)
        
        if not root or not head then
            box.Visible = false
            continue
        end
        
        local distance = (Camera.CFrame.Position - root.Position).Magnitude
        if distance > Settings.MaxDistance then
            box.Visible = false
            continue
        end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            box.Visible = false
            continue
        end
        
        -- Расчёт размеров для моделек
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y/2, 0))
        local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, root.Size.Y/2, 0))
        
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height / 2
        
        box.Visible = true
        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(rootPos.X - width/2, headPos.Y)
    end
end

-- Периодическое обновление
task.spawn(function()
    while true do
        UpdateAllOutlines()
        task.wait(1)
    end
end)

-- Обработчики игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        UpdateAllOutlines()
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
    if player == CurrentKiller then
        CurrentKiller = nil
    end
end)

-- Запуск для текущих
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        task.wait(0.5)
        UpdateAllOutlines()
    end
end

-- Рендер
RunService.RenderStepped:Connect(UpdatePositions)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillerESP_Model"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "ESP (Model Support)"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 14
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

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 65)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleBtn.Text = "ESP: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Frame

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    ToggleBtn.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
    ToggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Клик по статусу для ручного обновления
Status.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpdateAllOutlines()
        if CurrentKiller then
            Status.Text = "Killer: " .. CurrentKiller.Name
        end
    end
end)

-- Обновление статуса
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

print("ESP with Model support loaded! Works with any character type.")
