-- [[ Dark Hub GUI — Полностью очищенный от оранжевой обводки ]] --
local RawAssetID = 93790908316981 

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")

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

-- [[ КОНТЕЙНЕР СТРАНИЦ ]] --
local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -185, 1, -70)
PagesContainer.Position = UDim2.new(0, 175, 0, 60)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ZIndex = 5

local TabTitle = Instance.new("TextLabel", MainFrame)
TabTitle.Text = "Main"
TabTitle.Font = Enum.Font.GothamBold
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 185, 0, 18)
TabTitle.Size = UDim2.new(0, 150, 0, 20)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1

-- [[ КОНТЕЙНЕР КНОПОК УПРАВЛЕНИЯ ]] --
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
CloseBtn.Text = "×"
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

local HubIcon = Instance.new("ImageLabel", HeaderBg)
HubIcon.Name = "HubIcon"
HubIcon.Size = UDim2.new(0, 28, 0, 28)
HubIcon.Position = UDim2.new(0, 8, 0, 9)
HubIcon.BackgroundTransparency = 1
HubIcon.ScaleType = Enum.ScaleType.Fit 
HubIcon.ZIndex = 5

task.spawn(function()
    HubIcon.Image = "rbxthumb://type=Asset&id=" .. RawAssetID .. "&w=150&h=150"
    pcall(function()
        local assetInfo = MarketplaceService:GetProductInfo(RawAssetID)
        if assetInfo and assetInfo.AssetTypeId == 13 then
            HubIcon.Image = "http://www.roblox.com/asset/?id=" .. tostring(RawAssetID)
        end
    end)
end)

local HubTitle = Instance.new("TextLabel", HeaderBg)
HubTitle.Text = "Pulse Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Position = UDim2.new(0, 44, 0, 7)
HubTitle.Size = UDim2.new(0, 95, 0, 15)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1
HubTitle.ZIndex = 5

local SubTitle = Instance.new("TextLabel", HeaderBg)
SubTitle.Text = "Grow A Garden 2"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 130)
SubTitle.TextSize = 9
SubTitle.Position = UDim2.new(0, 44, 0, 23)
SubTitle.Size = UDim2.new(0, 95, 0, 13)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.BackgroundTransparency = 1
SubTitle.ZIndex = 5

-- Свёрнутые контролы
local EmbeddedControls = Instance.new("Frame", HeaderBg)
EmbeddedControls.Name = "EmbeddedControls"
EmbeddedControls.Size = UDim2.new(0, 50, 0, 30)
EmbeddedControls.Position = UDim2.new(1, -55, 0, 8)
EmbeddedControls.BackgroundTransparency = 1
EmbeddedControls.ZIndex = 6
EmbeddedControls.Visible = false

local EmbMinBtn = Instance.new("TextButton", EmbeddedControls)
EmbMinBtn.Size = UDim2.new(0, 20, 0, 20)
EmbMinBtn.Position = UDim2.new(0, 0, 0, 5)
EmbMinBtn.Text = "—"
EmbMinBtn.Font = Enum.Font.GothamBold
EmbMinBtn.TextSize = 11
EmbMinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
EmbMinBtn.BackgroundTransparency = 1
EmbMinBtn.ZIndex = 7

local EmbCloseBtn = Instance.new("TextButton", EmbeddedControls)
EmbCloseBtn.Size = UDim2.new(0, 20, 0, 20)
EmbCloseBtn.Position = UDim2.new(0, 25, 0, 2)
EmbCloseBtn.Text = "×"
EmbCloseBtn.Font = Enum.Font.Arial
EmbCloseBtn.TextSize = 20
EmbCloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
EmbCloseBtn.BackgroundTransparency = 1
EmbCloseBtn.ZIndex = 7

-- НАВИГАЦИЯ
local Navigation = Instance.new("ScrollingFrame", SidebarContainer)
Navigation.Size = UDim2.new(1, -20, 1, -135)
Navigation.Position = UDim2.new(0, 10, 0, 65)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0
local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 5)

-- ПОДВАЛ (DISCORD)
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

-- [[ ЭФФЕКТ ВОЛНЫ (RIPPLE) ]] --
local function CreateRipple(button, clickX, clickY)
    local Ripple = Instance.new("ImageLabel")
    Ripple.Name = "Ripple"
    Ripple.Parent = button
    Ripple.BackgroundTransparency = 1
    Ripple.Image = "rbxassetid://4012975932"
    Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Ripple.ImageTransparency = 0.5
    Ripple.ZIndex = 25
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Position = UDim2.new(0, clickX, 0, clickY)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local maxLength = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 3
    local t = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxLength, 0, maxLength),
        ImageTransparency = 1
    })
    t:Play()
    t.Completed:Connect(function() Ripple:Destroy() end)
end

-- ЛОГИКА СВОРАЧИВАНИЯ
local isMinimized = false
local function ToggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        PagesContainer.Visible = false
        TabTitle.Visible = false
        Navigation.Visible = false
        FooterBg.Visible = false
        ControlsContainer.Visible = false
        MainStroke.Enabled = false
        MainFrame.BackgroundTransparency = 1
        HeaderBg.Position = UDim2.new(0, 0, 0, 0)
        HeaderBg.Size = UDim2.new(0, 175, 0, 46) 
        EmbeddedControls.Visible = true 
        tween(MainFrame, {Size = UDim2.new(0, 175, 0, 46)})
    else
        EmbeddedControls.Visible = false
        HeaderBg.Position = UDim2.new(0, 10, 0, 10)
        HeaderBg.Size = UDim2.new(0, 150, 0, 46)
        MainStroke.Enabled = true
        MainFrame.BackgroundTransparency = 0.15
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}).Completed:Connect(function()
            if not isMinimized then
                PagesContainer.Visible = true
                TabTitle.Visible = true
                Navigation.Visible = true
                FooterBg.Visible = true
                ControlsContainer.Visible = true
            end
        end)
    end
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)
EmbMinBtn.MouseButton1Click:Connect(ToggleMinimize)

local function CloseGui() PulseHub:Destroy() end
CloseBtn.MouseButton1Click:Connect(CloseGui)
EmbCloseBtn.MouseButton1Click:Connect(CloseGui)

local function applyHover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function() tween(btn, {TextColor3 = hoverColor}) end)
    btn.MouseLeave:Connect(function() tween(btn, {TextColor3 = normalColor}) end)
end
applyHover(MinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255))
applyHover(EmbMinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255))
applyHover(CloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70))
applyHover(EmbCloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70))

-- DRAG СИСТЕМА
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

-- [[ КОНСТРУКТОР ЭЛЕМЕНТОВ ]] --
local Library = {}

function Library:CreateButton(parentPage, text, callback)
    local Btn = Instance.new("TextButton", parentPage)
    Btn.Size = UDim2.new(1, -20, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Btn.Text = text
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.TextSize = 13
    Btn.ClipsDescendants = true
    Btn.ZIndex = 6
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", Btn)
    stroke.Color = Color3.fromRGB(40, 40, 40)
    
    Btn.MouseButton1Down:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        CreateRipple(Btn, mousePos.X - Btn.AbsolutePosition.X, (mousePos.Y - inset.Y) - Btn.AbsolutePosition.Y)
    end)
    
    Btn.MouseButton1Click:Connect(callback)
end

function Library:CreateToggle(parentPage, text, default, callback)
    local TglFrame = Instance.new("Frame", parentPage)
    TglFrame.Size = UDim2.new(1, -20, 0, 36)
    TglFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TglFrame.ZIndex = 6
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", TglFrame)
    stroke.Color = Color3.fromRGB(40, 40, 40)
    
    local TglLabel = Instance.new("TextLabel", TglFrame)
    TglLabel.Size = UDim2.new(1, -60, 1, 0)
    TglLabel.Position = UDim2.new(0, 12, 0, 0)
    TglLabel.Text = text
    TglLabel.Font = Enum.Font.GothamMedium
    TglLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TglLabel.TextSize = 13
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left
    TglLabel.BackgroundTransparency = 1
    TglLabel.ZIndex = 7
    
    local Checkbox = Instance.new("TextButton", TglFrame)
    Checkbox.Size = UDim2.new(0, 34, 0, 18)
    Checkbox.Position = UDim2.new(1, -44, 0.5, -9)
    Checkbox.BackgroundColor3 = default and Color3.fromRGB(240, 110, 20) or Color3.fromRGB(40, 40, 40)
    Checkbox.Text = ""
    Checkbox.ZIndex = 7
    Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 9)
    
    local Indicator = Instance.new("Frame", Checkbox)
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    Indicator.ZIndex = 8
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local enabled = default
    Checkbox.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            tween(Checkbox, {BackgroundColor3 = Color3.fromRGB(240, 110, 20)}, 0.2)
            tween(Indicator, {Position = UDim2.new(1, -16, 0.5, -7)}, 0.2)
        else
            tween(Checkbox, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
            tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.2)
        end
        callback(enabled)
    end)
end

-- [[ СИСТЕМА СТРАНИЦ ]] --
local allTabs = {}
local allPages = {}

local function CreatePage(name)
    local PageFrame = Instance.new("ScrollingFrame", PagesContainer)
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    PageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PageFrame.ZIndex = 5
    
    local layout = Instance.new("UIListLayout", PageFrame)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    Instance.new("UIPadding", PageFrame).PaddingTop = UDim.new(0, 2)
    
    -- Контейнер для вкладки (гарантирует закругление)
    local TabContainer = Instance.new("Frame", Navigation)
    TabContainer.Name = name .. "_Tab"
    TabContainer.Size = UDim2.new(1, 0, 0, 34)
    TabContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28) -- Цвет для активной вкладки
    TabContainer.BackgroundTransparency = 1
    TabContainer.ClipsDescendants = true
    TabContainer.ZIndex = 6
    
    local TabCorner = Instance.new("UICorner", TabContainer)
    TabCorner.CornerRadius = UDim.new(0, 8)
    
    -- Сама кнопка внутри контейнера
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 1, 0)
    TabBtn.Text = "   " .. name
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 13
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.BackgroundTransparency = 1
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.ZIndex = 7
    
    allTabs[name] = TabContainer
    allPages[name] = PageFrame
    
    -- Клик (Анимация волны + переключение страниц)
    TabBtn.MouseButton1Down:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        CreateRipple(TabContainer, mousePos.X - TabContainer.AbsolutePosition.X, (mousePos.Y - inset.Y) - TabContainer.AbsolutePosition.Y)
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, tContainer in pairs(allTabs) do
            tween(tContainer, {BackgroundTransparency = 1}, 0.2)
            tween(tContainer.TextButton, {TextColor3 = Color3.fromRGB(140, 140, 140)}, 0.2)
            allPages[tName].Visible = false
        end
        TabTitle.Text = name
        PageFrame.Visible = true
        
        tween(TabContainer, {BackgroundTransparency = 0}, 0.2)
        tween(TabBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
    end)
    
    return PageFrame
end

-- [[ ИНИЦИАЛИЗАЦИЯ ВКЛАДОК ]] --
local MainPage = CreatePage("Main")
local AutoPage = CreatePage("Auto")
local AutoBuyPage = CreatePage("Auto Buy")
local PlayersPage = CreatePage("Players")

-- [[ НАПОЛНЕНИЕ КОНТЕНТОМ ]] --
Library:CreateToggle(MainPage, "Авто-Фарм Монет", false, function(state)
    print("Статус автофарма:", state)
end)

-- Настройки дефолтной активной страницы (Main) при запуске скрипта
allTabs["Main"].BackgroundTransparency = 0
allTabs["Main"].TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
allPages["Main"].Visible = true
