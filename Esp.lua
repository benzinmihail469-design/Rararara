-- ============================================================================
-- Dark Hub - Settings Edition (Fixed & Optimized)
-- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- Ожидаем загрузки локального игрока
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

local CustomIconID = "76579925188009"
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
            antiAfkConnection = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end)
            end)
        end
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end

toggleAntiAFK(true)

-- Безопасный выбор родительского объекта GUI
local SafeParent = nil
if typeof(gethui) == "function" then
    pcall(function() SafeParent = gethui() end)
end

if not SafeParent then
    pcall(function()
        local cg = game:GetService("CoreGui")
        local testFolder = Instance.new("Folder")
        testFolder.Parent = cg
        testFolder:Destroy()
        SafeParent = cg
    end)
end

if not SafeParent then
    SafeParent = LocalPlayer:WaitForChild("PlayerGui", 10)
end

if not SafeParent then return end

if SafeParent:FindFirstChild("DarkHub") then
    SafeParent.DarkHub:Destroy()
end

local DarkHub = Instance.new("ScreenGui")
DarkHub.Name = "DarkHub"
DarkHub.Parent = SafeParent
DarkHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local activeTweens = {}

local function tween(obj, props, dur)
    if not obj then return end
    if activeTweens[obj] then
        activeTweens[obj]:Cancel()
        activeTweens[obj] = nil
    end
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    activeTweens[obj] = t
    t:Play()
    return t
end

local function NormalizeText(str)
    if type(str) ~= "string" then return "" end
    local lowerStr = str:lower()
    
    local cyrUpper = {"А","Б","В","Г","Д","Е","Ё","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я"}
    local cyrLower = {"а","б","в","г","д","е","ё","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я"}
    for i = 1, #cyrUpper do
        lowerStr = lowerStr:gsub(cyrUpper[i], cyrLower[i])
    end

    local synonyms = {
        ["настройки"] = "settings", ["язык"] = "language", ["тема"] = "theme", ["шрифт"] = "font"
    }
    for ru, en in pairs(synonyms) do
        lowerStr = string.gsub(lowerStr, ru, en)
    end
    return string.gsub(lowerStr, "[%p%s%c]", "")
end

local function spawnWave(container, clickX, clickY)
    if not container then return end
    container.ClipsDescendants = true

    local absSize = container.AbsoluteSize
    local startX = clickX or (absSize.X / 2)
    local startY = clickY or (absSize.Y / 2)
    local maxDimension = math.max(absSize.X, absSize.Y) * 2.8

    local Wave = Instance.new("Frame")
    Wave.Name = "TsunamiWave"
    Wave.Parent = container
    Wave.AnchorPoint = Vector2.new(0.5, 0.5)
    Wave.Position = UDim2.new(0, startX, 0, startY)
    Wave.Size = UDim2.new(0, 0, 0, 0)
    Wave.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    Wave.BackgroundTransparency = 0.4
    Wave.BorderSizePixel = 0
    Wave.ZIndex = 20

    local Corner = Instance.new("UICorner", Wave)
    Corner.CornerRadius = UDim.new(1, 0)

    local waveTween = TweenService:Create(Wave, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxDimension, 0, maxDimension),
        BackgroundTransparency = 1
    })

    waveTween:Play()
    waveTween.Completed:Connect(function()
        Wave:Destroy()
    end)
end

-- ============================================================================
-- ОСНОВНОЙ GUI
-- ============================================================================
local MainFrame = Instance.new("Frame", DarkHub)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Visible = false

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
TabTitle.Text = "Settings"
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
HubTitle.Text = "Dark Hub"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Position = UDim2.new(0, 44, 0, 7)
HubTitle.Size = UDim2.new(0, 95, 0, 15)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1
HubTitle.ZIndex = 5

local SubTitle = Instance.new("TextLabel", HeaderBg)
SubTitle.Text = "Settings Panel"
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
    local currentFps = 1 / math.max(dt, 0.001)
    table.insert(fpsBuffer, currentFps)
    if #fpsBuffer > maxSamples then
        table.remove(fpsBuffer, 1)
    end
    
    lastUpdateTime = lastUpdateTime + dt
    if lastUpdateTime >= updateInterval then
        lastUpdateTime = 0
        local sum = 0
        for _, fps in ipairs(fpsBuffer) do sum = sum + fps end
        local averageFps = sum / #fpsBuffer
        local passedTime = CurrentTime - startTime
        StatsLabel.Text = string.format("FPS: %d  |  Session: %s", math.floor(averageFps + 0.5), formatSessionTime(passedTime))
    end
end)

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
        local t = tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350), Position = UDim2.new(0.5, 0, 0.5, 0)})
        if t then
            t.Completed:Connect(function()
                if not isMinimized then
                    PagesContainer.Visible, TabTitle.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = true, true, true, true, true, true
                end
            end)
        end
    end
end

MinBtn.Activated:Connect(ToggleMinimize)
EmbMinBtn.Activated:Connect(ToggleMinimize)

local function CloseGui()
    DarkHub:Destroy()
end
CloseBtn.Activated:Connect(CloseGui)
EmbCloseBtn.Activated:Connect(CloseGui)

local function setupHeaderBtnHover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function() tween(btn, {TextColor3 = hoverColor}) end)
    btn.MouseLeave:Connect(function() tween(btn, {TextColor3 = normalColor}) end)
end
setupHeaderBtnHover(MinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255))
setupHeaderBtnHover(EmbMinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255))
setupHeaderBtnHover(CloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70))
setupHeaderBtnHover(EmbCloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70))
setupHeaderBtnHover(ClearSearchBtn, Color3.fromRGB(150,150,150), Color3.fromRGB(255,255,255))

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

-- ============================================================================
-- UI БИБЛИОТЕКА И ТЕМЫ
-- ============================================================================
local Library = {}
Library.CurrentFont = Enum.Font.Gotham
Library.CurrentLanguage = "English"
Library.CurrentTabKey = "Settings"
Library.ActiveDropdownClose = nil

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
    ["AMOLED"]        = { Accent = Color3.fromRGB(255, 255, 255), MainBg = Color3.fromRGB(0, 0, 0),      ElementBg = Color3.fromRGB(15, 15, 15) }
}

local DefaultTheme = { Accent = Color3.fromRGB(0, 206, 209), MainBg = Color3.fromRGB(10, 20, 30), ElementBg = Color3.fromRGB(15, 30, 45) }
Library.CurrentThemeData = ThemeConfig["Deep Ocean"] or DefaultTheme

-- Защищённые вспомогательные функции для предотвращения "attempt to index nil with 'R'"
local function getThemeAccent()
    if Library.CurrentThemeData and typeof(Library.CurrentThemeData.Accent) == "Color3" then
        return Library.CurrentThemeData.Accent
    end
    return DefaultTheme.Accent
end

local function getThemeMainBg()
    if Library.CurrentThemeData and typeof(Library.CurrentThemeData.MainBg) == "Color3" then
        return Library.CurrentThemeData.MainBg
    end
    return DefaultTheme.MainBg
end

local function getLuminance(color)
    if typeof(color) ~= "Color3" then
        color = DefaultTheme.MainBg
    end
    return (color.R * 0.299 + color.G * 0.587 + color.B * 0.114)
end

local function isLightColor(color)
    return getLuminance(color) > 0.5
end

local ThemeNamesList = {}
for name, _ in pairs(ThemeConfig) do table.insert(ThemeNamesList, name) end
table.sort(ThemeNamesList)

local allTabs = {}
local allTabButtons = {}
local allTabIcons = {}
local allPages = {}

local currentActiveTab = nil
local currentHoveredTab = nil

local function applyHover(button)
    if not button or not button.Parent then return end
    local parentContainer = button.Parent
    local accent = getThemeAccent()
    local mainBg = getThemeMainBg()
    
    local stroke = parentContainer:FindFirstChild("HoverStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "HoverStroke"
        stroke.Color = accent
        stroke.Thickness = 1
        stroke.Transparency = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = parentContainer
    else
        stroke.Color = accent
    end
    
    local isL = isLightColor(mainBg)
    local hoverBg = isL and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(50, 50, 50)
    local hoverText = isL and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)

    tween(parentContainer, {BackgroundColor3 = hoverBg, BackgroundTransparency = 0.5}, 0.18)
    tween(stroke, {Transparency = 0.5}, 0.18)
    tween(button, {TextColor3 = hoverText}, 0.18)
end

local function removeHover(button)
    if not button or not button.Parent then return end
    local parentContainer = button.Parent
    
    local stroke = parentContainer:FindFirstChild("HoverStroke")
    if stroke then
        local t = tween(stroke, {Transparency = 1}, 0.18)
        if t then
            t.Completed:Connect(function()
                if stroke and stroke.Parent and stroke.Transparency >= 0.99 then
                    stroke:Destroy()
                end
            end)
        end
    end
    
    local isL = isLightColor(getThemeMainBg())
    local normalTextColor = isL and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
    
    tween(parentContainer, {BackgroundTransparency = 1}, 0.18)
    tween(button, {TextColor3 = normalTextColor}, 0.18)
end

local function setActiveTab(tabButton)
    if not tabButton or not tabButton.Parent then return end
    local parentContainer = tabButton.Parent
    local accent = getThemeAccent()
    local mainBg = getThemeMainBg()
    
    local indicator = parentContainer:FindFirstChild("ActiveIndicator")
    if not indicator then
        indicator = Instance.new("Frame")
        indicator.Name = "ActiveIndicator"
        indicator.Size = UDim2.new(0, 4, 1, 0)
        indicator.Position = UDim2.new(0, 0, 0, 0)
        indicator.BackgroundColor3 = accent
        indicator.BorderSizePixel = 0
        indicator.ZIndex = tabButton.ZIndex + 2
        indicator.BackgroundTransparency = 1
        indicator.Parent = parentContainer
        
        local corner = Instance.new("UICorner", indicator)
        corner.CornerRadius = UDim.new(0, 2)
    end
    
    tabButton.Font = Enum.Font.GothamBold
    local isL = isLightColor(mainBg)
    local activeTextColor = isL and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
    local activeBgColor = isL and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(35, 35, 35)

    tween(indicator, {BackgroundColor3 = accent, BackgroundTransparency = 0}, 0.25)
    tween(tabButton, {TextColor3 = activeTextColor}, 0.25)
    tween(parentContainer, {BackgroundColor3 = activeBgColor, BackgroundTransparency = 0}, 0.25)
    
    local textKey = tabButton.Name
    if allTabIcons[textKey] then
        tween(allTabIcons[textKey], {ImageTransparency = 0}, 0.25)
    end
end

local function clearActiveTab(tabButton)
    if not tabButton or not tabButton.Parent then return end
    local parentContainer = tabButton.Parent
    
    local indicator = parentContainer:FindFirstChild("ActiveIndicator")
    if indicator then
        local t = tween(indicator, {BackgroundTransparency = 1}, 0.25)
        if t then
            t.Completed:Connect(function()
                if indicator and indicator.Parent and indicator.BackgroundTransparency >= 0.99 then
                    indicator:Destroy()
                end
            end)
        end
    end
    
    tabButton.Font = Library.CurrentFont or Enum.Font.Gotham
    
    local isL = isLightColor(getThemeMainBg())
    local normalTextColor = isL and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
    
    tween(tabButton, {TextColor3 = normalTextColor}, 0.25)
    tween(parentContainer, {BackgroundTransparency = 1}, 0.25)
    
    local textKey = tabButton.Name
    if allTabIcons[textKey] then
        tween(allTabIcons[textKey], {ImageTransparency = 0.25}, 0.25)
    end
end

local function applyThemeToTabs(theme)
    theme = theme or Library.CurrentThemeData or DefaultTheme
    local mainBg = (theme and typeof(theme.MainBg) == "Color3") and theme.MainBg or DefaultTheme.MainBg
    local accent = (theme and typeof(theme.Accent) == "Color3") and theme.Accent or DefaultTheme.Accent

    local isLightMode = isLightColor(mainBg)
    local activeTextColor = isLightMode and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
    local inactiveTextColor = isLightMode and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
    local activeBgColor = isLightMode and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(35, 35, 35)

    for textKey, tabBtn in pairs(allTabButtons) do
        if tabBtn and tabBtn.Parent then
            local parentContainer = tabBtn.Parent
            local indicator = parentContainer:FindFirstChild("ActiveIndicator")
            local hoverStroke = parentContainer:FindFirstChild("HoverStroke")

            if tabBtn == currentActiveTab then
                tween(tabBtn, {TextColor3 = activeTextColor}, 0.2)
                tween(parentContainer, {BackgroundColor3 = activeBgColor, BackgroundTransparency = 0}, 0.2)
                
                if not indicator then
                    indicator = Instance.new("Frame")
                    indicator.Name = "ActiveIndicator"
                    indicator.Size = UDim2.new(0, 4, 1, 0)
                    indicator.Position = UDim2.new(0, 0, 0, 0)
                    indicator.BorderSizePixel = 0
                    indicator.ZIndex = tabBtn.ZIndex + 2
                    indicator.Parent = parentContainer
                    local corner = Instance.new("UICorner", indicator)
                    corner.CornerRadius = UDim.new(0, 2)
                end
                
                tween(indicator, {BackgroundColor3 = accent, BackgroundTransparency = 0}, 0.2)

                if allTabIcons[textKey] then
                    tween(allTabIcons[textKey], {ImageTransparency = 0}, 0.2)
                end
            else
                tween(tabBtn, {TextColor3 = inactiveTextColor}, 0.2)
                if currentHoveredTab ~= tabBtn then
                    tween(parentContainer, {BackgroundTransparency = 1}, 0.2)
                end

                if indicator then
                    local t = tween(indicator, {BackgroundTransparency = 1}, 0.2)
                    if t then
                        t.Completed:Connect(function()
                            if indicator and indicator.Parent and indicator.BackgroundTransparency >= 0.99 then
                                indicator:Destroy()
                            end
                        end)
                    end
                end

                if allTabIcons[textKey] then
                    tween(allTabIcons[textKey], {ImageTransparency = 0.25}, 0.2)
                end
            end

            if hoverStroke then
                tween(hoverStroke, {Color = accent}, 0.2)
            end
        end
    end
end

function Library:UpdateTheme(themeName)
    local theme = ThemeConfig[themeName] or DefaultTheme
    Library.CurrentThemeData = theme
    
    local mainBg = getThemeMainBg()
    local accent = getThemeAccent()
    local isLightMode = isLightColor(mainBg)
    
    local mainTextColor = isLightMode and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(255, 255, 255)
    local subTextColor = isLightMode and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
    local strokeColor = isLightMode and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(45, 45, 45)
    
    for _, obj in ipairs(Library.TrackedMainBg) do
        if obj and obj.Parent then tween(obj, {BackgroundColor3 = mainBg}) end
    end
    
    for _, obj in ipairs(Library.TrackedElementBg) do
        if obj and obj.Parent then
            if obj.Name ~= "TabContainer" then
                tween(obj, {BackgroundColor3 = theme.ElementBg or DefaultTheme.ElementBg})
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
    
    applyThemeToTabs(theme)
    
    for _, data in ipairs(Library.TrackedAccents) do
        if data.Type == "Toggle" then
            if data.IsEnabled() then
                tween(data.Checkbox, {BackgroundColor3 = accent})
                local brightness = (accent.R + accent.G + accent.B)
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
                data.Container.ScrollBarImageColor3 = accent
            end
            if data.SelectedLabel and data.SelectedLabel.Parent then
                tween(data.SelectedLabel, {TextColor3 = accent})
            end
            for optName, optData in pairs(data.Options) do
                if optData.Check and optData.Check.Parent then 
                    optData.Check.TextColor3 = accent
                    optData.Check.Visible = (optName == currentSelection)
                end
                if optName == currentSelection then
                    if optData.Label and optData.Label.Parent then tween(optData.Label, {TextColor3 = accent}) end
                else
                    if optData.Label and optData.Label.Parent then tween(optData.Label, {TextColor3 = subTextColor}) end
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
        ["Settings"] = "Settings", ["UI"] = "UI", ["Theme"] = "Theme",
        ["UISize"] = "UI Size", ["UITransparency"] = "UI Transparency",
        ["MenuFont"] = "Menu Font", ["Language"] = "Language", ["AntiAFK"] = "Anti-AFK", ["UITheme"] = "UI Theme",
        ["AnimatedWindow"] = "Animated Window", ["Gradient"] = "Gradient Background"
    },
    ["Русский"] = {
        ["Settings"] = "Настройки", ["UI"] = "Интерфейс", ["Theme"] = "Тема",
        ["UISize"] = "Размер интерфейса", ["UITransparency"] = "Прозрачность меню",
        ["MenuFont"] = "Шрифт меню", ["Language"] = "Язык", ["AntiAFK"] = "Анти-АФК", ["UITheme"] = "Тема UI",
        ["AnimatedWindow"] = "Анимированное окно", ["Gradient"] = "Градиентный фон"
    }
}

function Library:UpdateLanguage(lang)
    if not Localization[lang] then return end
    Library.CurrentLanguage = lang
    for _, loc in ipairs(LocaleObjects) do
        if loc.Object and loc.Object.Parent then
            local newText = Localization[lang][loc.Key] or loc.Key
            loc.Object.Text = newText
            if loc.SearchItem then
                loc.SearchItem.SearchText = NormalizeText(newText)
            end
        end
    end
    if allPages[Library.CurrentTabKey] then
        TabTitle.Text = Localization[lang][Library.CurrentTabKey] or Library.CurrentTabKey
    end
end

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
            local defaultStrokeColor = isLightColor(getThemeMainBg()) and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(45, 45, 45)
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
            if item.Instance and item.OriginalParent then
                item.Instance.Parent = item.OriginalParent
                item.Instance.Visible = true
            end
        end
        if allPages[Library.CurrentTabKey] then allPages[Library.CurrentTabKey].Visible = true end
    else
        for _, page in pairs(allPages) do page.Visible = false end
        SearchResultsPage.Visible = true
        for _, item in ipairs(SearchableElements) do
            if item.Instance then
                if string.find(item.SearchText, query, 1, true) then
                    item.Instance.Parent = SearchResultsPage
                    item.Instance.Visible = true
                else
                    item.Instance.Visible = false
                end
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

-- ============================================================================
-- ЭЛЕМЕНТЫ УПРАВЛЕНИЯ (DROPDOWN, BUTTON, TOGGLE, SLIDER)
-- ============================================================================
function Library:CreateDropdown(parentPage, textKey, options, default, callback)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local DropdownFrame = Instance.new("Frame", parentPage)
    DropdownFrame.Size = UDim2.new(1, -20, 0, 36)
    DropdownFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
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
    TitleLabel.Size = UDim2.new(0.45, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Text = initialText
    TitleLabel.Font = Library.CurrentFont
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 8
    
    table.insert(Library.TrackedMainText, TitleLabel)
    
    local SelectedLabel = Instance.new("TextLabel", HeaderBtn)
    SelectedLabel.Size = UDim2.new(0.55, -35, 1, 0)
    SelectedLabel.Position = UDim2.new(0.45, 0, 0, 0)
    SelectedLabel.Text = default
    SelectedLabel.Font = Library.CurrentFont
    SelectedLabel.TextColor3 = getThemeAccent()
    SelectedLabel.TextSize = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
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
    OptionsContainer.ScrollBarImageColor3 = getThemeAccent()
    OptionsContainer.ZIndex = 8
    OptionsContainer.ClipsDescendants = true
    OptionsContainer.Visible = false
    
    local ListLayout = Instance.new("UIListLayout", OptionsContainer)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function updateCanvas()
        OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    
    local isExpanded = false
    local optionButtons = {}

    local function toggleDropdown()
        isExpanded = not isExpanded
        local currentOptionsCount = #options
        local contentHeight = math.min(currentOptionsCount * 32, 140)
        
        if isExpanded then
            if Library.ActiveDropdownClose and Library.ActiveDropdownClose ~= toggleDropdown then
                Library.ActiveDropdownClose()
            end
            Library.ActiveDropdownClose = toggleDropdown
            
            OptionsContainer.Visible = true
            OptionsContainer.Size = UDim2.new(1, 0, 0, contentHeight)
            tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, 36 + contentHeight + 4)}, 0.2)
            tween(Arrow, {Rotation = 180}, 0.2)
            task.defer(updateCanvas)
        else
            if Library.ActiveDropdownClose == toggleDropdown then
                Library.ActiveDropdownClose = nil
            end
            tween(Arrow, {Rotation = 0}, 0.2)
            local closeTween = tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, 36)}, 0.2)
            if closeTween then
                closeTween.Completed:Connect(function()
                    if not isExpanded then
                        OptionsContainer.Visible = false
                    end
                end)
            else
                OptionsContainer.Visible = false
            end
        end
    end
    HeaderBtn.Activated:Connect(toggleDropdown)
    
    local function selectValue(option)
        SelectedLabel.Text = option
        if type(callback) == "function" then callback(option) end
        local accent = getThemeAccent()
        
        for optName, optData in pairs(optionButtons) do
            if optName == option then
                optData.Label.TextColor3 = accent
                optData.Check.Visible = true
                optData.Check.TextColor3 = accent
            else
                local curBgL = getLuminance(getThemeMainBg())
                optData.Label.TextColor3 = (curBgL > 0.5) and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
                optData.Check.Visible = false
            end
        end
    end

    local function populateOptions(newOptions)
        options = newOptions
        for _, child in ipairs(OptionsContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        table.clear(optionButtons)

        local accent = getThemeAccent()
        for i, option in ipairs(options) do
            local OptBtn = Instance.new("TextButton", OptionsContainer)
            OptBtn.Size = UDim2.new(1, 0, 0, 32)
            OptBtn.BackgroundTransparency = 1
            OptBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptBtn.Text = ""
            OptBtn.LayoutOrder = i
            OptBtn.ZIndex = 9
            
            local OptLabel = Instance.new("TextLabel", OptBtn)
            OptLabel.Size = UDim2.new(1, -40, 1, 0)
            OptLabel.Position = UDim2.new(0, 16, 0, 0)
            OptLabel.Text = option
            OptLabel.TextSize = 12
            OptLabel.TextXAlignment = Enum.TextXAlignment.Left
            OptLabel.TextTruncate = Enum.TextTruncate.AtEnd
            OptLabel.BackgroundTransparency = 1
            OptLabel.ZIndex = 10
            
            local curBgL = getLuminance(getThemeMainBg())
            local defaultSubText = (curBgL > 0.5) and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
            OptLabel.TextColor3 = (option == SelectedLabel.Text) and accent or defaultSubText
            
            if FontMapping and FontMapping[option] then
                OptLabel.Font = FontMapping[option]
            else
                OptLabel.Font = Library.CurrentFont
            end
            
            local Checkmark = Instance.new("TextLabel", OptBtn)
            Checkmark.Size = UDim2.new(0, 20, 1, 0)
            Checkmark.Position = UDim2.new(1, -30, 0, 0)
            Checkmark.Text = "✓"
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.TextColor3 = accent
            Checkmark.TextSize = 12
            Checkmark.BackgroundTransparency = 1
            Checkmark.Visible = (option == SelectedLabel.Text)
            Checkmark.ZIndex = 10
            
            OptBtn.MouseEnter:Connect(function()
                tween(OptBtn, {BackgroundTransparency = 0.96}, 0.15)
            end)
            OptBtn.MouseLeave:Connect(function()
                tween(OptBtn, {BackgroundTransparency = 1}, 0.15)
            end)
            
            optionButtons[option] = {Button = OptBtn, Label = OptLabel, Check = Checkmark}
            
            OptBtn.Activated:Connect(function()
                selectValue(option)
            end)
        end
        
        task.defer(updateCanvas)
    end

    populateOptions(options)
    
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

    return {
        SetValue = function(val) selectValue(val) end,
        GetValue = function() return SelectedLabel.Text end,
        UpdateOptions = function(newOpts) populateOptions(newOpts) end
    }
end

function Library:CreateButton(parentPage, textKey, callback)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local Btn = Instance.new("TextButton", parentPage)
    Btn.Size = UDim2.new(1, -20, 0, 36)
    Btn.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
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
        spawnWave(Btn, mousePos.X - Btn.AbsolutePosition.X, (mousePos.Y - inset.Y) - Btn.AbsolutePosition.Y)
    end)
    Btn.Activated:Connect(function()
        if type(callback) == "function" then callback() end
    end)
    
    local searchItem = {Instance = Btn, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = Btn, Key = textKey, SearchItem = searchItem})
end

function Library:CreateToggle(parentPage, textKey, default, callback)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local TglFrame = Instance.new("Frame", parentPage)
    TglFrame.Size = UDim2.new(1, -20, 0, 36)
    TglFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
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
    Checkbox.BackgroundColor3 = default and getThemeAccent() or Color3.fromRGB(40, 40, 40) 
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
    local function setToggleState(state)
        enabled = state
        local accent = getThemeAccent()
        local brightness = (accent.R + accent.G + accent.B)
        local activeIndicatorColor = brightness > 2.5 and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 255, 255)
        if enabled then
            tween(Checkbox, {BackgroundColor3 = accent}, 0.2)
            tween(Indicator, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = activeIndicatorColor}, 0.2)
        else
            local offColor = isLightColor(getThemeMainBg()) and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(40, 40, 40)
            tween(Checkbox, {BackgroundColor3 = offColor}, 0.2)
            tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end
        if type(callback) == "function" then callback(enabled) end
    end

    Checkbox.Activated:Connect(function()
        setToggleState(not enabled)
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

    return {
        SetValue = function(state) setToggleState(state) end,
        GetValue = function() return enabled end
    }
end

function Library:CreateSlider(parentPage, textKey, min, max, default, callback)
    local initialText = Localization[Library.CurrentLanguage][textKey] or textKey
    local SliderFrame = Instance.new("Frame", parentPage)
    SliderFrame.Size = UDim2.new(1, -20, 0, 52)
    SliderFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
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
    
    local SliderBtn = Instance.new("TextButton", SliderFrame)
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
    local currentValue = default
    local startX = 0
    local startPercent = 0
    local cachedTrackWidth = 0
    local isIntegerSlider = (max - min) > 5
    
    local function getTrafficLightColor(pct)
        local red = Color3.fromRGB(255, 60, 60)
        local yellow = Color3.fromRGB(255, 210, 40)
        local green = Color3.fromRGB(60, 255, 90)
        if pct < 0.5 then return red:Lerp(yellow, pct * 2) else return yellow:Lerp(green, (pct - 0.5) * 2) end
    end
    
    local function updateVisuals(percentage)
        SliderFill.BackgroundColor3 = getTrafficLightColor(percentage)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderHandle.Position = UDim2.new(percentage, 0, 0.5, 0)
        local rawValue = min + (max - min) * percentage
        if isIntegerSlider then
            local roundedValue = math.floor(rawValue + 0.5)
            currentValue = roundedValue
            ValueLabel.Text = string.format("%d", roundedValue)
            if type(callback) == "function" then callback(roundedValue) end
        else
            currentValue = rawValue
            ValueLabel.Text = string.format("%.2f", rawValue)
            if type(callback) == "function" then callback(rawValue) end
        end
    end

    local function setSliderVal(val)
        currentPercent = math.clamp((val - min) / (max - min), 0, 1)
        updateVisuals(currentPercent)
    end
    
    SliderBtn.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            startX = input.Position.X
            cachedTrackWidth = math.max(SliderTrack.AbsoluteSize.X, 1)
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
        while SliderTrack.Parent and SliderTrack.AbsoluteSize.X == 0 do task.wait() end
        if SliderTrack.Parent then updateVisuals(currentPercent) end
    end)
    
    local searchItem = {Instance = SliderFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = SliderLabel, Key = textKey, SearchItem = searchItem})

    return {
        SetValue = function(val) setSliderVal(val) end,
        GetValue = function() return currentValue end
    }
end

function Library:CreatePage(textKey, iconId, layoutOrder)
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
    TabBtn.Name = textKey
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
        if tonumber(iconId) then TabIcon.Image = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150" else TabIcon.Image = iconId end
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
        local localX = mousePos.X - TabContainer.AbsolutePosition.X
        local localY = (mousePos.Y - inset.Y) - TabContainer.AbsolutePosition.Y
        spawnWave(TabContainer, localX, localY)
    end)
    
    TabBtn.MouseEnter:Connect(function()
        if TabBtn ~= currentActiveTab then
            applyHover(TabBtn)
        end
        currentHoveredTab = TabBtn
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if TabBtn ~= currentActiveTab then
            removeHover(TabBtn)
        end
        currentHoveredTab = nil
    end)

    TabBtn.Activated:Connect(function()
        if currentActiveTab == TabBtn then return end

        if currentActiveTab then
            clearActiveTab(currentActiveTab)
        end
        
        if currentHoveredTab == TabBtn then
            removeHover(TabBtn)
        end

        if SearchBox.Text ~= "" then SearchBox.Text = "" end

        for tName, pFrame in pairs(allPages) do
            pFrame.Visible = false
        end

        Library.CurrentTabKey = textKey
        TabTitle.Text = Localization[Library.CurrentLanguage][textKey] or textKey
        PageFrame.Visible = true

        setActiveTab(TabBtn)
        currentActiveTab = TabBtn
    end)

    table.insert(LocaleObjects, {Object = TabBtn, Key = textKey})
    UpdateNavCanvas()
    return PageFrame
end

-- ============================================================================
-- ВКЛАДКА "SETTINGS" + СИСТЕМА КОНФИГУРАЦИЙ
-- ============================================================================
local SettingsPage = Library:CreatePage("Settings", "117996761927034", 1)

local LanguageDropdown = Library:CreateDropdown(SettingsPage, "Language", {"English", "Русский"}, "English", function(selectedLang)
    Library:UpdateLanguage(selectedLang)
end)

local ThemeDropdown = Library:CreateDropdown(SettingsPage, "UITheme", ThemeNamesList, "Deep Ocean", function(selectedTheme)
    Library:UpdateTheme(selectedTheme)
end)

local FontKeys = {}
for name, _ in pairs(FontMapping) do table.insert(FontKeys, name) end
table.sort(FontKeys)

local FontDropdown = Library:CreateDropdown(SettingsPage, "MenuFont", FontKeys, "Gotham", function(selectedFont)
    if FontMapping[selectedFont] then
        Library.CurrentFont = FontMapping[selectedFont]
        for _, obj in ipairs(Library.TrackedMainText) do
            if obj and obj.Parent then obj.Font = Library.CurrentFont end
        end
        for _, obj in ipairs(Library.TrackedSubText) do
            if obj and obj.Parent then obj.Font = Library.CurrentFont end
        end
    end
end)

local TransparencySlider = Library:CreateSlider(SettingsPage, "UITransparency", 0, 90, 15, function(value)
    MainFrame.BackgroundTransparency = value / 100
end)

local AntiAFKToggle = Library:CreateToggle(SettingsPage, "AntiAFK", true, function(state)
    toggleAntiAFK(state)
end)

local AnimatedWindowToggle = Library:CreateToggle(SettingsPage, "AnimatedWindow", false, function(state)
    toggleAnimatedWindow(state)
end)

local GradientToggle = Library:CreateToggle(SettingsPage, "Gradient", false, function(state)
    toggleGradientEffect(state)
end)

-- ----------------------------------------------------------------------------
-- МОДУЛЬ КОНФИГУРАЦИЙ (С ЗАЩИЩЕННЫМИ ФАЙЛОВЫМИ ОПЕРАЦИЯМИ)
-- ----------------------------------------------------------------------------
local ConfigSystem = {}
ConfigSystem.FolderPath = "DarkHub/Configs"
ConfigSystem.LastConfigPath = "DarkHub/LastConfig.json"
ConfigSystem.CurrentLoadedConfig = nil

pcall(function()
    if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
        if not isfolder("DarkHub") then makefolder("DarkHub") end
        if not isfolder(ConfigSystem.FolderPath) then makefolder(ConfigSystem.FolderPath) end
    end
end)

local ConfigSectionHeader = Instance.new("TextLabel", SettingsPage)
ConfigSectionHeader.Size = UDim2.new(1, -20, 0, 24)
ConfigSectionHeader.Text = "Конфигурации"
ConfigSectionHeader.Font = Enum.Font.GothamBold
ConfigSectionHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigSectionHeader.TextSize = 15
ConfigSectionHeader.TextXAlignment = Enum.TextXAlignment.Left
ConfigSectionHeader.BackgroundTransparency = 1
ConfigSectionHeader.LayoutOrder = 100
table.insert(Library.TrackedMainText, ConfigSectionHeader)

local ConfigDivider = Instance.new("Frame", SettingsPage)
ConfigDivider.Size = UDim2.new(1, -20, 0, 1)
ConfigDivider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ConfigDivider.BorderSizePixel = 0
ConfigDivider.LayoutOrder = 101
table.insert(Library.TrackedStrokes, ConfigDivider)

local ConfigsScrollFrame = Instance.new("ScrollingFrame", SettingsPage)
ConfigsScrollFrame.Size = UDim2.new(1, -20, 0, 170)
ConfigsScrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ConfigsScrollFrame.BackgroundTransparency = 0.5
ConfigsScrollFrame.ScrollBarThickness = 3
ConfigsScrollFrame.ScrollBarImageColor3 = getThemeAccent()
ConfigsScrollFrame.BorderSizePixel = 0
ConfigsScrollFrame.LayoutOrder = 102
Instance.new("UICorner", ConfigsScrollFrame).CornerRadius = UDim.new(0, 8)
local ConfigsScrollStroke = Instance.new("UIStroke", ConfigsScrollFrame)
ConfigsScrollStroke.Color = Color3.fromRGB(40, 40, 40)
table.insert(Library.TrackedStrokes, ConfigsScrollStroke)

local ConfigListLayout = Instance.new("UIListLayout", ConfigsScrollFrame)
ConfigListLayout.Padding = UDim.new(0, 6)
ConfigListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ConfigListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ConfigListPadding = Instance.new("UIPadding", ConfigsScrollFrame)
ConfigListPadding.PaddingTop = UDim.new(0, 6)
ConfigListPadding.PaddingBottom = UDim.new(0, 6)

ConfigListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ConfigsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ConfigListLayout.AbsoluteContentSize.Y + 12)
end)

local EmptyConfigLabel = Instance.new("TextLabel", ConfigsScrollFrame)
EmptyConfigLabel.Size = UDim2.new(1, 0, 1, 0)
EmptyConfigLabel.Text = "Нет сохранённых конфигов"
EmptyConfigLabel.Font = Enum.Font.Gotham
EmptyConfigLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
EmptyConfigLabel.TextSize = 12
EmptyConfigLabel.BackgroundTransparency = 1
EmptyConfigLabel.Visible = false

local SaveConfigBtn = Instance.new("TextButton", SettingsPage)
SaveConfigBtn.Size = UDim2.new(1, -20, 0, 34)
SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 90)
SaveConfigBtn.Text = "Save Config"
SaveConfigBtn.Font = Enum.Font.GothamBold
SaveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveConfigBtn.TextSize = 13
SaveConfigBtn.LayoutOrder = 103
SaveConfigBtn.ClipsDescendants = true
Instance.new("UICorner", SaveConfigBtn).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel", SettingsPage)
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Text = ""
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 140)
StatusLabel.TextSize = 11
StatusLabel.BackgroundTransparency = 1
StatusLabel.LayoutOrder = 104

local function ShowStatus(text, isError)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = isError and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(100, 220, 140)
    task.delay(4, function()
        if StatusLabel.Text == text then StatusLabel.Text = "" end
    end)
end

function ConfigSystem:GetCurrentData()
    return {
        Language = LanguageDropdown.GetValue(),
        Theme = ThemeDropdown.GetValue(),
        Font = FontDropdown.GetValue(),
        Transparency = TransparencySlider.GetValue(),
        AntiAFK = AntiAFKToggle.GetValue(),
        AnimatedWindow = AnimatedWindowToggle.GetValue(),
        Gradient = GradientToggle.GetValue()
    }
end

function ConfigSystem:ApplyData(data)
    if type(data) ~= "table" then return end
    if data.Language then LanguageDropdown.SetValue(data.Language) end
    if data.Theme then ThemeDropdown.SetValue(data.Theme) end
    if data.Font then FontDropdown.SetValue(data.Font) end
    if data.Transparency ~= nil then TransparencySlider.SetValue(data.Transparency) end
    if data.AntiAFK ~= nil then AntiAFKToggle.SetValue(data.AntiAFK) end
    if data.AnimatedWindow ~= nil then AnimatedWindowToggle.SetValue(data.AnimatedWindow) end
    if data.Gradient ~= nil then GradientToggle.SetValue(data.Gradient) end
end

-- Модальное окно
local ModalOverlay = Instance.new("Frame", DarkHub)
ModalOverlay.Size = UDim2.new(1, 0, 1, 0)
ModalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ModalOverlay.BackgroundTransparency = 0.6
ModalOverlay.Visible = false
ModalOverlay.ZIndex = 300

local ModalCard = Instance.new("Frame", ModalOverlay)
ModalCard.Size = UDim2.new(0, 280, 0, 140)
ModalCard.Position = UDim2.new(0.5, 0, 0.5, 0)
ModalCard.AnchorPoint = Vector2.new(0.5, 0.5)
ModalCard.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ModalCard.ZIndex = 301
Instance.new("UICorner", ModalCard).CornerRadius = UDim.new(0, 10)
local ModalStroke = Instance.new("UIStroke", ModalCard)
ModalStroke.Color = Color3.fromRGB(50, 50, 60)

local ModalTitle = Instance.new("TextLabel", ModalCard)
ModalTitle.Size = UDim2.new(1, -20, 0, 30)
ModalTitle.Position = UDim2.new(0, 10, 0, 10)
ModalTitle.Text = "Сохранить конфиг"
ModalTitle.Font = Enum.Font.GothamBold
ModalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ModalTitle.TextSize = 14
ModalTitle.BackgroundTransparency = 1
ModalTitle.ZIndex = 302

local ModalTextBox = Instance.new("TextBox", ModalCard)
ModalTextBox.Size = UDim2.new(1, -20, 0, 32)
ModalTextBox.Position = UDim2.new(0, 10, 0, 48)
ModalTextBox.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
ModalTextBox.PlaceholderText = "Введите имя конфига..."
ModalTextBox.Text = ""
ModalTextBox.Font = Enum.Font.Gotham
ModalTextBox.TextColor3 = Color3.fromRGB(240, 240, 240)
ModalTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ModalTextBox.TextSize = 12
ModalTextBox.ZIndex = 302
Instance.new("UICorner", ModalTextBox).CornerRadius = UDim.new(0, 6)

local ModalBtnConfirm = Instance.new("TextButton", ModalCard)
ModalBtnConfirm.Size = UDim2.new(0.45, -5, 0, 30)
ModalBtnConfirm.Position = UDim2.new(0, 10, 1, -40)
ModalBtnConfirm.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
ModalBtnConfirm.Text = "Сохранить"
ModalBtnConfirm.Font = Enum.Font.GothamBold
ModalBtnConfirm.TextColor3 = Color3.fromRGB(255, 255, 255)
ModalBtnConfirm.TextSize = 12
ModalBtnConfirm.ZIndex = 302
Instance.new("UICorner", ModalBtnConfirm).CornerRadius = UDim.new(0, 6)

local ModalBtnCancel = Instance.new("TextButton", ModalCard)
ModalBtnCancel.Size = UDim2.new(0.45, -5, 0, 30)
ModalBtnCancel.Position = UDim2.new(0.55, -5, 1, -40)
ModalBtnCancel.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ModalBtnCancel.Text = "Отмена"
ModalBtnCancel.Font = Enum.Font.Gotham
ModalBtnCancel.TextColor3 = Color3.fromRGB(220, 220, 220)
ModalBtnCancel.TextSize = 12
ModalBtnCancel.ZIndex = 302
Instance.new("UICorner", ModalBtnCancel).CornerRadius = UDim.new(0, 6)

local activeConfirmConnection = nil

local function HideModal()
    ModalOverlay.Visible = false
    ModalTextBox.Text = ""
    if activeConfirmConnection then
        activeConfirmConnection:Disconnect()
        activeConfirmConnection = nil
    end
end

ModalBtnCancel.Activated:Connect(HideModal)

function ConfigSystem:SaveToFile(name)
    if not name or name == "" then return end
    local filepath = ConfigSystem.FolderPath .. "/" .. name .. ".json"
    local timeStr = os.date("%d.%m.%Y %H:%M")
    local saveData = {
        Timestamp = timeStr,
        Settings = ConfigSystem:GetCurrentData()
    }
    
    local success, encoded = pcall(function() return HttpService:JSONEncode(saveData) end)
    if success and typeof(writefile) == "function" then
        pcall(function()
            writefile(filepath, encoded)
            ConfigSystem.CurrentLoadedConfig = name
            writefile(ConfigSystem.LastConfigPath, HttpService:JSONEncode({Last = name}))
        end)
        
        ShowStatus("Конфиг '" .. name .. "' сохранён!", false)
        ConfigSystem:RefreshList()
    else
        ShowStatus("Ошибка при сохранении конфига", true)
    end
end

function ConfigSystem:RenameConfig(oldName, newName)
    if not newName or newName == "" or newName == oldName then return end
    local oldPath = ConfigSystem.FolderPath .. "/" .. oldName .. ".json"
    local newPath = ConfigSystem.FolderPath .. "/" .. newName .. ".json"
    
    pcall(function()
        if typeof(isfile) == "function" and isfile(oldPath) and typeof(readfile) == "function" and typeof(writefile) == "function" and typeof(delfile) == "function" then
            local content = readfile(oldPath)
            writefile(newPath, content)
            delfile(oldPath)
            
            if ConfigSystem.CurrentLoadedConfig == oldName then
                ConfigSystem.CurrentLoadedConfig = newName
                writefile(ConfigSystem.LastConfigPath, HttpService:JSONEncode({Last = newName}))
            end
            ShowStatus("Конфиг переименован в '" .. newName .. "'", false)
            ConfigSystem:RefreshList()
        end
    end)
end

function ConfigSystem:RefreshList()
    for _, child in ipairs(ConfigsScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local files = {}
    if typeof(listfiles) == "function" and typeof(isfolder) == "function" then
        pcall(function()
            if isfolder(ConfigSystem.FolderPath) then
                for _, file in ipairs(listfiles(ConfigSystem.FolderPath)) do
                    if string.sub(file, -5) == ".json" then
                        local fileName = string.gsub(file, "\\", "/")
                        fileName = string.match(fileName, "([^/]+)%.json$")
                        if fileName then table.insert(files, fileName) end
                    end
                end
            end
        end)
    end
    
    EmptyConfigLabel.Visible = (#files == 0)
    
    for i, configName in ipairs(files) do
        local isCurrent = (configName == ConfigSystem.CurrentLoadedConfig)
        
        local Card = Instance.new("Frame", ConfigsScrollFrame)
        Card.Size = UDim2.new(1, -12, 0, 48)
        Card.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
        Card.LayoutOrder = i
        Card.ZIndex = 8
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
        
        local CardStroke = Instance.new("UIStroke", Card)
        CardStroke.Thickness = 1
        CardStroke.Color = isCurrent and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(45, 45, 50)
        
        if isCurrent then
            local ActiveBar = Instance.new("Frame", Card)
            ActiveBar.Size = UDim2.new(0, 4, 1, 0)
            ActiveBar.Position = UDim2.new(0, 0, 0, 0)
            ActiveBar.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
            ActiveBar.BorderSizePixel = 0
            ActiveBar.ZIndex = 9
            Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(0, 2)
        end
        
        local timestampText = "00.00.0000 00:00"
        local filePath = ConfigSystem.FolderPath .. "/" .. configName .. ".json"
        pcall(function()
            if typeof(isfile) == "function" and isfile(filePath) and typeof(readfile) == "function" then
                local data = HttpService:JSONDecode(readfile(filePath))
                if data and data.Timestamp then timestampText = data.Timestamp end
            end
        end)
        
        local TitleBox = Instance.new("TextBox", Card)
        TitleBox.Size = UDim2.new(1, -140, 0, 20)
        TitleBox.Position = UDim2.new(0, 10, 0, 6)
        TitleBox.Text = configName
        TitleBox.Font = Enum.Font.GothamBold
        TitleBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleBox.TextSize = 12
        TitleBox.TextXAlignment = Enum.TextXAlignment.Left
        TitleBox.BackgroundTransparency = 1
        TitleBox.ClearTextOnFocus = false
        TitleBox.ZIndex = 9
        
        TitleBox.FocusLost:Connect(function()
            if TitleBox.Text ~= configName then
                ConfigSystem:RenameConfig(configName, TitleBox.Text)
            end
        end)
        
        local DateLabel = Instance.new("TextLabel", Card)
        DateLabel.Size = UDim2.new(1, -140, 0, 14)
        DateLabel.Position = UDim2.new(0, 10, 0, 26)
        DateLabel.Text = timestampText
        DateLabel.Font = Enum.Font.Gotham
        DateLabel.TextColor3 = Color3.fromRGB(130, 130, 135)
        DateLabel.TextSize = 10
        DateLabel.TextXAlignment = Enum.TextXAlignment.Left
        DateLabel.BackgroundTransparency = 1
        DateLabel.ZIndex = 9
        
        local ActionsContainer = Instance.new("Frame", Card)
        ActionsContainer.Size = UDim2.new(0, 125, 0, 28)
        ActionsContainer.Position = UDim2.new(1, -130, 0.5, -14)
        ActionsContainer.BackgroundTransparency = 1
        ActionsContainer.ZIndex = 9
        
        local ActionLayout = Instance.new("UIListLayout", ActionsContainer)
        ActionLayout.FillDirection = Enum.FillDirection.Horizontal
        ActionLayout.Padding = UDim.new(0, 4)
        ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        
        local function createSmallBtn(btnText, color, callback)
            local btn = Instance.new("TextButton", ActionsContainer)
            btn.Size = UDim2.new(0, 38, 1, 0)
            btn.BackgroundColor3 = color
            btn.Text = btnText
            btn.Font = Enum.Font.GothamBold
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 10
            btn.ZIndex = 10
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.Activated:Connect(callback)
            return btn
        end
        
        -- Load
        createSmallBtn("Load", Color3.fromRGB(0, 120, 215), function()
            pcall(function()
                if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(filePath) then
                    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
                    if success and decoded and decoded.Settings then
                        ConfigSystem:ApplyData(decoded.Settings)
                        ConfigSystem.CurrentLoadedConfig = configName
                        if typeof(writefile) == "function" then
                            pcall(function()
                                writefile(ConfigSystem.LastConfigPath, HttpService:JSONEncode({Last = configName}))
                            end)
                        end
                        ShowStatus("Конфиг '" .. configName .. "' загружен!", false)
                        ConfigSystem:RefreshList()
                    end
                end
            end)
        end)
        
        -- Update
        createSmallBtn("Upd", Color3.fromRGB(180, 130, 20), function()
            ConfigSystem:SaveToFile(configName)
        end)
        
        -- Delete
        createSmallBtn("Del", Color3.fromRGB(180, 40, 40), function()
            if activeConfirmConnection then activeConfirmConnection:Disconnect() end
            
            ModalTitle.Text = "Удалить конфиг?"
            ModalTextBox.Visible = false
            ModalBtnConfirm.Text = "Да"
            ModalBtnConfirm.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            ModalOverlay.Visible = true
            
            activeConfirmConnection = ModalBtnConfirm.Activated:Connect(function()
                if activeConfirmConnection then
                    activeConfirmConnection:Disconnect()
                    activeConfirmConnection = nil
                end
                pcall(function()
                    if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(filePath) then
                        delfile(filePath)
                        if ConfigSystem.CurrentLoadedConfig == configName then
                            ConfigSystem.CurrentLoadedConfig = nil
                            if isfile(ConfigSystem.LastConfigPath) then delfile(ConfigSystem.LastConfigPath) end
                        end
                        ShowStatus("Конфиг удалён", true)
                        ConfigSystem:RefreshList()
                    end
                end)
                HideModal()
            end)
        end)
    end
end

SaveConfigBtn.Activated:Connect(function()
    if activeConfirmConnection then activeConfirmConnection:Disconnect() end
    
    ModalTitle.Text = "Создать новый конфиг"
    ModalTextBox.Visible = true
    ModalTextBox.Text = ""
    ModalBtnConfirm.Text = "Сохранить"
    ModalBtnConfirm.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
    ModalOverlay.Visible = true
    
    activeConfirmConnection = ModalBtnConfirm.Activated:Connect(function()
        if activeConfirmConnection then
            activeConfirmConnection:Disconnect()
            activeConfirmConnection = nil
        end
        local name = ModalTextBox.Text
        if name ~= "" then
            ConfigSystem:SaveToFile(name)
        end
        HideModal()
    end)
end)

-- Автозагрузка
task.spawn(function()
    ConfigSystem:RefreshList()
    pcall(function()
        if typeof(isfile) == "function" and typeof(readfile) == "function" and isfile(ConfigSystem.LastConfigPath) then
            local lastData = HttpService:JSONDecode(readfile(ConfigSystem.LastConfigPath))
            if lastData and lastData.Last then
                local lastConfigPath = ConfigSystem.FolderPath .. "/" .. lastData.Last .. ".json"
                if isfile(lastConfigPath) then
                    local cfgData = HttpService:JSONDecode(readfile(lastConfigPath))
                    if cfgData and cfgData.Settings then
                        ConfigSystem:ApplyData(cfgData.Settings)
                        ConfigSystem.CurrentLoadedConfig = lastData.Last
                        ConfigSystem:RefreshList()
                        ShowStatus("Автозагрузка: '" .. lastData.Last .. "'", false)
                    end
                end
            end
        end
    end)
end)

-- Инициализация первой вкладки
SettingsPage.Visible = true
local settingsButton = allTabButtons["Settings"]
if settingsButton then
    setActiveTab(settingsButton)
    currentActiveTab = settingsButton
end

Library:UpdateTheme("Deep Ocean")

-- ============================================================================
-- ЭКРАН ЗАГРУЗКИ
-- ============================================================================
local LoadingContainer = Instance.new("Frame")
LoadingContainer.Name = "LoadingContainer"
LoadingContainer.Size = UDim2.new(1, 0, 1, 0)
LoadingContainer.Position = UDim2.new(0, 0, 0, 0)
LoadingContainer.BackgroundTransparency = 1
LoadingContainer.ZIndex = 500
LoadingContainer.Parent = DarkHub

local LoadingCard = Instance.new("Frame")
LoadingCard.Name = "LoadingCard"
LoadingCard.Size = UDim2.new(0, 310, 0, 185)
LoadingCard.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingCard.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingCard.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
LoadingCard.BackgroundTransparency = 1
LoadingCard.ClipsDescendants = false
LoadingCard.ZIndex = 501
LoadingCard.Parent = LoadingContainer

local CardCorner = Instance.new("UICorner", LoadingCard)
CardCorner.CornerRadius = UDim.new(0, 16)

local CardStroke = Instance.new("UIStroke", LoadingCard)
CardStroke.Color = Color3.fromRGB(255, 255, 255)
CardStroke.Transparency = 1
CardStroke.Thickness = 1

local CardScale = Instance.new("UIScale", LoadingCard)
CardScale.Scale = 0.8

local IconFrame = Instance.new("Frame")
IconFrame.Name = "IconFrame"
IconFrame.Size = UDim2.new(0, 44, 0, 44)
IconFrame.Position = UDim2.new(0.5, 0, 0, 16)
IconFrame.AnchorPoint = Vector2.new(0.5, 0)
IconFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
IconFrame.BackgroundTransparency = 1
IconFrame.ZIndex = 502
IconFrame.Parent = LoadingCard

local IconCorner = Instance.new("UICorner", IconFrame)
IconCorner.CornerRadius = UDim.new(0, 10)

local IconScale = Instance.new("UIScale", IconFrame)
IconScale.Scale = 1.0

local IconImage = Instance.new("ImageLabel", IconFrame)
IconImage.Size = UDim2.new(1, 0, 1, 0)
IconImage.BackgroundTransparency = 1
IconImage.Image = "rbxthumb://type=Asset&id=" .. CustomIconID .. "&w=150&h=150"
IconImage.ScaleType = Enum.ScaleType.Fit
IconImage.ZIndex = 503
Instance.new("UICorner", IconImage).CornerRadius = UDim.new(0, 10)

local pulseInfo = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local pulseTween = TweenService:Create(IconScale, pulseInfo, {Scale = 1.08})
pulseTween:Play()

local LoadingTitle = Instance.new("TextLabel", LoadingCard)
LoadingTitle.Size = UDim2.new(1, 0, 0, 22)
LoadingTitle.Position = UDim2.new(0, 0, 0, 66)
LoadingTitle.Text = "Dark Hub"
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.TextSize = 18
LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.TextTransparency = 1
LoadingTitle.ZIndex = 502

local ProgressBarBg = Instance.new("Frame", LoadingCard)
ProgressBarBg.Size = UDim2.new(0, 250, 0, 20)
ProgressBarBg.Position = UDim2.new(0.5, 0, 0, 100)
ProgressBarBg.AnchorPoint = Vector2.new(0.5, 0)
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProgressBarBg.BackgroundTransparency = 1
ProgressBarBg.ClipsDescendants = true
ProgressBarBg.ZIndex = 502
Instance.new("UICorner", ProgressBarBg).CornerRadius = UDim.new(0, 8)

local ProgressBarFill = Instance.new("Frame", ProgressBarBg)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBarFill.ZIndex = 503
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(0, 8)

local BarGradient = Instance.new("UIGradient", ProgressBarFill)
BarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 230, 210))
})

local waveTweenInfo = TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
local waveTween = TweenService:Create(BarGradient, waveTweenInfo, {Offset = Vector2.new(1, 0)})
waveTween:Play()

local BarText = Instance.new("TextLabel", ProgressBarBg)
BarText.Size = UDim2.new(1, 0, 1, 0)
BarText.Text = "0%"
BarText.Font = Enum.Font.GothamBold
BarText.TextSize = 12
BarText.TextColor3 = Color3.fromRGB(255, 255, 255)
BarText.TextTransparency = 1
BarText.BackgroundTransparency = 1
BarText.ZIndex = 504

local LoadingStatus = Instance.new("TextLabel", LoadingCard)
LoadingStatus.Size = UDim2.new(1, -20, 0, 18)
LoadingStatus.Position = UDim2.new(0, 10, 0, 130)
LoadingStatus.Text = "Инициализация ядра..."
LoadingStatus.Font = Enum.Font.Gotham
LoadingStatus.TextSize = 12
LoadingStatus.TextColor3 = Color3.fromRGB(180, 180, 200)
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.TextTransparency = 1
LoadingStatus.ZIndex = 502

local particlesActive = true
local function spawnParticle()
    if not particlesActive or not LoadingCard or not LoadingCard.Parent then return end
    
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(4, 6), 0, math.random(4, 6))
    p.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(70, 95) / 100, 0)
    p.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    p.BackgroundTransparency = 0.5
    p.BorderSizePixel = 0
    p.ZIndex = 500
    p.Parent = LoadingCard
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    
    local targetY = p.Position.Y.Scale - math.random(30, 60) / 100
    local targetX = p.Position.X.Scale + (math.random(-15, 15) / 100)
    
    local pTween = TweenService:Create(p, TweenInfo.new(math.random(15, 25) / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(targetX, 0, targetY, 0),
        BackgroundTransparency = 1
    })
    pTween:Play()
    pTween.Completed:Connect(function()
        p:Destroy()
    end)
end

task.spawn(function()
    while particlesActive do
        spawnParticle()
        task.wait(math.random(2, 4) / 10)
    end
end)

TweenService:Create(LoadingCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
TweenService:Create(CardScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
TweenService:Create(CardStroke, TweenInfo.new(0.35), {Transparency = 0.85}):Play()

TweenService:Create(LoadingTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
TweenService:Create(ProgressBarBg, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
TweenService:Create(BarText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
TweenService:Create(LoadingStatus, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

local currentStatusText = LoadingStatus.Text
local function setStatus(newText, color)
    if currentStatusText == newText then return end
    currentStatusText = newText
    
    local fadeOut = TweenService:Create(LoadingStatus, TweenInfo.new(0.15), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Wait()
    
    LoadingStatus.Text = newText
    if color then
        LoadingStatus.TextColor3 = color
    end
    
    TweenService:Create(LoadingStatus, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
end

task.spawn(function()
    local stages = {
        { target = 0.30, duration = 1.0, status = "Инициализация ядра..." },
        { target = 0.60, duration = 1.2, status = "Загрузка интерфейса..." },
        { target = 0.85, duration = 0.8, status = "Подготовка настроек..." },
        { target = 0.95, duration = 0.6, status = "Загрузка конфигураций..." },
        { target = 1.00, duration = 0.4, status = "Запуск..." }
    }

    local currentProgress = 0

    for _, stage in ipairs(stages) do
        setStatus(stage.status)
        
        local fillTween = TweenService:Create(ProgressBarFill, TweenInfo.new(stage.duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(stage.target, 0, 1, 0)
        })
        fillTween:Play()
        
        local startTimeStage = os.clock()
        local startProgress = currentProgress
        local targetProgress = stage.target
        
        while os.clock() - startTimeStage < stage.duration do
            local elapsed = os.clock() - startTimeStage
            local alpha = math.clamp(elapsed / stage.duration, 0, 1)
            local quadAlpha = 1 - (1 - alpha) * (1 - alpha)
            currentProgress = startProgress + (targetProgress - startProgress) * quadAlpha
            BarText.Text = string.format("%d%%", math.floor(currentProgress * 100))
            task.wait()
        end
        
        currentProgress = stage.target
        BarText.Text = string.format("%d%%", math.floor(currentProgress * 100))
    end

    setStatus("ГОТОВО!", Color3.fromRGB(100, 255, 130))
    BarText.Text = "100%"
    task.wait(0.5)

    particlesActive = false

    TweenService:Create(CardScale, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.8}):Play()
    TweenService:Create(LoadingCard, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(CardStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(IconFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(IconImage, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    TweenService:Create(LoadingTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBarBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    local finalFade = TweenService:Create(LoadingStatus, TweenInfo.new(0.5), {TextTransparency = 1})
    finalFade:Play()

    finalFade.Completed:Wait()

    pulseTween:Cancel()
    waveTween:Cancel()
    LoadingContainer:Destroy()

    MainFrame.Visible = true
end)
