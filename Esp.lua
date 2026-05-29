--[[
    Современный UI фреймворк
    Полностью рабочий скрипт с кнопками, слайдерами, чекбоксами и другими элементами
--]]

--// Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Константы
local UI_THEME = {
    Primary = Color3.fromRGB(134, 142, 255),
    Secondary = Color3.fromRGB(83, 87, 158),
    Background = Color3.fromRGB(25, 25, 25),
    BackgroundDark = Color3.fromRGB(18, 18, 18),
    Text = Color3.fromRGB(200, 200, 200),
    TextDark = Color3.fromRGB(100, 100, 100),
    Success = Color3.fromRGB(60, 150, 107),
    Danger = Color3.fromRGB(170, 89, 91)
}

local ANIMATION_SPEED = 0.3
local TI = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

--// ============ ГЕНЕРАТОР ОБЪЕКТОВ ============

local function createStyledFrame(parent, size, position, color, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or UI_THEME.Background
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return frame
end

local function createTextLabel(parent, text, size, position, color, font, textSize)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = color or UI_THEME.Text
    label.Font = font or Enum.Font.GothamSemibold
    label.TextSize = textSize or 14
    label.Parent = parent
    return label
end

--// ============ КОМПОНЕНТ КНОПКИ ============

local function createButton(parent, title, callback, yOffset)
    local button = createStyledFrame(parent, UDim2.new(0.9, 0, 0, 45), 
        UDim2.new(0.05, 0, yOffset or 0, 0), UI_THEME.BackgroundDark, 0.8)
    
    local hoverFrame = Instance.new("Frame")
    hoverFrame.Size = UDim2.new(1, 0, 1, 0)
    hoverFrame.BackgroundColor3 = UI_THEME.Primary
    hoverFrame.BackgroundTransparency = 1
    hoverFrame.BorderSizePixel = 0
    hoverFrame.Parent = button
    
    local cornerHover = Instance.new("UICorner")
    cornerHover.CornerRadius = UDim.new(0, 8)
    cornerHover.Parent = hoverFrame
    
    local text = createTextLabel(button, title, UDim2.new(1, 0, 1, 0), 
        UDim2.new(0, 0, 0, 0), UI_THEME.Text, Enum.Font.GothamSemibold, 16)
    
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.Parent = button
    shadow.ZIndex = -1
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = shadow
    
    -- Эффекты
    local isHovering = false
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            isHovering = true
            TweenService:Create(hoverFrame, TI, {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(text, TI, {TextColor3 = UI_THEME.Primary}):Play()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(button, TI, {BackgroundColor3 = UI_THEME.Primary}):Play()
            TweenService:Create(text, TI, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            
            -- Ripple эффект
            local ripple = Instance.new("Frame")
            ripple.Size = UDim2.new(0, 0, 0, 0)
            ripple.Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X, 0, Mouse.Y - button.AbsolutePosition.Y)
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.5
            ripple.BorderSizePixel = 0
            ripple.Parent = button
            
            local rippleCorner = Instance.new("UICorner")
            rippleCorner.CornerRadius = UDim.new(1, 0)
            rippleCorner.Parent = ripple
            
            TweenService:Create(ripple, TI, {
                Size = UDim2.new(2, 0, 2, 0),
                Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X - 100, 0, Mouse.Y - button.AbsolutePosition.Y - 100),
                BackgroundTransparency = 1
            }):Play()
            
            task.delay(ANIMATION_SPEED, function()
                ripple:Destroy()
            end)
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            isHovering = false
            TweenService:Create(hoverFrame, TI, {BackgroundTransparency = 1}):Play()
            TweenService:Create(text, TI, {TextColor3 = UI_THEME.Text}):Play()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(button, TI, {BackgroundColor3 = UI_THEME.BackgroundDark}):Play()
            TweenService:Create(text, TI, {TextColor3 = UI_THEME.Text}):Play()
            task.delay(0.05, callback)
        end
    end)
    
    return button
end

--// ============ КОМПОНЕНТ СЛАЙДЕРА ============

local function createSlider(parent, title, minValue, maxValue, defaultValue, callback, yOffset)
    local container = createStyledFrame(parent, UDim2.new(0.9, 0, 0, 70), 
        UDim2.new(0.05, 0, yOffset or 0, 0), UI_THEME.BackgroundDark, 0.8)
    
    local titleLabel = createTextLabel(container, title, UDim2.new(1, 0, 0.35, 0), 
        UDim2.new(0.02, 0, 0, 0), UI_THEME.Text, Enum.Font.Gotham, 12)
    
    local valueLabel = createTextLabel(container, tostring(defaultValue), UDim2.new(0.3, 0, 0.35, 0), 
        UDim2.new(0.68, 0, 0, 0), UI_THEME.Primary, Enum.Font.GothamBold, 14)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = createStyledFrame(container, UDim2.new(0.96, 0, 0.15, 0), 
        UDim2.new(0.02, 0, 0.55, 0), UI_THEME.Background, 0.5)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local sliderFill = createStyledFrame(sliderBg, UDim2.new(0, 0, 1, 0), 
        UDim2.new(0, 0, 0, 0), UI_THEME.Primary, 1)
    
    local knob = Instance.new("ImageButton")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, -9, 0.5, -9)
    knob.BackgroundColor3 = UI_THEME.Primary
    knob.BackgroundTransparency = 1
    knob.Image = "rbxassetid://6020299385"
    knob.Parent = sliderBg
    
    local knobShadow = Instance.new("Frame")
    knobShadow.Size = UDim2.new(0, 22, 0, 22)
    knobShadow.Position = UDim2.new(0, -11, 0.5, -11)
    knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.5
    knobShadow.BorderSizePixel = 0
    knobShadow.Parent = sliderBg
    knobShadow.ZIndex = -1
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knobShadow
    
    local currentValue = defaultValue or minValue
    local isDragging = false
    
    local function updateValue(value)
        currentValue = math.floor(math.clamp(value, minValue, maxValue))
        local percent = (currentValue - minValue) / (maxValue - minValue)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -9, 0.5, -9)
        knobShadow.Position = UDim2.new(percent, -11, 0.5, -11)
        valueLabel.Text = tostring(currentValue)
        
        callback(currentValue)
    end
    
    updateValue(defaultValue or minValue)
    
    local function onDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local newValue = minValue + (maxValue - minValue) * percent
            updateValue(newValue)
        end
    end
    
    knob.MouseButton1Down:Connect(function()
        isDragging = true
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if isDragging then
                onDrag({Position = UserInputService:GetMouseLocation()})
            end
        end)
        
        local releaseConn
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
                connection:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
    
    return container
end

--// ============ КОМПОНЕНТ ЧЕКБОКСА ============

local function createCheckbox(parent, title, defaultValue, callback, yOffset)
    local container = createStyledFrame(parent, UDim2.new(0.9, 0, 0, 40), 
        UDim2.new(0.05, 0, yOffset or 0, 0), UI_THEME.BackgroundDark, 0.8)
    
    local checkBox = createStyledFrame(container, UDim2.new(0, 20, 0, 20), 
        UDim2.new(0.03, 0, 0.5, -10), UI_THEME.Background, 0)
    
    local checkMark = Instance.new("ImageLabel")
    checkMark.Size = UDim2.new(0.7, 0, 0.7, 0)
    checkMark.Position = UDim2.new(0.15, 0, 0.15, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Image = "rbxassetid://7072706620"
    checkMark.ImageColor3 = UI_THEME.Primary
    checkMark.ImageTransparency = 1
    checkMark.Parent = checkBox
    
    local titleLabel = createTextLabel(container, title, UDim2.new(0.7, 0, 1, 0), 
        UDim2.new(0.12, 0, 0, 0), UI_THEME.Text, Enum.Font.Gotham, 13)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local isChecked = defaultValue or false
    
    local function setChecked(checked)
        isChecked = checked
        if checked then
            TweenService:Create(checkBox, TI, {BackgroundColor3 = UI_THEME.Primary}):Play()
            TweenService:Create(checkMark, TI, {ImageTransparency = 0}):Play()
        else
            TweenService:Create(checkBox, TI, {BackgroundColor3 = UI_THEME.Background}):Play()
            TweenService:Create(checkMark, TI, {ImageTransparency = 1}):Play()
        end
        callback(isChecked)
    end
    
    setChecked(isChecked)
    
    local hoverFrame = Instance.new("Frame")
    hoverFrame.Size = UDim2.new(1, 0, 1, 0)
    hoverFrame.BackgroundColor3 = UI_THEME.Primary
    hoverFrame.BackgroundTransparency = 1
    hoverFrame.BorderSizePixel = 0
    hoverFrame.Parent = container
    
    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 8)
    hoverCorner.Parent = hoverFrame
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(hoverFrame, TI, {BackgroundTransparency = 0.95}):Play()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            setChecked(not isChecked)
        end
    end)
    
    container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(hoverFrame, TI, {BackgroundTransparency = 1}):Play()
        end
    end)
    
    return container
end

--// ============ КОМПОНЕНТ ТЕКСТОВОГО ПОЛЯ ============

local function createTextbox(parent, placeholder, callback, yOffset)
    local container = createStyledFrame(parent, UDim2.new(0.9, 0, 0, 50), 
        UDim2.new(0.05, 0, yOffset or 0, 0), UI_THEME.BackgroundDark, 0.8)
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.96, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.02, 0, 0.2, 0)
    textBox.BackgroundColor3 = UI_THEME.Background
    textBox.BackgroundTransparency = 0
    textBox.BorderSizePixel = 0
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = UI_THEME.TextDark
    textBox.Text = ""
    textBox.TextColor3 = UI_THEME.Text
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.ClearTextOnFocus = false
    textBox.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = textBox
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0.02, 0, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://7072706663"
    icon.ImageColor3 = UI_THEME.TextDark
    icon.Parent = container
    
    textBox.Focused:Connect(function()
        TweenService:Create(textBox, TI, {BackgroundColor3 = UI_THEME.Primary}):Play()
        TweenService:Create(icon, TI, {ImageColor3 = UI_THEME.Primary}):Play()
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textBox, TI, {BackgroundColor3 = UI_THEME.Background}):Play()
        TweenService:Create(icon, TI, {ImageColor3 = UI_THEME.TextDark}):Play()
        if enterPressed and textBox.Text ~= "" then
            callback(textBox.Text)
        end
    end)
    
    return container
end

--// ============ ОСНОВНОЕ ОКНО ============

local function createMainWindow()
    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernUI"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.ResetOnSpawn = false
    
    -- Затемнение фона
    local overlay = Instance.new("ImageButton")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.Image = "rbxassetid://7880418493"
    overlay.ImageColor3 = Color3.fromRGB(0, 0, 0)
    overlay.ImageTransparency = 0.3
    overlay.AutoButtonColor = false
    overlay.Parent = screenGui
    overlay.ZIndex = 0
    
    -- Главное окно
    local mainFrame = createStyledFrame(screenGui, UDim2.new(0, 400, 0, 550), 
        UDim2.new(0.5, -200, 0.5, -275), UI_THEME.BackgroundDark, 0.95)
    mainFrame.ZIndex = 10
    
    -- Тень
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, -10, 0.5, -10)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.Parent = mainFrame
    shadow.ZIndex = -1
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow
    
    -- Заголовок
    local titleBar = createStyledFrame(mainFrame, UDim2.new(1, 0, 0, 50), 
        UDim2.new(0, 0, 0, 0), UI_THEME.Primary, 1)
    
    local titleText = createTextLabel(titleBar, "MODERN UI", UDim2.new(1, 0, 1, 0), 
        UDim2.new(0.02, 0, 0, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 18)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://7072725342"
    closeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TI, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(overlay, TI, {ImageTransparency = 1}):Play()
        task.delay(ANIMATION_SPEED, function()
            screenGui:Destroy()
        end)
    end)
    
    -- Контейнер для контента (скроллинг)
    local scrollContainer = Instance.new("ScrollingFrame")
    scrollContainer.Size = UDim2.new(1, 0, 1, -50)
    scrollContainer.Position = UDim2.new(0, 0, 0, 50)
    scrollContainer.BackgroundTransparency = 1
    scrollContainer.BorderSizePixel = 0
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollContainer.ScrollBarThickness = 4
    scrollContainer.ScrollBarImageColor3 = UI_THEME.Primary
    scrollContainer.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollContainer
    
    -- Функция обновления CanvasSize
    local function updateCanvasSize()
        task.wait()
        scrollContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    updateCanvasSize()
    
    -- Делаем окно перетаскиваемым
    local dragging = false
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                           startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return scrollContainer, layout
end

--// ============ ДЕМОНСТРАЦИЯ ============

-- Создаем UI
local container, layout = createMainWindow()

-- Переменная для хранения текущей громкости
local currentVolume = 50

-- Кнопка "Приветствие"
createButton(container, "👋 Показать приветствие", function()
    print("Привет! Кнопка работает!")
    
    -- Временное уведомление
    local notif = createStyledFrame(container, UDim2.new(0.9, 0, 0, 40), 
        UDim2.new(0.05, 0, 0, 0), UI_THEME.Success, 0.9)
    notif.ZIndex = 1000
    
    local notifText = createTextLabel(notif, "✅ Кнопка нажата!", UDim2.new(1, 0, 1, 0), 
        UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), Enum.Font.Gotham, 14)
    
    notif.Position = UDim2.new(0.05, 0, -0.1, 0)
    TweenService:Create(notif, TI, {Position = UDim2.new(0.05, 0, 0, 0)}):Play()
    
    task.delay(2, function()
        TweenService:Create(notif, TI, {Position = UDim2.new(0.05, 0, -0.1, 0)}):Play()
        task.delay(ANIMATION_SPEED, function()
            notif:Destroy()
        end)
    end)
end, 0)

-- Слайдер громкости
createSlider(container, "🔊 Громкость", 0, 100, 50, function(value)
    currentVolume = value
    print("Громкость изменена на:", value, "%")
end, 60)

-- Чекбокс "Эффекты"
createCheckbox(container, "✨ Включить спецэффекты", true, function(checked)
    if checked then
        print("Спецэффекты включены ✨")
    else
        print("Спецэффекты выключены ⚡")
    end
end, 140)

-- Чекбокс "Уведомления"
createCheckbox(container, "🔔 Показывать уведомления", true, function(checked)
    print("Уведомления:", checked and "включены" or "выключены")
end, 190)

-- Текстовое поле для ввода имени
local nameValue = ""
createTextbox(container, "Введите ваше имя", function(text)
    nameValue = text
    print("Имя сохранено:", text)
end, 250)

-- Кнопка "Сохранить настройки"
createButton(container, "💾 Сохранить все настройки", function()
    print("=== НАСТРОЙКИ СОХРАНЕНЫ ===")
    print("Громкость:", currentVolume, "%")
    print("Имя:", nameValue ~= "" and nameValue or "не указано")
    print("==========================")
end, 320)

-- Кнопка "О программе"
createButton(container, "ℹ️ О программе", function()
    print("=== Modern UI Framework ===")
    print("Версия: 1.0.0")
    print("Разработчик: YourName")
    print("Компоненты: Кнопки, Слайдеры, Чекбоксы, Текстовые поля")
    print("==========================")
end, 380)

-- Анимация появления окна
local screenGui = container.Parent.Parent
local mainFrame = screenGui:FindFirstChildWhichIsA("Frame")
local overlay = screenGui:FindFirstChild("ImageButton")

mainFrame.Size = UDim2.new(0, 0, 0, 0)
overlay.ImageTransparency = 1

TweenService:Create(mainFrame, TI, {Size = UDim2.new(0, 400, 0, 550)}):Play()
TweenService:Create(overlay, TI, {ImageTransparency = 0.3}):Play()

print("✅ UI Framework загружен! Нажмите на кнопки для тестирования.")
