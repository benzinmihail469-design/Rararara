-- Survive Zombie Arena - Mobile Optimized GUI
-- Для телефонов и планшетов

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Определяем платформу
local isMobile = UserInputService.TouchEnabled

-- Цвета
local Colors = {
    Primary = Color3.fromRGB(255, 80, 120),
    Secondary = Color3.fromRGB(50, 50, 70),
    Background = Color3.fromRGB(20, 20, 25),
    Dark = Color3.fromRGB(15, 15, 20),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(60, 180, 100),
    Danger = Color3.fromRGB(255, 60, 60)
}

-- Размеры для мобильных (увеличенные)
local Sizes = {
    ButtonHeight = isMobile and 70 or 50,
    TitleSize = isMobile and 22 or 18,
    FontSize = isMobile and 16 or 14,
    Padding = isMobile and 12 or 8
}

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SZA_Mobile"
screenGui.DisplayOrder = 999
screenGui.Parent = LocalPlayer.PlayerGui

-- ============ ГЛАВНОЕ ОКНО ============

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
mainFrame.BackgroundColor3 = Colors.Background
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- ============ ЗАГОЛОВОК (упрощённый для мобильных) ============

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 80)
header.BackgroundColor3 = Colors.Dark
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

-- Обрезаем низ
local headerClip = Instance.new("Frame")
headerClip.Size = UDim2.new(1, 0, 1, 16)
headerClip.BackgroundTransparency = 1
headerClip.ClipsDescendants = true
headerClip.Parent = header

-- Название
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0.5, 0)
title.Position = UDim2.new(0.03, 0, 0.15, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Zombie Arena"
title.TextColor3 = Colors.Text
title.TextSize = Sizes.TitleSize
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = headerClip

-- Подзаголовок
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0.3, 0)
subtitle.Position = UDim2.new(0.03, 0, 0.55, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Best Mobile Script"
subtitle.TextColor3 = Colors.TextDark
subtitle.TextSize = Sizes.FontSize - 2
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = headerClip

-- Discord (упрощённый)
local discordBar = Instance.new("Frame")
discordBar.Size = UDim2.new(1, -16, 0, 30)
discordBar.Position = UDim2.new(0.02, 0, 1, -32)
discordBar.BackgroundTransparency = 1
discordBar.Parent = headerClip

local discordText = Instance.new("TextLabel")
discordText.Size = UDim2.new(1, 0, 1, 0)
discordText.BackgroundTransparency = 1
discordText.Text = "📱 discord.gg/Foxname"
discordText.TextColor3 = Colors.Primary
discordText.TextSize = Sizes.FontSize - 3
discordText.TextXAlignment = Enum.TextXAlignment.Left
discordText.Font = Enum.Font.Gotham
discordText.Parent = discordBar

-- ============ СКРОЛЛ КОНТЕНТ ============

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -80)
scrollFrame.Position = UDim2.new(0, 0, 0, 80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = isMobile and 6 or 4
scrollFrame.ScrollBarImageColor3 = Colors.Primary
scrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
scrollFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, Sizes.Padding)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = scrollFrame

local yOffset = 0

-- ============ ФУНКЦИЯ СОЗДАНИЯ БОЛЬШОЙ КНОПКИ ============

local function createBigButton(text, icon, color, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.94, 0, 0, Sizes.ButtonHeight)
    button.Position = UDim2.new(0.03, 0, 0, yOffset)
    button.Text = icon .. " " .. text
    button.TextColor3 = Colors.Text
    button.TextSize = Sizes.FontSize + 2
    button.BackgroundColor3 = color or Colors.Secondary
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    
    -- Эффект нажатия для мобильных
    local pressFrame = Instance.new("Frame")
    pressFrame.Size = UDim2.new(1, 0, 1, 0)
    pressFrame.BackgroundColor3 = Colors.Primary
    pressFrame.BackgroundTransparency = 1
    pressFrame.BorderSizePixel = 0
    pressFrame.Parent = button
    
    local pressCorner = Instance.new("UICorner")
    pressCorner.CornerRadius = UDim.new(0, 12)
    pressCorner.Parent = pressFrame
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(pressFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
            if isMobile and UserInputService.Vibrate then
                pcall(function() UserInputService:Vibrate() end)
            end
            callback()
            task.delay(0.1, function()
                TweenService:Create(pressFrame, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            end)
        end
    end)
    
    yOffset = yOffset + Sizes.ButtonHeight + Sizes.Padding
    return button
end

-- ============ ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЯ ============

local function createToggle(text, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.94, 0, 0, 60)
    container.Position = UDim2.new(0.03, 0, 0, yOffset)
    container.BackgroundColor3 = Colors.Secondary
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0.03, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.TextSize = Sizes.FontSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 60, 0, 30)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -15)
    toggleBg.BackgroundColor3 = Colors.Dark
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 26, 0, 26)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -13)
    toggleCircle.BackgroundColor3 = Colors.TextDark
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    local isOn = defaultValue or false
    
    local function updateToggle()
        if isOn then
            toggleBg.BackgroundColor3 = Colors.Primary
            toggleCircle.Position = UDim2.new(0, 32, 0.5, -13)
            toggleCircle.BackgroundColor3 = Colors.Text
        else
            toggleBg.BackgroundColor3 = Colors.Dark
            toggleCircle.Position = UDim2.new(0, 2, 0.5, -13)
            toggleCircle.BackgroundColor3 = Colors.TextDark
        end
        callback(isOn)
    end
    
    updateToggle()
    
    local pressFrame = Instance.new("Frame")
    pressFrame.Size = UDim2.new(1, 0, 1, 0)
    pressFrame.BackgroundColor3 = Colors.Primary
    pressFrame.BackgroundTransparency = 1
    pressFrame.BorderSizePixel = 0
    pressFrame.Parent = container
    
    local pressCorner = Instance.new("UICorner")
    pressCorner.CornerRadius = UDim.new(0, 12)
    pressCorner.Parent = pressFrame
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(pressFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.9}):Play()
            isOn = not isOn
            updateToggle()
            if isMobile and UserInputService.Vibrate then
                pcall(function() UserInputService:Vibrate() end)
            end
            task.delay(0.1, function()
                TweenService:Create(pressFrame, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            end)
        end
    end)
    
    yOffset = yOffset + 60 + Sizes.Padding
    return container, function() return isOn end
end

-- ============ ФУНКЦИЯ СОЗДАНИЯ СЛАЙДЕРА ============

local function createSlider(text, minValue, maxValue, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.94, 0, 0, 80)
    container.Position = UDim2.new(0.03, 0, 0, yOffset)
    container.BackgroundColor3 = Colors.Secondary
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.4, 0)
    label.Position = UDim2.new(0.03, 0, 0.1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.TextSize = Sizes.FontSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.67, 0, 0.1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Colors.Primary
    valueLabel.TextSize = Sizes.FontSize
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = container
    
    -- Слайдер
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.94, 0, 0, isMobile and 8 or 6)
    sliderBg.Position = UDim2.new(0.03, 0, 0.7, -4)
    sliderBg.BackgroundColor3 = Colors.Dark
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Colors.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local knob = Instance.new("ImageButton")
    knob.Size = UDim2.new(0, isMobile and 32 or 24, 0, isMobile and 32 or 24)
    knob.Position = UDim2.new(0, -16, 0.5, -16)
    knob.BackgroundTransparency = 1
    knob.Image = "rbxassetid://6020299385"
    knob.ImageColor3 = Colors.Primary
    knob.Parent = sliderBg
    
    local currentValue = defaultValue
    local dragging = false
    
    local function updateValue(value)
        currentValue = math.clamp(value, minValue, maxValue)
        local percent = (currentValue - minValue) / (maxValue - minValue)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -16, 0.5, -16)
        valueLabel.Text = tostring(math.floor(currentValue))
        
        callback(currentValue)
    end
    
    updateValue(currentValue)
    
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if dragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local percent = math.clamp((mousePos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    updateValue(minValue + (maxValue - minValue) * percent)
                end
            end)
            
            local releaseConn
            releaseConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    dragging = false
                    connection:Disconnect()
                    releaseConn:Disconnect()
                end
            end)
        end
    end
    
    knob.InputBegan:Connect(startDrag)
    sliderBg.InputBegan:Connect(startDrag)
    
    yOffset = yOffset + 80 + Sizes.Padding
    return container
end

-- ============ ДОБАВЛЯЕМ ЭЛЕМЕНТЫ ============

-- Kill Aura (главная кнопка)
createBigButton("Kill Aura", "⚔️", Colors.Primary, function()
    print("Kill Aura активирована!")
    -- Добавь свой код Kill Aura сюда
end)

-- Переключатели
local killAuraToggle, getKillAura = createToggle("Enable Kill Aura", true, function(value)
    print("Kill Aura включена:", value)
    -- Твой код для включения/выключения
end)

local espToggle, getESP = createToggle("Zombie ESP", true, function(value)
    print("ESP включён:", value)
    -- Твой код ESP
end)

-- Слайдер скорости
createSlider("⚡ Speed", 16, 100, 42, function(value)
    print("Скорость установлена на:", value)
    -- Твой код для изменения скорости игрока
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

-- Кнопка "2x Speed"
createBigButton("2x Speed", "×2", Colors.Secondary, function()
    print("2x Speed активирована!")
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local currentSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
        LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed * 2
    end
end)

-- Кнопка магазина
createBigButton("Shop", "🛒", Colors.Secondary, function()
    print("Магазин открыт!")
    -- Твой код магазина
end)

-- Кнопка телепорта
createBigButton("Teleport", "🌀", Colors.Secondary, function()
    print("Телепорт!")
    -- Твой код телепорта
end)

-- Кнопка инвентаря
createBigButton("Inventory", "📦", Colors.Secondary, function()
    print("Инвентарь открыт!")
    -- Твой код инвентаря
end)

-- Обновляем CanvasSize
local function updateCanvas()
    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
end

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- ============ АНИМАЦИЯ ПОЯВЛЕНИЯ ============

mainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.3), {
    Size = UDim2.new(0, 400, 0, 600)
}):Play()

print("✅ Mobile GUI для Survive Zombie Arena загружен!")
print("📱 Оптимизировано для телефонов и планшетов!")

-- ============ ПРОСТАЯ ЗАГЛУШКА ДЛЯ KILL AURA ============

-- Пример базовой Kill Aura для мобильных (добавь в скрипт выше)
local function setupKillAura()
    local enabled = false
    local range = 30
    
    -- Функция для поиска ближайшего зомби
    local function getNearestZombie()
        local nearest = nil
        local shortestDist = range
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart and LocalPlayer.Character then
                        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if localRoot then
                            local distance = (rootPart.Position - localRoot.Position).Magnitude
                            if distance < shortestDist then
                                shortestDist = distance
                                nearest = character
                            end
                        end
                    end
                end
            end
        end
        
        return nearest
    end
    
    -- Loop для Kill Aura
    coroutine.wrap(function()
        while true do
            if enabled then
                local target = getNearestZombie()
                if target then
                    -- Наносим урон (пример)
                    local humanoid = target:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end
                end
            end
            task.wait(0.1)
        end
    end)()
    
    return function(state)
        enabled = state
        print("Kill Aura:", enabled and "ON" or "OFF")
    end
end

-- Раскомментируй, чтобы включить Kill Aura:
-- local killAuraFunc = setupKillAura()
-- В toggle добавь: killAuraFunc(value)
