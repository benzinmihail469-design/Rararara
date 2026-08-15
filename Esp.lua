local Maclib = loadstring(game:HttpGet("https://raw.githubusercontent.com/L4R1/Maclib/main/source.lua"))()

local Window = Maclib:CreateWindow({
    Title = "KITI",
    Subtitle = "ТГК - t.me/KITI_RBB",
    Size = UDim2.fromOffset(830, 520),
    Dragable = true,
})

Window:SetUser({
    Name = "ayaka",
    Subtext = "Never"
})

-- ==================== TABS ====================
local GeneralTab = Window:Tab({ Name = "General", Icon = "settings" })
local MM2Tab     = Window:Tab({ Name = "MM2",     Icon = "crosshair" })
local VisualsTab = Window:Tab({ Name = "Visuals", Icon = "eye" })
local TargetTab  = Window:Tab({ Name = "Target",  Icon = "user" })
local FunTab     = Window:Tab({ Name = "Fun",     Icon = "star" })
local EmotesTab  = Window:Tab({ Name = "Emotes",  Icon = "activity" })
local SoundTab   = Window:Tab({ Name = "Sound",   Icon = "volume-2" })
local ConfigsTab = Window:Tab({ Name = "Configs", Icon = "folder" })

-- ==================== GENERAL TAB ====================
local FlyGroup = GeneralTab:Section({ Name = "Fly", Side = "Left" })
FlyGroup:Toggle({ Name = "OP Fly", Default = false, Callback = function(v) end })
FlyGroup:Input({ Name = "Fly Speed", Default = "50", Callback = function(v) end })

local MoveGroup = GeneralTab:Section({ Name = "Movement", Side = "Left" })
MoveGroup:Input({ Name = "Walkspeed", Default = "16", Callback = function(v) end })
MoveGroup:Input({ Name = "FOV", Default = "100", Callback = function(v) end })
MoveGroup:Toggle({ Name = "CTRL+Click TP", Default = true, Callback = function(v) end })

local NoclipGroup = GeneralTab:Section({ Name = "Noclip", Side = "Left" })
NoclipGroup:Toggle({ Name = "Noclip", Default = false, Callback = function(v) end })

local BlinkGroup = GeneralTab:Section({ Name = "Blink", Side = "Left" })
BlinkGroup:Toggle({ Name = "Blink", Default = false, Callback = function(v) end })
BlinkGroup:Input({ Name = "Blink Speed", Default = "32", Callback = function(v) end })

local TeleportGroup = GeneralTab:Section({ Name = "Teleport", Side = "Right" })
TeleportGroup:Input({ Name = "Player Name", Placeholder = "Player...", Callback = function(v) end })

local MiscGeneralGroup = GeneralTab:Section({ Name = "Misc", Side = "Right" })
MiscGeneralGroup:Button({ Name = "FPS Boost", Callback = function() end })
MiscGeneralGroup:Button({ Name = "Get Ping", Callback = function() end })
MiscGeneralGroup:Button({ Name = "Rejoin", Callback = function() end })
MiscGeneralGroup:Toggle({ Name = "AntiFling", Default = false, Callback = function(v) end })

local GhostGroup = GeneralTab:Section({ Name = "Client Ghost", Side = "Right" })
GhostGroup:Toggle({ Name = "Client Ghost", Default = true, Callback = function(v) end })

-- ==================== MM2 TAB ====================
local ESPGroup = MM2Tab:Section({ Name = "ESP", Side = "Left" })
ESPGroup:Toggle({ Name = "Players", Default = false, Callback = function(v) end })
ESPGroup:Toggle({ Name = "Dropped Gun", Default = true, Callback = function(v) end })
ESPGroup:Toggle({ Name = "Traps", Default = true, Callback = function(v) end })

local SheriffGroup = MM2Tab:Section({ Name = "Sheriff", Side = "Left" })
SheriffGroup:Toggle({ Name = "Auto-shoot", Default = false, Callback = function(v) end })
SheriffGroup:Toggle({ Name = "SilentAim", Default = false, Callback = function(v) end })
SheriffGroup:Toggle({ Name = "ForceShoot", Default = true, Callback = function(v) end })
SheriffGroup:Input({ Name = "Shoot Offset", Default = "1", Callback = function(v) end })
SheriffGroup:Input({ Name = "SilentAim Offset", Default = "2.8", Callback = function(v) end })

local DetectGroup = MM2Tab:Section({ Name = "Detectables", Side = "Left" })
DetectGroup:Button({ Name = "Hold Everyone Hostage", Callback = function() end })
DetectGroup:Button({ Name = "Kill Everyone", Callback = function() end })

local MurdGroup = MM2Tab:Section({ Name = "Murderer", Side = "Right" })
MurdGroup:Button({ Name = "Knife Throw to Nearest", Callback = function() end })
MurdGroup:Toggle({ Name = "Auto Knife Throw", Default = false, Callback = function(v) end })
MurdGroup:Button({ Name = "Kill Nearest", Callback = function() end })
MurdGroup:Button({ Name = "Fling Sheriff", Callback = function() end })
MurdGroup:Button({ Name = "Fling Murderer", Callback = function() end })

local ToolsGroup = MM2Tab:Section({ Name = "Tools", Side = "Right" })
ToolsGroup:Toggle({ Name = "Auto-get Dropped Gun", Default = false, Callback = function(v) end })
ToolsGroup:Toggle({ Name = "OffDamageWater", Default = true, Callback = function(v) end })
ToolsGroup:Button({ Name = "TP to Dropped Gun", Callback = function() end })
ToolsGroup:Button({ Name = "TP to Lobby", Callback = function() end })
ToolsGroup:Button({ Name = "TP to Random Spawn", Callback = function() end })
ToolsGroup:Button({ Name = "Copy Murderer Name", Callback = function() end })
ToolsGroup:Button({ Name = "Copy Sheriff Name", Callback = function() end })

-- ==================== VISUALS TAB ====================
local GunModelGroup = VisualsTab:Section({ Name = "Gun Model", Side = "Left" })
GunModelGroup:Toggle({ Name = "Custom Model", Default = true, Callback = function(v) end })
GunModelGroup:Dropdown({ Name = "Select Model", Options = {"BigUSP-S", "Default"}, Default = "BigUSP-S", Callback = function(v) end })

local EffectsGroup = VisualsTab:Section({ Name = "Effects", Side = "Left" })
EffectsGroup:Toggle({ Name = "Trails", Default = true, Callback = function(v) end })
EffectsGroup:Dropdown({ Name = "Trail Style", Options = {"Solid", "Gradient"}, Default = "Solid", Callback = function(v) end })
EffectsGroup:Toggle({ Name = "Magic Aura", Default = false, Callback = function(v) end })
EffectsGroup:Toggle({ Name = "Shader (RTX)", Default = true, Callback = function(v) end })

local EnvGroup = VisualsTab:Section({ Name = "Environment", Side = "Left" })
EnvGroup:Toggle({ Name = "Time Lock", Default = false, Callback = function(v) end })
EnvGroup:Input({ Name = "Time Value", Default = "14", Callback = function(v) end })
EnvGroup:Toggle({ Name = "Weather", Default = false, Callback = function(v) end })
EnvGroup:Dropdown({ Name = "Weather", Options = {"Fog", "Rain", "Snow"}, Default = "Fog", Callback = function(v) end })
EnvGroup:Input({ Name = "Fog Start", Default = "1", Callback = function(v) end })
EnvGroup:Input({ Name = "Distance", Default = "1", Callback = function(v) end })

local TargetESPGroup = VisualsTab:Section({ Name = "Target ESP/HUD", Side = "Right" })
TargetESPGroup:Toggle({ Name = "Target ESP", Default = true, Callback = function(v) end })
TargetESPGroup:Toggle({ Name = "Target HUD", Default = true, Callback = function(v) end })

local SkyboxGroup = VisualsTab:Section({ Name = "Skybox Manager", Side = "Right" })
SkyboxGroup:Button({ Name = "Remove Sky", Callback = function() end })
SkyboxGroup:Button({ Name = "Snow Skybox", Callback = function() end })
SkyboxGroup:Button({ Name = "Realistic Space", Callback = function() end })
SkyboxGroup:Button({ Name = "Purple Nebula", Callback = function() end })
SkyboxGroup:Button({ Name = "Blue Nebula", Callback = function() end })

-- ==================== TARGET TAB ====================
local SelPlayerGroup = TargetTab:Section({ Name = "Select Player", Side = "Left" })
SelPlayerGroup:Dropdown({ Name = "Players List", Options = {"Select"}, Default = "Select", Callback = function(v) end })
SelPlayerGroup:Button({ Name = "Refresh List", Callback = function() end })

local QuickSelGroup = TargetTab:Section({ Name = "Quick Select", Side = "Left" })
QuickSelGroup:Button({ Name = "Select Murderer", Callback = function() end })
QuickSelGroup:Button({ Name = "Select Sheriff", Callback = function() end })
QuickSelGroup:Button({ Name = "Select Nearest", Callback = function() end })

local TargetActionsGroup = TargetTab:Section({ Name = "Actions", Side = "Right" })
TargetActionsGroup:Button({ Name = "Teleport To", Callback = function() end })
TargetActionsGroup:Button({ Name = "Fling", Callback = function() end })
TargetActionsGroup:Button({ Name = "Kill (as Murderer)", Callback = function() end })
TargetActionsGroup:Button({ Name = "Set as Aimlock Target", Callback = function() end })
TargetActionsGroup:Toggle({ Name = "Aimlock", Default = false, Callback = function(v) end })

-- ==================== FUN TAB ====================
local MiscFunGroup = FunTab:Section({ Name = "Misc", Side = "Left" })
MiscFunGroup:Toggle({ Name = "BunnyHop", Default = false, Callback = function(v) end })
MiscFunGroup:Toggle({ Name = "Friend", Default = false, Callback = function(v) end })
MiscFunGroup:Toggle({ Name = "AspectRatio", Default = true, Callback = function(v) end })
MiscFunGroup:Input({ Name = "Aspect Ratio Scale", Default = "0.65", Callback = function(v) end })

local SpinGroup = FunTab:Section({ Name = "Spin", Side = "Left" })
SpinGroup:Toggle({ Name = "Spin", Default = false, Callback = function(v) end })
SpinGroup:Input({ Name = "Spin Speed", Default = "10", Callback = function(v) end })

local JerkGroup = FunTab:Section({ Name = "Jerk", Side = "Right" })
JerkGroup:Toggle({ Name = "Jerk Off", Default = true, Callback = function(v) end })

local HitEffGroup = FunTab:Section({ Name = "Hit Effects", Side = "Right" })
HitEffGroup:Toggle({ Name = "Hit Particles", Default = false, Callback = function(v) end })
HitEffGroup:Toggle({ Name = "Hit Sound", Default = false, Callback = function(v) end })

-- ==================== EMOTES TAB ====================
local EmotesGroup = EmotesTab:Section({ Name = "Emotes", Side = "Left" })
EmotesGroup:Dropdown({ Name = "Emotes (R15)", Options = {"YUNGBLUD - ..."}, Default = "YUNGBLUD - ...", Callback = function(v) end })
EmotesGroup:Button({ Name = "Stop Emote", Callback = function() end })

local AnimGroup = EmotesTab:Section({ Name = "Animations", Side = "Right" })
AnimGroup:Dropdown({ Name = "Select Animation", Options = {"Select"}, Default = "Select", Callback = function(v) end })
AnimGroup:Button({ Name = "Reset Animation", Callback = function() end })

-- ==================== SOUND TAB ====================
local UISoundGroup = SoundTab:Section({ Name = "UI Sound Settings", Side = "Left" })
UISoundGroup:Toggle({ Name = "UI Sounds Enabled", Default = true, Callback = function(v) end })
UISoundGroup:Dropdown({ Name = "Enable Sound", Options = {"Sparkle"}, Default = "Sparkle", Callback = function(v) end })
UISoundGroup:Dropdown({ Name = "Disable Sound", Options = {"Sparkle"}, Default = "Sparkle", Callback = function(v) end })
UISoundGroup:Button({ Name = "Test UI Sound", Callback = function() end })

local CustomSoundGroup = SoundTab:Section({ Name = "MM2 Custom Game Sounds", Side = "Right" })
CustomSoundGroup:Dropdown({ Name = "GunKill Sound", Options = {"RPGS Jellyfish"}, Default = "RPGS Jellyfish", Callback = function(v) end })
CustomSoundGroup:Dropdown({ Name = "Gunshot Sound", Options = {"Alchemist Bu..."}, Default = "Alchemist Bu...", Callback = function(v) end })
CustomSoundGroup:Dropdown({ Name = "Knife Kill Sound", Options = {"Jeff Laugh"}, Default = "Jeff Laugh", Callback = function(v) end })
CustomSoundGroup:Toggle({ Name = "Shutup GunReload", Default = true, Callback = function(v) end })

-- ==================== CONFIGS TAB ====================
local ConfigManagerGroup = ConfigsTab:Section({ Name = "Config Manager", Side = "Left" })
ConfigManagerGroup:Input({ Name = "Config Name", Default = "default", Callback = function(v) end })
ConfigManagerGroup:Button({ Name = "Save Config", Callback = function() end })
ConfigManagerGroup:Dropdown({ Name = "Select Config", Options = {"default"}, Default = "default", Callback = function(v) end })
ConfigManagerGroup:Button({ Name = "Load Config", Callback = function() end })
ConfigManagerGroup:Button({ Name = "Refresh List", Callback = function() end })
ConfigManagerGroup:Button({ Name = "Delete Config", Callback = function() end })

