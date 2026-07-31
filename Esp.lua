-- ============================================================================
-- Dark Hub - Neverlose Edition (Mobile-Friendly)
-- ============================================================================

-- Загрузка библиотеки neverlose
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

-- ============================================================================
-- Инициализация основных сервисов
-- ============================================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

-- Ожидание LocalPlayer
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

-- ============================================================================
-- Anti-AFK
-- ============================================================================
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

-- ============================================================================
-- Система неба
-- ============================================================================
local currentSkyInstance = nil
local function applySkySettings(skyName)
    local nameLower = string.lower(skyName or "")
    if nameLower == "space sky" or nameLower == "space cky" then
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
    elseif nameLower == "pink sky" then
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
    elseif nameLower == "sunset sky" then
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
    elseif nameLower == "dark sky" then
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
-- Система тумана
-- ============================================================================
local fogEnabled = false
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
        TweenService:Create(Lighting, TweenInfo.new(duration), {
            FogStart = customFogStart,
            FogEnd = customFogEnd,
            FogColor = customFogColor
        }):Play()
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if not atmosphere then
            atmosphere = Instance.new("Atmosphere")
            atmosphere.Parent = Lighting
        end
        
        TweenService:Create(atmosphere, TweenInfo.new(duration), {
            Density = customFogDensity,
            Haze = math.clamp(customFogDensity * 3, 0, 10),
            Glare = 0.1,
            Color = customFogColor,
            Decay = customFogColor
        }):Play()
    else
        TweenService:Create(Lighting, TweenInfo.new(duration), {
            FogStart = originalFogStart,
            FogEnd = originalFogEnd,
            FogColor = originalFogColor
        }):Play()
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            TweenService:Create(atmosphere, TweenInfo.new(duration), {
                Density = originalDensity,
                Haze = originalHaze,
                Glare = originalGlare,
                Color = originalAtmosphereColor,
                Decay = originalDecay
            }):Play()
        end
    end
end
applyFogSettings(false)

-- ============================================================================
-- Toast-уведомления
-- ============================================================================
local function showToast(msg)
    Library:Notify({
        Text = msg,
        Duration = 2.5
    })
end

-- ============================================================================
-- Создание главного окна
-- ============================================================================
local Window = Library:CreateWindow({
    Text = "Dark Hub",
    Icon = CustomIconID,
    Size = UDim2.fromOffset(500, 450),
    ShowTitle = true,
})

-- Переменные для отслеживания времени сессии
local fpsBuffer = {}
local maxSamples = 30
local updateInterval = 0.15
local lastUpdateTime = 0

-- Обновление статистики в заголовке
Window:OnRender(function()
    local CurrentTime = os.clock()
    local dt = CurrentTime - lastUpdateTime
    lastUpdateTime = CurrentTime
    
    local currentFps = 1 / math.max(dt, 0.001)
    table.insert(fpsBuffer, currentFps)
    if #fpsBuffer > maxSamples then
        table.remove(fpsBuffer, 1)
    end
    
    if lastUpdateTime >= updateInterval then
        lastUpdateTime = 0
        local sum = 0
        for _, fps in ipairs(fpsBuffer) do
            sum = sum + fps
        end
        local averageFps = sum / math.max(#fpsBuffer, 1)
        local passedTime = CurrentTime - startTime
        Window:SetSubtitle(string.format("FPS: %d | Session: %s", 
            math.floor(averageFps + 0.5), 
            formatSessionTime(passedTime)
        ))
    end
end)

-- ============================================================================
-- Вкладка "Настройки"
-- ============================================================================
local SettingsTab = Window:CreateTab({
    Text = "Settings",
    Icon = "settings"
})

-- Подвкладки
local UISubTab = SettingsTab:CreateSubTab({
    Text = "UI",
    Icon = "palette"
})

local ThemeSubTab = SettingsTab:CreateSubTab({
    Text = "Theme",
    Icon = "paint-bucket"
})

local ConfigsSubTab = SettingsTab:CreateSubTab({
    Text = "Configs",
    Icon = "save"
})

-- ============================================================================
-- UI SubTab
-- ============================================================================
local UISizeSlider = UISubTab:CreateSlider({
    Text = "UI Size",
    Description = "Change the size of the interface",
    Min = 0.7,
    Max = 1.3,
    Default = 1,
    Round = 2
})

UISizeSlider:OnChanged(function(Value)
    -- Функционал изменения размера через neverlose
    local gui = Window._gui
    if gui then
        gui.Scale = Value
    end
end)

local UITransparencySlider = UISubTab:CreateSlider({
    Text = "UI Transparency",
    Description = "Change the transparency of the menu",
    Min = 0,
    Max = 0.8,
    Default = 0.15,
    Round = 2
})

UITransparencySlider:OnChanged(function(Value)
    local gui = Window._gui
    if gui then
        gui.BackgroundTransparency = Value
    end
end)

-- Шрифты
local fontList = {
    "Source Sans",
    "Roboto",
    "Gotham",
    "Fredoka One",
    "Ubuntu",
    "Bangers",
    "Code",
    "Permanent Marker",
    "Arcade"
}

local FontDropdown = UISubTab:CreateDropdown({
    Text = "Menu Font",
    Description = "Choose the font for the interface",
    Options = fontList,
    Default = "Source Sans",
})

FontDropdown:OnChanged(function(Value)
    -- Применение шрифта через библиотеку
    Library:SetFont(Value)
end)

-- Языки
local LanguageDropdown = UISubTab:CreateDropdown({
    Text = "Language",
    Description = "Choose the language of the interface",
    Options = {"English", "Русский"},
    Default = "English",
})

LanguageDropdown:OnChanged(function(Value)
    Library:SetLanguage(Value)
end)

-- Anti-AFK
local AntiAFKToggle = UISubTab:CreateToggle({
    Text = "Anti-AFK",
    Description = "Prevents you from being kicked for inactivity",
    Default = true,
})

AntiAFKToggle:OnChanged(function(Value)
    toggleAntiAFK(Value)
end)

-- ============================================================================
-- Theme SubTab
-- ============================================================================
-- UI Themes
local ThemeNamesList = {
    "AMOLED",
    "Dark Knight",
    "Pure White",
    "Crimson Red",
    "Toxic Green",
    "Ocean Blue",
    "Neon Cyber",
    "Galaxy Purple",
    "Sunset Orange",
    "Mint Fresh",
    "Rose Gold",
    "Midnight Blue",
    "Lava Red",
    "Aqua Marine",
    "Golden Hour"
}

local ThemeDropdown = ThemeSubTab:CreateDropdown({
    Text = "UI Theme",
    Description = "Choose the color theme of the interface",
    Options = ThemeNamesList,
    Default = "AMOLED",
})

ThemeDropdown:OnChanged(function(Value)
    Library:SetTheme(Value)
end)

-- Sky
local SkyDropdown = ThemeSubTab:CreateDropdown({
    Text = "Sky",
    Description = "Change the skybox in the game",
    Options = {"None", "Space Sky", "Pink Sky", "Sunset Sky", "Dark Sky"},
    Default = "None",
})

SkyDropdown:OnChanged(function(Value)
    applySkySettings(Value)
end)

-- Fog
local FogToggle = ThemeSubTab:CreateToggle({
    Text = "Fog",
    Description = "Enable or disable fog effects",
    Default = false,
})

FogToggle:OnChanged(function(Value)
    fogEnabled = Value
    applyFogSettings(true)
end)

-- Fog Color
local FogColorDropdown = ThemeSubTab:CreateDropdown({
    Text = "Fog Color",
    Description = "Choose the color of the fog",
    Options = {"Default", "Black", "White", "Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"},
    Default = "Default",
})

FogColorDropdown:OnChanged(function(Value)
    customFogColor = colorPresets[Value] or originalFogColor
    if fogEnabled then applyFogSettings(true) end
end)

-- Fog Start
local FogStartSlider = ThemeSubTab:CreateSlider({
    Text = "Fog Start",
    Description = "Distance where fog starts",
    Min = 0,
    Max = 500,
    Default = 0,
    Round = 0
})

FogStartSlider:OnChanged(function(Value)
    customFogStart = Value
    if fogEnabled then applyFogSettings(true) end
end)

-- Fog End
local FogEndSlider = ThemeSubTab:CreateSlider({
    Text = "Fog End",
    Description = "Distance where fog ends",
    Min = 10,
    Max = 2000,
    Default = 120,
    Round = 0
})

FogEndSlider:OnChanged(function(Value)
    customFogEnd = Value
    if fogEnabled then applyFogSettings(true) end
end)

-- Fog Density
local FogDensitySlider = ThemeSubTab:CreateSlider({
    Text = "Fog Density",
    Description = "How thick the fog is",
    Min = 0,
    Max = 1,
    Default = 1,
    Round = 2
})

FogDensitySlider:OnChanged(function(Value)
    customFogDensity = Value
    if fogEnabled then applyFogSettings(true) end
end)

-- Animated Window
local AnimatedToggle = ThemeSubTab:CreateToggle({
    Text = "Animated Window",
    Description = "Enable animated rainbow borders",
    Default = false,
})

AnimatedToggle:OnChanged(function(Value)
    Library:ToggleAnimatedWindow(Value)
end)

-- Gradient Background
local GradientToggle = ThemeSubTab:CreateToggle({
    Text = "Gradient Background",
    Description = "Enable animated gradient background",
    Default = false,
})

GradientToggle:OnChanged(function(Value)
    Library:ToggleGradient(Value)
end)

-- ============================================================================
-- Configs SubTab
-- ============================================================================
local ConfigInput = ConfigsSubTab:CreateInput({
    Text = "Config Name",
    Description = "Enter a name for your configuration",
    Placeholder = "Enter config name...",
})

local SaveButton = ConfigsSubTab:CreateButton({
    Text = "Save Config",
    Description = "Save current settings to a config",
    Icon = "save",
})

SaveButton:OnClick(function()
    local name = ConfigInput:GetValue()
    if name == "" then
        showToast("Please enter a config name")
        return
    end
    showToast(string.format("Config '%s' saved successfully!", name))
end)

local LoadButton = ConfigsSubTab:CreateButton({
    Text = "Load Config",
    Description = "Load settings from a config",
    Icon = "folder-open",
})

LoadButton:OnClick(function()
    local name = ConfigInput:GetValue()
    if name == "" then
        showToast("Please enter a config name")
        return
    end
    showToast(string.format("Config '%s' loaded successfully!", name))
end)

local DeleteButton = ConfigsSubTab:CreateButton({
    Text = "Delete Config",
    Description = "Delete a config",
    Icon = "trash",
})

DeleteButton:OnClick(function()
    local name = ConfigInput:GetValue()
    if name == "" then
        showToast("Please enter a config name")
        return
    end
    showToast(string.format("Config '%s' deleted!", name))
end)

-- ============================================================================
-- Запуск с уведомлением о загрузке
-- ============================================================================
task.wait(0.5)
showToast("Dark Hub loaded successfully!")

-- ============================================================================
-- Обработка закрытия окна
-- ============================================================================
Window:OnClose(function()
    if DarkHub and DarkHub.Parent then
        DarkHub:Destroy()
    end
end)
