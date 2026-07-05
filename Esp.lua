-- [[ Pulse Hub GUI — Исправленная и анимированная версия ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local PulseHub = Instance.new("ScreenGui")

-- Защита от повторного запуска (чтобы GUI не спавнился много раз)
if game:GetService("CoreGui"):FindFirstChild("PulseHub") then
    game:GetService("CoreGui").PulseHub:Destroy()
end

PulseHub.Name = "PulseHub"
PulseHub.Parent = game:GetService("CoreGui")
PulseHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Функция для плавной анимации
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
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Плавное появление GUI при запуске
MainFrame.Size = UDim2.new(0, 550, 0, 0)
tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}, 0.3)

-- Скрипт перетаскивания (Drag) окна мышкой
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

-- [[ САЙДБАР (ЛЕВОЕ МЕНЮ) ]] --
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.ZIndex = 2
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

-- Логотип
local LogoArea = Instance.new("Frame", Sidebar)
LogoArea.Size = UDim2.new(1, 0, 0, 50)
LogoArea.BackgroundTransparency = 1

local HubTitle = Instance.new("TextLabel", LogoArea)
HubTitle.Text = "Pulse Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.new(1,1,1)
HubTitle.TextSize = 14
HubTitle.Position = UDim2.new(0, 15, 0, 12)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Контейнер для вкладок
local Navigation = Instance.new("ScrollingFrame", Sidebar)
Navigation.Size = UDim2.new(1, 0, 1, -110)
Navigation.Position = UDim2.new(0, 0, 0, 55)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0

local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [[ ВЕРХНЯЯ ПАНЕЛЬ С УПРАВЛЕНИЕМ ]] --
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, -160, 0, 45)
TopBar.Position = UDim2.new(0, 160, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 3

local TabTitle = Instance.new("TextLabel", TopBar)
TabTitle.Text = "Main"
TabTitle.Font = Enum.Font.GothamBold
TabTitle.TextColor3 = Color3.new(1,1,1)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 15, 0, 15)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрытия (X)
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.BackgroundTransparency = 1

CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 70, 70)}) end)
CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {TextColor3 = Color3.fromRGB(150, 150, 150)}) end)
CloseBtn.MouseButton1Click:Connect(function()
    local t = tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, 0.2)
    t.Completed:Connect(function() PulseHub:Destroy() end)
end)

-- Кнопка сворачивания (-)
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -65, 0, 10)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
MinBtn.BackgroundTransparency = 1

local isMinimized = false
MinBtn.MouseEnter:Connect(function() tween(MinBtn, {TextColor3 = Color3.new(1,1,1)}) end)
MinBtn.MouseLeave:Connect(function() tween(MinBtn, {TextColor3 = Color3.fromRGB(150, 150, 150)}) end)
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    tween(MainFrame, {Size = isMinimized and UDim2.new(0, 550, 0, 45) or UDim2.new(0, 550, 0, 350)}, 0.25)
end)

-- [[ КОНТЕНТ (СТРАНИЦЫ) ]] --
local PagesFolder = Instance.new("Folder", MainFrame)
local allTabs = {}
local allPages = {}

-- Функция создания новой страницы (вкладки)
local function CreatePage(name)
    local PageFrame = Instance.new("ScrollingFrame", PagesFolder)
    PageFrame.Name = name .. "Page"
    PageFrame.Size = UDim2.new(1, -180, 1, -65)
    PageFrame.Position = UDim2.new(0, 175, 0, 55)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    
    local PageLayout = Instance.new("UIListLayout", PageFrame)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Кнопка в Сайдбаре
    local TabBtn = Instance.new("TextButton", Navigation)
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Position = UDim2.new(0, 5, 0, 0)
    TabBtn.Text = "     " .. name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.BackgroundTransparency = 1
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    allTabs[name] = TabBtn
    allPages[name] = PageFrame
    
    -- Логика переключения вкладки
    local function selectTab()
        for tName, tBtn in pairs(allTabs) do
            tween(tBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 140)})
            allPages[tName].Visible = false
        end
        TabTitle.Text = name
        PageFrame.Visible = true
        tween(TabBtn, {BackgroundTransparency = 0.4, TextColor3 = Color3.new(1,1,1)})
    end
    
    TabBtn.MouseButton1Click:Connect(selectTab)
    
    -- Анимация наведения мыши
    TabBtn.MouseEnter:Connect(function()
        if TabTitle.Text ~= name then
            tween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = Color3.new(1,1,1)})
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if TabTitle.Text ~= name then
            tween(TabBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 140)})
        end
    end)
    
    return PageFrame
end

-- Функция создания переключателя (Toggle) внутри страницы
local function CreateToggle(parentPage, name, default, callback)
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
        if callback then callback(enabled) end
    end)
end

-- [[ НАПОЛНЕНИЕ СТРАНИЦ ИЗ ФОТОГРАФИИ 3348.jpg ]] --

-- Создаем страницы (Вкладки)
local MainPage = CreatePage("Main")
local SheriffPage = CreatePage("Sheriff")
local MurderPage = CreatePage("Murder")
local AutoFarmPage = CreatePage("Auto Farm")
local TeleportPage = CreatePage("Teleport")
local SettingsPage = CreatePage("Settings")

-- Контент для страницы Auto Farm (как на скриншоте)
CreateToggle(AutoFarmPage, "Auto Farm", true, function(val) print("Auto Farm:", val) end)
CreateToggle(AutoFarmPage, "Auto-Respawn", false)
CreateToggle(AutoFarmPage, "Anti-Fling", true)
CreateToggle(AutoFarmPage, "Avoid Murderer", false)
CreateToggle(AutoFarmPage, "Auto-Fling", false)
CreateToggle(AutoFarmPage, "Kill Aura", false)

-- Делаем вкладку "Auto Farm" открытой по умолчанию
allTabs["Auto Farm"].BackgroundTransparency = 0.4
allTabs["Auto Farm"].TextColor3 = Color3.new(1,1,1)
allPages["Auto Farm"].Visible = true
TabTitle.Text = "Auto Farm"

-- [[ ИНФО-ПАНЕЛЬ СНИЗУ (FOOTER) ]] --
local DiscordLabel = Instance.new("TextLabel", Sidebar)
DiscordLabel.Position = UDim2.new(0, 12, 1, -30)
DiscordLabel.Size = UDim2.new(1, -12, 0, 15)
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.Text = "discord.gg/pulsezone"
DiscordLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
DiscordLabel.TextSize = 10
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", Sidebar)
StatsLabel.Position = UDim2.new(0, 12, 1, -18)
StatsLabel.Size = UDim2.new(1, -12, 0, 15)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Session: 02:30 — 163 FPS"
StatsLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
StatsLabel.TextSize = 9
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.BackgroundTransparency = 1
