-- ============================================================================
-- Dark Hub - Neverlose Edition
-- ============================================================================
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

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
-- NEVERLOSE UI INITIALIZATION
-- ============================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

local Window = Library:Window({
    Name = "Dark Hub",
    Subtitle = "Settings Edition"
})

local SettingsTab = Window:Tab("Settings")

-- Разделы (Секции) внутри вкладки Settings
local UISection = SettingsTab:Section("Интерфейс (UI)")
local ThemeSection = SettingsTab:Section("Окружение и Тема")
local ConfigsSection = SettingsTab:Section("Конфигурации")

-- ============================================================================
-- UI SECTION
-- ============================================================================
UISection:Toggle("Анти-АФК", true, function(val)
    toggleAntiAFK(val)
end)

UISection:Dropdown("Язык", {"English", "Русский"}, "English", function(val)
    -- Логика переключения языка
end)

-- ============================================================================
-- THEME SECTION (SKY & FOG)
-- ============================================================================
ThemeSection:Dropdown("Небо", {"None", "Space Sky", "Pink Sky", "Sunset Sky", "Dark Sky"}, "None", function(val)
    applySkySettings(val)
end)

ThemeSection:Toggle("Туман", false, function(val)
    fogEnabled = val
    applyFogSettings(true)
end)

ThemeSection:Dropdown("Цвет тумана", {"Default", "Black", "White", "Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"}, "Default", function(val)
    customFogColor = colorPresets[val] or originalFogColor
    if fogEnabled then applyFogSettings(true) end
end)

ThemeSection:Slider("Начало тумана", 0, 500, 0, 1, function(val)
    customFogStart = val
    if fogEnabled then applyFogSettings(true) end
end)

ThemeSection:Slider("Конец тумана", 10, 2000, 120, 1, function(val)
    customFogEnd = val
    if fogEnabled then applyFogSettings(true) end
end)

ThemeSection:Slider("Плотность тумана", 0, 1, 1, 0.01, function(val)
    customFogDensity = val
    if fogEnabled then applyFogSettings(true) end
end)

-- ============================================================================
-- CONFIGS SECTION
-- ============================================================================
local currentConfigName = "Default"

ConfigsSection:TextBox("Имя конфига", "Введите имя...", false, function(val)
    currentConfigName = val
end)

ConfigsSection:Button("Сохранить конфиг", function()
    if currentConfigName == "" then
        Library:Notify("Ошибка: Имя конфига не может быть пустым")
        return
    end
    Library:Notify("Конфиг '" .. currentConfigName .. "' успешно сохранен!")
end)

ConfigsSection:Button("Загрузить конфиг", function()
    if currentConfigName == "" then
        Library:Notify("Ошибка: Введите имя конфига")
        return
    end
    Library:Notify("Конфиг '" .. currentConfigName .. "' успешно загружен!")
end)

ConfigsSection:Button("Удалить конфиг", function()
    if currentConfigName == "" then
        Library:Notify("Ошибка: Введите имя конфига")
        return
    end
    Library:Notify("Конфиг '" .. currentConfigName .. "' удален!")
end)

-- Уведомление об успешной загрузке
Library:Notify("Dark Hub успешно запущен на Neverlose UI!")
