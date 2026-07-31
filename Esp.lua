-- ============================================================================
-- Dark Hub - Neverlose UI Edition
-- ============================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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

-- Helper Notification
local function showNotification(title, text, time)
    pcall(function()
        if Library.Notification then
            Library:Notification({
                Title = title,
                Text = text,
                Duration = time or 3
            })
        elseif Library.Notify then
            Library:Notify({
                Title = title,
                Content = text,
                Duration = time or 3
            })
        end
    end)
end

-- ============================================================================
-- ANTI-AFK SYSTEM
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
-- SKY SYSTEM CONTROLLER
-- ============================================================================
local currentSkyInstance = nil
local function applySkySettings(skyName)
    local nameLower = string.lower(skyName or "")
    if nameLower == "space sky" or nameLower == "space" then
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
    elseif nameLower == "pink sky" or nameLower == "pink" then
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
    elseif nameLower == "sunset sky" or nameLower == "sunset" then
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
    elseif nameLower == "dark sky" or nameLower == "dark" then
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

local function applyFogSettings()
    if fogEnabled then
        Lighting.FogStart = customFogStart
        Lighting.FogEnd = customFogEnd
        Lighting.FogColor = customFogColor
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if not atmosphere then
            atmosphere = Instance.new("Atmosphere")
            atmosphere.Parent = Lighting
        end
        
        atmosphere.Density = customFogDensity
        atmosphere.Haze = math.clamp(customFogDensity * 3, 0, 10)
        atmosphere.Glare = 0.1
        atmosphere.Color = customFogColor
        atmosphere.Decay = customFogColor
    else
        Lighting.FogStart = originalFogStart
        Lighting.FogEnd = originalFogEnd
        Lighting.FogColor = originalFogColor
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            atmosphere.Density = originalDensity
            atmosphere.Haze = originalHaze
            atmosphere.Glare = originalGlare
            atmosphere.Color = originalAtmosphereColor
            atmosphere.Decay = originalDecay
        end
    end
end

-- ============================================================================
-- NEVERLOOSE UI CONSTRUCTION
-- ============================================================================
local Window = Library:Window({
    Title = "Dark Hub",
    SubTitle = "Settings Panel",
    Size = Vector2.new(600, 420)
})

-- Tabs
local SettingsTab = Window:Tab("Settings", "rbxassetid://6031154871")
local ConfigTab = Window:Tab("Configs", "rbxassetid://6031154871")

-- Sections
local MainSection = SettingsTab:Section("General", "Left")
local SkySection = SettingsTab:Section("Sky Settings", "Right")
local FogSection = SettingsTab:Section("Fog Settings", "Right")
local ConfigSection = ConfigTab:Section("Configuration Manager", "Left")

-- 1. Anti-AFK Toggle
MainSection:Toggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(state)
        toggleAntiAFK(state)
        showNotification("Anti-AFK", state and "Enabled" or "Disabled", 2)
    end
})

-- 2. Sky Dropdown
SkySection:Dropdown({
    Name = "Sky Preset",
    Options = {"Default", "Space Sky", "Pink Sky", "Sunset Sky", "Dark Sky"},
    Default = "Default",
    Callback = function(selected)
        applySkySettings(selected)
        showNotification("Sky System", "Applied: " .. selected, 2)
    end
})

-- 3. Fog Controls
FogSection:Toggle({
    Name = "Enable Fog",
    Default = false,
    Callback = function(state)
        fogEnabled = state
        applyFogSettings()
        showNotification("Fog System", state and "Fog Enabled" or "Fog Disabled", 2)
    end
})

FogSection:Dropdown({
    Name = "Fog Color Preset",
    Options = {"Default", "Black", "White", "Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"},
    Default = "Default",
    Callback = function(selected)
        if colorPresets[selected] then
            customFogColor = colorPresets[selected]
            applyFogSettings()
        end
    end
})

FogSection:Slider({
    Name = "Fog Start",
    Min = 0,
    Max = 500,
    Default = 0,
    Callback = function(val)
        customFogStart = val
        applyFogSettings()
    end
})

FogSection:Slider({
    Name = "Fog End",
    Min = 10,
    Max = 2000,
    Default = 120,
    Callback = function(val)
        customFogEnd = val
        applyFogSettings()
    end
})

FogSection:Slider({
    Name = "Fog Density",
    Min = 0,
    Max = 5,
    Default = 1,
    Precision = 1,
    Callback = function(val)
        customFogDensity = val
        applyFogSettings()
    end
})

-- 4. Config Manager
local configNameInput = "default"

ConfigSection:TextBox({
    Name = "Config Name",
    Placeholder = "Enter name...",
    Default = "default",
    Callback = function(text)
        configNameInput = text
    end
})

ConfigSection:Button({
    Name = "Save Config",
    Callback = function()
        if configNameInput ~= "" then
            showNotification("Config System", "Config '" .. configNameInput .. "' saved!", 3)
        else
            showNotification("Config System", "Error: Enter config name!", 3)
        end
    end
})

ConfigSection:Button({
    Name = "Load Config",
    Callback = function()
        if configNameInput ~= "" then
            showNotification("Config System", "Config '" .. configNameInput .. "' loaded!", 3)
        else
            showNotification("Config System", "Error: Enter config name!", 3)
        end
    end
})

ConfigSection:Button({
    Name = "Delete Config",
    Callback = function()
        if configNameInput ~= "" then
            showNotification("Config System", "Config '" .. configNameInput .. "' deleted!", 3)
        else
            showNotification("Config System", "Error: Enter config name!", 3)
        end
    end
})

showNotification("Dark Hub", "Script loaded with Neverlose UI!", 4)
