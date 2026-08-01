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
local AmoledImageID = "77553474353001"
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
local currentSkyName = "None"
local function applySkySettings(skyName)
    currentSkyName = skyName
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
-- CHARACTER EFFECT CONTROLLER (WINGS AURA & MODELS)
-- ============================================================================
local currentEffectModel = nil
local currentEffectName = "None"

local EFFECT_MODELS = {
    ["wings aura"] = "114522534858071"
}

local BODY_PART_NAMES = {
    ["torso"] = true, ["uppertorso"] = true, ["lowertorso"] = true,
    ["humanoidrootpart"] = true, ["head"] = true, ["humanoid"] = true,
    ["left arm"] = true, ["right arm"] = true, ["left leg"] = true, ["right leg"] = true,
    ["leftupperarm"] = true, ["rightupperarm"] = true, ["leftlowerarm"] = true, ["rightlowerarm"] = true,
    ["lefthand"] = true, ["righthand"] = true, ["leftupperleg"] = true, ["rightupperleg"] = true,
    ["leftlowerleg"] = true, ["rightlowerleg"] = true, ["leftfoot"] = true, ["rightfoot"] = true,
    ["root"] = true, ["baseplate"] = true, ["camera"] = true
}

local function removeCurrentEffect()
    if currentEffectModel and currentEffectModel.Parent then
        currentEffectModel:Destroy()
    end
    currentEffectModel = nil
    if LocalPlayer.Character then
        for _, child in ipairs(LocalPlayer.Character:GetChildren()) do
            if child.Name:sub(1, 15) == "DarkHub_Effect_" then
                child:Destroy()
            end
        end
    end
end

local function applyPlayerEffect(effectName)
    removeCurrentEffect()
    currentEffectName = effectName

    if not effectName or effectName == "None" or not EFFECT_MODELS[effectName] then
        return
    end

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char then return end

    local hum = char:WaitForChild("Humanoid", 5)
    local root = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    if not root or not hum then return end

    local modelId = EFFECT_MODELS[effectName]
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. modelId)
    end)

    if success and objects and #objects > 0 then
        local effectContainer = Instance.new("Model")
        effectContainer.Name = "DarkHub_Effect_" .. effectName

        for _, obj in ipairs(objects) do
            obj.Parent = effectContainer
        end

        for _, desc in ipairs(effectContainer:GetDescendants()) do
            if desc:IsA("Humanoid") or desc:IsA("Animator") or desc:IsA("Script") or desc:IsA("LocalScript") then
                desc:Destroy()
            elseif desc:IsA("BasePart") then
                desc.CanCollide = false
                desc.CanTouch = false
                desc.CanQuery = false
                desc.Massless = true
                desc.Anchored = false

                local lowerName = desc.Name:lower()
                if BODY_PART_NAMES[lowerName] then
                    desc.Transparency = 1
                end
            end
        end

        local primary = nil
        for _, desc in ipairs(effectContainer:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Transparency < 1 then
                primary = desc
                break
            end
        end

        if not primary then
            for _, desc in ipairs(effectContainer:GetDescendants()) do
                if desc:IsA("BasePart") then
                    primary = desc
                    break
                end
            end
        end

        if primary then
            effectContainer.Parent = char
            currentEffectModel = effectContainer

            primary.CFrame = root.CFrame

            local mainWeld = Instance.new("WeldConstraint")
            mainWeld.Part0 = root
            mainWeld.Part1 = primary
            mainWeld.Parent = primary

            for _, part in ipairs(effectContainer:GetDescendants()) do
                if part:IsA("BasePart") and part ~= primary then
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = primary
                    w.Part1 = part
                    w.Parent = part
                end
            end

            showToast("Effect applied: " .. effectName)
        else
            effectContainer:Destroy()
            showToast("No valid effect parts found!")
        end
    else
        showToast("Failed to load effect model!")
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if currentEffectName and currentEffectName ~= "None" then
        applyPlayerEffect(currentEffectName)
    end
end)

-- ============================================================================
-- LOADING SCREEN (AMOLED)
-- ============================================================================
local LoadingOverlay = Instance.new("Frame", DarkHub)
LoadingOverlay.Name = "LoadingOverlay"
LoadingOverlay.Size = UDim2.new(0, 280, 0, 195)
LoadingOverlay.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingOverlay.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingOverlay.BackgroundTransparency = 0
LoadingOverlay.ZIndex = 999
LoadingOverlay.ClipsDescendants = true

local OverlayCorner = Instance.new("UICorner", LoadingOverlay)
OverlayCorner.CornerRadius = UDim.new(0, 14)

local OverlayStroke = Instance.new("UIStroke", LoadingOverlay)
OverlayStroke.Color = Color3.fromRGB(255, 255, 255)
OverlayStroke.Thickness = 1
OverlayStroke.Transparency = 0.35

local LoadingIcon = Instance.new("ImageLabel", LoadingOverlay)
LoadingIcon.Name = "LoadingIcon"
LoadingIcon.Size = UDim2.new(0, 52, 0, 52)
LoadingIcon.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingIcon.Position = UDim2.new(0.5, 0, 0.23, 0)
LoadingIcon.BackgroundTransparency = 1
LoadingIcon.Image = "rbxassetid://" .. CustomIconID
LoadingIcon.ScaleType = Enum.ScaleType.Fit
LoadingIcon.ZIndex = 1001

local IconCorner = Instance.new("UICorner", LoadingIcon)
IconCorner.CornerRadius = UDim.new(1, 0)

local LoadingStatus = Instance.new("TextLabel", LoadingOverlay)
LoadingStatus.Name = "LoadingStatus"
LoadingStatus.Size = UDim2.new(1, -20, 0, 20)
LoadingStatus.Position = UDim2.new(0, 10, 0.46, 0)
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Text = "ЗАГРУЗКА ИНТЕРФЕЙСА"
LoadingStatus.Font = Enum.Font.SourceSansBold
LoadingStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingStatus.TextSize = 11
LoadingStatus.ZIndex = 1001

local LoadingPercent = Instance.new("TextLabel", LoadingOverlay)
LoadingPercent.Name = "LoadingPercent"
LoadingPercent.Size = UDim2.new(1, 0, 0, 26)
LoadingPercent.Position = UDim2.new(0, 0, 0.58, 0)
LoadingPercent.BackgroundTransparency = 1
LoadingPercent.Text = "0%"
LoadingPercent.Font = Enum.Font.SourceSansBold
LoadingPercent.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingPercent.TextSize = 22
LoadingPercent.ZIndex = 1001

local ProgressBarBg = Instance.new("Frame", LoadingOverlay)
ProgressBarBg.Name = "ProgressBarBg"
ProgressBarBg.Size = UDim2.new(0.85, 0, 0, 10)
ProgressBarBg.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressBarBg.Position = UDim2.new(0.5, 0, 0.80, 0)
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ProgressBarBg.BorderSizePixel = 0
ProgressBarBg.ZIndex = 1001

local BarCorner = Instance.new("UICorner", ProgressBarBg)
BarCorner.CornerRadius = UDim.new(1, 0)

local BarStroke = Instance.new("UIStroke", ProgressBarBg)
BarStroke.Color = Color3.fromRGB(50, 50, 50)
BarStroke.Thickness = 1

local ProgressBarFill = Instance.new("Frame", ProgressBarBg)
ProgressBarFill.Name = "ProgressBarFill"
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.ZIndex = 1002

local FillCorner = Instance.new("UICorner", ProgressBarFill)
FillCorner.CornerRadius = UDim.new(1, 0)

local FillGradient = Instance.new("UIGradient", ProgressBarFill)
FillGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
})

local Bubbles = {}
local bubbleCount = 12

for i = 1, bubbleCount do
    local bubble = Instance.new("Frame", LoadingOverlay)
    bubble.Name = "Bubble_" .. i
    bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bubble.BorderSizePixel = 0
    bubble.ZIndex = 998
    
    local size = math.random(4, 12)
    bubble.Size = UDim2.new(0, size, 0, size)
    
    local corner = Instance.new("UICorner", bubble)
    corner.CornerRadius = UDim.new(1, 0)
    
    local startX = math.random(10, 270)
    local startY = math.random(20, 180)
    
    table.insert(Bubbles, {
        Object = bubble,
        X = startX,
        Y = startY,
        BaseX = startX,
        SpeedY = math.random(18, 42),
        WobbleSpeed = math.random(2, 5),
        WobbleAmount = math.random(6, 18),
        Size = size,
        Seed = math.random() * 100,
        MaxAlpha = math.random(20, 50) / 100
    })
end

local bubbleConnection = RunService.RenderStepped:Connect(function(dt)
    local time = os.clock()
    if FillGradient then
        FillGradient.Rotation = (time * 120) % 360
    end
    for _, b in ipairs(Bubbles) do
        if b.Object and b.Object.Parent then
            b.Y = b.Y - b.SpeedY * dt
            b.X = b.BaseX + math.sin(time * b.WobbleSpeed + b.Seed) * b.WobbleAmount
            if b.Y < -15 then
                b.Y = 200
                b.BaseX = math.random(10, 270)
                b.SpeedY = math.random(18, 42)
            end
            local progress = math.clamp(b.Y / 195, 0, 1)
            local alpha = math.sin(progress * math.pi) * b.MaxAlpha
            b.Object.BackgroundTransparency = 1 - alpha
            b.Object.Position = UDim2.new(0, b.X, 0, b.Y)
        end
    end
end)

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
MainFrame.Visible = false
MainFrame.ClipsDescendants = true

-- Фоновое изображение для AMOLED (Безопасная загрузка)
local AmoledBgImage = Instance.new("ImageLabel", MainFrame)
AmoledBgImage.Name = "AmoledBgImage"
AmoledBgImage.Size = UDim2.new(1, 0, 1, 0)
AmoledBgImage.Position = UDim2.new(0, 0, 0, 0)
AmoledBgImage.BackgroundTransparency = 1
AmoledBgImage.Image = "rbxassetid://" .. AmoledImageID
AmoledBgImage.ScaleType = Enum.ScaleType.Crop
AmoledBgImage.ZIndex = 1
AmoledBgImage.ImageTransparency = 0.2
AmoledBgImage.Visible = true
Instance.new("UICorner", AmoledBgImage).CornerRadius = UDim.new(0, 14)

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

local TabTitle = Instance.new("TextLabel", MainFrame)
TabTitle.Text = "Settings"
TabTitle.Font = Enum.Font.SourceSansBold
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTitle.TextSize = 16
TabTitle.Position = UDim2.new(0, 185, 0, 18)
TabTitle.Size = UDim2.new(0, 200, 0, 20)
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.BackgroundTransparency = 1
TabTitle.ZIndex = 5

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
HubIcon.Image = "rbxassetid://" .. CustomIconID

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
                if not isMinimized and MainFrame and MainFrame.Parent then
                    PagesContainer.Visible, TabTitle.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = true, true, true, true, true, true
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
Library.CurrentThemeName = "AMOLED"
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

-- ============================================================================
-- LIBRARY UTILITIES & THEMING
-- ============================================================================
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
for name, _ in pairs(ThemeConfig) do
    table.insert(ThemeNamesList, name)
end
table.sort(ThemeNamesList)

local allTabs = {}
local allTabButtons = {}
local allTabIcons = {}
local allPages = {}
local currentActiveTab = nil
local currentHoveredTab = nil
local SubTabNav = nil
local subPages = {}
local subTabButtons = {}
local uiGradientInstance = nil

local function applyHover(button)
    if not button or typeof(button) ~= "Instance" or not button.Parent then return end
    local parentContainer = button.Parent
    if not parentContainer or typeof(parentContainer) ~= "Instance" or not parentContainer.Parent then return end
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
    local hoverBg = isL and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35)
    local hoverText = isL and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
    tween(parentContainer, {BackgroundColor3 = hoverBg, BackgroundTransparency = 0.5}, 0.18)
    tween(stroke, {Transparency = 0.5}, 0.18)
    tween(button, {TextColor3 = hoverText}, 0.18)
end

local function removeHover(button)
    if not button or typeof(button) ~= "Instance" or not button.Parent then return end
    local parentContainer = button.Parent
    if not parentContainer or typeof(parentContainer) ~= "Instance" then return end
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

local function applyThemeToTabs(theme)
    theme = theme or Library.CurrentThemeData or DefaultTheme
    local mainBg = (theme and typeof(theme.MainBg) == "Color3") and theme.MainBg or DefaultTheme.MainBg
    local accent = (theme and typeof(theme.Accent) == "Color3") and theme.Accent or DefaultTheme.Accent
    local isLightMode = isLightColor(mainBg)
    local activeTextColor = isLightMode and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
    local inactiveTextColor = isLightMode and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
    local activeBgColor = isLightMode and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(25, 25, 25)
    for textKey, tabBtn in pairs(allTabButtons) do
        if tabBtn and typeof(tabBtn) == "Instance" and tabBtn.Parent then
            local parentContainer = tabBtn.Parent
            if parentContainer and typeof(parentContainer) == "Instance" then
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
                else
                    tween(tabBtn, {TextColor3 = inactiveTextColor}, 0.2)
                    if currentHoveredTab ~= tabBtn then
                        tween(parentContainer, {BackgroundTransparency = 1}, 0.2)
                    end
                    if indicator then
                        indicator:Destroy()
                    end
                end
                if hoverStroke then
                    tween(hoverStroke, {Color = accent}, 0.2)
                end
            end
        end
    end
end

function Library:UpdateTheme(themeName)
    local theme = ThemeConfig[themeName] or DefaultTheme
    Library.CurrentThemeData = theme
    Library.CurrentThemeName = themeName

    if AmoledBgImage then
        if string.upper(tostring(themeName)) == "AMOLED" then
            AmoledBgImage.Visible = true
            AmoledBgImage.ImageTransparency = 0.2
        else
            AmoledBgImage.Visible = false
        end
    end

    local mainBg = getThemeMainBg()
    local accent = getThemeAccent()
    local elementBg = getThemeElementBg()
    local isLightMode = isLightColor(mainBg)
    local mainTextColor = isLightMode and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(255, 255, 255)
    local subTextColor = isLightMode and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(140, 140, 140)
    local strokeColor = isLightMode and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(35, 35, 35)
    local scrollBarColor = isLightMode and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(50, 50, 50)
    local offToggleColor = isLightMode and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35)
    local sliderTrackColor = isLightMode and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(30, 30, 30)
    
    for _, obj in ipairs(Library.TrackedMainBg) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {BackgroundColor3 = mainBg})
        end
    end
    
    for _, obj in ipairs(Library.TrackedElementBg) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {BackgroundColor3 = elementBg})
        end
    end
    
    for _, obj in ipairs(Library.TrackedStrokes) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {Color = strokeColor})
        end
    end
    
    for _, obj in ipairs(Library.TrackedMainText) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {TextColor3 = mainTextColor})
            if obj:IsA("TextBox") then
                obj.PlaceholderColor3 = subTextColor
            end
        end
    end
    
    for _, obj in ipairs(Library.TrackedSubText) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {TextColor3 = subTextColor})
        end
    end
    
    for _, obj in ipairs(Library.TrackedAccents) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {TextColor3 = accent})
        end
    end
    
    for _, tglData in ipairs(Library.TrackedCheckboxes) do
        if tglData.Checkbox and tglData.Checkbox.Parent then
            if not tglData.GetState() then
                tween(tglData.Checkbox, {BackgroundColor3 = offToggleColor})
                tween(tglData.Indicator, {BackgroundColor3 = accent})
            else
                tween(tglData.Checkbox, {BackgroundColor3 = accent})
                tween(tglData.Indicator, {BackgroundColor3 = mainBg})
            end
        end
    end
    
    for _, obj in ipairs(Library.TrackedSliderFills) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {BackgroundColor3 = accent})
        end
    end
    for _, obj in ipairs(Library.TrackedSliderHandles) do
        if obj and typeof(obj) == "Instance" and obj.Parent then
            tween(obj, {BackgroundColor3 = accent})
        end
    end
    
    for _, track in ipairs(Library.TrackedSliderTracks) do
        if track and track.Parent then
            tween(track, {BackgroundColor3 = sliderTrackColor})
        end
    end
    
    for _, sf in ipairs(Library.TrackedScrollingFrames) do
        if sf and sf.Parent then
            sf.ScrollBarImageColor3 = scrollBarColor
        end
    end
    
    for _, dropdownData in ipairs(Library.TrackedDropdowns) do
        if dropdownData.Frame and dropdownData.Frame.Parent then
            tween(dropdownData.Frame, {BackgroundColor3 = elementBg})
        end
        if dropdownData.Stroke and dropdownData.Stroke.Parent then
            tween(dropdownData.Stroke, {Color = strokeColor})
        end
        if dropdownData.TitleLabel and dropdownData.TitleLabel.Parent then
            tween(dropdownData.TitleLabel, {TextColor3 = mainTextColor})
        end
        if dropdownData.SelectedLabel and dropdownData.SelectedLabel.Parent then
            tween(dropdownData.SelectedLabel, {TextColor3 = accent})
        end
        if dropdownData.OptionsContainer and dropdownData.OptionsContainer.Parent then
            dropdownData.OptionsContainer.ScrollBarImageColor3 = scrollBarColor
            for _, optBtn in ipairs(dropdownData.OptionsContainer:GetChildren()) do
                if optBtn:IsA("TextButton") then
                    local optLabel = optBtn:FindFirstChildOfClass("TextLabel")
                    if optLabel then
                        tween(optLabel, {TextColor3 = subTextColor})
                    end
                end
            end
        end
    end
    
    for _, btnData in ipairs(Library.TrackedButtons) do
        if btnData.Button and btnData.Button.Parent then
            tween(btnData.Button, {BackgroundColor3 = elementBg, TextColor3 = mainTextColor})
        end
        if btnData.Stroke and btnData.Stroke.Parent then
            tween(btnData.Stroke, {Color = strokeColor})
        end
    end
    
    for _, tglData in ipairs(Library.TrackedToggles) do
        if tglData.Frame and tglData.Frame.Parent then
            tween(tglData.Frame, {BackgroundColor3 = elementBg})
        end
        if tglData.Stroke and tglData.Stroke.Parent then
            tween(tglData.Stroke, {Color = strokeColor})
        end
        if tglData.Label and tglData.Label.Parent then
            tween(tglData.Label, {TextColor3 = mainTextColor})
        end
    end
    
    for _, sldData in ipairs(Library.TrackedSliders) do
        if sldData.Frame and sldData.Frame.Parent then
            tween(sldData.Frame, {BackgroundColor3 = elementBg})
        end
        if sldData.Stroke and sldData.Stroke.Parent then
            tween(sldData.Stroke, {Color = strokeColor})
        end
        if sldData.Label and sldData.Label.Parent then
            tween(sldData.Label, {TextColor3 = mainTextColor})
        end
        if sldData.ValueLabel and sldData.ValueLabel.Parent then
            tween(sldData.ValueLabel, {TextColor3 = subTextColor})
        end
    end
    
    applyThemeToTabs(theme)
    
    if SubTabNav and SubTabNav.Parent then
        tween(SubTabNav, {BackgroundColor3 = elementBg})
    end
    
    for name, b in pairs(subTabButtons) do
        local isActive = subPages[name] and subPages[name].Visible
        tween(b, {TextColor3 = isActive and accent or subTextColor}, 0.2)
        local pill = b.Parent:FindFirstChild("Pill")
        if pill then
            tween(pill, {BackgroundColor3 = isActive and accent or Color3.fromRGB(30,30,30)}, 0.2)
        end
    end

    if uiGradientInstance and uiGradientInstance.Parent then
        uiGradientInstance.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, mainBg),
            ColorSequenceKeypoint.new(0.5, accent),
            ColorSequenceKeypoint.new(1, mainBg)
        })
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
        ["Settings"] = "Settings",
        ["UI"] = "UI",
        ["Theme"] = "Theme",
        ["Configs"] = "Configs",
        ["UISize"] = "UI Size",
        ["UITransparency"] = "UI Transparency",
        ["MenuFont"] = "Menu Font",
        ["Language"] = "Language",
        ["AntiAFK"] = "Anti-AFK",
        ["UITheme"] = "UI Theme",
        ["Sky"] = "Sky",
        ["Fog"] = "Fog",
        ["FogColor"] = "Fog Color",
        ["FogStart"] = "Fog Start",
        ["FogEnd"] = "Fog End",
        ["FogDensity"] = "Fog Density",
        ["AnimatedWindow"] = "Animated Window",
        ["Gradient"] = "Gradient Background",
        ["Configurations"] = "Configurations",
        ["ConfigName"] = "Config Name",
        ["Save"] = "Save Config",
        ["Load"] = "Load Config",
        ["Delete"] = "Delete Config",
        ["FOV"] = "Field of View",
        ["effect"] = "Effect",
        ["wings aura"] = "Wings Aura",
        ["ConfigEmptyError"] = "Error: Config name cannot be empty",
        ["PleaseEnterName"] = "Please enter a config name",
        ["PleaseSelectName"] = "Please select or enter a config name",
        ["ConfigSaved"] = "Config '%s' saved successfully!",
        ["ConfigSaveFailed"] = "Failed to save config '%s'",
        ["ConfigNotFound"] = "Config '%s' not found",
        ["ConfigLoadFailed"] = "Failed to load config '%s'",
        ["ConfigLoaded"] = "Config '%s' loaded successfully!",
        ["ConfigDeleted"] = "Config '%s' deleted!",
        ["ConfigDeleteFailed"] = "Failed to delete config '%s'",
        ["HubLoaded"] = "Dark Hub loaded successfully!"
    },
    ["Русский"] = {
        ["Settings"] = "Настройки",
        ["UI"] = "Интерфейс",
        ["Theme"] = "Тема",
        ["Configs"] = "Конфиги",
        ["UISize"] = "Размер интерфейса",
        ["UITransparency"] = "Прозрачность меню",
        ["MenuFont"] = "Шрифт меню",
        ["Language"] = "Язык",
        ["AntiAFK"] = "Анти-АФК",
        ["UITheme"] = "Тема UI",
        ["Sky"] = "Небо",
        ["Fog"] = "Туман",
        ["FogColor"] = "Цвет тумана",
        ["FogStart"] = "Начало тумана",
        ["FogEnd"] = "Конец тумана",
        ["FogDensity"] = "Плотность тумана",
        ["AnimatedWindow"] = "Анимированное окно",
        ["Gradient"] = "Градиентный фон",
        ["Configurations"] = "Конфигурации",
        ["ConfigName"] = "Имя конфига",
        ["Save"] = "Сохранить конфиг",
        ["Load"] = "Загрузить конфиг",
        ["Delete"] = "Удалить конфиг",
        ["FOV"] = "Угол обзора",
        ["effect"] = "Эффект",
        ["wings aura"] = "Крылья аура",
        ["ConfigEmptyError"] = "Ошибка: Имя конфига не может быть пустым",
        ["PleaseEnterName"] = "Пожалуйста, введите имя конфига",
        ["PleaseSelectName"] = "Выберите или введите имя конфига",
        ["ConfigSaved"] = "Конфиг '%s' успешно сохранен!",
        ["ConfigSaveFailed"] = "Не удалось сохранить конфиг '%s'",
        ["ConfigNotFound"] = "Конфиг '%s' не найден",
        ["ConfigLoadFailed"] = "Не удалось загрузить конфиг '%s'",
        ["ConfigLoaded"] = "Конфиг '%s' успешно загружен!",
        ["ConfigDeleted"] = "Конфиг '%s' удален!",
        ["ConfigDeleteFailed"] = "Не удалось удалить конфиг '%s'",
        ["HubLoaded"] = "Dark Hub успешно запущен!"
    }
}

local UniversalSupportedFonts = {
    ["Fredoka One"] = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Gotham"] = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Gotham Bold"] = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
    ["Source Sans"] = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Roboto"] = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Code"] = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Ubuntu"] = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Bangers"] = Font.new("rbxasset://fonts/families/Bangers.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Luckiest Guy"] = Font.new("rbxasset://fonts/families/LuckiestGuy.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Permanent Marker"] = Font.new("rbxasset://fonts/families/PermanentMarker.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    ["Arcade"] = Font.new("rbxasset://fonts/families/Arcade.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
}

local FontMapping = {
    ["Fredoka One"] = { Enum = Enum.Font.FredokaOne },
    ["Gotham"] = { Enum = Enum.Font.Gotham },
    ["Gotham Bold"] = { Enum = Enum.Font.GothamBold },
    ["Source Sans"] = { Enum = Enum.Font.SourceSans },
    ["Roboto"] = { Enum = Enum.Font.Roboto },
    ["Code"] = { Enum = Enum.Font.Code },
    ["Ubuntu"] = { Enum = Enum.Font.Ubuntu },
    ["Bangers"] = { Enum = Enum.Font.Bangers },
    ["Luckiest Guy"] = { Enum = Enum.Font.LuckiestGuy },
    ["Permanent Marker"] = { Enum = Enum.Font.PermanentMarker },
    ["Arcade"] = { Enum = Enum.Font.Arcade }
}

local function applyFontToElement(obj)
    if not obj or not obj.Parent then return end
    local fontKey = Library.CurrentFontKey or "Source Sans"
    local fontData = FontMapping[fontKey] or FontMapping["Source Sans"]
    local universalFontFace = UniversalSupportedFonts[fontKey] or UniversalSupportedFonts["Source Sans"]
    pcall(function()
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.FontFace = universalFontFace
            obj.Font = fontData.Enum
        end
    end)
end

local function applyFontToAll(fontKey)
    Library.CurrentFontKey = fontKey
    local fontData = FontMapping[fontKey] or FontMapping["Source Sans"]
    local universalFontFace = UniversalSupportedFonts[fontKey] or UniversalSupportedFonts["Source Sans"]

    local function recursiveApply(parent)
        for _, child in ipairs(parent:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                pcall(function()
                    child.FontFace = universalFontFace
                    child.Font = fontData.Enum
                end)
            end
        end
    end

    if DarkHub and DarkHub.Parent then
        recursiveApply(DarkHub)
    end
end

function Library:UpdateLanguage(lang)
    if not Localization[lang] then return end
    Library.CurrentLanguage = lang
    
    for _, loc in ipairs(LocaleObjects) do
        if loc.Object and typeof(loc.Object) == "Instance" and loc.Object.Parent then
            local newText = Localization[lang][loc.Key] or loc.Key
            loc.Object.Text = newText
            if loc.SearchItem then
                loc.SearchItem.SearchText = NormalizeText(newText)
            end
        end
    end
    
    if SearchBox then
        SearchBox.PlaceholderText = (lang == "Русский") and "Поиск..." or "Search..."
    end
    
    applyFontToAll(Library.CurrentFontKey)
end

local animatedWindowConnection = nil
local function toggleAnimatedWindow(state)
    if state then
        if not animatedWindowConnection then
            animatedWindowConnection = RunService.RenderStepped:Connect(function()
                local hue = (os.clock() * 0.15) % 1
                local rainbowColor = Color3.fromHSV(hue, 0.6, 1)
                for _, stroke in ipairs(Library.TrackedStrokes) do
                    if stroke and typeof(stroke) == "Instance" and stroke.Parent then
                        stroke.Color = rainbowColor
                    end
                end
            end)
        end
    else
        if animatedWindowConnection then
            animatedWindowConnection:Disconnect()
            animatedWindowConnection = nil
            local strokeColor = isLightColor(getThemeMainBg()) and Color3.fromRGB(190, 190, 190) or Color3.fromRGB(35, 35, 35)
            for _, stroke in ipairs(Library.TrackedStrokes) do
                if stroke and typeof(stroke) == "Instance" and stroke.Parent then
                    stroke.Color = strokeColor
                end
            end
        end
    end
end

local gradientRotateConnection = nil
local function toggleGradientEffect(state)
    if state then
        if not uiGradientInstance or typeof(uiGradientInstance) ~= "Instance" or not uiGradientInstance.Parent then
            uiGradientInstance = Instance.new("UIGradient")
            uiGradientInstance.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, getThemeMainBg()),
                ColorSequenceKeypoint.new(0.5, getThemeAccent()),
                ColorSequenceKeypoint.new(1, getThemeMainBg())
            })
            uiGradientInstance.Parent = MainFrame
        end
        if not gradientRotateConnection then
            gradientRotateConnection = RunService.RenderStepped:Connect(function()
                if uiGradientInstance and typeof(uiGradientInstance) == "Instance" and uiGradientInstance.Parent then
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
table.insert(Library.TrackedScrollingFrames, SearchResultsPage)

local searchLayout = Instance.new("UIListLayout", SearchResultsPage)
searchLayout.Padding = UDim.new(0, 8)
searchLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
searchLayout.SortOrder = Enum.SortOrder.LayoutOrder

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local rawText = SearchBox.Text
    local query = NormalizeText(rawText)
    ClearSearchBtn.Visible = (rawText ~= "")
    if rawText == "" then
        SearchResultsPage.Visible = false
        for _, item in ipairs(SearchableElements) do
            if item.Instance and typeof(item.Instance) == "Instance" and item.OriginalParent and typeof(item.OriginalParent) == "Instance" and item.OriginalParent.Parent then
                item.Instance.Parent = item.OriginalParent
                item.Instance.Visible = true
            end
        end
        if allPages[Library.CurrentTabKey] and typeof(allPages[Library.CurrentTabKey]) == "Instance" and allPages[Library.CurrentTabKey].Parent then
            allPages[Library.CurrentTabKey].Visible = true
        end
    else
        for _, page in pairs(allPages) do
            if page and typeof(page) == "Instance" and page.Parent then
                page.Visible = false
            end
        end
        SearchResultsPage.Visible = true
        for _, item in ipairs(SearchableElements) do
            if item.Instance and typeof(item.Instance) == "Instance" and item.Instance.Parent then
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

ClearSearchBtn.Activated:Connect(function()
    SearchBox.Text = ""
end)

-- ============================================================================
-- INTERFACE BUILDER METHODS
-- ============================================================================
function Library:CreateDropdown(parentPage, textKey, options, default, callback)
    local initialText = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][textKey] or textKey
    local DropdownFrame = Instance.new("Frame", parentPage)
    DropdownFrame.Name = textKey
    DropdownFrame.Size = UDim2.new(1, -20, 0, 36)
    DropdownFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.ZIndex = 6
    DropdownFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)
    local DropdownStroke = Instance.new("UIStroke", DropdownFrame)
    DropdownStroke.Color = Color3.fromRGB(35, 35, 35)
    DropdownStroke.Thickness = 1
    table.insert(Library.TrackedElementBg, DropdownFrame)
    table.insert(Library.TrackedStrokes, DropdownStroke)

    local HeaderBtn = Instance.new("TextButton", DropdownFrame)
    HeaderBtn.Name = "HeaderBtn"
    HeaderBtn.Size = UDim2.new(1, 0, 0, 36)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.ZIndex = 7

    local TitleLabel = Instance.new("TextLabel", HeaderBtn)
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0.45, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Text = initialText
    applyFontToElement(TitleLabel)
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 8
    table.insert(Library.TrackedMainText, TitleLabel)

    local SelectedLabel = Instance.new("TextLabel", HeaderBtn)
    SelectedLabel.Name = "SelectedLabel"
    SelectedLabel.Size = UDim2.new(0.55, -35, 1, 0)
    SelectedLabel.Position = UDim2.new(0.45, 0, 0, 0)
    SelectedLabel.Text = default
    applyFontToElement(SelectedLabel)
    SelectedLabel.TextColor3 = getThemeAccent()
    SelectedLabel.TextSize = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.ZIndex = 8
    table.insert(Library.TrackedAccents, SelectedLabel)

    local Arrow = Instance.new("TextLabel", HeaderBtn)
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Text = "v"
    applyFontToElement(Arrow)
    Arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    Arrow.TextSize = 10
    Arrow.BackgroundTransparency = 1
    Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    Arrow.Position = UDim2.new(1, -16, 0.5, 0)
    Arrow.ZIndex = 8
    table.insert(Library.TrackedSubText, Arrow)

    local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame)
    OptionsContainer.Name = "OptionsContainer"
    OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
    OptionsContainer.Position = UDim2.new(0, 0, 0, 36)
    OptionsContainer.BackgroundTransparency = 1
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.ScrollBarThickness = 3
    OptionsContainer.ZIndex = 8
    OptionsContainer.ClipsDescendants = true
    OptionsContainer.Visible = false
    table.insert(Library.TrackedScrollingFrames, OptionsContainer)

    local ListLayout = Instance.new("UIListLayout", OptionsContainer)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local isExpanded = false
    local function toggleDropdown()
        if not DropdownFrame or not DropdownFrame.Parent then return end
        isExpanded = not isExpanded
        local currentOptionsCount = #options
        local contentHeight = math.min(currentOptionsCount * 32, 140)
        if isExpanded then
            if Library.ActiveDropdownClose and Library.ActiveDropdownClose ~= toggleDropdown then
                pcall(Library.ActiveDropdownClose)
            end
            Library.ActiveDropdownClose = toggleDropdown
            OptionsContainer.Visible = true
            OptionsContainer.Size = UDim2.new(1, 0, 0, contentHeight)
            tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, 36 + contentHeight + 4)}, 0.2)
            tween(Arrow, {Rotation = 180}, 0.2)
        else
            if Library.ActiveDropdownClose == toggleDropdown then
                Library.ActiveDropdownClose = nil
            end
            tween(Arrow, {Rotation = 0}, 0.2)
            local closeTween = tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, 36)}, 0.2)
            if closeTween then
                closeTween.Completed:Connect(function()
                    if not isExpanded and OptionsContainer and OptionsContainer.Parent then
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
        if SelectedLabel and SelectedLabel.Parent then
            SelectedLabel.Text = option
        end
        if type(callback) == "function" then
            local success, err = pcall(callback, option)
            if not success then
                warn("[Dark Hub Error in Dropdown Callback]:", err)
            end
        end
    end

    local function populateOptions(newOptions)
        options = newOptions
        for _, child in ipairs(OptionsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for i, option in ipairs(options) do
            local OptBtn = Instance.new("TextButton", OptionsContainer)
            OptBtn.Size = UDim2.new(1, 0, 0, 32)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = ""
            OptBtn.LayoutOrder = i
            OptBtn.ZIndex = 9

            local OptLabel = Instance.new("TextLabel", OptBtn)
            OptLabel.Size = UDim2.new(1, -20, 1, 0)
            OptLabel.Position = UDim2.new(0, 16, 0, 0)
            OptLabel.Text = option
            applyFontToElement(OptLabel)
            
            local isL = isLightColor(getThemeMainBg())
            OptLabel.TextColor3 = isL and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(180, 180, 180)
            OptLabel.TextSize = 12
            OptLabel.TextXAlignment = Enum.TextXAlignment.Left
            OptLabel.BackgroundTransparency = 1
            OptLabel.ZIndex = 10
            table.insert(Library.TrackedSubText, OptLabel)

            OptBtn.MouseEnter:Connect(function()
                local mainIsL = isLightColor(getThemeMainBg())
                local hoverBg = mainIsL and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(30, 30, 30)
                tween(OptBtn, {BackgroundColor3 = hoverBg, BackgroundTransparency = 0.5}, 0.15)
            end)
            OptBtn.MouseLeave:Connect(function()
                tween(OptBtn, {BackgroundTransparency = 1}, 0.15)
            end)

            OptBtn.Activated:Connect(function()
                selectValue(option)
                toggleDropdown()
            end)
        end
    end
    populateOptions(options)

    table.insert(Library.TrackedDropdowns, {
        Frame = DropdownFrame,
        Stroke = DropdownStroke,
        TitleLabel = TitleLabel,
        SelectedLabel = SelectedLabel,
        OptionsContainer = OptionsContainer
    })

    local searchItem = {Instance = DropdownFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = TitleLabel, Key = textKey, SearchItem = searchItem})

    return {
        SetValue = function(val) selectValue(val) end,
        GetValue = function() return SelectedLabel and SelectedLabel.Text or "" end,
        UpdateOptions = function(newOpts) populateOptions(newOpts) end
    }
end

function Library:CreateButton(parentPage, textKey, callback)
    local initialText = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][textKey] or textKey
    local Btn = Instance.new("TextButton", parentPage)
    Btn.Name = textKey
    Btn.Size = UDim2.new(1, -20, 0, 36)
    Btn.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
    Btn.Text = initialText
    applyFontToElement(Btn)
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.TextSize = 13
    Btn.ClipsDescendants = true
    Btn.ZIndex = 6
    Btn.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Color3.fromRGB(35, 35, 35)
    table.insert(Library.TrackedElementBg, Btn)
    table.insert(Library.TrackedMainText, Btn)
    table.insert(Library.TrackedStrokes, BtnStroke)
    
    table.insert(Library.TrackedButtons, {
        Button = Btn,
        Stroke = BtnStroke
    })
    
    Btn.MouseButton1Down:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        spawnWave(Btn, mousePos.X - Btn.AbsolutePosition.X, (mousePos.Y - inset.Y) - Btn.AbsolutePosition.Y)
    end)
    Btn.Activated:Connect(function()
        if type(callback) == "function" then
            pcall(callback)
        end
    end)
    local searchItem = {Instance = Btn, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = Btn, Key = textKey, SearchItem = searchItem})
end

function Library:CreateToggle(parentPage, textKey, default, callback)
    local initialText = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][textKey] or textKey
    local TglFrame = Instance.new("Frame", parentPage)
    TglFrame.Name = textKey
    TglFrame.Size = UDim2.new(1, -20, 0, 36)
    TglFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
    TglFrame.ZIndex = 6
    TglFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
    local TglStroke = Instance.new("UIStroke", TglFrame)
    TglStroke.Color = Color3.fromRGB(35, 35, 35)
    table.insert(Library.TrackedElementBg, TglFrame)
    table.insert(Library.TrackedStrokes, TglStroke)

    local TglLabel = Instance.new("TextLabel", TglFrame)
    TglLabel.Size = UDim2.new(1, -60, 1, 0)
    TglLabel.Position = UDim2.new(0, 12, 0, 0)
    TglLabel.Text = initialText
    applyFontToElement(TglLabel)
    TglLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TglLabel.TextSize = 13
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left
    TglLabel.BackgroundTransparency = 1
    TglLabel.ZIndex = 7
    table.insert(Library.TrackedMainText, TglLabel)

    local Checkbox = Instance.new("TextButton", TglFrame)
    Checkbox.Size = UDim2.new(0, 34, 0, 18)
    Checkbox.Position = UDim2.new(1, -44, 0.5, -9)
    Checkbox.BackgroundColor3 = default and getThemeAccent() or (isLightColor(getThemeMainBg()) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35))
    Checkbox.Text = ""
    Checkbox.ZIndex = 7
    Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 9)

    local Indicator = Instance.new("Frame", Checkbox)
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Indicator.BackgroundColor3 = default and getThemeMainBg() or getThemeAccent()
    Indicator.ZIndex = 8
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local enabled = default
    local toggleData = {
        Checkbox = Checkbox,
        Indicator = Indicator,
        GetState = function() return enabled end
    }
    table.insert(Library.TrackedCheckboxes, toggleData)
    
    table.insert(Library.TrackedToggles, {
        Frame = TglFrame,
        Stroke = TglStroke,
        Label = TglLabel
    })

    local function setToggleState(state)
        enabled = state
        local mainBg = getThemeMainBg()
        if enabled then
            tween(Checkbox, {BackgroundColor3 = getThemeAccent()}, 0.2)
            tween(Indicator, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = mainBg}, 0.2)
        else
            local isL = isLightColor(mainBg)
            local offColor = isL and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35)
            tween(Checkbox, {BackgroundColor3 = offColor}, 0.2)
            tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = getThemeAccent()}, 0.2)
        end
        if type(callback) == "function" then
            pcall(callback, enabled)
        end
    end
    Checkbox.Activated:Connect(function()
        setToggleState(not enabled)
    end)

    local searchItem = {Instance = TglFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = TglLabel, Key = textKey, SearchItem = searchItem})

    return {
        SetValue = function(state) setToggleState(state) end,
        GetValue = function() return enabled end
    }
end

function Library:CreateSlider(parentPage, textKey, min, max, default, callback)
    local initialText = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][textKey] or textKey
    local SldFrame = Instance.new("Frame", parentPage)
    SldFrame.Name = textKey
    SldFrame.Size = UDim2.new(1, -20, 0, 50)
    SldFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
    SldFrame.ZIndex = 6
    SldFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", SldFrame).CornerRadius = UDim.new(0, 6)
    
    local SldStroke = Instance.new("UIStroke", SldFrame)
    SldStroke.Color = Color3.fromRGB(35, 35, 35)
    SldStroke.Thickness = 1
    table.insert(Library.TrackedElementBg, SldFrame)
    table.insert(Library.TrackedStrokes, SldStroke)

    local SldLabel = Instance.new("TextLabel", SldFrame)
    SldLabel.Size = UDim2.new(0.6, 0, 0, 22)
    SldLabel.Position = UDim2.new(0, 12, 0, 4)
    SldLabel.Text = initialText
    applyFontToElement(SldLabel)
    SldLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    SldLabel.TextSize = 13
    SldLabel.TextXAlignment = Enum.TextXAlignment.Left
    SldLabel.BackgroundTransparency = 1
    SldLabel.ZIndex = 7
    table.insert(Library.TrackedMainText, SldLabel)

    local ValueLabel = Instance.new("TextLabel", SldFrame)
    ValueLabel.Size = UDim2.new(0.35, 0, 0, 22)
    ValueLabel.Position = UDim2.new(0.6, -12, 0, 4)
    ValueLabel.Text = tostring(default)
    applyFontToElement(ValueLabel)
    ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.ZIndex = 7
    table.insert(Library.TrackedSubText, ValueLabel)

    local SliderTrack = Instance.new("Frame", SldFrame)
    SliderTrack.Size = UDim2.new(1, -24, 0, 6)
    SliderTrack.Position = UDim2.new(0, 12, 0, 32)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.ZIndex = 7
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)
    table.insert(Library.TrackedSliderTracks, SliderTrack)

    local valPct = math.clamp((default - min) / (max - min), 0, 1)

    local SliderFill = Instance.new("Frame", SliderTrack)
    SliderFill.Size = UDim2.new(valPct, 0, 1, 0)
    SliderFill.BackgroundColor3 = getThemeAccent()
    SliderFill.BorderSizePixel = 0
    SliderFill.ZIndex = 8
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    table.insert(Library.TrackedSliderFills, SliderFill)

    local SliderHandle = Instance.new("Frame", SliderTrack)
    SliderHandle.Size = UDim2.new(0, 12, 0, 12)
    SliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderHandle.Position = UDim2.new(valPct, 0, 0.5, 0)
    SliderHandle.BackgroundColor3 = getThemeAccent()
    SliderHandle.BorderSizePixel = 0
    SliderHandle.ZIndex = 9
    Instance.new("UICorner", SliderHandle).CornerRadius = UDim.new(1, 0)
    table.insert(Library.TrackedSliderHandles, SliderHandle)

    local isDragging = false
    local currentValue = default

    local function updateValueFromInput(input)
        local posX = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        local rawVal = min + (max - min) * posX
        local val = math.floor(rawVal * 100 + 0.5) / 100
        if math.abs(max - min) >= 10 and math.floor(min) == min and math.floor(max) == max then
            val = math.floor(rawVal + 0.5)
        end
        currentValue = val
        ValueLabel.Text = tostring(val)
        SliderFill.Size = UDim2.new(posX, 0, 1, 0)
        SliderHandle.Position = UDim2.new(posX, 0, 0.5, 0)
        if type(callback) == "function" then
            pcall(callback, val)
        end
    end

    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateValueFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValueFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    table.insert(Library.TrackedSliders, {
        Frame = SldFrame,
        Stroke = SldStroke,
        Label = SldLabel,
        ValueLabel = ValueLabel
    })

    local searchItem = {Instance = SldFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = SldLabel, Key = textKey, SearchItem = searchItem})

    return {
        SetValue = function(val)
            val = math.clamp(val, min, max)
            local pct = (val - min) / (max - min)
            currentValue = val
            ValueLabel.Text = tostring(val)
            SliderFill.Size = UDim2.new(pct, 0, 1, 0)
            SliderHandle.Position = UDim2.new(pct, 0, 0.5, 0)
            if type(callback) == "function" then
                pcall(callback, val)
            end
        end,
        GetValue = function() return currentValue end
    }
end

function Library:CreateInput(parentPage, textKey, placeholderText, callback)
    local initialText = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][textKey] or textKey
    local InpFrame = Instance.new("Frame", parentPage)
    InpFrame.Name = textKey
    InpFrame.Size = UDim2.new(1, -20, 0, 36)
    InpFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
    InpFrame.ZIndex = 6
    InpFrame.LayoutOrder = #parentPage:GetChildren()
    Instance.new("UICorner", InpFrame).CornerRadius = UDim.new(0, 6)
    local InpStroke = Instance.new("UIStroke", InpFrame)
    InpStroke.Color = Color3.fromRGB(35, 35, 35)
    InpStroke.Thickness = 1
    table.insert(Library.TrackedElementBg, InpFrame)
    table.insert(Library.TrackedStrokes, InpStroke)

    local InpLabel = Instance.new("TextLabel", InpFrame)
    InpLabel.Size = UDim2.new(0.45, 0, 1, 0)
    InpLabel.Position = UDim2.new(0, 12, 0, 0)
    InpLabel.Text = initialText
    applyFontToElement(InpLabel)
    InpLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    InpLabel.TextSize = 13
    InpLabel.TextXAlignment = Enum.TextXAlignment.Left
    InpLabel.BackgroundTransparency = 1
    InpLabel.ZIndex = 7
    table.insert(Library.TrackedMainText, InpLabel)

    local BoxContainer = Instance.new("Frame", InpFrame)
    BoxContainer.Size = UDim2.new(0.5, 0, 0, 24)
    BoxContainer.Position = UDim2.new(0.48, 0, 0.5, -12)
    BoxContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    BoxContainer.ZIndex = 7
    Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 4)
    local BoxStroke = Instance.new("UIStroke", BoxContainer)
    BoxStroke.Color = Color3.fromRGB(35, 35, 35)

    local InputBox = Instance.new("TextBox", BoxContainer)
    InputBox.Size = UDim2.new(1, -12, 1, 0)
    InputBox.Position = UDim2.new(0, 6, 0, 0)
    InputBox.BackgroundTransparency = 1
    InputBox.Text = ""
    InputBox.PlaceholderText = placeholderText or ""
    applyFontToElement(InputBox)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    InputBox.TextSize = 12
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.ZIndex = 8
    table.insert(Library.TrackedMainText, InputBox)

    InputBox.FocusLost:Connect(function(enterPressed)
        if type(callback) == "function" then
            pcall(callback, InputBox.Text, enterPressed)
        end
    end)

    local searchItem = {Instance = InpFrame, SearchText = NormalizeText(initialText), OriginalParent = parentPage}
    table.insert(SearchableElements, searchItem)
    table.insert(LocaleObjects, {Object = InpLabel, Key = textKey, SearchItem = searchItem})

    return {
        GetValue = function() return InputBox.Text end,
        SetValue = function(txt) InputBox.Text = txt end
    }
end

-- ============================================================================
-- MAIN TAB & SUB-TAB SYSTEM CREATOR
-- ============================================================================
function Library:CreateTab(nameKey, iconId)
    local tabName = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][nameKey] or nameKey
    
    local TabContainer = Instance.new("Frame", Navigation)
    TabContainer.Name = nameKey .. "_Container"
    TabContainer.Size = UDim2.new(1, 0, 0, 32)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ZIndex = 5
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 6)

    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Name = nameKey .. "_Btn"
    TabBtn.Size = UDim2.new(1, 0, 1, 0)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = tabName
    applyFontToElement(TabBtn)
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Position = UDim2.new(0, 34, 0, 0)
    TabBtn.ZIndex = 6

    local TabIcon = Instance.new("ImageLabel", TabContainer)
    TabIcon.Name = "Icon"
    TabIcon.Size = UDim2.new(0, 16, 0, 16)
    TabIcon.Position = UDim2.new(0, 10, 0.5, -8)
    TabIcon.BackgroundTransparency = 1
    TabIcon.ZIndex = 6
    if iconId and iconId ~= "" then
        TabIcon.Image = "rbxassetid://" .. iconId
    else
        TabIcon.Image = "rbxassetid://" .. CustomIconID
    end

    local MainPage = Instance.new("Frame", PagesContainer)
    MainPage.Name = nameKey .. "_Page"
    MainPage.Size = UDim2.new(1, 0, 1, 0)
    MainPage.BackgroundTransparency = 1
    MainPage.Visible = false
    MainPage.ZIndex = 5

    allTabs[nameKey] = MainPage
    allTabButtons[nameKey] = TabBtn
    allTabIcons[nameKey] = TabIcon
    allPages[nameKey] = MainPage

    local SubNavFrame = Instance.new("Frame", MainPage)
    SubNavFrame.Name = "SubTabNav"
    SubNavFrame.Size = UDim2.new(1, -10, 0, 30)
    SubNavFrame.Position = UDim2.new(0, 0, 0, 0)
    SubNavFrame.BackgroundColor3 = Library.CurrentThemeData.ElementBg or DefaultTheme.ElementBg
    SubNavFrame.ZIndex = 6
    Instance.new("UICorner", SubNavFrame).CornerRadius = UDim.new(0, 6)
    local SubNavStroke = Instance.new("UIStroke", SubNavFrame)
    SubNavStroke.Color = Color3.fromRGB(35, 35, 35)
    SubNavStroke.Thickness = 1
    table.insert(Library.TrackedElementBg, SubNavFrame)
    table.insert(Library.TrackedStrokes, SubNavStroke)
    SubTabNav = SubNavFrame

    local SubNavLayout = Instance.new("UIListLayout", SubNavFrame)
    SubNavLayout.FillDirection = Enum.FillDirection.Horizontal
    SubNavLayout.Padding = UDim.new(0, 6)
    SubNavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    SubNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local SubPadding = Instance.new("UIPadding", SubNavFrame)
    SubPadding.PaddingLeft = UDim.new(0, 6)

    local SubPagesContainer = Instance.new("Frame", MainPage)
    SubPagesContainer.Name = "SubPagesContainer"
    SubPagesContainer.Size = UDim2.new(1, 0, 1, -38)
    SubPagesContainer.Position = UDim2.new(0, 0, 0, 38)
    SubPagesContainer.BackgroundTransparency = 1
    SubPagesContainer.ZIndex = 5

    local function SwitchTab()
        for k, page in pairs(allPages) do
            page.Visible = false
        end
        MainPage.Visible = true
        currentActiveTab = TabBtn
        Library.CurrentTabKey = nameKey
        TabTitle.Text = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][nameKey] or nameKey
        applyThemeToTabs(Library.CurrentThemeData)
    end

    TabBtn.Activated:Connect(SwitchTab)
    TabBtn.MouseEnter:Connect(function()
        if TabBtn ~= currentActiveTab then
            currentHoveredTab = TabBtn
            applyHover(TabBtn)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if TabBtn ~= currentActiveTab then
            currentHoveredTab = nil
            removeHover(TabBtn)
        end
    end)

    table.insert(LocaleObjects, {Object = TabBtn, Key = nameKey})

    return {
        Page = MainPage,
        SubPagesContainer = SubPagesContainer,
        SubNavFrame = SubNavFrame,
        SwitchTab = SwitchTab
    }
end

function Library:CreateSubTab(tabObj, subNameKey)
    local subName = Localization[Library.CurrentLanguage] and Localization[Library.CurrentLanguage][subNameKey] or subNameKey
    
    local SubBtnFrame = Instance.new("Frame", tabObj.SubNavFrame)
    SubBtnFrame.Name = subNameKey .. "_NavFrame"
    SubBtnFrame.Size = UDim2.new(0, 75, 0, 22)
    SubBtnFrame.BackgroundTransparency = 1
    SubBtnFrame.ZIndex = 7

    local SubBtn = Instance.new("TextButton", SubBtnFrame)
    SubBtn.Name = subNameKey .. "_SubBtn"
    SubBtn.Size = UDim2.new(1, 0, 1, 0)
    SubBtn.BackgroundTransparency = 1
    SubBtn.Text = subName
    applyFontToElement(SubBtn)
    SubBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    SubBtn.TextSize = 11
    SubBtn.ZIndex = 8

    local Pill = Instance.new("Frame", SubBtnFrame)
    Pill.Name = "Pill"
    Pill.Size = UDim2.new(1, 0, 0, 2)
    Pill.Position = UDim2.new(0, 0, 1, -2)
    Pill.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Pill.BorderSizePixel = 0
    Pill.ZIndex = 8
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

    local SubPage = Instance.new("ScrollingFrame", tabObj.SubPagesContainer)
    SubPage.Name = subNameKey .. "_SubPage"
    SubPage.Size = UDim2.new(1, 0, 1, 0)
    SubPage.BackgroundTransparency = 1
    SubPage.Visible = false
    SubPage.ScrollBarThickness = 2
    SubPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    SubPage.BorderSizePixel = 0
    SubPage.ZIndex = 6
    table.insert(Library.TrackedScrollingFrames, SubPage)

    local SubPageLayout = Instance.new("UIListLayout", SubPage)
    SubPageLayout.Padding = UDim.new(0, 6)
    SubPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SubPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local function UpdateSubPageCanvas()
        if SubPage and SubPage.Parent then
            SubPage.CanvasSize = UDim2.new(0, 0, 0, SubPageLayout.AbsoluteContentSize.Y + 20)
        end
    end
    SubPageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSubPageCanvas)

    subPages[subNameKey] = SubPage
    subTabButtons[subNameKey] = SubBtn

    local function ActivateSubTab()
        for sKey, page in pairs(subPages) do
            page.Visible = false
        end
        for sKey, btn in pairs(subTabButtons) do
            tween(btn, {TextColor3 = Color3.fromRGB(140, 140, 140)}, 0.2)
            local p = btn.Parent:FindFirstChild("Pill")
            if p then
                tween(p, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.2)
            end
        end
        SubPage.Visible = true
        tween(SubBtn, {TextColor3 = getThemeAccent()}, 0.2)
        tween(Pill, {BackgroundColor3 = getThemeAccent()}, 0.2)
    end

    SubBtn.Activated:Connect(ActivateSubTab)
    table.insert(LocaleObjects, {Object = SubBtn, Key = subNameKey})

    return SubPage, ActivateSubTab
end

-- ============================================================================
-- CONFIG MANAGEMENT SYSTEM
-- ============================================================================
local FOLDER_PATH = "DarkHub"
local CONFIG_FOLDER = "DarkHub/Configs"

local function ensureFolders()
    if makefolder and isfolder then
        pcall(function()
            if not isfolder(FOLDER_PATH) then makefolder(FOLDER_PATH) end
            if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        end)
    end
end
ensureFolders()

local currentConfigName = ""

local function saveConfig(name)
    if not name or name == "" then
        showToast(Localization[Library.CurrentLanguage]["PleaseEnterName"] or "Please enter a config name")
        return
    end
    ensureFolders()
    local data = {
        Theme = Library.CurrentThemeName or "AMOLED",
        Font = Library.CurrentFontKey or "Source Sans",
        Language = Library.CurrentLanguage or "English",
        UISize = MainScale.Scale,
        UITransparency = MainFrame.BackgroundTransparency,
        AntiAFK = (antiAfkConnection ~= nil),
        AnimatedWindow = (animatedWindowConnection ~= nil),
        Gradient = (gradientRotateConnection ~= nil),
        Sky = currentSkyName or "None",
        Fog = fogEnabled,
        FogStart = customFogStart,
        FogEnd = customFogEnd,
        FogDensity = customFogDensity,
        Effect = currentEffectName or "None"
    }
    
    if writefile then
        local json = HttpService:JSONEncode(data)
        writefile(CONFIG_FOLDER .. "/" .. name .. ".json", json)
        showToast(string.format(Localization[Library.CurrentLanguage]["ConfigSaved"] or "Config '%s' saved!", name))
    end
end

local function listConfigs()
    ensureFolders()
    local files = {}
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(CONFIG_FOLDER)) do
                if file:sub(-5) == ".json" then
                    local filename = file:match("([^/]+)%.json$") or file:match("([^\\]+)%.json$")
                    if filename then
                        table.insert(files, filename)
                    end
                end
            end
        end)
    end
    return files
end

-- Initialize Dark Hub Navigation & Settings Page Construction
local SettingsTab = Library:CreateTab("Settings", CustomIconID)
local UISubPage, activateUI = Library:CreateSubTab(SettingsTab, "UI")
local ThemeSubPage, activateTheme = Library:CreateSubTab(SettingsTab, "Theme")
local ConfigsSubPage, activateConfigs = Library:CreateSubTab(SettingsTab, "Configs")

-- Setup UI Subpage Elements
Library:CreateSlider(UISubPage, "UISize", 0.5, 1.5, 1, function(val)
    MainScale.Scale = val
end)

Library:CreateSlider(UISubPage, "UITransparency", 0, 0.8, 0.15, function(val)
    MainFrame.BackgroundTransparency = val
end)

Library:CreateDropdown(UISubPage, "MenuFont", {"Source Sans", "Gotham", "Gotham Bold", "Roboto", "Code", "Ubuntu", "Fredoka One", "Bangers", "Luckiest Guy", "Permanent Marker", "Arcade"}, "Source Sans", function(selectedFont)
    applyFontToAll(selectedFont)
end)

Library:CreateDropdown(UISubPage, "Language", {"English", "Русский"}, "English", function(selectedLang)
    Library:UpdateLanguage(selectedLang)
end)

Library:CreateToggle(UISubPage, "AntiAFK", true, function(state)
    toggleAntiAFK(state)
end)

-- Setup Theme Subpage Elements
Library:CreateDropdown(ThemeSubPage, "UITheme", ThemeNamesList, "AMOLED", function(selectedTheme)
    Library:UpdateTheme(selectedTheme)
end)

Library:CreateDropdown(ThemeSubPage, "Sky", {"None", "space cky", "pink sky", "sunset sky", "dark sky"}, "None", function(selectedSky)
    applySkySettings(selectedSky)
end)

Library:CreateToggle(ThemeSubPage, "Fog", true, function(state)
    fogEnabled = state
    applyFogSettings(true)
end)

Library:CreateDropdown(ThemeSubPage, "FogColor", {"Default", "Black", "White", "Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"}, "Default", function(selectedColorName)
    if colorPresets[selectedColorName] then
        customFogColor = colorPresets[selectedColorName]
        applyFogSettings(true)
    end
end)

Library:CreateSlider(ThemeSubPage, "FogStart", 0, 500, 0, function(val)
    customFogStart = val
    applyFogSettings(false)
end)

Library:CreateSlider(ThemeSubPage, "FogEnd", 10, 2000, 120, function(val)
    customFogEnd = val
    applyFogSettings(false)
end)

Library:CreateSlider(ThemeSubPage, "FogDensity", 0, 1, 1, function(val)
    customFogDensity = val
    applyFogSettings(false)
end)

Library:CreateToggle(ThemeSubPage, "AnimatedWindow", false, function(state)
    toggleAnimatedWindow(state)
end)

Library:CreateToggle(ThemeSubPage, "Gradient", false, function(state)
    toggleGradientEffect(state)
end)

Library:CreateDropdown(ThemeSubPage, "effect", {"None", "wings aura"}, "None", function(selectedEffect)
    applyPlayerEffect(selectedEffect)
end)

-- Setup Configs Subpage Elements
local configDropdown = nil

Library:CreateInput(ConfigsSubPage, "ConfigName", "my_config", function(txt)
    currentConfigName = txt
end)

Library:CreateButton(ConfigsSubPage, "Save", function()
    saveConfig(currentConfigName)
    if configDropdown then
        configDropdown.UpdateOptions(listConfigs())
    end
end)

configDropdown = Library:CreateDropdown(ConfigsSubPage, "Configurations", listConfigs(), "Select...", function(selectedConfig)
    currentConfigName = selectedConfig
end)

Library:CreateButton(ConfigsSubPage, "Load", function()
    if not currentConfigName or currentConfigName == "" then return end
    ensureFolders()
    local path = CONFIG_FOLDER .. "/" .. currentConfigName .. ".json"
    if readfile and isfile and isfile(path) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if success and data then
            if data.Theme then Library:UpdateTheme(data.Theme) end
            if data.Font then applyFontToAll(data.Font) end
            if data.Language then Library:UpdateLanguage(data.Language) end
            if data.UISize then MainScale.Scale = data.UISize end
            if data.UITransparency then MainFrame.BackgroundTransparency = data.UITransparency end
            if data.AntiAFK ~= nil then toggleAntiAFK(data.AntiAFK) end
            if data.AnimatedWindow ~= nil then toggleAnimatedWindow(data.AnimatedWindow) end
            if data.Gradient ~= nil then toggleGradientEffect(data.Gradient) end
            if data.Sky then applySkySettings(data.Sky) end
            if data.Fog ~= nil then fogEnabled = data.Fog end
            if data.FogStart then customFogStart = data.FogStart end
            if data.FogEnd then customFogEnd = data.FogEnd end
            if data.FogDensity then customFogDensity = data.FogDensity end
            if data.Effect then applyPlayerEffect(data.Effect) end
            applyFogSettings(true)
            showToast("Config loaded successfully!")
        end
    end
end)

Library:CreateButton(ConfigsSubPage, "Delete", function()
    if not currentConfigName or currentConfigName == "" then return end
    ensureFolders()
    local path = CONFIG_FOLDER .. "/" .. currentConfigName .. ".json"
    if isfile and isfile(path) and delfile then
        delfile(path)
        showToast("Config deleted!")
        if configDropdown then
            configDropdown.UpdateOptions(listConfigs())
        end
    end
end)

-- Show Main Menu after simulate progress bar
SettingsTab.SwitchTab()
activateUI()

task.spawn(function()
    for i = 1, 100 do
        if LoadingPercent and LoadingPercent.Parent then
            LoadingPercent.Text = i .. "%"
        end
        if ProgressBarFill and ProgressBarFill.Parent then
            ProgressBarFill.Size = UDim2.new(i / 100, 0, 1, 0)
        end
        task.wait(0.012)
    end
    
    if bubbleConnection then
        bubbleConnection:Disconnect()
    end
    
    tween(LoadingOverlay, {BackgroundTransparency = 1}, 0.3)
    task.wait(0.3)
    LoadingOverlay:Destroy()
    MainFrame.Visible = true
    
    showToast(Localization[Library.CurrentLanguage]["HubLoaded"] or "Dark Hub loaded successfully!")
end)
