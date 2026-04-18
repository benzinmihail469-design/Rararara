--[[
    ESP Script (Wallhack / Player Highlight) без ключ-системы
    Работает в любом Roblox-исполнителе.
    Функции: Box, Tracer, Name, Distance, Health Bar
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Хранилище для объектов ESP
local ESPObjects = {}

-- Настройки ESP
local Settings = {
    Enabled = true,
    Box = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    Tracer = true,
    TracerColor = Color3.fromRGB(255, 255, 255),
    Name = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    Distance = true,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    HealthBar = true,
    TeamCheck = false, -- true = не подсвечивать членов своей команды
    MaxDistance = 2000, -- максимальная дистанция отрисовки
    UpdateInterval = 0 -- 0 = каждый кадр
}

-- Функция для безопасного создания Drawing-объектов
local function CreateDrawing(className, properties)
    local success, drawing = pcall(function()
        local d = Drawing.new(className)
        for prop, value in pairs(properties) do
            pcall(function()
                d[prop] = value
            end)
        end
        return d
    end)
    return success and drawing or nil
end

-- Очистка ESP для конкретного игрока
local function ClearESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            pcall(function() drawing:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- Создание ESP для игрока
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    -- Проверка команд (если TeamCheck включен)
    if Settings.TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return
    end
    
    -- Очищаем старый ESP
    ClearESP(player)
    
    local drawings = {}
    
    -- Box (2D квадрат)
    if Settings.Box then
        local box = CreateDrawing("Square", {
            Visible = false,
            Color = Settings.BoxColor,
            Thickness = 1,
            Filled = false
        })
        if box then drawings.Box = box end
    end
    
    -- Tracer (линия от низа экрана)
    if Settings.Tracer then
        local tracer = CreateDrawing("Line", {
            Visible = false,
            Color = Settings.TracerColor,
            Thickness = 1
        })
        if tracer then drawings.Tracer = tracer end
    end
    
    -- Имя
    if Settings.Name then
        local nameText = CreateDrawing("Text", {
            Visible = false,
            Text = player.Name,
            Color = Settings.NameColor,
            Size = 13,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0)
        })
        if nameText then drawings.Name = nameText end
    end
    
    -- Дистанция
    if Settings.Distance then
        local distanceText = CreateDrawing("Text", {
            Visible = false,
            Text = "",
            Color = Settings.DistanceColor,
            Size = 13,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0)
        })
        if distanceText then drawings.Distance = distanceText end
    end
    
    -- Health Bar
    if Settings.HealthBar then
        local healthBarBg = CreateDrawing("Square", {
            Visible = false,
            Color = Color3.new(0, 0, 0),
            Filled = true
        })
        local healthBarFill = CreateDrawing("Square", {
            Visible = false,
            Color = Color3.new(0, 255, 0),
            Filled = true
        })
        if healthBarBg and healthBarFill then
            drawings.HealthBarBg = healthBarBg
            drawings.HealthBarFill = healthBarFill
        end
    end
    
    ESPObjects[player] = drawings
end

-- Обновление ESP каждый кадр
local function UpdateESP()
    if not Settings.Enabled then
        -- Скрываем все объекты
        for player, drawings in pairs(ESPObjects) do
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
        return
    end
    
    for player, drawings in pairs(ESPObjects) do
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")
        
        if not humanoidRootPart or not humanoid or not head then
            -- Скрываем, если персонаж не загружен
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Проверка дистанции
        local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
        if distance > Settings.MaxDistance then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Получаем позицию на экране
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        
        if not rootOnScreen then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Расчёт размеров Box
        local boxHeight = (head.Position.Y - humanoidRootPart.Position.Y) * 2.5
        local boxWidth = boxHeight / 2
        local boxX = rootPos.X - boxWidth / 2
        local boxY = rootPos.Y - boxHeight / 2
        
        -- Box
        if drawings.Box then
            drawings.Box.Visible = true
            drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
            drawings.Box.Position = Vector2.new(boxX, boxY)
        end
        
        -- Tracer
        if drawings.Tracer then
            drawings.Tracer.Visible = true
            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        end
        
        -- Name
        if drawings.Name then
            drawings.Name.Visible = true
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(rootPos.X, boxY - 15)
        end
        
        -- Distance
        if drawings.Distance then
            drawings.Distance.Visible = true
            drawings.Distance.Text = string.format("%.0f studs", distance)
            drawings.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 5)
        end
        
        -- Health Bar
        if drawings.HealthBarBg and drawings.HealthBarFill then
            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local healthPercent = health / maxHealth
            
            local barWidth = 2
            local barHeight = boxHeight
            local barX = boxX - barWidth - 2
            local barY = boxY
            
            drawings.HealthBarBg.Visible = true
            drawings.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
            drawings.HealthBarBg.Position = Vector2.new(barX, barY)
            
            drawings.HealthBarFill.Visible = true
            drawings.HealthBarFill.Size = Vector2.new(barWidth, barHeight * healthPercent)
            drawings.HealthBarFill.Position = Vector2.new(barX, barY + barHeight * (1 - healthPercent))
            
            -- Цвет в зависимости от здоровья
            if healthPercent > 0.6 then
                drawings.HealthBarFill.Color = Color3.new(0, 255, 0)
            elseif healthPercent > 0.3 then
                drawings.HealthBarFill.Color = Color3.new(255, 255, 0)
            else
                drawings.HealthBarFill.Color = Color3.new(255, 0, 0)
            end
        end
    end
end

-- Обработчики событий
local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        CreateESP(player)
    end)
    if player.Character then
        CreateESP(player)
    end
end

local function OnPlayerRemoving(player)
    ClearESP(player)
end

-- Подключаем события для всех текущих игроков
for _, player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Главный цикл обновления
if Settings.UpdateInterval > 0 then
    while true do
        UpdateESP()
        task.wait(Settings.UpdateInterval)
    end
else
    RunService.RenderStepped:Connect(UpdateESP)
end

-- Создаём простой GUI для управления ESP
local function CreateControlGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESPControl"
    ScreenGui.Parent = CoreGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 150)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "ESP Control"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
    ToggleButton.Position = UDim2.new(0.1, 0, 0, 40)
    ToggleButton.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    ToggleButton.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = Frame
    
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)
    
    ToggleButton.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        ToggleButton.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
        ToggleButton.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    end)
    
    -- Кнопка TeamCheck
    local TeamButton = Instance.new("TextButton")
    TeamButton.Size = UDim2.new(0.8, 0, 0, 30)
    TeamButton.Position = UDim2.new(0.1, 0, 0, 80)
    TeamButton.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    TeamButton.Text = Settings.TeamCheck and "Team Check: ON" or "Team Check: OFF"
    TeamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamButton.TextSize = 14
    TeamButton.Font = Enum.Font.Gotham
    TeamButton.AutoButtonColor = false
    TeamButton.Parent = Frame
    
    Instance.new("UICorner", TeamButton).CornerRadius = UDim.new(0, 6)
    
    TeamButton.MouseButton1Click:Connect(function()
        Settings.TeamCheck = not Settings.TeamCheck
        TeamButton.Text = Settings.TeamCheck and "Team Check: ON" or "Team Check: OFF"
        TeamButton.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        -- Обновляем ESP для всех игроков
        for _, player in ipairs(Players:GetPlayers()) do
            ClearESP(player)
            OnPlayerAdded(player)
        end
    end)
    
    -- Кнопка закрытия GUI
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -25, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = Frame
    
    Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 4)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end

-- Запускаем GUI управления
CreateControlGUI()

print("ESP Script loaded! Control GUI is on the top-left.")
