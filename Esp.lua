-- Загружаем библиотеку Neverlose UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

-- ============================================================================
-- СЕРВИСЫ И ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================================================
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ============================================================================
-- ЛОГИКА ФУНКЦИЙ (Анти-АФК, Небо, Туман)
-- ============================================================================

-- [1] АНТИ-АФК
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

-- Включаем анти-афк по умолчанию
toggleAntiAFK(true)

-- [2] СИСТЕМА НЕБА
local currentSkyInstance = nil
local function applySkySettings(skyName)
    local nameLower = string.lower(skyName or "")
    
    if currentSkyInstance and currentSkyInstance.Parent then
        currentSkyInstance:Destroy()
        currentSkyInstance = nil
    end

    if nameLower == "default" then return end

    currentSkyInstance = Instance.new("Sky")
    currentSkyInstance.Name = "DarkHub_Sky"
    currentSkyInstance.Parent = Lighting

    if nameLower == "space sky" then
        currentSkyInstance.SkyboxBk = "rbxassetid://16262356578"
        currentSkyInstance.SkyboxDn = "rbxassetid://16262358026"
        currentSkyInstance.SkyboxFt = "rbxassetid://16262360469"
        currentSkyInstance.SkyboxLf = "rbxassetid://16262362003"
        currentSkyInstance.SkyboxRt = "rbxassetid://16262363873"
        currentSkyInstance.SkyboxUp = "rbxassetid://16262366016"
    elseif nameLower == "pink sky" then
        currentSkyInstance.SkyboxBk = "rbxassetid://271042516"
        currentSkyInstance.SkyboxDn = "rbxassetid://271077243"
        currentSkyInstance.SkyboxFt = "rbxassetid://271042556"
        currentSkyInstance.SkyboxLf = "rbxassetid://271042310"
        currentSkyInstance.SkyboxRt = "rbxassetid://271042467"
        currentSkyInstance.SkyboxUp = "rbxassetid://271077958"
    elseif nameLower == "sunset sky" then
        currentSkyInstance.SkyboxBk = "rbxassetid://169210090"
        currentSkyInstance.SkyboxDn = "rbxassetid://169210108"
        currentSkyInstance.SkyboxFt = "rbxassetid://169210121"
        currentSkyInstance.SkyboxLf = "rbxassetid://169210133"
        currentSkyInstance.SkyboxRt = "rbxassetid://169210143"
        currentSkyInstance.SkyboxUp = "rbxassetid://169210149"
    elseif nameLower == "dark sky" then
        currentSkyInstance.SkyboxBk = "rbxassetid://15470149279"
        currentSkyInstance.SkyboxDn = "rbxassetid://15470151245"
        currentSkyInstance.SkyboxFt = "rbxassetid://15470153860"
        currentSkyInstance.SkyboxLf = "rbxassetid://15470155938"
        currentSkyInstance.SkyboxRt = "rbxassetid://15470158022"
        currentSkyInstance.SkyboxUp = "rbxassetid://15470160563"
    end
end

-- [3] СИСТЕМА ТУМАНА
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

local function applyFogSettings(state)
    local duration = 0.4
    
    if state then
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

-- ============================================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА NEVERLOSE
-- ============================================================================

local Window = Library:Window({
    Title = "Dark Hub",
    Subtitle = "Settings Edition",
    Config = "DarkHub",
    Size = UDim2.new(0, 500, 0, 350) 
})

-- Создаем вкладки
local MainTab = Window:Tab("Main")
local EnvTab = Window:Tab("Environment")

-- [Вкладка: Main]
local MiscSection = MainTab:Section("Misc Settings")

MiscSection:Toggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(state)
        toggleAntiAFK(state)
    end
})

-- [Вкладка: Environment]
local SkySection = EnvTab:Section("World Sky")

SkySection:Dropdown({
    Name = "Select Sky",
    Options = {"Default", "Space Sky", "Pink Sky", "Sunset Sky", "Dark Sky"},
    Default = "Default",
    Callback = function(selectedSky)
        applySkySettings(selectedSky)
    end
})

local FogSection = EnvTab:Section("World Fog")

FogSection:Toggle({
    Name = "Custom Fog",
    Default = false,
    Callback = function(state)
        applyFogSettings(state)
    end
})

-- Уведомление об успешной загрузке
Library:Notification({
    Title = "Dark Hub",
    Content = "Скрипт успешно запущен на Neverlose UI!",
    Duration = 3
})
