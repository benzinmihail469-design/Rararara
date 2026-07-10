local CustomIconID = "76579925188009"
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local startTime = os.clock()
local function formatSessionTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local antiAfkConnection = nil
local function toggleAntiAFK(state)
    if state then
        if not antiAfkConnection then
            antiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end

local function toggleShader(name, state, instanceClass, properties)
    local storageName = "PulseHub_" .. name
    local existing = Lighting:FindFirstChild(storageName)
    if state then
        if not existing then
            local shader = Instance.new(instanceClass)
            shader.Name = storageName
            for k, v in pairs(properties) do
                shader[k] = v
            end
            shader.Parent = Lighting
        end
    else
        if existing then
            existing:Destroy()
        end
    end
end

local SafeParent = nil
if typeof(gethui) == "function" then
    SafeParent = gethui()
elseif game:GetService("CoreGui") then
    local success, _ = pcall(function() return game:GetService("CoreGui").Name end)
    if success then
        SafeParent = game:GetService("CoreGui")
    end
end

if not SafeParent then
    SafeParent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local PulseHub = Instance.new("ScreenGui")
if SafeParent:FindFirstChild("PulseHub") then
    SafeParent.PulseHub:Destroy()
end

PulseHub.Name = "PulseHub"
PulseHub.Parent = SafeParent
PulseHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function tween(obj, props, dur)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function NormalizeText(str)
    if type(str) ~= "string" then return "" end
    local lowerStr = string.lower(str)
    local upperToLower = {
        ["А"]="а", ["Б"]="б", ["Вв"]="в", ["Г"]="г", ["Д"]="д", ["Е"]="е", ["Ё"]="ё", ["Ж"]="ж", ["З"]="з",
        ["И"]="и", ["Й"]="й", ["К"]="к", ["Л"]="л", ["М"]="м", ["Н"]="н", ["О"]="о", ["П"]="п", ["Р"]="р",
        ["С"]="с", ["Т"]="т", ["У"]="у", ["Ф"]="ф", ["Х"]="х", ["Ц"]="ц", ["Ч"]="ч", ["Ш"]="ш", ["Щ"]="щ",
        ["Ъ"]="ъ", ["Ы"]="ы", ["Ь"]="ь", ["Э"]="э", ["Ю"]="ю", ["Я"]="я"
    }
    for u, l in pairs(upperToLower) do
        lowerStr = string.gsub(lowerStr, u, l)
    end
    local synonyms = {
        ["авто"] = "auto", ["фарм"] = "farm", ["есп"] = "esp", ["монет"] = "coins",
        ["монеты"] = "coins", ["игроков"] = "players", ["игрок"] = "player",
        ["визуал"] = "visual", ["телепорт"] = "teleport", ["настройки"] = "settings", ["язык"] = "language"
    }
    for ru, en in pairs(synonyms) do
        lowerStr = string.gsub(lowerStr, ru, en)
    end
    local homoglyphs = {["а"] = "a", ["о"] = "o", ["с"] = "c", ["е"] = "e", ["р"] = "p", ["х"] = "x", ["у"] = "y"}
    for ru, en in pairs(homoglyphs) do
        lowerStr = string.gsub(lowerStr, ru, en)
    end
    return string.gsub(lowerStr, "[%p%s%c]", "")
end

local MainFrame = Instance.new("Frame", PulseHub)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 350)

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 1

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1.5

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
TabTitle.Size = UDim2.new(0, 200, 0, 20)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1

local ControlsContainer = Instance.new("Frame", MainFrame)
ControlsContainer.Name = "ControlsContainer"
ControlsContainer.Size = UDim2.new(0, 60, 0, 30)
ControlsContainer.Position = UDim2.new(1, -65, 0, 10)
ControlsContainer.BackgroundTransparency = 1
ControlsContainer.ZIndex = 10

local MinBtn = Instance.new("TextButton", ControlsContainer)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(0, 0, 0, 3)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 12
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinBtn.BackgroundTransparency = 1
MinBtn.ZIndex = 11

local CloseBtn = Instance.new("TextButton", ControlsContainer)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(0, 30, 0, 0)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.Arial
CloseBtn.TextSize = 22
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.BackgroundTransparency = 1
CloseBtn.ZIndex = 11

local SearchContainer = Instance.new("Frame", MainFrame)
SearchContainer.Size = UDim2.new(0, 160, 0, 30)
SearchContainer.Position = UDim2.new(1, -240, 0, 12)
SearchContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SearchContainer.ZIndex = 6
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8)

local SearchStroke = Instance.new("UIStroke", SearchContainer)
SearchStroke.Color = Color3.fromRGB(45, 45, 45)
SearchStroke.Thickness = 1.2

local SearchIcon = Instance.new("ImageLabel", SearchContainer)
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://6031154871"
SearchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
SearchIcon.ZIndex = 7

local ClearSearchBtn = Instance.new("TextButton", SearchContainer)
ClearSearchBtn.Size = UDim2.new(0, 16, 0, 16)
ClearSearchBtn.Position = UDim2.new(1, -22, 0.5, -8)
ClearSearchBtn.BackgroundTransparency = 1
ClearSearchBtn.Text = "×"
ClearSearchBtn.Font = Enum.Font.Gotham
ClearSearchBtn.TextSize = 16
ClearSearchBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
ClearSearchBtn.Visible = false
ClearSearchBtn.ZIndex = 8

local SearchBox = Instance.new("TextBox", SearchContainer)
SearchBox.Size = UDim2.new(1, -55, 1, 0)
SearchBox.Position = UDim2.new(0, 30, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ZIndex = 7

local SidebarContainer = Instance.new("Frame", MainFrame)
SidebarContainer.Size = UDim2.new(0, 170, 1, 0)
SidebarContainer.BackgroundTransparency = 1
SidebarContainer.ZIndex = 3

local HeaderBg = Instance.new("Frame", SidebarContainer)
HeaderBg.Size = UDim2.new(0, 150, 0, 46)
HeaderBg.Position = UDim2.new(0, 10, 0, 10)
HeaderBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
HeaderBg.ZIndex = 4
Instance.new("UICorner", HeaderBg).CornerRadius = UDim.new(0, 10)
local HeaderStroke = Instance.new("UIStroke", HeaderBg)
HeaderStroke.Color = Color3.fromRGB(45, 45, 45)

local HubIcon = Instance.new("ImageLabel", HeaderBg)
HubIcon.Size = UDim2.new(0, 28, 0, 28)
HubIcon.Position = UDim2.new(0, 8, 0, 9)
HubIcon.BackgroundTransparency = 1
HubIcon.ScaleType = Enum.ScaleType.Fit
HubIcon.ZIndex = 5
Instance.new("UICorner", HubIcon).CornerRadius = UDim.new(0, 6)
HubIcon.Image = "rbxthumb://type=Asset&id=" .. CustomIconID .. "&w=150&h=150"

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

local EmbeddedControls = Instance.new("Frame", HeaderBg)
EmbeddedControls.Size = UDim2.new(0, 50, 0, 30)
EmbeddedControls.Position = UDim2.new(1, -50, 0, 8)
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

local Navigation = Instance.new("ScrollingFrame", SidebarContainer)
Navigation.Size = UDim2.new(1, -20, 1, -125)
Navigation.Position = UDim2.new(0, 10, 0, 65)
Navigation.BackgroundTransparency = 1
Navigation.ScrollBarThickness = 0
Navigation.BorderSizePixel = 0

local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function UpdateNavCanvas()
    Navigation.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 15)
end
NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateNavCanvas)

local FooterBg = Instance.new("Frame", SidebarContainer)
FooterBg.Size = UDim2.new(0, 150, 0, 46)
FooterBg.Position = UDim2.new(0, 10, 1, -56)
FooterBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
FooterBg.ZIndex = 4
Instance.new("UICorner", FooterBg).CornerRadius = UDim.new(0, 10)
local FooterStroke = Instance.new("UIStroke", FooterBg)
FooterStroke.Color = Color3.fromRGB(45, 45, 45)

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
StatsLabel.Text = "FPS: ...  |  Session: 00:00:00"
StatsLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.BackgroundTransparency = 1

local fpsBuffer = {}
local maxSamples = 30
local updateInterval = 0.15
local lastUpdateTime = 0

RunService.RenderStepped:Connect(function(dt)
    local CurrentTime = os.clock()
    local currentFps = 1 / dt
    table.insert(fpsBuffer, currentFps)
    if #fpsBuffer > maxSamples then
        table.remove(fpsBuffer, 1)
    end
    
    lastUpdateTime = lastUpdateTime + dt
    if lastUpdateTime >= updateInterval then
        lastUpdateTime = 0
        local sum = 0
        for _, fps in ipairs(fpsBuffer) do
            sum = sum + fps
        end
        local averageFps = sum / #fpsBuffer
        local passedTime = CurrentTime - startTime
        StatsLabel.Text = string.format("FPS: %d  |  Session: %s", math.round(averageFps), formatSessionTime(passedTime))
    end
end)

local function CreateRipple(button, clickX, clickY)
    local Ripple = Instance.new("ImageLabel")
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
    local t = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, maxLength, 0, maxLength), ImageTransparency = 1})
    t:Play()
    t.Completed:Connect(function() Ripple:Destroy() end)
end

local isMinimized = false
local LastMinimizedPos = UDim2.new(0.5, 0, 0.5, 0)
local function ToggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        PagesContainer.Visible, TabTitle.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = false, false, false, false, false, false
        MainStroke.Enabled = false
        MainFrame.BackgroundTransparency = 1
        HeaderBg.Position = UDim2.new(0, 0, 0, 0)
        HeaderBg.Size = UDim2.new(0, 175, 0, 46)
        EmbeddedControls.Visible = true
        tween(MainFrame, {Size = UDim2.new(0, 175, 0, 46), Position = LastMinimizedPos})
    else
        LastMinimizedPos = MainFrame.Position
        EmbeddedControls.Visible = false
        HeaderBg.Position = UDim2.new(0, 10, 0, 10)
        HeaderBg.Size = UDim2.new(0, 150, 0, 46)
        MainStroke.Enabled = true
        MainFrame.BackgroundTransparency = 0.15
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350), Position = UDim2.new(0.5, 0, 0.5, 0)}).Completed:Connect(function()
            if not isMinimized then
                PagesContainer.Visible, TabTitle.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = true, true, true, true, true, true
            end
        end)
    end
end

MinBtn.Activated:Connect(ToggleMinimize)
EmbMinBtn.Activated:Connect(ToggleMinimize)

local function CloseGui()
    PulseHub:Destroy()
end
CloseBtn.Activated:Connect(CloseGui)
EmbCloseBtn.Activated:Connect(CloseGui)

local function applyHover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function() tween(btn, {TextColor3 = hoverColor}) end)
    btn.MouseLeave:Connect(function() tween(btn, {TextColor3 = normalColor}) end)
end
applyHover(MinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255))
applyHover(EmbMinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255))
applyHover(CloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70))
applyHover(EmbCloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70))
applyHover(ClearSearchBtn, Color3.fromRGB(150,150,150), Color3.fromRGB(255,255,255))

local dragToggle, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
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
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        MainFrame.Position = newPos
        LastMinimizedPos = newPos
    end
end)

Library = {}
Library.CurrentFont = Enum.Font.Gotham
Library.CurrentLanguage = "English"
Library.CurrentTabKey = "Main"

Library.TrackedMainBg = {}
Library.TrackedElementBg = {}
Library.TrackedAccents = {}
Library.TrackedMainText = {}
Library.TrackedSubText = {}
Library.TrackedStrokes = {}

local ThemeConfig = {
    ["Black"]         = { Accent = Color3.fromRGB(180, 180, 180), MainBg = Color3.fromRGB(12, 12, 12), ElementBg = Color3.fromRGB(22, 22, 22) },
    ["White"]         = { Accent = Color3.fromRGB(0, 122, 255),   MainBg = Color3.fromRGB(240, 240, 240), ElementBg = Color3.fromRGB(255, 255, 255) },
    ["Pink"]          = { Accent = Color3.fromRGB(255, 105, 180), MainBg = Color3.fromRGB(25, 15, 20),   ElementBg = Color3.fromRGB(40, 25, 35) },
    ["Red"]           = { Accent = Color3.fromRGB(255, 50, 50),   MainBg = Color3.fromRGB(20, 10, 10),   ElementBg = Color3.fromRGB(35, 15, 15) },
    ["Green"]         = { Accent = Color3.fromRGB(50, 255, 50),   MainBg = Color3.fromRGB(10, 20, 10),   ElementBg = Color3.fromRGB(15, 35, 15) },
    ["Blue"]          = { Accent = Color3.fromRGB(0, 150, 255),   MainBg = Color3.fromRGB(10, 15, 25),   ElementBg = Color3.fromRGB(20, 25, 40) },
    ["Ash Gray"]      = { Accent = Color3.fromRGB(112, 128, 144), MainBg = Color3.fromRGB(28, 30, 33),   ElementBg = Color3.fromRGB(40, 42, 46) },
    ["Deep Ocean"]    = { Accent = Color3.fromRGB(0, 206, 209),   MainBg = Color3.fromRGB(10, 20, 30),   ElementBg = Color3.fromRGB(15, 30, 45) },
    ["Royal Blue"]    = { Accent = Color3.fromRGB(65, 105, 225),  MainBg = Color3.fromRGB(12, 18, 34),   ElementBg = Color3.fromRGB(22, 32, 60) },
    ["Midnight Blue"] = { Accent = Color3.fromRGB(30, 144, 255),  MainBg = Color3.fromRGB(6, 10, 18),    ElementBg = Color3.fromRGB(12, 20, 35) },
    ["Galaxy Purple"] = { Accent = Color3.fromRGB(138, 43, 226),  MainBg = Color3.fromRGB(15, 10, 25),   ElementBg = Color3.fromRGB(28, 18, 46) },
    ["Neon Purple"]   = { Accent = Color3.fromRGB(224, 32, 255),  MainBg = Color3.fromRGB(18, 8, 28),    ElementBg = Color3.fromRGB(32, 12, 51) },
    ["Neon Cyber"]    = { Accent = Color3.fromRGB(0, 255, 255),   MainBg = Color3.fromRGB(10, 10, 12),   ElementBg = Color3.fromRGB(20, 20, 25) },
    ["Amber Glow"]    = { Accent = Color3.fromRGB(255, 165, 0),   MainBg = Color3.fromRGB(20, 16, 10),   ElementBg = Color3.fromRGB(36, 28, 18) },
    ["Anime"]         = { Accent = Color3.fromRGB(255, 111, 207), MainBg = Color3.fromRGB(24, 20, 26),   ElementBg = Color3.fromRGB(43, 35, 48) },
    ["Deep Violet"]   = { Accent = Color3.fromRGB(102, 51, 153),  MainBg = Color3.fromRGB(13, 11, 20),   ElementBg = Color3.fromRGB(23, 19, 36) },
    ["Cyanic"]        = { Accent = Color3.fromRGB(0, 255, 200),   MainBg = Color3.fromRGB(10, 22, 26),   ElementBg = Color3.fromRGB(18, 38, 46) },
    ["Blood Red"]     = { Accent = Color3.fromRGB(170, 0, 0),     MainBg = Color3.fromRGB(14, 4, 4),     ElementBg = Color3.fromRGB(28, 8, 8) },
    ["AMOLED"]        = { Accent = Color3.fromRGB(0, 0, 0),       MainBg = Color3.fromRGB(0, 0, 0),      ElementBg = Color3.fromRGB(15, 15, 15) }
}

local ThemeNamesList = {}
for name, _ in pairs(ThemeConfig) do table.insert(ThemeNamesList, name) end
table.sort(ThemeNamesList)

Library.CurrentThemeData = ThemeConfig["Deep Ocean"]

local allTabs = {}
local allTabButtons = {}
local allTabIcons = {}
local allPages = {}

function Library:UpdateTheme(themeName)
    local theme = ThemeConfig[themeName]
    if not theme then return end
    Library.CurrentThemeData = theme
    
    local bgLuminance = (theme.MainBg.R * 0.299 + theme.MainBg.G * 0.587 + theme.MainBg.B * 0.114)
    local isLightMode = bgLuminance > 0.5
    
    local mainTextColor = isLightMode and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(255, 255, 255)
    local subTextColor = isLightMode and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
    local strokeColor = isLightMode and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(45, 45, 45)
    
    for _, obj in ipairs(Library.TrackedMainBg) do
        if obj and obj.Parent then tween(obj, {BackgroundColor3 = theme.MainBg}) end
    end
    
    for _, obj in ipairs(Library.TrackedElementBg) do
        if obj and obj.Parent then
            if obj.Name == "TabContainer" then
                if Library.CurrentTabKey and allTabs[Library.CurrentTabKey] == obj then
                    tween(obj, {BackgroundColor3 = isLightMode and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(35, 35, 35), BackgroundTransparency = 0})
                else
                    tween(obj, {BackgroundColor3 = theme.ElementBg, BackgroundTransparency = 1})
                end
            else
                tween(obj, {BackgroundColor3 = theme.ElementBg})
            end
        end
    end
    
    for _, obj in ipairs(Library.TrackedStrokes) do
        if obj and obj.Parent then tween(obj, {Color = strokeColor}) end
    end
    
    for _, obj in ipairs(Library.TrackedMainText) do
        if obj and obj.Parent then 
            tween(obj, {TextColor3 = mainTextColor}) 
            if obj:IsA("TextBox") then
                obj.PlaceholderColor3 = subTextColor
            end
        end
    end
    
    for _, obj in ipairs(Library.TrackedSubText) do
        if obj and obj.Parent then tween(obj, {TextColor3 = subTextColor}) end
    end
    
    for tName, tBtn in pairs(allTabButtons) do
        if tName == Library.CurrentTabKey then
            tBtn.TextColor3 = mainTextColor
        else
            tBtn.TextColor3 = subTextColor
        end
    end
    
    for _, data in ipairs(Library.TrackedAccents) do
        if data.Type == "Toggle" then
            if data.IsEnabled() then
                tween(data.Checkbox, {BackgroundColor3 = theme.Accent})
                local brightness = (theme.Accent.R + theme.Accent.G + theme.Accent.B)
                if brightness > 2.5 then
                    tween(data.Indicator, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                else
                    tween(data.Indicator, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                end
            else
                tween(data.Checkbox, {BackgroundColor3 = isLightMode and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(40, 40, 40)})
                tween(data.Indicator, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            end
        elseif data.Type == "Dropdown" then
            local currentSelection = data.GetDefault()
            if data.Container and data.Container.Parent then
                data.Container.ScrollBarImageColor3 = theme.Accent
            end
            if data.SelectedLabel and data.SelectedLabel.Parent then
                tween(data.SelectedLabel, {TextColor3 = theme.Accent})
            end
            for optName, optData in pairs(data.Options) do
                optData.Check.TextColor3 = theme.Accent
                if optName == currentSelection then
                    tween(optData.Label, {TextColor3 = theme.Accent})
                else
                    optData.Label.TextColor3 = subTextColor
                end
            end
        end
    end
end

table.insert(Library.TrackedMainBg, MainFrame)
table.insert(Library.TrackedElementBg, SearchContainer)
table.insert(Library.TrackedElementBg, HeaderBg)
table.insert(Library.TrackedElementBg, FooterBg)

table.insert(Library.TrackedStrokes, MainStroke)
table.insert(Library.TrackedStrokes, SearchStroke)
table.insert(Library.TrackedStrokes, HeaderStroke)
table.insert(Library.TrackedStrokes, FooterStroke)

table.insert(Library.TrackedMainText, TabTitle)
table.insert(Library.TrackedMainText, HubTitle)
table.insert(Library.TrackedSubText, SubTitle)
table.insert(Library.TrackedMainText, DiscordLabel)
table.insert(Library.TrackedSubText, StatsLabel)
table.insert(Library.TrackedMainText, SearchBox)
table.insert(Library.TrackedMainText, MinBtn)
table.insert(Library.TrackedMainText, CloseBtn)
table.insert(Library.TrackedMainText, EmbMinBtn)
table.insert(Library.TrackedMainText, EmbCloseBtn)

local SearchableElements = {}
local LocaleObjects = {}

local Localization = {
    ["English"] = {
        ["Main"] = "Main", ["Teleport"] = "Teleport", ["Murder"] = "Murder", ["Sheriff"] = "Sheriff",
        ["Players"] = "Players", ["Visual"] = "Visual", ["Settings"] = "Settings", ["UI"] = "UI",
        ["Theme"] = "Theme", ["AutoFarmCoins"] = "Auto-Farm Coins",
        ["CinematicShader"] = "Cinematic Shaders", ["BloomShader"] = "Bloom Glow FX", ["BlurShader"] = "Screen Blur Effect",
        ["ShaderPreset"] = "Shader Preset", ["SkyboxChanger"] = "Skybox Changer",
        ["UISize"] = "UI Size", ["UITransparency"] = "UI Transparency", ["MenuFont"] = "Menu Font",
        ["Language"] = "Language", ["AntiAFK"] = "Anti-AFK", ["UITheme"] = "UI Theme",
        ["AnimatedWindow"] = "Animated Window", ["Gradient"] = "Gradient Background",
        ["shader pack"] = "Shader Pack",
        -- Новая локализация для шейдеров
        ["Enable"] = "Enable", ["Mode"] = "Mode", ["Bloom"] = "Bloom",
        ["Intensity"] = "Intensity", ["Size"] = "Size", ["Atmosphere"] = "Atmosphere",
        ["Density"] = "Density", ["Sun Rays"] = "Sun Rays", ["Blur"] = "Blur", ["Strength"] = "Strength"
    },
    ["Русский"] = {
        ["Main"] = "Главная", ["Teleport"] = "Телепорт", ["Murder"] = "Убийца", ["Sheriff"] = "Шериф",
        ["Players"] = "Игроки", ["Visual"] = "Визуалы", ["Settings"] = "Настройки", ["UI"] = "Интерфейс",
        ["Theme"] = "Тема", ["AutoFarmCoins"] = "Авто-Фарм Монет",
        ["CinematicShader"] = "Кинематографичные Шейдеры", ["BloomShader"] = "Эффект Свечения", ["BlurShader"] = "Размытие Экрана",
        ["ShaderPreset"] = "Пресет Шейдеров", ["SkyboxChanger"] = "Смена Неба",
        ["UISize"] = "Размер интерфейса", ["UITransparency"] = "Прозрачность меню", ["MenuFont"] = "Шрифт меню",
        ["Language"] = "Язык", ["AntiAFK"] = "Анти-АФК", ["UITheme"] = "Тема UI",
        ["AnimatedWindow"] = "Анимированное окно", ["Gradient"] = "Градиентный фон",
        ["shader pack"] = "Пак шейдеров",
        -- Новая локализация для шейдеров
        ["Enable"] = "Включить", ["Mode"] = "Режим", ["Bloom"] = "Блум (Свечение)",
        ["Intensity"] = "Интенсивность", ["Size"] = "Размер", ["Atmosphere"] = "Атмосфера",
        ["Density"] = "Плотность", ["Sun Rays"] = "Лучи солнца", ["Blur"] = "Размытие", ["Strength"] = "Сила"
    }
}

local animatedWindowConnection = nil
local function toggleAnimatedWindow(state)
    if state then
        if not animatedWindowConnection then
            animatedWindowConnection = RunService.RenderStepped:Connect(function()
                local hue = (os.clock() * 0.15) % 1
                local rainbowColor = Color3.fromHSV(hue, 0.6, 1)
                
                for _, stroke in ipairs(Library.TrackedStrokes) do
                    if stroke and stroke.Parent then
                        stroke.Color = rainbowColor
                    end
                end
            end)
        end
    else
        if animatedWindowConnection then
            animatedWindowConnection:Disconnect()
            animatedWindowConnection = nil
            
            local bgL = (Library.CurrentThemeData.MainBg.R * 0.299 + Library.CurrentThemeData.MainBg.G * 0.587 + Library.CurrentThemeData.MainBg.B * 0.114)
            local defaultStrokeColor = (bgL > 0.5) and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(45, 45, 45)
            
            for _, stroke in ipairs(Library.TrackedStrokes) do
                if stroke and stroke.Parent then
                    stroke.Color = defaultStrokeColor
                end
            end
        end
    end
end

local uiGradientInstance = nil
local gradientRotateConnection = nil
local function toggleGradientEffect(state)
    if state then
        if not uiGradientInstance then
            uiGradientInstance = Instance.new("UIGradient")
            uiGradientInstance.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 16, 35)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 14, 18)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 24, 38))
            })
            uiGradientInstance.Parent = MainFrame
        end
        if not gradientRotateConnection then
            gradientRotateConnection = RunService.RenderStepped:Connect(function()
                if uiGradientInstance and uiGradientInstance.Parent then
                    uiGradientInstance.Rotation = (os.clock() * 25) % 360
                end
            end)
        end
    else
        if gradientRotateConnection then
            gradientRotateConnection:Disconnect()
            gradientRotateConnection = nil
        end
        if uiGradientInstance then
            uiGradientInstance:Destroy()
            uiGradientInstance = nil
        end
    end
end

local SearchResultsPage = Instance.new("ScrollingFrame", PagesContainer)
SearchResultsPage.Size = UDim2.new(1, 0, 1, 0)
SearchResultsPage.BackgroundTransparency = 1
SearchResultsPage.Visible = false
SearchResultsPage.ScrollBarThickness = 2
SearchResultsPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
SearchResultsPage.ZIndex = 5

local searchLayout = Instance.new("UIListLayout", SearchResultsPage)
searchLayout.Padding = UDim.new(0, 8)
searchLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
searchLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", SearchResultsPage).PaddingTop = UDim.new(0, 2)

searchLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SearchResultsPage.CanvasSize = UDim2.new(0, 0, 0, searchLayout.AbsoluteContentSize.Y + 15)
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local rawText = SearchBox.Text
    local query = NormalizeText(rawText)
    ClearSearchBtn.Visible = (rawText ~= "")
    if rawText == "" then
        SearchResultsPage.Visible = false
        for _, item in ipairs(SearchableElements) do
            item.Instance.Parent = item.OriginalParent
            item.Instance.Visible = true
        end
        if allPages[Library.CurrentTabKey] then allPages[Library.CurrentTabKey].Visible = true end
    else
        for _, page in pairs(allPages) do page.Visible = false end
        SearchResultsPage.Visible = true
        for _, item in ipairs(SearchableElements) do
            if string.find(item.SearchText, query, 1, true) then
                item.Instance.Parent = SearchResultsPage
                item.Instance.Visible = true
            else
                item.Instance.Visible = false
            end
        end
    end
end)

ClearSearchBtn.Activated:Connect(function() SearchBox.Text = "" end)

local FontMapping = {
    ["Gotham"] = Enum.Font.Gotham, ["Gotham Bold"] = Enum.Font.GothamBold, ["Source Sans"] = Enum.Font.SourceSans,
    ["Roboto"] = Enum.Font.Roboto, ["Roboto Mono"] = Enum.Font.RobotoMono, ["Ubuntu"] = Enum.Font.Ubuntu,
    ["Michroma"] = Enum.Font.Michroma, ["Code"] = Enum.Font.Code, ["Fantasy"] = Enum.Font.Fantasy,
    ["Fredoka One"] = Enum.Font.FredokaOne
}

function Library:CreateDropdown(parentPage, textKey, options, default, callback, previews)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local DropdownFrame = Instance.new("Frame", parentPage)
    DropdownFrame.Size = UDim2.new(1, -20, 0, 36)
    DropdownFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.ZIndex = 6
    DropdownFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)
    local DropdownStroke = Instance.new("UIStroke", DropdownFrame)
    DropdownStroke.Color = Color3.fromRGB(40, 40, 40)
    DropdownStroke.Thickness = 1
    
    table.insert(Library.TrackedElementBg, DropdownFrame)
    table.insert(Library.TrackedStrokes, DropdownStroke)
    
    local HeaderBtn = Instance.new("TextButton", DropdownFrame)
    HeaderBtn.Size = UDim2.new(1, 0, 0, 36)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.ZIndex = 7
    
    local TitleLabel = Instance.new("TextLabel", HeaderBtn)
    TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Text = initialText
    TitleLabel.Font = Library.CurrentFont
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 8
    
    table.insert(Library.TrackedMainText, TitleLabel)
    
    local SelectedLabel = Instance.new("TextLabel", HeaderBtn)
    SelectedLabel.Size = UDim2.new(0.5, -30, 1, 0)
    SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
    SelectedLabel.Text = default
    SelectedLabel.Font = Library.CurrentFont
    SelectedLabel.TextColor3 = Library.CurrentThemeData.Accent 
    SelectedLabel.TextSize = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.ZIndex = 8
    
    local Arrow = Instance.new("TextLabel", HeaderBtn)
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Text = "▼"
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    Arrow.TextSize = 10
    Arrow.BackgroundTransparency = 1
    Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    Arrow.Position = UDim2.new(1, -16, 0.5, 0)
    Arrow.ZIndex = 8
    
    table.insert(Library.TrackedSubText, Arrow)
    
    local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame)
    OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
    OptionsContainer.Position = UDim2.new(0, 0, 0, 36)
    OptionsContainer.BackgroundTransparency = 1
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.ScrollBarThickness = 3
    OptionsContainer.ScrollBarImageColor3 = Library.CurrentThemeData.Accent
    OptionsContainer.ZIndex = 7
    
    local ListLayout = Instance.new("UIListLayout", OptionsContainer)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    if previews then
        local UIPadding = Instance.new("UIPadding", OptionsContainer)
        UIPadding.PaddingBottom = UDim.new(0, 6)
    end

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + (previews and 10 or 0))
    end)
    
    local isExpanded = false
    local optionButtons = {}
    
    local PreviewImage
    if previews then
        PreviewImage = Instance.new("ImageLabel", OptionsContainer)
        PreviewImage.Size = UDim2.new(1, -24, 0, 110)
        PreviewImage.Position = UDim2.new(0, 12, 0, 0)
        PreviewImage.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        PreviewImage.BackgroundTransparency = 0.3
        PreviewImage.ScaleType = Enum.ScaleType.Crop
        PreviewImage.ZIndex = 8
        PreviewImage.LayoutOrder = 9999
        Instance.new("UICorner", PreviewImage).CornerRadius = UDim.new(0, 6)
        
        local PreviewStroke = Instance.new("UIStroke", PreviewImage)
        PreviewStroke.Color = Color3.fromRGB(55, 55, 55)
        PreviewStroke.Thickness = 1
        table.insert(Library.TrackedStrokes, PreviewStroke)

        local currentImg = previews[default] or ""
        if tonumber(currentImg) then
            PreviewImage.Image = "rbxassetid://" .. tostring(currentImg)
        else
            PreviewImage.Image = currentImg
        end
    end
    
    local function toggleDropdown()
        isExpanded = not isExpanded
        local baseOptionsHeight = #options * 32
        local maxVisibleOptionsHeight = 140
        local contentHeight = math.min(baseOptionsHeight, maxVisibleOptionsHeight)
        
        if previews then
            contentHeight = contentHeight + 122
        end
        
        local targetFrameHeight = isExpanded and (36 + contentHeight + 4) or 36
        
        tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, targetFrameHeight)}, 0.2)
        tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, isExpanded and contentHeight or 0)}, 0.2)
        tween(Arrow, {Rotation = isExpanded and 180 or 0}, 0.2)
    end
    HeaderBtn.Activated:Connect(toggleDropdown)
    
    for i, option in ipairs(options) do
        local OptBtn = Instance.new("TextButton", OptionsContainer)
        OptBtn.Size = UDim2.new(1, 0, 0, 32)
        OptBtn.BackgroundTransparency = 1
        OptBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptBtn.Text = ""
        OptBtn.LayoutOrder = i
        OptBtn.ZIndex = 8
        
        local OptLabel = Instance.new("TextLabel", OptBtn)
        OptLabel.Size = UDim2.new(1, -40, 1, 0)
        OptLabel.Position = UDim2.new(0, 16, 0, 0)
        OptLabel.Text = option
        OptLabel.TextSize = 12
        OptLabel.TextXAlignment = Enum.TextXAlignment.Left
        OptLabel.BackgroundTransparency = 1
        OptLabel.ZIndex = 9
        
        if FontMapping and FontMapping[option] then
            OptLabel.Font = FontMapping[option]
            OptLabel.Name = "FontPreviewLabel" 
        else
            OptLabel.Font = Library.CurrentFont
        end
        
        local Checkmark = Instance.new("TextLabel", OptBtn)
        Checkmark.Size = UDim2.new(0, 20, 1, 0)
        Checkmark.Position = UDim2.new(1, -30, 0, 0)
        Checkmark.Text = "✓"
        Checkmark.Font = Enum.Font.GothamBold
        Checkmark.TextColor3 = Library.CurrentThemeData.Accent
        Checkmark.TextSize = 12
        Checkmark.BackgroundTransparency = 1
        Checkmark.Visible = (option == default)
        Checkmark.ZIndex = 9
        
        OptBtn.MouseEnter:Connect(function()
            tween(OptBtn, {BackgroundTransparency = 0.96}, 0.15)
            if previews and previews[option] then
                local img = previews[option]
                PreviewImage.Image = tonumber(img) and ("rbxassetid://" .. tostring(img)) or img
            end
        end)
        OptBtn.MouseLeave:Connect(function()
            tween(OptBtn, {BackgroundTransparency = 1}, 0.15)
            if previews then
                local currentSelected = SelectedLabel.Text
                local img = previews[currentSelected] or previews[default] or ""
                PreviewImage.Image = tonumber(img) and ("rbxassetid://" .. tostring(img)) or img
            end
        end)
        
        optionButtons[option] = {Button = OptBtn, Label = OptLabel, Check = Checkmark}
        OptBtn.Activated:Connect(function()
            SelectedLabel.Text = option
            for optName, optData in pairs(optionButtons) do
                if optName == option then
                    optData.Label.TextColor3 = Library.CurrentThemeData.Accent
                    optData.Check.Visible = true
                else
                    local bgL = (Library.CurrentThemeData.MainBg.R * 0.299 + Library.CurrentThemeData.MainBg.G * 0.587 + Library.CurrentThemeData.MainBg.B * 0.114)
                    optData.Label.TextColor3 = (bgL > 0.5) and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(180, 180, 180)
                    optData.Check.Visible = false
                end
            end
            if previews and previews[option] then
                local img = previews[option]
                PreviewImage.Image = tonumber(img) and ("rbxassetid://" .. tostring(img)) or img
            end
            toggleDropdown()
            callback(option)
        end)
    end
    
    table.insert(Library.TrackedAccents, {
        Type = "Dropdown",
        Options = optionButtons,
        Container = OptionsContainer,
        SelectedLabel = SelectedLabel, 
        GetDefault = function() return SelectedLabel.Text end
    })
    
    local searchItem = {Instance = DropdownFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = TitleLabel, Key = textKey, SearchItem = searchItem})
end

function Library:CreateButton(parentPage, textKey, callback)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local Btn = Instance.new("TextButton", parentPage)
    Btn.Size = UDim2.new(1, -20, 0, 36)
    Btn.BackgroundColor3 = Library.CurrentThemeData.ElementBg
    Btn.Text = initialText
    Btn.Font = Library.CurrentFont
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.TextSize = 13
    Btn.ClipsDescendants = true
    Btn.ZIndex = 6
    Btn.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Color3.fromRGB(40, 40, 40)
    
    table.insert(Library.TrackedElementBg, Btn)
    table.insert(Library.TrackedMainText, Btn)
    table.insert(Library.TrackedStrokes, BtnStroke)
    
    Btn.MouseButton1Down:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        CreateRipple(Btn, mousePos.X - Btn.AbsolutePosition.X, (mousePos.Y - inset.Y) - Btn.AbsolutePosition.Y)
    end)
    Btn.Activated:Connect(callback)
    local searchItem = {Instance = Btn, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = Btn, Key = textKey, SearchItem = searchItem})
end

function Library:CreateToggle(parentPage, textKey, default, callback)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local TglFrame = Instance.new("Frame", parentPage)
    TglFrame.Size = UDim2.new(1, -20, 0, 36)
    TglFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg
    TglFrame.ZIndex = 6
    TglFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
    local TglStroke = Instance.new("UIStroke", TglFrame)
    TglStroke.Color = Color3.fromRGB(40, 40, 40)
    
    table.insert(Library.TrackedElementBg, TglFrame)
    table.insert(Library.TrackedStrokes, TglStroke)
    
    local TglLabel = Instance.new("TextLabel", TglFrame)
    TglLabel.Size = UDim2.new(1, -60, 1, 0)
    TglLabel.Position = UDim2.new(0, 12, 0, 0)
    TglLabel.Text = initialText
    TglLabel.Font = Library.CurrentFont
    TglLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TglLabel.TextSize = 13
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left
    TglLabel.BackgroundTransparency = 1
    TglLabel.ZIndex = 7
    
    table.insert(Library.TrackedMainText, TglLabel)
    
    local Checkbox = Instance.new("TextButton", TglFrame)
    Checkbox.Size = UDim2.new(0, 34, 0, 18)
    Checkbox.Position = UDim2.new(1, -44, 0.5, -9)
    Checkbox.BackgroundColor3 = default and Library.CurrentThemeData.Accent or Color3.fromRGB(40, 40, 40) 
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
    Checkbox.Activated:Connect(function()
        enabled = not enabled
        
        local brightness = (Library.CurrentThemeData.Accent.R + Library.CurrentThemeData.Accent.G + Library.CurrentThemeData.Accent.B)
        local activeIndicatorColor = brightness > 2.5 and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 255, 255)

        if enabled then
            tween(Checkbox, {BackgroundColor3 = Library.CurrentThemeData.Accent}, 0.2)
            tween(Indicator, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = activeIndicatorColor}, 0.2)
        else
            local bgL = (Library.CurrentThemeData.MainBg.R * 0.299 + Library.CurrentThemeData.MainBg.G * 0.587 + Library.CurrentThemeData.MainBg.B * 0.114)
            local offColor = (bgL > 0.5) and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(40, 40, 40)
            tween(Checkbox, {BackgroundColor3 = offColor}, 0.2)
            tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end
        callback(enabled)
    end)
    
    table.insert(Library.TrackedAccents, {
        Type = "Toggle",
        Checkbox = Checkbox,
        Indicator = Indicator,
        IsEnabled = function() return enabled end
    })
    
    local searchItem = {Instance = TglFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = TglLabel, Key = textKey, SearchItem = searchItem})
end

function Library:CreateSlider(parentPage, textKey, min, max, default, callback)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local SliderFrame = Instance.new("Frame", parentPage)
    SliderFrame.Size = UDim2.new(1, -20, 0, 52)
    SliderFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg
    SliderFrame.ZIndex = 6
    SliderFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
    local SliderStroke = Instance.new("UIStroke", SliderFrame)
    SliderStroke.Color = Color3.fromRGB(40, 40, 40)
    
    table.insert(Library.TrackedElementBg, SliderFrame)
    table.insert(Library.TrackedStrokes, SliderStroke)
    
    local SliderLabel = Instance.new("TextLabel", SliderFrame)
    SliderLabel.Size = UDim2.new(0.5, -12, 0, 22)
    SliderLabel.Position = UDim2.new(0, 12, 0, 6)
    SliderLabel.Text = initialText
    SliderLabel.Font = Library.CurrentFont
    SliderLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    SliderLabel.TextSize = 13
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.ZIndex = 7
    
    table.insert(Library.TrackedMainText, SliderLabel)
    
    local ValueLabel = Instance.new("TextLabel", SliderFrame)
    ValueLabel.Size = UDim2.new(0.5, -12, 0, 22)
    ValueLabel.Position = UDim2.new(0.5, 0, 0, 6)
    ValueLabel.Font = Library.CurrentFont
    ValueLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.ZIndex = 7
    
    table.insert(Library.TrackedSubText, ValueLabel)
    
    local SliderTrack = Instance.new("Frame", SliderFrame)
    SliderTrack.Size = UDim2.new(1, -24, 0, 5)
    SliderTrack.Position = UDim2.new(0, 12, 0, 34)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    SliderTrack.ZIndex = 7
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(0, 3)
    
    local SliderBtn = Instance.new("TextButton", SliderTrack)
    SliderBtn.Size = UDim2.new(1, 0, 1, 16)
    SliderBtn.Position = UDim2.new(0, 0, 0, -8)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.ZIndex = 10
    
    local SliderFill = Instance.new("Frame", SliderTrack)
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    SliderFill.ZIndex = 8
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 3)
    
    local SliderHandle = Instance.new("Frame", SliderTrack)
    SliderHandle.Size = UDim2.new(0, 14, 0, 14)
    SliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
    SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderHandle.ZIndex = 9
    Instance.new("UICorner", SliderHandle).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", SliderHandle).Color = Color3.fromRGB(25, 25, 25)
    
    local dragging = false
    local currentPercent = (default - min) / (max - min)
    local startX = 0
    local startPercent = 0
    local cachedTrackWidth = 0
    local isIntegerSlider = (max - min) > 5
    
    local function getTrafficLightColor(pct)
        local red = Color3.fromRGB(255, 60, 60)
        local yellow = Color3.fromRGB(255, 210, 40)
        local green = Color3.fromRGB(60, 255, 90)

        if pct < 0.5 then
            return red:Lerp(yellow, pct * 2)
        else
            return yellow:Lerp(green, (pct - 0.5) * 2)
        end
    end
    
    local function updateVisuals(percentage)
        SliderFill.BackgroundColor3 = getTrafficLightColor(percentage)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderHandle.Position = UDim2.new(percentage, 0, 0.5, 0)
        local rawValue = min + (max - min) * percentage
        if isIntegerSlider then
            local roundedValue = math.floor(rawValue + 0.5)
            ValueLabel.Text = string.format("%d", roundedValue)
            callback(roundedValue)
        else
            ValueLabel.Text = string.format("%.2f", rawValue)
            callback(rawValue)
        end
    end
    
    SliderBtn.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            startX = input.Position.X
            cachedTrackWidth = SliderTrack.AbsoluteSize.X
            local clickOffset = input.Position.X - SliderTrack.AbsolutePosition.X
            currentPercent = math.clamp(clickOffset / cachedTrackWidth, 0, 1)
            startPercent = currentPercent
            updateVisuals(currentPercent)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local deltaX = input.Position.X - startX
            local deltaPercent = deltaX / cachedTrackWidth
            currentPercent = math.clamp(startPercent + deltaPercent, 0, 1)
            updateVisuals(currentPercent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    
    task.spawn(function()
        while SliderTrack.AbsoluteSize.X == 0 do task.wait() end
        updateVisuals(currentPercent)
    end)
    
    local searchItem = {Instance = SliderFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = SliderLabel, Key = textKey, SearchItem = searchItem})
end

function Library:CreateImage(parentPage, imageId)
    local Img = Instance.new("ImageLabel", parentPage)
    Img.Size = UDim2.new(1, -20, 0, 130)
    Img.BackgroundTransparency = 1
    Img.LayoutOrder = #parentPage:GetChildren()
    if tonumber(imageId) then
        Img.Image = "rbxassetid://" .. tostring(imageId) .. "&w=420&h=420"
    else
        Img.Image = imageId
    end
    Img.ScaleType = Enum.ScaleType.Fit
    Img.ZIndex = 6
    return Img
end

function Library:CreateSubTabs(parentPage, tabsList)
    local SubTabContainer = Instance.new("Frame", parentPage)
    SubTabContainer.Size = UDim2.new(1, -20, 0, 32)
    SubTabContainer.BackgroundTransparency = 1
    local ListLayout = Instance.new("UIListLayout", SubTabContainer)
    ListLayout.FillDirection = Enum.FillDirection.Horizontal
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local ContentContainer = Instance.new("Frame", parentPage)
    ContentContainer.Size = UDim2.new(1, 0, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.AutomaticSize = Enum.AutomaticSize.Y
    local subPages = {}
    local registry = {}
    local colorGrayInactive = Color3.fromRGB(140, 140, 140)
    
    for i, tabData in ipairs(tabsList) do
        local textKey = tabData.Name
        local iconId = tabData.Icon
        local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
        local activeColor = Color3.fromRGB(108, 176, 214)
        local lowName = string.lower(string.gsub(textKey, "%s+", ""))
        if tabData.Color then
            activeColor = tabData.Color
        elseif string.find(lowName, "theme") or string.find(lowName, "тема") then
            activeColor = Color3.fromRGB(235, 94, 153)
        end
        
        local BtnContainer = Instance.new("Frame", SubTabContainer)
        BtnContainer.Size = UDim2.new(0, 0, 1, 0)
        BtnContainer.AutomaticSize = Enum.AutomaticSize.X
        BtnContainer.BackgroundTransparency = 1
        BtnContainer.LayoutOrder = i
        
        local VisualFrame = Instance.new("Frame", BtnContainer)
        VisualFrame.Size = UDim2.new(1, 0, 1, 0)
        VisualFrame.BackgroundColor3 = activeColor
        VisualFrame.BackgroundTransparency = 1
        Instance.new("UICorner", VisualFrame).CornerRadius = UDim.new(0, 7)
        local Stroke = Instance.new("UIStroke", VisualFrame)
        Stroke.Color = activeColor
        Stroke.Thickness = 1.6
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Enabled = false
        
        local ContentFrame = Instance.new("Frame", BtnContainer)
        ContentFrame.Size = UDim2.new(0, 0, 1, 0)
        ContentFrame.AutomaticSize = Enum.AutomaticSize.X
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.ZIndex = 2
        
        local ContentPadding = Instance.new("UIPadding", ContentFrame)
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        
        local BtnLayout = Instance.new("UIListLayout", ContentFrame)
        BtnLayout.FillDirection = Enum.FillDirection.Horizontal
        BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        BtnLayout.Padding = UDim.new(0, 6)
        
        local Icon
        if iconId and iconId ~= "" then
            Icon = Instance.new("ImageLabel", ContentFrame)
            Icon.Size = tabData.IconSize or UDim2.new(0, 18, 0, 18)
            Icon.BackgroundTransparency = 1
            if tonumber(iconId) then
                Icon.Image = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150"
            else
                Icon.Image = iconId
            end
            Icon.ScaleType = Enum.ScaleType.Fit
            Icon.ImageColor3 = colorGrayInactive
            Icon.ZIndex = 3
        end
        
        local Label = Instance.new("TextLabel", ContentFrame)
        Label.BackgroundTransparency = 1
        Label.Text = initialText
        Label.Font = Library.CurrentFont
        Label.TextColor3 = colorGrayInactive
        Label.Size = UDim2.new(0, 0, 1, 0)
        Label.TextSize = 13
        Label.AutomaticSize = Enum.AutomaticSize.X
        Label.ZIndex = 3
        
        local Page = Instance.new("Frame", ContentContainer)
        Page.Size = UDim2.new(1, 0, 0, 0)
        Page.BackgroundTransparency = 1
        Page.AutomaticSize = Enum.AutomaticSize.Y
        Page.Visible = false
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        subPages[textKey] = Page
        registry[textKey] = { Page = Page, Visual = VisualFrame, Stroke = Stroke, Label = Label, Icon = Icon, TargetColor = activeColor }
        
        local ClickBtn = Instance.new("TextButton", BtnContainer)
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 10
        
        local function activateTab()
            for _, data in pairs(registry) do
                data.Page.Visible = false
                data.Visual.BackgroundTransparency = 1
                data.Stroke.Enabled = false
                
                local bgL = (Library.CurrentThemeData.MainBg.R * 0.299 + Library.CurrentThemeData.MainBg.G * 0.587 + Library.CurrentThemeData.MainBg.B * 0.114)
                local currentInactive = (bgL > 0.5) and Color3.fromRGB(110, 110, 110) or colorGrayInactive
                data.Label.TextColor3 = currentInactive
                if data.Icon then data.Icon.ImageColor3 = currentInactive end
            end
            Page.Visible = true
            VisualFrame.BackgroundColor3 = activeColor
            VisualFrame.BackgroundTransparency = 0.88
            Stroke.Color = activeColor
            Stroke.Enabled = true
            Label.TextColor3 = activeColor
            if Icon then Icon.ImageColor3 = activeColor end
        end
        ClickBtn.Activated:Connect(activateTab)
        table.insert(LocaleObjects, {Object = Label, Key = textKey})
    end
    
    local firstTab = tabsList[1] and tabsList[1].Name
    if firstTab and registry[firstTab] then
        local data = registry[firstTab]
        data.Page.Visible = true
        data.Visual.BackgroundColor3 = data.TargetColor
        data.Visual.BackgroundTransparency = 0.88
        data.Stroke.Color = data.TargetColor
        data.Stroke.Enabled = true
        data.Label.TextColor3 = data.TargetColor
        if data.Icon then data.Icon.ImageColor3 = data.TargetColor end
    end
    return subPages
end

function CreatePage(textKey, iconId, layoutOrder)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local PageFrame = Instance.new("ScrollingFrame", PagesContainer)
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    PageFrame.ZIndex = 5
    
    local layout = Instance.new("UIListLayout", PageFrame)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", PageFrame).PaddingTop = UDim.new(0, 2)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PageFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
    
    local TabContainer = Instance.new("Frame", Navigation)
    TabContainer.Size = UDim2.new(1, 0, 0, 34)
    TabContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ClipsDescendants = true
    TabContainer.ZIndex = 6
    TabContainer.LayoutOrder = layoutOrder or 0
    TabContainer.Name = "TabContainer"
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)
    
    table.insert(Library.TrackedElementBg, TabContainer)
    
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 1, 0)
    TabBtn.Text = initialText
    TabBtn.Font = Library.CurrentFont
    TabBtn.TextSize = 13
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.BackgroundTransparency = 1
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.ZIndex = 7
    
    local Padding = Instance.new("UIPadding", TabBtn)
    Padding.PaddingLeft = UDim.new(0, iconId and 42 or 12)
    
    if iconId then
        local TabIcon = Instance.new("ImageLabel", TabContainer)
        TabIcon.Size = UDim2.new(0, 24, 0, 24)
        TabIcon.Position = UDim2.new(0, 10, 0.5, -12)
        TabIcon.BackgroundTransparency = 1
        if tonumber(iconId) then
            TabIcon.Image = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150"
        else
            TabIcon.Image = iconId
        end
        TabIcon.ImageTransparency = 0.25
        TabIcon.ZIndex = 7
        allTabIcons[textKey] = TabIcon
    end
    
    allTabs[textKey] = TabContainer
    allTabButtons[textKey] = TabBtn
    allPages[textKey] = PageFrame
    
    TabBtn.MouseButton1Down:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        CreateRipple(TabContainer, mousePos.X - TabContainer.AbsolutePosition.X, (mousePos.Y - inset.Y) - TabContainer.AbsolutePosition.Y)
    end)
    
    TabBtn.Activated:Connect(function()
        if SearchBox.Text ~= "" then SearchBox.Text = "" end
        
        local bgL = (Library.CurrentThemeData.MainBg.R * 0.299 + Library.CurrentThemeData.MainBg.G * 0.587 + Library.CurrentThemeData.MainBg.B * 0.114)
        local isL = bgL > 0.5
        
        for tName, tContainer in pairs(allTabs) do
            tween(tContainer, {BackgroundTransparency = 1}, 0.2)
            tween(allTabButtons[tName], {TextColor3 = isL and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)}, 0.2)
            if allTabIcons[tName] then tween(allTabIcons[tName], {ImageTransparency = 0.25}, 0.2) end
            allPages[tName].Visible = false
        end
        Library.CurrentTabKey = textKey
        TabTitle.Text = Localization[Library.CurrentLanguage][textKey] or textKey
        PageFrame.Visible = true
        
        local activeTabBg = isL and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(35, 35, 35)
        tween(TabContainer, {BackgroundColor3 = activeTabBg, BackgroundTransparency = 0}, 0.2)
        tween(TabBtn, {TextColor3 = isL and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(255, 255, 255)}, 0.2)
        if allTabIcons[textKey] then tween(allTabIcons[textKey], {ImageTransparency = 0}, 0.2) end
    end)
    table.insert(LocaleObjects, {Object = TabBtn, Key = textKey})
    UpdateNavCanvas()
    return PageFrame
end

local MainPage = CreatePage("Main", "103980564128710", 1)
local TeleportPage = CreatePage("Teleport", "94373592263020", 2)
local MurderPage = CreatePage("Murder", "85278865249050", 3)
local SheriffPage = CreatePage("Sheriff", "77487634679354", 4)
local PlayersPage = CreatePage("Players", "99904215381150", 5)
local VisualPage = CreatePage("Visual", "78910169210318", 6)
local SettingsPage = CreatePage("Settings", "117996761927034", 99)

Library:CreateToggle(MainPage, "AutoFarmCoins", false, function(state) end)

-- Создаем суб-вкладки для вкладки Visual
local VisualSections = Library:CreateSubTabs(VisualPage, {
    {Name = "shader pack", Icon = "80768064990053", Color = Color3.fromRGB(46, 204, 113)}
})

local SettingSections = Library:CreateSubTabs(SettingsPage, {
    {Name = "UI", Icon = "85203682050945", Color = Color3.fromRGB(108, 176, 214)},
    {Name = "Theme", Icon = "78640980615320", Color = Color3.fromRGB(235, 94, 153)}
})

----------------------------------------------------
-- КОНФИГУРАЦИЯ И СБОРКА ФУНКЦИЙ ШЕЙДЕРОВ (ИЗ ФОТО)
----------------------------------------------------
local shaderStates = {
    Master = false,
    Bloom = false,
    BloomIntensity = 4,
    BloomSize = 24,
    Atmosphere = false,
    AtmosphereDensity = 40,
    SunRays = false,
    SunRaysIntensity = 25,
    Blur = false,
    BlurStrength = 75
}

-- 1. Главный переключатель (Enable)
local masterCC = nil
Library:CreateToggle(VisualSections["shader pack"], "Enable", false, function(state)
    shaderStates.Master = state
    if state then
        masterCC = Lighting:FindFirstChild("PulseHub_MasterCC") or Instance.new("ColorCorrectionEffect")
        masterCC.Name = "PulseHub_MasterCC"
        masterCC.Saturation = 0.15
        masterCC.Contrast = 0.1
        masterCC.Parent = Lighting
    else
        if masterCC then masterCC:Destroy() masterCC = nil end
        local existing = Lighting:FindFirstChild("PulseHub_MasterCC")
        if existing then existing:Destroy() end
    end
end)

-- 2. Выбор времени суток (Mode Dropdown)
Library:CreateDropdown(VisualSections["shader pack"], "Mode", {"None", "Day", "Sunset", "Midnight"}, "None", function(selected)
    if selected == "Day" then
        Lighting.TimeOfDay = "14:00:00"
    elseif selected == "Sunset" then
        Lighting.TimeOfDay = "18:30:00"
    elseif selected == "Midnight" then
        Lighting.TimeOfDay = "00:00:00"
    end
end)

-- 3. Настройка Блума (Bloom Effect)
local function updateBloom()
    if shaderStates.Bloom then
        local bloom = Lighting:FindFirstChild("PulseHub_Bloom") or Instance.new("BloomEffect")
        bloom.Name = "PulseHub_Bloom"
        bloom.Intensity = shaderStates.BloomIntensity
        bloom.Size = shaderStates.BloomSize
        bloom.Threshold = 0.8
        bloom.Parent = Lighting
    else
        local bloom = Lighting:FindFirstChild("PulseHub_Bloom")
        if bloom then bloom:Destroy() end
    end
end

Library:CreateToggle(VisualSections["shader pack"], "Bloom", false, function(state)
    shaderStates.Bloom = state
    updateBloom()
end)

Library:CreateSlider(VisualSections["shader pack"], "Intensity", 0, 10, 4, function(value)
    shaderStates.BloomIntensity = value
    local bloom = Lighting:FindFirstChild("PulseHub_Bloom")
    if bloom then bloom.Intensity = value end
end)

Library:CreateSlider(VisualSections["shader pack"], "Size", 0, 56, 24, function(value)
    shaderStates.BloomSize = value
    local bloom = Lighting:FindFirstChild("PulseHub_Bloom")
    if bloom then bloom.Size = value end
end)

-- 4. Настройка Атмосферы (Atmosphere Effect)
local function updateAtmosphere()
    if shaderStates.Atmosphere then
        local atm = Lighting:FindFirstChild("PulseHub_Atmosphere") or Instance.new("Atmosphere")
        atm.Name = "PulseHub_Atmosphere"
        atm.Density = shaderStates.AtmosphereDensity / 100
        atm.Parent = Lighting
    else
        local atm = Lighting:FindFirstChild("PulseHub_Atmosphere")
        if atm then atm:Destroy() end
    end
end

Library:CreateToggle(VisualSections["shader pack"], "Atmosphere", false, function(state)
    shaderStates.Atmosphere = state
    updateAtmosphere()
end)

Library:CreateSlider(VisualSections["shader pack"], "Density", 0, 100, 40, function(value)
    shaderStates.AtmosphereDensity = value
    local atm = Lighting:FindFirstChild("PulseHub_Atmosphere")
    if atm then atm.Density = value / 100 end
end)

-- 5. Настройка Лучей Солнца (Sun Rays Effect)
local function updateSunRays()
    if shaderStates.SunRays then
        local sr = Lighting:FindFirstChild("PulseHub_SunRays") or Instance.new("SunRaysEffect")
        sr.Name = "PulseHub_SunRays"
        sr.Intensity = shaderStates.SunRaysIntensity / 100
        sr.Parent = Lighting
    else
        local sr = Lighting:FindFirstChild("PulseHub_SunRays")
        if sr then sr:Destroy() end
    end
end

Library:CreateToggle(VisualSections["shader pack"], "Sun Rays", false, function(state)
    shaderStates.SunRays = state
    updateSunRays()
end)

Library:CreateSlider(VisualSections["shader pack"], "Intensity", 0, 100, 25, function(value)
    shaderStates.SunRaysIntensity = value
    local sr = Lighting:FindFirstChild("PulseHub_SunRays")
    if sr then sr.Intensity = value / 100 end
end)

-- 6. Настройка Размытия Экрана (Blur Effect)
local function updateBlur()
    if shaderStates.Blur then
        local blur = Lighting:FindFirstChild("PulseHub_Blur") or Instance.new("BlurEffect")
        blur.Name = "PulseHub_Blur"
        blur.Size = (shaderStates.BlurStrength / 100) * 56
        blur.Parent = Lighting
    else
        local blur = Lighting:FindFirstChild("PulseHub_Blur")
        if blur then blur:Destroy() end
    end
end

Library:CreateToggle(VisualSections["shader pack"], "Blur", false, function(state)
    shaderStates.Blur = state
    updateBlur()
end)

Library:CreateSlider(VisualSections["shader pack"], "Strength", 0, 100, 75, function(value)
    shaderStates.BlurStrength = value
    local blur = Lighting:FindFirstChild("PulseHub_Blur")
    if blur then blur.Size = (value / 100) * 56 end
end)
----------------------------------------------------

Library:CreateSlider(SettingSections["UI"], "UISize", 0.5, 1.5, 1.00, function(value) MainScale.Scale = value end)
Library:CreateSlider(SettingSections["UI"], "UITransparency", 0, 100, 15, function(value) MainFrame.BackgroundTransparency = value / 100 end)

Library:CreateDropdown(SettingSections["UI"], "MenuFont", {"Gotham", "Gotham Bold", "Source Sans", "Roboto", "Roboto Mono", "Ubuntu", "Michroma", "Code", "Fantasy", "Fredoka One"}, "Gotham", function(selectedFont)
    local targetFont = FontMapping[selectedFont] or Enum.Font.Gotham
    Library.CurrentFont = targetFont
    for _, obj in ipairs(PulseHub:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if obj.Text ~= "—" and obj.Text ~= "×" and obj.Text ~= "▼" and obj.Text ~= "▲" and obj.Text ~= "✓" and obj.Name ~= "FontPreviewLabel" then 
                obj.Font = targetFont 
            end
        end
    end
end)

Library:CreateDropdown(SettingSections["UI"], "Language", {"English", "Русский"}, "English", function(selectedLang)
    Library.CurrentLanguage = selectedLang
    for _, item in ipairs(LocaleObjects) do
        local translatedText = Localization[selectedLang][item.Key]
        if translatedText then
            item.Object.Text = translatedText
            if item.SearchItem then item.SearchItem.SearchText = NormalizeText(translatedText) end
        end
    end
    TabTitle.Text = Localization[selectedLang][Library.CurrentTabKey] or Library.CurrentTabKey
end)

Library:CreateToggle(SettingSections["UI"], "AntiAFK", false, function(state)
    toggleAntiAFK(state)
end)

Library:CreateDropdown(SettingSections["Theme"], "UITheme", ThemeNamesList, "Deep Ocean", function(selectedTheme)
    Library:UpdateTheme(selectedTheme)
end)

Library:CreateToggle(SettingSections["Theme"], "AnimatedWindow", false, function(state)
    toggleAnimatedWindow(state)
end)

Library:CreateToggle(SettingSections["Theme"], "Gradient", false, function(state)
    toggleGradientEffect(state)
end)

if allTabs["Main"] and allTabButtons["Main"] then
    allTabs["Main"].BackgroundTransparency = 0
    allTabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
    if allTabIcons["Main"] then allTabIcons["Main"].ImageTransparency = 0 end
    allPages["Main"].Visible = true
    Library.CurrentTabKey = "Main"
    TabTitle.Text = Localization[Library.CurrentLanguage]["Main"] or "Main"
end

Library:UpdateTheme("Deep Ocean")
