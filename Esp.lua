--[[
	MacLib UI Library — Clean Architecture & Mobile/Executor Optimized Edition
	Адаптировано под ПК и мобильные устройства (Touch + UIScale)
	Исправлена палитра цветов (Colorpicker / Color), устранены утечки памяти и фризы верстки.
]]
local MacLib = {}
-- ============================================================================
-- БЛОК 1: СЕРВИСЫ И СОВМЕСТИМОСТЬ С ЭКЗЕКУТОРАМИ
-- ============================================================================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer
local function GetSafeGuiParent()
	if isStudio and LocalPlayer then
		return LocalPlayer:WaitForChild("PlayerGui")
	end
	if type(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then
			return hui
		end
	end
	local okCore, core = pcall(function()
		return CoreGui
	end)
	if okCore and core then
		return core
	end
	return LocalPlayer and LocalPlayer:WaitForChild("PlayerGui") or nil
end
-- ============================================================================
-- БЛОК 2: КОНСТАНТЫ, АССЕТЫ И ПАЛИТРА
-- ============================================================================
local assets = {
	interFont = "rbxassetid://12187365364",
	userInfoBlurred = "rbxassetid://18824089198",
	toggleBackground = "rbxassetid://18772190202",
	togglerHead = "rbxassetid://18772309008",
	buttonImage = "rbxassetid://10709791437",
	searchIcon = "rbxassetid://86737463322606",
	colorWheel = "rbxassetid://2849458409",
	colorTarget = "rbxassetid://73265255323268",
	gridose = "rbxassetid://121484455191370",
	globalSettingsIcon = "rbxassetid://18767849817",
	moveIcon = "rbxassetid://10734900011",
	paletteIcon = "rbxassetid://10734950309",
	confirmIcon = "rbxassetid://10709790644",
	cancelIcon = "rbxassetid://10747384394",
	hexIcon = "rbxassetid://10723407389",
	channelIcon = "rbxassetid://10734949856",
	alphaIcon = "rbxassetid://10723346959",
	brightnessIcon = "rbxassetid://10734974297"
}
local DEFAULT_SWATCHES = {
	Color3.fromRGB(255, 65, 65),
	Color3.fromRGB(255, 155, 45),
	Color3.fromRGB(255, 225, 55),
	Color3.fromRGB(65, 225, 110),
	Color3.fromRGB(55, 215, 255),
	Color3.fromRGB(85, 115, 255),
	Color3.fromRGB(195, 85, 255),
	Color3.fromRGB(255, 255, 255)
}
-- ============================================================================
-- БЛОК 3: УТИЛИТЫ (TWEEN, ГРАДИЕНТНЫЙ КОНТУР, ЦВЕТ И КЛАВИШИ)
-- ============================================================================
local function Tween(instance, tweenInfo, propertyTable)
	return TweenService:Create(instance, tweenInfo, propertyTable)
end
local STROKE_SEQUENCE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
})
local function ApplyGradientStroke(parent, strokeName, transparency, gradientName)
	local stroke = Instance.new("UIStroke")
	stroke.Name = strokeName or "UIStroke"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = transparency or 0.35
	stroke.Parent = parent
	local gradient = Instance.new("UIGradient")
	gradient.Name = gradientName or "StrokeGradient"
	gradient.Color = STROKE_SEQUENCE
	gradient.Rotation = 45
	gradient.Parent = stroke
	return stroke, gradient
end
local function ClampNumber(val, minVal, maxVal)
	local n = tonumber(val)
	if not n then
		return minVal
	end
	return math.clamp(n, minVal, maxVal)
end
local function FormatAlphaText(a)
	return tostring(math.round(a * 100) / 100)
end
local function HexToRGB(hexStr)
	local clean = tostring(hexStr or ""):gsub("#", ""):gsub("%s+", "")
	if #clean == 3 then
		clean = clean:sub(1, 1):rep(2) .. clean:sub(2, 2):rep(2) .. clean:sub(3, 3):rep(2)
	end
	if #clean ~= 6 then
		return nil
	end
	local r = tonumber(clean:sub(1, 2), 16)
	local g = tonumber(clean:sub(3, 4), 16)
	local b = tonumber(clean:sub(5, 6), 16)
	if not (r and g and b) then
		return nil
	end
	return r, g, b
end
local KEY_ALIASES = {
	["NONE"] = false,
	["ESC"] = Enum.KeyCode.Escape,
	["ESCAPE"] = Enum.KeyCode.Escape,
	["DEL"] = Enum.KeyCode.Delete,
	["DELETE"] = Enum.KeyCode.Delete,
	["BACKSPACE"] = false,
	["SPACE"] = Enum.KeyCode.Space,
	["SHIFT"] = Enum.KeyCode.LeftShift,
	["LSHIFT"] = Enum.KeyCode.LeftShift,
	["RSHIFT"] = Enum.KeyCode.RightShift,
	["CTRL"] = Enum.KeyCode.LeftControl,
	["LCTRL"] = Enum.KeyCode.LeftControl,
	["RCTRL"] = Enum.KeyCode.RightControl,
	["ALT"] = Enum.KeyCode.LeftAlt,
	["LALT"] = Enum.KeyCode.LeftAlt,
	["RALT"] = Enum.KeyCode.RightAlt,
	["TAB"] = Enum.KeyCode.Tab,
	["ENTER"] = Enum.KeyCode.Return,
	["RETURN"] = Enum.KeyCode.Return,
	["MB1"] = Enum.UserInputType.MouseButton1,
	["M1"] = Enum.UserInputType.MouseButton1,
	["MB2"] = Enum.UserInputType.MouseButton2,
	["M2"] = Enum.UserInputType.MouseButton2,
	["MB3"] = Enum.UserInputType.MouseButton3,
	["M3"] = Enum.UserInputType.MouseButton3
}
local function ParseKey(inputName)
	if not inputName or inputName == "" then
		return nil
	end
	local clean = tostring(inputName):gsub("%s+", ""):upper()
	if KEY_ALIASES[clean] ~= nil then
		return KEY_ALIASES[clean] or nil
	end
	local ok, code = pcall(function()
		return Enum.KeyCode[clean]
	end)
	if ok and code then
		return code
	end
	if #clean == 1 then
		local s, c = pcall(function()
			return Enum.KeyCode[clean]
		end)
		if s and c then
			return c
		end
	end
	return nil
end
local function FormatKey(key)
	if not key then
		return "None"
	end
	if typeof(key) == "EnumItem" then
		if key == Enum.UserInputType.MouseButton1 then return "MB1" end
		if key == Enum.UserInputType.MouseButton2 then return "MB2" end
		if key == Enum.UserInputType.MouseButton3 then return "MB3" end
		return key.Name
	end
	return tostring(key)
end
local CHARACTER_FILTERS = {
	All = function(value)
		return value
	end,
	Numeric = function(value)
		return value:match("^%-?%d*$") and value or value:gsub("[^%d-]", ""):gsub("(%-)", function(match, pos)
			return pos == 1 and match or ""
		end)
	end,
	Alphabetic = function(value)
		return value:gsub("[^a-zA-Z ]", "")
	end
}
-- ============================================================================
-- БЛОК 4: МОДУЛЬ ACRYLIC BLUR (3D СТЕКЛЯННОЕ РАЗМЫТИЕ)
-- ============================================================================
local function SetupAcrylicBlur(blurTarget, isBlurEnabledFn)
	local BlurController = {}
	local camera = workspace.CurrentCamera
	local MTREL = "Glass"
	local wedgeGuid = HttpService:GenerateGUID(true)
	local depthOfField = nil
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
			depthOfField = v
			break
		end
	end
	if not depthOfField then
		depthOfField = Instance.new("DepthOfFieldEffect")
		depthOfField.FarIntensity = 0
		depthOfField.FocusDistance = 51.6
		depthOfField.InFocusRadius = 50
		depthOfField.NearIntensity = 1
		depthOfField.Name = HttpService:GenerateGUID(true)
		depthOfField:AddTag(".")
		depthOfField.Parent = Lighting
	end
	local frame = Instance.new("Frame")
	frame.Parent = blurTarget
	frame.Size = UDim2.new(0.97, 0, 0.97, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Name = HttpService:GenerateGUID(true)
	local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
	local sz = 0.2
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
		else
			A, B, C = v3, v1, v2
		end
		local abMag = (A - B).magnitude
		if abMag <= 1e-5 then
			return p0, p1
		end
		local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / abMag
		local perp = sqrt(max(0, (C - A).magnitude ^ 2 - para * para))
		local difPara = abMag - para
		local st = CFrame.new(B, A)
		local za = CFrame.Angles(pi / 2, 0, 0)
		local cf0 = st
		local topLook = (cf0 * za).lookVector
		local midPoint = A + CFrame.new(A, B).lookVector * para
		local neededLook = CFrame.new(midPoint, C).lookVector
		local dot = math.clamp(topLook.x * neededLook.x + topLook.y * neededLook.y + topLook.z * neededLook.z, -1, 1)
		local ac = CFrame.Angles(0, 0, acos(dot))
		cf0 = cf0 * ac
		if ((cf0 * za).lookVector - neededLook).magnitude > 0.01 then
			cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot))
		end
		cf0 = cf0 * CFrame.new(0, perp / 2, -(difPara + para / 2))
		local cf1 = st * ac * CFrame.Angles(0, pi, 0)
		if ((cf1 * za).lookVector - neededLook).magnitude > 0.01 then
			cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
		end
		cf1 = cf1 * CFrame.new(0, perp / 2, difPara / 2)
		if not p0 then
			p0 = Instance.new("Part")
			p0.FormFactor = "Custom"
			p0.TopSurface = 0
			p0.BottomSurface = 0
			p0.Anchored = true
			p0.CanCollide = false
			p0.CastShadow = false
			p0.Material = MTREL
			p0.Size = Vector3.new(sz, sz, sz)
			p0.Name = HttpService:GenerateGUID(true)
			local mesh = Instance.new("SpecialMesh", p0)
			mesh.MeshType = 2
			mesh.Name = wedgeGuid
		end
		p0[wedgeGuid].Scale = Vector3.new(0, perp / sz, para / sz)
		p0.CFrame = cf0
		if not p1 then
			p1 = p0:Clone()
		end
		p1[wedgeGuid].Scale = Vector3.new(0, perp / sz, difPara / sz)
		p1.CFrame = cf1
		return p0, p1
	end
	local function DrawQuad(v1, v2, v3, v4, partsList)
		partsList[1], partsList[2] = DrawTriangle(v1, v2, v3, partsList[1], partsList[2])
		partsList[3], partsList[4] = DrawTriangle(v3, v2, v4, partsList[3], partsList[4])
	end
	local parts = {}
	local parents = {}
	do
		local function addParent(child)
			if child:IsA("GuiObject") then
				parents[#parents + 1] = child
				if child.Parent then
					addParent(child.Parent)
				end
			end
		end
		addParent(frame)
	end
	local function IsVisible(instance)
		while instance do
			if instance:IsA("GuiObject") then
				if not instance.Visible then
					return false
				end
			elseif instance:IsA("ScreenGui") then
				if not instance.Enabled then
					return false
				end
				break
			end
			instance = instance.Parent
		end
		return true
	end
	local function UpdateOrientation(fetchProps)
		camera = workspace.CurrentCamera
		if not camera or not IsVisible(frame) or not isBlurEnabledFn() then
			for _, pt in pairs(parts) do
				pt.Parent = nil
			end
			if depthOfField then
				depthOfField.Enabled = false
			end
			return
		end
		local rayCheck = camera:ScreenPointToRay(0, 0).Origin.x
		if rayCheck ~= rayCheck then
			return
		end
		if depthOfField then
			depthOfField.Enabled = true
		end
		local zIndex = 1 - 0.05 * frame.ZIndex
		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		local rot = 0
		for _, v in ipairs(parents) do
			rot = rot + v.Rotation
		end
		if rot ~= 0 and rot % 180 ~= 0 then
			local mid = tl:Lerp(br, 0.5)
			local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
			tl = Vector2.new(c * (tl.x - mid.x) - s * (tl.y - mid.y), s * (tl.x - mid.x) + c * (tl.y - mid.y)) + mid
			tr = Vector2.new(c * (tr.x - mid.x) - s * (tr.y - mid.y), s * (tr.x - mid.x) + c * (tr.y - mid.y)) + mid
			bl = Vector2.new(c * (bl.x - mid.x) - s * (bl.y - mid.y), s * (bl.x - mid.x) + c * (bl.y - mid.y)) + mid
			br = Vector2.new(c * (br.x - mid.x) - s * (br.y - mid.y), s * (br.x - mid.x) + c * (br.y - mid.y)) + mid
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
				pt.Parent = camera
				pt.Transparency = 0.98
				pt.BrickColor = BrickColor.new("Institutional white")
			end
		else
			for _, pt in pairs(parts) do
				if pt.Parent ~= camera then
					pt.Parent = camera
					pt.Transparency = 0.98
					pt.BrickColor = BrickColor.new("Institutional white")
				end
			end
		end
	end
	task.spawn(function()
		UpdateOrientation(true)
	end)
	local renderConn = RunService.RenderStepped:Connect(function()
		UpdateOrientation(false)
	end)
	function BlurController:Destroy()
		if renderConn then
			renderConn:Disconnect()
			renderConn = nil
		end
		for _, pt in pairs(parts) do
			if pt then
				pt:Destroy()
			end
		end
		table.clear(parts)
		if depthOfField then
			depthOfField.Enabled = false
		end
	end
	return BlurController
end
-- ============================================================================
-- БЛОК 5: ГЛАВНОЕ ОКНО (MacLib:Window)
-- ============================================================================
function MacLib:Window(Settings)
	Settings = Settings or {}
	local WindowFunctions = {}
	local windowConnections = {}
	local function TrackConnection(conn)
		table.insert(windowConnections, conn)
		return conn
	end
	local acrylicBlur = (Settings.AcrylicBlur ~= nil) and Settings.AcrylicBlur or true
	local windowState = true
	local hasGlobalSetting = false
	local tabs = {}
	local currentTabInstance = nil
	local tabIndex = 0
	local Camera = workspace.CurrentCamera
	local isMobile = UserInputService.TouchEnabled
	local macLib = Instance.new("ScreenGui")
	macLib.Name = "MacLib"
	macLib.ResetOnSpawn = false
	macLib.DisplayOrder = 100
	macLib.IgnoreGuiInset = true
	macLib.ScreenInsets = Enum.ScreenInsets.None
	macLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	macLib.Parent = GetSafeGuiParent()
	-- Контейнер уведомлений
	local notifications = Instance.new("Frame")
	notifications.Name = "Notifications"
	notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notifications.BackgroundTransparency = 1
	notifications.BorderSizePixel = 0
	notifications.Size = UDim2.fromScale(1, 1)
	notifications.ZIndex = 2
	notifications.Parent = macLib
	local notificationsUIListLayout = Instance.new("UIListLayout")
	notificationsUIListLayout.Name = "NotificationsUIListLayout"
	notificationsUIListLayout.Padding = UDim.new(0, 10)
	notificationsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notificationsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notificationsUIListLayout.Parent = notifications
	local notificationsUIPadding = Instance.new("UIPadding")
	notificationsUIPadding.Name = "NotificationsUIPadding"
	notificationsUIPadding.PaddingBottom = UDim.new(0, 10)
	notificationsUIPadding.PaddingLeft = UDim.new(0, 10)
	notificationsUIPadding.PaddingRight = UDim.new(0, 10)
	notificationsUIPadding.PaddingTop = UDim.new(0, 10)
	notificationsUIPadding.Parent = notifications
	-- Основная база окна
	local base = Instance.new("Frame")
	base.Name = "Base"
	base.AnchorPoint = Vector2.new(0.5, 0.5)
	base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	base.BackgroundTransparency = acrylicBlur and 0.05 or 0
	base.BorderSizePixel = 0
	base.Position = UDim2.fromScale(0.5, 0.5)
	base.Size = Settings.Size or UDim2.fromOffset(868, 650)
	local baseUIScale = Instance.new("UIScale")
	baseUIScale.Name = "BaseUIScale"
	baseUIScale.Scale = 1
	baseUIScale.Parent = base
	-- Автоматическая подгонка масштаба под экран устройства
	local function AutoScaleForMobile()
		Camera = workspace.CurrentCamera
		if not Camera or not base or not baseUIScale then
			return
		end
		local viewportSize = Camera.ViewportSize
		if viewportSize.X == 0 or viewportSize.Y == 0 then
			return
		end
		local targetSize = Settings.Size or UDim2.fromOffset(868, 650)
		local baseWidth = targetSize.X.Offset > 0 and targetSize.X.Offset or 868
		local baseHeight = targetSize.Y.Offset > 0 and targetSize.Y.Offset or 650
		local scaleX = (viewportSize.X * 0.92) / baseWidth
		local scaleY = (viewportSize.Y * 0.92) / baseHeight
		local finalScale = math.min(scaleX, scaleY)
		if isMobile or finalScale < 1 then
			baseUIScale.Scale = math.clamp(finalScale, 0.35, 1)
		else
			baseUIScale.Scale = Settings.Scale or 1
		end
	end
	if Camera then
		TrackConnection(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(AutoScaleForMobile))
	end
	task.spawn(AutoScaleForMobile)
	local baseUICorner = Instance.new("UICorner")
	baseUICorner.Name = "BaseUICorner"
	baseUICorner.CornerRadius = UDim.new(0, 10)
	baseUICorner.Parent = base
	local baseUIStroke = Instance.new("UIStroke")
	baseUIStroke.Name = "BaseUIStroke"
	baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
	baseUIStroke.Transparency = 0.9
	baseUIStroke.Parent = base
	-- Боковая панель (Sidebar)
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundTransparency = 1
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.fromScale(0, 0)
	sidebar.Size = UDim2.fromScale(0.325, 1)
	sidebar.Parent = base
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.AnchorPoint = Vector2.new(1, 0)
	divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider.BackgroundTransparency = 0.9
	divider.BorderSizePixel = 0
	divider.Position = UDim2.fromScale(1, 0)
	divider.Size = UDim2.new(0, 1, 1, 0)
	divider.Parent = sidebar
	-- Кнопки управления окном (Exit, Minimize, Maximize)
	local windowControls = Instance.new("Frame")
	windowControls.Name = "WindowControls"
	windowControls.BackgroundTransparency = 1
	windowControls.BorderSizePixel = 0
	windowControls.Size = UDim2.new(1, 0, 0, 31)
	windowControls.Parent = sidebar
	local controls = Instance.new("Frame")
	controls.Name = "Controls"
	controls.BackgroundTransparency = 1
	controls.BorderSizePixel = 0
	controls.Size = UDim2.fromScale(1, 1)
	controls.Parent = windowControls
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.Padding = UDim.new(0, 5)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = controls
	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingLeft = UDim.new(0, 11)
	uIPadding.Parent = controls
	local windowControlSettings = {
		sizes = { enabled = UDim2.fromOffset(12, 12), disabled = UDim2.fromOffset(8, 8) },
		transparencies = { enabled = 0, disabled = 1 },
		strokeTransparency = 0.9
	}
	local controlStrokeTemplate = Instance.new("UIStroke")
	controlStrokeTemplate.Name = "BaseUIStroke"
	controlStrokeTemplate.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	controlStrokeTemplate.Color = Color3.fromRGB(255, 255, 255)
	controlStrokeTemplate.Transparency = windowControlSettings.strokeTransparency
	local function CreateControlDot(name, color, order)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		btn.Text = ""
		btn.TextSize = 14
		btn.AutoButtonColor = false
		btn.BackgroundColor3 = color
		btn.BorderSizePixel = 0
		btn.LayoutOrder = order
		btn.Parent = controls
		local corner = Instance.new("UICorner")
		corner.Name = "UICorner"
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = btn
		return btn
	end
	local exit = CreateControlDot("Exit", Color3.fromRGB(250, 93, 86), 0)
	local minimize = CreateControlDot("Minimize", Color3.fromRGB(252, 190, 57), 1)
	local maximize = CreateControlDot("Maximize", Color3.fromRGB(119, 174, 94), 2)
	local function ApplyControlDotState(button, enabled)
		button.Size = enabled and windowControlSettings.sizes.enabled or windowControlSettings.sizes.disabled
		button.BackgroundTransparency = enabled and windowControlSettings.transparencies.enabled or windowControlSettings.transparencies.disabled
		button.Active = enabled
		button.Interactable = enabled
		for _, child in ipairs(button:GetChildren()) do
			if child:IsA("UIStroke") then
				child.Transparency = enabled and 0 or windowControlSettings.strokeTransparency
			end
		end
		if not enabled and not button:FindFirstChildOfClass("UIStroke") then
			controlStrokeTemplate:Clone().Parent = button
		end
	end
	ApplyControlDotState(maximize, false)
	for _, button in ipairs({ exit, minimize }) do
		local isEnabled = true
		if Settings.DisabledWindowControls and table.find(Settings.DisabledWindowControls, button.Name) then
			isEnabled = false
		end
		ApplyControlDotState(button, isEnabled)
	end
	local divider1 = Instance.new("Frame")
	divider1.Name = "Divider"
	divider1.AnchorPoint = Vector2.new(0, 1)
	divider1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider1.BackgroundTransparency = 0.9
	divider1.BorderSizePixel = 0
	divider1.Position = UDim2.fromScale(0, 1)
	divider1.Size = UDim2.new(1, 0, 0, 1)
	divider1.Parent = windowControls
	-- Информация о скрипте (Title / Subtitle / GlobalSettingsButton)
	local information = Instance.new("Frame")
	information.Name = "Information"
	information.BackgroundTransparency = 1
	information.BorderSizePixel = 0
	information.Position = UDim2.fromOffset(0, 31)
	information.Size = UDim2.new(1, 0, 0, 60)
	information.Parent = sidebar
	local divider2 = Instance.new("Frame")
	divider2.Name = "Divider"
	divider2.AnchorPoint = Vector2.new(0, 1)
	divider2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider2.BackgroundTransparency = 0.9
	divider2.BorderSizePixel = 0
	divider2.Position = UDim2.fromScale(0, 1)
	divider2.Size = UDim2.new(1, 0, 0, 1)
	divider2.Parent = information
	local informationHolder = Instance.new("Frame")
	informationHolder.Name = "InformationHolder"
	informationHolder.BackgroundTransparency = 1
	informationHolder.BorderSizePixel = 0
	informationHolder.Size = UDim2.fromScale(1, 1)
	informationHolder.Parent = information
	local informationHolderUIPadding = Instance.new("UIPadding")
	informationHolderUIPadding.Name = "InformationHolderUIPadding"
	informationHolderUIPadding.PaddingBottom = UDim.new(0, 10)
	informationHolderUIPadding.PaddingLeft = UDim.new(0, 23)
	informationHolderUIPadding.PaddingRight = UDim.new(0, 22)
	informationHolderUIPadding.PaddingTop = UDim.new(0, 10)
	informationHolderUIPadding.Parent = informationHolder
	local globalSettingsButton = Instance.new("ImageButton")
	globalSettingsButton.Name = "GlobalSettingsButton"
	globalSettingsButton.Image = assets.globalSettingsIcon
	globalSettingsButton.ImageTransparency = 0.4
	globalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
	globalSettingsButton.BackgroundTransparency = 1
	globalSettingsButton.BorderSizePixel = 0
	globalSettingsButton.Position = UDim2.fromScale(1, 0.5)
	globalSettingsButton.Size = UDim2.fromOffset(15, 15)
	globalSettingsButton.Parent = informationHolder
	globalSettingsButton.MouseEnter:Connect(function()
		Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.2 }):Play()
	end)
	globalSettingsButton.MouseLeave:Connect(function()
		Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.4 }):Play()
	end)
	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "TitleFrame"
	titleFrame.BackgroundTransparency = 1
	titleFrame.BorderSizePixel = 0
	titleFrame.Size = UDim2.fromScale(1, 1)
	titleFrame.Parent = informationHolder
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	title.Text = Settings.Title or "MacLib"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.RichText = true
	title.TextSize = 20
	title.TextTransparency = 0.2
	title.TextTruncate = Enum.TextTruncate.SplitWord
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Top
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.BackgroundTransparency = 1
	title.BorderSizePixel = 0
	title.Size = UDim2.new(1, -20, 0, 0)
	title.Parent = titleFrame
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	subtitle.RichText = true
	subtitle.Text = Settings.Subtitle or ""
	subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.TextSize = 12
	subtitle.TextTransparency = 0.7
	subtitle.TextTruncate = Enum.TextTruncate.SplitWord
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextYAlignment = Enum.TextYAlignment.Top
	subtitle.AutomaticSize = Enum.AutomaticSize.Y
	subtitle.BackgroundTransparency = 1
	subtitle.BorderSizePixel = 0
	subtitle.LayoutOrder = 1
	subtitle.Size = UDim2.new(1, -20, 0, 0)
	subtitle.Parent = titleFrame
	local titleFrameUIListLayout = Instance.new("UIListLayout")
	titleFrameUIListLayout.Name = "TitleFrameUIListLayout"
	titleFrameUIListLayout.Padding = UDim.new(0, 3)
	titleFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	titleFrameUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	titleFrameUIListLayout.Parent = titleFrame
	-- Группа вкладок и профиль пользователя в Sidebar
	local sidebarGroup = Instance.new("Frame")
	sidebarGroup.Name = "SidebarGroup"
	sidebarGroup.BackgroundTransparency = 1
	sidebarGroup.BorderSizePixel = 0
	sidebarGroup.Position = UDim2.fromOffset(0, 91)
	sidebarGroup.Size = UDim2.new(1, 0, 1, -91)
	sidebarGroup.Parent = sidebar
	local userInfo = Instance.new("Frame")
	userInfo.Name = "UserInfo"
	userInfo.AnchorPoint = Vector2.new(0, 1)
	userInfo.BackgroundTransparency = 1
	userInfo.BorderSizePixel = 0
	userInfo.Position = UDim2.fromScale(0, 1)
	userInfo.Size = UDim2.new(1, 0, 0, 107)
	userInfo.Parent = sidebarGroup
	local informationGroup = Instance.new("Frame")
	informationGroup.Name = "InformationGroup"
	informationGroup.BackgroundTransparency = 1
	informationGroup.BorderSizePixel = 0
	informationGroup.Size = UDim2.fromScale(1, 1)
	informationGroup.Parent = userInfo
	local informationGroupUIPadding = Instance.new("UIPadding")
	informationGroupUIPadding.Name = "InformationGroupUIPadding"
	informationGroupUIPadding.PaddingBottom = UDim.new(0, 17)
	informationGroupUIPadding.PaddingLeft = UDim.new(0, 25)
	informationGroupUIPadding.Parent = informationGroup
	local informationGroupUIListLayout = Instance.new("UIListLayout")
	informationGroupUIListLayout.Name = "InformationGroupUIListLayout"
	informationGroupUIListLayout.FillDirection = Enum.FillDirection.Horizontal
	informationGroupUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	informationGroupUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	informationGroupUIListLayout.Parent = informationGroup
	local headshot = Instance.new("ImageLabel")
	headshot.Name = "Headshot"
	headshot.BackgroundTransparency = 1
	headshot.BorderSizePixel = 0
	headshot.Size = UDim2.fromOffset(32, 32)
	headshot.Image = "rbxassetid://0"
	headshot.Parent = informationGroup
	local uICorner3 = Instance.new("UICorner")
	uICorner3.Name = "UICorner"
	uICorner3.CornerRadius = UDim.new(1, 0)
	uICorner3.Parent = headshot
	local baseUIStroke2 = Instance.new("UIStroke")
	baseUIStroke2.Name = "BaseUIStroke"
	baseUIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	baseUIStroke2.Color = Color3.fromRGB(255, 255, 255)
	baseUIStroke2.Transparency = 0.9
	baseUIStroke2.Parent = headshot
	local cachedHeadshotImage = "rbxassetid://0"
	local isHeadshotReady = false
	local userAndDisplayFrame = Instance.new("Frame")
	userAndDisplayFrame.Name = "UserAndDisplayFrame"
	userAndDisplayFrame.BackgroundTransparency = 1
	userAndDisplayFrame.BorderSizePixel = 0
	userAndDisplayFrame.LayoutOrder = 1
	userAndDisplayFrame.Size = UDim2.new(1, -42, 0, 32)
	userAndDisplayFrame.Parent = informationGroup
	local displayName = Instance.new("TextLabel")
	displayName.Name = "DisplayName"
	displayName.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	displayName.Text = LocalPlayer and LocalPlayer.DisplayName or "Player"
	displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
	displayName.TextSize = 13
	displayName.TextTransparency = 0.2
	displayName.TextTruncate = Enum.TextTruncate.SplitWord
	displayName.TextXAlignment = Enum.TextXAlignment.Left
	displayName.TextYAlignment = Enum.TextYAlignment.Top
	displayName.AutomaticSize = Enum.AutomaticSize.XY
	displayName.BackgroundTransparency = 1
	displayName.BorderSizePixel = 0
	displayName.Size = UDim2.fromScale(1, 0)
	displayName.Parent = userAndDisplayFrame
	local userAndDisplayFrameUIPadding = Instance.new("UIPadding")
	userAndDisplayFrameUIPadding.Name = "UserAndDisplayFrameUIPadding"
	userAndDisplayFrameUIPadding.PaddingLeft = UDim.new(0, 8)
	userAndDisplayFrameUIPadding.PaddingTop = UDim.new(0, 3)
	userAndDisplayFrameUIPadding.Parent = userAndDisplayFrame
	local userAndDisplayFrameUIListLayout = Instance.new("UIListLayout")
	userAndDisplayFrameUIListLayout.Name = "UserAndDisplayFrameUIListLayout"
	userAndDisplayFrameUIListLayout.Padding = UDim.new(0, 1)
	userAndDisplayFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	userAndDisplayFrameUIListLayout.Parent = userAndDisplayFrame
	local username = Instance.new("TextLabel")
	username.Name = "Username"
	username.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	username.Text = "@" .. (LocalPlayer and LocalPlayer.Name or "User")
	username.TextColor3 = Color3.fromRGB(255, 255, 255)
	username.TextSize = 12
	username.TextTransparency = 0.8
	username.TextTruncate = Enum.TextTruncate.SplitWord
	username.TextXAlignment = Enum.TextXAlignment.Left
	username.TextYAlignment = Enum.TextYAlignment.Top
	username.AutomaticSize = Enum.AutomaticSize.XY
	username.BackgroundTransparency = 1
	username.BorderSizePixel = 0
	username.LayoutOrder = 1
	username.Size = UDim2.fromScale(1, 0)
	username.Parent = userAndDisplayFrame
	local userInfoUIPadding = Instance.new("UIPadding")
	userInfoUIPadding.Name = "UserInfoUIPadding"
	userInfoUIPadding.PaddingLeft = UDim.new(0, 10)
	userInfoUIPadding.PaddingRight = UDim.new(0, 10)
	userInfoUIPadding.Parent = userInfo
	local sidebarGroupUIPadding = Instance.new("UIPadding")
	sidebarGroupUIPadding.Name = "SidebarGroupUIPadding"
	sidebarGroupUIPadding.PaddingLeft = UDim.new(0, 10)
	sidebarGroupUIPadding.PaddingRight = UDim.new(0, 10)
	sidebarGroupUIPadding.PaddingTop = UDim.new(0, 31)
	sidebarGroupUIPadding.Parent = sidebarGroup
	local tabSwitchers = Instance.new("Frame")
	tabSwitchers.Name = "TabSwitchers"
	tabSwitchers.BackgroundTransparency = 1
	tabSwitchers.BorderSizePixel = 0
	tabSwitchers.Size = UDim2.new(1, 0, 1, -107)
	tabSwitchers.Parent = sidebarGroup
	local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
	tabSwitchersScrollingFrame.Name = "TabSwitchersScrollingFrame"
	tabSwitchersScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabSwitchersScrollingFrame.BottomImage = ""
	tabSwitchersScrollingFrame.CanvasSize = UDim2.new()
	tabSwitchersScrollingFrame.ScrollBarImageTransparency = 0.8
	tabSwitchersScrollingFrame.ScrollBarThickness = 1
	tabSwitchersScrollingFrame.TopImage = ""
	tabSwitchersScrollingFrame.BackgroundTransparency = 1
	tabSwitchersScrollingFrame.BorderSizePixel = 0
	tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)
	tabSwitchersScrollingFrame.Parent = tabSwitchers
	local tabSwitchersScrollingFrameUIListLayout = Instance.new("UIListLayout")
	tabSwitchersScrollingFrameUIListLayout.Name = "TabSwitchersScrollingFrameUIListLayout"
	tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, 17)
	tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame
	local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
	tabSwitchersScrollingFrameUIPadding.Name = "TabSwitchersScrollingFrameUIPadding"
	tabSwitchersScrollingFrameUIPadding.PaddingTop = UDim.new(0, 2)
	tabSwitchersScrollingFrameUIPadding.Parent = tabSwitchersScrollingFrame
	-- Контентная часть (Content & Topbar)
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.AnchorPoint = Vector2.new(1, 0)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.Position = UDim2.fromScale(1, 0)
	content.Size = UDim2.fromScale(0.675, 1)
	content.Parent = base
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.BackgroundTransparency = 1
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(1, 0, 0, 63)
	topbar.Parent = content
	local divider4 = Instance.new("Frame")
	divider4.Name = "Divider"
	divider4.AnchorPoint = Vector2.new(0, 1)
	divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider4.BackgroundTransparency = 0.9
	divider4.BorderSizePixel = 0
	divider4.Position = UDim2.fromScale(0, 1)
	divider4.Size = UDim2.new(1, 0, 0, 1)
	divider4.Parent = topbar
	local elements = Instance.new("Frame")
	elements.Name = "Elements"
	elements.BackgroundTransparency = 1
	elements.BorderSizePixel = 0
	elements.Size = UDim2.fromScale(1, 1)
	elements.Parent = topbar
	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.Name = "UIPadding"
	uIPadding2.PaddingLeft = UDim.new(0, 20)
	uIPadding2.PaddingRight = UDim.new(0, 20)
	uIPadding2.Parent = elements
	local moveIcon = Instance.new("ImageButton")
	moveIcon.Name = "MoveIcon"
	moveIcon.Image = assets.moveIcon
	moveIcon.ImageTransparency = 0.5
	moveIcon.AnchorPoint = Vector2.new(1, 0.5)
	moveIcon.BackgroundTransparency = 1
	moveIcon.BorderSizePixel = 0
	moveIcon.Position = UDim2.fromScale(1, 0.5)
	moveIcon.Size = UDim2.fromOffset(15, 15)
	moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1
	moveIcon.Parent = elements
	local interact = Instance.new("TextButton")
	interact.Name = "Interact"
	interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	interact.Text = ""
	interact.TextSize = 14
	interact.AnchorPoint = Vector2.new(0.5, 0.5)
	interact.BackgroundTransparency = 1
	interact.BorderSizePixel = 0
	interact.Position = UDim2.fromScale(0.5, 0.5)
	interact.Size = UDim2.fromOffset(40, 40)
	interact.Parent = moveIcon
	interact.MouseEnter:Connect(function()
		Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.2 }):Play()
	end)
	interact.MouseLeave:Connect(function()
		Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.5 }):Play()
	end)
	-- Логика перетаскивания окна с поддержкой Touch и UIScale
	local draggingWindow = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	local function UpdateWindowDrag(input)
		local delta = input.Position - dragStart
		local currentScale = (baseUIScale and baseUIScale.Scale > 0) and baseUIScale.Scale or 1
		base.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + (delta.X / currentScale),
			startPos.Y.Scale,
			startPos.Y.Offset + (delta.Y / currentScale)
		)
	end
	local dragHandle = (Settings.DragStyle == 2) and base or interact
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingWindow = true
			dragStart = input.Position
			startPos = base.Position
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			dragInput = input
		end
	end)
	TrackConnection(UserInputService.InputChanged:Connect(function(input)
		if draggingWindow and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
			UpdateWindowDrag(input)
		end
	end))
	TrackConnection(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingWindow = false
		end
	end))
	local currentTab = Instance.new("TextLabel")
	currentTab.Name = "CurrentTab"
	currentTab.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	currentTab.RichText = true
	currentTab.Text = "Tab"
	currentTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentTab.TextSize = 15
	currentTab.TextTransparency = 0.5
	currentTab.TextTruncate = Enum.TextTruncate.SplitWord
	currentTab.TextXAlignment = Enum.TextXAlignment.Left
	currentTab.TextYAlignment = Enum.TextYAlignment.Top
	currentTab.AnchorPoint = Vector2.new(0, 0.5)
	currentTab.AutomaticSize = Enum.AutomaticSize.Y
	currentTab.BackgroundTransparency = 1
	currentTab.BorderSizePixel = 0
	currentTab.Position = UDim2.fromScale(0, 0.5)
	currentTab.Size = UDim2.fromScale(0.9, 0)
	currentTab.Parent = elements
	-- Панель GlobalSettings
	local globalSettings = Instance.new("Frame")
	globalSettings.Name = "GlobalSettings"
	globalSettings.AutomaticSize = Enum.AutomaticSize.XY
	globalSettings.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	globalSettings.BorderSizePixel = 0
	globalSettings.Position = UDim2.fromScale(0.298, 0.104)
	globalSettings.ZIndex = 10
	globalSettings.Parent = base
	local globalSettingsUIStroke = Instance.new("UIStroke")
	globalSettingsUIStroke.Name = "GlobalSettingsUIStroke"
	globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
	globalSettingsUIStroke.Transparency = 0.9
	globalSettingsUIStroke.Parent = globalSettings
	local globalSettingsUICorner = Instance.new("UICorner")
	globalSettingsUICorner.Name = "GlobalSettingsUICorner"
	globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
	globalSettingsUICorner.Parent = globalSettings
	local globalSettingsUIPadding = Instance.new("UIPadding")
	globalSettingsUIPadding.Name = "GlobalSettingsUIPadding"
	globalSettingsUIPadding.PaddingBottom = UDim.new(0, 10)
	globalSettingsUIPadding.PaddingTop = UDim.new(0, 10)
	globalSettingsUIPadding.Parent = globalSettings
	local globalSettingsUIListLayout = Instance.new("UIListLayout")
	globalSettingsUIListLayout.Name = "GlobalSettingsUIListLayout"
	globalSettingsUIListLayout.Padding = UDim.new(0, 5)
	globalSettingsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	globalSettingsUIListLayout.Parent = globalSettings
	local globalSettingsUIScale = Instance.new("UIScale")
	globalSettingsUIScale.Name = "GlobalSettingsUIScale"
	globalSettingsUIScale.Scale = 1e-07
	globalSettingsUIScale.Parent = globalSettings
	base.Parent = macLib
	function WindowFunctions:UpdateTitle(NewTitle)
		title.Text = NewTitle
	end
	function WindowFunctions:UpdateSubtitle(NewSubtitle)
		subtitle.Text = NewSubtitle
	end
	local hoveringGlobal = false
	local toggledGlobal = false
	local function ToggleGlobalMenu()
		toggledGlobal = not toggledGlobal
		Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Scale = toggledGlobal and 1 or 0
		}):Play()
	end
	globalSettingsButton.MouseButton1Click:Connect(function()
		if not hasGlobalSetting then
			return
		end
		ToggleGlobalMenu()
	end)
	globalSettings.MouseEnter:Connect(function()
		hoveringGlobal = true
	end)
	globalSettings.MouseLeave:Connect(function()
		hoveringGlobal = false
	end)
	TrackConnection(UserInputService.InputEnded:Connect(function(inp)
		if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and toggledGlobal and not hoveringGlobal then
			ToggleGlobalMenu()
		end
	end))
	local blurController = SetupAcrylicBlur(base, function()
		return acrylicBlur
	end)
	-- ========================================================================
	-- БЛОК 6: GLOBAL SETTING, NOTIFY И DIALOG
	-- ========================================================================
	function WindowFunctions:GlobalSetting(SettingConfig)
		hasGlobalSetting = true
		local GlobalSettingFunctions = {}
		local globalSetting = Instance.new("TextButton")
		globalSetting.Name = "GlobalSetting"
		globalSetting.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		globalSetting.Text = ""
		globalSetting.TextSize = 14
		globalSetting.BackgroundTransparency = 1
		globalSetting.BorderSizePixel = 0
		globalSetting.Size = UDim2.fromOffset(200, 30)
		globalSetting.Parent = globalSettings
		local globalSettingToggleUIPadding = Instance.new("UIPadding")
		globalSettingToggleUIPadding.Name = "GlobalSettingToggleUIPadding"
		globalSettingToggleUIPadding.PaddingLeft = UDim.new(0, 15)
		globalSettingToggleUIPadding.Parent = globalSetting
		local settingName = Instance.new("TextLabel")
		settingName.Name = "SettingName"
		settingName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		settingName.Text = SettingConfig.Name
		settingName.RichText = true
		settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
		settingName.TextSize = 13
		settingName.TextTransparency = 0.5
		settingName.TextTruncate = Enum.TextTruncate.SplitWord
		settingName.TextXAlignment = Enum.TextXAlignment.Left
		settingName.TextYAlignment = Enum.TextYAlignment.Top
		settingName.AnchorPoint = Vector2.new(0, 0.5)
		settingName.AutomaticSize = Enum.AutomaticSize.Y
		settingName.BackgroundTransparency = 1
		settingName.BorderSizePixel = 0
		settingName.Position = UDim2.fromScale(0, 0.5)
		settingName.Size = UDim2.new(1, -40, 0, 0)
		settingName.Parent = globalSetting
		local globalSettingToggleUIListLayout = Instance.new("UIListLayout")
		globalSettingToggleUIListLayout.Name = "GlobalSettingToggleUIListLayout"
		globalSettingToggleUIListLayout.Padding = UDim.new(0, 10)
		globalSettingToggleUIListLayout.FillDirection = Enum.FillDirection.Horizontal
		globalSettingToggleUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		globalSettingToggleUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		globalSettingToggleUIListLayout.Parent = globalSetting
		local checkmark = Instance.new("TextLabel")
		checkmark.Name = "Checkmark"
		checkmark.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		checkmark.Text = "✓"
		checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
		checkmark.TextSize = 13
		checkmark.TextTransparency = 1
		checkmark.TextXAlignment = Enum.TextXAlignment.Left
		checkmark.TextYAlignment = Enum.TextYAlignment.Top
		checkmark.AnchorPoint = Vector2.new(0, 0.5)
		checkmark.AutomaticSize = Enum.AutomaticSize.Y
		checkmark.BackgroundTransparency = 1
		checkmark.BorderSizePixel = 0
		checkmark.LayoutOrder = -1
		checkmark.Position = UDim2.fromScale(0, 0.5)
		checkmark.Size = UDim2.fromOffset(-10, 0)
		checkmark.Parent = globalSetting
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tweens = {
			checkIn = Tween(checkmark, tweenInfo, {
				Size = UDim2.fromOffset(12, 0),
				TextTransparency = 0
			}),
			checkOut = Tween(checkmark, tweenInfo, {
				Size = UDim2.fromOffset(-10, 0),
				TextTransparency = 1
			}),
			nameIn = Tween(settingName, tweenInfo, { TextTransparency = 0.2 }),
			nameOut = Tween(settingName, tweenInfo, { TextTransparency = 0.5 })
		}
		local function SetVisualToggle(state)
			if state then
				tweens.checkIn:Play()
				tweens.nameIn:Play()
			else
				tweens.checkOut:Play()
				tweens.nameOut:Play()
			end
		end
		local isSettingToggled = SettingConfig.Default and true or false
		SetVisualToggle(isSettingToggled)
		globalSetting.MouseButton1Click:Connect(function()
			isSettingToggled = not isSettingToggled
			SetVisualToggle(isSettingToggled)
			if SettingConfig.Callback then
				task.spawn(SettingConfig.Callback, isSettingToggled)
			end
		end)
		function GlobalSettingFunctions:UpdateName(NewName)
			settingName.Text = NewName
		end
		function GlobalSettingFunctions:UpdateState(NewState)
			isSettingToggled = NewState and true or false
			SetVisualToggle(isSettingToggled)
			if SettingConfig.Callback then
				task.spawn(SettingConfig.Callback, isSettingToggled)
			end
		end
		return GlobalSettingFunctions
	end
	-- ========================================================================
	-- БЛОК 7: TABGROUP, TAB И COLLAPSIBLE SECTION
	-- ========================================================================
	function WindowFunctions:TabGroup()
		local GroupFunctions = {}
		local tabGroup = Instance.new("Frame")
		tabGroup.Name = "Section"
		tabGroup.AutomaticSize = Enum.AutomaticSize.Y
		tabGroup.BackgroundTransparency = 1
		tabGroup.BorderSizePixel = 0
		tabGroup.Size = UDim2.fromScale(1, 0)
		tabGroup.Parent = tabSwitchersScrollingFrame
		local divider3 = Instance.new("Frame")
		divider3.Name = "Divider"
		divider3.AnchorPoint = Vector2.new(0.5, 1)
		divider3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		divider3.BackgroundTransparency = 0.9
		divider3.BorderSizePixel = 0
		divider3.Position = UDim2.fromScale(0.5, 1)
		divider3.Size = UDim2.new(1, -21, 0, 1)
		divider3.Parent = tabGroup
		local sectionTabSwitchers = Instance.new("Frame")
		sectionTabSwitchers.Name = "SectionTabSwitchers"
		sectionTabSwitchers.BackgroundTransparency = 1
		sectionTabSwitchers.BorderSizePixel = 0
		sectionTabSwitchers.Size = UDim2.fromScale(1, 1)
		sectionTabSwitchers.Parent = tabGroup
		local uIListLayout1 = Instance.new("UIListLayout")
		uIListLayout1.Name = "UIListLayout"
		uIListLayout1.Padding = UDim.new(0, 15)
		uIListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout1.Parent = sectionTabSwitchers
		local uIPadding1 = Instance.new("UIPadding")
		uIPadding1.Name = "UIPadding"
		uIPadding1.PaddingBottom = UDim.new(0, 15)
		uIPadding1.Parent = sectionTabSwitchers
		function GroupFunctions:Tab(TabConfig)
			local TabFunctions = {}
			local tabSwitcher = Instance.new("TextButton")
			tabSwitcher.Name = "TabSwitcher"
			tabSwitcher.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			tabSwitcher.Text = ""
			tabSwitcher.TextSize = 14
			tabSwitcher.AutoButtonColor = false
			tabSwitcher.AnchorPoint = Vector2.new(0.5, 0)
			tabSwitcher.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			tabSwitcher.BackgroundTransparency = 1
			tabSwitcher.BorderSizePixel = 0
			tabSwitcher.Position = UDim2.fromScale(0.5, 0)
			tabSwitcher.Size = UDim2.new(1, -21, 0, 40)
			tabIndex = tabIndex + 1
			tabSwitcher.LayoutOrder = tabIndex
			tabSwitcher.Parent = sectionTabSwitchers
			local tabSwitcherUICorner = Instance.new("UICorner")
			tabSwitcherUICorner.Name = "TabSwitcherUICorner"
			tabSwitcherUICorner.Parent = tabSwitcher
			local tabSwitcherUIStroke = Instance.new("UIStroke")
			tabSwitcherUIStroke.Name = "TabSwitcherUIStroke"
			tabSwitcherUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			tabSwitcherUIStroke.Color = Color3.fromRGB(255, 255, 255)
			tabSwitcherUIStroke.Transparency = 1
			tabSwitcherUIStroke.Parent = tabSwitcher
			local tabSwitcherUIListLayout = Instance.new("UIListLayout")
			tabSwitcherUIListLayout.Name = "TabSwitcherUIListLayout"
			tabSwitcherUIListLayout.Padding = UDim.new(0, 9)
			tabSwitcherUIListLayout.FillDirection = Enum.FillDirection.Horizontal
			tabSwitcherUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			tabSwitcherUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			tabSwitcherUIListLayout.Parent = tabSwitcher
			if TabConfig.Image then
				local tabImage = Instance.new("ImageLabel")
				tabImage.Name = "TabImage"
				tabImage.Image = TabConfig.Image
				tabImage.ImageTransparency = 0.4
				tabImage.BackgroundTransparency = 1
				tabImage.BorderSizePixel = 0
				tabImage.Size = UDim2.fromOffset(16, 16)
				tabImage.Parent = tabSwitcher
			end
			local tabSwitcherName = Instance.new("TextLabel")
			tabSwitcherName.Name = "TabSwitcherName"
			tabSwitcherName.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
			tabSwitcherName.Text = TabConfig.Name
			tabSwitcherName.RichText = true
			tabSwitcherName.TextColor3 = Color3.fromRGB(255, 255, 255)
			tabSwitcherName.TextSize = 16
			tabSwitcherName.TextTransparency = 0.4
			tabSwitcherName.TextTruncate = Enum.TextTruncate.SplitWord
			tabSwitcherName.TextXAlignment = Enum.TextXAlignment.Left
			tabSwitcherName.TextYAlignment = Enum.TextYAlignment.Top
			tabSwitcherName.AutomaticSize = Enum.AutomaticSize.Y
			tabSwitcherName.BackgroundTransparency = 1
			tabSwitcherName.BorderSizePixel = 0
			tabSwitcherName.Size = UDim2.fromScale(1, 0)
			tabSwitcherName.LayoutOrder = 1
			tabSwitcherName.Parent = tabSwitcher
			local tabSwitcherUIPadding = Instance.new("UIPadding")
			tabSwitcherUIPadding.Name = "TabSwitcherUIPadding"
			tabSwitcherUIPadding.PaddingLeft = UDim.new(0, 24)
			tabSwitcherUIPadding.PaddingRight = UDim.new(0, 35)
			tabSwitcherUIPadding.PaddingTop = UDim.new(0, 1)
			tabSwitcherUIPadding.Parent = tabSwitcher
			local elements1 = Instance.new("Frame")
			elements1.Name = "Elements"
			elements1.BackgroundTransparency = 1
			elements1.BorderSizePixel = 0
			elements1.Position = UDim2.fromOffset(0, 63)
			elements1.Size = UDim2.new(1, 0, 1, -63)
			local elementsUIPadding = Instance.new("UIPadding")
			elementsUIPadding.Name = "ElementsUIPadding"
			elementsUIPadding.PaddingRight = UDim.new(0, 5)
			elementsUIPadding.PaddingTop = UDim.new(0, 10)
			elementsUIPadding.Parent = elements1
			local elementsScrolling = Instance.new("ScrollingFrame")
			elementsScrolling.Name = "ElementsScrolling"
			elementsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
			elementsScrolling.BottomImage = ""
			elementsScrolling.CanvasSize = UDim2.new()
			elementsScrolling.ScrollBarImageTransparency = 0.5
			elementsScrolling.ScrollBarThickness = 1
			elementsScrolling.TopImage = ""
			elementsScrolling.BackgroundTransparency = 1
			elementsScrolling.BorderSizePixel = 0
			elementsScrolling.Size = UDim2.fromScale(1, 1)
			elementsScrolling.Parent = elements1
			local elementsScrollingUIPadding = Instance.new("UIPadding")
			elementsScrollingUIPadding.Name = "ElementsScrollingUIPadding"
			elementsScrollingUIPadding.PaddingBottom = UDim.new(0, 15)
			elementsScrollingUIPadding.PaddingLeft = UDim.new(0, 11)
			elementsScrollingUIPadding.PaddingRight = UDim.new(0, 3)
			elementsScrollingUIPadding.PaddingTop = UDim.new(0, 5)
			elementsScrollingUIPadding.Parent = elementsScrolling
			local elementsScrollingUIListLayout = Instance.new("UIListLayout")
			elementsScrollingUIListLayout.Name = "ElementsScrollingUIListLayout"
			elementsScrollingUIListLayout.Padding = UDim.new(0, 15)
			elementsScrollingUIListLayout.FillDirection = Enum.FillDirection.Horizontal
			elementsScrollingUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			elementsScrollingUIListLayout.Parent = elementsScrolling
			local left = Instance.new("Frame")
			left.Name = "Left"
			left.AutomaticSize = Enum.AutomaticSize.Y
			left.BackgroundTransparency = 1
			left.BorderSizePixel = 0
			left.Position = UDim2.fromScale(0.512, 0)
			left.Size = UDim2.new(0.5, -10, 0, 0)
			left.Parent = elementsScrolling
			local leftUIListLayout = Instance.new("UIListLayout")
			leftUIListLayout.Name = "LeftUIListLayout"
			leftUIListLayout.Padding = UDim.new(0, 15)
			leftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			leftUIListLayout.Parent = left
			local right = Instance.new("Frame")
			right.Name = "Right"
			right.AutomaticSize = Enum.AutomaticSize.Y
			right.BackgroundTransparency = 1
			right.BorderSizePixel = 0
			right.LayoutOrder = 1
			right.Position = UDim2.fromScale(0.512, 0)
			right.Size = UDim2.new(0.5, -10, 0, 0)
			right.Parent = elementsScrolling
			local rightUIListLayout = Instance.new("UIListLayout")
			rightUIListLayout.Name = "RightUIListLayout"
			rightUIListLayout.Padding = UDim.new(0, 15)
			rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rightUIListLayout.Parent = right
			-- ================================================================
			-- БЛОК 8: СЕКЦИЯ (SECTION) И ВСЕ ИНТЕРАКТИВНЫЕ ЭЛЕМЕНТЫ
			-- ================================================================
			function TabFunctions:Section(SectionConfig)
				SectionConfig = SectionConfig or {}
				local SectionFunctions = {}
				local hasHeader = (SectionConfig.Name ~= nil or SectionConfig.Icon ~= nil)
				local HEADER_HEIGHT = hasHeader and 36 or 0
				local COLLAPSE_DURATION = 0.26
				local section = Instance.new("Frame")
				section.Name = "Section"
				section.AutomaticSize = Enum.AutomaticSize.None
				section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				section.BackgroundTransparency = 0.98
				section.BorderSizePixel = 0
				section.ClipsDescendants = false
				section.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
				section.Parent = (SectionConfig.Side == "Left") and left or right
				local sectionUICorner = Instance.new("UICorner")
				sectionUICorner.Name = "SectionUICorner"
				sectionUICorner.CornerRadius = UDim.new(0, 10)
				sectionUICorner.Parent = section
				ApplyGradientStroke(section, "SectionUIStroke", 0.3, "StrokeGradient")
				local sectionMainLayout = Instance.new("UIListLayout")
				sectionMainLayout.Name = "SectionMainLayout"
				sectionMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
				sectionMainLayout.Parent = section
				local sectionHeaderTop = Instance.new("Frame")
				sectionHeaderTop.Name = "SectionHeaderTop"
				sectionHeaderTop.BackgroundTransparency = 1
				sectionHeaderTop.Size = UDim2.new(1, 0, 0, 36)
				sectionHeaderTop.LayoutOrder = 0
				sectionHeaderTop.Visible = hasHeader
				sectionHeaderTop.Parent = section
				local headerPadding = Instance.new("UIPadding")
				headerPadding.PaddingLeft = UDim.new(0, 16)
				headerPadding.PaddingRight = UDim.new(0, 16)
				headerPadding.Parent = sectionHeaderTop
				local headerTitleHolder = Instance.new("Frame")
				headerTitleHolder.Name = "HeaderTitleHolder"
				headerTitleHolder.BackgroundTransparency = 1
				headerTitleHolder.Size = UDim2.new(1, -30, 1, 0)
				headerTitleHolder.Parent = sectionHeaderTop
				local headerLayout = Instance.new("UIListLayout")
				headerLayout.FillDirection = Enum.FillDirection.Horizontal
				headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				headerLayout.Padding = UDim.new(0, 8)
				headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
				headerLayout.Parent = headerTitleHolder
				if SectionConfig.Icon then
					local sectionIcon = Instance.new("ImageLabel")
					sectionIcon.Name = "SectionIcon"
					sectionIcon.Image = SectionConfig.Icon
					sectionIcon.BackgroundTransparency = 1
					sectionIcon.Size = UDim2.fromOffset(16, 16)
					sectionIcon.LayoutOrder = 1
					sectionIcon.Parent = headerTitleHolder
				end
				if SectionConfig.Name then
					local sectionTitle = Instance.new("TextLabel")
					sectionTitle.Name = "SectionTitle"
					sectionTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					sectionTitle.Text = SectionConfig.Name
					sectionTitle.TextSize = 14
					sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					sectionTitle.BackgroundTransparency = 1
					sectionTitle.AutomaticSize = Enum.AutomaticSize.XY
					sectionTitle.LayoutOrder = 2
					sectionTitle.Parent = headerTitleHolder
				end
				local collapseButton = Instance.new("ImageButton")
				collapseButton.Name = "CollapseButton"
				collapseButton.Image = assets.buttonImage
				collapseButton.ImageColor3 = Color3.fromRGB(220, 220, 220)
				collapseButton.BackgroundTransparency = 1
				collapseButton.AutoButtonColor = false
				collapseButton.AnchorPoint = Vector2.new(1, 0.5)
				collapseButton.Position = UDim2.new(1, 0, 0.5, 0)
				collapseButton.Size = UDim2.fromOffset(14, 14)
				collapseButton.Rotation = 90
				collapseButton.Parent = sectionHeaderTop
				local contentHolder = Instance.new("Frame")
				contentHolder.Name = "ContentHolder"
				contentHolder.BackgroundTransparency = 1
				contentHolder.ClipsDescendants = true
				contentHolder.AutomaticSize = Enum.AutomaticSize.None
				contentHolder.Size = UDim2.new(1, 0, 0, 0)
				contentHolder.LayoutOrder = 1
				contentHolder.Parent = section
				local sectionContainer = Instance.new("Frame")
				sectionContainer.Name = "SectionContainer"
				sectionContainer.BackgroundTransparency = 1
				sectionContainer.AutomaticSize = Enum.AutomaticSize.None
				sectionContainer.Size = UDim2.new(1, 0, 0, 0)
				sectionContainer.Parent = contentHolder
				local sectionUIListLayout = Instance.new("UIListLayout")
				sectionUIListLayout.Name = "SectionUIListLayout"
				sectionUIListLayout.Padding = UDim.new(0, 10)
				sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				sectionUIListLayout.Parent = sectionContainer
				local sectionUIPadding = Instance.new("UIPadding")
				sectionUIPadding.Name = "SectionUIPadding"
				sectionUIPadding.PaddingBottom = UDim.new(0, 16)
				sectionUIPadding.PaddingLeft = UDim.new(0, 18)
				sectionUIPadding.PaddingRight = UDim.new(0, 16)
				sectionUIPadding.PaddingTop = UDim.new(0, SectionConfig.Name and 6 or 16)
				sectionUIPadding.Parent = sectionContainer
				local function GetCurrentScale()
					local s = (baseUIScale and baseUIScale.Scale) or 1
					return (s > 0) and s or 1
				end
				local function GetTargetContentHeight()
					local scale = GetCurrentScale()
					local padTop = sectionUIPadding.PaddingTop.Offset
					local padBottom = sectionUIPadding.PaddingBottom.Offset
					local rawContentY = sectionUIListLayout.AbsoluteContentSize.Y
					if rawContentY > 0 then
						return math.round(rawContentY / scale) + padTop + padBottom
					end
					local fallbackY = 0
					local visibleItems = 0
					local itemPadding = sectionUIListLayout.Padding.Offset
					for _, child in ipairs(sectionContainer:GetChildren()) do
						if child:IsA("GuiObject") and child.Visible then
							visibleItems = visibleItems + 1
							local h = child.Size.Y.Offset
							if h <= 0 and child.AbsoluteSize.Y > 0 then
								h = math.round(child.AbsoluteSize.Y / scale)
							end
							fallbackY = fallbackY + h
						end
					end
					if visibleItems == 0 then
						return 0
					end
					fallbackY = fallbackY + math.max(0, visibleItems - 1) * itemPadding
					return fallbackY + padTop + padBottom
				end
				local isCollapsed = false
				local isAnimating = false
				local animToken = 0
				local currentContentTween = nil
				local currentSectionTween = nil
				local currentArrowTween = nil
				local completedConn = nil
				local function CleanupSectionTweens()
					if completedConn then
						completedConn:Disconnect()
						completedConn = nil
					end
					if currentContentTween then
						currentContentTween:Cancel()
						currentContentTween = nil
					end
					if currentSectionTween then
						currentSectionTween:Cancel()
						currentSectionTween = nil
					end
					if currentArrowTween then
						currentArrowTween:Cancel()
						currentArrowTween = nil
					end
				end
				local function SyncExpandedHeight()
					local targetH = GetTargetContentHeight()
					sectionContainer.Size = UDim2.new(1, 0, 0, targetH)
					if not isCollapsed and not isAnimating then
						contentHolder.Size = UDim2.new(1, 0, 0, targetH)
						section.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT + targetH)
					end
				end
				local layoutSignalConn = sectionUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SyncExpandedHeight)
				local function ToggleCollapse()
					isCollapsed = not isCollapsed
					animToken = animToken + 1
					local myToken = animToken
					CleanupSectionTweens()
					local fullHeight = GetTargetContentHeight()
					sectionContainer.Size = UDim2.new(1, 0, 0, fullHeight)
					if not isCollapsed then
						contentHolder.Visible = true
					end
					local currentHeight = contentHolder.Size.Y.Offset
					local goalHeight = isCollapsed and 0 or fullHeight
					local distance = math.abs(goalHeight - currentHeight)
					local ratio = (fullHeight > 0) and (distance / fullHeight) or 1
					local duration = math.clamp(COLLAPSE_DURATION * math.max(0.45, ratio), 0.12, COLLAPSE_DURATION)
					local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					isAnimating = true
					currentArrowTween = Tween(collapseButton, tweenInfo, { Rotation = isCollapsed and 0 or 90 })
					currentContentTween = Tween(contentHolder, tweenInfo, { Size = UDim2.new(1, 0, 0, goalHeight) })
					currentSectionTween = Tween(section, tweenInfo, { Size = UDim2.new(1, 0, 0, HEADER_HEIGHT + goalHeight) })
					completedConn = currentContentTween.Completed:Connect(function(playbackState)
						if myToken ~= animToken then
							return
						end
						completedConn = nil
						if playbackState == Enum.PlaybackState.Completed then
							isAnimating = false
							if isCollapsed then
								contentHolder.Size = UDim2.new(1, 0, 0, 0)
								section.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
								contentHolder.Visible = false
							else
								local latestH = GetTargetContentHeight()
								sectionContainer.Size = UDim2.new(1, 0, 0, latestH)
								contentHolder.Size = UDim2.new(1, 0, 0, latestH)
								section.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT + latestH)
							end
						end
					end)
					currentArrowTween:Play()
					currentContentTween:Play()
					currentSectionTween:Play()
				end
				local lastToggleClock = 0
				local function SafeTriggerToggle()
					local now = os.clock()
					if now - lastToggleClock < 0.05 then
						return
					end
					lastToggleClock = now
					ToggleCollapse()
				end
				collapseButton.MouseButton1Click:Connect(SafeTriggerToggle)
				if hasHeader then
					local pressStartPos = nil
					local activePointer = nil
					sectionHeaderTop.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							pressStartPos = input.Position
							activePointer = input
						end
					end)
					sectionHeaderTop.InputEnded:Connect(function(input)
						if input == activePointer and pressStartPos then
							local delta = (input.Position - pressStartPos).Magnitude
							pressStartPos = nil
							activePointer = nil
							if delta <= 8 then
								SafeTriggerToggle()
							end
						end
					end)
				end
				section.Destroying:Connect(function()
					CleanupSectionTweens()
					if layoutSignalConn then
						layoutSignalConn:Disconnect()
						layoutSignalConn = nil
					end
				end)
				task.defer(SyncExpandedHeight)
				-- ============================================================
				-- 8.1: BUTTON
				-- ============================================================
				function SectionFunctions:Button(BtnSettings)
					BtnSettings = BtnSettings or {}
					local ButtonFunctions = {}
					local button = Instance.new("Frame")
					button.Name = "Button"
					button.BackgroundTransparency = 1
					button.BorderSizePixel = 0
					button.Size = UDim2.new(1, 0, 0, 38)
					button.Parent = sectionContainer
					local buttonCard = Instance.new("Frame")
					buttonCard.Name = "ButtonCard"
					buttonCard.AnchorPoint = Vector2.new(0.5, 0.5)
					buttonCard.Position = UDim2.fromScale(0.5, 0.5)
					buttonCard.Size = UDim2.fromScale(1, 1)
					buttonCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					buttonCard.BackgroundTransparency = 0.95
					buttonCard.BorderSizePixel = 0
					buttonCard.Parent = button
					local buttonCorner = Instance.new("UICorner")
					buttonCorner.Name = "ButtonCorner"
					buttonCorner.CornerRadius = UDim.new(0, 8)
					buttonCorner.Parent = buttonCard
					local buttonScale = Instance.new("UIScale")
					buttonScale.Name = "ButtonScale"
					buttonScale.Scale = 1
					buttonScale.Parent = buttonCard
					local buttonStroke = ApplyGradientStroke(buttonCard, "ButtonStroke", 0.4, "StrokeGradient")
					local buttonPadding = Instance.new("UIPadding")
					buttonPadding.Name = "ButtonPadding"
					buttonPadding.PaddingLeft = UDim.new(0, 14)
					buttonPadding.PaddingRight = UDim.new(0, 14)
					buttonPadding.Parent = buttonCard
					local buttonTitle = Instance.new("TextLabel")
					buttonTitle.Name = "ButtonTitle"
					buttonTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					buttonTitle.Text = BtnSettings.Name or "Action Button"
					buttonTitle.RichText = true
					buttonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					buttonTitle.TextSize = 13
					buttonTitle.TextTransparency = 0.5
					buttonTitle.TextTruncate = Enum.TextTruncate.AtEnd
					buttonTitle.TextXAlignment = Enum.TextXAlignment.Left
					buttonTitle.TextYAlignment = Enum.TextYAlignment.Center
					buttonTitle.AnchorPoint = Vector2.new(0, 0.5)
					buttonTitle.Position = UDim2.fromScale(0, 0.5)
					buttonTitle.Size = UDim2.new(1, -28, 1, 0)
					buttonTitle.BackgroundTransparency = 1
					buttonTitle.BorderSizePixel = 0
					buttonTitle.Parent = buttonCard
					local buttonIcon = Instance.new("ImageLabel")
					buttonIcon.Name = "ButtonIcon"
					buttonIcon.Image = BtnSettings.Icon or assets.buttonImage
					buttonIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					buttonIcon.ImageTransparency = 0.5
					buttonIcon.AnchorPoint = Vector2.new(1, 0.5)
					buttonIcon.Position = UDim2.fromScale(1, 0.5)
					buttonIcon.Size = UDim2.fromOffset(15, 15)
					buttonIcon.BackgroundTransparency = 1
					buttonIcon.BorderSizePixel = 0
					buttonIcon.Parent = buttonCard
					local buttonInteract = Instance.new("TextButton")
					buttonInteract.Name = "ButtonInteract"
					buttonInteract.Text = ""
					buttonInteract.AutoButtonColor = false
					buttonInteract.BackgroundTransparency = 1
					buttonInteract.BorderSizePixel = 0
					buttonInteract.Size = UDim2.fromScale(1, 1)
					buttonInteract.ZIndex = 2
					buttonInteract.Parent = buttonCard
					local hoverTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					local pressTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local releaseTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
					local isHovered = false
					local isPressed = false
					local function PlayHoverState(hovered)
						local targetTextTrans = hovered and 0.1 or 0.5
						local targetStrokeTrans = hovered and 0.2 or 0.4
						local targetBgTrans = hovered and 0.92 or 0.95
						Tween(buttonTitle, hoverTweenInfo, { TextTransparency = targetTextTrans }):Play()
						Tween(buttonIcon, hoverTweenInfo, { ImageTransparency = targetTextTrans }):Play()
						Tween(buttonStroke, hoverTweenInfo, { Transparency = targetStrokeTrans }):Play()
						Tween(buttonCard, hoverTweenInfo, { BackgroundTransparency = targetBgTrans }):Play()
					end
					local function PlayPressState()
						Tween(buttonScale, pressTweenInfo, { Scale = 0.94 }):Play()
						Tween(buttonTitle, pressTweenInfo, { TextTransparency = 0.05 }):Play()
						Tween(buttonIcon, pressTweenInfo, { ImageTransparency = 0.05 }):Play()
						Tween(buttonStroke, pressTweenInfo, { Transparency = 0.15 }):Play()
					end
					local function PlayReleaseState()
						Tween(buttonScale, releaseTweenInfo, { Scale = 1 }):Play()
						PlayHoverState(isHovered)
					end
					buttonInteract.MouseEnter:Connect(function()
						isHovered = true
						if not isPressed then
							PlayHoverState(true)
						end
					end)
					buttonInteract.MouseLeave:Connect(function()
						isHovered = false
						if isPressed then
							isPressed = false
							Tween(buttonScale, releaseTweenInfo, { Scale = 1 }):Play()
						end
						PlayHoverState(false)
					end)
					buttonInteract.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							isPressed = true
							PlayPressState()
						end
					end)
					buttonInteract.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if isPressed then
								isPressed = false
								PlayReleaseState()
							end
						end
					end)
					buttonInteract.Activated:Connect(function()
						if BtnSettings.Callback then
							task.spawn(BtnSettings.Callback)
						end
					end)
					function ButtonFunctions:UpdateName(Name)
						buttonTitle.Text = Name
					end
					function ButtonFunctions:SetVisibility(State)
						button.Visible = State
					end
					function ButtonFunctions:Fire()
						if BtnSettings.Callback then
							task.spawn(BtnSettings.Callback)
						end
					end
					return ButtonFunctions
				end
				-- ============================================================
				-- 8.2: TOGGLE
				-- ============================================================
				function SectionFunctions:Toggle(TglSettings)
					TglSettings = TglSettings or {}
					local ToggleFunctions = {}
					local toggle = Instance.new("Frame")
					toggle.Name = "Toggle"
					toggle.AutomaticSize = Enum.AutomaticSize.Y
					toggle.BackgroundTransparency = 1
					toggle.BorderSizePixel = 0
					toggle.Size = UDim2.new(1, 0, 0, 38)
					toggle.Parent = sectionContainer
					local toggleName = Instance.new("TextLabel")
					toggleName.Name = "ToggleName"
					toggleName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					toggleName.Text = TglSettings.Name or "Toggle"
					toggleName.RichText = true
					toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
					toggleName.TextSize = 13
					toggleName.TextTransparency = 0.5
					toggleName.TextTruncate = Enum.TextTruncate.AtEnd
					toggleName.TextXAlignment = Enum.TextXAlignment.Left
					toggleName.TextYAlignment = Enum.TextYAlignment.Top
					toggleName.AnchorPoint = Vector2.new(0, 0.5)
					toggleName.AutomaticSize = Enum.AutomaticSize.Y
					toggleName.BackgroundTransparency = 1
					toggleName.BorderSizePixel = 0
					toggleName.Position = UDim2.fromScale(0, 0.5)
					toggleName.Size = UDim2.new(1, -50, 0, 0)
					toggleName.Parent = toggle
					local toggle1 = Instance.new("ImageButton")
					toggle1.Name = "Toggle"
					toggle1.Image = assets.toggleBackground
					toggle1.ImageColor3 = Color3.fromRGB(61, 61, 61)
					toggle1.AutoButtonColor = false
					toggle1.AnchorPoint = Vector2.new(1, 0.5)
					toggle1.BackgroundTransparency = 1
					toggle1.BorderSizePixel = 0
					toggle1.Position = UDim2.fromScale(1, 0.5)
					toggle1.Size = UDim2.fromOffset(41, 21)
					toggle1.Parent = toggle
					local toggleScale = Instance.new("UIScale")
					toggleScale.Name = "ToggleUIScale"
					toggleScale.Scale = 1
					toggleScale.Parent = toggle1
					local toggle1Corner = Instance.new("UICorner")
					toggle1Corner.Name = "Toggle1Corner"
					toggle1Corner.CornerRadius = UDim.new(1, 0)
					toggle1Corner.Parent = toggle1
					local toggleUIStroke, toggleStrokeGradient = ApplyGradientStroke(toggle1, "ToggleUIStroke", 0.4, "ToggleStrokeGradient")
					local toggleUIPadding = Instance.new("UIPadding")
					toggleUIPadding.Name = "ToggleUIPadding"
					toggleUIPadding.PaddingBottom = UDim.new(0, 1)
					toggleUIPadding.PaddingLeft = UDim.new(0, -2)
					toggleUIPadding.PaddingRight = UDim.new(0, 3)
					toggleUIPadding.PaddingTop = UDim.new(0, 1)
					toggleUIPadding.Parent = toggle1
					local togglerHead = Instance.new("ImageLabel")
					togglerHead.Name = "TogglerHead"
					togglerHead.Image = assets.togglerHead
					togglerHead.ImageColor3 = Color3.fromRGB(91, 91, 91)
					togglerHead.AnchorPoint = Vector2.new(1, 0.5)
					togglerHead.BackgroundTransparency = 1
					togglerHead.BorderSizePixel = 0
					togglerHead.Position = UDim2.fromScale(0.5, 0.5)
					togglerHead.Size = UDim2.fromOffset(15, 15)
					togglerHead.ZIndex = 2
					togglerHead.Parent = toggle1
					local TweenSettings = {
						StateInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						HoverInfo = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						PressInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						ReleaseInfo = TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						EnabledColors = {
							Toggle = Color3.fromRGB(87, 86, 86),
							ToggleHover = Color3.fromRGB(100, 100, 100),
							TogglePress = Color3.fromRGB(112, 112, 112),
							ToggleHead = Color3.fromRGB(255, 255, 255)
						},
						DisabledColors = {
							Toggle = Color3.fromRGB(61, 61, 61),
							ToggleHover = Color3.fromRGB(74, 74, 74),
							TogglePress = Color3.fromRGB(84, 84, 84),
							ToggleHead = Color3.fromRGB(91, 91, 91),
							ToggleHeadHover = Color3.fromRGB(130, 130, 130),
							ToggleHeadPress = Color3.fromRGB(160, 160, 160)
						},
						StrokeTransparency = {
							Enabled = 0.15,
							EnabledHover = 0.05,
							Disabled = 0.5,
							DisabledHover = 0.28,
							Pressed = 0.02
						},
						HeadSizes = {
							Default = UDim2.fromOffset(15, 15),
							Hover = UDim2.fromOffset(16, 16),
							Pressed = UDim2.fromOffset(19, 14)
						}
					}
					local togglebool = TglSettings.Default and true or false
					local isHovered = false
					local isPressed = false
					local function UpdateVisuals(animType)
						local mainTweenInfo = TweenSettings.StateInfo
						local scaleTweenInfo = TweenSettings.ReleaseInfo
						if animType == "Press" then
							mainTweenInfo = TweenSettings.PressInfo
							scaleTweenInfo = TweenSettings.PressInfo
						elseif animType == "Hover" then
							mainTweenInfo = TweenSettings.HoverInfo
						end
						local targetBgColor, targetHeadColor, targetHeadPos, targetHeadSize
						local targetStrokeTrans, targetGradientRot, targetTextTrans, targetScale
						if isPressed then
							targetScale = 0.92
							targetHeadSize = TweenSettings.HeadSizes.Pressed
							targetStrokeTrans = TweenSettings.StrokeTransparency.Pressed
						elseif isHovered then
							targetScale = 1.04
							targetHeadSize = TweenSettings.HeadSizes.Hover
							targetStrokeTrans = togglebool and TweenSettings.StrokeTransparency.EnabledHover or TweenSettings.StrokeTransparency.DisabledHover
						else
							targetScale = 1
							targetHeadSize = TweenSettings.HeadSizes.Default
							targetStrokeTrans = togglebool and TweenSettings.StrokeTransparency.Enabled or TweenSettings.StrokeTransparency.Disabled
						end
						if togglebool then
							targetBgColor = isPressed and TweenSettings.EnabledColors.TogglePress
								or (isHovered and TweenSettings.EnabledColors.ToggleHover or TweenSettings.EnabledColors.Toggle)
							targetHeadColor = TweenSettings.EnabledColors.ToggleHead
							targetHeadPos = UDim2.new(1, 0, 0.5, 0)
							targetGradientRot = isHovered and 135 or 45
							targetTextTrans = isHovered and 0.1 or 0.2
						else
							targetBgColor = isPressed and TweenSettings.DisabledColors.TogglePress
								or (isHovered and TweenSettings.DisabledColors.ToggleHover or TweenSettings.DisabledColors.Toggle)
							targetHeadColor = isPressed and TweenSettings.DisabledColors.ToggleHeadPress
								or (isHovered and TweenSettings.DisabledColors.ToggleHeadHover or TweenSettings.DisabledColors.ToggleHead)
							local xOffset = isPressed and 4 or (isHovered and 1 or 0)
							targetHeadPos = UDim2.new(0.5, xOffset, 0.5, 0)
							targetGradientRot = isHovered and 90 or 45
							targetTextTrans = isHovered and 0.3 or 0.5
						end
						Tween(toggle1, mainTweenInfo, { ImageColor3 = targetBgColor }):Play()
						Tween(togglerHead, mainTweenInfo, {
							ImageColor3 = targetHeadColor,
							Position = targetHeadPos,
							Size = targetHeadSize
						}):Play()
						Tween(toggleUIStroke, mainTweenInfo, { Transparency = targetStrokeTrans }):Play()
						Tween(toggleStrokeGradient, mainTweenInfo, { Rotation = targetGradientRot }):Play()
						Tween(toggleName, mainTweenInfo, { TextTransparency = targetTextTrans }):Play()
						Tween(toggleScale, scaleTweenInfo, { Scale = targetScale }):Play()
						ToggleFunctions.State = togglebool
					end
					UpdateVisuals("State")
					local function PerformToggle()
						togglebool = not togglebool
						UpdateVisuals("State")
						if TglSettings.Callback then
							task.spawn(TglSettings.Callback, togglebool)
						end
					end
					toggle.MouseEnter:Connect(function()
						isHovered = true
						UpdateVisuals("Hover")
					end)
					toggle.MouseLeave:Connect(function()
						isHovered = false
						isPressed = false
						UpdateVisuals("Hover")
					end)
					toggle1.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							isPressed = true
							UpdateVisuals("Press")
						end
					end)
					toggle1.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if isPressed then
								isPressed = false
								UpdateVisuals("State")
							end
						end
					end)
					toggle1.MouseButton1Click:Connect(PerformToggle)
					function ToggleFunctions:Toggle()
						PerformToggle()
					end
					function ToggleFunctions:UpdateState(State)
						togglebool = State and true or false
						UpdateVisuals("State")
						if TglSettings.Callback then
							task.spawn(TglSettings.Callback, togglebool)
						end
					end
					function ToggleFunctions:GetState()
						return togglebool
					end
					function ToggleFunctions:UpdateName(Name)
						toggleName.Text = Name
					end
					function ToggleFunctions:SetVisibility(State)
						toggle.Visible = State
					end
					return ToggleFunctions
				end
				-- ============================================================
				-- 8.3: SLIDER
				-- ============================================================
				function SectionFunctions:Slider(SldSettings)
					SldSettings = SldSettings or {}
					local SliderFunctions = {}
					local minVal = SldSettings.Minimum or 0
					local maxVal = SldSettings.Maximum or 100
					local slider = Instance.new("Frame")
					slider.Name = "Slider"
					slider.AutomaticSize = Enum.AutomaticSize.Y
					slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					slider.BackgroundTransparency = 0.985
					slider.BorderSizePixel = 0
					slider.Size = UDim2.new(1, 0, 0, 52)
					slider.Parent = sectionContainer
					local sliderCorner = Instance.new("UICorner")
					sliderCorner.Name = "SliderCorner"
					sliderCorner.CornerRadius = UDim.new(0, 8)
					sliderCorner.Parent = slider
					ApplyGradientStroke(slider, "SliderStroke", 0.35, "SliderStrokeGradient")
					local sliderPadding = Instance.new("UIPadding")
					sliderPadding.Name = "SliderPadding"
					sliderPadding.PaddingBottom = UDim.new(0, 10)
					sliderPadding.PaddingLeft = UDim.new(0, 14)
					sliderPadding.PaddingRight = UDim.new(0, 14)
					sliderPadding.PaddingTop = UDim.new(0, 9)
					sliderPadding.Parent = slider
					local sliderLayout = Instance.new("UIListLayout")
					sliderLayout.Name = "SliderLayout"
					sliderLayout.FillDirection = Enum.FillDirection.Vertical
					sliderLayout.SortOrder = Enum.SortOrder.LayoutOrder
					sliderLayout.Padding = UDim.new(0, 8)
					sliderLayout.Parent = slider
					local sliderTop = Instance.new("Frame")
					sliderTop.Name = "SliderTop"
					sliderTop.BackgroundTransparency = 1
					sliderTop.Size = UDim2.new(1, 0, 0, 18)
					sliderTop.LayoutOrder = 1
					sliderTop.Parent = slider
					local sliderName = Instance.new("TextLabel")
					sliderName.Name = "SliderName"
					sliderName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					sliderName.Text = SldSettings.Name or "Slider"
					sliderName.RichText = true
					sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
					sliderName.TextSize = 13
					sliderName.TextTransparency = 0.4
					sliderName.TextTruncate = Enum.TextTruncate.AtEnd
					sliderName.TextXAlignment = Enum.TextXAlignment.Left
					sliderName.TextYAlignment = Enum.TextYAlignment.Center
					sliderName.BackgroundTransparency = 1
					sliderName.Size = UDim2.new(1, -55, 1, 0)
					sliderName.Parent = sliderTop
					local sliderValue = Instance.new("TextBox")
					sliderValue.Name = "SliderValue"
					sliderValue.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					sliderValue.Text = "0"
					sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
					sliderValue.TextSize = 12
					sliderValue.TextTransparency = 0.25
					sliderValue.TextTruncate = Enum.TextTruncate.AtEnd
					sliderValue.TextXAlignment = Enum.TextXAlignment.Center
					sliderValue.AnchorPoint = Vector2.new(1, 0.5)
					sliderValue.Position = UDim2.new(1, 0, 0.5, 0)
					sliderValue.Size = UDim2.fromOffset(46, 18)
					sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderValue.BackgroundTransparency = 0.95
					sliderValue.BorderSizePixel = 0
					sliderValue.Parent = sliderTop
					local sliderValueCorner = Instance.new("UICorner")
					sliderValueCorner.CornerRadius = UDim.new(0, 4)
					sliderValueCorner.Parent = sliderValue
					local sliderValueStroke = Instance.new("UIStroke")
					sliderValueStroke.Name = "SliderValueStroke"
					sliderValueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					sliderValueStroke.Color = Color3.fromRGB(255, 255, 255)
					sliderValueStroke.Transparency = 0.85
					sliderValueStroke.Parent = sliderValue
					local sliderTrackArea = Instance.new("TextButton")
					sliderTrackArea.Name = "SliderTrackArea"
					sliderTrackArea.Text = ""
					sliderTrackArea.AutoButtonColor = false
					sliderTrackArea.BackgroundTransparency = 1
					sliderTrackArea.BorderSizePixel = 0
					sliderTrackArea.Size = UDim2.new(1, 0, 0, 14)
					sliderTrackArea.LayoutOrder = 2
					sliderTrackArea.Parent = slider
					local sliderBar = Instance.new("Frame")
					sliderBar.Name = "SliderBar"
					sliderBar.AnchorPoint = Vector2.new(0.5, 0.5)
					sliderBar.Position = UDim2.fromScale(0.5, 0.5)
					sliderBar.Size = UDim2.new(1, 0, 0, 4)
					sliderBar.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
					sliderBar.BorderSizePixel = 0
					sliderBar.Parent = sliderTrackArea
					local sliderBarCorner = Instance.new("UICorner")
					sliderBarCorner.CornerRadius = UDim.new(1, 0)
					sliderBarCorner.Parent = sliderBar
					local sliderBarStroke = Instance.new("UIStroke")
					sliderBarStroke.Name = "SliderBarStroke"
					sliderBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					sliderBarStroke.Color = Color3.fromRGB(255, 255, 255)
					sliderBarStroke.Transparency = 0.9
					sliderBarStroke.Parent = sliderBar
					local sliderFill = Instance.new("Frame")
					sliderFill.Name = "SliderFill"
					sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderFill.BackgroundTransparency = 0.1
					sliderFill.BorderSizePixel = 0
					sliderFill.Size = UDim2.new(0, 0, 1, 0)
					sliderFill.Parent = sliderBar
					local sliderFillCorner = Instance.new("UICorner")
					sliderFillCorner.CornerRadius = UDim.new(1, 0)
					sliderFillCorner.Parent = sliderFill
					local sliderHead = Instance.new("Frame")
					sliderHead.Name = "SliderHead"
					sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
					sliderHead.Position = UDim2.new(0, 0, 0.5, 0)
					sliderHead.Size = UDim2.fromOffset(12, 12)
					sliderHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderHead.BorderSizePixel = 0
					sliderHead.Parent = sliderBar
					local sliderHeadCorner = Instance.new("UICorner")
					sliderHeadCorner.CornerRadius = UDim.new(1, 0)
					sliderHeadCorner.Parent = sliderHead
					local sliderHeadStroke = Instance.new("UIStroke")
					sliderHeadStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					sliderHeadStroke.Color = Color3.fromRGB(20, 20, 20)
					sliderHeadStroke.Transparency = 0.5
					sliderHeadStroke.Parent = sliderHead
					local draggingSlider = false
					local finalValue = math.round(SldSettings.Default or minVal)
					local DisplayMethods = {
						Hundredths = function(val) return string.format("%.2f", val) end,
						Tenths = function(val) return string.format("%.1f", val) end,
						Round = function(val) return tostring(math.round(val)) end,
						Degrees = function(val) return tostring(math.round(val)) .. "°" end,
						Percent = function(val)
							local range = maxVal - minVal
							local pct = range > 0 and ((val - minVal) / range * 100) or 0
							return tostring(math.round(pct)) .. "%"
						end,
						Value = function(val) return tostring(math.round(val)) end
					}
					local ValueDisplayMethod = DisplayMethods[SldSettings.DisplayMethod] or DisplayMethods.Value
					local function SetValue(val, ignoreCallback)
						local posXScale = 0
						local range = maxVal - minVal
						if typeof(val) == "Instance" or (typeof(val) == "table" and val.Position) then
							local barWidth = sliderBar.AbsoluteSize.X
							if barWidth > 0 then
								local relativeX = math.clamp(val.Position.X - sliderBar.AbsolutePosition.X, 0, barWidth)
								posXScale = relativeX / barWidth
							end
							local calculated = range > 0 and (minVal + (posXScale * range)) or minVal
							finalValue = math.round(calculated)
							posXScale = range > 0 and math.clamp((finalValue - minVal) / range, 0, 1) or 0
						else
							local num = math.clamp(tonumber(val) or minVal, minVal, maxVal)
							finalValue = math.round(num)
							posXScale = range > 0 and math.clamp((finalValue - minVal) / range, 0, 1) or 0
						end
						sliderFill.Size = UDim2.new(posXScale, 0, 1, 0)
						sliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
						sliderValue.Text = ValueDisplayMethod(finalValue)
						if not ignoreCallback and SldSettings.Callback then
							task.spawn(SldSettings.Callback, finalValue)
						end
						SliderFunctions.Value = finalValue
					end
					SetValue(SldSettings.Default or minVal, true)
					sliderTrackArea.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							draggingSlider = true
							SetValue(input)
						end
					end)
					local sldMoveConn = UserInputService.InputChanged:Connect(function(input)
						if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							SetValue(input)
						end
					end)
					local sldEndConn = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							draggingSlider = false
						end
					end)
					slider.Destroying:Connect(function()
						if sldMoveConn then sldMoveConn:Disconnect() end
						if sldEndConn then sldEndConn:Disconnect() end
					end)
					sliderValue.FocusLost:Connect(function()
						local inputText = sliderValue.Text
						local value, isPercent = inputText:match("^(%-?%d+%.?%d*)(%%?)$")
						if value then
							value = tonumber(value)
							if isPercent == "%" then
								value = minVal + ((value / 100) * (maxVal - minVal))
							end
							SetValue(math.round(value))
						else
							sliderValue.Text = ValueDisplayMethod(finalValue)
						end
					end)
					function SliderFunctions:UpdateName(Name)
						sliderName.Text = Name
					end
					function SliderFunctions:SetVisibility(State)
						slider.Visible = State
					end
					function SliderFunctions:UpdateValue(Value)
						SetValue(Value)
					end
					function SliderFunctions:GetValue()
						return finalValue
					end
					return SliderFunctions
				end
				-- ============================================================
				-- 8.4: INPUT
				-- ============================================================
				function SectionFunctions:Input(InpSettings)
					InpSettings = InpSettings or {}
					local InputFunctions = {}
					local input = Instance.new("Frame")
					input.Name = "Input"
					input.AutomaticSize = Enum.AutomaticSize.Y
					input.BackgroundTransparency = 1
					input.BorderSizePixel = 0
					input.Size = UDim2.new(1, 0, 0, 38)
					input.Parent = sectionContainer
					local inputName = Instance.new("TextLabel")
					inputName.Name = "InputName"
					inputName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					inputName.Text = InpSettings.Name or "Input"
					inputName.RichText = true
					inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputName.TextSize = 13
					inputName.TextTransparency = 0.5
					inputName.TextTruncate = Enum.TextTruncate.AtEnd
					inputName.TextXAlignment = Enum.TextXAlignment.Left
					inputName.TextYAlignment = Enum.TextYAlignment.Top
					inputName.AnchorPoint = Vector2.new(0, 0.5)
					inputName.AutomaticSize = Enum.AutomaticSize.XY
					inputName.BackgroundTransparency = 1
					inputName.BorderSizePixel = 0
					inputName.Position = UDim2.fromScale(0, 0.5)
					inputName.Parent = input
					local inputBox = Instance.new("TextBox")
					inputBox.Name = "InputBox"
					inputBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					inputBox.Text = InpSettings.Default or ""
					inputBox.PlaceholderText = InpSettings.Placeholder or ""
					inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputBox.TextSize = 12
					inputBox.TextTransparency = 0.4
					inputBox.AnchorPoint = Vector2.new(1, 0.5)
					inputBox.AutomaticSize = Enum.AutomaticSize.X
					inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputBox.BackgroundTransparency = 0.95
					inputBox.BorderSizePixel = 0
					inputBox.ClipsDescendants = true
					inputBox.LayoutOrder = 1
					inputBox.Position = UDim2.fromScale(1, 0.5)
					inputBox.Size = UDim2.fromOffset(21, 21)
					inputBox.Parent = input
					local inputBoxUICorner = Instance.new("UICorner")
					inputBoxUICorner.Name = "InputBoxUICorner"
					inputBoxUICorner.CornerRadius = UDim.new(0, 4)
					inputBoxUICorner.Parent = inputBox
					local inputBoxUIStroke = Instance.new("UIStroke")
					inputBoxUIStroke.Name = "InputBoxUIStroke"
					inputBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					inputBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
					inputBoxUIStroke.Transparency = 0.9
					inputBoxUIStroke.Parent = inputBox
					local inputBoxUIPadding = Instance.new("UIPadding")
					inputBoxUIPadding.Name = "InputBoxUIPadding"
					inputBoxUIPadding.PaddingLeft = UDim.new(0, 5)
					inputBoxUIPadding.PaddingRight = UDim.new(0, 5)
					inputBoxUIPadding.Parent = inputBox
					local inputBoxUISizeConstraint = Instance.new("UISizeConstraint")
					inputBoxUISizeConstraint.Name = "InputBoxUISizeConstraint"
					inputBoxUISizeConstraint.Parent = inputBox
					local AcceptedCharacters = CHARACTER_FILTERS[InpSettings.AcceptedCharacters] or CHARACTER_FILTERS.All
					local function CheckInputSize()
						local nameWidth = inputName.AbsoluteSize.X
						local totalWidth = input.AbsoluteSize.X
						local maxWidth = math.max(40, totalWidth - nameWidth - 20)
						inputBoxUISizeConstraint.MaxSize = Vector2.new(maxWidth, 9e9)
					end
					CheckInputSize()
					inputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(CheckInputSize)
					inputBox.FocusLost:Connect(function()
						local filteredText = AcceptedCharacters(inputBox.Text)
						inputBox.Text = filteredText
						if InpSettings.Callback then
							task.spawn(InpSettings.Callback, filteredText)
						end
					end)
					inputBox:GetPropertyChangedSignal("Text"):Connect(function()
						inputBox.Text = AcceptedCharacters(inputBox.Text)
						if InpSettings.onChanged then
							InpSettings.onChanged(inputBox.Text)
						end
						InputFunctions.Text = inputBox.Text
					end)
					function InputFunctions:UpdateName(Name)
						inputName.Text = Name
					end
					function InputFunctions:SetVisibility(State)
						input.Visible = State
					end
					function InputFunctions:GetInput()
						return inputBox.Text
					end
					function InputFunctions:UpdatePlaceholder(Placeholder)
						inputBox.PlaceholderText = Placeholder
					end
					function InputFunctions:UpdateText(Text)
						inputBox.Text = Text
					end
					return InputFunctions
				end
				-- ============================================================
				-- 8.5: KEYBIND
				-- ============================================================
				function SectionFunctions:Keybind(KeySettings)
					KeySettings = KeySettings or {}
					local KeybindFunctions = {}
					local keybind = Instance.new("Frame")
					keybind.Name = "Keybind"
					keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					keybind.BackgroundTransparency = 0.985
					keybind.BorderSizePixel = 0
					keybind.Size = UDim2.new(1, 0, 0, 38)
					keybind.Parent = sectionContainer
					local keybindCorner = Instance.new("UICorner")
					keybindCorner.Name = "KeybindCorner"
					keybindCorner.CornerRadius = UDim.new(0, 8)
					keybindCorner.Parent = keybind
					ApplyGradientStroke(keybind, "KeybindStroke", 0.35, "KeybindStrokeGradient")
					local keybindPadding = Instance.new("UIPadding")
					keybindPadding.PaddingLeft = UDim.new(0, 14)
					keybindPadding.PaddingRight = UDim.new(0, 14)
					keybindPadding.Parent = keybind
					local keybindName = Instance.new("TextLabel")
					keybindName.Name = "KeybindName"
					keybindName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					keybindName.Text = KeySettings.Name or "Keybind"
					keybindName.RichText = true
					keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
					keybindName.TextSize = 13
					keybindName.TextTransparency = 0.4
					keybindName.TextTruncate = Enum.TextTruncate.AtEnd
					keybindName.TextXAlignment = Enum.TextXAlignment.Left
					keybindName.TextYAlignment = Enum.TextYAlignment.Center
					keybindName.AnchorPoint = Vector2.new(0, 0.5)
					keybindName.Position = UDim2.fromScale(0, 0.5)
					keybindName.Size = UDim2.new(1, -75, 1, 0)
					keybindName.BackgroundTransparency = 1
					keybindName.BorderSizePixel = 0
					keybindName.Parent = keybind
					local binderBtn = Instance.new("TextButton")
					binderBtn.Name = "BinderBtn"
					binderBtn.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					binderBtn.Text = "None"
					binderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					binderBtn.TextSize = 12
					binderBtn.TextTransparency = 0.25
					binderBtn.AnchorPoint = Vector2.new(1, 0.5)
					binderBtn.AutomaticSize = Enum.AutomaticSize.X
					binderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					binderBtn.BackgroundTransparency = 0.94
					binderBtn.BorderSizePixel = 0
					binderBtn.Position = UDim2.fromScale(1, 0.5)
					binderBtn.Size = UDim2.fromOffset(40, 22)
					binderBtn.Parent = keybind
					local binderBtnCorner = Instance.new("UICorner")
					binderBtnCorner.CornerRadius = UDim.new(0, 5)
					binderBtnCorner.Parent = binderBtn
					local binderBtnStroke = Instance.new("UIStroke")
					binderBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					binderBtnStroke.Color = Color3.fromRGB(255, 255, 255)
					binderBtnStroke.Transparency = 0.8
					binderBtnStroke.Parent = binderBtn
					local binderBtnPadding = Instance.new("UIPadding")
					binderBtnPadding.PaddingLeft = UDim.new(0, 8)
					binderBtnPadding.PaddingRight = UDim.new(0, 8)
					binderBtnPadding.Parent = binderBtn
					local mobileBox = Instance.new("TextBox")
					mobileBox.Name = "MobileBox"
					mobileBox.Text = ""
					mobileBox.BackgroundTransparency = 1
					mobileBox.Size = UDim2.fromScale(1, 1)
					mobileBox.Visible = false
					mobileBox.Parent = binderBtn
					local binding = false
					local currentBind = nil
					if KeySettings.Default ~= nil then
						currentBind = typeof(KeySettings.Default) == "string" and ParseKey(KeySettings.Default) or KeySettings.Default
					end
					binderBtn.Text = FormatKey(currentBind)
					binderBtn.MouseButton1Click:Connect(function()
						if binding then
							return
						end
						binding = true
						binderBtn.Text = "..."
						Tween(binderBtnStroke, TweenInfo.new(0.2), { Transparency = 0.2 }):Play()
						mobileBox.Visible = true
						mobileBox.Text = ""
						task.defer(function()
							mobileBox:CaptureFocus()
						end)
						local inputConnection = nil
						local textConnection = nil
						local focusLostConnection = nil
						local function FinishBind(chosen)
							if not binding then
								return
							end
							binding = false
							if inputConnection then inputConnection:Disconnect(); inputConnection = nil end
							if textConnection then textConnection:Disconnect(); textConnection = nil end
							if focusLostConnection then focusLostConnection:Disconnect(); focusLostConnection = nil end
							mobileBox.Visible = false
							mobileBox:ReleaseFocus()
							currentBind = chosen
							KeybindFunctions.Bind = currentBind
							binderBtn.Text = FormatKey(currentBind)
							Tween(binderBtnStroke, TweenInfo.new(0.2), { Transparency = 0.8 }):Play()
							if KeySettings.onBinded and currentBind then
								task.spawn(KeySettings.onBinded, currentBind)
							end
						end
						textConnection = mobileBox:GetPropertyChangedSignal("Text"):Connect(function()
							local val = mobileBox.Text
							if val ~= "" and val ~= "..." then
								local key = ParseKey(val)
								if key ~= nil or val:upper() == "NONE" or val:upper() == "ESC" then
									FinishBind(key)
								end
							end
						end)
						focusLostConnection = mobileBox.FocusLost:Connect(function()
							if mobileBox.Text ~= "" then
								FinishBind(ParseKey(mobileBox.Text))
							else
								FinishBind(currentBind)
							end
						end)
						task.defer(function()
							if not binding then
								return
							end
							inputConnection = UserInputService.InputBegan:Connect(function(inp)
								if inp.UserInputType == Enum.UserInputType.MouseMovement then
									return
								end
								if inp.UserInputType == Enum.UserInputType.Keyboard then
									local selected = nil
									if inp.KeyCode ~= Enum.KeyCode.Escape and inp.KeyCode ~= Enum.KeyCode.Backspace and inp.KeyCode ~= Enum.KeyCode.Delete then
										selected = inp.KeyCode
									end
									FinishBind(selected)
								elseif inp.UserInputType == Enum.UserInputType.MouseButton1
									or inp.UserInputType == Enum.UserInputType.MouseButton2
									or inp.UserInputType == Enum.UserInputType.MouseButton3 then
									FinishBind(inp.UserInputType)
								end
							end)
						end)
					end)
					local keyActivation = UserInputService.InputBegan:Connect(function(inp)
						if UserInputService:GetFocusedTextBox() then
							return
						end
						if binding or not currentBind then
							return
						end
						local isTriggered = (inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == currentBind)
							or (inp.UserInputType == currentBind)
						if isTriggered and KeySettings.Callback then
							task.spawn(KeySettings.Callback, currentBind)
						end
					end)
					keybind.Destroying:Connect(function()
						if keyActivation then
							keyActivation:Disconnect()
							keyActivation = nil
						end
					end)
					function KeybindFunctions:SetBind(Key)
						currentBind = typeof(Key) == "string" and ParseKey(Key) or Key
						KeybindFunctions.Bind = currentBind
						binderBtn.Text = FormatKey(currentBind)
					end
					function KeybindFunctions:Unbind()
						currentBind = nil
						KeybindFunctions.Bind = nil
						binderBtn.Text = "None"
					end
					function KeybindFunctions:GetBind()
						return currentBind
					end
					function KeybindFunctions:UpdateName(Name)
						keybindName.Text = Name
					end
					function KeybindFunctions:SetVisibility(State)
						keybind.Visible = State
					end
					return KeybindFunctions
				end
				-- ============================================================
				-- 8.6: DROPDOWN (SINGLE & MULTI + ПОИСК)
				-- ============================================================
				function SectionFunctions:Dropdown(DrpSettings)
					DrpSettings = DrpSettings or {}
					local DropdownFunctions = {}
					local Selected = {}
					local OptionObjs = {}
					local OptionOrder = 0
					local TITLE_HEIGHT = 18
					local TITLE_GAP = 6
					local TOP_OFFSET = TITLE_HEIGHT + TITLE_GAP
					local DD_HEADER_HEIGHT = 38
					local OPTION_HEIGHT = 30
					local SEARCH_HEIGHT = 30
					local LIST_PADDING = 5
					local LIST_TOP_PAD = 6
					local LIST_BOTTOM_PAD = 10
					local dropdownTweenInfo = TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					local optionTweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					local dropdownWrapper = Instance.new("Frame")
					dropdownWrapper.Name = "DropdownWrapper"
					dropdownWrapper.BackgroundTransparency = 1
					dropdownWrapper.BorderSizePixel = 0
					dropdownWrapper.Size = UDim2.new(1, 0, 0, TOP_OFFSET + DD_HEADER_HEIGHT)
					dropdownWrapper.Parent = sectionContainer
					local dropdownTitle = Instance.new("TextLabel")
					dropdownTitle.Name = "DropdownTitle"
					dropdownTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					dropdownTitle.Text = DrpSettings.Name or "Dropdown"
					dropdownTitle.RichText = true
					dropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					dropdownTitle.TextSize = 13
					dropdownTitle.TextTransparency = 0.35
					dropdownTitle.TextTruncate = Enum.TextTruncate.AtEnd
					dropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
					dropdownTitle.TextYAlignment = Enum.TextYAlignment.Center
					dropdownTitle.BackgroundTransparency = 1
					dropdownTitle.BorderSizePixel = 0
					dropdownTitle.Position = UDim2.fromOffset(2, 0)
					dropdownTitle.Size = UDim2.new(1, -4, 0, TITLE_HEIGHT)
					dropdownTitle.Parent = dropdownWrapper
					local dropdown = Instance.new("Frame")
					dropdown.Name = "Dropdown"
					dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					dropdown.BackgroundTransparency = 0.985
					dropdown.BorderSizePixel = 0
					dropdown.Position = UDim2.fromOffset(0, TOP_OFFSET)
					dropdown.Size = UDim2.new(1, 0, 0, DD_HEADER_HEIGHT)
					dropdown.ClipsDescendants = true
					dropdown.Parent = dropdownWrapper
					local dropdownUICorner = Instance.new("UICorner")
					dropdownUICorner.Name = "DropdownUICorner"
					dropdownUICorner.CornerRadius = UDim.new(0, 8)
					dropdownUICorner.Parent = dropdown
					local dropdownUIStroke = ApplyGradientStroke(dropdown, "DropdownUIStroke", 0.35, "DropdownStrokeGradient")
					local dropdownUIPadding = Instance.new("UIPadding")
					dropdownUIPadding.Name = "DropdownUIPadding"
					dropdownUIPadding.PaddingLeft = UDim.new(0, 14)
					dropdownUIPadding.PaddingRight = UDim.new(0, 14)
					dropdownUIPadding.Parent = dropdown
					local ddInteract = Instance.new("TextButton")
					ddInteract.Name = "Interact"
					ddInteract.Text = ""
					ddInteract.AutoButtonColor = false
					ddInteract.BackgroundTransparency = 1
					ddInteract.BorderSizePixel = 0
					ddInteract.Size = UDim2.new(1, 0, 0, DD_HEADER_HEIGHT)
					ddInteract.ZIndex = 2
					ddInteract.Parent = dropdown
					local dropdownValue = Instance.new("TextLabel")
					dropdownValue.Name = "DropdownValue"
					dropdownValue.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					dropdownValue.Text = "..."
					dropdownValue.RichText = true
					dropdownValue.TextColor3 = Color3.fromRGB(255, 255, 255)
					dropdownValue.TextSize = 13
					dropdownValue.TextTransparency = 0.25
					dropdownValue.TextTruncate = Enum.TextTruncate.AtEnd
					dropdownValue.TextXAlignment = Enum.TextXAlignment.Left
					dropdownValue.TextYAlignment = Enum.TextYAlignment.Center
					dropdownValue.BackgroundTransparency = 1
					dropdownValue.BorderSizePixel = 0
					dropdownValue.Size = UDim2.new(1, -26, 0, DD_HEADER_HEIGHT)
					dropdownValue.Parent = dropdown
					local dropdownImage = Instance.new("ImageLabel")
					dropdownImage.Name = "DropdownImage"
					dropdownImage.Image = assets.buttonImage
					dropdownImage.ImageColor3 = Color3.fromRGB(220, 220, 220)
					dropdownImage.ImageTransparency = 0.35
					dropdownImage.AnchorPoint = Vector2.new(1, 0.5)
					dropdownImage.BackgroundTransparency = 1
					dropdownImage.BorderSizePixel = 0
					dropdownImage.Position = UDim2.new(1, 0, 0, DD_HEADER_HEIGHT / 2)
					dropdownImage.Size = UDim2.fromOffset(14, 14)
					dropdownImage.Rotation = 0
					dropdownImage.Parent = dropdown
					local headerDivider = Instance.new("Frame")
					headerDivider.Name = "HeaderDivider"
					headerDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					headerDivider.BackgroundTransparency = 1
					headerDivider.BorderSizePixel = 0
					headerDivider.Position = UDim2.fromOffset(0, DD_HEADER_HEIGHT - 1)
					headerDivider.Size = UDim2.new(1, 0, 0, 1)
					headerDivider.Parent = dropdown
					local dropdownFrame = Instance.new("Frame")
					dropdownFrame.Name = "DropdownFrame"
					dropdownFrame.BackgroundTransparency = 1
					dropdownFrame.BorderSizePixel = 0
					dropdownFrame.Position = UDim2.fromOffset(0, DD_HEADER_HEIGHT)
					dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
					dropdownFrame.Visible = false
					dropdownFrame.Parent = dropdown
					local dropdownFrameUIPadding = Instance.new("UIPadding")
					dropdownFrameUIPadding.Name = "DropdownFrameUIPadding"
					dropdownFrameUIPadding.PaddingTop = UDim.new(0, LIST_TOP_PAD)
					dropdownFrameUIPadding.PaddingBottom = UDim.new(0, LIST_BOTTOM_PAD)
					dropdownFrameUIPadding.Parent = dropdownFrame
					local dropdownFrameUIListLayout = Instance.new("UIListLayout")
					dropdownFrameUIListLayout.Name = "DropdownFrameUIListLayout"
					dropdownFrameUIListLayout.Padding = UDim.new(0, LIST_PADDING)
					dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					dropdownFrameUIListLayout.Parent = dropdownFrame
					local search = Instance.new("Frame")
					search.Name = "Search"
					search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					search.BackgroundTransparency = 0.96
					search.BorderSizePixel = 0
					search.LayoutOrder = -1
					search.Size = UDim2.new(1, 0, 0, SEARCH_HEIGHT)
					search.Visible = DrpSettings.Search == true
					search.Parent = dropdownFrame
					local searchUICorner = Instance.new("UICorner")
					searchUICorner.Name = "SearchUICorner"
					searchUICorner.CornerRadius = UDim.new(0, 6)
					searchUICorner.Parent = search
					local searchUIStroke = Instance.new("UIStroke")
					searchUIStroke.Name = "SearchUIStroke"
					searchUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					searchUIStroke.Color = Color3.fromRGB(255, 255, 255)
					searchUIStroke.Transparency = 0.88
					searchUIStroke.Parent = search
					local searchIcon = Instance.new("ImageLabel")
					searchIcon.Name = "SearchIcon"
					searchIcon.Image = assets.searchIcon
					searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
					searchIcon.AnchorPoint = Vector2.new(0, 0.5)
					searchIcon.BackgroundTransparency = 1
					searchIcon.BorderSizePixel = 0
					searchIcon.Position = UDim2.new(0, 10, 0.5, 0)
					searchIcon.Size = UDim2.fromOffset(12, 12)
					searchIcon.Parent = search
					local searchBox = Instance.new("TextBox")
					searchBox.Name = "SearchBox"
					searchBox.CursorPosition = -1
					searchBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
					searchBox.PlaceholderText = "Search..."
					searchBox.Text = ""
					searchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
					searchBox.TextSize = 13
					searchBox.TextXAlignment = Enum.TextXAlignment.Left
					searchBox.BackgroundTransparency = 1
					searchBox.BorderSizePixel = 0
					searchBox.Position = UDim2.fromOffset(28, 0)
					searchBox.Size = UDim2.new(1, -34, 1, 0)
					searchBox.Parent = search
					local function CalculateListHeight()
						local visibleCount = 0
						local itemsHeight = 0
						if search.Visible then
							visibleCount = visibleCount + 1
							itemsHeight = itemsHeight + SEARCH_HEIGHT
						end
						for _, opt in pairs(OptionObjs) do
							if opt.Button.Visible then
								visibleCount = visibleCount + 1
								itemsHeight = itemsHeight + OPTION_HEIGHT
							end
						end
						if visibleCount == 0 then
							return 0
						end
						local spacing = LIST_PADDING * math.max(0, visibleCount - 1)
						return LIST_TOP_PAD + itemsHeight + spacing + LIST_BOTTOM_PAD
					end
					local dropped = false
					local activeCardTween = nil
					local activeWrapperTween = nil
					local activeArrowTween = nil
					local activeStrokeTween = nil
					local activeDividerTween = nil
					local ddAnimToken = 0
					local function AnimateDropdownHeight(listHeight)
						local cardHeight = DD_HEADER_HEIGHT + listHeight
						local wrapperHeight = TOP_OFFSET + cardHeight
						if listHeight > 0 then
							dropdownFrame.Size = UDim2.new(1, 0, 0, listHeight)
						end
						if activeCardTween then activeCardTween:Cancel() end
						if activeWrapperTween then activeWrapperTween:Cancel() end
						activeCardTween = Tween(dropdown, dropdownTweenInfo, { Size = UDim2.new(1, 0, 0, cardHeight) })
						activeWrapperTween = Tween(dropdownWrapper, dropdownTweenInfo, { Size = UDim2.new(1, 0, 0, wrapperHeight) })
						activeCardTween:Play()
						activeWrapperTween:Play()
						return activeCardTween
					end
					searchBox:GetPropertyChangedSignal("Text"):Connect(function()
						local searchTerm = searchBox.Text:lower()
						for _, v in pairs(OptionObjs) do
							local isVisible = (searchTerm == "") or (string.find(v.LowerName, searchTerm, 1, true) ~= nil)
							if v.Button.Visible ~= isVisible then
								v.Button.Visible = isVisible
							end
						end
						if dropped then
							AnimateDropdownHeight(CalculateListHeight())
						end
					end)
					local function UpdateValueText()
						if #Selected > 0 then
							dropdownValue.Text = table.concat(Selected, ", ")
							dropdownValue.TextTransparency = 0.15
						else
							dropdownValue.Text = "Не выбрано"
							dropdownValue.TextTransparency = 0.5
						end
					end
					local function SetOptionVisual(opt, isSelected, instant)
						if instant then
							opt.Checkmark.Size = UDim2.fromOffset(isSelected and 14 or 0, 14)
							opt.Checkmark.ImageTransparency = isSelected and 0.1 or 1
							opt.NameLabel.TextTransparency = isSelected and 0.15 or 0.5
							opt.Button.BackgroundTransparency = isSelected and 0.955 or 1
							opt.Stroke.Transparency = isSelected and 0.72 or 1
						else
							if isSelected then
								opt.Tweens.CheckIn:Play()
								opt.Tweens.NameIn:Play()
								opt.Tweens.BgIn:Play()
								opt.Tweens.StrokeIn:Play()
							else
								opt.Tweens.CheckOut:Play()
								opt.Tweens.NameOut:Play()
								opt.Tweens.BgOut:Play()
								opt.Tweens.StrokeOut:Play()
							end
						end
					end
					local function ToggleOption(optionName, State, instant)
						local option = OptionObjs[optionName]
						if not option then
							return
						end
						if State then
							if DrpSettings.Multi then
								if not table.find(Selected, optionName) then
									table.insert(Selected, optionName)
								end
								DropdownFunctions.Value = Selected
							else
								for name, opt in pairs(OptionObjs) do
									if name ~= optionName and opt.Selected then
										opt.Selected = false
										SetOptionVisual(opt, false, instant)
									end
								end
								Selected = { optionName }
								DropdownFunctions.Value = optionName
							end
							option.Selected = true
							SetOptionVisual(option, true, instant)
						else
							if DrpSettings.Required and #Selected <= 1 and table.find(Selected, optionName) then
								return
							end
							if DrpSettings.Multi then
								local idx = table.find(Selected, optionName)
								if idx then
									table.remove(Selected, idx)
								end
								DropdownFunctions.Value = Selected
							else
								Selected = {}
								DropdownFunctions.Value = nil
							end
							option.Selected = false
							SetOptionVisual(option, false, instant)
						end
						UpdateValueText()
					end
					local function ToggleDropdown()
						dropped = not dropped
						ddAnimToken = ddAnimToken + 1
						local currentToken = ddAnimToken
						if activeArrowTween then activeArrowTween:Cancel() end
						if activeStrokeTween then activeStrokeTween:Cancel() end
						if activeDividerTween then activeDividerTween:Cancel() end
						local listHeight = dropped and CalculateListHeight() or 0
						if dropped then
							dropdownFrame.Visible = true
						end
						activeArrowTween = Tween(dropdownImage, dropdownTweenInfo, {
							Rotation = dropped and 90 or 0,
							ImageTransparency = dropped and 0.1 or 0.35
						})
						activeStrokeTween = Tween(dropdownUIStroke, dropdownTweenInfo, {
							Transparency = dropped and 0.15 or 0.35
						})
						activeDividerTween = Tween(headerDivider, dropdownTweenInfo, {
							BackgroundTransparency = dropped and 0.9 or 1
						})
						activeArrowTween:Play()
						activeStrokeTween:Play()
						activeDividerTween:Play()
						local cardTween = AnimateDropdownHeight(listHeight)
						if not dropped then
							cardTween.Completed:Connect(function(playbackState)
								if playbackState == Enum.PlaybackState.Completed and ddAnimToken == currentToken and not dropped then
									dropdownFrame.Visible = false
								end
							end)
						end
					end
					ddInteract.MouseButton1Click:Connect(ToggleDropdown)
					local function AddOption(i, v)
						OptionOrder = OptionOrder + 1
						local option = Instance.new("TextButton")
						option.Name = "Option"
						option.Text = ""
						option.AutoButtonColor = false
						option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						option.BackgroundTransparency = 1
						option.BorderSizePixel = 0
						option.LayoutOrder = OptionOrder
						option.Size = UDim2.new(1, 0, 0, OPTION_HEIGHT)
						option.Parent = dropdownFrame
						local optionCorner = Instance.new("UICorner")
						optionCorner.CornerRadius = UDim.new(0, 6)
						optionCorner.Parent = option
						local optionStroke = Instance.new("UIStroke")
						optionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						optionStroke.Color = Color3.fromRGB(255, 255, 255)
						optionStroke.Transparency = 1
						optionStroke.Parent = option
						local optionUIPadding = Instance.new("UIPadding")
						optionUIPadding.Name = "OptionUIPadding"
						optionUIPadding.PaddingLeft = UDim.new(0, 10)
						optionUIPadding.PaddingRight = UDim.new(0, 10)
						optionUIPadding.Parent = option
						local optionUIListLayout = Instance.new("UIListLayout")
						optionUIListLayout.Name = "OptionUIListLayout"
						optionUIListLayout.Padding = UDim.new(0, 8)
						optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
						optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
						optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
						optionUIListLayout.Parent = option
						local checkmark = Instance.new("ImageLabel")
						checkmark.Name = "Checkmark"
						checkmark.Image = assets.buttonImage
						checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
						checkmark.ImageTransparency = 1
						checkmark.BackgroundTransparency = 1
						checkmark.BorderSizePixel = 0
						checkmark.LayoutOrder = -1
						checkmark.Size = UDim2.fromOffset(0, 14)
						checkmark.Parent = option
						local optionName = Instance.new("TextLabel")
						optionName.Name = "OptionName"
						optionName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
						optionName.Text = v
						optionName.RichText = true
						optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
						optionName.TextSize = 13
						optionName.TextTransparency = 0.5
						optionName.TextTruncate = Enum.TextTruncate.AtEnd
						optionName.TextXAlignment = Enum.TextXAlignment.Left
						optionName.TextYAlignment = Enum.TextYAlignment.Center
						optionName.BackgroundTransparency = 1
						optionName.BorderSizePixel = 0
						optionName.Size = UDim2.new(1, -22, 1, 0)
						optionName.Parent = option
						local cachedTweens = {
							CheckIn = Tween(checkmark, optionTweenInfo, { Size = UDim2.fromOffset(14, 14), ImageTransparency = 0.1 }),
							CheckOut = Tween(checkmark, optionTweenInfo, { Size = UDim2.fromOffset(0, 14), ImageTransparency = 1 }),
							NameIn = Tween(optionName, optionTweenInfo, { TextTransparency = 0.15 }),
							NameOut = Tween(optionName, optionTweenInfo, { TextTransparency = 0.5 }),
							BgIn = Tween(option, optionTweenInfo, { BackgroundTransparency = 0.955 }),
							BgOut = Tween(option, optionTweenInfo, { BackgroundTransparency = 1 }),
							StrokeIn = Tween(optionStroke, optionTweenInfo, { Transparency = 0.72 }),
							StrokeOut = Tween(optionStroke, optionTweenInfo, { Transparency = 1 })
						}
						OptionObjs[v] = {
							Index = i,
							Button = option,
							NameLabel = optionName,
							Checkmark = checkmark,
							Stroke = optionStroke,
							LowerName = tostring(v):lower(),
							Selected = false,
							Tweens = cachedTweens
						}
						local isSelected = false
						if DrpSettings.Default then
							if DrpSettings.Multi and type(DrpSettings.Default) == "table" then
								isSelected = table.find(DrpSettings.Default, v) ~= nil
							else
								isSelected = (DrpSettings.Default == i or DrpSettings.Default == v)
							end
						end
						if isSelected then
							ToggleOption(v, true, true)
						else
							SetOptionVisual(OptionObjs[v], false, true)
						end
						option.MouseButton1Click:Connect(function()
							local currentlySelected = OptionObjs[v] and OptionObjs[v].Selected or false
							local newSelected = not currentlySelected
							if DrpSettings.Required and not newSelected and #Selected <= 1 then
								return
							end
							ToggleOption(v, newSelected, false)
							task.spawn(function()
								if DrpSettings.Multi then
									local Return = {}
									for _, opt in ipairs(Selected) do
										Return[opt] = true
									end
									if DrpSettings.Callback then
										DrpSettings.Callback(Return)
									end
								else
									if newSelected and DrpSettings.Callback then
										DrpSettings.Callback(Selected[1] or nil)
									end
								end
							end)
						end)
					end
					if DrpSettings.Options then
						for i, v in pairs(DrpSettings.Options) do
							AddOption(i, v)
						end
					end
					UpdateValueText()
					function DropdownFunctions:UpdateName(New)
						DrpSettings.Name = New
						dropdownTitle.Text = New
					end
					function DropdownFunctions:SetVisibility(State)
						dropdownWrapper.Visible = State
					end
					function DropdownFunctions:UpdateSelection(newSelection)
						if type(newSelection) == "number" then
							for option, data in pairs(OptionObjs) do
								ToggleOption(option, data.Index == newSelection, false)
							end
						elseif type(newSelection) == "string" then
							for option in pairs(OptionObjs) do
								ToggleOption(option, option == newSelection, false)
							end
						elseif type(newSelection) == "table" then
							for option in pairs(OptionObjs) do
								ToggleOption(option, table.find(newSelection, option) ~= nil, false)
							end
						end
					end
					function DropdownFunctions:InsertOptions(newOptions)
						for i, v in pairs(newOptions) do
							if not OptionObjs[v] then
								AddOption(i, v)
							end
						end
						if dropped then
							AnimateDropdownHeight(CalculateListHeight())
						end
					end
					function DropdownFunctions:ClearOptions()
						for _, optionData in pairs(OptionObjs) do
							optionData.Button:Destroy()
						end
						OptionObjs = {}
						Selected = {}
						OptionOrder = 0
						UpdateValueText()
						if dropped then
							AnimateDropdownHeight(CalculateListHeight())
						end
					end
					function DropdownFunctions:GetOptions()
						local optionsStatus = {}
						for option, data in pairs(OptionObjs) do
							optionsStatus[option] = data.Selected == true
						end
						return optionsStatus
					end
					function DropdownFunctions:RemoveOptions(remove)
						for _, optionName in ipairs(remove) do
							local optionData = OptionObjs[optionName]
							if optionData then
								local idx = table.find(Selected, optionName)
								if idx then
									table.remove(Selected, idx)
								end
								optionData.Button:Destroy()
								OptionObjs[optionName] = nil
							end
						end
						UpdateValueText()
						if dropped then
							AnimateDropdownHeight(CalculateListHeight())
						end
					end
					function DropdownFunctions:IsOption(optionName)
						return OptionObjs[optionName] ~= nil
					end
					return DropdownFunctions
				end
				-- ============================================================
				-- 8.7: ИСПРАВЛЕННЫЙ COLORPICKER / COLOR (ПАЛИТРА ЦВЕТОВ)
				-- ============================================================
				function SectionFunctions:Colorpicker(ClrSettings)
					ClrSettings = ClrSettings or {}
					local ColorpickerFunctions = {}
					local isAlpha = ClrSettings.Alpha ~= nil
					local savedColor = ClrSettings.Default or Color3.fromRGB(255, 255, 255)
					local savedAlpha = isAlpha and math.clamp(tonumber(ClrSettings.Alpha) or 0, 0, 1) or 0
					ColorpickerFunctions.Color = savedColor
					ColorpickerFunctions.Alpha = isAlpha and savedAlpha or nil
					-- 1. Карточка Colorpicker внутри секции
					local colorpicker = Instance.new("Frame")
					colorpicker.Name = "Colorpicker"
					colorpicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					colorpicker.BackgroundTransparency = 0.985
					colorpicker.BorderSizePixel = 0
					colorpicker.Size = UDim2.new(1, 0, 0, 38)
					colorpicker.Parent = sectionContainer
					local pickerCardCorner = Instance.new("UICorner")
					pickerCardCorner.Name = "PickerCardCorner"
					pickerCardCorner.CornerRadius = UDim.new(0, 8)
					pickerCardCorner.Parent = colorpicker
					local pickerCardStroke = ApplyGradientStroke(colorpicker, "PickerCardStroke", 0.35, "PickerCardStrokeGradient")
					local pickerCardPadding = Instance.new("UIPadding")
					pickerCardPadding.Name = "PickerCardPadding"
					pickerCardPadding.PaddingLeft = UDim.new(0, 14)
					pickerCardPadding.PaddingRight = UDim.new(0, 14)
					pickerCardPadding.Parent = colorpicker
					local colorpickerName = Instance.new("TextLabel")
					colorpickerName.Name = "ColorpickerName"
					colorpickerName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					colorpickerName.Text = ClrSettings.Name or "Colorpicker"
					colorpickerName.RichText = true
					colorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
					colorpickerName.TextSize = 13
					colorpickerName.TextTransparency = 0.4
					colorpickerName.TextTruncate = Enum.TextTruncate.AtEnd
					colorpickerName.TextXAlignment = Enum.TextXAlignment.Left
					colorpickerName.TextYAlignment = Enum.TextYAlignment.Center
					colorpickerName.AnchorPoint = Vector2.new(0, 0.5)
					colorpickerName.Position = UDim2.fromScale(0, 0.5)
					colorpickerName.Size = UDim2.new(1, -46, 1, 0)
					colorpickerName.BackgroundTransparency = 1
					colorpickerName.BorderSizePixel = 0
					colorpickerName.Parent = colorpicker
					local colorCbg = Instance.new("ImageLabel")
					colorCbg.Name = "ColorPreviewBg"
					colorCbg.Image = assets.gridose
					colorCbg.ScaleType = Enum.ScaleType.Tile
					colorCbg.TileSize = UDim2.fromOffset(8, 8)
					colorCbg.AnchorPoint = Vector2.new(1, 0.5)
					colorCbg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					colorCbg.BackgroundTransparency = 0
					colorCbg.BorderSizePixel = 0
					colorCbg.Position = UDim2.fromScale(1, 0.5)
					colorCbg.Size = UDim2.fromOffset(22, 22)
					colorCbg.Parent = colorpicker
					local previewBgCorner = Instance.new("UICorner")
					previewBgCorner.CornerRadius = UDim.new(0, 6)
					previewBgCorner.Parent = colorCbg
					local previewBgStroke = Instance.new("UIStroke")
					previewBgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					previewBgStroke.Color = Color3.fromRGB(255, 255, 255)
					previewBgStroke.Transparency = 0.55
					previewBgStroke.Parent = colorCbg
					local previewScale = Instance.new("UIScale")
					previewScale.Scale = 1
					previewScale.Parent = colorCbg
					local colorC = Instance.new("Frame")
					colorC.Name = "Color"
					colorC.AnchorPoint = Vector2.new(0.5, 0.5)
					colorC.BackgroundColor3 = savedColor
					colorC.BackgroundTransparency = isAlpha and savedAlpha or 0
					colorC.BorderSizePixel = 0
					colorC.Position = UDim2.fromScale(0.5, 0.5)
					colorC.Size = UDim2.fromScale(1, 1)
					colorC.Parent = colorCbg
					local previewInnerCorner = Instance.new("UICorner")
					previewInnerCorner.CornerRadius = UDim.new(0, 6)
					previewInnerCorner.Parent = colorC
					local cpInteract = Instance.new("TextButton")
					cpInteract.Name = "Interact"
					cpInteract.Text = ""
					cpInteract.AutoButtonColor = false
					cpInteract.BackgroundTransparency = 1
					cpInteract.BorderSizePixel = 0
					cpInteract.Size = UDim2.fromScale(1, 1)
					cpInteract.ZIndex = 2
					cpInteract.Parent = colorpicker
					-- 2. Модальное окно палитры (Frame вместо багованного CanvasGroup, фиксированные высоты)
					local colorPickerModal = Instance.new("Frame")
					colorPickerModal.Name = "ColorPickerCanvas"
					colorPickerModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					colorPickerModal.BackgroundTransparency = 1
					colorPickerModal.BorderSizePixel = 0
					colorPickerModal.Size = UDim2.fromScale(1, 1)
					colorPickerModal.ZIndex = 30
					colorPickerModal.Visible = false
					colorPickerModal.Active = true
					colorPickerModal.ClipsDescendants = true
					colorPickerModal.Parent = base
					local canvasUICorner = Instance.new("UICorner")
					canvasUICorner.Name = "BaseUICorner"
					canvasUICorner.CornerRadius = UDim.new(0, 10)
					canvasUICorner.Parent = colorPickerModal
					local backdropBlocker = Instance.new("TextButton")
					backdropBlocker.Name = "BackdropBlocker"
					backdropBlocker.Text = ""
					backdropBlocker.AutoButtonColor = false
					backdropBlocker.BackgroundTransparency = 1
					backdropBlocker.BorderSizePixel = 0
					backdropBlocker.Size = UDim2.fromScale(1, 1)
					backdropBlocker.Active = true
					backdropBlocker.ZIndex = 30
					backdropBlocker.Parent = colorPickerModal
					local prompt = Instance.new("Frame")
					prompt.Name = "Prompt"
					prompt.AnchorPoint = Vector2.new(0.5, 0.5)
					prompt.AutomaticSize = Enum.AutomaticSize.None
					prompt.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
					prompt.BorderSizePixel = 0
					prompt.Position = UDim2.fromScale(0.5, 0.5)
					prompt.Size = UDim2.fromOffset(424, 412)
					prompt.Active = true
					prompt.ZIndex = 31
					prompt.Parent = colorPickerModal
					local promptScale = Instance.new("UIScale")
					promptScale.Name = "PromptUIScale"
					promptScale.Scale = 0.94
					promptScale.Parent = prompt
					local promptUICorner = Instance.new("UICorner")
					promptUICorner.Name = "PromptUICorner"
					promptUICorner.CornerRadius = UDim.new(0, 12)
					promptUICorner.Parent = prompt
					ApplyGradientStroke(prompt, "PromptUIStroke", 0.32, "PromptStrokeGradient")
					local promptUIPadding = Instance.new("UIPadding")
					promptUIPadding.Name = "PromptUIPadding"
					promptUIPadding.PaddingTop = UDim.new(0, 16)
					promptUIPadding.PaddingBottom = UDim.new(0, 16)
					promptUIPadding.PaddingLeft = UDim.new(0, 20)
					promptUIPadding.PaddingRight = UDim.new(0, 20)
					promptUIPadding.Parent = prompt
					local promptUIListLayout = Instance.new("UIListLayout")
					promptUIListLayout.Name = "PromptUIListLayout"
					promptUIListLayout.Padding = UDim.new(0, 12)
					promptUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					promptUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					promptUIListLayout.Parent = prompt
					-- Шапка модального окна (фиксированная высота 32px)
					local headerFrame = Instance.new("Frame")
					headerFrame.Name = "HeaderFrame"
					headerFrame.BackgroundTransparency = 1
					headerFrame.BorderSizePixel = 0
					headerFrame.LayoutOrder = 0
					headerFrame.Size = UDim2.new(1, 0, 0, 32)
					headerFrame.ZIndex = 32
					headerFrame.Parent = prompt
					local headerTopRow = Instance.new("Frame")
					headerTopRow.Name = "HeaderTopRow"
					headerTopRow.BackgroundTransparency = 1
					headerTopRow.Size = UDim2.new(1, 0, 0, 20)
					headerTopRow.ZIndex = 32
					headerTopRow.Parent = headerFrame
					local headerTopRowLayout = Instance.new("UIListLayout")
					headerTopRowLayout.FillDirection = Enum.FillDirection.Horizontal
					headerTopRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					headerTopRowLayout.Padding = UDim.new(0, 8)
					headerTopRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
					headerTopRowLayout.Parent = headerTopRow
					local headerIcon = Instance.new("ImageLabel")
					headerIcon.Name = "HeaderIcon"
					headerIcon.Image = assets.paletteIcon
					headerIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					headerIcon.ImageTransparency = 0.25
					headerIcon.BackgroundTransparency = 1
					headerIcon.Size = UDim2.fromOffset(16, 16)
					headerIcon.LayoutOrder = 1
					headerIcon.ZIndex = 32
					headerIcon.Parent = headerTopRow
					local paragraphHeader = Instance.new("TextLabel")
					paragraphHeader.Name = "ParagraphHeader"
					paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					paragraphHeader.RichText = true
					paragraphHeader.Text = ClrSettings.Name or "Colorpicker"
					paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
					paragraphHeader.TextSize = 15
					paragraphHeader.TextTransparency = 0.15
					paragraphHeader.TextTruncate = Enum.TextTruncate.AtEnd
					paragraphHeader.TextXAlignment = Enum.TextXAlignment.Left
					paragraphHeader.BackgroundTransparency = 1
					paragraphHeader.BorderSizePixel = 0
					paragraphHeader.Size = UDim2.new(1, -28, 1, 0)
					paragraphHeader.LayoutOrder = 2
					paragraphHeader.ZIndex = 32
					paragraphHeader.Parent = headerTopRow
					local headerLine = Instance.new("Frame")
					headerLine.Name = "Line"
					headerLine.AnchorPoint = Vector2.new(0, 1)
					headerLine.Position = UDim2.fromScale(0, 1)
					headerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					headerLine.BackgroundTransparency = 0.88
					headerLine.BorderSizePixel = 0
					headerLine.Size = UDim2.new(1, 0, 0, 1)
					headerLine.ZIndex = 32
					headerLine.Parent = headerFrame
					-- 3. Блок настроек палитры (фиксированная высота 292px)
					local colorOptions = Instance.new("Frame")
					colorOptions.Name = "ColorOptions"
					colorOptions.BackgroundTransparency = 1
					colorOptions.BorderSizePixel = 0
					colorOptions.LayoutOrder = 1
					colorOptions.Size = UDim2.new(1, 0, 0, 292)
					colorOptions.ZIndex = 32
					colorOptions.Parent = prompt
					local colorOptionsLayout = Instance.new("UIListLayout")
					colorOptionsLayout.Name = "ColorOptionsLayout"
					colorOptionsLayout.Padding = UDim.new(0, 10)
					colorOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
					colorOptionsLayout.Parent = colorOptions
					-- 3.1: Цветовой круг + Поля ввода (180px)
					local wheelAndInputs = Instance.new("Frame")
					wheelAndInputs.Name = "Wheel"
					wheelAndInputs.BackgroundTransparency = 1
					wheelAndInputs.BorderSizePixel = 0
					wheelAndInputs.LayoutOrder = 1
					wheelAndInputs.Size = UDim2.new(1, 0, 0, 180)
					wheelAndInputs.ZIndex = 32
					wheelAndInputs.Parent = colorOptions
					local wheelFrame = Instance.new("Frame")
					wheelFrame.Name = "WheelFrame"
					wheelFrame.AnchorPoint = Vector2.new(0, 0.5)
					wheelFrame.Position = UDim2.fromScale(0, 0.5)
					wheelFrame.Size = UDim2.fromOffset(180, 180)
					wheelFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
					wheelFrame.BackgroundTransparency = 0.2
					wheelFrame.BorderSizePixel = 0
					wheelFrame.ZIndex = 32
					wheelFrame.Parent = wheelAndInputs
					local wheelFrameCorner = Instance.new("UICorner")
					wheelFrameCorner.CornerRadius = UDim.new(1, 0)
					wheelFrameCorner.Parent = wheelFrame
					local wheelFrameStroke = Instance.new("UIStroke")
					wheelFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					wheelFrameStroke.Color = Color3.fromRGB(255, 255, 255)
					wheelFrameStroke.Transparency = 0.72
					wheelFrameStroke.Thickness = 1.2
					wheelFrameStroke.Parent = wheelFrame
					local wheelBtn = Instance.new("ImageButton")
					wheelBtn.Name = "Wheel"
					wheelBtn.Image = assets.colorWheel
					wheelBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
					wheelBtn.AutoButtonColor = false
					wheelBtn.AnchorPoint = Vector2.new(0.5, 0.5)
					wheelBtn.Position = UDim2.fromScale(0.5, 0.5)
					wheelBtn.BackgroundTransparency = 1
					wheelBtn.BorderSizePixel = 0
					wheelBtn.Size = UDim2.new(1, -6, 1, -6)
					wheelBtn.ZIndex = 33
					wheelBtn.Parent = wheelFrame
					-- Контрастный двухконтурный прицел (Target)
					local target = Instance.new("Frame")
					target.Name = "Target"
					target.AnchorPoint = Vector2.new(0.5, 0.5)
					target.Position = UDim2.fromScale(0.5, 0.5)
					target.Size = UDim2.fromOffset(18, 18)
					target.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					target.BorderSizePixel = 0
					target.ZIndex = 35
					target.Parent = wheelBtn
					local targetScale = Instance.new("UIScale")
					targetScale.Scale = 1
					targetScale.Parent = target
					local targetCorner = Instance.new("UICorner")
					targetCorner.CornerRadius = UDim.new(1, 0)
					targetCorner.Parent = target
					local targetOuterStroke = Instance.new("UIStroke")
					targetOuterStroke.Name = "TargetOuterStroke"
					targetOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					targetOuterStroke.Color = Color3.fromRGB(10, 10, 12)
					targetOuterStroke.Thickness = 2
					targetOuterStroke.Transparency = 0.1
					targetOuterStroke.Parent = target
					local targetInnerRing = Instance.new("Frame")
					targetInnerRing.Name = "TargetInnerRing"
					targetInnerRing.AnchorPoint = Vector2.new(0.5, 0.5)
					targetInnerRing.Position = UDim2.fromScale(0.5, 0.5)
					targetInnerRing.Size = UDim2.new(1, -4, 1, -4)
					targetInnerRing.BackgroundColor3 = savedColor
					targetInnerRing.BorderSizePixel = 0
					targetInnerRing.ZIndex = 36
					targetInnerRing.Parent = target
					local targetInnerCorner = Instance.new("UICorner")
					targetInnerCorner.CornerRadius = UDim.new(1, 0)
					targetInnerCorner.Parent = targetInnerRing
					local targetInnerStroke = Instance.new("UIStroke")
					targetInnerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					targetInnerStroke.Color = Color3.fromRGB(255, 255, 255)
					targetInnerStroke.Thickness = 1.5
					targetInnerStroke.Transparency = 0
					targetInnerStroke.Parent = targetInnerRing
					-- Правая колонка полей ввода (Hex, Red, Green, Blue, Alpha)
					local inputs = Instance.new("Frame")
					inputs.Name = "Inputs"
					inputs.AnchorPoint = Vector2.new(1, 0.5)
					inputs.BackgroundTransparency = 1
					inputs.BorderSizePixel = 0
					inputs.Position = UDim2.fromScale(1, 0.5)
					inputs.Size = UDim2.fromOffset(188, 172)
					inputs.ZIndex = 32
					inputs.Parent = wheelAndInputs
					local inputsLayout = Instance.new("UIListLayout")
					inputsLayout.Name = "InputsLayout"
					inputsLayout.Padding = UDim.new(0, 6)
					inputsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					inputsLayout.SortOrder = Enum.SortOrder.LayoutOrder
					inputsLayout.Parent = inputs
					local modifierInputs = {}
					local function CreateColorInputRow(fieldName, labelText, iconId, accentColor, defaultText, order, visible)
						local row = Instance.new("Frame")
						row.Name = fieldName
						row.BackgroundTransparency = 1
						row.BorderSizePixel = 0
						row.LayoutOrder = order
						row.Size = UDim2.new(1, 0, 0, 28)
						row.Visible = visible
						row.ZIndex = 32
						row.Parent = inputs
						local leftGroup = Instance.new("Frame")
						leftGroup.Name = "LeftGroup"
						leftGroup.AnchorPoint = Vector2.new(0, 0.5)
						leftGroup.Position = UDim2.fromScale(0, 0.5)
						leftGroup.Size = UDim2.new(1, -90, 1, 0)
						leftGroup.BackgroundTransparency = 1
						leftGroup.ZIndex = 32
						leftGroup.Parent = row
						local leftLayout = Instance.new("UIListLayout")
						leftLayout.FillDirection = Enum.FillDirection.Horizontal
						leftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
						leftLayout.Padding = UDim.new(0, 6)
						leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
						leftLayout.Parent = leftGroup
						local fieldIcon = Instance.new("ImageLabel")
						fieldIcon.Name = "FieldIcon"
						fieldIcon.Image = iconId
						fieldIcon.ImageColor3 = accentColor
						fieldIcon.ImageTransparency = 0.25
						fieldIcon.BackgroundTransparency = 1
						fieldIcon.Size = UDim2.fromOffset(13, 13)
						fieldIcon.LayoutOrder = 1
						fieldIcon.ZIndex = 32
						fieldIcon.Parent = leftGroup
						local label = Instance.new("TextLabel")
						label.Name = "InputName"
						label.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
						label.Text = labelText
						label.TextColor3 = Color3.fromRGB(255, 255, 255)
						label.TextSize = 12
						label.TextTransparency = 0.4
						label.TextXAlignment = Enum.TextXAlignment.Left
						label.AutomaticSize = Enum.AutomaticSize.XY
						label.BackgroundTransparency = 1
						label.BorderSizePixel = 0
						label.LayoutOrder = 2
						label.ZIndex = 32
						label.Parent = leftGroup
						local box = Instance.new("TextBox")
						box.Name = "InputBox"
						box.ClearTextOnFocus = false
						box.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
						box.Text = defaultText
						box.TextColor3 = Color3.fromRGB(255, 255, 255)
						box.TextSize = 12
						box.TextTransparency = 0.2
						box.TextXAlignment = Enum.TextXAlignment.Center
						box.AnchorPoint = Vector2.new(1, 0.5)
						box.Position = UDim2.fromScale(1, 0.5)
						box.Size = UDim2.fromOffset(86, 25)
						box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						box.BackgroundTransparency = 0.95
						box.BorderSizePixel = 0
						box.ClipsDescendants = true
						box.ZIndex = 33
						box.Parent = row
						local boxCorner = Instance.new("UICorner")
						boxCorner.CornerRadius = UDim.new(0, 6)
						boxCorner.Parent = box
						local boxStroke = Instance.new("UIStroke")
						boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						boxStroke.Color = Color3.fromRGB(255, 255, 255)
						boxStroke.Transparency = 0.82
						boxStroke.Parent = box
						local boxPadding = Instance.new("UIPadding")
						boxPadding.PaddingLeft = UDim.new(0, 6)
						boxPadding.PaddingRight = UDim.new(0, 6)
						boxPadding.Parent = box
						modifierInputs[fieldName] = box
						return row, box, boxStroke
					end
					CreateColorInputRow("Hex", "Hex", assets.hexIcon, Color3.fromRGB(210, 210, 210), "#FFFFFF", 0, true)
					CreateColorInputRow("Red", "Red", assets.channelIcon, Color3.fromRGB(255, 110, 110), "255", 1, true)
					CreateColorInputRow("Green", "Green", assets.channelIcon, Color3.fromRGB(110, 240, 140), "255", 2, true)
					CreateColorInputRow("Blue", "Blue", assets.channelIcon, Color3.fromRGB(110, 175, 255), "255", 3, true)
					CreateColorInputRow("Alpha", "Alpha", assets.alphaIcon, Color3.fromRGB(200, 200, 200), "0", 4, isAlpha)
					-- 3.2: Слайдер яркости (Value) с изолированным градиентом (не чернит бегунок!)
					local valueContainer = Instance.new("Frame")
					valueContainer.Name = "ValueContainer"
					valueContainer.BackgroundTransparency = 1
					valueContainer.Size = UDim2.new(1, 0, 0, 22)
					valueContainer.LayoutOrder = 2
					valueContainer.ZIndex = 32
					valueContainer.Parent = colorOptions
					local brightnessIcon = Instance.new("ImageLabel")
					brightnessIcon.Name = "BrightnessIcon"
					brightnessIcon.Image = assets.brightnessIcon
					brightnessIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					brightnessIcon.ImageTransparency = 0.4
					brightnessIcon.AnchorPoint = Vector2.new(0, 0.5)
					brightnessIcon.Position = UDim2.fromScale(0, 0.5)
					brightnessIcon.Size = UDim2.fromOffset(15, 15)
					brightnessIcon.BackgroundTransparency = 1
					brightnessIcon.ZIndex = 32
					brightnessIcon.Parent = valueContainer
					local valueSliderBtn = Instance.new("TextButton")
					valueSliderBtn.Name = "Value"
					valueSliderBtn.Text = ""
					valueSliderBtn.AutoButtonColor = false
					valueSliderBtn.AnchorPoint = Vector2.new(1, 0.5)
					valueSliderBtn.Position = UDim2.fromScale(1, 0.5)
					valueSliderBtn.BackgroundTransparency = 1
					valueSliderBtn.BorderSizePixel = 0
					valueSliderBtn.Size = UDim2.new(1, -24, 0, 14)
					valueSliderBtn.ZIndex = 33
					valueSliderBtn.Parent = valueContainer
					local valueTrackFill = Instance.new("Frame")
					valueTrackFill.Name = "ValueTrackFill"
					valueTrackFill.Size = UDim2.fromScale(1, 1)
					valueTrackFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					valueTrackFill.BorderSizePixel = 0
					valueTrackFill.ZIndex = 33
					valueTrackFill.Parent = valueSliderBtn
					local valueCorner = Instance.new("UICorner")
					valueCorner.CornerRadius = UDim.new(1, 0)
					valueCorner.Parent = valueTrackFill
					local valueGradient = Instance.new("UIGradient")
					valueGradient.Name = "ValueGradient"
					valueGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
					})
					valueGradient.Parent = valueTrackFill
					local valueStroke = Instance.new("UIStroke")
					valueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					valueStroke.Color = Color3.fromRGB(255, 255, 255)
					valueStroke.Transparency = 0.78
					valueStroke.Parent = valueTrackFill
					local slide = Instance.new("Frame")
					slide.Name = "Slide"
					slide.AnchorPoint = Vector2.new(0.5, 0.5)
					slide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					slide.BorderSizePixel = 0
					slide.Position = UDim2.fromScale(0, 0.5)
					slide.Size = UDim2.fromOffset(14, 20)
					slide.ZIndex = 35
					slide.Parent = valueSliderBtn
					local slideScale = Instance.new("UIScale")
					slideScale.Scale = 1
					slideScale.Parent = slide
					local slideCorner = Instance.new("UICorner")
					slideCorner.CornerRadius = UDim.new(1, 0)
					slideCorner.Parent = slide
					local slideStroke = Instance.new("UIStroke")
					slideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					slideStroke.Color = Color3.fromRGB(15, 15, 18)
					slideStroke.Thickness = 2
					slideStroke.Transparency = 0.15
					slideStroke.Parent = slide
					-- 3.3: Быстрая палитра готовых цветов (Swatches, 26px)
					local swatchesRow = Instance.new("Frame")
					swatchesRow.Name = "SwatchesRow"
					swatchesRow.BackgroundTransparency = 1
					swatchesRow.Size = UDim2.new(1, 0, 0, 26)
					swatchesRow.LayoutOrder = 3
					swatchesRow.ZIndex = 32
					swatchesRow.Parent = colorOptions
					local swatchesLayout = Instance.new("UIListLayout")
					swatchesLayout.FillDirection = Enum.FillDirection.Horizontal
					swatchesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					swatchesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					swatchesLayout.Padding = UDim.new(0, 8)
					swatchesLayout.SortOrder = Enum.SortOrder.LayoutOrder
					swatchesLayout.Parent = swatchesRow
					-- 3.4: Сравнение цветов NEW и CURRENT (фиксированная высота 34px, без AutomaticSize)
					local colorWells = Instance.new("Frame")
					colorWells.Name = "ColorWells"
					colorWells.AutomaticSize = Enum.AutomaticSize.None
					colorWells.BackgroundTransparency = 1
					colorWells.BorderSizePixel = 0
					colorWells.LayoutOrder = 4
					colorWells.Size = UDim2.new(1, 0, 0, 34)
					colorWells.ZIndex = 32
					colorWells.Parent = colorOptions
					local wellsGridLayout = Instance.new("UIGridLayout")
					wellsGridLayout.Name = "UIGridLayout"
					wellsGridLayout.CellPadding = UDim2.fromOffset(10, 0)
					wellsGridLayout.CellSize = UDim2.new(0.5, -5, 0, 34)
					wellsGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
					wellsGridLayout.Parent = colorWells
					local function CreateColorWell(wellName, badgeText, order)
						local wellBg = Instance.new("ImageLabel")
						wellBg.Name = wellName
						wellBg.Image = assets.gridose
						wellBg.ScaleType = Enum.ScaleType.Tile
						wellBg.TileSize = UDim2.fromOffset(10, 10)
						wellBg.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
						wellBg.BackgroundTransparency = 0
						wellBg.BorderSizePixel = 0
						wellBg.LayoutOrder = order
						wellBg.ZIndex = 32
						wellBg.Parent = colorWells
						local bgCorner = Instance.new("UICorner")
						bgCorner.CornerRadius = UDim.new(0, 8)
						bgCorner.Parent = wellBg
						local bgStroke = Instance.new("UIStroke")
						bgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						bgStroke.Color = Color3.fromRGB(255, 255, 255)
						bgStroke.Transparency = 0.75
						bgStroke.Parent = wellBg
						local fill = Instance.new("Frame")
						fill.Name = "Color"
						fill.AnchorPoint = Vector2.new(0.5, 0.5)
						fill.Position = UDim2.fromScale(0.5, 0.5)
						fill.Size = UDim2.fromScale(1, 1)
						fill.BackgroundColor3 = savedColor
						fill.BackgroundTransparency = isAlpha and savedAlpha or 0
						fill.BorderSizePixel = 0
						fill.ZIndex = 33
						fill.Parent = wellBg
						local fillCorner = Instance.new("UICorner")
						fillCorner.CornerRadius = UDim.new(0, 8)
						fillCorner.Parent = fill
						local badge = Instance.new("TextLabel")
						badge.Name = "Badge"
						badge.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						badge.Text = badgeText
						badge.TextSize = 10
						badge.TextColor3 = Color3.fromRGB(255, 255, 255)
						badge.TextTransparency = 0.15
						badge.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
						badge.BackgroundTransparency = 0.35
						badge.AnchorPoint = Vector2.new(0, 0.5)
						badge.Position = UDim2.new(0, 8, 0.5, 0)
						badge.AutomaticSize = Enum.AutomaticSize.XY
						badge.ZIndex = 34
						badge.Parent = wellBg
						local badgeCorner = Instance.new("UICorner")
						badgeCorner.CornerRadius = UDim.new(0, 4)
						badgeCorner.Parent = badge
						local badgePadding = Instance.new("UIPadding")
						badgePadding.PaddingLeft = UDim.new(0, 5)
						badgePadding.PaddingRight = UDim.new(0, 5)
						badgePadding.PaddingTop = UDim.new(0, 2)
						badgePadding.PaddingBottom = UDim.new(0, 2)
						badgePadding.Parent = badge
						return fill
					end
					local newColorFill = CreateColorWell("NewColor", "NEW", 0)
					local oldColorFill = CreateColorWell("OldColor", "CURRENT", 1)
					-- 4. Кнопки Confirm и Cancel (фиксированная высота 36px)
					local interactions = Instance.new("Frame")
					interactions.Name = "Interactions"
					interactions.BackgroundTransparency = 1
					interactions.BorderSizePixel = 0
					interactions.LayoutOrder = 2
					interactions.Size = UDim2.new(1, 0, 0, 36)
					interactions.ZIndex = 32
					interactions.Parent = prompt
					local interactionsLayout = Instance.new("UIListLayout")
					interactionsLayout.Name = "InteractionsLayout"
					interactionsLayout.FillDirection = Enum.FillDirection.Horizontal
					interactionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					interactionsLayout.Padding = UDim.new(0, 10)
					interactionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
					interactionsLayout.Parent = interactions
					local function CreateModalButton(btnName, btnText, iconId, order)
						local btn = Instance.new("TextButton")
						btn.Name = btnName
						btn.Text = ""
						btn.AutoButtonColor = false
						btn.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
						btn.BackgroundTransparency = 0.08
						btn.BorderSizePixel = 0
						btn.LayoutOrder = order
						btn.Size = UDim2.new(0.5, -5, 0, 36)
						btn.ZIndex = 33
						btn.Parent = interactions
						local scale = Instance.new("UIScale")
						scale.Scale = 1
						scale.Parent = btn
						local corner = Instance.new("UICorner")
						corner.CornerRadius = UDim.new(0, 8)
						corner.Parent = btn
						local stroke = ApplyGradientStroke(btn, "UIStroke", 0.5, "StrokeGradient")
						local contentRow = Instance.new("Frame")
						contentRow.Name = "ContentRow"
						contentRow.BackgroundTransparency = 1
						contentRow.Size = UDim2.fromScale(1, 1)
						contentRow.ZIndex = 34
						contentRow.Parent = btn
						local rowLayout = Instance.new("UIListLayout")
						rowLayout.FillDirection = Enum.FillDirection.Horizontal
						rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
						rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
						rowLayout.Padding = UDim.new(0, 7)
						rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
						rowLayout.Parent = contentRow
						local icon = Instance.new("ImageLabel")
						icon.Name = "Icon"
						icon.Image = iconId
						icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
						icon.ImageTransparency = 0.35
						icon.BackgroundTransparency = 1
						icon.Size = UDim2.fromOffset(14, 14)
						icon.LayoutOrder = 1
						icon.ZIndex = 34
						icon.Parent = contentRow
						local label = Instance.new("TextLabel")
						label.Name = "Label"
						label.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						label.Text = btnText
						label.TextColor3 = Color3.fromRGB(255, 255, 255)
						label.TextSize = 13
						label.TextTransparency = 0.35
						label.AutomaticSize = Enum.AutomaticSize.XY
						label.BackgroundTransparency = 1
						label.LayoutOrder = 2
						label.ZIndex = 34
						label.Parent = contentRow
						return btn, stroke, label, icon, scale
					end
					local confirm, confirmStroke, confirmLabel, confirmIcon, confirmScale = CreateModalButton("Confirm", "Confirm", assets.confirmIcon, 1)
					local cancel, cancelStroke, cancelLabel, cancelIcon, cancelScale = CreateModalButton("Cancel", "Cancel", assets.cancelIcon, 2)
					-- 5. Точная математика цвета HSV (исправлен инвертированный угол Y!)
					local fromHSV, fromRGB = Color3.fromHSV, Color3.fromRGB
					local hue, saturation, valHSV = savedColor:ToHSV()
					local currentAlpha = savedAlpha
					local wheelDragging = false
					local slideDragging = false
					local activeInputObject = nil
					local isModalOpen = false
					local TWEEN_MODAL = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					local TWEEN_HOVER = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					local TWEEN_HANDLE = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					local TWEEN_COLOR = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					local function SyncVisualHandles(instant)
						local angle = hue * math.pi * 2
						local normX = -math.cos(angle) * saturation
						local normY = -math.sin(angle) * saturation
						local targetGoalPos = UDim2.fromScale(0.5 + normX * 0.5, 0.5 + normY * 0.5)
						local slideRatio = math.clamp(1 - valHSV, 0, 1)
						local slideGoalPos = UDim2.fromScale(slideRatio, 0.5)
						local fullBrightColor = fromHSV(hue, saturation, 1)
						local currentColor = fromHSV(hue, saturation, valHSV)
						local ringContrastColor = (valHSV > 0.65 and saturation < 0.35)
							and Color3.fromRGB(20, 20, 24)
							or Color3.fromRGB(255, 255, 255)
						targetInnerRing.BackgroundColor3 = currentColor
						targetInnerStroke.Color = ringContrastColor
						valueTrackFill.BackgroundColor3 = fullBrightColor
						wheelBtn.ImageColor3 = fromHSV(0, 0, 0.25 + valHSV * 0.75)
						if instant or not isModalOpen then
							target.Position = targetGoalPos
							slide.Position = slideGoalPos
						else
							Tween(target, TWEEN_HANDLE, { Position = targetGoalPos }):Play()
							Tween(slide, TWEEN_HANDLE, { Position = slideGoalPos }):Play()
						end
					end
					local function SyncTextAndNewWell(instant)
						local c = fromHSV(hue, saturation, valHSV)
						local r = math.clamp(math.round(c.R * 255), 0, 255)
						local g = math.clamp(math.round(c.G * 255), 0, 255)
						local b = math.clamp(math.round(c.B * 255), 0, 255)
						local targetAlpha = isAlpha and currentAlpha or 0
						if instant or not isModalOpen then
							newColorFill.BackgroundColor3 = c
							newColorFill.BackgroundTransparency = targetAlpha
						else
							Tween(newColorFill, TWEEN_COLOR, {
								BackgroundColor3 = c,
								BackgroundTransparency = targetAlpha
							}):Play()
						end
						modifierInputs.Red.Text = tostring(r)
						modifierInputs.Green.Text = tostring(g)
						modifierInputs.Blue.Text = tostring(b)
						modifierInputs.Hex.Text = string.format("#%02X%02X%02X", r, g, b)
						if isAlpha then
							modifierInputs.Alpha.Text = FormatAlphaText(currentAlpha)
						end
					end
					local function UpdateAllPickerVisuals(instant)
						SyncVisualHandles(instant)
						SyncTextAndNewWell(instant)
					end
					-- Создаём кнопки быстрой палитры (Swatches)
					for idx, swatchColor in ipairs(DEFAULT_SWATCHES) do
						local swBtn = Instance.new("TextButton")
						swBtn.Name = "Swatch_" .. tostring(idx)
						swBtn.Text = ""
						swBtn.AutoButtonColor = false
						swBtn.BackgroundColor3 = swatchColor
						swBtn.BorderSizePixel = 0
						swBtn.Size = UDim2.fromOffset(38, 22)
						swBtn.LayoutOrder = idx
						swBtn.ZIndex = 33
						swBtn.Parent = swatchesRow
						local swCorner = Instance.new("UICorner")
						swCorner.CornerRadius = UDim.new(0, 5)
						swCorner.Parent = swBtn
						local swStroke = Instance.new("UIStroke")
						swStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						swStroke.Color = Color3.fromRGB(255, 255, 255)
						swStroke.Transparency = 0.7
						swStroke.Parent = swBtn
						swBtn.MouseButton1Click:Connect(function()
							hue, saturation, valHSV = swatchColor:ToHSV()
							UpdateAllPickerVisuals(false)
						end)
					end
					local function UpdateSlideFromPointer(screenPos)
						local absPos = valueSliderBtn.AbsolutePosition
						local absSize = valueSliderBtn.AbsoluteSize
						if absSize.X <= 0 then
							return
						end
						local ratio = math.clamp((screenPos.X - absPos.X) / absSize.X, 0, 1)
						valHSV = 1 - ratio
						UpdateAllPickerVisuals(true)
					end
					local function UpdateWheelFromPointer(screenPos)
						local absPos = wheelBtn.AbsolutePosition
						local absSize = wheelBtn.AbsoluteSize
						local radiusScreen = absSize.X * 0.5
						if radiusScreen <= 0 then
							return
						end
						local centerScreen = absPos + (absSize * 0.5)
						local deltaScreen = Vector2.new(
							screenPos.X - centerScreen.X,
							screenPos.Y - centerScreen.Y
						)
						local dist = deltaScreen.Magnitude
						if dist > radiusScreen then
							deltaScreen = deltaScreen.Unit * radiusScreen
							dist = radiusScreen
						end
						local phi = math.atan2(-deltaScreen.Y, deltaScreen.X)
						hue = ((math.pi - phi) / (2 * math.pi)) % 1
						saturation = math.clamp(dist / radiusScreen, 0, 1)
						UpdateAllPickerVisuals(true)
					end
					wheelBtn.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							wheelDragging = true
							activeInputObject = input
							Tween(targetScale, TWEEN_HOVER, { Scale = 1.22 }):Play()
							UpdateWheelFromPointer(input.Position)
						end
					end)
					valueSliderBtn.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							slideDragging = true
							activeInputObject = input
							Tween(slideScale, TWEEN_HOVER, { Scale = 1.18 }):Play()
							UpdateSlideFromPointer(input.Position)
						end
					end)
					local globalInputChangedConn = UserInputService.InputChanged:Connect(function(input)
						if not isModalOpen or not (wheelDragging or slideDragging) then
							return
						end
						local isMouseMove = (input.UserInputType == Enum.UserInputType.MouseMovement)
						local isTouchMove = (input.UserInputType == Enum.UserInputType.Touch and (activeInputObject == nil or input == activeInputObject))
						if isMouseMove or isTouchMove then
							if wheelDragging then
								UpdateWheelFromPointer(input.Position)
							elseif slideDragging then
								UpdateSlideFromPointer(input.Position)
							end
						end
					end)
					local globalInputEndedConn = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if activeInputObject == nil or input == activeInputObject or input.UserInputType == Enum.UserInputType.MouseButton1 then
								if wheelDragging then
									Tween(targetScale, TWEEN_HOVER, { Scale = 1 }):Play()
								end
								if slideDragging then
									Tween(slideScale, TWEEN_HOVER, { Scale = 1 }):Play()
								end
								wheelDragging = false
								slideDragging = false
								activeInputObject = nil
							end
						end
					end)
					for _, box in pairs(modifierInputs) do
						local stroke = box:FindFirstChildOfClass("UIStroke")
						box.Focused:Connect(function()
							box.PlaceholderText = box.Text
							Tween(box, TWEEN_HOVER, { BackgroundTransparency = 0.9 }):Play()
							if stroke then
								Tween(stroke, TWEEN_HOVER, { Transparency = 0.3 }):Play()
							end
						end)
						box.FocusLost:Connect(function()
							Tween(box, TWEEN_HOVER, { BackgroundTransparency = 0.95 }):Play()
							if stroke then
								Tween(stroke, TWEEN_HOVER, { Transparency = 0.82 }):Play()
							end
						end)
					end
					local function ApplyRGBInputs()
						local r = ClampNumber(modifierInputs.Red.Text, 0, 255)
						local g = ClampNumber(modifierInputs.Green.Text, 0, 255)
						local b = ClampNumber(modifierInputs.Blue.Text, 0, 255)
						hue, saturation, valHSV = fromRGB(r, g, b):ToHSV()
						UpdateAllPickerVisuals(false)
					end
					local function ApplyHexInput()
						local r, g, b = HexToRGB(modifierInputs.Hex.Text)
						if r and g and b then
							hue, saturation, valHSV = fromRGB(r, g, b):ToHSV()
						end
						UpdateAllPickerVisuals(false)
					end
					local function ApplyAlphaInput()
						local raw = tonumber(modifierInputs.Alpha.Text)
						if raw then
							if raw > 1 then
								raw = raw / 100
							end
							currentAlpha = math.clamp(raw, 0, 1)
						end
						UpdateAllPickerVisuals(false)
					end
					modifierInputs.Red.FocusLost:Connect(ApplyRGBInputs)
					modifierInputs.Green.FocusLost:Connect(ApplyRGBInputs)
					modifierInputs.Blue.FocusLost:Connect(ApplyRGBInputs)
					modifierInputs.Hex.FocusLost:Connect(ApplyHexInput)
					modifierInputs.Alpha.FocusLost:Connect(ApplyAlphaInput)
					local function LoadSavedStateIntoModal(instant)
						hue, saturation, valHSV = savedColor:ToHSV()
						currentAlpha = isAlpha and savedAlpha or 0
						oldColorFill.BackgroundColor3 = savedColor
						oldColorFill.BackgroundTransparency = isAlpha and savedAlpha or 0
						colorC.BackgroundColor3 = savedColor
						colorC.BackgroundTransparency = isAlpha and savedAlpha or 0
						UpdateAllPickerVisuals(instant)
					end
					cpInteract.MouseEnter:Connect(function()
						Tween(colorpickerName, TWEEN_HOVER, { TextTransparency = 0.15 }):Play()
						Tween(pickerCardStroke, TWEEN_HOVER, { Transparency = 0.18 }):Play()
						Tween(colorpicker, TWEEN_HOVER, { BackgroundTransparency = 0.955 }):Play()
						Tween(previewScale, TWEEN_HOVER, { Scale = 1.08 }):Play()
					end)
					cpInteract.MouseLeave:Connect(function()
						Tween(colorpickerName, TWEEN_HOVER, { TextTransparency = 0.4 }):Play()
						Tween(pickerCardStroke, TWEEN_HOVER, { Transparency = 0.35 }):Play()
						Tween(colorpicker, TWEEN_HOVER, { BackgroundTransparency = 0.985 }):Play()
						Tween(previewScale, TWEEN_HOVER, { Scale = 1 }):Play()
					end)
					local function BindModalButtonAnimations(btn, stroke, label, icon, scale)
						btn.MouseEnter:Connect(function()
							Tween(btn, TWEEN_HOVER, { BackgroundColor3 = Color3.fromRGB(36, 36, 40) }):Play()
							Tween(stroke, TWEEN_HOVER, { Transparency = 0.22 }):Play()
							Tween(label, TWEEN_HOVER, { TextTransparency = 0.08 }):Play()
							Tween(icon, TWEEN_HOVER, { ImageTransparency = 0.08 }):Play()
						end)
						btn.MouseLeave:Connect(function()
							Tween(btn, TWEEN_HOVER, { BackgroundColor3 = Color3.fromRGB(26, 26, 28) }):Play()
							Tween(stroke, TWEEN_HOVER, { Transparency = 0.5 }):Play()
							Tween(label, TWEEN_HOVER, { TextTransparency = 0.35 }):Play()
							Tween(icon, TWEEN_HOVER, { ImageTransparency = 0.35 }):Play()
							Tween(scale, TWEEN_HOVER, { Scale = 1 }):Play()
						end)
						btn.InputBegan:Connect(function(inp)
							if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
								Tween(scale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.95 }):Play()
							end
						end)
						btn.InputEnded:Connect(function(inp)
							if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
								Tween(scale, TWEEN_HOVER, { Scale = 1 }):Play()
							end
						end)
					end
					BindModalButtonAnimations(confirm, confirmStroke, confirmLabel, confirmIcon, confirmScale)
					BindModalButtonAnimations(cancel, cancelStroke, cancelLabel, cancelIcon, cancelScale)
					local modalTweenToken = 0
					local activeOverlayTween = nil
					local activeScaleTween = nil
					local function SetModalOpen(state)
						modalTweenToken = modalTweenToken + 1
						local token = modalTweenToken
						isModalOpen = state
						if not state then
							wheelDragging = false
							slideDragging = false
							activeInputObject = nil
							targetScale.Scale = 1
							slideScale.Scale = 1
						end
						if activeOverlayTween then activeOverlayTween:Cancel() end
						if activeScaleTween then activeScaleTween:Cancel() end
						if state then
							LoadSavedStateIntoModal(true)
							colorPickerModal.Visible = true
							colorPickerModal.BackgroundTransparency = 1
							promptScale.Scale = 0.94
							activeOverlayTween = Tween(colorPickerModal, TWEEN_MODAL, { BackgroundTransparency = 0.42 })
							activeScaleTween = Tween(promptScale, TWEEN_MODAL, { Scale = 1 })
							activeOverlayTween:Play()
							activeScaleTween:Play()
						else
							activeOverlayTween = Tween(colorPickerModal, TWEEN_MODAL, { BackgroundTransparency = 1 })
							activeScaleTween = Tween(promptScale, TWEEN_MODAL, { Scale = 0.94 })
							activeOverlayTween:Play()
							activeScaleTween:Play()
							activeOverlayTween.Completed:Connect(function(playbackState)
								if playbackState == Enum.PlaybackState.Completed and modalTweenToken == token and not isModalOpen then
									colorPickerModal.Visible = false
								end
							end)
						end
					end
					cpInteract.MouseButton1Click:Connect(function()
						SetModalOpen(true)
					end)
					cancel.MouseButton1Click:Connect(function()
						LoadSavedStateIntoModal(true)
						SetModalOpen(false)
					end)
					confirm.MouseButton1Click:Connect(function()
						local c = fromHSV(hue, saturation, valHSV)
						local r = math.clamp(math.round(c.R * 255), 0, 255)
						local g = math.clamp(math.round(c.G * 255), 0, 255)
						local b = math.clamp(math.round(c.B * 255), 0, 255)
						savedColor = fromRGB(r, g, b)
						savedAlpha = isAlpha and math.clamp(currentAlpha, 0, 1) or 0
						ColorpickerFunctions.Color = savedColor
						ColorpickerFunctions.Alpha = isAlpha and savedAlpha or nil
						oldColorFill.BackgroundColor3 = savedColor
						oldColorFill.BackgroundTransparency = isAlpha and savedAlpha or 0
						Tween(colorC, TWEEN_COLOR, {
							BackgroundColor3 = savedColor,
							BackgroundTransparency = isAlpha and savedAlpha or 0
						}):Play()
						SetModalOpen(false)
						if ClrSettings.Callback then
							task.spawn(ClrSettings.Callback, savedColor, isAlpha and savedAlpha or nil)
						end
					end)
					colorpicker.Destroying:Connect(function()
						if globalInputChangedConn then globalInputChangedConn:Disconnect() end
						if globalInputEndedConn then globalInputEndedConn:Disconnect() end
						if colorPickerModal then colorPickerModal:Destroy() end
					end)
					LoadSavedStateIntoModal(true)
					function ColorpickerFunctions:UpdateName(New)
						ClrSettings.Name = New
						colorpickerName.Text = New
						paragraphHeader.Text = New
					end
					function ColorpickerFunctions:SetVisibility(State)
						colorpicker.Visible = State
					end
					function ColorpickerFunctions:SetColor(color3)
						if typeof(color3) ~= "Color3" then
							return
						end
						savedColor = color3
						ColorpickerFunctions.Color = savedColor
						colorC.BackgroundColor3 = savedColor
						hue, saturation, valHSV = savedColor:ToHSV()
						oldColorFill.BackgroundColor3 = savedColor
						if isModalOpen then
							UpdateAllPickerVisuals(true)
						else
							newColorFill.BackgroundColor3 = savedColor
						end
					end
					function ColorpickerFunctions:SetAlpha(newAlpha)
						local clamped = math.clamp(tonumber(newAlpha) or 0, 0, 1)
						savedAlpha = clamped
						currentAlpha = clamped
						ColorpickerFunctions.Alpha = isAlpha and savedAlpha or clamped
						colorC.BackgroundTransparency = clamped
						oldColorFill.BackgroundTransparency = clamped
						newColorFill.BackgroundTransparency = clamped
						if isModalOpen and isAlpha then
							modifierInputs.Alpha.Text = FormatAlphaText(clamped)
						end
					end
					return ColorpickerFunctions
				end
				-- Алиас Section:Color(...) для обратной совместимости
				SectionFunctions.Color = SectionFunctions.Colorpicker
				-- ============================================================
				-- 8.8: ТЕКСТОВЫЕ ЭЛЕМЕНТЫ И РАЗДЕЛИТЕЛИ
				-- ============================================================
				function SectionFunctions:Header(HdrSettings)
					HdrSettings = HdrSettings or {}
					local HeaderFunctions = {}
					local header = Instance.new("Frame")
					header.Name = "Header"
					header.AutomaticSize = Enum.AutomaticSize.Y
					header.BackgroundTransparency = 1
					header.BorderSizePixel = 0
					header.LayoutOrder = 0
					header.Size = UDim2.fromScale(1, 0)
					header.Parent = sectionContainer
					local pad = Instance.new("UIPadding")
					pad.Name = "UIPadding"
					pad.PaddingBottom = UDim.new(0, 5)
					pad.Parent = header
					local headerText = Instance.new("TextLabel")
					headerText.Name = "HeaderText"
					headerText.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					headerText.RichText = true
					headerText.Text = HdrSettings.Text or HdrSettings.Name or "Header"
					headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
					headerText.TextSize = 16
					headerText.TextTransparency = 0.4
					headerText.TextWrapped = true
					headerText.TextXAlignment = Enum.TextXAlignment.Left
					headerText.AutomaticSize = Enum.AutomaticSize.Y
					headerText.BackgroundTransparency = 1
					headerText.BorderSizePixel = 0
					headerText.Size = UDim2.fromScale(1, 0)
					headerText.Parent = header
					function HeaderFunctions:UpdateName(New)
						headerText.Text = New
					end
					function HeaderFunctions:SetVisibility(State)
						header.Visible = State
					end
					return HeaderFunctions
				end
				function SectionFunctions:Label(LblSettings)
					LblSettings = LblSettings or {}
					local LabelFunctions = {}
					local label = Instance.new("Frame")
					label.Name = "Label"
					label.AutomaticSize = Enum.AutomaticSize.Y
					label.BackgroundTransparency = 1
					label.BorderSizePixel = 0
					label.Size = UDim2.new(1, 0, 0, 38)
					label.Parent = sectionContainer
					local labelText = Instance.new("TextLabel")
					labelText.Name = "LabelText"
					labelText.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					labelText.RichText = true
					labelText.Text = LblSettings.Text or LblSettings.Name or "Label"
					labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
					labelText.TextSize = 13
					labelText.TextTransparency = 0.5
					labelText.TextWrapped = true
					labelText.TextXAlignment = Enum.TextXAlignment.Left
					labelText.AutomaticSize = Enum.AutomaticSize.Y
					labelText.BackgroundTransparency = 1
					labelText.BorderSizePixel = 0
					labelText.Size = UDim2.fromScale(1, 1)
					labelText.Parent = label
					function LabelFunctions:UpdateName(New)
						labelText.Text = New
					end
					function LabelFunctions:SetVisibility(State)
						label.Visible = State
					end
					return LabelFunctions
				end
				function SectionFunctions:SubLabel(SubSettings)
					SubSettings = SubSettings or {}
					local SubLabelFunctions = {}
					local subLabel = Instance.new("Frame")
					subLabel.Name = "SubLabel"
					subLabel.AutomaticSize = Enum.AutomaticSize.Y
					subLabel.BackgroundTransparency = 1
					subLabel.BorderSizePixel = 0
					subLabel.Size = UDim2.new(1, 0, 0, 0)
					subLabel.Parent = sectionContainer
					local subLabelText = Instance.new("TextLabel")
					subLabelText.Name = "SubLabelText"
					subLabelText.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					subLabelText.RichText = true
					subLabelText.Text = SubSettings.Text or SubSettings.Name or "SubLabel"
					subLabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
					subLabelText.TextSize = 11
					subLabelText.TextTransparency = 0.7
					subLabelText.TextWrapped = true
					subLabelText.TextXAlignment = Enum.TextXAlignment.Left
					subLabelText.AutomaticSize = Enum.AutomaticSize.Y
					subLabelText.BackgroundTransparency = 1
					subLabelText.BorderSizePixel = 0
					subLabelText.Size = UDim2.fromScale(1, 0)
					subLabelText.Parent = subLabel
					function SubLabelFunctions:UpdateName(New)
						subLabelText.Text = New
					end
					function SubLabelFunctions:SetVisibility(State)
						subLabel.Visible = State
					end
					return SubLabelFunctions
				end
				function SectionFunctions:Paragraph(PrgSettings)
					PrgSettings = PrgSettings or {}
					local ParagraphFunctions = {}
					local paragraph = Instance.new("Frame")
					paragraph.Name = "Paragraph"
					paragraph.AutomaticSize = Enum.AutomaticSize.Y
					paragraph.BackgroundTransparency = 1
					paragraph.BorderSizePixel = 0
					paragraph.Size = UDim2.new(1, 0, 0, 38)
					paragraph.Parent = sectionContainer
					local paragraphHeader = Instance.new("TextLabel")
					paragraphHeader.Name = "ParagraphHeader"
					paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
					paragraphHeader.RichText = true
					paragraphHeader.Text = PrgSettings.Header or "Paragraph"
					paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
					paragraphHeader.TextSize = 16
					paragraphHeader.TextTransparency = 0.4
					paragraphHeader.TextWrapped = true
					paragraphHeader.TextXAlignment = Enum.TextXAlignment.Left
					paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
					paragraphHeader.BackgroundTransparency = 1
					paragraphHeader.BorderSizePixel = 0
					paragraphHeader.Size = UDim2.fromScale(1, 0)
					paragraphHeader.Parent = paragraph
					local pLayout = Instance.new("UIListLayout")
					pLayout.Name = "UIListLayout"
					pLayout.Padding = UDim.new(0, 5)
					pLayout.SortOrder = Enum.SortOrder.LayoutOrder
					pLayout.Parent = paragraph
					local paragraphBody = Instance.new("TextLabel")
					paragraphBody.Name = "ParagraphBody"
					paragraphBody.FontFace = Font.new(assets.interFont)
					paragraphBody.RichText = true
					paragraphBody.Text = PrgSettings.Body or ""
					paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
					paragraphBody.TextSize = 13
					paragraphBody.TextTransparency = 0.5
					paragraphBody.TextWrapped = true
					paragraphBody.TextXAlignment = Enum.TextXAlignment.Left
					paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
					paragraphBody.BackgroundTransparency = 1
					paragraphBody.BorderSizePixel = 0
					paragraphBody.LayoutOrder = 1
					paragraphBody.Size = UDim2.fromScale(1, 0)
					paragraphBody.Parent = paragraph
					function ParagraphFunctions:UpdateHeader(New)
						paragraphHeader.Text = New
					end
					function ParagraphFunctions:UpdateBody(New)
						paragraphBody.Text = New
					end
					function ParagraphFunctions:SetVisibility(State)
						paragraph.Visible = State
					end
					return ParagraphFunctions
				end
				function SectionFunctions:Divider()
					local DividerFunctions = {}
					local div = Instance.new("Frame")
					div.Name = "Divider"
					div.AnchorPoint = Vector2.new(0, 1)
					div.AutomaticSize = Enum.AutomaticSize.Y
					div.BackgroundTransparency = 1
					div.BorderSizePixel = 0
					div.Position = UDim2.fromScale(0, 1)
					div.Size = UDim2.new(1, 0, 0, 1)
					div.Parent = sectionContainer
					local pad = Instance.new("UIPadding")
					pad.Name = "UIPadding"
					pad.PaddingBottom = UDim.new(0, 8)
					pad.PaddingTop = UDim.new(0, 8)
					pad.Parent = div
					local dLayout = Instance.new("UIListLayout")
					dLayout.Name = "UIListLayout"
					dLayout.SortOrder = Enum.SortOrder.LayoutOrder
					dLayout.Parent = div
					local line = Instance.new("Frame")
					line.Name = "Line"
					line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					line.BackgroundTransparency = 0.9
					line.BorderSizePixel = 0
					line.Size = UDim2.new(1, 0, 0, 1)
					line.Parent = div
					function DividerFunctions:Remove()
						div:Destroy()
					end
					function DividerFunctions:SetVisibility(State)
						div.Visible = State
					end
					return DividerFunctions
				end
				function SectionFunctions:Spacer()
					local SpacerFunctions = {}
					local spacer = Instance.new("Frame")
					spacer.Name = "Spacer"
					spacer.AnchorPoint = Vector2.new(0, 1)
					spacer.BackgroundTransparency = 1
					spacer.BorderSizePixel = 0
					spacer.Position = UDim2.fromScale(0, 1)
					spacer.Size = UDim2.new(1, 0, 0, 8)
					spacer.Parent = sectionContainer
					function SpacerFunctions:Remove()
						spacer:Destroy()
					end
					function SpacerFunctions:SetVisibility(State)
						spacer.Visible = State
					end
					return SpacerFunctions
				end
				function SectionFunctions:ToggleCollapse()
					ToggleCollapse()
				end
				function SectionFunctions:SetVisibility(State)
					section.Visible = State
				end
				return SectionFunctions
			end
			local function SelectCurrentTab()
				local easeTime = 0.15
				if currentTabInstance then
					currentTabInstance.Parent = nil
				end
				for _, v in pairs(tabSwitchersScrollingFrame:GetDescendants()) do
					if v.Name == "TabSwitcher" then
						Tween(v, TweenInfo.new(easeTime, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 }):Play()
						local st = v:FindFirstChild("TabSwitcherUIStroke")
						if st then
							Tween(st, TweenInfo.new(easeTime, Enum.EasingStyle.Sine), { Transparency = 1 }):Play()
						end
					end
				end
				tabs[tabSwitcher].Parent = content
				currentTabInstance = tabs[tabSwitcher]
				currentTab.Text = TabConfig.Name
				Tween(tabSwitcher, TweenInfo.new(easeTime, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.98 }):Play()
				Tween(tabSwitcherUIStroke, TweenInfo.new(easeTime, Enum.EasingStyle.Sine), { Transparency = 0.95 }):Play()
			end
			tabSwitcher.MouseButton1Click:Connect(SelectCurrentTab)
			function TabFunctions:Select()
				SelectCurrentTab()
			end
			tabs[tabSwitcher] = elements1
			return TabFunctions
		end
		return GroupFunctions
	end
	-- Уведомления (Notify)
	function WindowFunctions:Notify(NotifyConfig)
		NotifyConfig = NotifyConfig or {}
		local NotificationFunctions = {}
		local notification = Instance.new("Frame")
		notification.Name = "Notification"
		notification.AnchorPoint = Vector2.new(0.5, 0.5)
		notification.AutomaticSize = Enum.AutomaticSize.Y
		notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		notification.BorderSizePixel = 0
		notification.Position = UDim2.fromScale(0.5, 0.5)
		notification.Size = UDim2.fromOffset(NotifyConfig.SizeX or 250, 0)
		notification.Parent = notifications
		local notificationUIStroke = Instance.new("UIStroke")
		notificationUIStroke.Name = "NotificationUIStroke"
		notificationUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		notificationUIStroke.Color = Color3.fromRGB(255, 255, 255)
		notificationUIStroke.Transparency = 0.9
		notificationUIStroke.Parent = notification
		local notificationUICorner = Instance.new("UICorner")
		notificationUICorner.Name = "NotificationUICorner"
		notificationUICorner.CornerRadius = UDim.new(0, 10)
		notificationUICorner.Parent = notification
		local notificationUIScale = Instance.new("UIScale")
		notificationUIScale.Name = "NotificationUIScale"
		notificationUIScale.Scale = 0
		notificationUIScale.Parent = notification
		local notificationInformation = Instance.new("Frame")
		notificationInformation.Name = "NotificationInformation"
		notificationInformation.AutomaticSize = Enum.AutomaticSize.Y
		notificationInformation.BackgroundTransparency = 1
		notificationInformation.BorderSizePixel = 0
		notificationInformation.Size = UDim2.fromScale(1, 1)
		notificationInformation.Parent = notification
		local notificationTitle = Instance.new("TextLabel")
		notificationTitle.Name = "NotificationTitle"
		notificationTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		notificationTitle.RichText = true
		notificationTitle.Text = NotifyConfig.Title or "Notification"
		notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationTitle.TextSize = 13
		notificationTitle.TextTransparency = 0.2
		notificationTitle.TextTruncate = Enum.TextTruncate.SplitWord
		notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
		notificationTitle.TextYAlignment = Enum.TextYAlignment.Top
		notificationTitle.AutomaticSize = Enum.AutomaticSize.XY
		notificationTitle.BackgroundTransparency = 1
		notificationTitle.BorderSizePixel = 0
		notificationTitle.Size = UDim2.new(1, -12, 0, 0)
		notificationTitle.Parent = notificationInformation
		local notificationTitleUIPadding = Instance.new("UIPadding")
		notificationTitleUIPadding.Name = "NotificationTitleUIPadding"
		notificationTitleUIPadding.PaddingRight = UDim.new(0, 25)
		notificationTitleUIPadding.Parent = notificationTitle
		local notificationDescription = Instance.new("TextLabel")
		notificationDescription.Name = "NotificationDescription"
		notificationDescription.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		notificationDescription.Text = NotifyConfig.Description or ""
		notificationDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationDescription.TextSize = 11
		notificationDescription.TextTransparency = 0.5
		notificationDescription.TextWrapped = true
		notificationDescription.RichText = true
		notificationDescription.TextXAlignment = Enum.TextXAlignment.Left
		notificationDescription.TextYAlignment = Enum.TextYAlignment.Top
		notificationDescription.AutomaticSize = Enum.AutomaticSize.XY
		notificationDescription.BackgroundTransparency = 1
		notificationDescription.BorderSizePixel = 0
		notificationDescription.Size = UDim2.new(1, -12, 0, 0)
		notificationDescription.Parent = notificationInformation
		local notificationDescriptionUIPadding = Instance.new("UIPadding")
		notificationDescriptionUIPadding.Name = "NotificationDescriptionUIPadding"
		notificationDescriptionUIPadding.PaddingRight = UDim.new(0, 25)
		notificationDescriptionUIPadding.PaddingTop = UDim.new(0, 17)
		notificationDescriptionUIPadding.Parent = notificationDescription
		local notificationUIPadding = Instance.new("UIPadding")
		notificationUIPadding.Name = "NotificationUIPadding"
		notificationUIPadding.PaddingBottom = UDim.new(0, 12)
		notificationUIPadding.PaddingLeft = UDim.new(0, 10)
		notificationUIPadding.PaddingRight = UDim.new(0, 10)
		notificationUIPadding.PaddingTop = UDim.new(0, 10)
		notificationUIPadding.Parent = notificationInformation
		local notificationControls = Instance.new("Frame")
		notificationControls.Name = "NotificationControls"
		notificationControls.AutomaticSize = Enum.AutomaticSize.Y
		notificationControls.BackgroundTransparency = 1
		notificationControls.BorderSizePixel = 0
		notificationControls.Size = UDim2.fromScale(1, 1)
		notificationControls.Parent = notification
		local interactable = Instance.new("TextButton")
		interactable.Name = "Interactable"
		interactable.FontFace = Font.new(assets.interFont)
		interactable.Text = "✓"
		interactable.TextColor3 = Color3.fromRGB(255, 255, 255)
		interactable.TextSize = 17
		interactable.TextTransparency = 0.2
		interactable.AnchorPoint = Vector2.new(1, 0.5)
		interactable.AutomaticSize = Enum.AutomaticSize.XY
		interactable.BackgroundTransparency = 1
		interactable.BorderSizePixel = 0
		interactable.LayoutOrder = 1
		interactable.Position = UDim2.fromScale(1, 0.5)
		interactable.Parent = notificationControls
		local ncPad = Instance.new("UIPadding")
		ncPad.Name = "UIPadding"
		ncPad.PaddingBottom = UDim.new(0, 6)
		ncPad.PaddingRight = UDim.new(0, 13)
		ncPad.PaddingTop = UDim.new(0, 6)
		ncPad.Parent = notificationControls
		local tweens = {
			In = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = NotifyConfig.Scale or 1
			}),
			Out = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = 0
			})
		}
		if NotifyConfig.Style == "Confirm" then
			interactable.Text = "✓"
		elseif NotifyConfig.Style == "Cancel" then
			interactable.Text = "✗"
		else
			interactable:Destroy()
			interactable = nil
		end
		if interactable then
			interactable.MouseButton1Click:Connect(function()
				NotificationFunctions:Cancel()
				if NotifyConfig.Callback then
					task.spawn(NotifyConfig.Callback)
				end
			end)
		end
		local AnimateNotification = task.spawn(function()
			tweens.In:Play()
			local lifetime = (NotifyConfig.Lifetime ~= nil) and NotifyConfig.Lifetime or 3
			if lifetime ~= 0 then
				task.wait(lifetime)
				tweens.Out:Play()
				tweens.Out.Completed:Wait()
				notification:Destroy()
			end
		end)
		function NotificationFunctions:UpdateTitle(New)
			notificationTitle.Text = New
		end
		function NotificationFunctions:UpdateDescription(New)
			notificationDescription.Text = New
		end
		function NotificationFunctions:Resize(X)
			notification.Size = UDim2.fromOffset(X or 250, 0)
		end
		function NotificationFunctions:Cancel()
			pcall(task.cancel, AnimateNotification)
			tweens.Out:Play()
			tweens.Out.Completed:Wait()
			notification:Destroy()
		end
		return NotificationFunctions
	end
	-- Диалоговые окна (Dialog)
	function WindowFunctions:Dialog(DialogConfig)
		DialogConfig = DialogConfig or {}
		local DialogFunctions = {}
		local dialogOverlay = Instance.new("Frame")
		dialogOverlay.Name = "Dialog"
		dialogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dialogOverlay.BackgroundTransparency = 1
		dialogOverlay.BorderSizePixel = 0
		dialogOverlay.Size = UDim2.fromScale(1, 1)
		dialogOverlay.ZIndex = 25
		dialogOverlay.Active = true
		dialogOverlay.Parent = base
		local dlgCorner = Instance.new("UICorner")
		dlgCorner.Name = "BaseUICorner"
		dlgCorner.CornerRadius = UDim.new(0, 10)
		dlgCorner.Parent = dialogOverlay
		local prompt = Instance.new("Frame")
		prompt.Name = "Prompt"
		prompt.AnchorPoint = Vector2.new(0.5, 0.5)
		prompt.AutomaticSize = Enum.AutomaticSize.Y
		prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		prompt.BorderSizePixel = 0
		prompt.Position = UDim2.fromScale(0.5, 0.5)
		prompt.Size = UDim2.fromOffset(280, 0)
		prompt.ZIndex = 26
		prompt.Parent = dialogOverlay
		local promptScale = Instance.new("UIScale")
		promptScale.Scale = 0.94
		promptScale.Parent = prompt
		local dlgStroke = Instance.new("UIStroke")
		dlgStroke.Name = "GlobalSettingsUIStroke"
		dlgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		dlgStroke.Color = Color3.fromRGB(255, 255, 255)
		dlgStroke.Transparency = 0.9
		dlgStroke.Parent = prompt
		local promptCorner = Instance.new("UICorner")
		promptCorner.Name = "GlobalSettingsUICorner"
		promptCorner.CornerRadius = UDim.new(0, 10)
		promptCorner.Parent = prompt
		local promptPad = Instance.new("UIPadding")
		promptPad.Name = "GlobalSettingsUIPadding"
		promptPad.PaddingBottom = UDim.new(0, 20)
		promptPad.PaddingLeft = UDim.new(0, 20)
		promptPad.PaddingRight = UDim.new(0, 20)
		promptPad.PaddingTop = UDim.new(0, 20)
		promptPad.Parent = prompt
		local paragraph = Instance.new("Frame")
		paragraph.Name = "Paragraph"
		paragraph.AutomaticSize = Enum.AutomaticSize.Y
		paragraph.BackgroundTransparency = 1
		paragraph.BorderSizePixel = 0
		paragraph.Size = UDim2.new(1, 0, 0, 38)
		paragraph.ZIndex = 26
		paragraph.Parent = prompt
		local paragraphHeader = Instance.new("TextLabel")
		paragraphHeader.Name = "ParagraphHeader"
		paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		paragraphHeader.RichText = true
		paragraphHeader.Text = DialogConfig.Title or "Dialog"
		paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
		paragraphHeader.TextSize = 18
		paragraphHeader.TextTransparency = 0.4
		paragraphHeader.TextWrapped = true
		paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
		paragraphHeader.BackgroundTransparency = 1
		paragraphHeader.BorderSizePixel = 0
		paragraphHeader.Size = UDim2.fromScale(1, 0)
		paragraphHeader.ZIndex = 26
		paragraphHeader.Parent = paragraph
		local pList = Instance.new("UIListLayout")
		pList.Name = "UIListLayout"
		pList.Padding = UDim.new(0, 15)
		pList.SortOrder = Enum.SortOrder.LayoutOrder
		pList.Parent = paragraph
		local paragraphBody = Instance.new("TextLabel")
		paragraphBody.Name = "ParagraphBody"
		paragraphBody.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		paragraphBody.RichText = true
		paragraphBody.Text = DialogConfig.Description or ""
		paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
		paragraphBody.TextSize = 14
		paragraphBody.TextTransparency = 0.5
		paragraphBody.TextWrapped = true
		paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
		paragraphBody.BackgroundTransparency = 1
		paragraphBody.BorderSizePixel = 0
		paragraphBody.LayoutOrder = 1
		paragraphBody.Size = UDim2.fromScale(1, 0)
		paragraphBody.ZIndex = 26
		paragraphBody.Parent = paragraph
		local interactions = Instance.new("Frame")
		interactions.Name = "Interactions"
		interactions.AutomaticSize = Enum.AutomaticSize.Y
		interactions.BackgroundTransparency = 1
		interactions.BorderSizePixel = 0
		interactions.LayoutOrder = 1
		interactions.Size = UDim2.fromScale(1, 0)
		interactions.ZIndex = 26
		interactions.Parent = prompt
		local iList = Instance.new("UIListLayout")
		iList.Name = "UIListLayout"
		iList.Padding = UDim.new(0, 10)
		iList.SortOrder = Enum.SortOrder.LayoutOrder
		iList.Parent = interactions
		local iPad = Instance.new("UIPadding")
		iPad.Name = "UIPadding"
		iPad.PaddingTop = UDim.new(0, 20)
		iPad.Parent = interactions
		local prList = Instance.new("UIListLayout")
		prList.Name = "UIListLayout"
		prList.SortOrder = Enum.SortOrder.LayoutOrder
		prList.Parent = prompt
		local isClosing = false
		local function DialogOut()
			if isClosing then
				return
			end
			isClosing = true
			local outTween = Tween(dialogOverlay, TweenInfo.new(0.18, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 })
			Tween(promptScale, TweenInfo.new(0.18, Enum.EasingStyle.Sine), { Scale = 0.94 }):Play()
			outTween:Play()
			outTween.Completed:Connect(function()
				dialogOverlay:Destroy()
			end)
		end
		for _, v in pairs(DialogConfig.Buttons or {}) do
			local button = Instance.new("TextButton")
			button.Name = "Button"
			button.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
			button.Text = v.Name
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.TextSize = 15
			button.TextTransparency = 0.5
			button.TextTruncate = Enum.TextTruncate.AtEnd
			button.AutoButtonColor = false
			button.AutomaticSize = Enum.AutomaticSize.Y
			button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			button.BorderSizePixel = 0
			button.Size = UDim2.fromScale(1, 0)
			button.ZIndex = 27
			button.Parent = interactions
			local bPad = Instance.new("UIPadding")
			bPad.Name = "UIPadding"
			bPad.PaddingBottom = UDim.new(0, 9)
			bPad.PaddingLeft = UDim.new(0, 10)
			bPad.PaddingRight = UDim.new(0, 10)
			bPad.PaddingTop = UDim.new(0, 9)
			bPad.Parent = button
			local bCorner = Instance.new("UICorner")
			bCorner.Name = "BaseUICorner"
			bCorner.CornerRadius = UDim.new(0, 10)
			bCorner.Parent = button
			button.MouseEnter:Connect(function()
				Tween(button, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					BackgroundTransparency = 0.3,
					TextTransparency = 0.2
				}):Play()
			end)
			button.MouseLeave:Connect(function()
				Tween(button, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
					BackgroundTransparency = 0,
					TextTransparency = 0.5
				}):Play()
			end)
			button.MouseButton1Click:Connect(function()
				if isClosing then
					return
				end
				if v.Callback then
					task.spawn(v.Callback)
				end
				DialogOut()
			end)
		end
		Tween(dialogOverlay, TweenInfo.new(0.18, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.5 }):Play()
		Tween(promptScale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		function DialogFunctions:UpdateTitle(New)
			paragraphHeader.Text = New
		end
		function DialogFunctions:UpdateDescription(New)
			paragraphBody.Text = New
		end
		function DialogFunctions:Cancel()
			DialogOut()
		end
		return DialogFunctions
	end
	-- Состояния окна и выгрузка
	function WindowFunctions:SetNotificationsState(State)
		notifications.Visible = State
	end
	function WindowFunctions:GetNotificationsState()
		return notifications.Visible
	end
	function WindowFunctions:SetState(State)
		windowState = State
		base.Visible = State
	end
	function WindowFunctions:GetState()
		return windowState
	end
	local onUnloadCallback = nil
	function WindowFunctions:Unload()
		if onUnloadCallback then
			pcall(onUnloadCallback)
		end
		for _, conn in ipairs(windowConnections) do
			if conn then
				conn:Disconnect()
			end
		end
		table.clear(windowConnections)
		if blurController then
			blurController:Destroy()
		end
		macLib:Destroy()
	end
	function WindowFunctions.onUnloaded(callback)
		onUnloadCallback = callback
	end
	local MenuKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local function ToggleMenu()
		local state = not WindowFunctions:GetState()
		WindowFunctions:SetState(state)
		WindowFunctions:Notify({
			Title = Settings.Title or "MacLib",
			Description = (state and "Maximized " or "Minimized ") .. "the menu. Use " .. tostring(MenuKeybind.Name) .. " to toggle it.",
			Lifetime = 5
		})
	end
	TrackConnection(UserInputService.InputEnded:Connect(function(inp, gpe)
		if gpe then
			return
		end
		if inp.KeyCode == MenuKeybind then
			ToggleMenu()
		end
	end))
	minimize.MouseButton1Click:Connect(ToggleMenu)
	exit.MouseButton1Click:Connect(function()
		WindowFunctions:Unload()
	end)
	function WindowFunctions:SetKeybind(Keycode)
		MenuKeybind = Keycode
	end
	function WindowFunctions:SetAcrylicBlurState(State)
		acrylicBlur = State
		base.BackgroundTransparency = State and 0.05 or 0
	end
	function WindowFunctions:GetAcrylicBlurState()
		return acrylicBlur
	end
	local showUserInfo = (Settings.ShowUserInfo ~= nil) and Settings.ShowUserInfo or true
	local function ApplyUserInfoState(State)
		showUserInfo = State
		local pName = LocalPlayer and LocalPlayer.Name or "User"
		local pDisplay = LocalPlayer and LocalPlayer.DisplayName or "Player"
		if State then
			headshot.Image = (isHeadshotReady and cachedHeadshotImage) or "rbxassetid://0"
			username.Text = "@" .. pName
			displayName.Text = pDisplay
		else
			headshot.Image = assets.userInfoBlurred
			username.Text = "@" .. string.rep(".", #pName)
			displayName.Text = string.rep(".", #pDisplay)
		end
	end
	ApplyUserInfoState(showUserInfo)
	-- Асинхронная подгрузка аватарки игрока без фриза старта
	if LocalPlayer then
		task.spawn(function()
			local ok, img, ready = pcall(function()
				return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
			end)
			if ok and img then
				cachedHeadshotImage = img
				isHeadshotReady = ready
				if showUserInfo and headshot and headshot.Parent then
					headshot.Image = (ready and img) or "rbxassetid://0"
				end
			end
		end)
	end
	function WindowFunctions:SetUserInfoState(State)
		ApplyUserInfoState(State)
	end
	function WindowFunctions:GetUserInfoState()
		return showUserInfo
	end
	function WindowFunctions:SetSize(Size)
		base.Size = Size
	end
	function WindowFunctions:GetSize()
		return base.Size
	end
	function WindowFunctions:SetScale(Scale)
		baseUIScale.Scale = Scale
	end
	function WindowFunctions:GetScale()
		return baseUIScale.Scale
	end
	-- Асинхронная предзагрузка ассетов без блокировки потока
	task.spawn(function()
		local assetList = {}
		for _, assetId in pairs(assets) do
			table.insert(assetList, assetId)
		end
		pcall(function()
			ContentProvider:PreloadAsync(assetList)
		end)
	end)
	macLib.Enabled = true
	windowState = true
	return WindowFunctions
end
-- ============================================================================
-- БЛОК 9: ДЕМОНСТРАЦИОННЫЙ РЕЖИМ (MacLib:Demo)
-- ============================================================================
function MacLib:Demo()
	local Window = MacLib:Window({
		Title = "MacLib Demo",
		Subtitle = "This is a subtitle.",
		Size = UDim2.fromOffset(868, 650),
		DragStyle = 1,
		DisabledWindowControls = {},
		ShowUserInfo = true,
		Keybind = Enum.KeyCode.RightControl,
		AcrylicBlur = true
	})
	Window:GlobalSetting({
		Name = "UI Blur",
		Default = Window:GetAcrylicBlurState(),
		Callback = function(bool)
			Window:SetAcrylicBlurState(bool)
			Window:Notify({
				Title = "MacLib Demo",
				Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
				Lifetime = 5
			})
		end
	})
	Window:GlobalSetting({
		Name = "Notifications",
		Default = Window:GetNotificationsState(),
		Callback = function(bool)
			Window:SetNotificationsState(bool)
			Window:Notify({
				Title = "MacLib Demo",
				Description = (bool and "Enabled" or "Disabled") .. " Notifications",
				Lifetime = 5
			})
		end
	})
	Window:GlobalSetting({
		Name = "Show User Info",
		Default = Window:GetUserInfoState(),
		Callback = function(bool)
			Window:SetUserInfoState(bool)
			Window:Notify({
				Title = "MacLib Demo",
				Description = (bool and "Showing" or "Redacted") .. " User Info",
				Lifetime = 5
			})
		end
	})
	local tabGroup = Window:TabGroup()
	local mainTab = tabGroup:Tab({ Name = "Demo", Image = "rbxassetid://18821914323" })
	local mainSection = mainTab:Section({
		Side = "Left",
		Name = "Combat Settings",
		Icon = "rbxassetid://18821914323"
	})
	mainSection:Header({ Name = "Header #1" })
	mainSection:Button({
		Name = "Button",
		Callback = function()
			Window:Dialog({
				Title = "MacLib Demo",
				Description = "Lorem ipsum odor amet, consectetuer adipiscing elit. Eros vestibulum aliquet mattis, ex platea nunc.",
				Buttons = {
					{
						Name = "Confirm",
						Callback = function()
							print("Confirmed!")
						end
					},
					{
						Name = "Cancel"
					}
				}
			})
		end
	})
	mainSection:Input({
		Name = "Input",
		Placeholder = "Input",
		AcceptedCharacters = "All",
		Callback = function(input)
			Window:Notify({
				Title = "MacLib Demo",
				Description = "Successfully set input to " .. input
			})
		end,
		onChanged = function(input)
			print("Input is now " .. input)
		end
	})
	mainSection:Slider({
		Name = "Slider",
		Default = 50,
		Minimum = 0,
		Maximum = 100,
		DisplayMethod = "Percent",
		Callback = function(Value)
			print("Changed to " .. Value)
		end
	})
	mainSection:Toggle({
		Name = "Toggle",
		Default = false,
		Callback = function(value)
			Window:Notify({
				Title = "MacLib Demo",
				Description = (value and "Enabled " or "Disabled ") .. "Toggle"
			})
		end
	})
	mainSection:Keybind({
		Name = "Keybind",
		Callback = function(binded)
			Window:Notify({
				Title = "Demo Window",
				Description = "Pressed keybind - " .. tostring(binded.Name),
				Lifetime = 3
			})
		end,
		onBinded = function(bind)
			Window:Notify({
				Title = "Demo Window",
				Description = "Successfully Binded Keybind to - " .. tostring(bind.Name),
				Lifetime = 3
			})
		end
	})
	mainSection:Colorpicker({
		Name = "Colorpicker",
		Default = Color3.fromRGB(0, 255, 255),
		Callback = function(color)
			print("Color: ", color)
		end
	})
	local alphaColorPicker = mainSection:Colorpicker({
		Name = "Transparency Colorpicker",
		Default = Color3.fromRGB(255, 0, 0),
		Alpha = 0,
		Callback = function(color, alpha)
			print("Color: ", color, " Alpha: ", alpha)
		end
	})
	local rainbowConnection = nil
	local hue = 0
	mainSection:Toggle({
		Name = "Rainbow",
		Default = false,
		Callback = function(value)
			if value then
				rainbowConnection = RunService.RenderStepped:Connect(function(deltaTime)
					hue = (hue + deltaTime * 0.1) % 1
					alphaColorPicker:SetColor(Color3.fromHSV(hue, 1, 1))
				end)
			else
				if rainbowConnection then
					rainbowConnection:Disconnect()
					rainbowConnection = nil
				end
			end
		end
	})
	local optionTable = {}
	for i = 1, 10 do
		table.insert(optionTable, "Option " .. tostring(i))
	end
	local Dropdown = mainSection:Dropdown({
		Name = "Dropdown",
		Multi = false,
		Required = true,
		Options = optionTable,
		Default = 1,
		Callback = function(Value)
			print("Dropdown changed: " .. tostring(Value))
		end
	})
	local MultiDropdown = mainSection:Dropdown({
		Name = "Multi Dropdown",
		Search = true,
		Multi = true,
		Required = false,
		Options = optionTable,
		Default = { "Option 1", "Option 3" },
		Callback = function(Value)
			local Values = {}
			for k, state in next, Value do
				if state then
					table.insert(Values, k)
				end
			end
			print("Multidropdown changed:", table.concat(Values, ", "))
		end
	})
	mainSection:Button({
		Name = "Update Selection",
		Callback = function()
			Dropdown:UpdateSelection(4)
			MultiDropdown:UpdateSelection({ "Option 2", "Option 5" })
		end
	})
	mainSection:Divider()
	mainSection:Header({ Text = "Header #2" })
	mainSection:Paragraph({
		Header = "Paragraph",
		Body = "Paragraph body. Lorem ipsum odor amet, consectetuer adipiscing elit. Morbi tempus netus aliquet per velit est gravida."
	})
	mainSection:Label({ Text = "Label. Lorem ipsum odor amet, consectetuer adipiscing elit." })
	mainSection:SubLabel({ Text = "Sub-Label. Lorem ipsum odor amet, consectetuer adipiscing elit." })
	Window.onUnloaded(function()
		if rainbowConnection then
			rainbowConnection:Disconnect()
			rainbowConnection = nil
		end
		print("Unloaded!")
	end)
	mainTab:Select()
	return Window
end
return MacLib
