--[[
    ESP для Bite By Night - Автоопределение Убийцы (Исправлено)
    Зелёный контур = Убийца (The Rotten, Mimic, Ennard)
    Красный контур = Выжившие (Survivors)
    Использует комплексный анализ: Health, Speed, GUI, Tools.
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
    KillerColor = Color3.fromRGB(0, 255, 0), -- Зелёный для убийцы
    SurvivorColor = Color3.fromRGB(255, 0, 0), -- Красный для выживших
    LocalColor = Color3.fromRGB(0, 128, 255), -- Синий для себя (если ShowLocalPlayer = true)
    Thickness = 2,
    MaxDistance = 2000,
    ShowLocalPlayer = false -- Показывать ли себя
}

-- Функция для определения, является ли игрок убийцей (исправленная)
local function IsKiller(player)
    local character = player.Character
    if not character then return false end

    -- 1. Проверка по здоровью (у убийц от 1750 HP, у выживших 100 HP) [citation:10]
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.MaxHealth >= 1000 then
        return true
    end

    -- 2. Проверка по скорости (у убийц базовое WalkSpeed выше) [citation:10]
    if humanoid and humanoid.WalkSpeed >= 14 then
        -- Дополнительная проверка, чтобы не спутать с баффами выживших
        local success, result = pcall(function()
            return player:FindFirstChildOfClass("Backpack"):FindFirstChild("Remnant Cleaver")
        end)
        if success and result then return true end
        -- Если не нашли Cleaver, но скорость подозрительная, смотрим другие признаки
    end

    -- 3. Проверка по специфическому GUI убийцы (Scream, Charge, Mode Switch и т.д.) [citation:2]
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local guiName = gui.Name:lower()
                -- Имена GUI убийц: Abilities, KillerUI, SkillTree, HUD
                if guiName:find("killer") or guiName:find("abilit") or guiName:find("skill") then
                    return true
                end
                -- Проверка по элементам внутри (кнопки способностей)
                for _, element in ipairs(gui:GetDescendants()) do
                    if element:IsA("ImageButton") or element:IsA("TextButton") then
                        local elementName = element.Name:lower()
                        if elementName:find("scream") or elementName:find("charge") or elementName:find("mode") or elementName:find("grab") then
                            return true
                        end
                    end
                end
            end
        end
    end

    -- 4. Проверка по оружию убийцы в Backpack
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                -- Оружие The Rotten (Springtrap) [citation:2]
                if toolName:find("remnant") or toolName:find("cleaver") or toolName:find("beartrap") then
                    return true
                end
                -- Оружие/способности других убийц [citation:2]
                if toolName:find("wire") or toolName:find("grab") or toolName:find("stealer") then
                    return true
                end
            end
        end
    end

    -- 5. Прямая проверка наличия оружия в руках персонажа
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("remnant") or toolName:find("cleaver") or toolName:find("beartrap") then
                return true
            end
            if toolName:find("wire") or toolName:find("grab") or toolName:find("stealer") then
                return true
            end
        end
    end

    -- 6. Проверка по атрибутам (если разработчики добавляют их)
    local success, attr = pcall(function()
        return player:GetAttribute("IsKiller") or character:GetAttribute("IsKiller")
    end)
    if success and attr then
        return true
    end

    return false
end

-- Функция создания Drawing-объектов
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

-- Очистка ESP для игрока
local function ClearESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            pcall(function() drawing:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- Создание контура для игрока
local function CreateOutline(player)
    if not Settings.ShowLocalPlayer and player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    -- Определяем цвет в зависимости от роли
    local color
    if player == LocalPlayer then
        color = Settings.LocalColor
    elseif IsKiller(player) then
        color = Settings.KillerColor
    else
        color = Settings.SurvivorColor
    end
    
    -- Очищаем старый контур
    ClearESP(player)
    
    local drawings = {}
    
    -- Создаём квадратный контур
    local box = CreateDrawing("Square", {
        Visible = false,
        Color = color,
        Thickness = Settings.Thickness,
        Filled = false
    })
    
    if box then
        drawings.Box = box
        ESPObjects[player] = drawings
    end
end

-- Обновление позиций контуров
local function UpdateOutlines()
    if not Settings.Enabled then
        for _, drawings in pairs(ESPObjects) do
            if drawings.Box then
                drawings.Box.Visible = false
            end
        end
        return
    end
    
    for player, drawings in pairs(ESPObjects) do
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")
        
        if not humanoidRootPart or not humanoid or not head or not drawings.Box then
            if drawings.Box then
                drawings.Box.Visible = false
            end
            continue
        end
        
        -- Проверка дистанции
        local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
        if distance > Settings.MaxDistance then
            drawings.Box.Visible = false
            continue
        end
        
        -- Получаем позиции на экране
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        
        if not rootOnScreen then
            drawings.Box.Visible = false
            continue
        end
        
        -- Расчёт размеров Box
        local boxHeight = (head.Position.Y - humanoidRootPart.Position.Y) * 2.5
        local boxWidth = boxHeight / 2
        local boxX = rootPos.X - boxWidth / 2
        local boxY = rootPos.Y - boxHeight / 2
        
        -- Обновляем Box
        drawings.Box.Visible = true
        drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
        drawings.Box.Position = Vector2.new(boxX, boxY)
    end
end

-- Обработчики событий
local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        task.wait(1) -- Даём время на загрузку GUI и оружия
        CreateOutline(player)
    end)
    if player.Character then
        task.wait(1)
        CreateOutline(player)
    end
end

local function OnPlayerRemoving(player)
    ClearESP(player)
end

-- Подключаем события для всех игроков
for _, player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Периодически перепроверяем роли (каждые 3 секунды)
task.spawn(function()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player ~= LocalPlayer then
                CreateOutline(player)
            end
        end
        task.wait(3)
    end
end)

-- Главный цикл обновления
RunService.RenderStepped:Connect(UpdateOutlines)

-- Создаём GUI для управления
local function CreateControlGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BiteByNight_ESP_Fixed"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 140)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "Bite By Night ESP (Fixed)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    -- Кнопка вкл/выкл
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
    ToggleButton.Position = UDim2.new(0.1, 0, 0, 40)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    ToggleButton.Text = "ESP: ON"
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
    
    -- Информация о цветах
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, 0, 0, 50)
    Info.Position = UDim2.new(0, 0, 0, 80)
    Info.BackgroundTransparency = 1
    Info.Text = "🟢 Killer (HP/Speed/GUI)\n🔴 Survivor"
    Info.TextColor3 = Color3.fromRGB(255, 255, 255)
    Info.TextSize = 11
    Info.Font = Enum.Font.Gotham
    Info.TextWrapped = true
    Info.Parent = Frame
    
    -- Кнопка закрытия
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

CreateControlGUI()

print("Bite By Night ESP Fixed loaded! Detects Killer by Health, Speed, GUI, and Tools.")
