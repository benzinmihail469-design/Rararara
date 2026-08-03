-- ============================================================================
-- Dark Hub - Settings Edition (AMOLED Style with UI, Theme, Sky & Configs)
-- ============================================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- Wait for LocalPlayer
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

local CustomIconID = "76579925188009"
local SettingsIconID = "126198709409720" -- Иконка для Settings
local DefaultIconID = "6031094678" -- Резервная иконка
local startTime = os.clock()

local function getIconAsset(id)
    if id and type(id) == "string" and #id > 0 then
        return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150"
    end
    return "rbxassetid://" .. DefaultIconID
end

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

-- Safe GUI Parent Resolution
local SafeParent = nil
if typeof(gethui) == "function" then
    pcall(function()
        SafeParent = gethui()
    end)
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
if not SafeParent then
    return
end
if SafeParent:FindFirstChild("DarkHub") then
    SafeParent.DarkHub:Destroy()
end

local DarkHub = Instance.new("ScreenGui")
DarkHub.Name = "DarkHub"
DarkHub.Parent = SafeParent
DarkHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DarkHub.IgnoreGuiInset = true

-- Fixed Tween Manager
local activeTweens = {}
local function tween(obj, props, dur, easingStyle, easingDirection)
    if not obj or typeof(obj) ~= "Instance" or not obj.Parent then
        return nil
    end
    if not activeTweens[obj] then
        activeTweens[obj] = {}
    end
    for prop, _ in pairs(props) do
        if activeTweens[obj][prop] then
            pcall(function()
                activeTweens[obj][prop]:Cancel()
            end)
            activeTweens[obj][prop] = nil
        end
    end
    local success, t = pcall(function()
        return TweenService:Create(
            obj,
            TweenInfo.new(dur or 0.25, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out),
            props
        )
    end)
    if success and t then
        for prop, _ in pairs(props) do
            activeTweens[obj][prop] = t
        end
        t:Play()
        return t
    end
    return nil
end

local function NormalizeText(str)
    if type(str) ~= "string" then
        return ""
    end
    local lowerStr = str:lower()
    local synonyms = {
        ["настройки"] = "settings",
        ["язык"] = "language",
        ["тема"] = "theme",
        ["шрифт"] = "font"
    }
    for ru, en in pairs(synonyms) do
        lowerStr = string.gsub(lowerStr, ru, en)
    end
    return string.gsub(lowerStr, "[%p%s%c]", "")
end

local function spawnWave(container, clickX, clickY)
    if not container or typeof(container) ~= "Instance" or not container.Parent then
        return
    end
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
    Wave.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Wave.BackgroundTransparency = 0.4
    Wave.BorderSizePixel = 0
    Wave.ZIndex = 20
    local Corner = Instance.new("UICorner", Wave)
    Corner.CornerRadius = UDim.new(1, 0)
    local waveTween = tween(Wave, {
        Size = UDim2.new(0, maxDimension, 0, maxDimension),
        BackgroundTransparency = 1
    }, 0.6)
    if waveTween then
        waveTween.Completed:Connect(function()
            if Wave and Wave.Parent then
                Wave:Destroy()
            end
        end)
    end
end

-- ============================================================================
-- SKY SYSTEM CONTROLLER
-- ============================================================================
local currentSkyInstance = nil
local function applySkySettings(skyName)
    if skyName == "space cky" then
        if not currentSkyInstance or not currentSkyInstance.Parent then
            currentSkyInstance = Instance.new("Sky")
            currentSkyInstance.Name = "DarkHub_SpaceSky"
            currentSkyInstance.Parent = Lighting
        end
        currentSkyInstance.SkyboxBk = "rbxassetid://16262356578"
        currentSkyInstance.SkyboxDn = "rbxassetid://16262358026"
        currentSkyInstance.SkyboxFt = "rbxassetid://16262360469"
        currentSkyInstance.SkyboxLf = "rbxassetid://16262362003"
        currentSkyInstance.SkyboxRt = "rbxassetid://16262363873"
        currentSkyInstance.SkyboxUp = "rbxassetid://16262366016"
    elseif skyName == "pink sky" then
        if not currentSkyInstance or not currentSkyInstance.Parent then
            currentSkyInstance = Instance.new("Sky")
            currentSkyInstance.Name = "DarkHub_PinkSky"
            currentSkyInstance.Parent = Lighting
        end
        currentSkyInstance.SkyboxBk = "rbxassetid://271042516"
        currentSkyInstance.SkyboxDn = "rbxassetid://271077243"
        currentSkyInstance.SkyboxFt = "rbxassetid://271042556"
        currentSkyInstance.SkyboxLf = "rbxassetid://271042310"
        currentSkyInstance.SkyboxRt = "rbxassetid://271042467"
        currentSkyInstance.SkyboxUp = "rbxassetid://271077958"
    elseif skyName == "sunset sky" then
        if not currentSkyInstance or not currentSkyInstance.Parent then
            currentSkyInstance = Instance.new("Sky")
            currentSkyInstance.Name = "DarkHub_SunsetSky"
            currentSkyInstance.Parent = Lighting
        end
        currentSkyInstance.SkyboxBk = "rbxassetid://169210090"
        currentSkyInstance.SkyboxDn = "rbxassetid://169210108"
        currentSkyInstance.SkyboxFt = "rbxassetid://169210121"
        currentSkyInstance.SkyboxLf = "rbxassetid://169210133"
        currentSkyInstance.SkyboxRt = "rbxassetid://169210143"
        currentSkyInstance.SkyboxUp = "rbxassetid://169210149"
    elseif skyName == "dark sky" then
        if not currentSkyInstance or not currentSkyInstance.Parent then
            currentSkyInstance = Instance.new("Sky")
            currentSkyInstance.Name = "DarkHub_DarkSky"
            currentSkyInstance.Parent = Lighting
        end
        currentSkyInstance.SkyboxBk = "rbxassetid://15470149279"
        currentSkyInstance.SkyboxDn = "rbxassetid://15470151245"
        currentSkyInstance.SkyboxFt = "rbxassetid://15470153860"
        currentSkyInstance.SkyboxLf = "rbxassetid://15470155938"
        currentSkyInstance.SkyboxRt = "rbxassetid://15470158022"
        currentSkyInstance.SkyboxUp = "rbxassetid://15470160563"
    else
        if currentSkyInstance and currentSkyInstance.Parent then
            currentSkyInstance:Destroy()
            currentSkyInstance = nil
        end
    end
end

-- ============================================================================
-- FOG SYSTEM CONTROLLER
-- ============================================================================
local fogEnabled = true
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalFogColor = Lighting.FogColor

local originalAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local originalDensity = originalAtmosphere and originalAtmosphere.Density or 0.25
local originalHaze = originalAtmosphere and originalAtmosphere.Haze or 0
local originalGlare = originalAtmosphere and originalAtmosphere.Glare or 0
local originalAtmosphereColor = originalAtmosphere and originalAtmosphere.Color or Color3.fromRGB(199, 199, 199)
local originalDecay = originalAtmosphere and originalAtmosphere.Decay or Color3.fromRGB(107, 107, 107)

local customFogStart = 0
local customFogEnd = 120 
local customFogColor = Color3.fromRGB(120, 120, 130)
local customFogDensity = 1.0 

local colorPresets = {
    ["Default"] = originalFogColor,
    ["Black"] = Color3.fromRGB(0, 0, 0),
    ["White"] = Color3.fromRGB(255, 255, 255),
    ["Red"] = Color3.fromRGB(255, 50, 50),
    ["Blue"] = Color3.fromRGB(50, 150, 255),
    ["Green"] = Color3.fromRGB(50, 255, 50),
    ["Purple"] = Color3.fromRGB(150, 50, 255),
    ["Cyan"] = Color3.fromRGB(0, 255, 255),
    ["Yellow"] = Color3.fromRGB(255, 255, 50),
    ["Orange"] = Color3.fromRGB(255, 150, 0)
}

local function applyFogSettings(smooth)
    local duration = smooth and 0.4 or 0
    
    if fogEnabled then
        tween(Lighting, {
            FogStart = customFogStart,
            FogEnd = customFogEnd,
            FogColor = customFogColor
        }, duration)
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if not atmosphere then
            atmosphere = Instance.new("Atmosphere")
            atmosphere.Parent = Lighting
        end
        
        tween(atmosphere, {
            Density = customFogDensity,
            Haze = math.clamp(customFogDensity * 3, 0, 10),
            Glare = 0.1,
            Color = customFogColor,
            Decay = customFogColor
        }, duration)
    else
        tween(Lighting, {
            FogStart = originalFogStart,
            FogEnd = originalFogEnd,
            FogColor = originalFogColor
        }, duration)
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            tween(atmosphere, {
                Density = originalDensity,
                Haze = originalHaze,
                Glare = originalGlare,
                Color = originalAtmosphereColor,
                Decay = originalDecay
            }, duration)
        end
    end
end
applyFogSettings(false)

-- ============================================================================
-- TOAST NOTIFICATION CONTROLLER
-- ============================================================================
local ToastContainer = Instance.new("Frame", DarkHub)
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 220, 0, 0)
ToastContainer.Position = UDim2.new(1, -230, 1, -20)
ToastContainer.AnchorPoint = Vector2.new(0, 1)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 1000

local toastLayout = Instance.new("UIListLayout", ToastContainer)
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.Padding = UDim.new(0, 6)

local function showToast(msg)
    local toast = Instance.new("Frame", ToastContainer)
    toast.Size = UDim2.new(1, 0, 0, 32)
    toast.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    toast.BackgroundTransparency = 0.2
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    
    local lbl = Instance.new("TextLabel", toast)
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    task.delay(2.5, function()
        if toast and toast.Parent then
            local t = tween(toast, {BackgroundTransparency = 1}, 0.3)
            if t then
                t.Completed:Connect(function()
                    if toast and toast.Parent then toast:Destroy() end
                end)
            end
        end
    end)
end

-- ============================================================================
-- MAIN GUI FRAMEWORK (AMOLED)
-- ============================================================================
local MainFrame = Instance.new("Frame", DarkHub)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.15
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Visible = true
MainFrame.ClipsDescendants = true

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 1

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5

local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -185, 1, -70)
PagesContainer.Position = UDim2.new(0, 175, 0, 60)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ZIndex = 5

-- Контейнер вкладки Settings и иконки
local TabHeaderFrame = Instance.new("Frame", MainFrame)
TabHeaderFrame.Name = "TabHeaderFrame"
TabHeaderFrame.Size = UDim2.new(0, 200, 0, 24)
TabHeaderFrame.Position = UDim2.new(0, 185, 0, 15)
TabHeaderFrame.BackgroundTransparency = 1
TabHeaderFrame.ZIndex = 5

local TabTitleIcon = Instance.new("ImageLabel", TabHeaderFrame)
TabTitleIcon.Name = "TabTitleIcon"
TabTitleIcon.Size = UDim2.new(0, 18, 0, 18)
TabTitleIcon.Position = UDim2.new(0, 0, 0.5, -9)
TabTitleIcon.BackgroundTransparency = 1
TabTitleIcon.Image = getIconAsset(SettingsIconID)
TabTitleIcon.ScaleType = Enum.ScaleType.Fit
TabTitleIcon.ZIndex = 6

local TabTitle = Instance.new("TextLabel", TabHeaderFrame)
TabTitle.Name = "TabTitle"
TabTitle.Text = "Settings"
TabTitle.Font = Enum.Font.SourceSansBold
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 24, 0, 0)
TabTitle.Size = UDim2.new(1, -24, 1, 0)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1
TabTitle.ZIndex = 6

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
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 12
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinBtn.BackgroundTransparency = 1
MinBtn.ZIndex = 11

local CloseBtn = Instance.new("TextButton", ControlsContainer)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(0, 30, 0, 0)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 22
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.BackgroundTransparency = 1
CloseBtn.ZIndex = 11

local SearchContainer = Instance.new("Frame", MainFrame)
SearchContainer.Size = UDim2.new(0, 160, 0, 30)
SearchContainer.Position = UDim2.new(1, -240, 0, 12)
SearchContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
ClearSearchBtn.Font = Enum.Font.SourceSansBold
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
SearchBox.Font = Enum.Font.SourceSansBold
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
HeaderBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
HubIcon.Image = getIconAsset(CustomIconID)

local HubTitle = Instance.new("TextLabel", HeaderBg)
HubTitle.Text = "Dark Hub"
HubTitle.Font = Enum.Font.SourceSansBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 13
HubTitle.Position = UDim2.new(0, 44, 0, 7)
HubTitle.Size = UDim2.new(0, 95, 0, 15)
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.BackgroundTransparency = 1
HubTitle.ZIndex = 5

local SubTitle = Instance.new("TextLabel", HeaderBg)
SubTitle.Text = "Settings Panel"
SubTitle.Font = Enum.Font.SourceSansBold
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
EmbMinBtn.Font = Enum.Font.SourceSansBold
EmbMinBtn.TextSize = 11
EmbMinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
EmbMinBtn.BackgroundTransparency = 1
EmbMinBtn.ZIndex = 7

local EmbCloseBtn = Instance.new("TextButton", EmbeddedControls)
EmbCloseBtn.Size = UDim2.new(0, 20, 0, 20)
EmbCloseBtn.Position = UDim2.new(0, 25, 0, 2)
EmbCloseBtn.Text = "×"
EmbCloseBtn.Font = Enum.Font.SourceSansBold
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
Navigation.ZIndex = 4

local NavLayout = Instance.new("UIListLayout", Navigation)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function UpdateNavCanvas()
    if Navigation and Navigation.Parent then
        Navigation.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 15)
    end
end
NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateNavCanvas)

local FooterBg = Instance.new("Frame", SidebarContainer)
FooterBg.Size = UDim2.new(0, 150, 0, 46)
FooterBg.Position = UDim2.new(0, 10, 1, -56)
FooterBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FooterBg.ZIndex = 4
Instance.new("UICorner", FooterBg).CornerRadius = UDim.new(0, 10)

local FooterStroke = Instance.new("UIStroke", FooterBg)
FooterStroke.Color = Color3.fromRGB(45, 45, 45)

local DiscordLabel = Instance.new("TextLabel", FooterBg)
DiscordLabel.Position = UDim2.new(0, 10, 0, 7)
DiscordLabel.Size = UDim2.new(1, -20, 0, 15)
DiscordLabel.Font = Enum.Font.SourceSansBold
DiscordLabel.Text = "discord.gg/pulsezone"
DiscordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordLabel.TextSize = 10
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.ZIndex = 5

local StatsLabel = Instance.new("TextLabel", FooterBg)
StatsLabel.Position = UDim2.new(0, 10, 0, 23)
StatsLabel.Size = UDim2.new(1, -20, 0, 15)
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.Text = "FPS: ... | Session: 00:00:00"
StatsLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.BackgroundTransparency = 1
StatsLabel.ZIndex = 5

local fpsBuffer = {}
local maxSamples = 30
local updateInterval = 0.15
local lastUpdateTime = 0
RunService.RenderStepped:Connect(function(dt)
    if not StatsLabel or not StatsLabel.Parent then
        return
    end
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
        for _, fps in ipairs(fpsBuffer) do
            sum = sum + fps
        end
        local averageFps = sum / math.max(#fpsBuffer, 1)
        local passedTime = CurrentTime - startTime
        StatsLabel.Text = string.format("FPS: %d | Session: %s", math.floor(averageFps + 0.5), formatSessionTime(passedTime))
    end
end)

local isMinimized = false
local LastMinimizedPos = UDim2.new(0.5, 0, 0.5, 0)
local function ToggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        PagesContainer.Visible, TabHeaderFrame.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = false, false, false, false, false, false
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
                if not isMinimized and MainFrame and MainFrame.Parent then
                    PagesContainer.Visible, TabHeaderFrame.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = true, true, true, true, true, true
                end
            end)
        end
    end
end

MinBtn.Activated:Connect(ToggleMinimize)
EmbMinBtn.Activated:Connect(ToggleMinimize)

local function CloseGui()
    if DarkHub and DarkHub.Parent then
        DarkHub:Destroy()
    end
end
CloseBtn.Activated:Connect(CloseGui)
EmbCloseBtn.Activated:Connect(CloseGui)

local function setupHeaderBtnHover(btn, normalColor, hoverColor)
    if not btn then return end
    btn.MouseEnter:Connect(function()
        tween(btn, {TextColor3 = hoverColor})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {TextColor3 = normalColor})
    end)
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
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
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
    if input == dragInput and dragToggle and MainFrame and MainFrame.Parent then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        MainFrame.Position = newPos
        LastMinimizedPos = newPos
    end
end)

-- ============================================================================
-- UI LIBRARY & THEMES (AMOLED FOCUSED)
-- ============================================================================
local Library = {}
Library.CurrentFontKey = "Source Sans"
Library.CurrentLanguage = "English"
Library.CurrentTabKey = "Settings"
Library.ActiveDropdownClose = nil
Library.TrackedMainBg = {}
Library.TrackedElementBg = {}
Library.TrackedAccents = {}
Library.TrackedMainText = {}
Library.TrackedSubText = {}
Library.TrackedStrokes = {}
Library.TrackedCheckboxes = {}
Library.TrackedSliderFills = {}
Library.TrackedSliderHandles = {}
Library.TrackedSliderTracks = {}
Library.TrackedScrollingFrames = {}
Library.TrackedDropdowns = {}
Library.TrackedButtons = {}
Library.TrackedToggles = {}
Library.TrackedSliders = {}

local ThemeConfig = {
    ["AMOLED"] = { Accent = Color3.fromRGB(255, 255, 255), MainBg = Color3.fromRGB(0, 0, 0), ElementBg = Color3.fromRGB(15, 15, 15) },
    ["Dark Knight"] = { Accent = Color3.fromRGB(180, 180, 180), MainBg = Color3.fromRGB(12, 12, 12), ElementBg = Color3.fromRGB(22, 22, 22) },
    ["Pure White"] = { Accent = Color3.fromRGB(0, 122, 255), MainBg = Color3.fromRGB(240, 240, 240), ElementBg = Color3.fromRGB(255, 255, 255) },
    ["Crimson Red"] = { Accent = Color3.fromRGB(255, 50, 50), MainBg = Color3.fromRGB(20, 10, 10), ElementBg = Color3.fromRGB(35, 15, 15) },
    ["Toxic Green"] = { Accent = Color3.fromRGB(50, 255, 50), MainBg = Color3.fromRGB(10, 20, 10), ElementBg = Color3.fromRGB(15, 35, 15) },
    ["Ocean Blue"] = { Accent = Color3.fromRGB(0, 150, 255), MainBg = Color3.fromRGB(10, 15, 25), ElementBg = Color3.fromRGB(20, 25, 40) },
    ["Neon Cyber"] = { Accent = Color3.fromRGB(0, 255, 255), MainBg = Color3.fromRGB(10, 10, 12), ElementBg = Color3.fromRGB(20, 20, 25) },
    ["Galaxy Purple"] = { Accent = Color3.fromRGB(138, 43, 226), MainBg = Color3.fromRGB(15, 10, 25), ElementBg = Color3.fromRGB(28, 18, 46) },
    ["Sunset Orange"] = { Accent = Color3.fromRGB(255, 140, 0), MainBg = Color3.fromRGB(25, 15, 5), ElementBg = Color3.fromRGB(40, 25, 10) },
    ["Mint Fresh"] = { Accent = Color3.fromRGB(0, 255, 170), MainBg = Color3.fromRGB(5, 20, 15), ElementBg = Color3.fromRGB(10, 35, 25) },
    ["Rose Gold"] = { Accent = Color3.fromRGB(255, 105, 180), MainBg = Color3.fromRGB(20, 10, 15), ElementBg = Color3.fromRGB(35, 18, 28) },
    ["Midnight Blue"] = { Accent = Color3.fromRGB(25, 25, 112), MainBg = Color3.fromRGB(5, 5, 20), ElementBg = Color3.fromRGB(12, 12, 35) },
    ["Lava Red"] = { Accent = Color3.fromRGB(255, 69, 0), MainBg = Color3.fromRGB(20, 5, 0), ElementBg = Color3.fromRGB(35, 10, 0) },
    ["Aqua Marine"] = { Accent = Color3.fromRGB(127, 255, 212), MainBg = Color3.fromRGB(5, 15, 15), ElementBg = Color3.fromRGB(10, 28, 28) },
    ["Golden Hour"] = { Accent = Color3.fromRGB(255, 215, 0), MainBg = Color3.fromRGB(20, 15, 0), ElementBg = Color3.fromRGB(35, 25, 0) }
}

local DefaultTheme = { Accent = Color3.fromRGB(255, 255, 255), MainBg = Color3.fromRGB(0, 0, 0), ElementBg = Color3.fromRGB(15, 15, 15) }
Library.CurrentThemeData = ThemeConfig["AMOLED"]

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

local function getThemeElementBg()
    if Library.CurrentThemeData and typeof(Library.CurrentThemeData.ElementBg) == "Color3" then
        return Library.CurrentThemeData.ElementBg
    end
    return DefaultTheme.ElementBg
end

-- ============================================================================
-- SLIDER IMPLEMENTATION (COMPLETED)
-- ============================================================================
function Library:CreateSlider(parentPage, textKey, min, max, default, callback)
    local initialText = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][textKey] or textKey
    local SldFrame = Instance.new("Frame", parentPage)
    SldFrame.Name = textKey
    SldFrame.Size = UDim2.new(1, -20, 0, 48)
    SldFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
    SldFrame.ZIndex = 6
    SldFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", SldFrame).CornerRadius = UDim.new(0, 6)
    local SldStroke = Instance.new("UIStroke", SldFrame)
    SldStroke.Color = Color3.fromRGB(35, 35, 35)
    table.insert(Library.TrackedElementBg, SldFrame)
    table.insert(Library.TrackedStrokes, SldStroke)

    local SldLabel = Instance.new("TextLabel", SldFrame)
    SldLabel.Size = UDim2.new(0.6, 0, 0, 20)
    SldLabel.Position = UDim2.new(0, 12, 0, 6)
    SldLabel.Text = initialText
    SldLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    SldLabel.TextSize = 13
    SldLabel.TextXAlignment = Enum.TextXAlignment.Left
    SldLabel.BackgroundTransparency = 1
    SldLabel.ZIndex = 7
    table.insert(Library.TrackedMainText, SldLabel)

    local ValLabel = Instance.new("TextLabel", SldFrame)
    ValLabel.Size = UDim2.new(0.35, 0, 0, 20)
    ValLabel.Position = UDim2.new(0.6, -12, 0, 6)
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.BackgroundTransparency = 1
    ValLabel.ZIndex = 7
    table.insert(Library.TrackedSubText, ValLabel)

    local Track = Instance.new("Frame", SldFrame)
    Track.Size = UDim2.new(1, -24, 0, 6)
    Track.Position = UDim2.new(0, 12, 1, -12)
    Track.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Track.ZIndex = 7
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    table.insert(Library.TrackedSliderTracks, Track)

    local initialPct = math.clamp((default - min) / (max - min), 0, 1)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(initialPct, 0, 1, 0)
    Fill.BackgroundColor3 = getThemeAccent()
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 8
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    table.insert(Library.TrackedSliderFills, Fill)

    local Handle = Instance.new("Frame", Fill)
    Handle.Size = UDim2.new(0, 12, 0, 12)
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.Position = UDim2.new(1, 0, 0.5, 0)
    Handle.BackgroundColor3 = getThemeAccent()
    Handle.ZIndex = 9
    Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)
    table.insert(Library.TrackedSliderHandles, Handle)

    local dragging = false
    local function update(input)
        local posX = input.Position.X - Track.AbsolutePosition.X
        local pct = math.clamp(posX / Track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pct + 0.5)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        ValLabel.Text = tostring(value)
        if type(callback) == "function" then
            pcall(callback, value)
        end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(Library.TrackedSliders, {
        Frame = SldFrame,
        Stroke = SldStroke,
        Label = SldLabel,
        ValueLabel = ValLabel
    })
end

showToast("Dark Hub loaded successfully!")
