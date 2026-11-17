--[[
​██╗     ██╗   ██╗███╗   ██╗ █████╗     ██╗███╗   ██╗████████╗███████╗██████╗ ███████╗ █████╗  ██████╗███████╗    ███████╗██╗   ██╗██╗████████╗███████╗
██║     ██║   ██║████╗  ██║██╔══██╗    ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝    ██╔════╝██║   ██║██║╚══██╔══╝██╔════╝
██║     ██║   ██║██╔██╗ ██║███████║    ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝█████╗  ███████║██║     █████╗      ███████╗██║   ██║██║   ██║   █████╗
██║     ██║   ██║██║╚██╗██║██╔══██║    ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██╔══╝  ██╔══██║██║     ██╔══╝      ╚════██║██║   ██║██║   ██║   ██╔══╝
███████╗╚██████╔╝██║ ╚████║██║  ██║    ██║██║ ╚████║   ██║   ███████╗██║  ██║██║     ██║  ██║╚██████╗███████╗    ███████║╚██████╔╝██║   ██║   ███████╗
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝    ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝    ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝
by    d8b   db d88888b d8888b. db    db db       .d8b.       .d8888.  .d88b.  d88888b d888888b db   d8b   db  .d88b.  d8888b. db   dD .d8888.
888o  88 88'     88  8D 88    88 88      d8' 8b      88'  YP .8P  Y8. 88'     ~~88~~' 88   I8I   88 .8P  Y8. 88  8D 88 ,8P' 88'  YP
88V8o 88 88ooooo 88oooY' 88    88 88      88ooo88      8bo.   88    88 88ooo      88    88   I8I   88 88    88 88oobY' 88,8P   8bo.
88 V8o88 88~~~~~ 88~~~b. 88    88 88      88~~~88        Y8b. 88    88 88~~~      88    Y8   I8I   88 88    88 888b   888b     Y8b.
88  V888 88.     88   8D 88b  d88 88booo. 88   88      db   8D 8b  d8' 88         88    8b d8'8b d8' 8b  d8' 88 88. 88 88. db   8D  VP   V8P Y88888P Y8888P' ~Y8888P' Y88888P YP   YP      8888Y'  Y88P'  YP         YP     8b8' 8d8'   Y88P'  88   YD YP   YD `8888Y'
​Main Credits
​Hunter (Nebula Softworks) | Designing And Programming | Main Developer
JustHey (Nebula Softworks) | Configurations, Bug Fixing And More! | Co Developer
Throit | Color Picker
Wally | Dragging And Certain Functions
Sirius | PCall Parsing, Notifications, Slider And Home Tab
Luna Executor | Original UI
​Extra Credits / Provided Certain Elements
​Pookie Pepelss | Bug Tester
Inori | Configuration Concept
Latte Softworks and qweery | Lucide Icons And Material Icons
kirill9655 | Loading Circle
Deity/dp4pv/x64x70 | Certain Scripting and Testing ig
​Contributors
iPigTw | Typo Fixer, Fixed Key System!!
pushByAccident | Fixing Executor Lists
ImFloriz | Method Fixing
​Luna Interface Suite
by Nebula Softworks
​]]
​local Release = "Prerelease Beta 6.1"
​local Luna = {
Folder = "Luna",
Options = {},
ThemeGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(117, 164, 206)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(123, 201, 201)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(224, 138, 175))}
}
​local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Localization = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
​local isStudio
local website = "github.com/Nebula-Softworks"
​if RunService:IsStudio() then
isStudio = true
end
​-- Icons removed (1500+ lines stripped for lightweight mobile performance)
local IconModule = {
Lucide = {},
Material = {}
}
​-- Other Variables
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or nil
local tweeninfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local IsMobile = UserInputService.TouchEnabled
​local PresetGradients = {
["Nightlight (Classic)"] = {Color3.fromRGB(147, 255, 239), Color3.fromRGB(201,211,233), Color3.fromRGB(255, 167, 227)},
["Nightlight (Neo)"] = {Color3.fromRGB(117, 164, 206), Color3.fromRGB(123, 201, 201), Color3.fromRGB(224, 138, 175)},
Starlight = {Color3.fromRGB(147, 255, 239), Color3.fromRGB(181, 206, 241), Color3.fromRGB(214, 158, 243)},
Solar = {Color3.fromRGB(242, 157, 76), Color3.fromRGB(240, 179, 81), Color3.fromRGB(238, 201, 86)},
Sparkle = {Color3.fromRGB(199, 130, 242), Color3.fromRGB(221, 130, 238), Color3.fromRGB(243, 129, 233)},
Lime = {Color3.fromRGB(170, 255, 127), Color3.fromRGB(163, 220, 138), Color3.fromRGB(155, 185, 149)},
Vine = {Color3.fromRGB(0, 191, 143), Color3.fromRGB(0, 126, 94), Color3.fromRGB(0, 61, 46)},
Cherry = {Color3.fromRGB(148, 54, 54), Color3.fromRGB(168, 67, 70), Color3.fromRGB(188, 80, 86)},
Daylight = {Color3.fromRGB(51, 156, 255), Color3.fromRGB(89, 171, 237), Color3.fromRGB(127, 186, 218)},
Blossom = {Color3.fromRGB(255, 165, 243), Color3.fromRGB(213, 129, 231), Color3.fromRGB(170, 92, 218)},
}
​local function GetIcon(icon, source)
return ""
end
​local function RemoveTable(tablre, value)
for i, v in pairs(tablre) do
if tostring(v) == tostring(value) then
table.remove(tablre, i)
end
end
end
​local function Kwargify(defaults, passed)
for i, v in pairs(defaults) do
if passed[i] == nil then
passed[i] = v
end
end
return passed
end
​local function PackColor(Color)
return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end
​local function UnpackColor(Color)
return Color3.fromRGB(Color.R, Color.G, Color.B)
end
​function tween(object, goal, callback, tweenin)
if not object then return end
local tw = TweenService:Create(object, tweenin or tweeninfo, goal)
tw.Completed:Connect(callback or function() end)
tw:Play()
end
​-- Mobile helper: binds tap/click without misfiring when the user scrolls a ScrollingFrame
local function BindTap(guiObject, callback)
if not guiObject then return end
local touchStartPos = nil
local movedTooMuch = false
​guiObject.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch then
touchStartPos = input.Position
movedTooMuch = false
end
end)
​guiObject.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch and touchStartPos then
if (input.Position - touchStartPos).Magnitude > 12 then
movedTooMuch = true
end
end
end)
​guiObject.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch then
if touchStartPos and not movedTooMuch then
touchStartPos = nil
callback()
end
touchStartPos = nil
end
end)
​if guiObject:IsA("GuiButton") then
guiObject.MouseButton1Click:Connect(function()
if not UserInputService.TouchEnabled then
callback()
end
end)
else
guiObject.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
callback()
end
end)
end
end
​-- Mobile helper: ensures ScrollingFrames and Sections auto-update CanvasSize & height
local function SetupAutoScroll(scrollingFrame)
if not scrollingFrame or not scrollingFrame:IsA("ScrollingFrame") then return end
pcall(function()
scrollingFrame.ScrollingEnabled = true
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
if IsMobile then
scrollingFrame.ScrollBarThickness = math.max(scrollingFrame.ScrollBarThickness, 4)
end
end)
local layout = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")
if layout then
local function updateCanvas()
pcall(function()
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 36)
end)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.defer(updateCanvas)
end
end
​local function SetupAutoSection(sectionLabel, sectionFrame, parentScrollPage)
if not sectionLabel or not sectionFrame then return end
pcall(function()
sectionLabel.AutomaticSize = Enum.AutomaticSize.Y
sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
end)
local layout = sectionFrame:FindFirstChildWhichIsA("UIListLayout")
if layout then
local function updateSectionSize()
pcall(function()
local contentY = layout.AbsoluteContentSize.Y
sectionFrame.Size = UDim2.new(sectionFrame.Size.X.Scale, sectionFrame.Size.X.Offset, 0, contentY + 6)
sectionLabel.Size = UDim2.new(sectionLabel.Size.X.Scale, sectionLabel.Size.X.Offset, 0, contentY + 34)
if parentScrollPage and parentScrollPage:IsA("ScrollingFrame") then
local pLayout = parentScrollPage:FindFirstChildWhichIsA("UIListLayout")
if pLayout then
parentScrollPage.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 36)
end
end
end)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
task.defer(updateSectionSize)
end
end
​local function BlurModule(Frame)
if IsMobile then
-- Skip heavy 3D Glass part generation on mobile devices to prevent FPS drops and camera artifacts
return
end
local RunService = game:GetService('RunService')
local camera = workspace.CurrentCamera
local MTREL = "Glass"
local binds = {}
local root = Instance.new('Folder', camera)
root.Name = 'LunaBlur'
​local gTokenMH = 99999999
local gToken = math.random(1, gTokenMH)
​local DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
DepthOfField.FarIntensity = 0
DepthOfField.FocusDistance = 51.6
DepthOfField.InFocusRadius = 50
DepthOfField.NearIntensity = 6
DepthOfField.Name = "DPT_"..gToken
​local frame = Instance.new('Frame')
frame.Parent = Frame
frame.Size = UDim2.new(0.95, 0, 0.95, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 1
​local GenUid; do
local id = 0
function GenUid()
id = id + 1
return 'neon::'..tostring(id)
end
end
​do
local function IsNotNaN(x)
return x == x
end
local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
local tries = 0
while not continue and tries < 60 do
RunService.RenderStepped:Wait()
tries = tries + 1
continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
end
end
​local DrawQuad; do
local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
local sz = 0.22
local function DrawTriangle(v1, v2, v3, p0, p1)
local s1 = (v1 - v2).magnitude
local s2 = (v2 - v3).magnitude
local s3 = (v3 - v1).magnitude
local smax = max(s1, s2, s3)
local A, B, C
if s1 == smax then
A, B, C = v1, v2, v3
elseif s2 == smax then
A, B, C = v2, v3, v1
elseif s3 == smax then
A, B, C = v3, v1, v2
end
​local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
local perp = sqrt((C-A).magnitude^2 - para*para)
local dif_para = (A - B).magnitude - para
​local st = CFrame.new(B, A)
local za = CFrame.Angles(pi/2,0,0)
​local cf0 = st
​local Top_Look = (cf0 * za).lookVector
local Mid_Point = A + CFrame.new(A, B).lookVector * para
local Needed_Look = CFrame.new(Mid_Point, C).lookVector
local dot = Top_Look.xNeeded_Look.x + Top_Look.yNeeded_Look.y + Top_Look.z*Needed_Look.z
​local ac = CFrame.Angles(0, 0, acos(dot))
​cf0 = cf0 * ac
if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
end
cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))
​local cf1 = st * ac * CFrame.Angles(0, pi, 0)
if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
end
cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)
​if not p0 then
p0 = Instance.new('Part')
p0.FormFactor = 'Custom'
p0.TopSurface = 0
p0.BottomSurface = 0
p0.Anchored = true
p0.CanCollide = false
p0.CastShadow = false
p0.Material = MTREL
p0.Size = Vector3.new(sz, sz, sz)
local mesh = Instance.new('SpecialMesh', p0)
mesh.MeshType = 2
mesh.Name = 'WedgeMesh'
end
p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
p0.CFrame = cf0
​if not p1 then
p1 = p0:clone()
end
p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
p1.CFrame = cf1
​return p0, p1
end
​function DrawQuad(v1, v2, v3, v4, parts)
parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
end
end
​if binds[frame] then
return binds[frame].parts
end
​local uid = GenUid()
local parts = {}
local f = Instance.new('Folder', root)
f.Name = frame.Name
​local parents = {}
do
local function add(child)
if child:IsA'GuiObject' then
parents[#parents + 1] = child
add(child.Parent)
end
end
add(frame)
end
​local function UpdateOrientation(fetchProps)
if not Frame or not Frame.Visible then
for _, pt in pairs(parts) do
pt.Transparency = 1
end
return
end
local properties = {
Transparency = 0.98;
BrickColor = BrickColor.new('Institutional white');
}
local zIndex = 1 - 0.05*frame.ZIndex
​local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
do
local rot = 0;
for _, v in ipairs(parents) do
rot = rot + v.Rotation
end
if rot ~= 0 and rot%180 ~= 0 then
local mid = tl:lerp(br, 0.5)
local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
end
end
DrawQuad(
camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
parts
)
if fetchProps then
for _, pt in pairs(parts) do
pt.Parent = f
end
for propName, propValue in pairs(properties) do
for _, pt in pairs(parts) do
pt[propName] = propValue
end
end
end
end
​UpdateOrientation(true)
RunService:BindToRenderStep(uid, 2000, UpdateOrientation)
end
​local function unpackt(array)
local val = ""
local i = 0
for _, v in pairs(array) do
if i < 3 then
val = val .. tostring(v) .. ", "
i += 1
else
val = "Various"
break
end
end
return val
end
​-- Interface Management
local LunaUI = isStudio and script.Parent:WaitForChild("Luna UI") or game:GetObjects("rbxassetid://86467455075715")[1]
​local SizeBleh = nil
local MainSize = UDim2.fromOffset(675, 424)
local MinSize = UDim2.fromOffset(500, 42)
​-- Automatic UIScale for mobile / compact viewports so fixed-offset internal panels never clip
local WindowUIScale = Instance.new("UIScale")
WindowUIScale.Name = "MobileUIScale"
WindowUIScale.Scale = 1
​local function UpdateMobileScale()
Camera = workspace.CurrentCamera or Camera
if not Camera then return end
local vp = Camera.ViewportSize
if vp.X <= 0 or vp.Y <= 0 then return end
if IsMobile or vp.X < 740 or vp.Y < 480 then
local scaleX = (vp.X - 24) / 675
local scaleY = (vp.Y - 36) / 424
WindowUIScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.5, 1)
else
WindowUIScale.Scale = 1
end
end
​local function Hide(Window, bind, notif)
if Window.Size.X.Offset > 0 and Window.Size.Y.Offset > 0 then
SizeBleh = Window.Size
else
SizeBleh = MainSize
end
bind = string.split(tostring(bind), "Enum.KeyCode.")
bind = bind[2] or "K"
if notif then
Luna:Notification({
Title = "Interface Hidden",
Content = IsMobile and "Tap the floating Luna button on screen to reopen the menu." or ("The interface has been hidden, you may reopen the interface by Pressing the UI Bind ("..tostring(bind)..")")
})
end
tween(Window, {BackgroundTransparency = 1})
tween(Window.Elements, {BackgroundTransparency = 1})
tween(Window.Line, {BackgroundTransparency = 1})
tween(Window.Title.Title, {TextTransparency = 1})
tween(Window.Title.subtitle, {TextTransparency = 1})
tween(Window.Logo, {ImageTransparency = 1})
tween(Window.Navigation.Line, {BackgroundTransparency = 1})
​for _, TopbarButton in ipairs(Window.Controls:GetChildren()) do
if TopbarButton.ClassName == "Frame" then
tween(TopbarButton, {BackgroundTransparency = 1})
tween(TopbarButton.UIStroke, {Transparency = 1})
tween(TopbarButton.ImageLabel, {ImageTransparency = 1})
TopbarButton.Visible = false
end
end
for _, tabbtn in ipairs(Window.Navigation.Tabs:GetChildren()) do
if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "InActive Template" then
TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
TweenService:Create(tabbtn.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
TweenService:Create(tabbtn.DropShadowHolder.DropShadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
end
end
​task.wait(0.28)
Window.Size = UDim2.new(0,0,0,0)
if Window.Parent and Window.Parent:FindFirstChild("ShadowHolder") then
Window.Parent.ShadowHolder.Visible = false
end
task.wait()
Window.Elements.Visible = false
Window.Visible = false
end
​if gethui then
LunaUI.Parent = gethui()
elseif syn and syn.protect_gui then
syn.protect_gui(LunaUI)
LunaUI.Parent = CoreGui
elseif not isStudio and CoreGui:FindFirstChild("RobloxGui") then
LunaUI.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not isStudio then
LunaUI.Parent = CoreGui
end
​if gethui then
for _, Interface in ipairs(gethui():GetChildren()) do
if Interface.Name == LunaUI.Name and Interface ~= LunaUI then
pcall(function() Hide(Interface.SmartWindow) end)
Interface.Enabled = false
Interface.Name = "Luna-Old"
end
end
elseif not isStudio then
for _, Interface in ipairs(CoreGui:GetChildren()) do
if Interface.Name == LunaUI.Name and Interface ~= LunaUI then
pcall(function() Hide(Interface.SmartWindow) end)
Interface.Enabled = false
Interface.Name = "Luna-Old"
end
end
end
​LunaUI.Enabled = false
LunaUI.SmartWindow.Visible = false
LunaUI.Notifications.Template.Visible = false
LunaUI.DisplayOrder = 1000000000
pcall(function()
LunaUI.IgnoreGuiInset = true
end)
​local Main = LunaUI.SmartWindow
local Dragger = Main.Drag
local dragBar = LunaUI:FindFirstChild("Drag")
local dragInteract = dragBar and dragBar:FindFirstChild("Interact") or nil
local dragBarCosmetic = dragBar and dragBar:FindFirstChild("Drag") or nil
local Elements = Main.Elements.Interactions
local LoadingFrame = Main.LoadingFrame
local Navigation = Main.Navigation
local Tabs = Navigation.Tabs
local Notifications = LunaUI.Notifications
local KeySystem = Main.KeySystem
​WindowUIScale.Parent = Main
if Main.Parent and Main.Parent:FindFirstChild("ShadowHolder") then
local shadowScale = WindowUIScale:Clone()
shadowScale.Parent = Main.Parent.ShadowHolder
WindowUIScale:GetPropertyChangedSignal("Scale"):Connect(function()
shadowScale.Scale = WindowUIScale.Scale
end)
end
UpdateMobileScale()
if Camera then
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateMobileScale)
end
​SetupAutoScroll(Tabs)
​local function Draggable(Bar, Window, enableTaptic, tapticOffset)
pcall(function()
if not Bar or not Window then return end
local Dragging, DragInput, MousePos, FramePos
​local function connectFunctions()
if dragBar and enableTaptic then
dragBar.MouseEnter:Connect(function()
if not Dragging then
TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
end
end)
​dragBar.MouseLeave:Connect(function()
if not Dragging then
TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
end
end)
end
end
​connectFunctions()
​Bar.InputBegan:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Dragging = true
MousePos = Input.Position
FramePos = Window.Position
​if enableTaptic and dragBarCosmetic then
TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
end
​Input.Changed:Connect(function()
if Input.UserInputState == Enum.UserInputState.End then
Dragging = false
connectFunctions()
​if enableTaptic and dragBarCosmetic then
TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
end
end
end)
end
end)
​Bar.InputChanged:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
DragInput = Input
end
end)
​UserInputService.InputChanged:Connect(function(Input)
if Input == DragInput and Dragging then
local Delta = Input.Position - MousePos
​local newMainPosition = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
TweenService:Create(Window, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = newMainPosition}):Play()
​if dragBar and Window == Main then
local newDragBarPosition = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y + 240 * WindowUIScale.Scale)
dragBar.Position = newDragBarPosition
end
end
end)
end)
end
​function Luna:Notification(data)
task.spawn(function()
data = Kwargify({
Title = "Missing Title",
Content = "Missing or Unknown Content",
Icon = "",
ImageSource = "Material"
}, data or {})
​local newNotification = Notifications.Template:Clone()
newNotification.Name = data.Title
newNotification.Parent = Notifications
newNotification.LayoutOrder = #Notifications:GetChildren()
newNotification.Visible = false
BlurModule(newNotification)
​newNotification.Title.Text = data.Title
newNotification.Description.Text = data.Content
newNotification.Icon.Image = ""
newNotification.Icon.Visible = false
​-- Adjust text positions cleanly since icons are removed
pcall(function()
newNotification.Title.Position = UDim2.new(0, 16, newNotification.Title.Position.Y.Scale, newNotification.Title.Position.Y.Offset)
newNotification.Description.Position = UDim2.new(0, 16, newNotification.Description.Position.Y.Scale, newNotification.Description.Position.Y.Offset)
end)
​newNotification.BackgroundTransparency = 1
newNotification.Title.TextTransparency = 1
newNotification.Description.TextTransparency = 1
newNotification.UIStroke.Transparency = 1
newNotification.Shadow.ImageTransparency = 1
newNotification.Icon.ImageTransparency = 1
newNotification.Icon.BackgroundTransparency = 1
​task.wait()
​newNotification.Size = UDim2.new(1, 0, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)
newNotification.Visible = true
​newNotification.Description.Size = UDim2.new(1, -32, 0, math.huge)
local bounds = newNotification.Description.TextBounds.Y + 55
newNotification.Description.Size = UDim2.new(1, -32, 0, bounds - 35)
newNotification.Size = UDim2.new(1, 0, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)
TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, bounds)}):Play()
​task.wait(0.15)
TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45}):Play()
TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
​task.wait(0.1)
TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.35}):Play()
TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.95}):Play()
TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.82}):Play()
​local waitDuration = math.min(math.max((#newNotification.Description.Text * 0.1) + 2.5, 3), 10)
task.wait(data.Duration or waitDuration)
​TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
​TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, 0)}):Play()
​task.wait(1)
​TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)}):Play()
​newNotification.Visible = false
newNotification:Destroy()
end)
end
​local function Unhide(Window, currentTab)
Window.Size = SizeBleh or MainSize
if Window.Parent and Window.Parent:FindFirstChild("ShadowHolder") then
Window.Parent.ShadowHolder.Visible = true
end
Window.Elements.Visible = true
Window.Visible = true
task.wait()
tween(Window, {BackgroundTransparency = 0.2})
tween(Window.Elements, {BackgroundTransparency = 0.08})
tween(Window.Line, {BackgroundTransparency = 0})
tween(Window.Title.Title, {TextTransparency = 0})
tween(Window.Title.subtitle, {TextTransparency = 0})
tween(Window.Logo, {ImageTransparency = 0})
tween(Window.Navigation.Line, {BackgroundTransparency = 0})
​for _, TopbarButton in ipairs(Window.Controls:GetChildren()) do
if TopbarButton.ClassName == "Frame" and TopbarButton.Name ~= "Theme" then
TopbarButton.Visible = true
tween(TopbarButton, {BackgroundTransparency = 0.25})
tween(TopbarButton.UIStroke, {Transparency = 0.5})
tween(TopbarButton.ImageLabel, {ImageTransparency = 0.25})
end
end
for _, tabbtn in ipairs(Window.Navigation.Tabs:GetChildren()) do
if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "InActive Template" then
if tabbtn.Name == currentTab then
TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.41}):Play()
end
TweenService:Create(tabbtn.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
TweenService:Create(tabbtn.DropShadowHolder.DropShadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
end
end
end
​local function Maximise(Window)
Window.Controls.ToggleSize.ImageLabel.Image = "rbxassetid://10137941941"
tween(Window, {Size = MainSize})
Window.Elements.Visible = true
Window.Navigation.Visible = true
end
​local function Minimize(Window)
Window.Controls.ToggleSize.ImageLabel.Image = "rbxassetid://11036884234"
Window.Elements.Visible = false
Window.Navigation.Visible = false
tween(Window, {Size = MinSize})
end
​-- Unified Mobile + PC Element Builder used by both Tab and Section
local function AttachElementBuilders(TargetContainer, RootScrollPage, IsSectionFrame, SectionLabel)
local API = {}
​local function PrepSectionOffset()
if IsSectionFrame then
TargetContainer.Position = UDim2.new(0, 0, 0, 28)
end
end
​local function RefreshParentSizes()
if IsSectionFrame and SectionLabel then
local layout = TargetContainer:FindFirstChildWhichIsA("UIListLayout")
if layout then
local contentY = layout.AbsoluteContentSize.Y
TargetContainer.Size = UDim2.new(TargetContainer.Size.X.Scale, TargetContainer.Size.X.Offset, 0, contentY + 6)
SectionLabel.Size = UDim2.new(SectionLabel.Size.X.Scale, SectionLabel.Size.X.Offset, 0, contentY + 34)
end
end
if RootScrollPage and RootScrollPage:IsA("ScrollingFrame") then
local pLayout = RootScrollPage:FindFirstChildWhichIsA("UIListLayout")
if pLayout then
RootScrollPage.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 36)
end
end
end
​function API:CreateDivider()
PrepSectionOffset()
local b = Elements.Template.Divider:Clone()
b.Parent = TargetContainer
if IsSectionFrame then
b.Size = UDim2.new(1, 0, 0, 18)
end
b.Line.BackgroundTransparency = 1
tween(b.Line, {BackgroundTransparency = 0})
task.defer(RefreshParentSizes)
end
​function API:CreateButton(ButtonSettings)
PrepSectionOffset()
​ButtonSettings = Kwargify({
Name = "Button",
Description = nil,
Callback = function() end,
}, ButtonSettings or {})
​local ButtonV = {
Hover = false,
Settings = ButtonSettings
}
​local hasDesc = ButtonSettings.Description ~= nil and ButtonSettings.Description ~= ""
local Button = hasDesc and Elements.Template.ButtonDesc:Clone() or Elements.Template.Button:Clone()
​Button.Name = ButtonSettings.Name
Button.Title.Text = ButtonSettings.Name
if hasDesc and Button:FindFirstChild("Desc") then
Button.Desc.Text = ButtonSettings.Description
end
Button.Visible = true
Button.Parent = TargetContainer
​Button.UIStroke.Transparency = 1
Button.Title.TextTransparency = 1
if hasDesc and Button:FindFirstChild("Desc") then
Button.Desc.TextTransparency = 1
end
​TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(Button.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
TweenService:Create(Button.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
if hasDesc and Button:FindFirstChild("Desc") then
TweenService:Create(Button.Desc, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
end
​BindTap(Button.Interact, function()
local Success, Response = pcall(ButtonSettings.Callback)
if not Success then
TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(Button.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
Button.Title.Text = "Callback Error"
print("Luna Interface Suite | "..ButtonSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
Button.Title.Text = ButtonSettings.Name
TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(Button.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
else
tween(Button.UIStroke, {Color = Color3.fromRGB(136, 131, 163)})
task.wait(0.2)
if ButtonV.Hover then
tween(Button.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
else
tween(Button.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end
end
end)
​Button.MouseEnter:Connect(function()
ButtonV.Hover = true
tween(Button.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
end)
​Button.MouseLeave:Connect(function()
ButtonV.Hover = false
tween(Button.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end)
​function ButtonV:Set(ButtonSettings2)
ButtonSettings2 = Kwargify({
Name = ButtonSettings.Name,
Description = ButtonSettings.Description,
Callback = ButtonSettings.Callback
}, ButtonSettings2 or {})
​ButtonSettings = ButtonSettings2
ButtonV.Settings = ButtonSettings2
​Button.Name = ButtonSettings.Name
Button.Title.Text = ButtonSettings.Name
if ButtonSettings.Description ~= nil and ButtonSettings.Description ~= "" and Button:FindFirstChild("Desc") then
Button.Desc.Text = ButtonSettings.Description
end
end
​function ButtonV:Destroy()
Button.Visible = false
Button:Destroy()
task.defer(RefreshParentSizes)
end
​task.defer(RefreshParentSizes)
return ButtonV
end
​function API:CreateLabel(LabelSettings)
PrepSectionOffset()
​local LabelV = {}
​LabelSettings = Kwargify({
Text = "Label",
Style = 1
}, LabelSettings or {})
​LabelV.Settings = LabelSettings
​local Label
if LabelSettings.Style == 1 then
Label = Elements.Template.Label:Clone()
elseif LabelSettings.Style == 2 then
Label = Elements.Template.Info:Clone()
elseif LabelSettings.Style == 3 then
Label = Elements.Template.Warn:Clone()
else
Label = Elements.Template.Label:Clone()
end
​-- Hide any icon inside Info/Warn labels
for _, child in ipairs(Label:GetChildren()) do
if child:IsA("ImageLabel") then
child.Image = ""
child.Visible = false
end
end
​Label.Text.Text = LabelSettings.Text
Label.Visible = true
Label.Parent = TargetContainer
​Label.BackgroundTransparency = 1
Label.UIStroke.Transparency = 1
Label.Text.TextTransparency = 1
​if LabelSettings.Style ~= 1 then
TweenService:Create(Label, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.8}):Play()
else
TweenService:Create(Label, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
end
TweenService:Create(Label.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
TweenService:Create(Label.Text, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
​function LabelV:Set(NewLabel)
LabelSettings.Text = NewLabel
LabelV.Settings = LabelSettings
Label.Text.Text = NewLabel
end
​function LabelV:Destroy()
Label.Visible = false
Label:Destroy()
task.defer(RefreshParentSizes)
end
​task.defer(RefreshParentSizes)
return LabelV
end
​function API:CreateParagraph(ParagraphSettings)
PrepSectionOffset()
​ParagraphSettings = Kwargify({
Title = "Paragraph",
Text = "Lorem ipsum dolor sit amet."
}, ParagraphSettings or {})
​local ParagraphV = {
Settings = ParagraphSettings
}
​local Paragraph = Elements.Template.Paragraph:Clone()
Paragraph.Title.Text = ParagraphSettings.Title
Paragraph.Text.Text = tostring(ParagraphSettings.Text)
Paragraph.Visible = true
Paragraph.Parent = TargetContainer
​Paragraph.BackgroundTransparency = 1
Paragraph.UIStroke.Transparency = 1
Paragraph.Title.TextTransparency = 1
Paragraph.Text.TextTransparency = 1
​TweenService:Create(Paragraph, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
TweenService:Create(Paragraph.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
TweenService:Create(Paragraph.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
TweenService:Create(Paragraph.Text, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
​function ParagraphV:Update()
task.defer(function()
if not Paragraph or not Paragraph.Parent then return end
Paragraph.Text.Size = UDim2.new(Paragraph.Text.Size.X.Scale, Paragraph.Text.Size.X.Offset, 0, math.huge)
local textY = Paragraph.Text.TextBounds.Y
Paragraph.Text.Size = UDim2.new(Paragraph.Text.Size.X.Scale, Paragraph.Text.Size.X.Offset, 0, textY)
Paragraph.Size = UDim2.new(Paragraph.Size.X.Scale, Paragraph.Size.X.Offset, 0, textY + 40)
RefreshParentSizes()
end)
end
​function ParagraphV:Set(NewParagraphSettings)
if type(NewParagraphSettings) == "string" then
NewParagraphSettings = {Title = ParagraphSettings.Title, Text = NewParagraphSettings}
end
NewParagraphSettings = Kwargify({
Title = ParagraphSettings.Title,
Text = ParagraphSettings.Text
}, NewParagraphSettings or {})
​ParagraphSettings = NewParagraphSettings
ParagraphV.Settings = NewParagraphSettings
​Paragraph.Title.Text = NewParagraphSettings.Title
Paragraph.Text.Text = tostring(NewParagraphSettings.Text)
​ParagraphV:Update()
end
​function ParagraphV:Destroy()
Paragraph.Visible = false
Paragraph:Destroy()
task.defer(RefreshParentSizes)
end
​ParagraphV:Update()
return ParagraphV
end
​-- Mobile-Adapted Slider (supports Touch + Mouse + UIScale + Scroll Lock)
function API:CreateSlider(SliderSettings, Flag)
PrepSectionOffset()
local SliderV = { IgnoreConfig = false, Class = "Slider", Settings = SliderSettings }
​SliderSettings = Kwargify({
Name = "Slider",
Range = {0, 200},
Increment = 1,
CurrentValue = 100,
Callback = function(Value) end,
}, SliderSettings or {})
​local SLDragging = false
local ActiveInput = nil
local Slider = Elements.Template.Slider:Clone()
Slider.Name = SliderSettings.Name .. " - Slider"
Slider.Title.Text = SliderSettings.Name
Slider.Visible = true
Slider.Parent = TargetContainer
​Slider.BackgroundTransparency = 1
Slider.UIStroke.Transparency = 1
Slider.Title.TextTransparency = 1
​TweenService:Create(Slider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(Slider.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
TweenService:Create(Slider.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
​local function GetNormalizedRatio(val)
local minVal = SliderSettings.Range[1]
local maxVal = SliderSettings.Range[2]
if maxVal == minVal then return 0 end
return math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
end
​local function UpdateProgressVisual(val, animated)
local barWidth = Slider.Main.AbsoluteSize.X
local ratio = GetNormalizedRatio(val)
local targetSize
if barWidth > 0 then
local px = math.max(barWidth * ratio, 5)
targetSize = UDim2.new(0, px, 1, 0)
else
targetSize = UDim2.new(ratio, 0, 1, 0)
end
if animated then
TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
else
Slider.Main.Progress.Size = targetSize
end
end
​local function FireSliderCallback(NewValue)
local Success, Response = pcall(function()
SliderSettings.Callback(NewValue)
end)
if not Success then
TweenService:Create(Slider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(Slider.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
Slider.Title.Text = "Callback Error"
print("Luna Interface Suite | "..SliderSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
Slider.Title.Text = SliderSettings.Name
TweenService:Create(Slider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(Slider.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
end
end
​local UpdatingFromDrag = false
​local function UpdateSliderFromScreenX(screenX)
local barPos = Slider.Main.AbsolutePosition.X
local barSize = math.max(Slider.Main.AbsoluteSize.X, 1)
local ratio = math.clamp((screenX - barPos) / barSize, 0, 1)
​local minVal = SliderSettings.Range[1]
local maxVal = SliderSettings.Range[2]
local rawVal = minVal + ratio * (maxVal - minVal)
local inc = SliderSettings.Increment > 0 and SliderSettings.Increment or 1
local NewValue = math.floor(rawVal / inc + 0.5) * (inc * 10000000) / 10000000
NewValue = math.clamp(NewValue, minVal, maxVal)
​UpdatingFromDrag = true
Slider.Value.Text = tostring(NewValue)
Slider.Value.Size = UDim2.fromOffset( math.max(Slider.Value.TextBounds.X, 18), 23)
UpdatingFromDrag = false
​UpdateProgressVisual(NewValue, false)
​if SliderSettings.CurrentValue ~= NewValue then
SliderSettings.CurrentValue = NewValue
SliderV.CurrentValue = NewValue
FireSliderCallback(NewValue)
end
end
​task.defer(function()
UpdateProgressVisual(SliderSettings.CurrentValue, false)
end)
Slider.Value.Text = tostring(SliderSettings.CurrentValue)
SliderV.CurrentValue = SliderSettings.CurrentValue
FireSliderCallback(SliderSettings.CurrentValue)
​Slider.MouseEnter:Connect(function()
tween(Slider.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
end)
​Slider.MouseLeave:Connect(function()
tween(Slider.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end)
​local function BeginSlide(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
SLDragging = true
ActiveInput = Input
if RootScrollPage and RootScrollPage:IsA("ScrollingFrame") then
RootScrollPage.ScrollingEnabled = false
end
UpdateSliderFromScreenX(Input.Position.X)
end
end
​Slider.Interact.InputBegan:Connect(BeginSlide)
Slider.Main.InputBegan:Connect(BeginSlide)
​UserInputService.InputChanged:Connect(function(Input)
if not SLDragging then return end
if Input == ActiveInput or Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
UpdateSliderFromScreenX(Input.Position.X)
end
end)
​UserInputService.InputEnded:Connect(function(Input)
if SLDragging and (Input == ActiveInput or Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
SLDragging = false
ActiveInput = nil
if RootScrollPage and RootScrollPage:IsA("ScrollingFrame") then
RootScrollPage.ScrollingEnabled = true
end
end
end)
​local function Set(NewVal, fromTextBox)
NewVal = tonumber(NewVal) or SliderSettings.CurrentValue
NewVal = math.clamp(NewVal, SliderSettings.Range[1], SliderSettings.Range[2])
UpdateProgressVisual(NewVal, true)
if not fromTextBox then
UpdatingFromDrag = true
Slider.Value.Text = tostring(NewVal)
UpdatingFromDrag = false
end
SliderSettings.CurrentValue = NewVal
SliderV.CurrentValue = NewVal
FireSliderCallback(NewVal)
end
​function SliderV:UpdateValue(Value)
Set(tonumber(Value))
end
​Slider.Value:GetPropertyChangedSignal("Text"):Connect(function()
if UpdatingFromDrag then return end
local text = Slider.Value.Text
if not tonumber(text) and text ~= "." and text ~= "-" then
Slider.Value.Text = text:match("[-0-9.]*") or ""
end
local num = tonumber(Slider.Value.Text)
if num then
if num > SliderSettings.Range[2] then
num = SliderSettings.Range[2]
Slider.Value.Text = tostring(num)
end
Slider.Value.Size = UDim2.fromOffset(math.max(Slider.Value.TextBounds.X, 18), 23)
Set(num, true)
end
end)
​function SliderV:Set(NewSliderSettings)
NewSliderSettings = Kwargify({
Name = SliderSettings.Name,
Range = SliderSettings.Range,
Increment = SliderSettings.Increment,
CurrentValue = SliderSettings.CurrentValue,
Callback = SliderSettings.Callback
}, NewSliderSettings or {})
​SliderSettings = NewSliderSettings
SliderV.Settings = NewSliderSettings
​Slider.Name = SliderSettings.Name .. " - Slider"
Slider.Title.Text = SliderSettings.Name
​Set(SliderSettings.CurrentValue)
end
​function SliderV:Destroy()
Slider.Visible = false
Slider:Destroy()
task.defer(RefreshParentSizes)
end
​if Flag then
Luna.Options[Flag] = SliderV
end
​LunaUI.ThemeRemote:GetPropertyChangedSignal("Value"):Connect(function()
Slider.Main.color.Color = Luna.ThemeGradient
Slider.Main.UIStroke.color.Color = Luna.ThemeGradient
end)
​task.defer(RefreshParentSizes)
return SliderV
end
​-- Mobile-Adapted Toggle
function API:CreateToggle(ToggleSettings, Flag)
PrepSectionOffset()
local ToggleV = { IgnoreConfig = false, Class = "Toggle" }
​ToggleSettings = Kwargify({
Name = "Toggle",
Description = nil,
CurrentValue = false,
Callback = function(Value) end,
}, ToggleSettings or {})
​local hasDesc = ToggleSettings.Description ~= nil and ToggleSettings.Description ~= ""
local Toggle = hasDesc and Elements.Template.ToggleDesc:Clone() or Elements.Template.Toggle:Clone()
​Toggle.Visible = true
Toggle.Parent = TargetContainer
​Toggle.Name = ToggleSettings.Name .. " - Toggle"
Toggle.Title.Text = ToggleSettings.Name
if hasDesc and Toggle:FindFirstChild("Desc") then
Toggle.Desc.Text = ToggleSettings.Description
end
​Toggle.UIStroke.Transparency = 1
Toggle.Title.TextTransparency = 1
if hasDesc and Toggle:FindFirstChild("Desc") then
Toggle.Desc.TextTransparency = 1
end
​TweenService:Create(Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5}):Play()
if hasDesc and Toggle:FindFirstChild("Desc") then
TweenService:Create(Toggle.Desc, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
end
TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
TweenService:Create(Toggle.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
​local function Set(bool)
if bool then
Toggle.toggle.color.Enabled = true
tween(Toggle.toggle, {BackgroundTransparency = 0})
Toggle.toggle.UIStroke.color.Enabled = true
tween(Toggle.toggle.UIStroke, {Color = Color3.new(1, 1, 1)})
tween(Toggle.toggle.val, {BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -23, 0.5, 0), BackgroundTransparency = 0.45})
else
Toggle.toggle.color.Enabled = false
Toggle.toggle.UIStroke.color.Enabled = false
Toggle.toggle.UIStroke.Color = Color3.fromRGB(97, 97, 97)
tween(Toggle.toggle, {BackgroundTransparency = 1})
tween(Toggle.toggle.val, {BackgroundColor3 = Color3.fromRGB(97, 97, 97), Position = UDim2.new(0, 5, 0.5, 0), BackgroundTransparency = 0})
end
ToggleV.CurrentValue = bool
end
​BindTap(Toggle.Interact, function()
ToggleSettings.CurrentValue = not ToggleSettings.CurrentValue
Set(ToggleSettings.CurrentValue)
​local Success, Response = pcall(function()
ToggleSettings.Callback(ToggleSettings.CurrentValue)
end)
if not Success then
TweenService:Create(Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
Toggle.Title.Text = "Callback Error"
print("Luna Interface Suite | "..ToggleSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
Toggle.Title.Text = ToggleSettings.Name
TweenService:Create(Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
end
end)
​Toggle.MouseEnter:Connect(function()
tween(Toggle.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
end)
​Toggle.MouseLeave:Connect(function()
tween(Toggle.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end)
​if ToggleSettings.CurrentValue then
Set(ToggleSettings.CurrentValue)
pcall(function()
ToggleSettings.Callback(ToggleSettings.CurrentValue)
end)
else
Set(false)
end
​function ToggleV:UpdateState(State)
ToggleSettings.CurrentValue = State
Set(ToggleSettings.CurrentValue)
end
​function ToggleV:Set(NewToggleSettings)
NewToggleSettings = Kwargify({
Name = ToggleSettings.Name,
Description = ToggleSettings.Description,
CurrentValue = ToggleSettings.CurrentValue,
Callback = ToggleSettings.Callback
}, NewToggleSettings or {})
​ToggleV.Settings = NewToggleSettings
ToggleSettings = NewToggleSettings
​Toggle.Name = ToggleSettings.Name .. " - Toggle"
Toggle.Title.Text = ToggleSettings.Name
if ToggleSettings.Description ~= nil and ToggleSettings.Description ~= "" and Toggle:FindFirstChild("Desc") then
Toggle.Desc.Text = ToggleSettings.Description
end
​Set(ToggleSettings.CurrentValue)
ToggleV.CurrentValue = ToggleSettings.CurrentValue
pcall(function()
ToggleSettings.Callback(ToggleSettings.CurrentValue)
end)
end
​function ToggleV:Destroy()
Toggle.Visible = false
Toggle:Destroy()
task.defer(RefreshParentSizes)
end
​LunaUI.ThemeRemote:GetPropertyChangedSignal("Value"):Connect(function()
Toggle.toggle.color.Color = Luna.ThemeGradient
Toggle.toggle.UIStroke.color.Color = Luna.ThemeGradient
end)
​if Flag then
Luna.Options[Flag] = ToggleV
end
​task.defer(RefreshParentSizes)
return ToggleV
end
​-- Mobile-Adapted Bind / Keybind (allows touch tap activation on mobile + keyboard binding)
function API:CreateBind(BindSettings, Flag)
PrepSectionOffset()
local BindV = { Class = "Keybind", IgnoreConfig = false, Settings = BindSettings, Active = false }
​BindSettings = Kwargify({
Name = "Bind",
Description = nil,
CurrentBind = "Q",
HoldToInteract = false,
Callback = function(Bind) end,
OnChangedCallback = function(Bind) end,
}, BindSettings or {})
​if BindSettings.CurrentKeybind and not BindSettings.CurrentBind then
BindSettings.CurrentBind = BindSettings.CurrentKeybind
end
​local CheckingForKey = false
​local hasDesc = BindSettings.Description ~= nil and BindSettings.Description ~= ""
local Bind = hasDesc and Elements.Template.BindDesc:Clone() or Elements.Template.Bind:Clone()
​Bind.Visible = true
Bind.Parent = TargetContainer
​Bind.Name = BindSettings.Name
Bind.Title.Text = BindSettings.Name
if hasDesc and Bind:FindFirstChild("Desc") then
Bind.Desc.Text = BindSettings.Description
end
​Bind.Title.TextTransparency = 1
if hasDesc and Bind:FindFirstChild("Desc") then
Bind.Desc.TextTransparency = 1
end
Bind.BindFrame.BackgroundTransparency = 1
Bind.BindFrame.UIStroke.Transparency = 1
Bind.BindFrame.BindBox.TextTransparency = 1
​TweenService:Create(Bind, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(Bind.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
if hasDesc and Bind:FindFirstChild("Desc") then
TweenService:Create(Bind.Desc, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
end
TweenService:Create(Bind.BindFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.9}):Play()
TweenService:Create(Bind.BindFrame.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.3}):Play()
TweenService:Create(Bind.BindFrame.BindBox, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
​Bind.BindFrame.BindBox.Text = tostring(BindSettings.CurrentBind)
Bind.BindFrame.BindBox.Size = UDim2.new(0, math.max(Bind.BindFrame.BindBox.TextBounds.X + 20, 36), 0, 42)
​local function ExecuteBindCallback(state)
local Success, Response = pcall(function()
BindSettings.Callback(state)
end)
if not Success then
TweenService:Create(Bind, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(Bind.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
Bind.Title.Text = "Callback Error"
print("Luna Interface Suite | "..BindSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
Bind.Title.Text = BindSettings.Name
TweenService:Create(Bind, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(Bind.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
end
end
​-- Mobile touch support: tapping the Bind row toggles the bind directly so mobile users can activate keybinds
BindTap(Bind, function()
if CheckingForKey then return end
if IsMobile then
BindV.Active = not BindV.Active
tween(Bind.BindFrame.UIStroke, {Color = BindV.Active and Color3.fromRGB(123, 201, 201) or Color3.fromRGB(64, 61, 76)})
ExecuteBindCallback(BindV.Active)
end
end)
​Bind.BindFrame.BindBox.Focused:Connect(function()
CheckingForKey = true
Bind.BindFrame.BindBox.Text = ""
end)
​Bind.BindFrame.BindBox.FocusLost:Connect(function()
CheckingForKey = false
if Bind.BindFrame.BindBox.Text == nil or Bind.BindFrame.BindBox.Text == "" then
Bind.BindFrame.BindBox.Text = tostring(BindSettings.CurrentBind)
end
end)
​Bind.MouseEnter:Connect(function()
tween(Bind.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
end)
​Bind.MouseLeave:Connect(function()
tween(Bind.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end)
​UserInputService.InputBegan:Connect(function(input, processed)
if CheckingForKey then
if input.KeyCode ~= Enum.KeyCode.Unknown then
local SplitMessage = string.split(tostring(input.KeyCode), ".")
local NewKeyNoEnum = SplitMessage[3]
Bind.BindFrame.BindBox.Text = tostring(NewKeyNoEnum)
BindSettings.CurrentBind = tostring(NewKeyNoEnum)
BindV.CurrentBind = BindSettings.CurrentBind
pcall(function()
BindSettings.OnChangedCallback(BindSettings.CurrentBind)
end)
Bind.BindFrame.BindBox:ReleaseFocus()
end
elseif BindSettings.CurrentBind ~= nil and not processed then
local ok, targetKey = pcall(function() return Enum.KeyCode[BindSettings.CurrentBind] end)
if ok and targetKey and input.KeyCode == targetKey then
local Held = true
local Connection
Connection = input.Changed:Connect(function(prop)
if prop == "UserInputState" then
Connection:Disconnect()
Held = false
end
end)
​if not BindSettings.HoldToInteract then
BindV.Active = not BindV.Active
ExecuteBindCallback(BindV.Active)
else
task.wait(0.1)
if Held then
local Loop; Loop = RunService.Stepped:Connect(function()
if not Held then
ExecuteBindCallback(false)
Loop:Disconnect()
else
ExecuteBindCallback(true)
end
end)
end
end
end
end
end)
​Bind.BindFrame.BindBox:GetPropertyChangedSignal("Text"):Connect(function()
-- Support mobile virtual keyboard typing a key into BindBox
if CheckingForKey and #Bind.BindFrame.BindBox.Text > 0 then
local typed = string.upper(string.sub(Bind.BindFrame.BindBox.Text, 1, 1))
local ok, kc = pcall(function() return Enum.KeyCode[typed] end)
if ok and kc then
CheckingForKey = false
Bind.BindFrame.BindBox.Text = typed
BindSettings.CurrentBind = typed
BindV.CurrentBind = typed
pcall(function()
BindSettings.OnChangedCallback(typed)
end)
Bind.BindFrame.BindBox:ReleaseFocus()
end
end
TweenService:Create(Bind.BindFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, math.max(Bind.BindFrame.BindBox.TextBounds.X + 20, 36), 0, 30)}):Play()
end)
​function BindV:Set(NewBindSettings)
NewBindSettings = Kwargify({
Name = BindSettings.Name,
Description = BindSettings.Description,
CurrentBind = BindSettings.CurrentBind,
HoldToInteract = BindSettings.HoldToInteract,
Callback = BindSettings.Callback
}, NewBindSettings or {})
​BindV.Settings = NewBindSettings
BindSettings = NewBindSettings
​Bind.Name = BindSettings.Name
Bind.Title.Text = BindSettings.Name
if BindSettings.Description ~= nil and BindSettings.Description ~= "" and Bind:FindFirstChild("Desc") then
Bind.Desc.Text = BindSettings.Description
end
​Bind.BindFrame.BindBox.Text = tostring(BindSettings.CurrentBind)
Bind.BindFrame.Size = UDim2.new(0, math.max(Bind.BindFrame.BindBox.TextBounds.X + 20, 36), 0, 30)
BindV.CurrentBind = BindSettings.CurrentBind
end
​function BindV:Destroy()
Bind.Visible = false
Bind:Destroy()
task.defer(RefreshParentSizes)
end
​if Flag then
Luna.Options[Flag] = BindV
end
​task.defer(RefreshParentSizes)
return BindV
end
​function API:CreateKeybind(BindSettings, Flag)
return API:CreateBind(BindSettings, Flag)
end
​-- Mobile-Adapted Dynamic Input
function API:CreateInput(InputSettings, Flag)
PrepSectionOffset()
local InputV = { IgnoreConfig = false, Class = "Input", Settings = InputSettings }
​InputSettings = Kwargify({
Name = "Dynamic Input",
Description = nil,
CurrentValue = "",
PlaceholderText = "Input Placeholder",
RemoveTextAfterFocusLost = false,
Numeric = false,
Enter = false,
MaxCharacters = nil,
Callback = function(Text) end,
}, InputSettings or {})
​InputV.CurrentValue = InputSettings.CurrentValue
​local descriptionbool = InputSettings.Description ~= nil and InputSettings.Description ~= ""
local Input = descriptionbool and Elements.Template.InputDesc:Clone() or Elements.Template.Input:Clone()
​Input.Name = InputSettings.Name
Input.Title.Text = InputSettings.Name
if descriptionbool and Input:FindFirstChild("Desc") then
Input.Desc.Text = InputSettings.Description
end
Input.Visible = true
Input.Parent = TargetContainer
​Input.BackgroundTransparency = 1
Input.UIStroke.Transparency = 1
Input.Title.TextTransparency = 1
if descriptionbool and Input:FindFirstChild("Desc") then
Input.Desc.TextTransparency = 1
end
Input.InputFrame.BackgroundTransparency = 1
Input.InputFrame.UIStroke.Transparency = 1
Input.InputFrame.InputBox.TextTransparency = 1
​TweenService:Create(Input, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(Input.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
TweenService:Create(Input.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
if descriptionbool and Input:FindFirstChild("Desc") then
TweenService:Create(Input.Desc, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
end
TweenService:Create(Input.InputFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.9}):Play()
TweenService:Create(Input.InputFrame.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.3}):Play()
TweenService:Create(Input.InputFrame.InputBox, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
​Input.InputFrame.InputBox.PlaceholderText = InputSettings.PlaceholderText
Input.InputFrame.Size = UDim2.new(0, math.clamp(Input.InputFrame.InputBox.TextBounds.X + 52, 90, 220), 0, 30)
​Input.InputFrame.InputBox.FocusLost:Connect(function(enterPressed)
if InputSettings.Enter then
-- On mobile virtual keyboards, dismissing the keyboard doesn't always pass enterPressed=true
if enterPressed or IsMobile then
local Success, Response = pcall(function()
InputSettings.Callback(Input.InputFrame.InputBox.Text)
InputV.CurrentValue = Input.InputFrame.InputBox.Text
end)
if not Success then
TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
Input.Title.Text = "Callback Error"
print("Luna Interface Suite | "..InputSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
Input.Title.Text = InputSettings.Name
TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
end
end
end
​if InputSettings.RemoveTextAfterFocusLost then
Input.InputFrame.InputBox.Text = ""
end
end)
​if InputSettings.Numeric then
Input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
local text = Input.InputFrame.InputBox.Text
if not tonumber(text) and text ~= "." then
Input.InputFrame.InputBox.Text = text:match("[0-9.]*") or ""
end
end)
end
​Input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
if tonumber(InputSettings.MaxCharacters) then
if #Input.InputFrame.InputBox.Text > InputSettings.MaxCharacters then
Input.InputFrame.InputBox.Text = Input.InputFrame.InputBox.Text:sub(1, InputSettings.MaxCharacters)
end
end
TweenService:Create(Input.InputFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, math.clamp(Input.InputFrame.InputBox.TextBounds.X + 52, 90, 220), 0, 30)}):Play()
if not InputSettings.Enter then
local Success, Response = pcall(function()
InputSettings.Callback(Input.InputFrame.InputBox.Text)
end)
if not Success then
TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
Input.Title.Text = "Callback Error"
print("Luna Interface Suite | "..InputSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
Input.Title.Text = InputSettings.Name
TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
end
end
InputV.CurrentValue = Input.InputFrame.InputBox.Text
end)
​Input.MouseEnter:Connect(function()
tween(Input.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
end)
​Input.MouseLeave:Connect(function()
tween(Input.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end)
​function InputV:Set(NewInputSettings)
NewInputSettings = Kwargify(InputSettings, NewInputSettings or {})
​InputV.Settings = NewInputSettings
InputSettings = NewInputSettings
​Input.Name = InputSettings.Name
Input.Title.Text = InputSettings.Name
if InputSettings.Description ~= nil and InputSettings.Description ~= "" and Input:FindFirstChild("Desc") then
Input.Desc.Text = InputSettings.Description
end
​Input.InputFrame.InputBox.Text = tostring(InputSettings.CurrentValue)
Input.InputFrame.Size = UDim2.new(0, math.clamp(Input.InputFrame.InputBox.TextBounds.X + 52, 90, 220), 0, 30)
InputV.CurrentValue = InputSettings.CurrentValue
end
​function InputV:Destroy()
Input.Visible = false
Input:Destroy()
task.defer(RefreshParentSizes)
end
​if Flag then
Luna.Options[Flag] = InputV
end
​task.defer(RefreshParentSizes)
return InputV
end
​-- Mobile-Adapted Dropdown
function API:CreateDropdown(DropdownSettings, Flag)
PrepSectionOffset()
local DropdownV = { IgnoreConfig = false, Class = "Dropdown", Settings = DropdownSettings }
​DropdownSettings = Kwargify({
Name = "Dropdown",
Description = nil,
Options = {"Option 1", "Option 2"},
CurrentOption = {"Option 1"},
MultipleOptions = false,
SpecialType = nil,
Callback = function(Options) end,
}, DropdownSettings or {})
​DropdownV.CurrentOption = DropdownSettings.CurrentOption
​local descriptionbool = DropdownSettings.Description ~= nil and DropdownSettings.Description ~= ""
local closedsize = descriptionbool and 48 or 38
local openedsize = descriptionbool and 170 or 160
local opened = false
​local Dropdown = descriptionbool and Elements.Template.DropdownDesc:Clone() or Elements.Template.Dropdown:Clone()
​Dropdown.Name = DropdownSettings.Name
Dropdown.Title.Text = DropdownSettings.Name
if descriptionbool and Dropdown:FindFirstChild("Desc") then
Dropdown.Desc.Text = DropdownSettings.Description
end
​Dropdown.Parent = TargetContainer
Dropdown.Visible = true
SetupAutoScroll(Dropdown.List)
​local function Toggle()
opened = not opened
if opened then
tween(Dropdown.icon, {Rotation = 180})
tween(Dropdown, {Size = UDim2.new(1, -25, 0, openedsize)}, function()
RefreshParentSizes()
end)
else
tween(Dropdown.icon, {Rotation = 0})
tween(Dropdown, {Size = UDim2.new(1, -25, 0, closedsize)}, function()
RefreshParentSizes()
end)
end
task.delay(0.1, RefreshParentSizes)
task.delay(0.32, RefreshParentSizes)
end
​local function SafeCallback(param, c2)
local Success, Response = pcall(function()
DropdownSettings.Callback(param)
end)
if not Success then
TweenService:Create(Dropdown, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
Dropdown.Title.Text = "Callback Error"
print("Luna Interface Suite | "..DropdownSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
Dropdown.Title.Text = DropdownSettings.Name
TweenService:Create(Dropdown, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
end
if Success and c2 then
c2()
end
end
​Dropdown.Selected:GetPropertyChangedSignal("Text"):Connect(function()
local text = Dropdown.Selected.Text:lower()
for _, Item in ipairs(Dropdown.List:GetChildren()) do
if Item:IsA("TextLabel") and Item.Name ~= "Template" then
Item.Visible = text == "" or string.find(Item.Name:lower(), text, 1, true) ~= nil
end
end
end)
​local function Clear()
for _, option in ipairs(Dropdown.List:GetChildren()) do
if option.ClassName == "TextLabel" and option.Name ~= "Template" then
option:Destroy()
end
end
end
​local function ActivateColorSingle(name)
for _, Option in pairs(Dropdown.List:GetChildren()) do
if Option.ClassName == "TextLabel" and Option.Name ~= "Template" then
tween(Option, {BackgroundTransparency = 0.98})
end
end
​Toggle()
local targetOpt = name and Dropdown.List:FindFirstChild(tostring(name))
if targetOpt then
tween(targetOpt, {BackgroundTransparency = 0.95, TextColor3 = Color3.fromRGB(240, 240, 240)})
end
end
​local function Refresh()
Clear()
for i, v in pairs(DropdownSettings.Options) do
local Option = Dropdown.List.Template:Clone()
local optionhover = false
Option.Text = tostring(v)
if v == "Template" then v = "Template (Name)" end
Option.Name = tostring(v)
Option.Visible = true
Option.Parent = Dropdown.List
​BindTap(Option.Interact, function()
local bleh
if DropdownSettings.MultipleOptions then
if type(DropdownSettings.CurrentOption) ~= "table" then
DropdownSettings.CurrentOption = {}
end
if table.find(DropdownSettings.CurrentOption, v) then
RemoveTable(DropdownSettings.CurrentOption, v)
DropdownV.CurrentOption = DropdownSettings.CurrentOption
if not optionhover then
tween(Option, {TextColor3 = Color3.fromRGB(200, 200, 200)})
end
tween(Option, {BackgroundTransparency = 0.98})
else
table.insert(DropdownSettings.CurrentOption, v)
DropdownV.CurrentOption = DropdownSettings.CurrentOption
tween(Option, {TextColor3 = Color3.fromRGB(240, 240, 240), BackgroundTransparency = 0.95})
end
bleh = DropdownSettings.CurrentOption
else
DropdownSettings.CurrentOption = {v}
bleh = v
DropdownV.CurrentOption = bleh
ActivateColorSingle(v)
end
​SafeCallback(bleh, function()
if DropdownSettings.MultipleOptions then
if DropdownSettings.CurrentOption and type(DropdownSettings.CurrentOption) == "table" then
if #DropdownSettings.CurrentOption == 1 then
Dropdown.Selected.PlaceholderText = tostring(DropdownSettings.CurrentOption[1])
elseif #DropdownSettings.CurrentOption == 0 then
Dropdown.Selected.PlaceholderText = "None"
else
Dropdown.Selected.PlaceholderText = unpackt(DropdownSettings.CurrentOption)
end
else
DropdownSettings.CurrentOption = {}
Dropdown.Selected.PlaceholderText = "None"
end
else
Dropdown.Selected.PlaceholderText = tostring(DropdownSettings.CurrentOption[1] or "None")
end
Dropdown.Selected.Text = ""
end)
end)
​Option.MouseEnter:Connect(function()
optionhover = true
if Option.BackgroundTransparency ~= 0.95 then
tween(Option, {TextColor3 = Color3.fromRGB(240, 240, 240)})
end
end)
Option.MouseLeave:Connect(function()
optionhover = false
if Option.BackgroundTransparency ~= 0.95 then
tween(Option, {TextColor3 = Color3.fromRGB(200, 200, 200)})
end
end)
end
end
​local function PlayerTableRefresh()
table.clear(DropdownSettings.Options)
for _, v in ipairs(Players:GetPlayers()) do
table.insert(DropdownSettings.Options, v.Name)
end
end
​BindTap(Dropdown.Interact, function()
Toggle()
end)
​Dropdown.MouseEnter:Connect(function()
tween(Dropdown.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
end)
​Dropdown.MouseLeave:Connect(function()
tween(Dropdown.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end)
​if DropdownSettings.SpecialType == "Player" then
PlayerTableRefresh()
DropdownSettings.CurrentOption = DropdownSettings.Options[1]
Players.PlayerAdded:Connect(function() PlayerTableRefresh() Refresh() end)
Players.PlayerRemoving:Connect(function() PlayerTableRefresh() Refresh() end)
end
​Refresh()
​if DropdownSettings.CurrentOption then
if type(DropdownSettings.CurrentOption) == "string" then
DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
end
if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
end
else
DropdownSettings.CurrentOption = {}
end
​local bleh, ind = nil, 0
for _, v in pairs(DropdownSettings.CurrentOption) do
if v ~= nil then
ind = ind + 1
end
end
if ind == 1 then
bleh = DropdownSettings.CurrentOption[1]
else
bleh = DropdownSettings.CurrentOption
end
if bleh ~= nil and (type(bleh) ~= "table" or #bleh > 0) then
SafeCallback(bleh)
end
if type(bleh) == "string" then
local opt = Dropdown.List:FindFirstChild(bleh)
if opt then
tween(opt, {TextColor3 = Color3.fromRGB(240, 240, 240), BackgroundTransparency = 0.95})
end
elseif type(bleh) == "table" then
for _, v in pairs(bleh) do
local opt = Dropdown.List:FindFirstChild(tostring(v))
if opt then
tween(opt, {TextColor3 = Color3.fromRGB(240, 240, 240), BackgroundTransparency = 0.95})
end
end
end
​if DropdownSettings.MultipleOptions then
if DropdownSettings.CurrentOption and type(DropdownSettings.CurrentOption) == "table" then
if #DropdownSettings.CurrentOption == 1 then
Dropdown.Selected.PlaceholderText = tostring(DropdownSettings.CurrentOption[1])
elseif #DropdownSettings.CurrentOption == 0 then
Dropdown.Selected.PlaceholderText = "None"
else
Dropdown.Selected.PlaceholderText = unpackt(DropdownSettings.CurrentOption)
end
else
DropdownSettings.CurrentOption = {}
Dropdown.Selected.PlaceholderText = "None"
end
for _, name in pairs(DropdownSettings.CurrentOption) do
local opt = Dropdown.List:FindFirstChild(tostring(name))
if opt then
tween(opt, {TextColor3 = Color3.fromRGB(227, 227, 227), BackgroundTransparency = 0.95})
end
end
else
Dropdown.Selected.PlaceholderText = tostring(DropdownSettings.CurrentOption[1] or "None")
end
Dropdown.Selected.Text = ""
​function DropdownV:Set(NewDropdownSettings)
NewDropdownSettings = Kwargify(DropdownSettings, NewDropdownSettings or {})
​DropdownV.Settings = NewDropdownSettings
DropdownSettings = NewDropdownSettings
​Dropdown.Name = DropdownSettings.Name
Dropdown.Title.Text = DropdownSettings.Name
if DropdownSettings.Description ~= nil and DropdownSettings.Description ~= "" and Dropdown:FindFirstChild("Desc") then
Dropdown.Desc.Text = DropdownSettings.Description
end
​if DropdownSettings.SpecialType == "Player" then
PlayerTableRefresh()
DropdownSettings.CurrentOption = DropdownSettings.Options[1]
end
​Refresh()
​if DropdownSettings.CurrentOption then
if type(DropdownSettings.CurrentOption) == "string" then
DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
end
if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
end
else
DropdownSettings.CurrentOption = {}
end
​local bleh2, ind2 = nil, 0
for _, v in pairs(DropdownSettings.CurrentOption) do
if v ~= nil then
ind2 = ind2 + 1
end
end
if ind2 == 1 then bleh2 = DropdownSettings.CurrentOption[1] else bleh2 = DropdownSettings.CurrentOption end
if bleh2 ~= nil and (type(bleh2) ~= "table" or #bleh2 > 0) then
SafeCallback(bleh2)
end
for _, Option in pairs(Dropdown.List:GetChildren()) do
if Option.ClassName == "TextLabel" and Option.Name ~= "Template" then
tween(Option, {TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundTransparency = 0.98})
end
end
if type(bleh2) == "string" then
local opt = Dropdown.List:FindFirstChild(bleh2)
if opt then
tween(opt, {TextColor3 = Color3.fromRGB(240, 240, 240), BackgroundTransparency = 0.95})
end
elseif type(bleh2) == "table" then
for _, name in pairs(bleh2) do
local opt = Dropdown.List:FindFirstChild(tostring(name))
if opt then
tween(opt, {TextColor3 = Color3.fromRGB(227, 227, 227), BackgroundTransparency = 0.95})
end
end
end
​if DropdownSettings.MultipleOptions then
if DropdownSettings.CurrentOption and type(DropdownSettings.CurrentOption) == "table" then
if #DropdownSettings.CurrentOption == 1 then
Dropdown.Selected.PlaceholderText = tostring(DropdownSettings.CurrentOption[1])
elseif #DropdownSettings.CurrentOption == 0 then
Dropdown.Selected.PlaceholderText = "None"
else
Dropdown.Selected.PlaceholderText = unpackt(DropdownSettings.CurrentOption)
end
else
DropdownSettings.CurrentOption = {}
Dropdown.Selected.PlaceholderText = "None"
end
else
Dropdown.Selected.PlaceholderText = tostring(DropdownSettings.CurrentOption[1] or "None")
end
Dropdown.Selected.Text = ""
end
​function DropdownV:Destroy()
Dropdown.Visible = false
Dropdown:Destroy()
task.defer(RefreshParentSizes)
end
​if Flag then
Luna.Options[Flag] = DropdownV
end
​task.defer(RefreshParentSizes)
return DropdownV
end
​-- Mobile-Adapted Color Picker (Touch + Mouse + UIScale + Scroll Lock)
function API:CreateColorPicker(ColorPickerSettings, Flag)
PrepSectionOffset()
local ColorPickerV = { IgnoreClass = false, Class = "Colorpicker", Settings = ColorPickerSettings }
​ColorPickerSettings = Kwargify({
Name = "Color Picker",
Color = Color3.fromRGB(255, 255, 255),
Callback = function(Value) end
}, ColorPickerSettings or {})
​local function Color3ToHex(color)
return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
end
​ColorPickerV.Color = ColorPickerSettings.Color
​local closedsize = UDim2.new(0, 75, 0, 22)
local openedsize = UDim2.new(0, 219, 0, 129)
​local ColorPicker = Elements.Template.ColorPicker:Clone()
local Background = ColorPicker.CPBackground
local Display = Background.Display
local MainCP = Background.MainCP
local Slider = ColorPicker.ColorSlider
​ColorPicker.Name = ColorPickerSettings.Name
ColorPicker.Title.Text = ColorPickerSettings.Name
ColorPicker.Visible = true
ColorPicker.Parent = TargetContainer
ColorPicker.Size = UDim2.new(1.042, -25, 0, 38)
Background.Size = closedsize
Display.BackgroundTransparency = 0
​ColorPicker.MouseEnter:Connect(function()
tween(ColorPicker.UIStroke, {Color = Color3.fromRGB(87, 84, 104)})
end)
ColorPicker.MouseLeave:Connect(function()
tween(ColorPicker.UIStroke, {Color = Color3.fromRGB(64, 61, 76)})
end)
​local function SafeCallback(param, c2)
local Success, Response = pcall(function()
ColorPickerSettings.Callback(param)
end)
if not Success then
TweenService:Create(ColorPicker, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
ColorPicker.Title.Text = "Callback Error"
print("Luna Interface Suite | "..ColorPickerSettings.Name.." Callback Error " ..tostring(Response))
task.wait(0.5)
ColorPicker.Title.Text = ColorPickerSettings.Name
TweenService:Create(ColorPicker, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 30, 38)}):Play()
TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
end
if Success and c2 then
c2()
end
end
​local opened = false
MainCP.Image = "http://www.roblox.com/asset/?id=11415645739"
local mainDragging = false
local sliderDragging = false
​BindTap(ColorPicker.Interact, function()
if mainDragging or sliderDragging then return end
opened = not opened
if opened then
tween(ColorPicker, {Size = UDim2.new(1.042, -25, 0, 165)}, function()
RefreshParentSizes()
end, TweenInfo.new(0.6, Enum.EasingStyle.Exponential))
tween(Background, {Size = openedsize})
tween(Display, {BackgroundTransparency = 1})
else
tween(ColorPicker, {Size = UDim2.new(1.042, -25, 0, 38)}, function()
RefreshParentSizes()
end, TweenInfo.new(0.6, Enum.EasingStyle.Exponential))
tween(Background, {Size = closedsize})
tween(Display, {BackgroundTransparency = 0})
end
task.delay(0.1, RefreshParentSizes)
task.delay(0.35, RefreshParentSizes)
end)
​local h, s, v = ColorPickerSettings.Color:ToHSV()
​local function setDisplay(hp, sp, vp)
hp = hp or h
sp = sp or s
vp = vp or v
MainCP.MainPoint.Position = UDim2.new(sp, -MainCP.MainPoint.AbsoluteSize.X / 2, 1 - vp, -MainCP.MainPoint.AbsoluteSize.Y / 2)
MainCP.MainPoint.ImageColor3 = Color3.fromHSV(hp, sp, vp)
Background.BackgroundColor3 = Color3.fromHSV(hp, 1, 1)
Display.BackgroundColor3 = Color3.fromHSV(hp, sp, vp)
​local x = hp * Slider.AbsoluteSize.X
Slider.SliderPoint.Position = UDim2.new(0, x - Slider.SliderPoint.AbsoluteSize.X / 2, 0.5, 0)
Slider.SliderPoint.ImageColor3 = Color3.fromHSV(hp, 1, 1)
​local color = Color3.fromHSV(hp, sp, vp)
local cr = math.floor((color.R * 255) + 0.5)
local cg = math.floor((color.G * 255) + 0.5)
local cb = math.floor((color.B * 255) + 0.5)
ColorPicker.RInput.InputBox.Text = tostring(cr)
ColorPicker.GInput.InputBox.Text = tostring(cg)
ColorPicker.BInput.InputBox.Text = tostring(cb)
ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X", cr, cg, cb)
end
​local function UpdateMainAtPos(inputPos)
local sizeX = math.max(MainCP.AbsoluteSize.X, 1)
local sizeY = math.max(MainCP.AbsoluteSize.Y, 1)
local localX = math.clamp(inputPos.X - MainCP.AbsolutePosition.X, 0, sizeX)
local localY = math.clamp(inputPos.Y - MainCP.AbsolutePosition.Y, 0, sizeY)
s = localX / sizeX
v = 1 - (localY / sizeY)
setDisplay(h, s, v)
local color = Color3.fromHSV(h, s, v)
ColorPickerSettings.Color = color
ColorPickerV.Color = color
SafeCallback(color)
end
​local function UpdateSliderAtPos(inputPos)
local sizeX = math.max(Slider.AbsoluteSize.X, 1)
local localX = math.clamp(inputPos.X - Slider.AbsolutePosition.X, 0, sizeX)
h = localX / sizeX
setDisplay(h, s, v)
local color = Color3.fromHSV(h, s, v)
ColorPickerSettings.Color = color
ColorPickerV.Color = color
SafeCallback(color)
end
​local function StartMainDrag(input)
if not opened then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
mainDragging = true
if RootScrollPage and RootScrollPage:IsA("ScrollingFrame") then
RootScrollPage.ScrollingEnabled = false
end
UpdateMainAtPos(input.Position)
end
end
​local function StartSliderDrag(input)
if not opened then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
sliderDragging = true
if RootScrollPage and RootScrollPage:IsA("ScrollingFrame") then
RootScrollPage.ScrollingEnabled = false
end
UpdateSliderAtPos(input.Position)
end
end
​MainCP.InputBegan:Connect(StartMainDrag)
MainCP.MainPoint.InputBegan:Connect(StartMainDrag)
Slider.InputBegan:Connect(StartSliderDrag)
Slider.SliderPoint.InputBegan:Connect(StartSliderDrag)
​UserInputService.InputChanged:Connect(function(input)
if not (mainDragging or sliderDragging) then return end
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
if mainDragging then
UpdateMainAtPos(input.Position)
elseif sliderDragging then
UpdateSliderAtPos(input.Position)
end
end
end)
​UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
if mainDragging or sliderDragging then
mainDragging = false
sliderDragging = false
if RootScrollPage and RootScrollPage:IsA("ScrollingFrame") then
RootScrollPage.ScrollingEnabled = true
end
end
end
end)
​setDisplay(h, s, v)
​ColorPicker.HexInput.InputBox.FocusLost:Connect(function()
local currentHex = Color3ToHex(ColorPickerSettings.Color)
if not pcall(function()
local rHex, gHex, bHex = string.match(ColorPicker.HexInput.InputBox.Text, "^#?(%w%w)(%w%w)(%w%w)$")
local rgbColor = Color3.fromRGB(tonumber(rHex, 16), tonumber(gHex, 16), tonumber(bHex, 16))
h, s, v = rgbColor:ToHSV()
setDisplay(h, s, v)
ColorPickerSettings.Color = rgbColor
ColorPickerV.Color = rgbColor
end) then
ColorPicker.HexInput.InputBox.Text = currentHex
end
SafeCallback(ColorPickerSettings.Color)
end)
​local function rgbBoxes(box, toChange)
local value = tonumber(box.Text)
local color = Color3.fromHSV(h, s, v)
local oldR = math.floor((color.R * 255) + 0.5)
local oldG = math.floor((color.G * 255) + 0.5)
local oldB = math.floor((color.B * 255) + 0.5)
local save
if toChange == "R" then save = oldR; if value then oldR = math.clamp(value, 0, 255) end
elseif toChange == "G" then save = oldG; if value then oldG = math.clamp(value, 0, 255) end
else save = oldB; if value then oldB = math.clamp(value, 0, 255) end end
​if value then
local newColor = Color3.fromRGB(oldR, oldG, oldB)
h, s, v = newColor:ToHSV()
setDisplay(h, s, v)
ColorPickerSettings.Color = newColor
ColorPickerV.Color = newColor
SafeCallback(newColor)
else
box.Text = tostring(save)
end
end
​ColorPicker.RInput.InputBox.FocusLost:Connect(function()
rgbBoxes(ColorPicker.RInput.InputBox, "R")
end)
ColorPicker.GInput.InputBox.FocusLost:Connect(function()
rgbBoxes(ColorPicker.GInput.InputBox, "G")
end)
ColorPicker.BInput.InputBox.FocusLost:Connect(function()
rgbBoxes(ColorPicker.BInput.InputBox, "B")
end)
​function ColorPickerV:Set(NewColorPickerSettings)
NewColorPickerSettings = Kwargify(ColorPickerSettings, NewColorPickerSettings or {})
​ColorPickerV.Settings = NewColorPickerSettings
ColorPickerSettings = NewColorPickerSettings
​ColorPicker.Name = ColorPickerSettings.Name
ColorPicker.Title.Text = ColorPickerSettings.Name
ColorPicker.Visible = true
​h, s, v = ColorPickerSettings.Color:ToHSV()
setDisplay(h, s, v)
local color = Color3.fromHSV(h, s, v)
ColorPickerSettings.Color = color
ColorPickerV.Color = color
SafeCallback(color)
end
​function ColorPickerV:Destroy()
ColorPicker:Destroy()
task.defer(RefreshParentSizes)
end
​if Flag then
Luna.Options[Flag] = ColorPickerV
end
​SafeCallback(ColorPickerSettings.Color)
task.defer(RefreshParentSizes)
return ColorPickerV
end
​return API
end
​function Luna:CreateWindow(WindowSettings)
​WindowSettings = Kwargify({
Name = "Luna UI Example Window",
Subtitle = "",
LogoID = "",
LoadingEnabled = true,
LoadingTitle = "Luna Interface Suite",
LoadingSubtitle = "by Nebula Softworks",
​ConfigSettings = {},
​KeySystem = false,
KeySettings = {}
}, WindowSettings or {})
​WindowSettings.ConfigSettings = Kwargify({
RootFolder = nil,
ConfigFolder = "Big Hub"
}, WindowSettings.ConfigSettings or {})
​WindowSettings.KeySettings = Kwargify({
Title = WindowSettings.Name,
Subtitle = "Key System",
Note = "No Instructions",
SaveInRoot = false,
SaveKey = true,
Key = {""},
SecondAction = {}
}, WindowSettings.KeySettings or {})
​WindowSettings.KeySettings.SecondAction = Kwargify({
Enabled = false,
Type = "Discord",
Parameter = ""
}, WindowSettings.KeySettings.SecondAction)
​local Passthrough = false
​local Window = { Bind = Enum.KeyCode.K, CurrentTab = nil, State = true, Size = false, Settings = nil }
​Main.Title.Title.Text = WindowSettings.Name
Main.Title.subtitle.Text = WindowSettings.Subtitle
Main.Logo.Image = ""
Main.Visible = true
Main.BackgroundTransparency = 1
Main.Size = MainSize
Main.Size = UDim2.fromOffset(Main.Size.X.Offset - 70, Main.Size.Y.Offset - 55)
Main.Parent.ShadowHolder.Size = Main.Size
LoadingFrame.Frame.Frame.Title.TextTransparency = 1
LoadingFrame.Frame.Frame.Subtitle.TextTransparency = 1
LoadingFrame.Version.TextTransparency = 1
LoadingFrame.Frame.ImageLabel.ImageTransparency = 1
​UpdateMobileScale()
​tween(Elements.Parent, {BackgroundTransparency = 1})
Elements.Parent.Visible = false
​LoadingFrame.Frame.Frame.Title.Text = WindowSettings.LoadingTitle
LoadingFrame.Frame.Frame.Subtitle.Text = WindowSettings.LoadingSubtitle
LoadingFrame.Version.Text = LoadingFrame.Frame.Frame.Title.Text == "Luna Interface Suite" and Release or "Luna UI"
​pcall(function()
Navigation.Player.icon.ImageLabel.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)
Navigation.Player.Namez.Text = Players.LocalPlayer.DisplayName
Navigation.Player.TextLabel.Text = Players.LocalPlayer.Name
​for i, v in pairs(Main.Controls:GetChildren()) do
v.Visible = false
end
​Main:GetPropertyChangedSignal("Position"):Connect(function()
Main.Parent.ShadowHolder.Position = Main.Position
end)
Main:GetPropertyChangedSignal("Size"):Connect(function()
Main.Parent.ShadowHolder.Size = Main.Size
end)
​LoadingFrame.Visible = true
​LunaUI.Enabled = true
​BlurModule(Main)
​if WindowSettings.KeySystem then
local KeySettings = WindowSettings.KeySettings
​Draggable(Dragger, Main)
Draggable(LunaUI.MobileSupport, LunaUI.MobileSupport)
if dragBar then Draggable(dragInteract, Main, true, 255) end
​if not WindowSettings.KeySettings then
Passthrough = true
return
end
​WindowSettings.KeySettings.FileName = "key"
​if typeof(WindowSettings.KeySettings.Key) == "string" then WindowSettings.KeySettings.Key = {WindowSettings.KeySettings.Key} end
​local direc = WindowSettings.KeySettings.SaveInRoot and "Luna/Configurations/" .. tostring(WindowSettings.ConfigSettings.RootFolder) .. "/" .. tostring(WindowSettings.ConfigSettings.ConfigFolder) .. "/Key System/" or "Luna/Configurations/" .. tostring(WindowSettings.ConfigSettings.ConfigFolder) .. "/Key System/"
​if isfile and isfile(direc .. WindowSettings.KeySettings.FileName .. ".luna") then
for i, Key in ipairs(WindowSettings.KeySettings.Key) do
if string.find(readfile(direc .. WindowSettings.KeySettings.FileName .. ".luna"), Key) then
Passthrough = true
break
end
end
end
​if not Passthrough then
local Btn = KeySystem.Action.Copy
local typesys = KeySettings.SecondAction.Type
​if typesys == "Discord" then
Btn = KeySystem.Action.Discord
end
​local AttemptsRemaining = math.random(2, 5)
​KeySystem.Visible = true
KeySystem.Title.Text = WindowSettings.KeySettings.Title
KeySystem.Subtitle.Text = WindowSettings.KeySettings.Subtitle
KeySystem.textshit.Text = WindowSettings.KeySettings.Note
​if KeySettings.SecondAction.Enabled == true then
Btn.Visible = true
end
​BindTap(Btn.Interact, function()
if typesys == "Discord" then
if setclipboard then
setclipboard(tostring("https://discord.gg/"..KeySettings.SecondAction.Parameter))
end
if request then
request({
Url = 'http://127.0.0.1:6463/rpc?v=1',
Method = 'POST',
Headers = {
['Content-Type'] = 'application/json',
Origin = 'https://discord.com'
},
Body = HttpService:JSONEncode({
cmd = 'INVITE_BROWSER',
nonce = HttpService:GenerateGUID(false),
args = {code = KeySettings.SecondAction.Parameter}
})
})
end
else
if setclipboard then
setclipboard(tostring(KeySettings.SecondAction.Parameter))
end
end
end)
​BindTap(KeySystem.Action.Submit.Interact, function()
if #KeySystem.Input.InputBox.Text == 0 then return end
local KeyFound = false
local FoundKey = ''
for _, Key in ipairs(WindowSettings.KeySettings.Key) do
if KeySystem.Input.InputBox.Text == Key then
KeyFound = true
FoundKey = Key
break
end
end
if KeyFound then
for _, instance in pairs(KeySystem:GetDescendants()) do
if instance.ClassName ~= "UICorner" and instance.ClassName ~= "UIPadding" then
if instance.ClassName ~= "UIStroke" and instance.ClassName ~= "UIListLayout" then
tween(instance, {BackgroundTransparency = 1}, nil, TweenInfo.new(0.6, Enum.EasingStyle.Exponential))
end
if instance.ClassName == "ImageButton" then
tween(instance, {ImageTransparency = 1}, nil, TweenInfo.new(0.5, Enum.EasingStyle.Exponential))
end
if instance.ClassName == "TextLabel" then
tween(instance, {TextTransparency = 1}, nil, TweenInfo.new(0.4, Enum.EasingStyle.Exponential))
end
if instance.ClassName == "UIStroke" then
tween(instance, {Transparency = 1}, nil, TweenInfo.new(0.5, Enum.EasingStyle.Exponential))
end
end
end
tween(KeySystem, {BackgroundTransparency = 1}, nil, TweenInfo.new(0.6, Enum.EasingStyle.Exponential))
task.wait(0.51)
Passthrough = true
KeySystem.Visible = false
if WindowSettings.KeySettings.SaveKey then
pcall(function()
if writefile then
writefile(direc .. WindowSettings.KeySettings.FileName .. ".luna", FoundKey)
end
end)
Luna:Notification({Title = "Key System", Content = "The key for this script has been saved successfully."})
end
else
if AttemptsRemaining == 0 then
Players.LocalPlayer:Kick("No Attempts Remaining")
game:Shutdown()
end
KeySystem.Input.InputBox.Text = "Incorrect Key"
AttemptsRemaining = AttemptsRemaining - 1
task.wait(0.4)
KeySystem.Input.InputBox.Text = ""
end
end)
​BindTap(KeySystem.Close, function()
Luna:Destroy()
end)
end
end
​if WindowSettings.KeySystem then
repeat task.wait() until Passthrough
end
​if WindowSettings.LoadingEnabled then
task.wait(0.3)
TweenService:Create(LoadingFrame.Frame.Frame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
TweenService:Create(LoadingFrame.Frame.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
task.wait(0.05)
TweenService:Create(LoadingFrame.Frame.Frame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
task.wait(0.29)
TweenService:Create(LoadingFrame.Frame.ImageLabel, TweenInfo.new(1.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 2, false, 0.2), {Rotation = 450}):Play()
​task.wait(3.32)
​TweenService:Create(LoadingFrame.Frame.Frame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
TweenService:Create(LoadingFrame.Frame.ImageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
task.wait(0.05)
TweenService:Create(LoadingFrame.Frame.Frame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
task.wait(0.3)
TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
end
​TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2, Size = MainSize}):Play()
TweenService:Create(Main.Parent.ShadowHolder, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = MainSize}):Play()
TweenService:Create(Main.Title.Title, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
TweenService:Create(Main.Title.subtitle, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
TweenService:Create(Main.Logo, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
TweenService:Create(Navigation.Player.icon.ImageLabel, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
TweenService:Create(Navigation.Player.icon.UIStroke, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = 0}):Play()
TweenService:Create(Main.Line, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
task.wait(0.4)
LoadingFrame.Visible = false
​Draggable(Dragger, Main)
Draggable(LunaUI.MobileSupport, LunaUI.MobileSupport)
if dragBar then Draggable(dragInteract, Main, true, 255) end
​Elements.Template.LayoutOrder = 1000000000
Elements.Template.Visible = false
Navigation.Tabs["InActive Template"].LayoutOrder = 1000000000
Navigation.Tabs["InActive Template"].Visible = false
​local FirstTab = true
​function Window:CreateHomeTab(HomeTabSettings)
​HomeTabSettings = Kwargify({
Icon = 1,
SupportedExecutors = {"Vega X", "Delta", "Nihon", "Xeno", "Codex", "Arceus X", "Fluxus"},
DiscordInvite = "noinvitelink"
}, HomeTabSettings or {})
​local HomeTab = {}
​local HomeTabButton = Navigation.Tabs.Home
HomeTabButton.Visible = true
HomeTabButton.ImageLabel.Image = ""
HomeTabButton.ImageLabel.Visible = false
pcall(function()
HomeTabButton.TextLabel.Position = UDim2.new(0, 14, HomeTabButton.TextLabel.Position.Y.Scale, HomeTabButton.TextLabel.Position.Y.Offset)
end)
​local HomeTabPage = Elements.Home
HomeTabPage.Visible = true
SetupAutoScroll(HomeTabPage)
​function HomeTab:Activate()
tween(HomeTabButton, {BackgroundTransparency = 0})
tween(HomeTabButton.UIStroke, {Transparency = 0.41})
​Elements.UIPageLayout:JumpTo(HomeTabPage)
​task.wait(0.05)
​for _, OtherTabButton in ipairs(Navigation.Tabs:GetChildren()) do
if OtherTabButton.Name ~= "InActive Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= HomeTabButton then
tween(OtherTabButton, {BackgroundTransparency = 1})
tween(OtherTabButton.UIStroke, {Transparency = 1})
end
end
​Window.CurrentTab = "Home"
end
​HomeTab:Activate()
FirstTab = false
BindTap(HomeTabButton.Interact, function()
HomeTab:Activate()
end)
​pcall(function()
HomeTabPage.icon.ImageLabel.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)
HomeTabPage.player.Text.Text = "Hello, " .. Players.LocalPlayer.DisplayName
HomeTabPage.player.user.Text = Players.LocalPlayer.Name .. " - ".. WindowSettings.Name
​local execName = (isStudio and "Debugging (Studio)") or (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or (IsMobile and "Mobile Executor" or "Unknown Executor")
HomeTabPage.detailsholder.dashboard.Client.Title.Text = tostring(execName)
​local supported = false
for _, v in pairs(HomeTabSettings.SupportedExecutors) do
if tostring(v):lower() == tostring(execName):lower() then
supported = true
break
end
end
if isStudio then
HomeTabPage.detailsholder.dashboard.Client.Subtitle.Text = "Luna Interface Suite - Debugging Mode"
elseif supported then
HomeTabPage.detailsholder.dashboard.Client.Subtitle.Text = "Your Executor Supports This Script."
else
HomeTabPage.detailsholder.dashboard.Client.Subtitle.Text = "Your Executor Isn't Officially Supported By This Script."
end
​BindTap(HomeTabPage.detailsholder.dashboard.Discord.Interact, function()
if setclipboard then
setclipboard(tostring("https://discord.gg/"..HomeTabSettings.DiscordInvite))
end
if request then
request({
Url = 'http://127.0.0.1:6463/rpc?v=1',
Method = 'POST',
Headers = {
['Content-Type'] = 'application/json',
Origin = 'https://discord.com'
},
Body = HttpService:JSONEncode({
cmd = 'INVITE_BROWSER',
nonce = HttpService:GenerateGUID(false),
args = {code = HomeTabSettings.DiscordInvite}
})
})
end
end)
​local friendsCooldown = 0
local function getPing()
local ok, val = pcall(function()
return math.clamp(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue(), 10, 700)
end)
return ok and val or 50
end
​local function checkFriends()
if friendsCooldown == 0 then
friendsCooldown = 25
pcall(function()
local playersFriends = {}
local friendsInTotal = 0
local onlineFriends = 0
local friendsInGame = 0
​local list = Players:GetFriendsAsync(Player.UserId)
while true do
for _, data in ipairs(list:GetCurrentPage()) do
friendsInTotal += 1
table.insert(playersFriends, data)
end
if list.IsFinished then
break
else
list:AdvanceToNextPageAsync()
end
end
for _, v in pairs(Player:GetFriendsOnline()) do
onlineFriends += 1
end
for _, v in pairs(playersFriends) do
if v and v.Username and Players:FindFirstChild(v.Username) then
friendsInGame = friendsInGame + 1
end
end
​HomeTabPage.detailsholder.dashboard.Friends.All.Value.Text = tostring(friendsInTotal).." friends"
HomeTabPage.detailsholder.dashboard.Friends.Offline.Value.Text = tostring(friendsInTotal - onlineFriends).." friends"
HomeTabPage.detailsholder.dashboard.Friends.Online.Value.Text = tostring(onlineFriends).." friends"
HomeTabPage.detailsholder.dashboard.Friends.InGame.Value.Text = tostring(friendsInGame).." friends"
end)
else
friendsCooldown -= 1
end
end
​local function format(Int)
return string.format("%02i", Int)
end
​local function convertToHMS(Seconds)
local Minutes = (Seconds - Seconds%60)/60
Seconds = Seconds - Minutes60
local Hours = (Minutes - Minutes%60)/60
Minutes = Minutes - Hours60
return format(Hours)..":"..format(Minutes)..":"..format(Seconds)
end
​task.spawn(function()
while task.wait(1) do
if not LunaUI or not LunaUI.Parent then break end
pcall(function()
HomeTabPage.detailsholder.dashboard.Server.Players.Value.Text = #Players:GetPlayers().." playing"
HomeTabPage.detailsholder.dashboard.Server.MaxPlayers.Value.Text = Players.MaxPlayers.." players can join this server"
HomeTabPage.detailsholder.dashboard.Server.Latency.Value.Text = isStudio and tostring(math.round((Players.LocalPlayer:GetNetworkPing() * 2 ) / 0.01)) .."ms" or tostring(math.floor(getPing()) .."ms")
HomeTabPage.detailsholder.dashboard.Server.Time.Value.Text = convertToHMS(time())
HomeTabPage.detailsholder.dashboard.Server.Region.Value.Text = Localization:GetCountryRegionForPlayerAsync(Players.LocalPlayer)
end)
checkFriends()
end
end)
end
​function Window:CreateTab(TabSettings)
​local Tab = {}
​TabSettings = Kwargify({
Name = "Tab",
ShowTitle = true,
Icon = "",
ImageSource = "Material"
}, TabSettings or {})
​local TabButton = Navigation.Tabs["InActive Template"]:Clone()
​TabButton.Name = TabSettings.Name
TabButton.TextLabel.Text = TabSettings.Name
TabButton.Parent = Navigation.Tabs
TabButton.ImageLabel.Image = ""
TabButton.ImageLabel.Visible = false
pcall(function()
TabButton.TextLabel.Position = UDim2.new(0, 14, TabButton.TextLabel.Position.Y.Scale, TabButton.TextLabel.Position.Y.Offset)
end)
​TabButton.Visible = true
​local TabPage = Elements.Template:Clone()
TabPage.Name = TabSettings.Name
TabPage.Title.Visible = TabSettings.ShowTitle
TabPage.Title.Text = TabSettings.Name
TabPage.Visible = true
​Tab.Page = TabPage
​if TabSettings.ShowTitle == false then
TabPage.UIPadding.PaddingTop = UDim.new(0, 10)
end
​TabPage.LayoutOrder = #Elements:GetChildren() - 3
​for _, TemplateElement in ipairs(TabPage:GetChildren()) do
if TemplateElement.ClassName == "Frame" or (TemplateElement.ClassName == "TextLabel" and TemplateElement.Name ~= "Title") then
TemplateElement:Destroy()
end
end
TabPage.Parent = Elements
SetupAutoScroll(TabPage)
​function Tab:Activate()
tween(TabButton, {BackgroundTransparency = 0})
tween(TabButton.UIStroke, {Transparency = 0.41})
​Elements.UIPageLayout:JumpTo(TabPage)
​task.wait(0.05)
​for _, OtherTabButton in ipairs(Navigation.Tabs:GetChildren()) do
if OtherTabButton.Name ~= "InActive Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton then
tween(OtherTabButton, {BackgroundTransparency = 1})
tween(OtherTabButton.UIStroke, {Transparency = 1})
end
end
​Window.CurrentTab = TabSettings.Name
end
​if FirstTab then
Tab:Activate()
end
​task.wait(0.01)
​BindTap(TabButton.Interact, function()
Tab:Activate()
end)
​FirstTab = false
​-- Attach all mobile-adapted element creators directly to Tab
local TabBuilders = AttachElementBuilders(TabPage, TabPage, false, nil)
for methodName, methodFunc in pairs(TabBuilders) do
Tab[methodName] = methodFunc
end
​-- Section
function Tab:CreateSection(name)
local Section = {}
​if name == nil then name = "Section" end
Section.Name = name
​local Sectiont = Elements.Template.Section:Clone()
Sectiont.Text = name
Sectiont.Visible = true
Sectiont.Parent = TabPage
local SectionFrame = Sectiont.Frame
​SetupAutoSection(Sectiont, SectionFrame, TabPage)
​Sectiont.TextTransparency = 1
tween(Sectiont, {TextTransparency = 0})
​function Section:Set(NewSection)
Sectiont.Text = NewSection
end
​function Section:Destroy()
Sectiont:Destroy()
end
​local SectionBuilders = AttachElementBuilders(SectionFrame, TabPage, true, Sectiont)
for methodName, methodFunc in pairs(SectionBuilders) do
Section[methodName] = methodFunc
end
​return Section
end
​function Tab:BuildConfigSection()
if isStudio then
Tab:CreateLabel({Text = "Config system unavailable. (Environment isStudio)", Style = 3})
return "Config system unavailable."
end
​local inputPath = nil
local selectedConfig = nil
​local Title = Elements.Template.Title:Clone()
Title.Text = "Configurations"
Title.Visible = true
Title.Parent = TabPage
Title.TextTransparency = 1
TweenService:Create(Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
​Tab:CreateSection("Config Creator")
​Tab:CreateInput({
Name = "Config Name",
Description = "Insert a name for your to be created config.",
PlaceholderText = "Name",
CurrentValue = "",
Numeric = false,
MaxCharacters = nil,
Enter = false,
Callback = function(input)
inputPath = input
end,
})
​local configSelection
​Tab:CreateButton({
Name = "Create Config",
Description = "Create a config with all of your current settings.",
Callback = function()
if not inputPath or string.gsub(inputPath, " ", "") == "" then
Luna:Notification({
Title = "Interface",
Content = "Config name cannot be empty."
})
return
end
​local success, returned = Luna:SaveConfig(inputPath)
if not success then
Luna:Notification({
Title = "Interface",
Content = "Unable to save config, return error: " .. tostring(returned)
})
return
end
​Luna:Notification({
Title = "Interface",
Content = string.format("Created config %q", inputPath),
})
​configSelection:Set({ Options = Luna:RefreshConfigList() })
end
})
​Tab:CreateSection("Config Load/Settings")
​configSelection = Tab:CreateDropdown({
Name = "Select Config",
Description = "Select a config to load your settings on.",
Options = Luna:RefreshConfigList(),
CurrentOption = {},
MultipleOptions = false,
SpecialType = nil,
Callback = function(Value)
selectedConfig = Value
end,
})
​Tab:CreateButton({
Name = "Load Config",
Description = "Load your saved config settings.",
Callback = function()
local success, returned = Luna:LoadConfig(selectedConfig)
if not success then
Luna:Notification({
Title = "Interface",
Content = "Unable to load config, return error: " .. tostring(returned)
})
return
end
​Luna:Notification({
Title = "Interface",
Content = string.format("Loaded config %q", tostring(selectedConfig)),
})
end
})
​Tab:CreateButton({
Name = "Overwrite Config",
Description = "Overwrite your current config settings.",
Callback = function()
local success, returned = Luna:SaveConfig(selectedConfig)
if not success then
Luna:Notification({
Title = "Interface",
Content = "Unable to overwrite config, return error: " .. tostring(returned)
})
return
end
​Luna:Notification({
Title = "Interface",
Content = string.format("Overwrote config %q", tostring(selectedConfig)),
})
end
})
​Tab:CreateButton({
Name = "Refresh Config List",
Description = "Refresh the current config list.",
Callback = function()
configSelection:Set({ Options = Luna:RefreshConfigList() })
end,
})
​local loadlabel
Tab:CreateButton({
Name = "Set as autoload",
Description = "Set a config to auto load setting in your next session.",
Callback = function()
local name = selectedConfig
if not name then return end
writefile(Luna.Folder .. "/settings/autoload.txt", tostring(name))
loadlabel:Set({ Text = "Current autoload config: " .. tostring(name) })
​Luna:Notification({
Title = "Interface",
Content = string.format("Set %q to auto load", tostring(name)),
})
end,
})
​loadlabel = Tab:CreateParagraph({
Title = "Current Auto Load",
Text = "None"
})
​Tab:CreateButton({
Name = "Delete Autoload",
Description = "Delete The Autoload File",
Callback = function()
if isfile and isfile(Luna.Folder .. "/settings/autoload.txt") and delfile then
delfile(Luna.Folder .. "/settings/autoload.txt")
end
loadlabel:Set({ Text = "None" })
​Luna:Notification({
Title = "Interface",
Content = "Deleted Autoload",
})
end,
})
​if isfile and isfile(Luna.Folder .. "/settings/autoload.txt") then
local name = readfile(Luna.Folder .. "/settings/autoload.txt")
loadlabel:Set({ Text = "Current autoload config: " .. tostring(name) })
end
end
​local ClassParser = {
["Toggle"] = {
Save = function(Flag, data)
return {
type = "Toggle",
flag = Flag,
state = data.CurrentValue or false
}
end,
Load = function(Flag, data)
if Luna.Options[Flag] then
Luna.Options[Flag]:Set({ CurrentValue = data.state })
end
end
},
["Slider"] = {
Save = function(Flag, data)
return {
type = "Slider",
flag = Flag,
value = (data.CurrentValue and tostring(data.CurrentValue)),
}
end,
Load = function(Flag, data)
if Luna.Options[Flag] and data.value then
Luna.Options[Flag]:Set({ CurrentValue = tonumber(data.value) or data.value })
end
end
},
["Input"] = {
Save = function(Flag, data)
return {
type = "Input",
flag = Flag,
text = data.CurrentValue
}
end,
Load = function(Flag, data)
if Luna.Options[Flag] and data.text and type(data.text) == "string" then
Luna.Options[Flag]:Set({ CurrentValue = data.text })
end
end
},
["Dropdown"] = {
Save = function(Flag, data)
return {
type = "Dropdown",
flag = Flag,
value = data.CurrentOption
}
end,
Load = function(Flag, data)
if Luna.Options[Flag] and data.value then
Luna.Options[Flag]:Set({ CurrentOption = data.value })
end
end
},
["Colorpicker"] = {
Save = function(Flag, data)
local function Color3ToHex(color)
if typeof(color) == "Color3" then
return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
end
return tostring(color or "#FFFFFF")
end
​return {
type = "Colorpicker",
flag = Flag,
color = Color3ToHex(data.Color) or nil,
alpha = data.Alpha
}
end,
Load = function(Flag, data)
local function HexToColor3(hex)
local r = tonumber(hex:sub(2, 3), 16) / 255
local g = tonumber(hex:sub(4, 5), 16) / 255
local b = tonumber(hex:sub(6, 7), 16) / 255
return Color3.new(r, g, b)
end
​if Luna.Options[Flag] and data.color then
Luna.Options[Flag]:Set({Color = HexToColor3(data.color)})
end
end
}
}
​function Tab:BuildThemeSection()
local Title = Elements.Template.Title:Clone()
Title.Text = "Theming"
Title.Visible = true
Title.Parent = TabPage
Title.TextTransparency = 1
TweenService:Create(Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
​Tab:CreateSection("Custom Editor")
​local c1cp = Tab:CreateColorPicker({
Name = "Color 1",
Color = Color3.fromRGB(117, 164, 206),
}, "LunaInterfaceSuitePrebuiltCPC1")
​local c2cp = Tab:CreateColorPicker({
Name = "Color 2",
Color = Color3.fromRGB(123, 201, 201),
}, "LunaInterfaceSuitePrebuiltCPC2")
​local c3cp = Tab:CreateColorPicker({
Name = "Color 3",
Color = Color3.fromRGB(224, 138, 184),
}, "LunaInterfaceSuitePrebuiltCPC3")
​task.wait(0.2)
​c1cp:Set({
Callback = function(Value)
if c2cp and c3cp then
Luna.ThemeGradient = ColorSequence.new{
ColorSequenceKeypoint.new(0.00, Value or Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.50, typeof(c2cp.Color) == "Color3" and c2cp.Color or Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.00, typeof(c3cp.Color) == "Color3" and c3cp.Color or Color3.fromRGB(255,255,255))
}
LunaUI.ThemeRemote.Value = not LunaUI.ThemeRemote.Value
end
end
})
​c2cp:Set({
Callback = function(Value)
if c1cp and c3cp then
Luna.ThemeGradient = ColorSequence.new{
ColorSequenceKeypoint.new(0.00, typeof(c1cp.Color) == "Color3" and c1cp.Color or Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.50, Value or Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.00, typeof(c3cp.Color) == "Color3" and c3cp.Color or Color3.fromRGB(255,255,255))
}
LunaUI.ThemeRemote.Value = not LunaUI.ThemeRemote.Value
end
end
})
​c3cp:Set({
Callback = function(Valuex)
if c2cp and c1cp then
Luna.ThemeGradient = ColorSequence.new{
ColorSequenceKeypoint.new(0.00, typeof(c1cp.Color) == "Color3" and c1cp.Color or Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.50, typeof(c2cp.Color) == "Color3" and c2cp.Color or Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.00, Valuex or Color3.fromRGB(255,255,255))
}
LunaUI.ThemeRemote.Value = not LunaUI.ThemeRemote.Value
end
end
})
​Tab:CreateSection("Preset Gradients")
​for i, v in pairs(PresetGradients) do
Tab:CreateButton({
Name = tostring(i),
Callback = function()
c1cp:Set({ Color = v[1] })
c2cp:Set({ Color = v[2] })
c3cp:Set({ Color = v[3] })
end,
})
end
end
​local function BuildFolderTree()
if isStudio or not isfolder or not makefolder then return "Config system unavailable." end
local paths = {
Luna.Folder,
Luna.Folder .. "/settings"
}
​for i = 1, #paths do
local str = paths[i]
pcall(function()
if not isfolder(str) then
makefolder(str)
end
end)
end
end
​local function SetFolder()
if isStudio then return "Config system unavailable." end
​if WindowSettings.ConfigSettings.RootFolder ~= nil and WindowSettings.ConfigSettings.RootFolder ~= "" then
Luna.Folder = WindowSettings.ConfigSettings.RootFolder .. "/" .. WindowSettings.ConfigSettings.ConfigFolder
else
Luna.Folder = WindowSettings.ConfigSettings.ConfigFolder
end
​BuildFolderTree()
end
​SetFolder()
​function Luna:SaveConfig(Path)
if isStudio or not writefile then return false, "Config system unavailable." end
​if not Path then
return false, "Please select a config file."
end
​local fullPath = Luna.Folder .. "/settings/" .. Path .. ".luna"
​local data = {
objects = {}
}
​for flag, option in next, Luna.Options do
if not ClassParser[option.Class] then continue end
if option.IgnoreConfig then continue end
​table.insert(data.objects, ClassParser[option.Class].Save(flag, option))
end
​local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
if not success then
return false, "Unable to encode into JSON data"
end
​writefile(fullPath, encoded)
return true
end
​function Luna:LoadConfig(Path)
if isStudio or not isfile or not readfile then return false, "Config system unavailable." end
​if not Path then
return false, "Please select a config file."
end
​local file = Luna.Folder .. "/settings/" .. Path .. ".luna"
if not isfile(file) then return false, "Invalid file" end
​local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
if not success then return false, "Unable to decode JSON data." end
​for _, option in next, decoded.objects do
if ClassParser[option.type] then
task.spawn(function()
ClassParser[option.type].Load(option.flag, option)
end)
end
end
​return true
end
​function Luna:LoadAutoloadConfig()
if isStudio or not isfile or not readfile then return "Config system unavailable." end
if isfile(Luna.Folder .. "/settings/autoload.txt") then
local name = readfile(Luna.Folder .. "/settings/autoload.txt")
​local success, err = Luna:LoadConfig(name)
if not success then
return Luna:Notification({
Title = "Interface",
Content = "Failed to load autoload config: " .. tostring(err),
})
end
​Luna:Notification({
Title = "Interface",
Content = string.format("Auto loaded config %q", name),
})
end
end
​function Luna:RefreshConfigList()
if isStudio or not listfiles then return {} end
​local ok, list = pcall(listfiles, Luna.Folder .. "/settings")
if not ok or type(list) ~= "table" then return {} end
​local out = {}
for i = 1, #list do
local file = list[i]
if file:sub(-5) == ".luna" then
local pos = file:find(".luna", 1, true)
local start = pos
​local char = file:sub(pos, pos)
while char ~= "/" and char ~= "\" and char ~= "" do
pos = pos - 1
char = file:sub(pos, pos)
end
​if char == "/" or char == "\" then
local name = file:sub(pos + 1, start - 1)
if name ~= "options" then
table.insert(out, name)
end
end
end
end
​return out
end
​return Tab
end
​Elements.Parent.Visible = true
tween(Elements.Parent, {BackgroundTransparency = 0.1})
Navigation.Visible = true
tween(Navigation.Line, {BackgroundTransparency = 0})
​for _, TopbarButton in ipairs(Main.Controls:GetChildren()) do
if TopbarButton.ClassName == "Frame" and TopbarButton.Name ~= "Theme" then
TopbarButton.Visible = true
tween(TopbarButton, {BackgroundTransparency = 0.25})
tween(TopbarButton.UIStroke, {Transparency = 0.5})
tween(TopbarButton.ImageLabel, {ImageTransparency = 0.25})
end
end
​BindTap(Main.Controls.Close.ImageLabel, function()
Hide(Main, Window.Bind, true)
if dragBar then dragBar.Visible = false end
Window.State = false
if IsMobile or not UserInputService.KeyboardEnabled then
LunaUI.MobileSupport.Visible = true
end
end)
Main.Controls.Close.MouseEnter:Connect(function()
tween(Main.Controls.Close.ImageLabel, {ImageColor3 = Color3.new(1,1,1)})
end)
Main.Controls.Close.MouseLeave:Connect(function()
tween(Main.Controls.Close.ImageLabel, {ImageColor3 = Color3.fromRGB(195,195,195)})
end)
​UserInputService.InputBegan:Connect(function(input, gpe)
if gpe then return end
if Window.State then return end
if input.KeyCode == Window.Bind then
Unhide(Main, Window.CurrentTab)
LunaUI.MobileSupport.Visible = false
if dragBar then dragBar.Visible = true end
Window.State = true
end
end)
​BindTap(Main.Logo, function()
if Navigation.Size.X.Offset == 205 then
tween(Elements.Parent, {Size = UDim2.new(1, -55, Elements.Parent.Size.Y.Scale, Elements.Parent.Size.Y.Offset)})
tween(Navigation, {Size = UDim2.new(Navigation.Size.X.Scale, 55, Navigation.Size.Y.Scale, Navigation.Size.Y.Offset)})
else
tween(Elements.Parent, {Size = UDim2.new(1, -205, Elements.Parent.Size.Y.Scale, Elements.Parent.Size.Y.Offset)})
tween(Navigation, {Size = UDim2.new(Navigation.Size.X.Scale, 205, Navigation.Size.Y.Scale, Navigation.Size.Y.Offset)})
end
end)
​BindTap(Main.Controls.ToggleSize.ImageLabel, function()
Window.Size = not Window.Size
if Window.Size then
Minimize(Main)
if dragBar then dragBar.Visible = false end
else
Maximise(Main)
if dragBar then dragBar.Visible = true end
end
end)
Main.Controls.ToggleSize.MouseEnter:Connect(function()
tween(Main.Controls.ToggleSize.ImageLabel, {ImageColor3 = Color3.new(1,1,1)})
end)
Main.Controls.ToggleSize.MouseLeave:Connect(function()
tween(Main.Controls.ToggleSize.ImageLabel, {ImageColor3 = Color3.fromRGB(195,195,195)})
end)
​BindTap(Main.Controls.Theme.ImageLabel, function()
if Window.Settings then
Window.Settings:Activate()
Elements.Settings.CanvasPosition = Vector2.new(0, 698)
end
end)
Main.Controls.Theme.MouseEnter:Connect(function()
tween(Main.Controls.Theme.ImageLabel, {ImageColor3 = Color3.new(1,1,1)})
end)
Main.Controls.Theme.MouseLeave:Connect(function()
tween(Main.Controls.Theme.ImageLabel, {ImageColor3 = Color3.fromRGB(195,195,195)})
end)
​BindTap(LunaUI.MobileSupport.Interact, function()
Unhide(Main, Window.CurrentTab)
if dragBar then dragBar.Visible = true end
Window.State = true
LunaUI.MobileSupport.Visible = false
end)
​return Window
end
​function Luna:Destroy()
Main.Visible = false
for _, Notification in ipairs(Notifications:GetChildren()) do
if Notification.ClassName == "Frame" then
Notification.Visible = false
Notification:Destroy()
end
end
LunaUI:Destroy()
end
​if (getgenv and not getgenv().ConfirmLuna) or (not getgenv) then
Luna:Notification({
Title = "Luna Is Deprecated",
Content = "If you are not the script developer, ignore this message. \n\n The Luna Interface Library Is Deprecated And Not Recommended to Use. A New Library Is Available at nebulasoftworks.xyz/starlight. If you insist on using Luna, set the getgenv().ConfirmLuna variable to true. "
})
end
​return Luna
