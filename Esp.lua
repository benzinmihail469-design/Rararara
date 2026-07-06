-- [[ Pulse Hub GUI — Полная монолитная версия со сворачиванием по ширине ]] --
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
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.ClipsDescendants = true -- Чтобы контент не вылезал при сжатии

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 35, 35)
MainStroke.Thickness = 1.5

-- [[ ВЕРХНЯЯ ПАНЕЛЬ (Кнопки управления) ]] --
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5

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

-- Название текущей вкладки справа от плашки
local TabTitle = Instance.new("TextLabel", TopBar)
TabTitle.Text = "Main"
TabTitle.Font = Enum.Font.GothamBold
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 185, 0, 18)
TabTitle.Size = UDim2.new(0, 150, 0, 20)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1

-- [[ ЛЕВАЯ ЧАСТЬ: САЙДБАР ]] --
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.ZIndex = 3

-- Оригинальная выделенная плашка под заголовок из скриншота 3358_3.jpg
local HeaderBackground = Instance.new("Frame", Sidebar)
HeaderBackground.Name = "HeaderBackground"
HeaderBackground.Size = UDim2.new(0, 150, 0, 46)
HeaderBackground.Position = UDim2.new(0, 10, 0, 10)
HeaderBackground.BackgroundColor3 = Color3.fromRGB(22, 22, 22) -- Черный аккуратный цвет заголовка
HeaderBackground.ZIndex = 4
local HeaderCorner = Instance.new("UICorner", HeaderBackground)
HeaderCorner.CornerRadius = UDim.new(0, 10)
local HeaderStroke = Instance.new("UIStroke", HeaderBackground)
HeaderStroke.Color = Color3.fromRGB(35, 35, 35)

local HubIcon = Instance.new("ImageLabel", HeaderBackground)
HubIcon.Size = UDim2.new(0, 30, 0, 30)
HubIcon.Position = UDim2.new(0, 8, 0, 8)
HubIcon.Image = "rbxassetid://10840212450"
HubIcon.BackgroundTransparency = 1
HubIcon.ZIndex = 5

local HubTitle = Instance.new("TextLabel", HeaderBackground)
HubTitle.Text = "Pulse Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Position = UDim2.new(0, 46, 0, 7)
HubTitle.Size = UDim2.new(0, 95, 0, 15)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1
HubTitle.ZIndex = 5

local SubTitle = Instance.new("TextLabel", HeaderBackground)
SubTitle.Text = "Grow A Garden 2"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 130)
SubTitle.TextSize = 9
SubTitle.Position = UDim2.new(0, 46, 0, 23)
SubTitle.Size = UDim2.new(0, 95, 0, 13)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.BackgroundTransparency = 1
SubTitle.ZIndex = 5

-- Навигация по вкладкам
local Navigation = Instance.new("ScrollingFrame", Sidebar)
Navigation.Size = UDim2.new(1, -10, 1, -120)
Navigation.Position = UDim2.new(0, 10, 0, 65)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0

local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Подвал сайдбара (Discord + FPS)
local FooterFrame = Instance.new("Frame", Sidebar)
FooterFrame.Name = "FooterFrame"
FooterFrame.BackgroundTransparency = 1
FooterFrame.Position = UDim2.new(0, 10, 1, -50)
FooterFrame.Size = UDim2.new(1, -20, 0, 40)

local DiscordLabel = Instance.new("TextLabel", FooterFrame)
DiscordLabel.Size = UDim2.new(1, 0, 0, 15)
DiscordLabel.Font = Enum.Font.GothamMedium
DiscordLabel.Text = "discord.gg/pulsezone"
DiscordLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Абсолютно белый Дискорд
DiscordLabel.TextSize = 10
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", FooterFrame)
StatsLabel.Position = UDim2.new(0, 0, 0, 16)
StatsLabel.Size = UDim2.new(1, 0, 0, 15)
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

-- [[ ПРАВАЯ ЧАСТЬ: КОНТЕНТ СТРАНИЦ ]] --
local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -185, 1, -70)
PagesContainer.Position = UDim2.new(0, 175, 0, 60)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ZIndex = 2

-- [[ ИДЕАЛЬНАЯ СИСТЕМА СВОРАЧИВАНИЯ ]] --
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        -- Сворачиваем всё окно до ширины сайдбара
        PagesContainer.Visible = false
        TabTitle.Visible = false
        ButtonHolder.Position = UDim2.new(0, 130, 0, 15) -- Сдвигаем кнопки ближе к сайдбару внутри шапки
        
        HeaderBackground.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Делаем заголовок темнее
        tween(MainFrame, {Size = UDim2.new(0, 170, 0, 350)}) -- Сжатие по ширине
    else
        -- Возвращаем исходный вид полноценного GUI
        ButtonHolder.Position = UDim2.new(1, -80, 0, 15)
        HeaderBackground.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}).Completed:Connect(function()
            if not isMinimized then
                PagesContainer.Visible = true
                TabTitle.Visible = true
            end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function() PulseHub:Destroy() end)

-- Перетаскивание (Drag)
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

-- [[ СИСТЕМЫ СТРАНИЦ И ВКЛАДОК ]] --
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
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

-- [[ СОЗДАНИЕ СТРУКТУРЫ И КОНТЕНТА ]] --
local MainPage = CreatePage("Main")
local AutoPage = CreatePage("Auto")
local AutoBuyPage = CreatePage("Auto Buy")
local PlayersPage = CreatePage("Players")

CreateToggle(MainPage, "Anti-AFK System", true)
CreateToggle(AutoPage, "Auto Farm Grass", false)
CreateToggle(AutoPage, "Auto Collect Coins", true)

-- Активация первой вкладки по умолчанию
allTabs["Main"].BackgroundTransparency = 0.5
allTabs["Main"].TextColor3 = Color3.new(1,1,1)
allTabs["Main"].UIStroke.Enabled = true
allPages["Main"].Visible = true
