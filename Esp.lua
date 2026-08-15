-- Загрузка библиотеки Neverlose UI (raw ссылка для корректного выполнения)
local Neverlose_Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mana42138/Neverlose-UI/main/Source.lua"))()

-- Создание главного окна
local Window = Neverlose_Main:AddWindow("Dark Hub", "Neverlose Edition")

-- === ВКЛАДКИ (TABS) ===
local LegitTab = Window:AddTab("Legitbot")
local VisualsTab = Window:AddTab("Visuals")
local MiscTab = Window:AddTab("Miscellaneous")
local ConfigTab = Window:AddTab("Configs")

-- ==========================================
-- 1. ВКЛАДКА: LEGITBOT
-- ==========================================
local AimSection = LegitTab:AddSection("Aimbot Settings")

AimSection:AddToggle("Enable Aimbot", false, function(state)
    getgenv().AimbotEnabled = state
end)

AimSection:AddSlider("Aimbot Smooth", 1, 20, 5, function(val)
    getgenv().AimbotSmooth = val
end)

AimSection:AddSlider("FOV Radius", 10, 500, 90, function(val)
    getgenv().AimbotFOV = val
end)

AimSection:AddDropdown("Target Bone", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(selected)
    getgenv().AimTargetBone = selected
end)

AimSection:AddKeybind("Aimbot Key", Enum.KeyCode.E, function()
    print("Aimbot key pressed")
end)

-- ==========================================
-- 2. ВКЛАДКА: VISUALS
-- ==========================================
local EspSection = VisualsTab:AddSection("Player ESP")

EspSection:AddToggle("Enable Player ESP", false, function(state)
    _G.ESPEnabled = state
end)

EspSection:AddToggle("Enable Weapon ESP", false, function(state)
    _G.GunESPEnabled = state
end)

EspSection:AddColorpicker("ESP Color", Color3.fromRGB(0, 162, 255), function(color)
    getgenv().ESPColor = color
end)

local RenderSection = VisualsTab:AddSection("World & Camera")

RenderSection:AddSlider("Camera FOV", 70, 120, 70, function(val)
    game:GetService("Workspace").CurrentCamera.FieldOfView = val
end)

-- ==========================================
-- 3. ВКЛАДКА: MISCELLANEOUS
-- ==========================================
local MovementSection = MiscTab:AddSection("Movement Options")

MovementSection:AddSlider("WalkSpeed Multiplier", 16, 100, 16, function(speed)
    local char = game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
    end
end)

MovementSection:AddToggle("BunnyHop / AutoJump", false, function(state)
    getgenv().BHop = state
end)

local ServerSection = MiscTab:AddSection("Server Options")

ServerSection:AddButton("Rejoin Server", function()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
end)

ServerSection:AddButton("Copy Job ID", function()
    if setclipboard then
        setclipboard(game.JobId)
    end
end)

-- ==========================================
-- 4. ВКЛАДКА: CONFIGS
-- ==========================================
local ConfigSection = ConfigTab:AddSection("Configuration Management")

ConfigSection:AddDropdown("Select Config", {"Default", "Legit Hvh", "Rage Test"}, "Default", function(cfg)
    getgenv().SelectedConfig = cfg
end)

ConfigSection:AddButton("Load Config", function()
    print("Config Loaded:", getgenv().SelectedConfig)
end)

ConfigSection:AddButton("Save Config", function()
    print("Config Saved:", getgenv().SelectedConfig)
end)
