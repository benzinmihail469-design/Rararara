-- [[ Pulse Hub GUI — Раздельный интерфейс с фиксацией и авто-центром ]] --
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

-- Функция для перетаскивания (работает независимо для любого окна)
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ 1. МАЛЕНЬКИЙ НЕЗАВИСИМЫЙ ЗАГОЛОВОК (Фиксируется где угодно) ]] --
local MiniFrame = Instance.new("Frame")
MiniFrame.Name = "MiniFrame"
MiniFrame.Parent = PulseHub
MiniFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MiniFrame.BackgroundTransparency = 0.15
MiniFrame.Position = UDim2.new(0.1, 0, 0.1, 0) -- Начальная позиция в углу
MiniFrame.Size = UDim2.new(0, 220, 0, 55)
MiniFrame.ZIndex = 10
Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 12)

local MiniStroke = Instance.new("UIStroke", MiniFrame)
MiniStroke.Color = Color3.fromRGB(45, 45, 45)
MiniStroke.Thickness = 1

local MiniIcon = Instance.new("ImageLabel", MiniFrame)
MiniIcon.Size = UDim2.new(0, 34, 0, 34)
MiniIcon.Position = UDim2.new(0, 12, 0, 10)
MiniIcon.Image = "rbxassetid://10840212450"
MiniIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 8)

local MiniTitle = Instance.new("TextLabel", MiniFrame)
MiniTitle.Text = "Pulse Hub"
MiniTitle.Font = Enum.Font.GothamBold
MiniTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniTitle.TextSize = 13
MiniTitle.Position = UDim2.new(0, 54, 0, 11)
MiniTitle.Size = UDim2.new(0, 100, 0, 16)
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left
MiniTitle.BackgroundTransparency = 1

local MiniSub = Instance.new("TextLabel", MiniFrame)
MiniSub.Text = "Grow A Garden 2"
MiniSub.Font = Enum.Font.Gotham
MiniSub.TextColor3 = Color3.fromRGB(140, 140, 140)
MiniSub.TextSize = 10
MiniSub.Position = UDim2.new(0, 54, 0, 27)
MiniSub.Size = UDim2.new(0, 100, 0, 14)
MiniSub.TextXAlignment = Enum.TextXAlignment.Left
MiniSub.BackgroundTransparency = 1

local ToggleBtn = Instance.new("TextButton", MiniFrame)
ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleBtn.Position = UDim2.new(1, -40, 0, 12)
ToggleBtn.Text = "—"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
ToggleBtn.BackgroundTransparency = 1

MakeDraggable(MiniFrame) -- Маленький заголовок можно таскать, он останется на месте!

-- [[ 2. ГЛАВНОЕ ГУИ (Всегда центрируется) ]] --
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = PulseHub
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175) -- Ровно центр
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- [[ ОСНОВНОЙ КОНТЕНТ ГЛАВНОГО ОКНА ]] --
local BodyContainer = Instance.new("Frame", MainFrame)
BodyContainer.Size = UDim2.new(1, 0, 1, 0)
BodyContainer.BackgroundTransparency = 1

local Sidebar = Instance.new("Frame", BodyContainer)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.BackgroundTransparency = 0.4
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

local Navigation = Instance.new("ScrollingFrame", Sidebar)
Navigation.Size = UDim2.new(1, 0, 1, -135)
Navigation.Position = UDim2.new(0, 0, 0, 20)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0
local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 4)

-- [[ ВЫДЕЛЕННЫЙ ПОДВАЛ В СЕНТРЕ С FPS ]] --
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

-- Счётчик FPS
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

-- [[ ЛОГИКА СВОРАЧИВАНИЯ / РАЗВОРАЧИВАНИЯ ]] --
local isMenuOpen = true

ToggleBtn.MouseButton1Click:Connect(function()
    isMenuOpen = not isMenuOpen
    if isMenuOpen then
        ToggleBtn.Text = "—"
        -- Принудительно кидаем Главное ГУИ строго в центр экрана при разворачивании!
        MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
        MainFrame.Size = UDim2.new(0, 550, 0, 0)
        MainFrame.Visible = true
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}, 0.25)
    else
        ToggleBtn.Text = "┌┐"
        local t = tween(MainFrame, {Size = UDim2.new(0, 550, 0, 0)}, 0.2)
        t.Completed:Connect(function()
            if not isMenuOpen then MainFrame.Visible = false end
        end)
    end
end)

-- [[ СИСТЕМА СТРАНИЦ ]] --
local PagesFolder = Instance.new("Folder", BodyContainer)
local allTabs = {}
local allPages = {}

local function CreatePage(name)
    local PageFrame = Instance.new("ScrollingFrame", PagesFolder)
    PageFrame.Size = UDim2.new(1, -180, 1, -40)
    PageFrame.Position = UDim2.new(0, 175, 0, 20)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
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

-- Инициализация вкладок
local MainPage = CreatePage("Main")
local AutoPage = CreatePage("Auto")

CreateToggle(MainPage, "Enable Role ESP", true)
CreateToggle(MainPage, "Gun ESP", false)

allTabs["Main"].BackgroundTransparency = 0
allTabs["Main"].TextColor3 = Color3.new(1,1,1)
allTabs["Main"].UIStroke.Enabled = true
allPages["Main"].Visible = true
