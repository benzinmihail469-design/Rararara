-- [[ Pulse Hub GUI — Полностью исправленные закругления углов шапки ]] --
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
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

-- Стильный контур вокруг всего GUI
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Появление
MainFrame.Size = UDim2.new(0, 550, 0, 0)
tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}, 0.3)

-- Скрипт перетаскивания (Drag)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- [[ ФИРМЕННЫЙ ЗАГОЛОВОК (Исправлена ширина на 100%) ]] --
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 55) -- Ширина 1 (100%), чтобы идеально сжиматься вместе с окном
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TopBar.BackgroundTransparency = 1 
TopBar.ZIndex = 5

local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 14)

local HubIcon = Instance.new("ImageLabel", TopBar)
HubIcon.Size = UDim2.new(0, 34, 0, 34)
HubIcon.Position = UDim2.new(0, 15, 0, 10)
HubIcon.Image = "rbxassetid://10840212450"
HubIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HubIcon.BackgroundTransparency = 0
Instance.new("UICorner", HubIcon).CornerRadius = UDim.new(0, 8)

local HubTitle = Instance.new("TextLabel", TopBar)
HubTitle.Text = "Pulse Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 14
HubTitle.Position = UDim2.new(0, 58, 0, 11)
HubTitle.Size = UDim2.new(0, 120, 0, 16)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", TopBar)
SubTitle.Text = "Grow A Garden 2"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Color3.fromRGB(140, 140, 140)
SubTitle.TextSize = 11
SubTitle.Position = UDim2.new(0, 58, 0, 27)
SubTitle.Size = UDim2.new(0, 120, 0, 14)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.BackgroundTransparency = 1

local TabTitle = Instance.new("TextLabel", TopBar)
TabTitle.Text = "— Auto"
TabTitle.Font = Enum.Font.GothamMedium
TabTitle.TextColor3 = Color3.fromRGB(100, 100, 100)
TabTitle.TextSize = 13
TabTitle.Position = UDim2.new(0, 165, 0, 11)
TabTitle.Size = UDim2.new(0, 150, 0, 16)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1

-- Контейнер кнопок управления (Привязан к правой стороне TopBar)
local ButtonHolder = Instance.new("Frame", TopBar)
ButtonHolder.Name = "ButtonHolder"
ButtonHolder.Size = UDim2.new(0, 60, 0, 30)
ButtonHolder.Position = UDim2.new(1, -75, 0, 12) -- Позиция от правого края для плавной адаптации
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

-- [[ ОСНОВНОЙ КОНТЕНТ ]] --
local BodyContainer = Instance.new("Frame", MainFrame)
BodyContainer.Size = UDim2.new(1, 0, 1, 0)
BodyContainer.BackgroundTransparency = 1
BodyContainer.ZIndex = 2

local Sidebar = Instance.new("Frame", BodyContainer)
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.BackgroundTransparency = 0.4
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

local Navigation = Instance.new("ScrollingFrame", Sidebar)
Navigation.Size = UDim2.new(1, 0, 1, -135)
Navigation.Position = UDim2.new(0, 0, 0, 60)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0

local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [[ ВЫДЕЛЕННЫЙ ПОДВАЛ С FPS ]] --
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

local FrameUpdateTable = {}
local function GetFPS()
    local CurrentTime = os.clock()
    table.insert(FrameUpdateTable, CurrentTime)
    while FrameUpdateTable[1] < CurrentTime - 1 do
        table.remove(FrameUpdateTable, 1)
    end
    return #FrameUpdateTable
end

RunService.RenderStepped:Connect(function()
    StatsLabel.Text = "Performance: " .. GetFPS() .. " FPS"
end)

-- Анимация кнопок
CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {TextColor3 = Color3.fromRGB(255, 70, 70)}) end)
CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {TextColor3 = Color3.fromRGB(150, 150, 150)}) end)
CloseBtn.MouseButton1Click:Connect(function()
    local t = tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, 0.2)
    t.Completed:Connect(function() PulseHub:Destroy() end)
end)

-- [[ УМНАЯ СИСТЕМА СВОРАЧИВАНИЯ ]] --
local isMinimized = false
MinBtn.MouseEnter:Connect(function() tween(MinBtn, {TextColor3 = Color3.new(1,1,1)}) end)
MinBtn.MouseLeave:Connect(function() tween(MinBtn, {TextColor3 = Color3.fromRGB(150, 150, 150)}) end)
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        BodyContainer.Visible = false
        TabTitle.Visible = false
        
        -- Включаем черный фон шапки
        TopBar.BackgroundTransparency = 0.15
        
        -- Сжимаем окно в красивую плашку, кнопки встают на место автоматически благодаря привязке к правому краю
        tween(MainFrame, {Size = UDim2.new(0, 240, 0, 55)}, 0.2)
    else
        -- Возвращаем в центр экрана при разворачивании
        MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
        TopBar.BackgroundTransparency = 1
        
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}, 0.2).Completed:Connect(function()
            if not isMinimized then 
                BodyContainer.Visible = true 
                TabTitle.Visible = true
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
    PageFrame.Name = name .. "Page"
    PageFrame.Size = UDim2.new(1, -180, 1, -75)
    PageFrame.Position = UDim2.new(0, 175, 0, 60)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    
    local PageLayout = Instance.new("UIListLayout", PageFrame)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local TabBtn = Instance.new("TextButton", Navigation)
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Position = UDim2.new(0, 5, 0, 0)
    TabBtn.Text = "     " .. name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    TabBtn.BackgroundTransparency = 1
    TabBtn.ClipsDescendants = true
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local TabStroke = Instance.new("UIStroke", TabBtn)
    TabStroke.Color = Color3.fromRGB(60, 60, 60)
    TabStroke.Thickness = 1
    TabStroke.Enabled = false
    
    allTabs[name] = TabBtn
    allPages[name] = PageFrame
    
    local function selectTab()
        for tName, tBtn in pairs(allTabs) do
            tween(tBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 140)})
            tBtn.UIStroke.Enabled = false
            allPages[tName].Visible = false
        end
        TabTitle.Text = "— " .. name
        PageFrame.Visible = true
        TabStroke.Enabled = true
        tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = Color3.new(1,1,1)})
    end
    
    TabBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(TabBtn, {Size = UDim2.new(1, -14, 0, 30), Position = UDim2.new(0, 7, 0, 1)}, 0.1)
            selectTab()
        end
    end)
    
    TabBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(TabBtn, {Size = UDim2.new(1, -10, 0, 32), Position = UDim2.new(0, 5, 0, 0)}, 0.1)
        end
    end)
    
    TabBtn.MouseEnter:Connect(function()
        if TabTitle.Text ~= "— " .. name then tween(TabBtn, {BackgroundTransparency = 0.6, TextColor3 = Color3.new(1,1,1)}) end
    end)
    TabBtn.MouseLeave:Connect(function()
        if TabTitle.Text ~= "— " .. name then
            tween(TabBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 140)})
        end
    end)
    
    return PageFrame
end

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

-- Вкладки
local MainPage = CreatePage("Main")
local AutoPage = CreatePage("Auto")
local AutoBuyPage = CreatePage("Auto Buy")
local PlayersPage = CreatePage("Players")

CreateToggle(AutoPage, "Auto Farm", true)
CreateToggle(AutoPage, "Anti-Fling", true)

allTabs["Auto"].BackgroundTransparency = 0
allTabs["Auto"].TextColor3 = Color3.new(1,1,1)
allTabs["Auto"].UIStroke.Enabled = true
allPages["Auto"].Visible = true
