--[[
    ============================================
    ЧИСТАЯ UI БИБЛИОТЕКА ДЛЯ ROBLOX
    Автор: Переписано с оригинального Kavo UI
    Версия: 2.0 (Clean Edition)
    ============================================
    
    Функции:
    - Создание окон с перетаскиванием
    - Вкладки (Tabs)
    - Секции (Sections)
    - Кнопки (Buttons)
    - Переключатели (Toggles)
    - Текстовые поля (Textboxes)
    - Ползунки (Sliders)
    - Система подсказок (Tooltips)
    - Настраиваемые темы
]]

-- ============================================
-- ОСНОВНОЙ МОДУЛЬ
-- ============================================
local CleanUI = {}

-- Подключаем сервисы Roblox
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================

-- Плавная анимация
local function Animate(object, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Создание скругленного угла
local function AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = instance
    return corner
end

-- ============================================
-- НАСТРОЙКИ ПО УМОЛЧАНИЮ
-- ============================================
local DefaultTheme = {
    MainBackground = Color3.fromRGB(36, 37, 43),      -- Фон главного окна
    SidebarColor = Color3.fromRGB(28, 29, 34),        -- Цвет боковой панели
    AccentColor = Color3.fromRGB(74, 99, 135),        -- Основной акцентный цвет
    ElementColor = Color3.fromRGB(32, 32, 38),        -- Цвет фона элементов
    TextColor = Color3.fromRGB(255, 255, 255),        -- Цвет текста
}

-- Предустановленные темы
local PresetThemes = {
    Dark = {
        MainBackground = Color3.fromRGB(20, 20, 20),
        SidebarColor = Color3.fromRGB(15, 15, 15),
        AccentColor = Color3.fromRGB(112, 112, 112),
        ElementColor = Color3.fromRGB(25, 25, 25),
        TextColor = Color3.fromRGB(255, 255, 255),
    },
    Purple = {
        MainBackground = Color3.fromRGB(20, 20, 20),
        SidebarColor = Color3.fromRGB(15, 15, 15),
        AccentColor = Color3.fromRGB(139, 123, 139),
        ElementColor = Color3.fromRGB(25, 25, 25),
        TextColor = Color3.fromRGB(255, 255, 255),
    },
    Blue = {
        MainBackground = Color3.fromRGB(20, 20, 20),
        SidebarColor = Color3.fromRGB(15, 15, 15),
        AccentColor = Color3.fromRGB(91, 94, 176),
        ElementColor = Color3.fromRGB(25, 25, 25),
        TextColor = Color3.fromRGB(255, 255, 255),
    },
    Green = {
        MainBackground = Color3.fromRGB(20, 20, 20),
        SidebarColor = Color3.fromRGB(15, 15, 15),
        AccentColor = Color3.fromRGB(86, 128, 61),
        ElementColor = Color3.fromRGB(25, 25, 25),
        TextColor = Color3.fromRGB(255, 255, 255),
    },
}

-- ============================================
-- СИСТЕМА ПЕРЕТАСКИВАНИЯ ОКНА
-- ============================================
local function MakeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================
-- СИСТЕМА ПОДСКАЗОК
-- ============================================
local TooltipSystem = {}
local currentTooltip = nil

function TooltipSystem:Show(text, parent)
    if currentTooltip then
        currentTooltip:Destroy()
    end
    
    local tooltip = Instance.new("Frame")
    tooltip.Parent = parent or game.CoreGui
    tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tooltip.BorderSizePixel = 0
    tooltip.Position = UDim2.new(0.5, -150, 0.85, 0)
    tooltip.Size = UDim2.new(0, 300, 0, 30)
    tooltip.ZIndex = 1000
    
    AddCorner(tooltip, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = tooltip
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = "ℹ️ " .. text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    currentTooltip = tooltip
    
    -- Автоматическое скрытие через 2 секунды
    task.delay(2, function()
        if tooltip then
            Animate(tooltip, {BackgroundTransparency = 1}, 0.3)
            task.wait(0.3)
            tooltip:Destroy()
            if currentTooltip == tooltip then
                currentTooltip = nil
            end
        end
    end)
end

-- ============================================
-- КЛАСС: ОКНО (WINDOW)
-- ============================================
local Window = {}
Window.__index = Window

function CleanUI:CreateWindow(title, theme)
    theme = theme or DefaultTheme
    -- Если передано название темы, берем из пресетов
    if type(theme) == "string" and PresetThemes[theme] then
        theme = PresetThemes[theme]
    end
    
    local self = setmetatable({}, Window)
    self.Theme = theme
    self.Title = title or "UI Library"
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Генерируем уникальное имя для ScreenGui
    local guiName = "CleanUI_" .. math.random(1, 999999)
    
    -- Создаем ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = guiName
    self.Gui.Parent = game.CoreGui
    self.Gui.ResetOnSpawn = false
    
    -- Главное окно
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Parent = self.Gui
    self.MainFrame.BackgroundColor3 = theme.MainBackground
    self.MainFrame.Size = UDim2.new(0, 520, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -260, 0.5, -175)
    self.MainFrame.ClipsDescendants = true
    AddCorner(self.MainFrame, 6)
    
    -- Верхняя панель (для перетаскивания)
    self.Header = Instance.new("Frame")
    self.Header.Parent = self.MainFrame
    self.Header.BackgroundColor3 = theme.SidebarColor
    self.Header.Size = UDim2.new(1, 0, 0, 30)
    MakeDraggable(self.Header, self.MainFrame)
    
    -- Заголовок окна
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Parent = self.Header
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    self.TitleLabel.Text = title
    self.TitleLabel.TextColor3 = theme.TextColor
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка закрытия
    self.CloseButton = Instance.new("ImageButton")
    self.CloseButton.Parent = self.Header
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Position = UDim2.new(1, -30, 0, 5)
    self.CloseButton.Size = UDim2.new(0, 20, 0, 20)
    self.CloseButton.Image = "rbxassetid://3926305904"
    self.CloseButton.ImageRectOffset = Vector2.new(284, 4)
    self.CloseButton.ImageRectSize = Vector2.new(24, 24)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Боковая панель (вкладки)
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Parent = self.MainFrame
    self.Sidebar.BackgroundColor3 = theme.SidebarColor
    self.Sidebar.Size = UDim2.new(0, 150, 1, -30)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 30)
    
    -- Контейнер для кнопок вкладок
    self.TabsContainer = Instance.new("Frame")
    self.TabsContainer.Parent = self.Sidebar
    self.TabsContainer.BackgroundTransparency = 1
    self.TabsContainer.Size = UDim2.new(1, -10, 1, 0)
    self.TabsContainer.Position = UDim2.new(0, 5, 0, 5)
    
    self.TabsLayout = Instance.new("UIListLayout")
    self.TabsLayout.Parent = self.TabsContainer
    self.TabsLayout.Padding = UDim.new(0, 5)
    
    -- Контейнер для страниц
    self.PagesContainer = Instance.new("Frame")
    self.PagesContainer.Parent = self.MainFrame
    self.PagesContainer.BackgroundTransparency = 1
    self.PagesContainer.Position = UDim2.new(0, 155, 0, 35)
    self.PagesContainer.Size = UDim2.new(1, -160, 1, -40)
    
    return self
end

function Window:Destroy()
    self.Gui:Destroy()
end

function Window:Hide()
    self.MainFrame.Visible = false
end

function Window:Show()
    self.MainFrame.Visible = true
end

function Window:Toggle()
    self.MainFrame.Visible = not self.MainFrame.Visible
end

-- ============================================
-- КЛАСС: ВКЛАДКА (TAB)
-- ============================================
local Tab = {}
Tab.__index = Tab

function Window:AddTab(name)
    local self = setmetatable({}, Tab)
    self.Window = getmetatable(self).__index.Window
    self.Name = name
    self.Sections = {}
    self.Visible = true
    
    -- Кнопка вкладки
    self.TabButton = Instance.new("TextButton")
    self.TabButton.Parent = self.Window.TabsContainer
    self.TabButton.BackgroundColor3 = self.Window.Theme.SidebarColor
    self.TabButton.Size = UDim2.new(1, 0, 0, 35)
    self.TabButton.Text = name
    self.TabButton.TextColor3 = self.Window.Theme.TextColor
    self.TabButton.TextSize = 13
    self.TabButton.Font = Enum.Font.Gotham
    AddCorner(self.TabButton, 4)
    
    -- Страница вкладки
    self.Page = Instance.new("ScrollingFrame")
    self.Page.Parent = self.Window.PagesContainer
    self.Page.BackgroundTransparency = 1
    self.Page.Size = UDim2.new(1, 0, 1, 0)
    self.Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Page.ScrollBarThickness = 4
    self.Page.ScrollBarImageColor3 = self.Window.Theme.AccentColor
    self.Page.Visible = false
    
    self.PageLayout = Instance.new("UIListLayout")
    self.PageLayout.Parent = self.Page
    self.PageLayout.Padding = UDim.new(0, 8)
    
    -- Обновление размера Canvas при изменении содержимого
    local function updateCanvas()
        self.Page.CanvasSize = UDim2.new(0, 0, 0, self.PageLayout.AbsoluteContentSize.Y + 10)
    end
    self.PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    
    -- Обработчик нажатия на кнопку вкладки
    self.TabButton.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)
    
    table.insert(self.Window.Tabs, self)
    
    -- Если это первая вкладка, делаем её активной
    if #self.Window.Tabs == 1 then
        self.Window:SelectTab(self)
    end
    
    return self
end

function Window:SelectTab(tab)
    -- Скрываем все страницы
    for _, t in pairs(self.Tabs) do
        t.Page.Visible = false
        t.TabButton.BackgroundColor3 = self.Theme.SidebarColor
    end
    
    -- Показываем выбранную
    tab.Page.Visible = true
    tab.TabButton.BackgroundColor3 = self.Theme.AccentColor
    self.CurrentTab = tab
end

-- ============================================
-- КЛАСС: СЕКЦИЯ (SECTION)
-- ============================================
local Section = {}
Section.__index = Section

function Tab:AddSection(title, collapsed)
    local self = setmetatable({}, Section)
    self.Tab = getmetatable(self).__index.Tab
    self.Title = title
    self.Elements = {}
    collapsed = collapsed or false
    
    -- Контейнер секции
    self.Container = Instance.new("Frame")
    self.Container.Parent = self.Tab.Page
    self.Container.BackgroundTransparency = 1
    self.Container.Size = UDim2.new(1, -10, 0, 0)
    self.Container.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Заголовок секции
    self.Header = Instance.new("Frame")
    self.Header.Parent = self.Container
    self.Header.BackgroundColor3 = self.Tab.Window.Theme.AccentColor
    self.Header.Size = UDim2.new(1, 0, 0, 30)
    self.Header.AutomaticSize = Enum.AutomaticSize.None
    AddCorner(self.Header, 4)
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Parent = self.Header
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    self.TitleLabel.Text = title
    self.TitleLabel.TextColor3 = self.Tab.Window.Theme.TextColor
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Контейнер для элементов
    self.ElementsContainer = Instance.new("Frame")
    self.ElementsContainer.Parent = self.Container
    self.ElementsContainer.BackgroundTransparency = 1
    self.ElementsContainer.Position = UDim2.new(0, 0, 0, 35)
    self.ElementsContainer.Size = UDim2.new(1, 0, 0, 0)
    self.ElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
    
    self.ElementsLayout = Instance.new("UIListLayout")
    self.ElementsLayout.Parent = self.ElementsContainer
    self.ElementsLayout.Padding = UDim.new(0, 5)
    
    table.insert(self.Tab.Sections, self)
    
    return self
end

-- ============================================
-- ЭЛЕМЕНТЫ ИНТЕРФЕЙСА
-- ============================================

-- КНОПКА
function Section:AddButton(text, tooltip, callback)
    local button = Instance.new("TextButton")
    button.Parent = self.ElementsContainer
    button.BackgroundColor3 = self.Tab.Window.Theme.ElementColor
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Text = text
    button.TextColor3 = self.Tab.Window.Theme.TextColor
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    AddCorner(button, 4)
    
    -- Кнопка с информацией (подсказка)
    local infoButton = Instance.new("ImageButton")
    infoButton.Parent = button
    infoButton.BackgroundTransparency = 1
    infoButton.Position = UDim2.new(1, -30, 0, 7)
    infoButton.Size = UDim2.new(0, 20, 0, 20)
    infoButton.Image = "rbxassetid://3926305904"
    infoButton.ImageRectOffset = Vector2.new(764, 764)
    infoButton.ImageRectSize = Vector2.new(36, 36)
    infoButton.ImageColor3 = self.Tab.Window.Theme.AccentColor
    
    infoButton.MouseButton1Click:Connect(function()
        TooltipSystem:Show(tooltip or "Нет подсказки", self.Tab.Window.Gui)
    end)
    
    -- Эффект при наведении
    button.MouseEnter:Connect(function()
        Animate(button, {BackgroundColor3 = self.Tab.Window.Theme.ElementColor:Lerp(Color3.fromRGB(255, 255, 255), 0.1)}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Animate(button, {BackgroundColor3 = self.Tab.Window.Theme.ElementColor}, 0.2)
    end)
    
    -- Эффект нажатия (волна)
    button.MouseButton1Click:Connect(function()
        callback()
        
        local ripple = Instance.new("ImageLabel")
        ripple.Parent = button
        ripple.BackgroundTransparency = 1
        ripple.Image = "rbxassetid://4560909609"
        ripple.ImageColor3 = self.Tab.Window.Theme.AccentColor
        ripple.ImageTransparency = 0.5
        ripple.Size = UDim2.new(0, 5, 0, 5)
        ripple.Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X - 2, 0, Mouse.Y - button.AbsolutePosition.Y - 2)
        
        Animate(ripple, {Size = UDim2.new(0, 100, 0, 100), ImageTransparency = 1}, 0.4)
        task.wait(0.4)
        ripple:Destroy()
    end)
    
    return button
end

-- ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE)
function Section:AddToggle(text, tooltip, callback, defaultValue)
    local toggled = defaultValue or false
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Parent = self.ElementsContainer
    toggleFrame.BackgroundColor3 = self.Tab.Window.Theme.ElementColor
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.AutomaticSize = Enum.AutomaticSize.None
    AddCorner(toggleFrame, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = toggleFrame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Text = text
    label.TextColor3 = self.Tab.Window.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Parent = toggleFrame
    toggleButton.BackgroundTransparency = 1
    toggleButton.Position = UDim2.new(1, -35, 0, 7)
    toggleButton.Size = UDim2.new(0, 25, 0, 20)
    toggleButton.Image = "rbxassetid://3926309567"
    
    local infoButton = Instance.new("ImageButton")
    infoButton.Parent = toggleFrame
    infoButton.BackgroundTransparency = 1
    infoButton.Position = UDim2.new(1, -60, 0, 7)
    infoButton.Size = UDim2.new(0, 20, 0, 20)
    infoButton.Image = "rbxassetid://3926305904"
    infoButton.ImageRectOffset = Vector2.new(764, 764)
    infoButton.ImageRectSize = Vector2.new(36, 36)
    infoButton.ImageColor3 = self.Tab.Window.Theme.AccentColor
    
    infoButton.MouseButton1Click:Connect(function()
        TooltipSystem:Show(tooltip or "Нет подсказки", self.Tab.Window.Gui)
    end)
    
    local function updateToggle()
        if toggled then
            toggleButton.ImageRectOffset = Vector2.new(784, 420)
            toggleButton.ImageRectSize = Vector2.new(48, 48)
            toggleButton.ImageColor3 = self.Tab.Window.Theme.AccentColor
        else
            toggleButton.ImageRectOffset = Vector2.new(628, 420)
            toggleButton.ImageRectSize = Vector2.new(48, 48)
            toggleButton.ImageColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        callback(toggled)
    end)
    
    updateToggle()
    
    -- Метод для обновления состояния извне
    local methods = {
        SetValue = function(newValue)
            toggled = newValue
            updateToggle()
            callback(toggled)
        end,
        GetValue = function()
            return toggled
        end
    }
    
    return methods
end

-- ТЕКСТОВОЕ ПОЛЕ
function Section:AddTextbox(text, tooltip, callback, placeholder)
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Parent = self.ElementsContainer
    textboxFrame.BackgroundColor3 = self.Tab.Window.Theme.ElementColor
    textboxFrame.Size = UDim2.new(1, 0, 0, 35)
    AddCorner(textboxFrame, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = textboxFrame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Text = text
    label.TextColor3 = self.Tab.Window.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local textbox = Instance.new("TextBox")
    textbox.Parent = textboxFrame
    textbox.BackgroundColor3 = self.Tab.Window.Theme.ElementColor:Lerp(Color3.fromRGB(0, 0, 0), 0.3)
    textbox.Position = UDim2.new(0, 135, 0, 7)
    textbox.Size = UDim2.new(1, -200, 0, 20)
    textbox.PlaceholderText = placeholder or "Введите значение..."
    textbox.TextColor3 = self.Tab.Window.Theme.TextColor
    textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 12
    AddCorner(textbox, 4)
    
    local infoButton = Instance.new("ImageButton")
    infoButton.Parent = textboxFrame
    infoButton.BackgroundTransparency = 1
    infoButton.Position = UDim2.new(1, -35, 0, 7)
    infoButton.Size = UDim2.new(0, 20, 0, 20)
    infoButton.Image = "rbxassetid://3926305904"
    infoButton.ImageRectOffset = Vector2.new(764, 764)
    infoButton.ImageRectSize = Vector2.new(36, 36)
    infoButton.ImageColor3 = self.Tab.Window.Theme.AccentColor
    
    infoButton.MouseButton1Click:Connect(function()
        TooltipSystem:Show(tooltip or "Нет подсказки", self.Tab.Window.Gui)
    end)
    
    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textbox.Text)
            textbox.Text = ""
        end
    end)
    
    return textbox
end

-- ПОЛЗУНОК (SLIDER)
function Section:AddSlider(text, tooltip, minValue, maxValue, callback, defaultValue)
    defaultValue = defaultValue or minValue
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = self.ElementsContainer
    sliderFrame.BackgroundColor3 = self.Tab.Window.Theme.ElementColor
    sliderFrame.Size = UDim2.new(1, 0, 0, 55)
    AddCorner(sliderFrame, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = sliderFrame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Size = UDim2.new(0, 150, 0, 20)
    label.Text = text
    label.TextColor3 = self.Tab.Window.Theme.TextColor
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = sliderFrame
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = self.Tab.Window.Theme.AccentColor
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = sliderFrame
    sliderBar.BackgroundColor3 = self.Tab.Window.Theme.ElementColor:Lerp(Color3.fromRGB(255, 255, 255), 0.1)
    sliderBar.Position = UDim2.new(0, 10, 0, 32)
    sliderBar.Size = UDim2.new(1, -80, 0, 6)
    AddCorner(sliderBar, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBar
    sliderFill.BackgroundColor3 = self.Tab.Window.Theme.AccentColor
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    AddCorner(sliderFill, 3)
    
    local sliderButton = Instance.new("ImageButton")
    sliderButton.Parent = sliderBar
    sliderButton.BackgroundTransparency = 1
    sliderButton.Size = UDim2.new(0, 14, 0, 14)
    sliderButton.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -7, 0, -4)
    sliderButton.Image = "rbxassetid://3926307971"
    sliderButton.ImageColor3 = self.Tab.Window.Theme.AccentColor
    
    local infoButton = Instance.new("ImageButton")
    infoButton.Parent = sliderFrame
    infoButton.BackgroundTransparency = 1
    infoButton.Position = UDim2.new(1, -35, 0, 7)
    infoButton.Size = UDim2.new(0, 20, 0, 20)
    infoButton.Image = "rbxassetid://3926305904"
    infoButton.ImageRectOffset = Vector2.new(764, 764)
    infoButton.ImageRectSize = Vector2.new(36, 36)
    infoButton.ImageColor3 = self.Tab.Window.Theme.AccentColor
    
    infoButton.MouseButton1Click:Connect(function()
        TooltipSystem:Show(tooltip or "Нет подсказки", self.Tab.Window.Gui)
    end)
    
    local dragging = false
    local currentValue = defaultValue
    
    local function updateSlider(value)
        local newValue = math.clamp(value, minValue, maxValue)
        currentValue = newValue
        local percent = (newValue - minValue) / (maxValue - minValue)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderButton.Position = UDim2.new(percent, -7, 0, -4)
        valueLabel.Text = tostring(math.floor(newValue))
        callback(newValue)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local newValue = minValue + (maxValue - minValue) * relativeX
            updateSlider(newValue)
        end
    end)
    
    return {
        SetValue = function(value)
            updateSlider(value)
        end,
        GetValue = function()
            return currentValue
        end
    }
end

-- ============================================
-- ВОЗВРАЩАЕМ МОДУЛЬ
-- ============================================
return CleanUI
