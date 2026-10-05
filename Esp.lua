-- ====================================================================
-- SALAD UI LIBRARY (Mobile Adapted)
-- Объединённый код: Части 1-5
-- ====================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- ЧАСТЬ 1: ИНИЦИАЛИЗАЦИЯ, СТИЛИ И АДАПТИВНАЯ ОСНОВА GUI
-- ====================================================================

local Theme = {
    Background = Color3.fromRGB(12, 13, 16),
    CardBackground = Color3.fromRGB(18, 20, 26),
    CardOutline = Color3.fromRGB(28, 32, 42),
    TextPrimary = Color3.fromRGB(240, 242, 245),
    TextSecondary = Color3.fromRGB(130, 136, 148),
    Accent = Color3.fromRGB(255, 255, 255),
    ToggleActive = Color3.fromRGB(255, 255, 255),
    ToggleInactive = Color3.fromRGB(35, 39, 50),
    SliderTrack = Color3.fromRGB(28, 32, 42),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 8)
}

-- Алиасы для совместимости с частями 3-5
Theme.Card = Theme.CardBackground
Theme.CardStroke = Theme.CardOutline
Theme.ToggleOn = Theme.ToggleActive
Theme.ToggleOff = Theme.ToggleInactive

-- Создание главного ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaladUI_MobileAdapted"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Вспомогательная функция плавных анимаций
local function Tween(instance, properties, duration)
    local info = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local anim = TweenService:Create(instance, info, properties)
    anim:Play()
    return anim
end

-- Перетаскивание окна (Mouse + Touch)
local function MakeDraggable(dragHandle, frameToMove)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frameToMove.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frameToMove.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ====================================================================
-- ЧАСТЬ 2: ГЛАВНОЕ ОКНО, ШАПКА И СИСТЕМА ВКЛАДОК
-- ====================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.075, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local SizeConstraint = Instance.new("UISizeConstraint")
SizeConstraint.MinSize = Vector2.new(320, 240)
SizeConstraint.MaxSize = Vector2.new(1050, 680)
SizeConstraint.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = Theme.CornerRadius
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.CardOutline
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Шапка (Top Bar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Background
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
MakeDraggable(TopBar, MainFrame)

-- Логотип
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 80, 1, 0)
Logo.Position = UDim2.new(0, 16, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "SALAD"
Logo.TextColor3 = Theme.TextPrimary
Logo.TextSize = 16
Logo.Font = Theme.FontBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TopBar

-- Контейнер главных вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -220, 0, 32)
TabContainer.Position = UDim2.new(0, 100, 0, 5)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TopBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabContainer

-- Контейнер подвкладок
local SubTabContainer = Instance.new("Frame")
SubTabContainer.Size = UDim2.new(1, -32, 0, 30)
SubTabContainer.Position = UDim2.new(0, 16, 0, 45)
SubTabContainer.BackgroundTransparency = 1
SubTabContainer.Parent = MainFrame

local SubTabListLayout = Instance.new("UIListLayout")
SubTabListLayout.FillDirection = Enum.FillDirection.Horizontal
SubTabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SubTabListLayout.Padding = UDim.new(0, 12)
SubTabListLayout.Parent = SubTabContainer

-- Область содержимого (скроллинг)
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -32, 1, -85)
ContentScroll.Position = UDim2.new(0, 16, 0, 80)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Theme.TextSecondary
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = MainFrame

local ContentGrid = Instance.new("UIGridLayout")
ContentGrid.SortOrder = Enum.SortOrder.LayoutOrder
ContentGrid.CellPadding = UDim2.new(0, 12, 0, 12)
ContentGrid.CellSize = UDim2.new(0.32, 0, 0, 0)
ContentGrid.Parent = ContentScroll

-- Адаптация колонок под ширину экрана
local function UpdateLayoutForMobile()
    if MainFrame.AbsoluteSize.X < 600 then
        ContentGrid.CellSize = UDim2.new(1, 0, 0, 0)
    elseif MainFrame.AbsoluteSize.X < 850 then
        ContentGrid.CellSize = UDim2.new(0.48, 0, 0, 0)
    else
        ContentGrid.CellSize = UDim2.new(0.32, 0, 0, 0)
    end
end

MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateLayoutForMobile)
task.spawn(UpdateLayoutForMobile)

-- ====================================================================
-- ЧАСТЬ 3: КАРТОЧКИ СЕКЦИЙ И ЭЛЕМЕНТЫ (Toggle, Slider)
-- ====================================================================

local UI = {}

function UI:CreateCard(title)
    local Card = Instance.new("Frame")
    Card.Name = title .. "_Card"
    Card.BackgroundColor3 = Theme.CardBackground
    Card.BorderSizePixel = 0
    Card.AutomaticSize = Enum.AutomaticSize.Y
    Card.Size = UDim2.new(1, 0, 0, 40)
    Card.Parent = ContentScroll

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = Theme.CornerRadius
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Theme.CardOutline
    CardStroke.Thickness = 1
    CardStroke.Parent = Card

    local CardPadding = Instance.new("UIPadding")
    CardPadding.PaddingTop = UDim.new(0, 12)
    CardPadding.PaddingBottom = UDim.new(0, 12)
    CardPadding.PaddingLeft = UDim.new(0, 12)
    CardPadding.PaddingRight = UDim.new(0, 12)
    CardPadding.Parent = Card

    local CardLayout = Instance.new("UIListLayout")
    CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CardLayout.Padding = UDim.new(0, 10)
    CardLayout.Parent = Card

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(1, 0, 0, 18)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = title
    CardTitle.TextColor3 = Theme.TextPrimary
    CardTitle.TextSize = 13
    CardTitle.Font = Theme.FontBold
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card

    local CardAPI = {}

    -- Toggle
    function CardAPI:AddToggle(text, defaultValue, callback)
        local state = defaultValue or false

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = Card

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -45, 1, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Theme.TextSecondary
        ToggleLabel.TextSize = 12
        ToggleLabel.Font = Theme.Font
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 36, 0, 18)
        Switch.Position = UDim2.new(1, -36, 0.5, -9)
        Switch.BackgroundColor3 = state and Theme.ToggleActive or Theme.ToggleInactive
        Switch.AutoButtonColor = false
        Switch.Text = ""
        Switch.Parent = ToggleFrame

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = Switch

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 14, 0, 14)
        Circle.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        Circle.BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
        Circle.BorderSizePixel = 0
        Circle.Parent = Switch

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = Circle

        Switch.MouseButton1Click:Connect(function()
            state = not state
            Tween(Switch, { BackgroundColor3 = state and Theme.ToggleActive or Theme.ToggleInactive }, 0.15)
            Tween(Circle, {
                Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = state and Theme.Background or Theme.TextSecondary
            }, 0.15)
            if callback then callback(state) end
        end)
    end

    -- Slider
    function CardAPI:AddSlider(text, min, max, defaultValue, callback)
        local value = defaultValue or min

        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 36)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = Card

        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(0.7, 0, 0, 16)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = text
        SliderLabel.TextColor3 = Theme.TextSecondary
        SliderLabel.TextSize = 12
        SliderLabel.Font = Theme.Font
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0.3, 0, 0, 16)
        ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(value)
        ValueLabel.TextColor3 = Theme.TextPrimary
        ValueLabel.TextSize = 12
        ValueLabel.Font = Theme.Font
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, 0, 0, 4)
        Track.Position = UDim2.new(0, 0, 1, -6)
        Track.BackgroundColor3 = Theme.SliderTrack
        Track.BorderSizePixel = 0
        Track.Parent = SliderFrame

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = Track

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 10, 0, 10)
        Knob.Position = UDim2.new(1, -5, 0.5, -5)
        Knob.BackgroundColor3 = Theme.Accent
        Knob.Parent = Fill

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local dragging = false

        local function UpdateSlider(input)
            local posX = input.Position.X - Track.AbsolutePosition.X
            local percentage = math.clamp(posX / Track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * percentage)
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            if callback then callback(value) end
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input)
            end
        end)
    end

    return CardAPI
end

-- ====================================================================
-- ЧАСТЬ 4: DROPDOWN И ПЛАВАЮЩАЯ КНОПКА ДЛЯ МОБИЛЬНЫХ
-- ====================================================================

function UI:AddDropdownToCard(cardInstance, text, options, defaultOption, callback)
    local selected = defaultOption or options[1] or ""
    local expanded = false

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 48)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = cardInstance

    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(1, 0, 0, 16)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = text
    DropdownLabel.TextColor3 = Theme.TextSecondary
    DropdownLabel.TextSize = 12
    DropdownLabel.Font = Theme.Font
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 26)
    Button.Position = UDim2.new(0, 0, 0, 20)
    Button.BackgroundColor3 = Theme.SliderTrack
    Button.Text = " " .. selected
    Button.TextColor3 = Theme.TextPrimary
    Button.TextSize = 12
    Button.Font = Theme.Font
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = DropdownFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.TextSecondary
    Arrow.TextSize = 10
    Arrow.Font = Theme.FontBold
    Arrow.Parent = Button

    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(1, 0, 0, 0)
    ListFrame.Position = UDim2.new(0, 0, 1, 4)
    ListFrame.BackgroundColor3 = Theme.CardBackground
    ListFrame.Visible = false
    ListFrame.ClipsDescendants = true
    ListFrame.ZIndex = 5
    ListFrame.Parent = Button

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = ListFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 24)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = " " .. opt
        OptBtn.TextColor3 = Theme.TextSecondary
        OptBtn.TextSize = 11
        OptBtn.Font = Theme.Font
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.ZIndex = 6
        OptBtn.Parent = ListFrame

        OptBtn.MouseButton1Click:Connect(function()
            selected = opt
            Button.Text = " " .. selected
            ListFrame.Visible = false
            expanded = false
            DropdownFrame.Size = UDim2.new(1, 0, 0, 48)
            if callback then callback(selected) end
        end)
    end

    Button.MouseButton1Click:Connect(function()
        expanded = not expanded
        ListFrame.Visible = expanded
        ListFrame.Size = expanded and UDim2.new(1, 0, 0, #options * 24) or UDim2.new(1, 0, 0, 0)
        DropdownFrame.Size = expanded and UDim2.new(1, 0, 0, 48 + #options * 24) or UDim2.new(1, 0, 0, 48)
    end)
end

-- Плавающая кнопка для мобильных устройств
local MobileToggleButton = Instance.new("TextButton")
MobileToggleButton.Name = "SaladMobileToggle"
MobileToggleButton.Size = UDim2.new(0, 44, 0, 44)
MobileToggleButton.Position = UDim2.new(0, 15, 0.4, 0)
MobileToggleButton.BackgroundColor3 = Theme.CardBackground
MobileToggleButton.Text = "S"
MobileToggleButton.TextColor3 = Theme.TextPrimary
MobileToggleButton.TextSize = 18
MobileToggleButton.Font = Theme.FontBold
MobileToggleButton.Parent = ScreenGui

local MobileBtnCorner = Instance.new("UICorner")
MobileBtnCorner.CornerRadius = UDim.new(1, 0)
MobileBtnCorner.Parent = MobileToggleButton

local MobileBtnStroke = Instance.new("UIStroke")
MobileBtnStroke.Color = Theme.CardOutline
MobileBtnStroke.Thickness = 2
MobileBtnStroke.Parent = MobileToggleButton

MakeDraggable(MobileToggleButton, MobileToggleButton)

MobileToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ====================================================================
-- ЧАСТЬ 5: COLOR PICKER, СТАТУС-БАР, ТАБЫ И ПОЛНАЯ СБОРКА
-- ====================================================================

-- 1. ColorPicker
function UI:AddColorPickerToCard(cardInstance, text, defaultColor, callback)
    local currentColor = defaultColor or Color3.fromRGB(50, 150, 255)

    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, 0, 0, 24)
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.Parent = cardInstance

    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(1, -30, 1, 0)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = text
    ColorLabel.TextColor3 = Theme.TextSecondary
    ColorLabel.TextSize = 12
    ColorLabel.Font = Theme.Font
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Parent = ColorFrame

    local ColorPreview = Instance.new("TextButton")
    ColorPreview.Size = UDim2.new(0, 18, 0, 18)
    ColorPreview.Position = UDim2.new(1, -18, 0.5, -9)
    ColorPreview.BackgroundColor3 = currentColor
    ColorPreview.Text = ""
    ColorPreview.AutoButtonColor = false
    ColorPreview.Parent = ColorFrame

    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(1, 0)
    PreviewCorner.Parent = ColorPreview

    ColorPreview.MouseButton1Click:Connect(function()
        if currentColor == Color3.fromRGB(50, 150, 255) then
            currentColor = Color3.fromRGB(255, 80, 80)
        elseif currentColor == Color3.fromRGB(255, 80, 80) then
            currentColor = Color3.fromRGB(80, 255, 120)
        else
            currentColor = Color3.fromRGB(50, 150, 255)
        end
        ColorPreview.BackgroundColor3 = currentColor
        if callback then callback(currentColor) end
    end)
end

-- 2. Статус-бар (Username, Ping, Time)
local StatsBar = Instance.new("Frame")
StatsBar.Size = UDim2.new(0, 260, 0, 24)
StatsBar.Position = UDim2.new(0.5, -130, 0, 9)
StatsBar.BackgroundColor3 = Theme.CardBackground
StatsBar.Parent = TopBar

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 12)
StatsCorner.Parent = StatsBar

local StatsStroke = Instance.new("UIStroke")
StatsStroke.Color = Theme.CardOutline
StatsStroke.Thickness = 1
StatsStroke.Parent = StatsBar

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 1, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Theme.TextSecondary
StatsLabel.TextSize = 11
StatsLabel.Font = Theme.Font
StatsLabel.Text = "Loading stats..."
StatsLabel.Parent = StatsBar

task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local timeStr = os.date("%H:%M")
        StatsLabel.Text = string.format("%s | %dms | %s", LocalPlayer.Name, ping, timeStr)
    end
end)

-- 3. Главные вкладки
local MainTabs = {"Combat", "Visuals", "Player", "Style", "Misc"}
local ActiveMainTab = "Visuals"

for _, tabName in ipairs(MainTabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 65, 1, 0)
    TabButton.BackgroundTransparency = (tabName == ActiveMainTab) and 0 or 1
    TabButton.BackgroundColor3 = Theme.CardBackground
    TabButton.Text = tabName
    TabButton.TextColor3 = (tabName == ActiveMainTab) and Theme.TextPrimary or Theme.TextSecondary
    TabButton.TextSize = 12
    TabButton.Font = Theme.FontBold
    TabButton.Parent = TabContainer

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    TabButton.MouseButton1Click:Connect(function()
        ActiveMainTab = tabName
        for _, btn in ipairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                local isActive = (btn.Text == tabName)
                Tween(btn, {
                    BackgroundTransparency = isActive and 0 or 1,
                    TextColor3 = isActive and Theme.TextPrimary or Theme.TextSecondary
                }, 0.15)
            end
        end
    end)
end

-- 4. Подвкладки
local SubTabs = {"Players", "World", "Effects"}
local ActiveSubTab = "World"

for _, subName in ipairs(SubTabs) do
    local SubButton = Instance.new("TextButton")
    SubButton.Size = UDim2.new(0, 60, 1, 0)
    SubButton.BackgroundTransparency = (subName == ActiveSubTab) and 0 or 1
    SubButton.BackgroundColor3 = Theme.CardBackground
    SubButton.Text = subName
    SubButton.TextColor3 = (subName == ActiveSubTab) and Theme.TextPrimary or Theme.TextSecondary
    SubButton.TextSize = 11
    SubButton.Font = Theme.Font
    SubButton.Parent = SubTabContainer

    local SubCorner = Instance.new("UICorner")
    SubCorner.CornerRadius = UDim.new(0, 6)
    SubCorner.Parent = SubButton

    SubButton.MouseButton1Click:Connect(function()
        ActiveSubTab = subName
        for _, btn in ipairs(SubTabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                local isActive = (btn.Text == subName)
                Tween(btn, {
                    BackgroundTransparency = isActive and 0 or 1,
                    TextColor3 = isActive and Theme.TextPrimary or Theme.TextSecondary
                }, 0.15)
            end
        end
    end)
end

-- ====================================================================
-- ПОЛНОЕ ЗАПОЛНЕНИЕ КАРТОЧЕК
-- ====================================================================

-- Секция 1: Shaders
local ShadersCard = UI:CreateCard("Shaders")
UI:AddDropdownToCard(ShadersCard, "Preset", {"Moonlight", "Sunlight", "Cyberpunk"}, "Moonlight")
UI:AddDropdownToCard(ShadersCard, "Skybox", {"Goodnight", "Daylight", "Purple Nebula"}, "Goodnight")
UI:AddDropdownToCard(ShadersCard, "Sun / Moon", {"Default", "Custom"}, "Default")
ShadersCard:AddToggle("Fog", true)
ShadersCard:AddToggle("Bloom", true)
ShadersCard:AddToggle("Sun Rays", true)
ShadersCard:AddToggle("Blur", false)
ShadersCard:AddSlider("Blur Amount", 0, 10, 1)
ShadersCard:AddToggle("Color Grade", true)
ShadersCard:AddToggle("Atmosphere", true)

-- Секция 2: Lighting
local LightingCard = UI:CreateCard("Lighting")
LightingCard:AddToggle("Fullbright", false)
LightingCard:AddToggle("Time Change", false)
LightingCard:AddToggle("Ambient", false)
LightingCard:AddToggle("Exposure", false)

-- Секция 3: Weather
local WeatherCard = UI:CreateCard("Weather")
UI:AddDropdownToCard(WeatherCard, "Type", {"Snow Soft", "Rain Heavy", "Foggy"}, "Snow Soft")
WeatherCard:AddSlider("Amount", 0, 500, 250)
WeatherCard:AddSlider("Fall Speed", 0, 200, 100)
WeatherCard:AddSlider("Particle Size", 0, 100, 33)
WeatherCard:AddSlider("Transparency", 0, 100, 100)
WeatherCard:AddSlider("Distance", 0, 300, 120)
WeatherCard:AddSlider("Height", 0, 200, 90)

-- Секция 4: Glyphs
local GlyphsCard = UI:CreateCard("Glyphs")
GlyphsCard:AddToggle("Glyphs", true)
UI:AddColorPickerToCard(GlyphsCard, "Color", Color3.fromRGB(50, 150, 255))
UI:AddDropdownToCard(GlyphsCard, "Theme", {"Theme", "Custom"}, "Theme")
GlyphsCard:AddSlider("Count", 0, 100, 55)

-- Секция 5: Sky
local SkyCard = UI:CreateCard("Sky")
SkyCard:AddToggle("Constellations", true)
SkyCard:AddToggle("Starfall", true)

-- Секция 6: Camera
local CameraCard = UI:CreateCard("Camera")
CameraCard:AddSlider("Field of View", 60, 120, 89, function(v)
    workspace.CurrentCamera.FieldOfView = v
end)
CameraCard:AddToggle("Unlock FPS", true)
CameraCard:AddToggle("No Zoom Limit", true)

print("SALAD UI Library успешно загружена!")
