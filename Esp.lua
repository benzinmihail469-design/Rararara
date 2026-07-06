-- [[ Pulse Hub GUI — Фикс сворачивания, прозрачность и монолитный подвал ]] --
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

local function tween(obj, props, dur) 
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- [[ ГЛАВНОЕ ОКНО ]] --
local MainFrame = Instance.new("Frame", PulseHub)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainFrame.BackgroundTransparency = 0.15 -- Красивая прозрачность для заднего фона хаба
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.ClipsDescendants = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1.5

-- [[ КОНТЕЙНЕР ДЛЯ ВСЕГО САЙДБАРА (Защита от деформации при сворачивании) ]] --
local SidebarContainer = Instance.new("Frame", MainFrame)
SidebarContainer.Name = "SidebarContainer"
SidebarContainer.Size = UDim2.new(0, 160, 1, 0)
SidebarContainer.BackgroundTransparency = 1
SidebarContainer.ZIndex = 3

-- [[ ВЫДЕЛЕННАЯ ПЛАШКА ЗАГОЛОВКА ]] --
local HeaderBg = Instance.new("Frame", SidebarContainer)
HeaderBg.Name = "HeaderBg"
HeaderBg.Size = UDim2.new(1, -10, 0, 46)
HeaderBg.Position = UDim2.new(0, 10, 0, 10)
HeaderBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22) -- Полностью непрозрачная плашка
HeaderBg.BackgroundTransparency = 0
HeaderBg.ZIndex = 4

local HeaderCorner = Instance.new("UICorner", HeaderBg)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local HeaderStroke = Instance.new("UIStroke", HeaderBg)
HeaderStroke.Color = Color3.fromRGB(45, 45, 45)
HeaderStroke.Thickness = 1.2

local HubIcon = Instance.new("ImageLabel", HeaderBg)
HubIcon.Size = UDim2.new(0, 30, 0, 30)
HubIcon.Position = UDim2.new(0, 8, 0, 8)
HubIcon.Image = "rbxassetid://10840212450"
HubIcon.BackgroundTransparency = 1
HubIcon.ZIndex = 5

local HubTitle = Instance.new("TextLabel", HeaderBg)
HubTitle.Text = "Pulse Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Position = UDim2.new(0, 46, 0, 7)
HubTitle.Size = UDim2.new(0, 95, 0, 15)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1
HubTitle.ZIndex = 5

local SubTitle = Instance.new("TextLabel", HeaderBg)
SubTitle.Text = "Grow A Garden 2"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 130)
SubTitle.TextSize = 9
SubTitle.Position = UDim2.new(0, 46, 0, 23)
SubTitle.Size = UDim2.new(0, 95, 0, 13)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.BackgroundTransparency = 1
SubTitle.ZIndex = 5

-- [[ НАВИГАЦИЯ (ВКЛАДКИ) ]] --
local Navigation = Instance.new("ScrollingFrame", SidebarContainer)
Navigation.Size = UDim2.new(1, -10, 1, -135)
Navigation.Position = UDim2.new(0, 10, 0, 65)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0

local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [[ ВЫДЕЛЕННЫЙ ПОДВАЛ (В сочетании с заголовком) ]] --
local FooterBg = Instance.new("Frame", SidebarContainer)
FooterBg.Name = "FooterBg"
FooterBg.Size = UDim2.new(1, -10, 0, 46)
FooterBg.Position = UDim2.new(0, 10, 1, -56)
FooterBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22) -- Полностью непрозрачный подвал
FooterBg.BackgroundTransparency = 0
FooterBg.ZIndex = 4

local FooterCorner = Instance.new("UICorner", FooterBg)
FooterCorner.CornerRadius = UDim.new(0, 10)

local FooterStroke = Instance.new("UIStroke", FooterBg)
FooterStroke.Color = Color3.fromRGB(45, 45, 45) -- Такой же контур, как у заголовка
FooterStroke.Thickness = 1.2

local DiscordLabel = Instance.new("TextLabel", FooterBg)
DiscordLabel.Position = UDim2.new(0, 10, 0, 7)
DiscordLabel.Size = UDim2.new(1, -20, 0, 15)
DiscordLabel.Font = Enum.Font.GothamMedium
DiscordLabel.Text = "discord.gg/pulsezone"
DiscordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordLabel.TextSize = 10
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.ZIndex = 5

local StatsLabel = Instance.new("TextLabel", FooterBg)
StatsLabel.Position = UDim2.new(0, 10, 0, 23)
StatsLabel.Size = UDim2.new(1, -20, 0, 15)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "FPS: ..."
StatsLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.BackgroundTransparency = 1
StatsLabel.ZIndex = 5

local FrameUpdateTable = {}
RunService.RenderStepped:Connect(function()
    local CurrentTime = os.clock()
    table.insert(FrameUpdateTable, CurrentTime)
    while FrameUpdateTable[1] < CurrentTime - 1 do table.remove(FrameUpdateTable, 1) end
    StatsLabel.Text = "FPS: " .. #FrameUpdateTable
end)

-- [[ ВЕРХНЯЯ ПАНЕЛЬ КОНТЕНТА И КНОПОК ]] --
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5

local TabTitle = Instance.new("TextLabel", TopBar)
TabTitle.Text = "Auto"
TabTitle.Font = Enum.Font.GothamBold
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 185, 0, 18)
TabTitle.Size = UDim2.new(0, 150, 0, 20)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1

-- Кнопки управления (Привязаны к правому краю MainFrame)
local ButtonHolder = Instance.new("Frame", TopBar)
ButtonHolder.Name = "ButtonHolder"
ButtonHolder.Size = UDim2.new(0, 70, 0, 30)
ButtonHolder.Position = UDim2.new(1, -80, 0, 15)
ButtonHolder.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", ButtonHolder)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinBtn.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", ButtonHolder)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0, 35, 0, 0)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.Arial
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.BackgroundTransparency = 1

-- [[ ПРАВАЯ ЧАСТЬ: КОНТЕНТ СТРАНИЦ ]] --
local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -185, 1, -70)
PagesContainer.Position = UDim2.new(0, 175, 0, 60)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ZIndex = 2

-- [[ МОДЕРНИЗИРОВАННАЯ СИСТЕМА ИДЕАЛЬНОГО СВОРАЧИВАНИЯ ]] --
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        PagesContainer.Visible = false
        TabTitle.Visible = false
        
        -- Плавно перемещаем контейнер кнопок внутрь заголовка сайдбара, чтобы не ломать структуру
        ButtonHolder.Position = UDim2.new(0, 125, 0, 15)
        tween(MainFrame, {Size = UDim2.new(0, 170, 0, 350)}) -- Сжатие ровно по границе сайдбара
    else
        ButtonHolder.Position = UDim2.new(1, -80, 0, 15)
        
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}).Completed:Connect(function()
            if not isMinimized then
                PagesContainer.Visible = true
                TabTitle.Visible = true
            end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function() 
    local t = tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, 0.2)
    t.Completed:Connect(function() PulseHub:Destroy() end)
end)

-- Drag (Перетаскивание GUI за любую область)
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- [[ ГЕНЕРАТОР СТРАНИЦ ]] --
local allTabs = {}
local allPages = {}

local function CreatePage(name)
    local PageFrame = Instance.new("ScrollingFrame", PagesContainer)
    PageFrame.Name = name .. "Page"
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 0
    
    local PageLayout = Instance.new("UIListLayout", PageFrame)
    PageLayout.Padding = UDim.new(0, 6)
    
    local TabBtn = Instance.new("TextButton", Navigation)
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.Text = "   " .. name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 13
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    TabBtn.BackgroundTransparency = 1
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local TabStroke = Instance.new("UIStroke", TabBtn)
    TabStroke.Color = Color3.fromRGB(45, 45, 45)
    TabStroke.Enabled = false
    
    allTabs[name] = TabBtn
    allPages[name] = PageFrame
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, tBtn in pairs(allTabs) do
            tween(tBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)})
            tBtn.UIStroke.Enabled = false
            allPages[tName].Visible = false
        end
        TabTitle.Text = name
        PageFrame.Visible = true
        TabStroke.Enabled = true
        tween(TabBtn, {BackgroundTransparency = 0.5, TextColor3 = Color3.new(1,1,1)})
    end)
    
    return PageFrame
end

local function CreateToggle(parentPage, name, default, callback)
    local ToggleFrame = Instance.new("Frame", parentPage)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", ToggleFrame).Color = Color3.fromRGB(35, 35, 35)
    
    local ToggleTitle = Instance.new("TextLabel", ToggleFrame)
    ToggleTitle.Text = name
    ToggleTitle.Font = Enum.Font.GothamMedium
    ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    ToggleTitle.TextSize = 13
    ToggleTitle.Position = UDim2.new(0, 12, 0, 0)
    ToggleTitle.Size = UDim2.new(1, -60, 1, 0)
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.BackgroundTransparency = 1
    
    local ToggleBG = Instance.new("TextButton", ToggleFrame)
    ToggleBG.BackgroundColor3 = default and Color3.fromRGB(255, 90, 30) or Color3.fromRGB(45, 45, 45)
    ToggleBG.Position = UDim2.new(1, -45, 0, 11)
    ToggleBG.Size = UDim2.new(0, 32, 0, 18)
    ToggleBG.Text = ""
    Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1, 0)
    
    local ToggleCircle = Instance.new("Frame", ToggleBG)
    ToggleCircle.BackgroundColor3 = Color3.new(1,1,1)
    ToggleCircle.Position = default and UDim2.new(1, -15, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)
    
    local enabled = default
    ToggleBG.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            tween(ToggleBG, {BackgroundColor3 = Color3.fromRGB(255, 90, 30)})
            tween(ToggleCircle, {Position = UDim2.new(1, -15, 0, 2)})
        else
            tween(ToggleBG, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            tween(ToggleCircle, {Position = UDim2.new(0, 2, 0, 2)})
        end
        if callback then callback(enabled) end
    end)
end

-- [[ ИНИЦИАЛИЗАЦИЯ ]] --
local MainPage = CreatePage("Main")
local AutoPage = CreatePage("Auto")
local AutoBuyPage = CreatePage("Auto Buy")
local PlayersPage = CreatePage("Players")

CreateToggle(MainPage, "Anti-AFK System", true)
CreateToggle(AutoPage, "Auto Farm Grass", true)
CreateToggle(AutoPage, "Anti-Fling Bypass", true)

-- Выбор дефолтной вкладки
allTabs["Auto"].BackgroundTransparency = 0.5
allTabs["Auto"].TextColor3 = Color3.new(1,1,1)
allTabs["Auto"].UIStroke.Enabled = true
allPages["Auto"].Visible = true
