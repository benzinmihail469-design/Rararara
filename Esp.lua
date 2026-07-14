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
        ["А"]="а", ["Б"]="б", ["В"]="в", ["Г"]="г", ["Д"]="д", ["Е"]="е", ["Ё"]="ё", ["Ж"]="ж", ["З"]="з",
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
SubTitle.Text = "Grow a Garden 2"
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

local Library = {}
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
        elseif data.Type == "Slider" then
            if data.Fill and data.Fill.Parent then
                tween(data.Fill, {BackgroundColor3 = theme.Accent})
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

local Localization = {
    ["English"] = {
        ["Main"] = "Main", ["Players"] = "Players", ["Visual"] = "Visual", ["Settings"] = "Settings",
        ["AntiAFK"] = "Anti-AFK", ["UITheme"] = "UI Theme", ["Language"] = "Language",
        ["AnimatedWindow"] = "Animated Window", ["Gradient"] = "Gradient Background",
        ["PlayerEsp"] = "Player ESP", ["EspColor"] = "ESP Color", ["EspToggle"] = "Enable Modifiers",
        ["WalkSpeed"] = "WalkSpeed", ["JumpPower"] = "JumpPower", ["AutoHarvest"] = "Auto Harvest",
        ["SafeTeleport"] = "Teleport to Plant", ["HarvestSpeed"] = "Harvest Speed (sec)"
    },
    ["Русский"] = {
        ["Main"] = "Главная", ["Players"] = "Игроки", ["Visual"] = "Визуалы", ["Settings"] = "Настройки",
        ["AntiAFK"] = "Анти-АФК", ["UITheme"] = "Тема UI", ["Language"] = "Язык",
        ["AnimatedWindow"] = "Анимированное окно", ["Gradient"] = "Градиентный фон",
        ["PlayerEsp"] = "ESP Игроков", ["EspColor"] = "Цвет ЕСП", ["EspToggle"] = "Включить Модификаторы",
        ["WalkSpeed"] = "Скорость ходьбы", ["JumpPower"] = "Сила прыжка", ["AutoHarvest"] = "Авто-Сбор Урожая",
        ["SafeTeleport"] = "Телепорт к растению", ["HarvestSpeed"] = "Задержка сбора (сек)"
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
                    if stroke and stroke.Parent then stroke.Color = rainbowColor end
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
                if stroke and stroke.Parent then stroke.Color = defaultStrokeColor end
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

-- ============================================================================
-- [НОВЫЕ ФУНКЦИИ И СТРУКТУРЫ РАСШИРЕНИЯ БИБЛИОТЕКИ]
-- ============================================================================

function Library:CreateTab(tabName, iconId)
    local localizedTabName = Localization[Library.CurrentLanguage][tabName] or tabName
    
    local TabContainer = Instance.new("Frame", Navigation)
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 32)
    TabContainer.BackgroundTransparency = 1
    TabContainer.LayoutOrder = #Navigation:GetChildren()
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 6)
    
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 1, 0)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.ZIndex = 5
    
    local TabLabel = Instance.new("TextLabel", TabBtn)
    TabLabel.Size = UDim2.new(1, -35, 1, 0)
    TabLabel.Position = UDim2.new(0, 30, 0, 0)
    TabLabel.Text = localizedTabName
    TabLabel.Font = Library.CurrentFont
    TabLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabLabel.TextSize = 12
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.BackgroundTransparency = 1
    TabLabel.ZIndex = 6
    
    local TabIcon = Instance.new("ImageLabel", TabBtn)
    TabIcon.Size = UDim2.new(0, 16, 0, 16)
    TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = iconId or "rbxassetid://6023426915"
    TabIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
    TabIcon.ZIndex = 6
    
    local Page = Instance.new("ScrollingFrame", PagesContainer)
    Page.Name = tabName .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    Page.ZIndex = 4
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 2)
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
    end)
    
    allTabs[tabName] = TabContainer
    allTabButtons[tabName] = TabLabel
    allTabIcons[tabName] = TabIcon
    allPages[tabName] = Page
    
    table.insert(Library.TrackedElementBg, TabContainer)
    
    local function selectTab()
        Library.CurrentTabKey = tabName
        TabTitle.Text = Localization[Library.CurrentLanguage][tabName] or tabName
        
        for name, page in pairs(allPages) do
            page.Visible = (name == tabName)
        end
        
        Library:UpdateTheme(Library.CurrentThemeName or "Deep Ocean")
    end
    
    TabBtn.Activated:Connect(selectTab)
    
    if Library.CurrentTabKey == tabName then
        task.spawn(selectTab)
    end
    
    return Page
end

function Library:CreateToggle(parentPage, textKey, default, callback)
    local localizedText = Localization[Library.CurrentLanguage][textKey] or textKey
    
    local ToggleFrame = Instance.new("Frame", parentPage)
    ToggleFrame.Size = UDim2.new(1, -20, 0, 36)
    ToggleFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg
    ToggleFrame.ZIndex = 6
    ToggleFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    local ToggleStroke = Instance.new("UIStroke", ToggleFrame)
    ToggleStroke.Color = Color3.fromRGB(40, 40, 40)
    ToggleStroke.Thickness = 1
    
    table.insert(Library.TrackedElementBg, ToggleFrame)
    table.insert(Library.TrackedStrokes, ToggleStroke)
    
    local TitleLabel = Instance.new("TextLabel", ToggleFrame)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Text = localizedText
    TitleLabel.Font = Library.CurrentFont
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 7
    
    table.insert(Library.TrackedMainText, TitleLabel)
    
    local Checkbox = Instance.new("Frame", ToggleFrame)
    Checkbox.Size = UDim2.new(0, 34, 0, 18)
    Checkbox.Position = UDim2.new(1, -46, 0.5, -9)
    Checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Checkbox.ZIndex = 7
    Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(1, 0)
    
    local Indicator = Instance.new("Frame", Checkbox)
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = UDim2.new(0, 2, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.ZIndex = 8
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local ToggleBtn = Instance.new("TextButton", ToggleFrame)
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 9
    
    local isEnabled = default or false
    
    local function updateToggle(state)
        isEnabled = state
        local targetPos = isEnabled and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = isEnabled and Library.CurrentThemeData.Accent or Color3.fromRGB(40, 40, 40)
        
        tween(Indicator, {Position = targetPos}, 0.15)
        tween(Checkbox, {BackgroundColor3 = targetColor}, 0.15)
        
        task.spawn(function()
            pcall(callback, isEnabled)
        end)
    end
    
    ToggleBtn.Activated:Connect(function()
        updateToggle(not isEnabled)
    end)
    
    table.insert(Library.TrackedAccents, {
        Type = "Toggle",
        Checkbox = Checkbox,
        Indicator = Indicator,
        IsEnabled = function() return isEnabled end
    })
    
    local normText = NormalizeText(localizedText)
    table.insert(SearchableElements, {
        SearchText = normText,
        Instance = ToggleFrame,
        OriginalParent = parentPage
    })
    
    updateToggle(isEnabled)
end

function Library:CreateButton(parentPage, textKey, callback)
    local localizedText = Localization[Library.CurrentLanguage][textKey] or textKey
    
    local ButtonFrame = Instance.new("Frame", parentPage)
    ButtonFrame.Size = UDim2.new(1, -20, 0, 36)
    ButtonFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg
    ButtonFrame.ZIndex = 6
    ButtonFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 6)
    
    local ButtonStroke = Instance.new("UIStroke", ButtonFrame)
    ButtonStroke.Color = Color3.fromRGB(40, 40, 40)
    ButtonStroke.Thickness = 1
    
    table.insert(Library.TrackedElementBg, ButtonFrame)
    table.insert(Library.TrackedStrokes, ButtonStroke)
    
    local ClickBtn = Instance.new("TextButton", ButtonFrame)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.ZIndex = 7
    
    local TitleLabel = Instance.new("TextLabel", ClickBtn)
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Text = localizedText
    TitleLabel.Font = Library.CurrentFont
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.TextSize = 13
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 8
    
    table.insert(Library.TrackedMainText, TitleLabel)
    
    ClickBtn.Activated:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = mousePos.X - ButtonFrame.AbsolutePosition.X
        local relativeY = mousePos.Y - ButtonFrame.AbsolutePosition.Y
        CreateRipple(ButtonFrame, relativeX, relativeY)
        
        task.spawn(function()
            pcall(callback)
        end)
    end)
    
    local normText = NormalizeText(localizedText)
    table.insert(SearchableElements, {
        SearchText = normText,
        Instance = ButtonFrame,
        OriginalParent = parentPage
    })
end

function Library:CreateSlider(parentPage, textKey, min, max, default, callback)
    local localizedText = Localization[Library.CurrentLanguage][textKey] or textKey
    
    local SliderFrame = Instance.new("Frame", parentPage)
    SliderFrame.Size = UDim2.new(1, -20, 0, 46)
    SliderFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg
    SliderFrame.ZIndex = 6
    SliderFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
    
    local SliderStroke = Instance.new("UIStroke", SliderFrame)
    SliderStroke.Color = Color3.fromRGB(40, 40, 40)
    SliderStroke.Thickness = 1
    
    table.insert(Library.TrackedElementBg, SliderFrame)
    table.insert(Library.TrackedStrokes, SliderStroke)
    
    local TitleLabel = Instance.new("TextLabel", SliderFrame)
    TitleLabel.Size = UDim2.new(0.7, 0, 0, 24)
    TitleLabel.Position = UDim2.new(0, 12, 0, 2)
    TitleLabel.Text = localizedText
    TitleLabel.Font = Library.CurrentFont
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 7
    
    table.insert(Library.TrackedMainText, TitleLabel)
    
    local ValueLabel = Instance.new("TextLabel", SliderFrame)
    ValueLabel.Size = UDim2.new(0.3, -12, 0, 24)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 2)
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Library.CurrentFont
    ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.ZIndex = 7
    
    table.insert(Library.TrackedSubText, ValueLabel)
    
    local SliderBar = Instance.new("Frame", SliderFrame)
    SliderBar.Size = UDim2.new(1, -24, 0, 4)
    SliderBar.Position = UDim2.new(0, 12, 1, -12)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBar.ZIndex = 7
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame", SliderBar)
    SliderFill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    SliderFill.BackgroundColor3 = Library.CurrentThemeData.Accent
    SliderFill.ZIndex = 8
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    
    table.insert(Library.TrackedAccents, {
        Type = "Slider",
        Fill = SliderFill
    })
    
    local SliderTrigger = Instance.new("TextButton", SliderFrame)
    SliderTrigger.Size = UDim2.new(1, 0, 1, 0)
    SliderTrigger.BackgroundTransparency = 1
    SliderTrigger.Text = ""
    SliderTrigger.ZIndex = 9
    
    local isDragging = false
    
    local function updateSlider(input)
        local barAbsoluteSize = SliderBar.AbsoluteSize.X
        local barAbsolutePosition = SliderBar.AbsolutePosition.X
        local percentage = math.clamp((input.Position.X - barAbsolutePosition) / barAbsoluteSize, 0, 1)
        
        local newValue = math.floor(min + (max - min) * percentage)
        ValueLabel.Text = tostring(newValue)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        task.spawn(function()
            pcall(callback, newValue)
        end)
    end
    
    SliderTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    local normText = NormalizeText(localizedText)
    table.insert(SearchableElements, {
        SearchText = normText,
        Instance = SliderFrame,
        OriginalParent = parentPage
    })
end

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
        if previews then contentHeight = contentHeight + 122 end
        local targetFrameHeight = isExpanded and (36 + contentHeight + 4) or 36
        
        tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, targetFrameHeight)}, 0.2)
        tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, isExpanded and contentHeight or 0)}, 0.2)
        tween(Arrow, {Rotation = isExpanded and 180 or 0}, 0.2)
    end
    HeaderBtn.Activated:Connect(toggleDropdown)
    
    for i, option in ipairs(options) do
        local OptBtn = Instance.new("TextButton", OptionsContainer)
        OptBtn.Size = UDim2.new(1, -24, 0, 30)
        OptBtn.Position = UDim2.new(0, 12, 0, 0)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = ""
        OptBtn.ZIndex = 8
        OptBtn.LayoutOrder = i
        
        local OptLabel = Instance.new("TextLabel", OptBtn)
        OptLabel.Size = UDim2.new(1, -20, 1, 0)
        OptLabel.Text = option
        OptLabel.Font = Library.CurrentFont
        OptLabel.TextColor3 = (option == default) and Library.CurrentThemeData.Accent or Color3.fromRGB(150, 150, 150)
        OptLabel.TextSize = 12
        OptLabel.TextXAlignment = Enum.TextXAlignment.Left
        OptLabel.BackgroundTransparency = 1
        OptLabel.ZIndex = 9
        
        local CheckMark = Instance.new("TextLabel", OptBtn)
        CheckMark.Size = UDim2.new(0, 20, 1, 0)
        CheckMark.Position = UDim2.new(1, -20, 0, 0)
        CheckMark.Text = "✓"
        CheckMark.Font = Enum.Font.GothamBold
        CheckMark.TextColor3 = Library.CurrentThemeData.Accent
        CheckMark.TextSize = 12
        CheckMark.TextXAlignment = Enum.TextXAlignment.Right
        CheckMark.BackgroundTransparency = 1
        CheckMark.Visible = (option == default)
        CheckMark.ZIndex = 9
        
        OptBtn.Activated:Connect(function()
            SelectedLabel.Text = option
            toggleDropdown()
            
            for _, optObj in ipairs(OptionsContainer:GetChildren()) do
                if optObj:IsA("TextButton") then
                    local label = optObj:FindFirstChildOfClass("TextLabel")
                    local check = optObj:FindFirstChild("TextLabel") and optObj:FindFirstChild("TextLabel").Parent:FindFirstChild("CheckMark") -- simplify safety
                    if label then
                        label.TextColor3 = (label.Text == option) and Library.CurrentThemeData.Accent or Color3.fromRGB(150, 150, 150)
                    end
                end
            end
            
            if previews and PreviewImage then
                local currentImg = previews[option] or ""
                if tonumber(currentImg) then
                    PreviewImage.Image = "rbxassetid://" .. tostring(currentImg)
                else
                    PreviewImage.Image = currentImg
                end
            end
            
            task.spawn(function()
                pcall(callback, option)
            end)
        end)
    end
    
    local normText = NormalizeText(initialText)
    table.insert(SearchableElements, {
        SearchText = normText,
        Instance = DropdownFrame,
        OriginalParent = parentPage
    })
end

function Library:CreateImage(parentPage, imageId)
    local ImgFrame = Instance.new("Frame", parentPage)
    ImgFrame.Size = UDim2.new(1, -20, 0, 130)
    ImgFrame.BackgroundTransparency = 1
    ImgFrame.LayoutOrder = #parentPage:GetChildren()
    
    local Img = Instance.new("ImageLabel", ImgFrame)
    Img.Size = UDim2.new(1, 0, 1, 0)
    Img.BackgroundTransparency = 1
    if tonumber(imageId) then 
        Img.Image = "rbxassetid://" .. tostring(imageId)
    else 
        Img.Image = imageId 
    end
    Img.ScaleType = Enum.ScaleType.Fit
    Img.ZIndex = 7
end


-- ============================================================================
-- [ЛОГИКА РАБОТЫ АВТО-СБОРА (AUTO HARVEST) И МОДИФИКАТОРОВ]
-- ============================================================================

local autoHarvestActive = false
local safeTeleportToCrops = true
local harvestDelay = 0.5

local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    
    local origDistance = prompt.MaxActivationDistance
    local origRequires = prompt.RequiresLineOfSight
    
    prompt.MaxActivationDistance = 999999
    prompt.RequiresLineOfSight = false
    task.wait(0.05)
    
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputBegan(Enum.UserInputType.MouseButton1)
        task.wait(prompt.HoldDuration + 0.05)
        prompt:InputEnded(Enum.UserInputType.MouseButton1)
    end
    
    task.delay(1, function()
        pcall(function()
            prompt.MaxActivationDistance = origDistance
            prompt.RequiresLineOfSight = origRequires
        end)
    end)
end

local function getMyPlot()
    local localPlayer = Players.LocalPlayer
    local containers = {
        workspace:FindFirstChild("Farm"),
        workspace:FindFirstChild("Farms"),
        workspace:FindFirstChild("Plots"),
        workspace:FindFirstChild("Plots_Physical")
    }
    
    for _, container in ipairs(containers) do
        if container then
            for _, plot in ipairs(container:GetChildren()) do
                if plot.Name == localPlayer.Name then
                    return plot
                end
                local data = plot:FindFirstChild("Important") or plot:FindFirstChild("Data") or plot:FindFirstChild("Settings")
                if data then
                    local owner = data:FindFirstChild("Owner")
                    if owner and (owner.Value == localPlayer.Name or owner.Value == localPlayer) then
                        return plot
                    end
                end
            end
        end
    end
    
    local fallback = workspace:FindFirstChild(localPlayer.Name)
    if fallback then return fallback end
    return nil
end

local function runHarvestLoop()
    local myPlot = getMyPlot()
    local player = Players.LocalPlayer
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    if not root then return end
    local executedAny = false
    
    if myPlot then
        local plantsFolder = myPlot:FindFirstChild("Plants_Physical") or myPlot:FindFirstChild("Plants")
        if plantsFolder then
            for _, plant in ipairs(plantsFolder:GetChildren()) do
                if not autoHarvestActive then return end
                local prompt = plant:FindFirstChildOfClass("ProximityPrompt") or plant:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    local actText = string.lower(prompt.ActionText)
                    if actText:find("harvest") or actText:find("урожай") or actText:find("collect") or actText:find("собрать") or actText:find("pick") or actText == "" then
                        local promptParent = prompt.Parent
                        if promptParent and promptParent:IsA("BasePart") then
                            if safeTeleportToCrops then
                                root.CFrame = promptParent.CFrame * CFrame.new(0, 3, 0)
                                task.wait(0.15)
                            end
                            firePrompt(prompt)
                            task.wait(harvestDelay)
                            executedAny = true
                        end
                    end
                end
            end
        end
    end
    
    -- Резервный сбор по области (если уехали с базы или крадем урожай ночью)
    if not executedAny then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if not autoHarvestActive then return end
            if desc:IsA("ProximityPrompt") then
                local actText = string.lower(desc.ActionText)
                if actText:find("harvest") or actText:find("урожай") or actText:find("collect") or actText:find("собрать") or actText:find("pick") then
                    local parent = desc.Parent
                    if parent and parent:IsA("BasePart") then
                        local distance = (root.Position - parent.Position).Magnitude
                        if distance <= desc.MaxActivationDistance + 5 then
                            firePrompt(desc)
                            task.wait(harvestDelay)
                        end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if autoHarvestActive then
            pcall(runHarvestLoop)
        end
    end
end)


-- Игрок модификаторы
local modActive = false
local walkSpeedVal = 16
local jumpPowerVal = 50

task.spawn(function()
    while true do
        task.wait(0.2)
        local character = Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and modActive then
            humanoid.WalkSpeed = walkSpeedVal
            humanoid.JumpPower = jumpPowerVal
        end
    end
end)


-- ESP Игроков через нативные Highlights (без лагов на любых девайсах)
local espActive = false
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            local char = p.Character
            if char then
                if espActive then
                    local hl = char:FindFirstChild("ESPHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "ESPHighlight"
                        hl.Parent = char
                    end
                    hl.FillColor = Library.CurrentThemeData.Accent
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.OutlineTransparency = 0
                    
                    local bg = char:FindFirstChild("ESPTag")
                    if not bg then
                        bg = Instance.new("BillboardGui")
                        bg.Name = "ESPTag"
                        bg.AlwaysOnTop = true
                        bg.Size = UDim2.new(0, 100, 0, 30)
                        bg.StudsOffset = Vector3.new(0, 3, 0)
                        bg.Parent = char
                        
                        local text = Instance.new("TextLabel", bg)
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.Font = Enum.Font.GothamBold
                        text.TextSize = 12
                        text.TextColor3 = Library.CurrentThemeData.Accent
                        text.Text = p.Name
                    end
                else
                    local hl = char:FindFirstChild("ESPHighlight")
                    if hl then hl:Destroy() end
                    local bg = char:FindFirstChild("ESPTag")
                    if bg then bg:Destroy() end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if espActive then pcall(updateESP) end
    end
end)


-- ============================================================================
-- [РЕНДЕРИНГ СТРАНИЦ ХАБА И ЭЛЕМЕНТОВ УПРАВЛЕНИЯ]
-- ============================================================================

local MainPage = Library:CreateTab("Main", "rbxassetid://10747372703")
local PlayersPage = Library:CreateTab("Players", "rbxassetid://10747373865")
local VisualPage = Library:CreateTab("Visual", "rbxassetid://10747373151")
local SettingsPage = Library:CreateTab("Settings", "rbxassetid://10747373426")

-- СТРАНИЦА MAIN (Основная автоматизация)
Library:CreateToggle(MainPage, "AutoHarvest", false, function(state)
    autoHarvestActive = state
end)

Library:CreateToggle(MainPage, "SafeTeleport", true, function(state)
    safeTeleportToCrops = state
end)

Library:CreateSlider(MainPage, "HarvestSpeed", 0, 5, 0, function(val)
    harvestDelay = val
end)

Library:CreateToggle(MainPage, "AntiAFK", false, function(state)
    toggleAntiAFK(state)
end)

-- СТРАНИЦА PLAYERS (Модификаторы персонажа)
Library:CreateToggle(PlayersPage, "EspToggle", false, function(state)
    modActive = state
end)

Library:CreateSlider(PlayersPage, "WalkSpeed", 16, 150, 16, function(val)
    walkSpeedVal = val
end)

Library:CreateSlider(PlayersPage, "JumpPower", 50, 300, 50, function(val)
    jumpPowerVal = val
end)

-- СТРАНИЦА VISUAL (Графика/ESP)
Library:CreateToggle(VisualPage, "PlayerEsp", false, function(state)
    espActive = state
    pcall(updateESP)
end)

-- СТРАНИЦА SETTINGS (Кастомизация UI)
Library:CreateDropdown(SettingsPage, "Language", {"English", "Русский"}, "English", function(lang)
    Library.CurrentLanguage = lang
    TabTitle.Text = Localization[lang][Library.CurrentTabKey] or Library.CurrentTabKey
end)

Library:CreateDropdown(SettingsPage, "UITheme", ThemeNamesList, "Deep Ocean", function(theme)
    Library.CurrentThemeName = theme
    Library:UpdateTheme(theme)
end)

Library:CreateToggle(SettingsPage, "Gradient", false, function(state)
    toggleGradientEffect(state)
end)

Library:CreateToggle(SettingsPage, "AnimatedWindow", false, function(state)
    toggleAnimatedWindow(state)
end)

-- Первая загрузка темы
Library:UpdateTheme("Deep Ocean")
