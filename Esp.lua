-- [[ Pulse Hub GUI Clone ]] --
local PulseHub = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Sidebar = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local LogoArea = Instance.new("Frame")
local HubTitle = Instance.new("TextLabel")
local HubSub = Instance.new("TextLabel")
local Navigation = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ContentArea = Instance.new("Frame")
local TabTitle = Instance.new("TextLabel")
local TopBar = Instance.new("Frame")
local CloseBtn = Instance.new("TextButton")
local SearchBar = Instance.new("TextBox")
local ElementsHolder = Instance.new("ScrollingFrame")
local UIListLayout_2 = Instance.new("UIListLayout")

-- Настройка главного контейнера
PulseHub.Name = "PulseHub"
PulseHub.Parent = game:GetService("CoreGui")
PulseHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = PulseHub
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать окно

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- [[ САЙДБАР (Левое меню) ]] --
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.Size = UDim2.new(0, 160, 1, 0)

UICorner_2.CornerRadius = UDim.new(0, 10)
UICorner_2.Parent = Sidebar

LogoArea.Name = "LogoArea"
LogoArea.Parent = Sidebar
LogoArea.BackgroundTransparency = 1.000
LogoArea.Size = UDim2.new(1, 0, 0, 50)

HubTitle.Name = "HubTitle"
HubTitle.Parent = LogoArea
HubTitle.BackgroundTransparency = 1.000
HubTitle.Position = UDim2.new(0, 15, 0, 10)
HubTitle.Size = UDim2.new(1, -15, 0, 18)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.Text = "Pulse Hub"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 14.000
HubTitle.TextXAlignment = Enum.TextXAlignment.Left

HubSub.Name = "HubSub"
HubSub.Parent = LogoArea
HubSub.BackgroundTransparency = 1.000
HubSub.Position = UDim2.new(0, 15, 0, 26)
HubSub.Size = UDim2.new(1, -15, 0, 14)
HubSub.Font = Enum.Font.Gotham
HubSub.Text = "Murder Mystery 2"
HubSub.TextColor3 = Color3.fromRGB(120, 120, 120)
HubSub.TextSize = 10.000
HubSub.TextXAlignment = Enum.TextXAlignment.Left

Navigation.Name = "Navigation"
Navigation.Parent = Sidebar
Navigation.BackgroundTransparency = 1.000
Navigation.Position = UDim2.new(0, 0, 0, 55)
Navigation.Size = UDim2.new(1, 0, 1, -95)
Navigation.ScrollBarThickness = 0

UIListLayout.Parent = Navigation
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

-- [[ ЗОНА КОНТЕНТА ]] --
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1.000
ContentArea.Position = UDim2.new(0, 165, 0, 0)
ContentArea.Size = UDim2.new(1, -165, 1, 0)

TopBar.Name = "TopBar"
TopBar.Parent = ContentArea
TopBar.BackgroundTransparency = 1.000
TopBar.Size = UDim2.new(1, 0, 0, 45)

TabTitle.Name = "TabTitle"
TabTitle.Parent = TopBar
TabTitle.BackgroundTransparency = 1.000
TabTitle.Position = UDim2.new(0, 10, 0, 15)
TabTitle.Size = UDim2.new(0, 200, 0, 20)
TabTitle.Font = Enum.Font.GothamBold
TabTitle.Text = "Auto Farm"
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16.000
TabTitle.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TopBar
CloseBtn.BackgroundTransparency = 1.000
CloseBtn.Position = UDim2.new(1, -30, 0, 12)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 14.000

CloseBtn.MouseButton1Click:Connect(function()
    PulseHub:Destroy()
end)

SearchBar.Name = "SearchBar"
SearchBar.Parent = TopBar
SearchBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SearchBar.Position = UDim2.new(1, -150, 0, 12)
SearchBar.Size = UDim2.new(0, 110, 0, 22)
SearchBar.Font = Enum.Font.Gotham
SearchBar.PlaceholderText = "Search..."
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBar.TextSize = 11.000
local SearchCorner = Instance.new("UICorner", SearchBar)
SearchCorner.CornerRadius = UDim.new(0, 4)

ElementsHolder.Name = "ElementsHolder"
ElementsHolder.Parent = ContentArea
ElementsHolder.BackgroundTransparency = 1.000
ElementsHolder.Position = UDim2.new(0, 10, 0, 50)
ElementsHolder.Size = UDim2.new(1, -20, 1, -60)
ElementsHolder.ScrollBarThickness = 2
ElementsHolder.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)

UIListLayout_2.Parent = ElementsHolder
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_2.Padding = UDim.new(0, 6)

-- [[ ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ ]] --

-- Кнопка в Сайдбаре (Вкладка)
local function CreateTab(name, selected)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Parent = Navigation
    TabBtn.BackgroundColor3 = selected and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(14, 14, 14)
    TabBtn.BackgroundTransparency = selected and 0 or 1
    TabBtn.Size = UDim2.new(1, -10, 0, 30)
    TabBtn.Position = UDim2.new(0, 5, 0, 0)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Text = "    " .. name
    TabBtn.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(14, 14, 14)
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.TextSize = 12.000
    
    if selected then
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    end
    
    local btnCorner = Instance.new("UICorner", TabBtn)
    btnCorner.CornerRadius = UDim.new(0, 6)
end

-- Переключатель (Toggle) из правой части 3348.jpg
local function CreateToggle(name, default)
    local ToggleFrame = Instance.new("Frame")
    local ToggleTitle = Instance.new("TextLabel")
    local ToggleBG = Instance.new("TextButton")
    local ToggleCircle = Instance.new("Frame")
    
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Parent = ElementsHolder
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
    
    local tfCorner = Instance.new("UICorner", ToggleFrame)
    tfCorner.CornerRadius = UDim.new(0, 6)
    
    ToggleTitle.Parent = ToggleFrame
    ToggleTitle.BackgroundTransparency = 1.000
    ToggleTitle.Position = UDim2.new(0, 12, 0, 0)
    ToggleTitle.Size = UDim2.new(1, -60, 1, 0)
    ToggleTitle.Font = Enum.Font.GothamMedium
    ToggleTitle.Text = name
    ToggleTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleTitle.TextSize = 12.000
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    ToggleBG.Name = "ToggleBG"
    ToggleBG.Parent = ToggleFrame
    ToggleBG.BackgroundColor3 = default and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(40, 40, 40)
    ToggleBG.Position = UDim2.new(1, -45, 0, 10)
    ToggleBG.Size = UDim2.new(0, 32, 0, 18)
    ToggleBG.Text = ""
    
    local tbgCorner = Instance.new("UICorner", ToggleBG)
    tbgCorner.CornerRadius = UDim.new(1, 0)
    
    ToggleCircle.Name = "ToggleCircle"
    ToggleCircle.Parent = ToggleBG
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Position = default and UDim2.new(1, -15, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    
    local tcCorner = Instance.new("UICorner", ToggleCircle)
    tcCorner.CornerRadius = UDim.new(1, 0)
    
    -- Логика переключения
    local enabled = default
    ToggleBG.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            ToggleBG.BackgroundColor3 = Color3.fromRGB(140, 140, 140) -- Светло-серый активный цвет как на скрине
            ToggleCircle:TweenPosition(UDim2.new(1, -16, 0, 2), "Out", "Quad", 0.15, true)
        else
            ToggleBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ToggleCircle:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.15, true)
        }
    end)
end

-- [[ НАПОЛНЕНИЕ ИНТЕРФЕЙСА (копии элементов из 3348.jpg) ]] --

-- Вкладки слева
CreateTab("Main", false)
CreateTab("Sheriff", false)
CreateTab("Murder", false)
CreateTab("Auto Farm", true) -- Выбранная
CreateTab("Teleport", false)
CreateTab("Fun/Troll", false)
CreateTab("Fling Players", false)
CreateTab("Visuals", false)
CreateTab("Settings", false)

-- Переключатели справа (Auto Farm вкладка)
CreateToggle("Auto Farm", true)
CreateToggle("Auto-Respawn", false)
CreateToggle("Anti-Fling", true)
CreateToggle("Avoid Murderer", false)
CreateToggle("Auto-Fling", false)
CreateToggle("Kill Aura", false)

-- Подвал сайдбара с Discord ссылкой
local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Parent = Sidebar
DiscordLabel.BackgroundTransparency = 1.000
DiscordLabel.Position = UDim2.new(0, 12, 1, -30)
DiscordLabel.Size = UDim2.new(1, -12, 0, 15)
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.Text = "discord.gg/pulsezone"
DiscordLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
DiscordLabel.TextSize = 10.000
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Sidebar
StatsLabel.BackgroundTransparency = 1.000
StatsLabel.Position = UDim2.new(0, 12, 1, -18)
StatsLabel.Size = UDim2.new(1, -12, 0, 15)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Session: 02:30 — 163 FPS"
StatsLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
StatsLabel.TextSize = 9.000
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
