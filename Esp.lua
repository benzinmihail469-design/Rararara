-- [[ Pulse Hub GUI — Родной дизайн, фиксация и авто-центрирование ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PulseHub = Instance.new("ScreenGui")

if game:GetService("CoreGui"):FindFirstChild("PulseHub") then
    game:GetService("CoreGui").PulseHub:Destroy()
end

PulseHub.Name = "PulseHub"
PulseHub.Parent = game:GetService("CoreGui")
PulseHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function tween(object, properties, duration)
    local info = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

-- [[ ГЛАВНОЕ ОКНО ]] --
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = PulseHub
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175) -- Всегда стартует в центре
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Скрипт перетаскивания (Drag)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [[ ОСНОВНОЙ КОНТЕНТ ]] --
local BodyContainer = Instance.new("Frame", MainFrame)
BodyContainer.Size = UDim2.new(1, 0, 1, 0)
BodyContainer.BackgroundTransparency = 1
BodyContainer.ZIndex = 2

-- [[ ЛЕВЫЙ САЙДБАР ]] --
local Sidebar = Instance.new("Frame", BodyContainer)
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.BackgroundTransparency = 0.4
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

-- [[ ВЕРНУЛ РОДНОЙ ЗАГОЛОВОК (Внутри сайдбара вверху, как на фото) ]] --
local BrandHeader = Instance.new("Frame", Sidebar)
BrandHeader.Name = "BrandHeader"
BrandHeader.Size = UDim2.new(1, 0, 0, 55)
BrandHeader.BackgroundTransparency = 1

local HubIcon = Instance.new("ImageLabel", BrandHeader)
HubIcon.Size = UDim2.new(0, 34, 0, 34)
HubIcon.Position = UDim2.new(0, 12, 0, 10)
HubIcon.Image = "rbxassetid://10840212450" -- Твоя зеленая иконка пульса
HubIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", HubIcon).CornerRadius = UDim.new(0, 8)

local HubTitle = Instance.new("TextLabel", BrandHeader)
HubTitle.Text = "Pulse Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Position = UDim2.new(0, 54, 0, 11)
HubTitle.Size = UDim2.new(0, 100, 0, 16)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", BrandHeader)
SubTitle.Text = "Grow A Garden 2"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Color3.fromRGB(140, 140, 140)
SubTitle.TextSize = 10
SubTitle.Position = UDim2.new(0, 54, 0, 27)
SubTitle.Size = UDim2.new(0, 100, 0, 14)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.BackgroundTransparency = 1

-- [[ НАЗВАНИЕ ТЕКУЩЕЙ ВКЛАДКИ СПРАВА ]] --
local TopBarRight = Instance.new("Frame", MainFrame)
TopBarRight.Name = "TopBarRight"
TopBarRight.Size = UDim2.new(1, -160, 0, 55)
TopBarRight.Position = UDim2.new(0, 160, 0, 0)
TopBarRight.BackgroundTransparency = 1
TopBarRight.ZIndex = 5

local TabTitle = Instance.new("TextLabel", TopBarRight)
TabTitle.Text = "Main"
TabTitle.Font = Enum.Font.GothamBold
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 15, 0, 15)
TabTitle.Size = UDim2.new(0, 150, 0, 20)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1

-- Кнопки управления (Справа вверху)
local ButtonHolder = Instance.new("Frame", TopBarRight)
ButtonHolder.Size = UDim2.new(0, 60, 0, 30)
ButtonHolder.Position = UDim2.new(1, -75, 0, 12)
ButtonHolder.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", ButtonHolder)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 12
MinBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
MinBtn.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", ButtonHolder)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0, 30, 0, 0)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.Arial
CloseBtn.TextSize = 22
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.BackgroundTransparency = 1

-- Навигация по вкладкам в сайдбаре
local Navigation = Instance.new("ScrollingFrame", Sidebar)
Navigation.Size = UDim2.new(1, 0, 1, -135)
Navigation.Position = UDim2.new(0, 0, 0, 60)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0
local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 4)

-- [[ ВЫДЕЛЕННЫЙ ПОДВАЛ С ЖИВЫМ FPS ]] --
local FooterFrame = Instance.new("Frame", Sidebar)
FooterFrame.Name = "FooterFrame"
FooterFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
FooterFrame.BackgroundTransparency = 0.3
FooterFrame.Position = UDim2.new(0, 8, 1, -55)
FooterFrame.Size = UDim2.new(1, -16, 0, 45)
Instance.new("UICorner", FooterFrame).CornerRadius = UDim.new(0, 8)

local FooterStroke = Instance.new("UIStroke", FooterFrame)
FooterStroke.Color = Color3.fromRGB(45, 45, 45)
FooterStroke.Thickness = 1

local DiscordLabel = Instance.new("TextLabel", FooterFrame)
DiscordLabel.Position = UDim2.new(0, 8, 0, 6)
DiscordLabel.Size = UDim2.new(1, -16, 0, 15)
DiscordLabel.Font = Enum.Font.GothamMedium
DiscordLabel.Text = "discord.gg/pulsezone"
DiscordLabel.TextColor3 = Color3.fromRGB(140, 140, 255)
DiscordLabel.TextSize = 10
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", FooterFrame)
StatsLabel.Position = UDim2.new(0, 8, 0, 22)
StatsLabel.Size = UDim2.new(1, -16, 0, 15)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Performance: ..."
StatsLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.BackgroundTransparency = 1

-- Оптимальный подсчет FPS
local FrameUpdateTable = {}
local function GetFPS()
    local CurrentTime = os.clock()
    table.insert(FrameUpdateTable, CurrentTime)
    while FrameUpdateTable[1] < CurrentTime - 1 do table.remove(FrameUpdateTable, 1) end
    return #FrameUpdateTable
end
RunService.RenderStepped:Connect(function()
    StatsLabel.Text = "Performance: " .. GetFPS() .. " FPS"
end)

-- [[ СИСТЕМА СВОРАЧИВАНИЯ С АВТО-ЦЕНТРИРОВАНИЕМ ]] --
local isMinimized = false

CloseBtn.MouseButton1Click:Connect(function() PulseHub:Destroy() end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        -- Сворачиваем: Скрываем контент страниц, меню вкладок и подвал
        Navigation.Visible = false
        FooterFrame.Visible = false
        TopBarRight.Visible = false
        
        -- Переносим кнопки управления внутрь маленького хедера, чтобы они были видны
        ButtonHolder.Parent = BrandHeader
        ButtonHolder.Position = UDim2.new(0, 170, 0, 12)
        
        -- Ужимаем всё ГУИ строго до размеров шапки бренда (240x55). Она зафиксируется там, где стояла!
        tween(MainFrame, {Size = UDim2.new(0, 240, 0, 55)}, 0.18)
    else
        -- Разворачиваем: Принудительно возвращаем окно В ЦЕНТР ЭКРАНА
        MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
        MainFrame.Size = UDim2.new(0, 550, 0, 55)
        
        -- Возвращаем кнопки обратно на правую сторону
        ButtonHolder.Parent = TopBarRight
        ButtonHolder.Position = UDim2.new(1, -75, 0, 12)
        
        -- Раскрываем высоту плавно
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}, 0.22).Completed:Connect(function()
            if not isMinimized then
                Navigation.Visible = true
                FooterFrame.Visible = true
                TopBarRight.Visible = true
            end
        end)
    end
end)

-- [[ СИСТЕМЫ СТРАНИЦ ]] --
local PagesFolder = Instance.new("Folder", BodyContainer)
local allTabs = {}
local allPages = {}

local function CreatePage(name)
    local PageFrame = Instance.new("ScrollingFrame", PagesFolder)
    PageFrame.Size = UDim2.new(1, -180, 1, -75)
    PageFrame.Position = UDim2.new(0, 175, 0, 60)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 2
    Instance.new("UIListLayout", PageFrame).Padding = UDim.new(0, 6)
    
    local TabBtn = Instance.new("TextButton", Navigation)
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Position = UDim2.new(0, 5, 0, 0)
    TabBtn.Text = "     " .. name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    TabBtn.BackgroundTransparency = 1
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local TabStroke = Instance.new("UIStroke", TabBtn)
    TabStroke.Color = Color3.fromRGB(60, 60, 60)
    TabStroke.Enabled = false
    
    allTabs[name] = TabBtn
    allPages[name] = PageFrame
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, tBtn in pairs(allTabs) do
            tBtn.BackgroundTransparency = 1
            tBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
            tBtn.UIStroke.Enabled = false
            allPages[tName].Visible = false
        end
        PageFrame.Visible = true
        TabStroke.Enabled = true
        TabTitle.Text = name
        tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = Color3.new(1,1,1)})
    end)
    
    return PageFrame
end

local function CreateToggle(parentPage, name, default)
    local ToggleFrame = Instance.new("Frame", parentPage)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    ToggleFrame.Size = UDim2.new(1, -5, 0, 38)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    local ToggleTitle = Instance.new("TextLabel", ToggleFrame)
    ToggleTitle.Text = name
    ToggleTitle.Font = Enum.Font.GothamMedium
    ToggleTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleTitle.TextSize = 12
    ToggleTitle.Position = UDim2.new(0, 12, 0, 0)
    ToggleTitle.Size = UDim2.new(1, -60, 1, 0)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.BackgroundTransparency = 1
    
    local ToggleBG = Instance.new("TextButton", ToggleFrame)
    ToggleBG.BackgroundColor3 = default and Color3.fromRGB(140, 140, 140) or Color3.fromRGB(40, 40, 40)
    ToggleBG.Position = UDim2.new(1, -45, 0, 10)
    ToggleBG.Size = UDim2.new(0, 32, 0, 18)
    ToggleBG.Text = ""
    Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1, 0)
    
    local ToggleCircle = Instance.new("Frame", ToggleBG)
    ToggleCircle.BackgroundColor3 = Color3.new(1,1,1)
    ToggleCircle.Position = default and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)
    
    local enabled = default
    ToggleBG.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            tween(ToggleBG, {BackgroundColor3 = Color3.fromRGB(140, 140, 140)})
            tween(ToggleCircle, {Position = UDim2.new(1, -16, 0, 2)})
        else
            tween(ToggleBG, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            tween(ToggleCircle, {Position = UDim2.new(0, 2, 0, 2)})
        end
    end)
end

-- Инициализация структуры
local MainPage = CreatePage("Main")
local AutoPage = CreatePage("Auto")

CreateToggle(MainPage, "Enable Role ESP", true)
CreateToggle(MainPage, "Gun ESP", false)

allTabs["Main"].BackgroundTransparency = 0
allTabs["Main"].TextColor3 = Color3.new(1,1,1)
allTabs["Main"].UIStroke.Enabled = true
allPages["Main"].Visible = true
