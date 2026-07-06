-- [[ Pulse Hub GUI — Фикс подвала и крестика по скриншоту 3384.jpg ]] --
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
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- [[ ГЛАВНОЕ ОКНО ]] --
local MainFrame = Instance.new("Frame", PulseHub)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1.5

-- [[ КОНТЕЙНЕР КНОПОК УПРАВЛЕНИЯ (ВЕРХНИЙ ПРАВЫЙ УГОЛ) ]] --
local ControlsContainer = Instance.new("Frame", MainFrame)
ControlsContainer.Name = "ControlsContainer"
ControlsContainer.Size = UDim2.new(0, 60, 0, 30)
ControlsContainer.Position = UDim2.new(1, -70, 0, 15)
ControlsContainer.BackgroundTransparency = 1
ControlsContainer.ZIndex = 10

local MinBtn = Instance.new("TextButton", ControlsContainer)
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(0, 0, 0, 3)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 12
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinBtn.BackgroundTransparency = 1
MinBtn.ZIndex = 11

local CloseBtn = Instance.new("TextButton", ControlsContainer)
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(0, 30, 0, 0)
CloseBtn.Text = "×" -- Четкий крестик
CloseBtn.Font = Enum.Font.Arial
CloseBtn.TextSize = 22
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.BackgroundTransparency = 1
CloseBtn.ZIndex = 11

-- [[ САЙДБАР ]] --
local SidebarContainer = Instance.new("Frame", MainFrame)
SidebarContainer.Name = "SidebarContainer"
SidebarContainer.Size = UDim2.new(0, 170, 1, 0)
SidebarContainer.BackgroundTransparency = 1
SidebarContainer.ZIndex = 3

-- ПЛАШКА ЗАГОЛОВКА
local HeaderBg = Instance.new("Frame", SidebarContainer)
HeaderBg.Name = "HeaderBg"
HeaderBg.Size = UDim2.new(0, 150, 0, 46)
HeaderBg.Position = UDim2.new(0, 10, 0, 10)
HeaderBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
HeaderBg.ZIndex = 4

local HeaderCorner = Instance.new("UICorner", HeaderBg)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local HeaderStroke = Instance.new("UIStroke", HeaderBg)
HeaderStroke.Color = Color3.fromRGB(45, 45, 45)
HeaderStroke.Thickness = 1.2

local HubTitle = Instance.new("TextLabel", HeaderBg)
HubTitle.Text = "Pulse Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Position = UDim2.new(0, 15, 0, 7)
HubTitle.Size = UDim2.new(0, 95, 0, 15)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1
HubTitle.ZIndex = 5

local SubTitle = Instance.new("TextLabel", HeaderBg)
SubTitle.Text = "Grow A Garden 2"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 130)
SubTitle.TextSize = 9
SubTitle.Position = UDim2.new(0, 15, 0, 23)
SubTitle.Size = UDim2.new(0, 95, 0, 13)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.BackgroundTransparency = 1
SubTitle.ZIndex = 5

-- Встроенная кнопка сворачивания (только для режима свёрнутого GUI, как на 3384.jpg)
local EmbeddedMinBtn = Instance.new("TextButton", HeaderBg)
EmbeddedMinBtn.Name = "EmbeddedMinBtn"
EmbeddedMinBtn.Size = UDim2.new(0, 20, 0, 20)
EmbeddedMinBtn.Position = UDim2.new(1, -30, 0, 13)
EmbeddedMinBtn.Text = "—"
EmbeddedMinBtn.Font = Enum.Font.GothamBold
EmbeddedMinBtn.TextSize = 12
EmbeddedMinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
EmbeddedMinBtn.BackgroundTransparency = 1
EmbeddedMinBtn.ZIndex = 6
EmbeddedMinBtn.Visible = false

-- НАВИГАЦИЯ
local Navigation = Instance.new("ScrollingFrame", SidebarContainer)
Navigation.Size = UDim2.new(1, -20, 1, -135)
Navigation.Position = UDim2.new(0, 10, 0, 65)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0

local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 5)

-- [[ ВОЗВРАЩЕННЫЙ ПОДВАЛ (ДИСКОРД И FPS) ]] --
local FooterBg = Instance.new("Frame", SidebarContainer)
FooterBg.Name = "FooterBg"
FooterBg.Size = UDim2.new(0, 150, 0, 46)
FooterBg.Position = UDim2.new(0, 10, 1, -56)
FooterBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
FooterBg.ZIndex = 4
Instance.new("UICorner", FooterBg).CornerRadius = UDim.new(0, 10)

local FooterStroke = Instance.new("UIStroke", FooterBg)
FooterStroke.Color = Color3.fromRGB(45, 45, 45)
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

local StatsLabel = Instance.new("TextLabel", FooterBg)
StatsLabel.Position = UDim2.new(0, 10, 0, 23)
StatsLabel.Size = UDim2.new(1, -20, 0, 15)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "FPS: ..."
StatsLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.BackgroundTransparency = 1

local FrameUpdateTable = {}
RunService.RenderStepped:Connect(function()
    local CurrentTime = os.clock()
    table.insert(FrameUpdateTable, CurrentTime)
    while FrameUpdateTable[1] < CurrentTime - 1 do table.remove(FrameUpdateTable, 1) end
    StatsLabel.Text = "FPS: " .. #FrameUpdateTable
end)

-- [[ КОНТЕНТ СТРАНИЦ ]] --
local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -185, 1, -70)
PagesContainer.Position = UDim2.new(0, 175, 0, 60)
PagesContainer.BackgroundTransparency = 1

local TabTitle = Instance.new("TextLabel", MainFrame)
TabTitle.Text = "Main"
TabTitle.Font = Enum.Font.GothamBold
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 185, 0, 18)
TabTitle.Size = UDim2.new(0, 150, 0, 20)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1

-- [[ ИСПРАВЛЕННАЯ АНИМАЦИЯ ВОЛНЫ (RIPPLE EFFECT) ]] --
local function CreateRipple(button)
    local mousePos = UserInputService:GetMouseLocation()
    local buttonPos = button.AbsolutePosition
    
    local Ripple = Instance.new("ImageLabel")
    Ripple.Name = "Ripple"
    Ripple.Parent = button
    Ripple.BackgroundTransparency = 1
    Ripple.Image = "rbxassetid://4012975932"
    Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Ripple.ImageTransparency = 0.65
    Ripple.ZIndex = button.ZIndex + 1
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local relativeX = mousePos.X - buttonPos.X
    local relativeY = (mousePos.Y - 36) - buttonPos.Y -- Учитываем верхнюю плашку Roblox
    Ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local maxLength = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 3
    local t = TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxLength, 0, maxLength),
        ImageTransparency = 1
    })
    t:Play()
    t.Completed:Connect(function() Ripple:Destroy() end)
end

-- [[ ИСПРАВЛЕННАЯ ЛОГИКА СВОРАЧИВАНИЯ ПО СКРИНШОТУ 3384.jpg ]] --
local isMinimized = false
local function ToggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        PagesContainer.Visible = false
        TabTitle.Visible = false
        Navigation.Visible = false
        FooterBg.Visible = false -- Подвал скрывается вместе с остальным GUI
        ControlsContainer.Visible = false
        
        MainStroke.Enabled = false
        MainFrame.BackgroundTransparency = 1
        
        HeaderBg.Position = UDim2.new(0, 0, 0, 0)
        EmbeddedMinBtn.Visible = true -- Появляется встроенная полосочка
        
        tween(MainFrame, {Size = UDim2.new(0, 150, 0, 46)})
    else
        EmbeddedMinBtn.Visible = false
        HeaderBg.Position = UDim2.new(0, 10, 0, 10)
        
        MainStroke.Enabled = true
        MainFrame.BackgroundTransparency = 0.15
        
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}).Completed:Connect(function()
            if not isMinimized then
                PagesContainer.Visible = true
                TabTitle.Visible = true
                Navigation.Visible = true
                FooterBg.Visible = true -- Подвал плавно возвращается обратно
                ControlsContainer.Visible = true
            end
        end)
    end
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)
EmbeddedMinBtn.MouseButton1Click:Connect(ToggleMinimize)
CloseBtn.MouseButton1Click:Connect(function() PulseHub:Destroy() end)

-- [[ DRAG ]] --
local dragToggle, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [[ СИСТЕМА ВКЛАДОК ]] --
local allTabs = {}
local allPages = {}

local function CreatePage(name)
    local PageFrame = Instance.new("ScrollingFrame", PagesContainer)
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 0
    Instance.new("UIListLayout", PageFrame).Padding = UDim.new(0, 6)
    
    local TabBtn = Instance.new("TextButton", Navigation)
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.Text = "   " .. name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 13
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    TabBtn.BackgroundTransparency = 1
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.ClipsDescendants = true
    TabBtn.ZIndex = 5
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local TabStroke = Instance.new("UIStroke", TabBtn)
    TabStroke.Color = Color3.fromRGB(45, 45, 45)
    TabStroke.Thickness = 1.2
    TabStroke.Enabled = false
    
    allTabs[name] = TabBtn
    allPages[name] = PageFrame
    
    TabBtn.MouseButton1Click:Connect(function()
        CreateRipple(TabBtn)
        
        for tName, tBtn in pairs(allTabs) do
            tween(tBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 140)})
            tBtn.UIStroke.Enabled = false
            allPages[tName].Visible = false
        end
        TabTitle.Text = name
        PageFrame.Visible = true
        TabStroke.Enabled = true
        tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1)})
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
CreateToggle(AutoPage, "Auto Farm Coins (Max Speed: 25)", false)

allTabs["Main"].BackgroundTransparency = 0
allTabs["Main"].TextColor3 = Color3.new(1,1,1)
allTabs["Main"].UIStroke.Enabled = true
allPages["Main"].Visible = true
