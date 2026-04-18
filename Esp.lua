--[[
    ESP для Bite By Night - Corner Box + поддержка Model + Speed Changer
    Зелёные уголки = Убийца, Красные уголки = Выжившие
    Работает с любым типом персонажа + регулировка скорости (мах 50)
    ПОЛНОСТЬЮ РАБОЧИЙ ПОЛЗУНОК С РУЧНЫМ УПРАВЛЕНИЕМ
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    MaxDistance = 2000,
    
    -- Speed
    SpeedEnabled = false,
    SpeedValue = 16
}

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
    
    local health = model:GetAttribute("Health") or model:GetAttribute("HP")
    if health then return tonumber(health) or 100, tonumber(health) or 100 end
    
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
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, el in ipairs(gui:GetDescendants()) do
                if el:IsA("TextLabel") then
                    local text = el.Text:lower()
                    if text:find("killer") or text:find("(killer)") then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if text:find(p.Name:lower()) then return p end
                        end
                    end
                end
            end
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local model = p.Character
            if model then
                local _, maxHP = GetHealth(model)
                if maxHP > 500 then return p end
                
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("Tool") then
                        local n = child.Name:lower()
                        if n:find("remnant") or n:find("cleaver") or n:find("beartrap") then return p end
                    end
                end
                
                local pgui = p:FindFirstChild("PlayerGui")
                if pgui then
                    for _, g in ipairs(pgui:GetDescendants()) do
                        if g:IsA("TextLabel") then
                            local t = g.Text:lower()
                            if t:find("killer") or t:find("scream") or t:find("charge") then return p end
                        end
                    end
                end
            end
            
            local bp = p:FindFirstChildOfClass("Backpack")
            if bp then
                for _, tool in ipairs(bp:GetChildren()) do
                    local n = tool.Name:lower()
                    if n:find("remnant") or n:find("cleaver") then return p end
                end
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

-- ==================== ОБНОВЛЕНИЕ ВСЕХ КОНТУРОВ ====================

local function UpdateAllOutlines()
    CurrentKiller = FindKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            CreateCornerBox(p, p == CurrentKiller)
        end
    end
end

-- ==================== ОБНОВЛЕНИЕ ПОЗИЦИЙ CORNER BOX ====================

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

task.spawn(function()
    while true do
        if Settings.SpeedEnabled then
            UpdateSpeed()
        end
        task.wait(0.3)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateSpeed()
end)

-- ==================== ЗАПУСК И ОБРАБОТЧИКИ ====================

task.spawn(function()
    while true do
        UpdateAllOutlines()
        task.wait(1)
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) UpdateAllOutlines() end)
end)

Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
    if p == CurrentKiller then CurrentKiller = nil end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character then task.wait(0.5) UpdateAllOutlines() end
end

RunService.RenderStepped:Connect(UpdatePositions)

-- ==================== GUI С РУЧНЫМ УПРАВЛЕНИЕМ (100% РАБОЧИЙ ПОЛЗУНОК) ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillerESP_Speed_Fixed"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 230)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "ESP + Speed Control"
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
    SpeedBtn.Text = Settings.SpeedEnabled and "Speed: ON" or "Speed: OFF"
    SpeedBtn.BackgroundColor3 = Settings.SpeedEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    UpdateSpeed()
end)

-- Текст скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 145)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = Frame

-- Слайдер - фон
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.8, 0, 0, 8)
SliderFrame.Position = UDim2.new(0.1, 0, 0, 170)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = Frame
SliderFrame.ZIndex = 1

Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)

-- Синий заполнитель
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderFrame
SliderFill.ZIndex = 2

Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

-- Белый ползунок
local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 18, 0, 18)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Text = ""
SliderKnob.AutoButtonColor = false
SliderKnob.Parent = SliderFrame
SliderKnob.ZIndex = 10

Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

local KnobStroke = Instance.new("UIStroke")
KnobStroke.Color = Color3.fromRGB(150, 150, 150)
KnobStroke.Thickness = 1.5
KnobStroke.Parent = SliderKnob

-- ПЕРЕМЕННЫЕ ДЛЯ РУЧНОГО ПЕРЕТАСКИВАНИЯ
local isDragging = false
local dragConnection = nil
local releaseConnection = nil

-- Функция обновления слайдера
local function UpdateSlider(percent)
    percent = math.clamp(percent, 0, 1)
    
    -- Вычисляем скорость (16-50)
    Settings.SpeedValue = math.floor(16 + percent * 34)
    SpeedLabel.Text = "Speed: " .. Settings.SpeedValue
    
    -- Обновляем визуал
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
    
    -- Применяем скорость
    if Settings.SpeedEnabled then
        UpdateSpeed()
    end
end

-- Функция получения процента из позиции мыши (ТОЛЬКО ПО ГОРИЗОНТАЛИ)
local function GetPercentFromMouse(mouseX)
    local minX = SliderFrame.AbsolutePosition.X
    local maxX = minX + SliderFrame.AbsoluteSize.X
    local clampedX = math.clamp(mouseX, minX, maxX)
    return (clampedX - minX) / SliderFrame.AbsoluteSize.X
end

-- НАЧАЛО ПЕРЕТАСКИВАНИЯ
local function StartDrag()
    isDragging = true
    
    -- Подключаем отслеживание движения мыши
    dragConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = GetPercentFromMouse(input.Position.X)
            UpdateSlider(percent)
        end
    end)
    
    -- Подключаем отслеживание отпускания кнопки
    releaseConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            StopDrag()
        end
    end)
end

-- ОСТАНОВКА ПЕРЕТАСКИВАНИЯ
function StopDrag()
    isDragging = false
    if dragConnection then
        dragConnection:Disconnect()
        dragConnection = nil
    end
    if releaseConnection then
        releaseConnection:Disconnect()
        releaseConnection = nil
    end
end

-- КЛИК ПО ПОЛЗУНКУ (начало перетаскивания)
SliderKnob.MouseButton1Down:Connect(function()
    StartDrag()
end)

-- КЛИК ПО ФОНУ СЛАЙДЕРА (сразу двигаем и начинаем перетаскивание)
SliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local percent = GetPercentFromMouse(input.Position.X)
        UpdateSlider(percent)
        StartDrag()
    end
end)

-- ЗАЩИТА ОТ ЗАЛИПАНИЯ (если мышь отпущена вне окна)
UserInputService.WindowFocusReleased:Connect(function()
    if isDragging then
        StopDrag()
    end
end)

-- Начальное значение (16)
UpdateSlider(0)

-- Информация
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 20)
Info.Position = UDim2.new(0, 0, 0, 195)
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
    StopDrag()
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

print("ESP + Speed loaded! Manual slider - drag works perfectly!")
