--[[
    Мобильный GUI на основе Rayfield
    Оптимизирован для сенсорного управления
]]

-- Службы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создаем основной ScreenGui
local MobileGUI = Instance.new("ScreenGui")
MobileGUI.Name = "MobileGUI"
MobileGUI.Parent = PlayerGui
MobileGUI.ResetOnSpawn = false

-- Главный фрейм (основное окно)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MobileGUI

-- Скругление углов
local Corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = MainFrame

-- Тень (для эффекта глубины)
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 8, 1, 8)
Shadow.Position = UDim2.new(0, -4, 0, -4)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = -1
Shadow.Parent = MainFrame
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 20)
ShadowCorner.Parent = Shadow

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 54)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 16)
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Mobile UI Suite"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка закрытия (свайп или кнопка, для мобильных лучше кнопка)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0.5, -20)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    MobileGUI.Enabled = false
end)

-- Контейнер для содержимого (скроллинг)
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, 0, 1, -110)
ScrollContainer.Position = UDim2.new(0, 0, 0, 70)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.ScrollBarThickness = 0
ScrollContainer.Parent = MainFrame

-- Размещаем элементы в сетку с помощью UIGridLayout
local GridLayout = Instance.new("UIGridLayout")
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
GridLayout.CellPadding = UDim.new(0, 12)
GridLayout.CellSize = UDim2.new(0.5, -6, 0, 120) -- Адаптивная ширина для 2 колонок
GridLayout.Parent = ScrollContainer

-- Нижняя панель навигации (Tab Bar)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 70)
TabBar.Position = UDim2.new(0, 0, 1, -70)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 12)
TabBarCorner.Parent = TabBar

-- Контейнер для кнопок вкладок
local TabButtonsContainer = Instance.new("Frame")
TabButtonsContainer.Size = UDim2.new(1, 0, 1, 0)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsContainer.Parent = TabBar

local TabButtonLayout = Instance.new("UIListLayout")
TabButtonLayout.FillDirection = Enum.FillDirection.Horizontal
TabButtonLayout.Padding = UDim.new(0, 0)
TabButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabButtonLayout.Parent = TabButtonsContainer

-- Система уведомлений
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Size = UDim2.new(1, 0, 1, 0)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = MobileGUI

-- === Функционал библиотеки ===

-- Хранилище для элементов
local Elements = {}
local CurrentTab = nil

-- Функция создания уведомления
local function Notify(title, message, duration)
    duration = duration or 3
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0.9, 0, 0, 80)
    notification.Position = UDim2.new(0.5, 0, 1, -100)
    notification.AnchorPoint = Vector2.new(0.5, 1)
    notification.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.Parent = NotificationHolder
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 12)
    notifCorner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notification
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 30)
    msgLabel.Position = UDim2.new(0, 10, 0, 40)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    msgLabel.TextSize = 14
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.Parent = notification
    
    -- Анимация появления
    notification.BackgroundTransparency = 1
    notification.Position = UDim2.new(0.5, 0, 1, 0)
    TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, -100)}):Play()
    
    task.delay(duration, function()
        TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- Функция создания карточки элемента
local function CreateCard(title, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -12, 1, -12)
    card.Position = UDim2.new(0, 6, 0, 6)
    card.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    card.BackgroundTransparency = 0
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = ScrollContainer
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, 0, 0, 40)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cardTitle.TextSize = 16
    cardTitle.TextXAlignment = Enum.TextXAlignment.Center
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.Parent = card
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = card
    
    return card, contentFrame
end

-- Функция создания кнопки
local function CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 45)
    button.Position = UDim2.new(0.5, 0, 0.5, 0)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    -- Визуальный фидбек для мобильных
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}):Play()
    end)
end

-- Функция создания переключателя
local function CreateToggle(parent, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0.9, 0, 0, 50)
    toggleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 30)
    toggleButton.Position = UDim2.new(1, -10, 0.5, -15)
    toggleButton.AnchorPoint = Vector2.new(1, 0)
    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
    toggleButton.Text = defaultValue and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 12
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    local toggleBtnCorner = Instance.new("UICorner")
    toggleBtnCorner.CornerRadius = UDim.new(1, 0)
    toggleBtnCorner.Parent = toggleButton
    
    local state = defaultValue
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
        toggleButton.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- Функция создания слайдера
local function CreateSlider(parent, text, minVal, maxVal, defaultVal, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 70)
    sliderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    sliderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = parent
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(defaultVal)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = sliderFrame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0.9, 0, 0, 4)
    sliderBar.Position = UDim2.new(0.5, 0, 0.7, 0)
    sliderBar.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = sliderFrame
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = sliderBar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0, 40, 0, 25)
    valueDisplay.Position = UDim2.new(1, -45, 0, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(defaultVal)
    valueDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueDisplay.TextSize = 12
    valueDisplay.Font = Enum.Font.Gotham
    valueDisplay.Parent = sliderFrame
    
    -- Симуляция слайдера для мобильных (просто кнопки +/-, т.к. слайдер сложен на мобилках без джойстика)
    local decButton = Instance.new("TextButton")
    decButton.Size = UDim2.new(0, 35, 0, 35)
    decButton.Position = UDim2.new(0.5, -50, 0.7, -17.5)
    decButton.AnchorPoint = Vector2.new(0.5, 0)
    decButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    decButton.Text = "-"
    decButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    decButton.TextSize = 20
    decButton.Font = Enum.Font.GothamBold
    decButton.BorderSizePixel = 0
    decButton.Parent = sliderFrame
    local decCorner = Instance.new("UICorner")
    decCorner.CornerRadius = UDim.new(1, 0)
    decCorner.Parent = decButton
    
    local incButton = Instance.new("TextButton")
    incButton.Size = UDim2.new(0, 35, 0, 35)
    incButton.Position = UDim2.new(0.5, 50, 0.7, -17.5)
    incButton.AnchorPoint = Vector2.new(0.5, 0)
    incButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    incButton.Text = "+"
    incButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    incButton.TextSize = 20
    incButton.Font = Enum.Font.GothamBold
    incButton.BorderSizePixel = 0
    incButton.Parent = sliderFrame
    local incCorner = Instance.new("UICorner")
    incCorner.CornerRadius = UDim.new(1, 0)
    incCorner.Parent = incButton
    
    local current = defaultVal
    local function updateSlider(val)
        current = math.clamp(val, minVal, maxVal)
        fill.Size = UDim2.new((current - minVal) / (maxVal - minVal), 0, 1, 0)
        label.Text = text .. ": " .. tostring(math.floor(current * 100) / 100)
        valueDisplay.Text = tostring(math.floor(current * 100) / 100)
        callback(current)
    end
    
    decButton.MouseButton1Click:Connect(function()
        updateSlider(current - 1)
    end)
    incButton.MouseButton1Click:Connect(function()
        updateSlider(current + 1)
    end)
    
    updateSlider(defaultVal)
end

-- Функция создания поля ввода
local function CreateInput(parent, placeholder, callback)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0.9, 0, 0, 45)
    inputFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    inputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = parent
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and textBox.Text ~= "" then
            callback(textBox.Text)
            textBox.Text = ""
        end
    end)
end

-- Функция создания вкладки
local function CreateTab(name, order)
    -- Кнопка на нижней панели
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundTransparency = 1
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = TabButtonsContainer
    
    -- Контейнер для элементов вкладки (будет показываться/скрываться)
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Visible = (CurrentTab == nil)
    tabContainer.Parent = ScrollContainer
    
    local tabGrid = Instance.new("UIGridLayout")
    tabGrid.SortOrder = Enum.SortOrder.LayoutOrder
    tabGrid.CellPadding = UDim.new(0, 12)
    tabGrid.CellSize = UDim2.new(0.5, -6, 0, 120)
    tabGrid.Parent = tabContainer
    
    tabButton.MouseButton1Click:Connect(function()
        if CurrentTab == tabContainer then return end
        if CurrentTab then CurrentTab.Visible = false end
        tabContainer.Visible = true
        CurrentTab = tabContainer
        
        -- Обновляем стиль кнопок
        for _, btn in ipairs(TabButtonsContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    if order == 1 then
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = tabContainer
    end
    
    local api = {}
    
    function api:Button(text, callback)
        local card, content = CreateCard(text, #tabContainer:GetChildren())
        card.Parent = tabContainer
        CreateButton(content, text, callback)
    end
    
    function api:Toggle(text, default, callback)
        local card, content = CreateCard(text, #tabContainer:GetChildren())
        card.Parent = tabContainer
        CreateToggle(content, text, default, callback)
    end
    
    function api:Slider(text, min, max, default, callback)
        local card, content = CreateCard(text, #tabContainer:GetChildren())
        card.Parent = tabContainer
        CreateSlider(content, text, min, max, default, callback)
    end
    
    function api:Input(placeholder, callback)
        local card, content = CreateCard(placeholder, #tabContainer:GetChildren())
        card.Parent = tabContainer
        CreateInput(content, placeholder, callback)
    end
    
    return api
end

-- Публичное API
local MobileUI = {}

function MobileUI:Notify(title, message, duration)
    Notify(title, message, duration)
end

function MobileUI:Tab(name)
    local tabsCount = #TabButtonsContainer:GetChildren() + 1
    return CreateTab(name, tabsCount)
end

function MobileUI:SetTitle(title)
    TitleLabel.Text = title
end

function MobileUI:Destroy()
    MobileGUI:Destroy()
end

-- Инициализация и возврат
Notify("Добро пожаловать!", "Интерфейс оптимизирован для мобильных устройств", 3)

return MobileUI
