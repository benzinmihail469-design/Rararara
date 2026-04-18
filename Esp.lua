--[[
    ESP для Bite By Night - 100% определение Убийцы
    Зелёный контур = Убийца (тот, у кого роль Killer в игре)
    Красный контур = Выжившие
    Определяет убийцу через Leaderboard / PlayerList
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
    KillerColor = Color3.fromRGB(0, 255, 0), -- Зелёный
    SurvivorColor = Color3.fromRGB(255, 0, 0), -- Красный
    Thickness = 2,
    MaxDistance = 2000
}

-- Функция для точного определения убийцы через PlayerList / Leaderboard
local function FindKiller()
    local killer = nil
    
    -- Способ 1: Проверить Leaderboard (самый надёжный)
    local playerList = game:GetService("Players"):GetChildren()
    
    -- Ищем GUI с таблицей лидеров
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:find("Leader") or gui.Name:find("PlayerList")) then
            for _, element in ipairs(gui:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") then
                    local text = element.Text:lower()
                    -- Ищем строку с "(KILLER)" или "Killer"
                    if text:find("killer") or text:find("(killer)") then
                        -- Извлекаем имя игрока (обычно оно перед "(KILLER)")
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
    
    -- Способ 2: Проверить PlayerGui каждого игрока на наличие маркеров убийцы
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        -- Ищем GUI элементы с текстом "Killer", "The Rotten", "Mimic", "Ennard"
                        for _, element in ipairs(gui:GetDescendants()) do
                            if element:IsA("TextLabel") then
                                local text = element.Text:lower()
                                if text:find("killer") or text:find("rotten") or text:find("mimic") or text:find("ennard") then
                                    return player
                                end
                            end
                        end
                    end
                end
            end
            
            -- Способ 3: Проверить по оружию в руках
            local character = player.Character
            if character then
                for _, tool in ipairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        local toolName = tool.Name:lower()
                        if toolName:find("remnant") or toolName:find("cleaver") or toolName:find("beartrap") or toolName:find("wire") then
                            return player
                        end
                    end
                end
            end
            
            -- Способ 4: Проверить по здоровью (убийца имеет > 1000 HP)
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.MaxHealth > 1000 then
                    return player
                end
            end
        end
    end
    
    -- Способ 5: Проверить чат (если кто-то написал что он убийца)
    -- (это редко, но как fallback)
    
    return killer
end

-- Храним текущего убийцу
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
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    ClearESP(player)
    
    local color = isKiller and Settings.KillerColor or Settings.SurvivorColor
    
    local box = CreateDrawing("Square", {
        Visible = false,
        Color = color,
        Thickness = isKiller and 3 or Settings.Thickness, -- Убийца с более толстой рамкой
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

-- Обновление позиций
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
        
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
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
        
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        
        local height = (head.Position.Y - root.Position.Y) * 2.5
        local width = height / 2
        
        box.Visible = true
        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
    end
end

-- Периодическое обновление убийцы
task.spawn(function()
    while true do
        UpdateAllOutlines()
        task.wait(2) -- Проверяем каждые 2 секунды
    end
end)

-- Обработчики
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        UpdateAllOutlines()
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
    if player == CurrentKiller then
        CurrentKiller = nil
    end
end)

-- Запуск для текущих игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        task.spawn(function()
            task.wait(1)
            UpdateAllOutlines()
        end)
    end
end

-- Главный цикл рендера
RunService.RenderStepped:Connect(UpdatePositions)

-- Простой GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillerESP"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "KILLER ESP"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 30)
Status.BackgroundTransparency = 1
Status.Text = "Killer: Searching..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 25)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleBtn.Text = "ESP: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Frame

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    ToggleBtn.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
    ToggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Обновление статуса в GUI
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

-- Ручная проверка при нажатии на Status
Status.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpdateAllOutlines()
        if CurrentKiller then
            Status.Text = "Killer: " .. CurrentKiller.Name
        end
    end
end)

print("Killer ESP loaded! Click on 'Killer: Searching...' to force update.")
