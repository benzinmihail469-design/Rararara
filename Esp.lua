-- [[ Library.lua ]] --
-- Версия 2.0.0
-- Поддержка ПК + мобильных устройств
-- Сборка GUI: Library:BuildGUI()

local Library = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [[ Вспомогательные функции ]]
local function IsMobile()
    return UserInputService.TouchEnabled or false
end

local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

-- [[ Основная библиотека ]]
function Library:New(config)
    config = config or {}
    local self = setmetatable({}, Library)
    self.Name = config.Name or "Library"
    self.Icon = config.Icon or "rbxassetid://1234567890"
    self.MenuKey = config.MenuKey or Enum.KeyCode.Insert
    self.IsOpen = false
    self.Pages = {}
    self.CurrentPage = nil
    self.Flags = {}
    self.Sections = {}
    self.Elements = {}
    self.Theme = {
        Background = Color3.fromRGB(20, 20, 25),
        Background2 = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(0, 150, 255),
        AccentGradient = Color3.fromRGB(100, 200, 255),
        Text = Color3.fromRGB(235, 235, 235),
        TextDim = Color3.fromRGB(150, 150, 150),
        Element = Color3.fromRGB(40, 40, 45),
        Outline = Color3.fromRGB(50, 50, 55),
    }
    self.Holder = Instance.new("ScreenGui")
    self.Holder.Name = "LibraryGUI"
    self.Holder.Parent = CoreGui
    self.Holder.ResetOnSpawn = false
    self.Holder.ZIndexBehavior = Enum.ZIndexBehavior.Global

    -- Флаг для отслеживания готовности
    self._ready = false

    -- Автоматическая сборка GUI
    self:BuildGUI()

    return self
end

-- [[ Сборка основного GUI ]]
function Library:BuildGUI()
    if self._ready then return end
    self._ready = true

    -- Основное окно
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.Holder
    self.MainFrame.Size = UDim2.new(0, 600, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Visible = false
    self.MainFrame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.MainFrame

    -- Затемнение фона (для мобильных)
    self.BlurFrame = Instance.new("Frame")
    self.BlurFrame.Name = "Blur"
    self.BlurFrame.Parent = self.MainFrame
    self.BlurFrame.Size = UDim2.new(1, 0, 1, 0)
    self.BlurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.BlurFrame.BackgroundTransparency = 0.5
    self.BlurFrame.Visible = IsMobile()

    -- Заголовок
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Parent = self.MainFrame
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = self.Theme.Background2
    self.TitleBar.BorderSizePixel = 0

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar

    -- Иконка в заголовке
    self.TitleIcon = Instance.new("ImageLabel")
    self.TitleIcon.Name = "TitleIcon"
    self.TitleIcon.Parent = self.TitleBar
    self.TitleIcon.Size = UDim2.new(0, 24, 0, 24)
    self.TitleIcon.Position = UDim2.new(0, 12, 0.5, -12)
    self.TitleIcon.Image = self.Icon
    self.TitleIcon.BackgroundTransparency = 1

    -- Заголовок
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "TitleText"
    self.TitleText.Parent = self.TitleBar
    self.TitleText.Size = UDim2.new(1, -100, 1, 0)
    self.TitleText.Position = UDim2.new(0, 44, 0, 0)
    self.TitleText.Text = self.Name
    self.TitleText.TextColor3 = self.Theme.Text
    self.TitleText.TextSize = 18
    self.TitleText.Font = Enum.Font.GothamBold
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.BackgroundTransparency = 1

    -- Кнопка закрытия
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Parent = self.TitleBar
    self.CloseButton.Size = UDim2.new(0, 32, 0, 32)
    self.CloseButton.Position = UDim2.new(1, -38, 0.5, -16)
    self.CloseButton.Text = "✕"
    self.CloseButton.TextColor3 = self.Theme.Text
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Кнопка сворачивания
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Parent = self.TitleBar
    self.MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
    self.MinimizeButton.Position = UDim2.new(1, -76, 0.5, -16)
    self.MinimizeButton.Text = "—"
    self.MinimizeButton.TextColor3 = self.Theme.Text
    self.MinimizeButton.TextSize = 20
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.BackgroundTransparency = 1
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end)

    -- Контейнер для содержимого
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "Content"
    self.ContentContainer.Parent = self.MainFrame
    self.ContentContainer.Size = UDim2.new(1, 0, 1, -40)
    self.ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    self.ContentContainer.BackgroundTransparency = 1

    -- Создаем контейнер для вкладок (левая панель)
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "Tabs"
    self.TabContainer.Parent = self.ContentContainer
    self.TabContainer.Size = UDim2.new(0, 180, 1, 0)
    self.TabContainer.BackgroundColor3 = self.Theme.Background2
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 0
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = self.TabContainer
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Контейнер для страниц
    self.PageContainer = Instance.new("Frame")
    self.PageContainer.Name = "Pages"
    self.PageContainer.Parent = self.ContentContainer
    self.PageContainer.Size = UDim2.new(1, -180, 1, 0)
    self.PageContainer.Position = UDim2.new(0, 180, 0, 0)
    self.PageContainer.BackgroundTransparency = 1

    -- Плавающая кнопка для мобильных
    if IsMobile() then
        self.FloatingButton = Instance.new("TextButton")
        self.FloatingButton.Name = "FloatingButton"
        self.FloatingButton.Parent = self.Holder
        self.FloatingButton.Size = UDim2.new(0, 60, 0, 60)
        self.FloatingButton.Position = UDim2.new(1, -80, 0.5, -30)
        self.FloatingButton.BackgroundColor3 = self.Theme.Accent
        self.FloatingButton.Text = "☰"
        self.FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.FloatingButton.TextSize = 30
        self.FloatingButton.Font = Enum.Font.GothamBold
        self.FloatingButton.BorderSizePixel = 0

        local floatCorner = Instance.new("UICorner")
        floatCorner.CornerRadius = UDim.new(1, 0)
        floatCorner.Parent = self.FloatingButton

        self.FloatingButton.MouseButton1Click:Connect(function()
            self:Toggle()
        end)

        -- Перетаскивание кнопки
        local dragging = false
        local dragStart = nil
        self.FloatingButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
            end
        end)
        self.FloatingButton.InputEnded:Connect(function(input)
            if dragging then
                dragging = false
                dragStart = nil
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                self.FloatingButton.Position = UDim2.new(
                    self.FloatingButton.Position.X.Scale,
                    self.FloatingButton.Position.X.Offset + delta.X,
                    self.FloatingButton.Position.Y.Scale,
                    self.FloatingButton.Position.Y.Offset + delta.Y
                )
                dragStart = input.Position
            end
        end)
    end

    -- Обработка горячей клавиши
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.MenuKey then
            self:Toggle()
        end
    end)

    self:SetupDrag(self.MainFrame, self.TitleBar)
end

-- [[ Перетаскивание окна ]]
function Library:SetupDrag(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if dragging then
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            dragStart = input.Position
        end
    end)
end

-- [[ Открыть/закрыть ]]
function Library:Toggle()
    self.IsOpen = not self.IsOpen
    self.MainFrame.Visible = self.IsOpen
    if IsMobile() and self.FloatingButton then
        self.FloatingButton.Visible = not self.IsOpen
    end
    if self.IsOpen then
        self:UpdateUI()
    end
end

-- [[ Обновление интерфейса ]]
function Library:UpdateUI()
    for _, page in pairs(self.Pages) do
        if page.Active then
            page:Show()
        end
    end
end

-- [[ Создание страницы (вкладки) ]]
function Library:Page(config)
    config = config or {}
    local page = {}
    page.Name = config.Name or "Page"
    page.Icon = config.Icon or "rbxassetid://1234567890"
    page.Active = false
    page.Elements = {}

    -- Кнопка вкладки
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab_" .. page.Name
    tabButton.Parent = self.TabContainer
    tabButton.Size = UDim2.new(1, -8, 0, 36)
    tabButton.Position = UDim2.new(0, 4, 0, 0)
    tabButton.BackgroundColor3 = self.Theme.Background2
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton

    -- Иконка вкладки
    local tabIcon = Instance.new("ImageLabel")
    tabIcon.Name = "Icon"
    tabIcon.Parent = tabButton
    tabIcon.Size = UDim2.new(0, 20, 0, 20)
    tabIcon.Position = UDim2.new(0, 8, 0.5, -10)
    tabIcon.Image = page.Icon
    tabIcon.BackgroundTransparency = 1

    -- Текст вкладки
    local tabText = Instance.new("TextLabel")
    tabText.Name = "Text"
    tabText.Parent = tabButton
    tabText.Size = UDim2.new(1, -36, 1, 0)
    tabText.Position = UDim2.new(0, 32, 0, 0)
    tabText.Text = page.Name
    tabText.TextColor3 = self.Theme.TextDim
    tabText.TextSize = 14
    tabText.Font = Enum.Font.GothamMedium
    tabText.TextXAlignment = Enum.TextXAlignment.Left
    tabText.BackgroundTransparency = 1

    -- Контейнер страницы
    local pageFrame = Instance.new("Frame")
    pageFrame.Name = "Page_" .. page.Name
    pageFrame.Parent = self.PageContainer
    pageFrame.Size = UDim2.new(1, 0, 1, 0)
    pageFrame.BackgroundTransparency = 1
    pageFrame.Visible = false

    -- Содержимое страницы (скролл)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.Parent = pageFrame
    scroll.Size = UDim2.new(1, -16, 1, -8)
    scroll.Position = UDim2.new(0, 8, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Parent = scroll
    scrollLayout.Padding = UDim.new(0, 8)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

    page.Frame = pageFrame
    page.Scroll = scroll
    page.TabButton = tabButton
    page.TabText = tabText
    page.TabIcon = tabIcon

    page.Show = function(self)
        for _, p in pairs(self.Pages) do
            p.Frame.Visible = false
            p.TabButton.BackgroundColor3 = self.Theme.Background2
            p.TabText.TextColor3 = self.Theme.TextDim
            p.Active = false
        end
        self.Active = true
        self.Frame.Visible = true
        self.TabButton.BackgroundColor3 = self.Theme.Accent
        self.TabText.TextColor3 = self.Theme.Text
        self:UpdateSections()
    end

    page.UpdateSections = function(self)
        for _, section in pairs(self.Elements) do
            if section.Update then
                section:Update()
            end
        end
    end

    tabButton.MouseButton1Click:Connect(function()
        page:Show()
    end)

    table.insert(self.Pages, page)
    if #self.Pages == 1 then
        page:Show()
    end

    return page
end

-- [[ Создание секции ]]
function Library:Section(config)
    config = config or {}
    local section = {}
    section.Name = config.Name or "Section"
    section.Icon = config.Icon or "rbxassetid://1234567890"
    section.Page = config.Page or self.Pages[1]
    section.Elements = {}

    -- Заголовок секции
    local header = Instance.new("Frame")
    header.Name = "Header_" .. section.Name
    header.Parent = section.Page.Scroll
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = self.Theme.Background2
    header.BorderSizePixel = 0

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = header

    -- Иконка секции
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = header
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0.5, -10)
    icon.Image = section.Icon
    icon.BackgroundTransparency = 1

    -- Название секции
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = header
    title.Size = UDim2.new(1, -44, 1, 0)
    title.Position = UDim2.new(0, 40, 0, 0)
    title.Text = section.Name
    title.TextColor3 = self.Theme.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    -- Контейнер для элементов секции
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = section.Page.Scroll
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    section.Header = header
    section.Content = content

    section.AddElement = function(self, element)
        table.insert(self.Elements, element)
        return element
    end

    section.Update = function(self)
        for _, el in pairs(self.Elements) do
            if el.Update then
                el:Update()
            end
        end
    end

    table.insert(section.Page.Elements, section)
    return section
end

-- [[ Toggle (переключатель) ]]
function Library:Toggle(config)
    config = config or {}
    local toggle = {}
    toggle.Name = config.Name or "Toggle"
    toggle.Flag = config.Flag or toggle.Name
    toggle.Default = config.Default or false
    toggle.Callback = config.Callback or function() end
    toggle.Section = config.Section

    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. toggle.Name
    frame.Parent = toggle.Section.Content
    frame.Size = UDim2.new(1, -8, 0, 32)
    frame.Position = UDim2.new(0, 4, 0, 0)
    frame.BackgroundColor3 = self.Theme.Element
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = frame
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = toggle.Name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.Parent = frame
    btn.Size = UDim2.new(0, 40, 0, 24)
    btn.Position = UDim2.new(1, -48, 0.5, -12)
    btn.BackgroundColor3 = self.Theme.Element
    btn.BorderSizePixel = 0
    btn.Text = ""

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Parent = btn
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(0, 2, 0.5, -10)
    indicator.BackgroundColor3 = self.Theme.Background
    indicator.BorderSizePixel = 0

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    local value = toggle.Default
    toggle.Value = value

    local function updateUI()
        if value then
            btn.BackgroundColor3 = self.Theme.Accent
            indicator.Position = UDim2.new(1, -22, 0.5, -10)
        else
            btn.BackgroundColor3 = self.Theme.Element
            indicator.Position = UDim2.new(0, 2, 0.5, -10)
        end
    end
    updateUI()

    btn.MouseButton1Click:Connect(function()
        value = not value
        toggle.Value = value
        updateUI()
        toggle.Callback(value)
        self.Flags[toggle.Flag] = value
    end)

    toggle.Frame = frame
    toggle.Update = updateUI

    self.Flags[toggle.Flag] = toggle.Default
    return toggle
end

-- [[ Slider (ползунок) ]]
function Library:Slider(config)
    config = config or {}
    local slider = {}
    slider.Name = config.Name or "Slider"
    slider.Flag = config.Flag or slider.Name
    slider.Min = config.Min or 0
    slider.Max = config.Max or 100
    slider.Default = config.Default or 50
    slider.Suffix = config.Suffix or ""
    slider.Callback = config.Callback or function() end
    slider.Section = config.Section

    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. slider.Name
    frame.Parent = slider.Section.Content
    frame.Size = UDim2.new(1, -8, 0, 48)
    frame.Position = UDim2.new(0, 4, 0, 0)
    frame.BackgroundColor3 = self.Theme.Element
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = frame
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.Text = slider.Name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Parent = frame
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -72, 0, 4)
    valueLabel.Text = tostring(slider.Default) .. slider.Suffix
    valueLabel.TextColor3 = self.Theme.TextDim
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Parent = frame
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 32)
    track.BackgroundColor3 = self.Theme.Background
    track.BorderSizePixel = 0

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = track
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local value = slider.Default
    slider.Value = value

    local function updateUI()
        local percent = (value - slider.Min) / (slider.Max - slider.Min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(math.floor(value)) .. slider.Suffix
    end
    updateUI()

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    track.InputEnded:Connect(function(input)
        dragging = false
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position.X - track.AbsolutePosition.X
            local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
            value = slider.Min + (slider.Max - slider.Min) * percent
            slider.Value = value
            updateUI()
            slider.Callback(value)
            self.Flags[slider.Flag] = value
        end
    end)

    slider.Frame = frame
    slider.Update = updateUI

    self.Flags[slider.Flag] = slider.Default
    return slider
end

-- [[ Button (кнопка) ]]
function Library:Button(config)
    config = config or {}
    local button = {}
    button.Name = config.Name or "Button"
    button.Callback = config.Callback or function() end
    button.Section = config.Section

    local frame = Instance.new("TextButton")
    frame.Name = "Button_" .. button.Name
    frame.Parent = button.Section.Content
    frame.Size = UDim2.new(1, -8, 0, 36)
    frame.Position = UDim2.new(0, 4, 0, 0)
    frame.BackgroundColor3 = self.Theme.Element
    frame.BorderSizePixel = 0
    frame.Text = ""

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = button.Name
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.BackgroundTransparency = 1

    frame.MouseButton1Click:Connect(function()
        button.Callback()
        -- Анимация нажатия
        frame.BackgroundColor3 = self.Theme.Accent
        task.wait(0.1)
        frame.BackgroundColor3 = self.Theme.Element
    end)

    button.Frame = frame
    return button
end

-- [[ Dropdown (выпадающий список) ]]
function Library:Dropdown(config)
    config = config or {}
    local dropdown = {}
    dropdown.Name = config.Name or "Dropdown"
    dropdown.Flag = config.Flag or dropdown.Name
    dropdown.Items = config.Items or {"Option 1", "Option 2", "Option 3"}
    dropdown.Default = config.Default or dropdown.Items[1]
    dropdown.Callback = config.Callback or function() end
    dropdown.Section = config.Section
    dropdown.Open = false
    dropdown.Value = dropdown.Default

    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. dropdown.Name
    frame.Parent = dropdown.Section.Content
    frame.Size = UDim2.new(1, -8, 0, 36)
    frame.Position = UDim2.new(0, 4, 0, 0)
    frame.BackgroundColor3 = self.Theme.Element
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame

    local mainBtn = Instance.new("TextButton")
    mainBtn.Name = "Main"
    mainBtn.Parent = frame
    mainBtn.Size = UDim2.new(1, 0, 0, 36)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Text = ""

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = mainBtn
    label.Size = UDim2.new(1, -36, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = dropdown.Default
    label.TextColor3 = self.Theme.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Parent = mainBtn
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -28, 0.5, -8)
    arrow.Image = "rbxassetid://6031091904"
    arrow.BackgroundTransparency = 1

    local listContainer = Instance.new("ScrollingFrame")
    listContainer.Name = "List"
    listContainer.Parent = frame
    listContainer.Size = UDim2.new(1, 0, 0, 0)
    listContainer.Position = UDim2.new(0, 0, 0, 36)
    listContainer.BackgroundTransparency = 1
    listContainer.ScrollBarThickness = 0
    listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    listContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = listContainer
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local options = {}

    for _, item in ipairs(dropdown.Items) do
        local btn = Instance.new("TextButton")
        btn.Name = "Option_" .. item
        btn.Parent = listContainer
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = self.Theme.Background
        btn.BorderSizePixel = 0
        btn.Text = item
        btn.TextColor3 = self.Theme.TextDim
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            dropdown.Value = item
            label.Text = item
            dropdown:Close()
            dropdown.Callback(item)
            self.Flags[dropdown.Flag] = item
        end)

        table.insert(options, btn)
    end

    local function updateHeight()
        local count = #options
        local height = math.min(count * 30, 150)
        listContainer.Size = UDim2.new(1, 0, 0, height)
        frame.Size = UDim2.new(1, -8, 0, 36 + height)
    end

    dropdown.Open = false
    dropdown.Close = function(self)
        self.Open = false
        arrow.Rotation = 0
        listContainer.Size = UDim2.new(1, 0, 0, 0)
        frame.Size = UDim2.new(1, -8, 0, 36)
    end

    dropdown.Toggle = function(self)
        if self.Open then
            self:Close()
        else
            self.Open = true
            arrow.Rotation = 180
            updateHeight()
        end
    end

    mainBtn.MouseButton1Click:Connect(function()
        dropdown:Toggle()
    end)

    dropdown.Frame = frame
    dropdown.Update = function()
        updateHeight()
    end

    self.Flags[dropdown.Flag] = dropdown.Default
    return dropdown
end

-- [[ Textbox (поле ввода) ]]
function Library:Textbox(config)
    config = config or {}
    local textbox = {}
    textbox.Name = config.Name or "Textbox"
    textbox.Flag = config.Flag or textbox.Name
    textbox.Placeholder = config.Placeholder or "Enter text..."
    textbox.Default = config.Default or ""
    textbox.Callback = config.Callback or function() end
    textbox.Section = config.Section

    local frame = Instance.new("Frame")
    frame.Name = "Textbox_" .. textbox.Name
    frame.Parent = textbox.Section.Content
    frame.Size = UDim2.new(1, -8, 0, 36)
    frame.Position = UDim2.new(0, 4, 0, 0)
    frame.BackgroundColor3 = self.Theme.Element
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = frame
    label.Size = UDim2.new(1, -120, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = textbox.Name
    label.TextColor3 = self.Theme.TextDim
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Parent = frame
    input.Size = UDim2.new(0, 100, 0, 28)
    input.Position = UDim2.new(1, -112, 0.5, -14)
    input.BackgroundColor3 = self.Theme.Background
    input.BorderSizePixel = 0
    input.Text = textbox.Default
    input.TextColor3 = self.Theme.Text
    input.TextSize = 13
    input.Font = Enum.Font.GothamMedium
    input.PlaceholderText = textbox.Placeholder
    input.PlaceholderColor3 = self.Theme.TextDim

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = input

    input:GetPropertyChangedSignal("Text"):Connect(function()
        textbox.Value = input.Text
        textbox.Callback(input.Text)
        self.Flags[textbox.Flag] = input.Text
    end)

    textbox.Frame = frame
    textbox.Value = textbox.Default

    self.Flags[textbox.Flag] = textbox.Default
    return textbox
end

-- [[ Экспорт ]]
return Library
