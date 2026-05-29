--[[
    МОБИЛЬНЫЙ UI ФРЕЙМВОРК
    Оптимизирован для сенсорного управления
    Поддержка: телефоны, планшеты, ПК
--]]

--// Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TouchService = game:GetService("TouchEnabled") and UserInputService or nil
local LocalPlayer = Players.LocalPlayer

--// Определяем платформу
local isMobile = UserInputService.TouchEnabled
local isStudio = game:GetService("RunService"):IsStudio()

--// Константы
local UI_THEME = {
    Primary = Color3.fromRGB(134, 142, 255),
    Secondary = Color3.fromRGB(83, 87, 158),
    Background = Color3.fromRGB(25, 25, 25),
    BackgroundDark = Color3.fromRGB(18, 18, 18),
    BackgroundLight = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(200, 200, 200),
    TextDark = Color3.fromRGB(100, 100, 100),
    Success = Color3.fromRGB(60, 150, 107),
    Danger = Color3.fromRGB(170, 89, 91),
    Warning = Color3.fromRGB(255, 170, 51)
}

local ANIMATION_SPEED = 0.25
local TI = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

--// Размеры для мобильных устройств (увеличенные)
local MOBILE_SIZES = {
    ButtonHeight = isMobile and 60 or 45,
    SliderHeight = isMobile and 85 or 70,
    CheckboxHeight = isMobile and 55 or 40,
    TextboxHeight = isMobile and 65 or 50,
    FontSize = isMobile and 16 or 14,
    TitleSize = isMobile and 20 or 18,
    Padding = isMobile and 15 or 10
}

--// ============ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ============

local function createStyledFrame(parent, size, position, color, transparency, radius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or UI_THEME.Background
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = frame
    
    return frame
end

local function createTextLabel(parent, text, size, position, color, font, textSize, alignment)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = color or UI_THEME.Text
    label.Font = font or Enum.Font.GothamSemibold
    label.TextSize = textSize or MOBILE_SIZES.FontSize
    label.TextXAlignment = alignment or Enum.TextXAlignment.Center
    label.Parent = parent
    return label
end

--// ============ УВЕДОМЛЕНИЯ (Тост-сообщения) ============

local function showToast(message, type, duration)
    local screenGui = game:GetService("CoreGui"):FindFirstChild("ModernUI")
    if not screenGui then return end
    
    local toast = createStyledFrame(screenGui, UDim2.new(0, 300, 0, 50), 
        UDim2.new(0.5, -150, 1, -70), 
        type == "success" and UI_THEME.Success or 
        type == "error" and UI_THEME.Danger or 
        type == "warning" and UI_THEME.Warning or 
        UI_THEME.Primary, 0.95, 8)
    toast.ZIndex = 1000
    
    local toastText = createTextLabel(toast, message, UDim2.new(1, -20, 1, 0), 
        UDim2.new(0.02, 0, 0, 0), Color3.fromRGB(255, 255, 255), Enum.Font.Gotham, 14, Enum.TextXAlignment.Left)
    
    toast.Position = UDim2.new(0.5, -150, 1, -70)
    toast.BackgroundTransparency = 0.3
    
    TweenService:Create(toast, TI, {
        Position = UDim2.new(0.5, -150, 1, -130),
        BackgroundTransparency = 0.95
    }):Play()
    
    task.delay(duration or 2, function()
        TweenService:Create(toast, TI, {
            Position = UDim2.new(0.5, -150, 1, -70),
            BackgroundTransparency = 0.3
        }):Play()
        task.delay(ANIMATION_SPEED, function()
            toast:Destroy()
        end)
    end)
end

--// ============ КОМПОНЕНТ КНОПКИ (С поддержкой тач-событий) ============

local function createButton(parent, title, callback, yOffset, iconId)
    local button = createStyledFrame(parent, UDim2.new(0.92, 0, 0, MOBILE_SIZES.ButtonHeight), 
        UDim2.new(0.04, 0, yOffset or 0, 0), UI_THEME.BackgroundLight, 0.9, 12)
    
    -- Тень для мобильных (лучше видимость)
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 0, 1, 4)
    shadow.Position = UDim2.new(0, 0, 1, 0)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.BorderSizePixel = 0
    shadow.Parent = button
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow
    
    -- Иконка
    local icon = nil
    if iconId then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0.05, 0, 0.5, -15)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ImageColor3 = UI_THEME.Text
        icon.Parent = button
    end
    
    local text = createTextLabel(button, title, UDim2.new(1, -60, 1, 0), 
        UDim2.new(icon and 0.15 or 0.05, 0, 0, 0), UI_THEME.Text, Enum.Font.GothamSemibold, MOBILE_SIZES.FontSize, 
        icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center)
    
    -- Эффект нажатия
    local pressFrame = Instance.new("Frame")
    pressFrame.Size = UDim2.new(1, 0, 1, 0)
    pressFrame.BackgroundColor3 = UI_THEME.Primary
    pressFrame.BackgroundTransparency = 1
    pressFrame.BorderSizePixel = 0
    pressFrame.Parent = button
    
    local pressCorner = Instance.new("UICorner")
    pressCorner.CornerRadius = UDim.new(0, 12)
    pressCorner.Parent = pressFrame
    
    local isPressed = false
    
    local function onPress()
        if isPressed then return end
        isPressed = true
        
        TweenService:Create(pressFrame, TI, {BackgroundTransparency = 0.85}):Play()
        TweenService:Create(text, TI, {TextColor3 = UI_THEME.Primary}):Play()
        if icon then
            TweenService:Create(icon, TI, {ImageColor3 = UI_THEME.Primary}):Play()
        end
        TweenService:Create(button, TI, {Size = UDim2.new(0.92, 0, 0, MOBILE_SIZES.ButtonHeight - 4)}):Play()
        
        -- Тактильная обратная связь (вибрация на мобильных)
        if isMobile and UserInputService.Vibrate then
            UserInputService:Vibrate()
        end
        
        callback()
        
        task.delay(0.15, function()
            TweenService:Create(pressFrame, TI, {BackgroundTransparency = 1}):Play()
            TweenService:Create(text, TI, {TextColor3 = UI_THEME.Text}):Play()
            if icon then
                TweenService:Create(icon, TI, {ImageColor3 = UI_THEME.Text}):Play()
            end
            TweenService:Create(button, TI, {Size = UDim2.new(0.92, 0, 0, MOBILE_SIZES.ButtonHeight)}):Play()
            isPressed = false
        end)
    end
    
    -- Поддержка и тач, и мыши
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            onPress()
        end
    end)
    
    return button
end

--// ============ КОМПОНЕНТ СЛАЙДЕРА (Для пальцев) ============

local function createSlider(parent, title, minValue, maxValue, defaultValue, callback, yOffset, formatFunc)
    local container = createStyledFrame(parent, UDim2.new(0.92, 0, 0, MOBILE_SIZES.SliderHeight), 
        UDim2.new(0.04, 0, yOffset or 0, 0), UI_THEME.BackgroundLight, 0.9, 12)
    
    local titleLabel = createTextLabel(container, title, UDim2.new(1, -20, 0.4, 0), 
        UDim2.new(0.04, 0, 0.1, 0), UI_THEME.Text, Enum.Font.Gotham, MOBILE_SIZES.FontSize - 2, Enum.TextXAlignment.Left)
    
    local valueLabel = createTextLabel(container, "", UDim2.new(0.4, 0, 0.4, 0), 
        UDim2.new(0.56, 0, 0.1, 0), UI_THEME.Primary, Enum.Font.GothamBold, MOBILE_SIZES.FontSize, Enum.TextXAlignment.Right)
    
    -- Увеличенная область для пальца
    local sliderBg = createStyledFrame(container, UDim2.new(0.92, 0, 0, isMobile and 8 or 6), 
        UDim2.new(0.04, 0, 0.7, -4), Color3.fromRGB(40, 40, 40), 0.5, isMobile and 4 or 3)
    
    local sliderFill = createStyledFrame(sliderBg, UDim2.new(0, 0, 1, 0), 
        UDim2.new(0, 0, 0, 0), UI_THEME.Primary, 1, isMobile and 4 or 3)
    
    -- Увеличенный ползунок для пальцев
    local knobSize = isMobile and 28 or 20
    local knob = Instance.new("ImageButton")
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.Position = UDim2.new(0, -knobSize/2, 0.5, -knobSize/2)
    knob.BackgroundColor3 = UI_THEME.Primary
    knob.BackgroundTransparency = 0
    knob.BorderSizePixel = 0
    knob.Image = "rbxassetid://6020299385"
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Тень ползунка
    local knobShadow = Instance.new("Frame")
    knobShadow.Size = UDim2.new(0, knobSize + 4, 0, knobSize + 4)
    knobShadow.Position = UDim2.new(0, -knobSize/2 - 2, 0.5, -knobSize/2 - 2)
    knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.5
    knobShadow.BorderSizePixel = 0
    knobShadow.Parent = sliderBg
    knobShadow.ZIndex = -1
    
    local knobShadowCorner = Instance.new("UICorner")
    knobShadowCorner.CornerRadius = UDim.new(1, 0)
    knobShadowCorner.Parent = knobShadow
    
    local currentValue = defaultValue or minValue
    local isDragging = false
    local dragConnection = nil
    local endConnection = nil
    
    local function formatValue(value)
        if formatFunc then
            return formatFunc(value)
        end
        return tostring(math.floor(value))
    end
    
    local function updateValue(value, fromDrag)
        currentValue = math.clamp(value, minValue, maxValue)
        local percent = (currentValue - minValue) / (maxValue - minValue)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -knobSize/2, 0.5, -knobSize/2)
        knobShadow.Position = UDim2.new(percent, -knobSize/2 - 2, 0.5, -knobSize/2 - 2)
        valueLabel.Text = formatValue(currentValue)
        
        if not fromDrag then
            callback(currentValue)
        end
    end
    
    local function onDrag(input)
        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local newValue = minValue + (maxValue - minValue) * percent
        currentValue = math.clamp(newValue, minValue, maxValue)
        local newPercent = (currentValue - minValue) / (maxValue - minValue)
        
        sliderFill.Size = UDim2.new(newPercent, 0, 1, 0)
        knob.Position = UDim2.new(newPercent, -knobSize/2, 0.5, -knobSize/2)
        knobShadow.Position = UDim2.new(newPercent, -knobSize/2 - 2, 0.5, -knobSize/2 - 2)
        valueLabel.Text = formatValue(currentValue)
    end
    
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            
            -- Сразу обновляем значение по месту касания
            onDrag(input)
            
            dragConnection = RunService.RenderStepped:Connect(function()
                if isDragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    onDrag({Position = mousePos})
                end
            end)
            
            endConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    isDragging = false
                    callback(currentValue)
                    if dragConnection then dragConnection:Disconnect() end
                    if endConnection then endConnection:Disconnect() end
                    
                    -- Тактильная обратная связь
                    if isMobile and UserInputService.Vibrate then
                        UserInputService:Vibrate()
                    end
                end
            end)
        end
    end
    
    knob.InputBegan:Connect(startDrag)
    sliderBg.InputBegan:Connect(startDrag)
    
    updateValue(defaultValue or minValue, false)
    
    return container
end

--// ============ КОМПОНЕНТ ЧЕКБОКСА (Увеличенный для пальцев) ============

local function createCheckbox(parent, title, defaultValue, callback, yOffset, description)
    local container = createStyledFrame(parent, UDim2.new(0.92, 0, 0, MOBILE_SIZES.CheckboxHeight), 
        UDim2.new(0.04, 0, yOffset or 0, 0), UI_THEME.BackgroundLight, 0.9, 12)
    
    -- Увеличенная область для нажатия пальцем
    local touchArea = Instance.new("ImageButton")
    touchArea.Size = UDim2.new(1, 0, 1, 0)
    touchArea.BackgroundTransparency = 1
    touchArea.AutoButtonColor = false
    touchArea.Parent = container
    
    local checkBoxSize = isMobile and 32 or 24
    local checkBox = createStyledFrame(container, UDim2.new(0, checkBoxSize, 0, checkBoxSize), 
        UDim2.new(0.04, 0, 0.5, -checkBoxSize/2), UI_THEME.Background, 0, 8)
    
    local checkMark = Instance.new("ImageLabel")
    checkMark.Size = UDim2.new(0.7, 0, 0.7, 0)
    checkMark.Position = UDim2.new(0.15, 0, 0.15, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Image = "rbxassetid://7072706620"
    checkMark.ImageColor3 = UI_THEME.Primary
    checkMark.ImageTransparency = 1
    checkMark.Parent = checkBox
    
    local titleLabel = createTextLabel(container, title, UDim2.new(0.7, 0, description and 0.5 or 1, 0), 
        UDim2.new(0.12, 0, description and 0.25 or 0.5, -10), UI_THEME.Text, Enum.Font.Gotham, MOBILE_SIZES.FontSize - 1, Enum.TextXAlignment.Left)
    
    local descLabel = nil
    if description then
        descLabel = createTextLabel(container, description, UDim2.new(0.7, 0, 0.3, 0), 
            UDim2.new(0.12, 0, 0.6, 0), UI_THEME.TextDark, Enum.Font.Gotham, MOBILE_SIZES.FontSize - 4, Enum.TextXAlignment.Left)
    end
    
    local isChecked = defaultValue or false
    
    local function setChecked(checked, silent)
        isChecked = checked
        if checked then
            TweenService:Create(checkBox, TI, {BackgroundColor3 = UI_THEME.Primary}):Play()
            TweenService:Create(checkMark, TI, {ImageTransparency = 0}):Play()
        else
            TweenService:Create(checkBox, TI, {BackgroundColor3 = UI_THEME.Background}):Play()
            TweenService:Create(checkMark, TI, {ImageTransparency = 1}):Play()
        end
        
        if not silent then
            callback(isChecked)
            if isMobile and UserInputService.Vibrate then
                UserInputService:Vibrate()
            end
        end
    end
    
    setChecked(isChecked, true)
    
    -- Эффект нажатия
    local pressFrame = Instance.new("Frame")
    pressFrame.Size = UDim2.new(1, 0, 1, 0)
    pressFrame.BackgroundColor3 = UI_THEME.Primary
    pressFrame.BackgroundTransparency = 1
    pressFrame.BorderSizePixel = 0
    pressFrame.Parent = container
    
    local pressCorner = Instance.new("UICorner")
    pressCorner.CornerRadius = UDim.new(0, 12)
    pressCorner.Parent = pressFrame
    
    touchArea.MouseButton1Click:Connect(function()
        TweenService:Create(pressFrame, TI, {BackgroundTransparency = 0.9}):Play()
        setChecked(not isChecked, false)
        task.delay(0.1, function()
            TweenService:Create(pressFrame, TI, {BackgroundTransparency = 1}):Play()
        end)
    end)
    
    return container, setChecked
end

--// ============ КОМПОНЕНТ ВЫБОРА (Модальное окно для мобильных) ============

local function createPicker(parent, title, items, defaultItem, callback, yOffset)
    local container = createStyledFrame(parent, UDim2.new(0.92, 0, 0, MOBILE_SIZES.ButtonHeight), 
        UDim2.new(0.04, 0, yOffset or 0, 0), UI_THEME.BackgroundLight, 0.9, 12)
    
    local titleLabel = createTextLabel(container, title, UDim2.new(0.6, 0, 1, 0), 
        UDim2.new(0.04, 0, 0, 0), UI_THEME.Text, Enum.Font.Gotham, MOBILE_SIZES.FontSize - 1, Enum.TextXAlignment.Left)
    
    local selectedLabel = createTextLabel(container, defaultItem or items[1], UDim2.new(0.3, 0, 0.6, 0), 
        UDim2.new(0.62, 0, 0.2, 0), UI_THEME.Primary, Enum.Font.GothamBold, MOBILE_SIZES.FontSize, Enum.TextXAlignment.Right)
    
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(0.94, 0, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://7072706663"
    arrow.ImageColor3 = UI_THEME.Text
    arrow.Parent = container
    
    local currentItem = defaultItem or items[1]
    local modalOpen = false
    local modal = nil
    
    local function closeModal()
        if modal then
            TweenService:Create(modal, TI, {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
            task.delay(ANIMATION_SPEED, function()
                if modal then modal:Destroy() end
                modal = nil
            end)
            modalOpen = false
        end
    end
    
    local function openModal()
        if modalOpen then return end
        modalOpen = true
        
        local screenGui = game:GetService("CoreGui"):FindFirstChild("ModernUI")
        if not screenGui then return end
        
        -- Затемнение
        local overlay = Instance.new("ImageButton")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundTransparency = 1
        overlay.Image = "rbxassetid://7880418493"
        overlay.ImageColor3 = Color3.fromRGB(0, 0, 0)
        overlay.ImageTransparency = 0.5
        overlay.AutoButtonColor = false
        overlay.Parent = screenGui
        overlay.ZIndex = 2000
        
        overlay.MouseButton1Click:Connect(function()
            closeModal()
            overlay:Destroy()
        end)
        
        -- Модальное окно
        modal = createStyledFrame(screenGui, UDim2.new(0.85, 0, 0.5, 0), 
            UDim2.new(0.5, -170, 1.5, 0), UI_THEME.BackgroundDark, 0.95, 16)
        modal.ZIndex = 2001
        
        local modalTitle = createTextLabel(modal, title, UDim2.new(1, 0, 0.15, 0), 
            UDim2.new(0, 0, 0, 0), UI_THEME.Primary, Enum.Font.GothamBold, MOBILE_SIZES.TitleSize)
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 5)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = modal
        
        local function selectItem(item)
            currentItem = item
            selectedLabel.Text = item
            callback(item)
            closeModal()
            overlay:Destroy()
        end
        
        for i, item in ipairs(items) do
            local itemBtn = createStyledFrame(modal, UDim2.new(0.94, 0, 0, 50), 
                UDim2.new(0.03, 0, 0, 0), UI_THEME.BackgroundLight, 0.9, 10)
            itemBtn.LayoutOrder = i
            
            local itemText = createTextLabel(itemBtn, item, UDim2.new(1, 0, 1, 0), 
                UDim2.new(0, 0, 0, 0), item == currentItem and UI_THEME.Primary or UI_THEME.Text, 
                Enum.Font.Gotham, MOBILE_SIZES.FontSize)
            
            -- Эффект нажатия
            local itemPress = Instance.new("Frame")
            itemPress.Size = UDim2.new(1, 0, 1, 0)
            itemPress.BackgroundColor3 = UI_THEME.Primary
            itemPress.BackgroundTransparency = 1
            itemPress.BorderSizePixel = 0
            itemPress.Parent = itemBtn
            
            local itemPressCorner = Instance.new("UICorner")
            itemPressCorner.CornerRadius = UDim.new(0, 10)
            itemPressCorner.Parent = itemPress
            
            itemBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(itemPress, TI, {BackgroundTransparency = 0.85}):Play()
                    task.delay(0.1, function()
                        selectItem(item)
                    end)
                end
            end)
        end
        
        TweenService:Create(modal, TI, {Position = UDim2.new(0.5, -170, 0.5, -150)}):Play()
    end
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            openModal()
        end
    end)
    
    return container
end

--// ============ ОСНОВНОЕ ОКНО (С поддержкой свайпов) ============

local function createMainWindow(title)
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
    overlay.ImageTransparency = 0.4
    overlay.AutoButtonColor = false
    overlay.Parent = screenGui
    overlay.ZIndex = 0
    
    -- Определяем размеры для мобильных
    local windowWidth = isMobile and 400 or 450
    local windowHeight = isMobile and 600 or 550
    
    local mainFrame = createStyledFrame(screenGui, UDim2.new(0, windowWidth, 0, windowHeight), 
        UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2), UI_THEME.BackgroundDark, 0.98, 16)
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
    shadowCorner.CornerRadius = UDim.new(0, 20)
    shadowCorner.Parent = shadow
    
    -- Заголовок
    local titleBarHeight = isMobile and 60 or 50
    local titleBar = createStyledFrame(mainFrame, UDim2.new(1, 0, 0, titleBarHeight), 
        UDim2.new(0, 0, 0, 0), UI_THEME.Primary, 1, 16)
    titleBar.BackgroundTransparency = 0
    
    -- Скругление только сверху
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    
    local clipFrame = Instance.new("Frame")
    clipFrame.Size = UDim2.new(1, 0, 1, 0)
    clipFrame.BackgroundTransparency = 1
    clipFrame.ClipsDescendants = true
    clipFrame.Parent = titleBar
    
    local titleText = createTextLabel(clipFrame, title, UDim2.new(0.8, 0, 1, 0), 
        UDim2.new(0.05, 0, 0, 0), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, MOBILE_SIZES.TitleSize, Enum.TextXAlignment.Left)
    
    -- Кнопка закрытия (увеличенная для пальцев)
    local closeBtnSize = isMobile and 44 or 36
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, closeBtnSize, 0, closeBtnSize)
    closeBtn.Position = UDim2.new(1, -closeBtnSize - 10, 0.5, -closeBtnSize/2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://7072725342"
    closeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = titleBar
    
    -- Контейнер для контента (скроллинг с инерцией для мобильных)
    local scrollContainer = Instance.new("ScrollingFrame")
    scrollContainer.Size = UDim2.new(1, 0, 1, -titleBarHeight)
    scrollContainer.Position = UDim2.new(0, 0, 0, titleBarHeight)
    scrollContainer.BackgroundTransparency = 1
    scrollContainer.BorderSizePixel = 0
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollContainer.ScrollBarThickness = isMobile and 6 or 4
    scrollContainer.ScrollBarImageColor3 = UI_THEME.Primary
    scrollContainer.ScrollBarImageTransparency = isMobile and 0.3 or 0.5
    scrollContainer.ElasticBehavior = Enum.ElasticBehavior.Always
    scrollContainer.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, isMobile and 12 or 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollContainer
    
    -- Функция обновления CanvasSize
    local function updateCanvasSize()
        task.wait()
        scrollContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    updateCanvasSize()
    
    -- Анимация появления окна
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    overlay.ImageTransparency = 1
    
    TweenService:Create(mainFrame, TI, {Size = UDim2.new(0, windowWidth, 0, windowHeight)}):Play()
    TweenService:Create(overlay, TI, {ImageTransparency = 0.4}):Play()
    
    -- Закрытие
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TI, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(overlay, TI, {ImageTransparency = 1}):Play()
        task.delay(ANIMATION_SPEED, function()
            screenGui:Destroy()
        end)
    end)
    
    -- Drag and drop (только для ПК, на мобильных отключаем)
    if not isMobile then
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
    end
    
    return scrollContainer, layout, screenGui
end

--// ============ ДЕМОНСТРАЦИЯ ============

-- Создаем UI
local container, layout, screenGui = createMainWindow("МОБИЛЬНЫЙ UI")

-- Переменные для хранения значений
local settings = {
    volume = 75,
    effects = true,
    notifications = true,
    quality = "Среднее",
    playerName = "",
    autoSave = false
}

-- Приветственная кнопка
createButton(container, "👋 Привет!", function()
    showToast("Добро пожаловать в мобильный UI! 🎉", "success", 2)
end, 0, "rbxassetid://6020299385")

-- Слайдер громкости
createSlider(container, "🔊 Громкость", 0, 100, settings.volume, function(value)
    settings.volume = value
    showToast("Громкость: " .. value .. "%", "info", 1)
end, 70, function(v) return v .. "%" end)

-- Чекбокс эффектов
createCheckbox(container, "✨ Спецэффекты", settings.effects, function(checked)
    settings.effects = checked
    showToast("Спецэффекты " .. (checked and "включены ✨" or "выключены ⚡"), "info", 1.5)
end, 165, "Визуальные эффекты в игре")

-- Чекбокс уведомлений
createCheckbox(container, "🔔 Уведомления", settings.notifications, function(checked)
    settings.notifications = checked
    showToast("Уведомления " .. (checked and "включены" or "выключены"), "info", 1.5)
end, 230)

-- Выбор качества
createPicker(container, "🎮 Качество графики", {"Низкое", "Среднее", "Высокое", "Максимальное"}, 
    settings.quality, function(value)
    settings.quality = value
    showToast("Качество: " .. value, "success", 1.5)
end, 295)

-- Кнопка сохранения
createButton(container, "💾 Сохранить настройки", function()
    showToast("Настройки сохранены! ✅", "success", 2)
    print("=== СОХРАНЕННЫЕ НАСТРОЙКИ ===")
    print("Громкость:", settings.volume, "%")
    print("Спецэффекты:", settings.effects)
    print("Уведомления:", settings.notifications)
    print("Качество:", settings.quality)
    print("============================")
end, 370, "rbxassetid://7072706620")

-- Кнопка выхода
createButton(container, "❌ Выход", function()
    showToast("До свидания! 👋", "warning", 1.5)
    task.delay(1, function()
        if screenGui then screenGui:Destroy() end
    end)
end, 440, "rbxassetid://7072725342")

print("✅ Мобильный UI Framework загружен!")
print("📱 Платформа:", isMobile and "Мобильное устройство" or "ПК/Ноутбук")
