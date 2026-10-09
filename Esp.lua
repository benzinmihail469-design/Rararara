--[[
!! УСТАРЕВШИЙ РЕПОЗИТОРИЙ !! Пожалуйста, используйте новый репозиторий:
https://github.com/biggaboy212/Maclib/tree/main
]]

local MacLib = {}

--// Услуги
local TweenService = game:GetService("TweenService")
локальный RunService = игра:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

--// Переменные
локальный isStudio = RunService:IsStudio()
localLocalPlayer = Players.LocalPlayer

локальное состояние окна
локальный акрилРазмытие
local hasGlobalSetting

локальные вкладки = {}
local currentTabInstance = nil
local tabIndex = 0

локальные активы = {
	interFont = "rbxassetid://12187365364",
	userInfoBlurred = "rbxassetid://18824089198",
	toggleBackground = "rbxassetid://18772190202",
	togglerHead = "rbxassetid://18772309008",
	buttonImage = "rbxassetid://10709791437",
	searchIcon = "rbxassetid://86737463322606"
}

--// Функции
локальная функция Tween(instance, tweeninfo, propertytable)
	return TweenService:Create(instance, tweeninfo, propertytable)
конец

--// Функции библиотеки
функция MacLib:Window(Settings)
	local WindowFunctions = {}
	Если Settings.AcrylicBlur ≤ nil, то
		acrylicBlur = Settings.AcrylicBlur
	еще
		acrylicBlur = true
	конец

	локальная камера = рабочая область.Текущая камера
	local isMobile = UserInputService.TouchEnabled

	local macLib = Instance.new("ScreenGui")
	macLib.Name = "MacLib"
	macLib.ResetOnSpawn = false
	macLib.DisplayOrder = 100
	macLib.IgnoreGuiInset = true
	macLib.ScreenInsets = Enum.ScreenInsets.None
	macLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	macLib.Parent = (isStudio и LocalPlayer.PlayerGui) или game:GetService("CoreGui")

	локальные уведомления = Instance.new("Frame")
	notifications.Name = "Уведомления"
	notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notifications.BackgroundTransparency = 1
	notifications.BorderColor3 = Color3.fromRGB(0, 0, 0)
	notifications.BorderSizePixel = 0
	notifications.Size = UDim2.fromScale(1, 1)
	notifications.Parent = macLib
	notifications.ZIndex = 2

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

	local base = Instance.new("Frame")
	base.Name = "Base"
	base.AnchorPoint = Vector2.new(0.5, 0.5)
	base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	base.BackgroundTransparency = Settings.AcrylicBlur and 0.05 or 0
	base.BorderColor3 = Color3.fromRGB(0, 0, 0)
	base.BorderSizePixel = 0
	base.Position = UDim2.fromScale(0.5, 0.5)
	base.Size = Settings.Size or UDim2.fromOffset(868, 650)

	local baseUIScale = Instance.new("UIScale")
	baseUIScale.Name = "БасеUIScale"
	baseUIScale.Parent = base

	--// РђРІС‚РѕРјР°С‚РёС‡РµСЃРєР°СЏ РїРѕРґРѕРЅРє° СЂР°Р·РјРµСЂР° РїРѕРґ СЃРµРЅСЃРѕСЂРЅС‹Рµ СЌРєСЂР°РЅС‹
	локальная функция AutoScaleForMobile()
		если не base или не baseUIScale, то вернуть end
		local viewportSize = Camera.ViewportSize
		if viewportSize.X == 0 or viewportSize.Y == 0 then return end

		local targetSize = Settings.Size or UDim2.fromOffset(868, 650)
		local baseWidth = targetSize.X.Offset > 0 and targetSize.X.Offset or 868
		local baseHeight = targetSize.Y.Offset > 0 and targetSize.Y.Offset or 650

		local scaleX = (viewportSize.X * 0.92) / baseWidth
		local scaleY = (viewportSize.Y * 0.92) / baseHeight
		local finalScale = math.min(scaleX, scaleY)

		если isMobile или finalScale < 1, то
			baseUIScale.Scale = math.clamp(finalScale, 0.35, 1)
		еще
			baseUIScale.Scale = Settings.Scale or 1
		конец
	конец

	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(AutoScaleForMobile)
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

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sidebar.BackgroundTransparency = 1
	sidebar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.fromScale(-3.52e-08, 4.69e-08)
	sidebar.Size = UDim2.fromScale(0.325, 1)

	local divider = Instance.new("Frame")
	divider.Name = "Разделитель"
	divider.AnchorPoint = Vector2.new(1, 0)
	divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider.BackgroundTransparency = 0.9
	divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
	divider.BorderSizePixel = 0
	divider.Position = UDim2.fromScale(1, 0)
	divider.Size = UDim2.new(0, 1, 1, 0)
	divider.Parent = sidebar

	local windowControls = Instance.new("Frame")
	windowControls.Name = "WindowControls"
	windowControls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	windowControls.BackgroundTransparency = 1
	windowControls.BorderColor3 = Color3.fromRGB(0, 0, 0)
	windowControls.BorderSizePixel = 0
	windowControls.Size = UDim2.new(1, 0, 0, 31)

	локальные элементы управления = Instance.new("Frame")
	controls.Name = "Controls"
	controls.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
	controls.BackgroundTransparency = 1
	controls.BorderColor3 = Color3.fromRGB(0, 0, 0)
	controls.BorderSizePixel = 0
	controls.Size = UDim2.fromScale(1, 1)

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
		прозрачность = { включено = 0, отключено = 1 },
		strokeTransparency = 0.9,
	}

	local stroke = Instance.new("UIStroke")
	stroke.Name = "BaseUIStroke"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = windowControlSettings.strokeTransparency

	local exit = Instance.new("TextButton")
	exit.Name = "Выход"
	exit.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	exit.Text = ""
	exit.TextColor3 = Color3.fromRGB(0, 0, 0)
	exit.TextSize = 14
	exit.AutoButtonColor = false
	exit.BackgroundColor3 = Color3.fromRGB(250, 93, 86)
	exit.BorderColor3 = Color3.fromRGB(0, 0, 0)
	exit.BorderSizePixel = 0

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = exit

	exit.Parent = controls

	local minimize = Instance.new("TextButton")
	minimize.Name = "Minimize"
	minimize.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	minimize.Text = ""
	minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
	minimize.TextSize = 14
	minimize.AutoButtonColor = false
	minimize.BackgroundColor3 = Color3.fromRGB(252, 190, 57)
	minimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
	minimize.BorderSizePixel = 0
	minimize.LayoutOrder = 1
	
	local uICorner1 = Instance.new("UICorner")
	uICorner1.Name = "UICorner"
	uICorner1.CornerRadius = UDim.new(1, 0)
	uICorner1.Parent = minimize
	
	minimize.Parent = controls

	local maximize = Instance.new("TextButton")
	maximize.Name = "Maximize"
	maximize.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	maximize.Text = ""
	maximize.TextColor3 = Color3.fromRGB(0, 0, 0)
	maximize.TextSize = 14
	maximize.AutoButtonColor = false
	maximize.BackgroundColor3 = Color3.fromRGB(119, 174, 94)
	maximize.BorderColor3 = Color3.fromRGB(0, 0, 0)
	maximize.BorderSizePixel = 0
	maximize.LayoutOrder = 1

	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "UICorner"
	uICorner2.CornerRadius = UDim.new(1, 0)
	uICorner2.Parent = maximize

	maximize.Parent = controls
	
	локальная функция applyState(button, enabled)
		local size = enabled and windowControlSettings.sizes.enabled or windowControlSettings.sizes.disabled
		local transparency = enabled and windowControlSettings.transparencies.enabled or windowControlSettings.transparencies.disabled

		button.Size = size
		button.BackgroundTransparency = прозрачность
		button.Active = enabled
		button.Interactable = enabled

		for _, child in ipairs(button:GetChildren()) do
			если child:IsA("UIStroke") then
				child.Transparency = прозрачность
			конец
		конец
		если не включено, то
			stroke:Clone().Parent = button
		конец
	конец

	applyState(maximize, false)
	
	local controlsList = {exit, minimize}
	for _, button in pairs(controlsList) do
		local buttonName = button.Name
		local isEnabled = true

		Если Settings.DisabledWindowControls и table.find(Settings.DisabledWindowControls, buttonName), то
			isEnabled = false
		конец

		applyState(button, isEnabled)
	конец

	controls.Parent = windowControls

	local divider1 = Instance.new("Frame")
	divider1.Name = "Разделитель"
	divider1.AnchorPoint = Vector2.new(0, 1)
	divider1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider1.BackgroundTransparency = 0.9
	divider1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	divider1.BorderSizePixel = 0
	divider1.Position = UDim2.fromScale(0, 1)
	divider1.Size = UDim2.new(1, 0, 0, 1)
	divider1.Parent = windowControls

	windowControls.Parent = sidebar

	локальная информация = Instance.new("Frame")
	information.Name = "Информация"
	information.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	информация.ФонПрозрачность = 1
	information.BorderColor3 = Color3.fromRGB(0, 0, 0)
	information.BorderSizePixel = 0
	information.Position = UDim2.fromOffset(0, 31)
	information.Size = UDim2.new(1, 0, 0, 60)

	local divider2 = Instance.new("Frame")
	divider2.Name = "Разделитель"
	divider2.AnchorPoint = Vector2.new(0, 1)
	divider2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider2.BackgroundTransparency = 0.9
	divider2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	divider2.BorderSizePixel = 0
	divider2.Position = UDim2.fromScale(0, 1)
	divider2.Size = UDim2.new(1, 0, 0, 1)
	divider2.Parent = information

	local informationHolder = Instance.new("Frame")
	InformationHolder.Name = "ИнформационныйХолдер"
	informationHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	informationHolder.BackgroundTransparency = 1
	informationHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	informationHolder.BorderSizePixel = 0
	informationHolder.Size = UDim2.fromScale(1, 1)

	local informationHolderUIPadding = Instance.new("UIPadding")
	informationHolderUIPadding.Name = "InformationHolderUIPadding"
	informationHolderUIPadding.PaddingBottom = UDim.new(0, 10)
	informationHolderUIPadding.PaddingLeft = UDim.new(0, 23)
	informationHolderUIPadding.PaddingRight = UDim.new(0, 22)
	informationHolderUIPadding.PaddingTop = UDim.new(0, 10)
	informationHolderUIPadding.Parent = informationHolder

	local globalSettingsButton = Instance.new("ImageButton")
	globalSettingsButton.Name = "GlobalSettingsButton"
	globalSettingsButton.Image = "rbxassetid://18767849817"
	globalSettingsButton.ImageTransparency = 0,4
	globalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
	globalSettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	globalSettingsButton.BackgroundTransparency = 1
	globalSettingsButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	globalSettingsButton.BorderSizePixel = 0
	globalSettingsButton.Position = UDim2.fromScale(1, 0.5)
	globalSettingsButton.Size = UDim2.fromOffset(15, 15)
	globalSettingsButton.Parent = informationHolder

	локальная функция ChangeGlobalSettingsButtonState(State)
		если State == "Default", то
			Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Прозрачность изображения = 0,4
			}):Играть()
		elseif State == "Hover" then
			Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Прозрачность изображения = 0,2
			}):Играть()
		конец
	конец

	globalSettingsButton.MouseEnter:Connect(function()
		ChangeGlobalSettingsButtonState("Hover")
	конец)
	globalSettingsButton.MouseLeave:Connect(function()
		ChangeGlobalSettingsButtonState("Default")
	конец)

	локальный titleFrame = Instance.new("Frame")
	titleFrame.Name = "Рамка заголовка"
	titleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	titleFrame.BackgroundTransparency = 1
	titleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	titleFrame.BorderSizePixel = 0
	titleFrame.Size = UDim2.fromScale(1, 1)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.FontFace = Font.new(
		assets.interFont,
		Enum.FontWeight.SemiBold,
		Enum.FontStyle.Normal
	)
	title.Text = Settings.Title
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.RichText = true
	title.TextSize = 20
	title.TextTransparency = 0.2
	title.TextTruncate = Enum.TextTruncate.SplitWord
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Top
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0
	title.Size = UDim2.new(1, -20, 0, 0)
	title.Parent = titleFrame

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.FontFace = Font.new(
		assets.interFont,
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	subtitle.RichText = true
	subtitle.Text = Settings.Subtitle
	subtitle.RichText = true
	subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.TextSize = 12
	subtitle.TextTransparency = 0.7
	subtitle.TextTruncate = Enum.TextTruncate.SplitWord
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextYAlignment = Enum.TextYAlignment.Top
	subtitle.AutomaticSize = Enum.AutomaticSize.Y
	subtitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.BackgroundTransparency = 1
	subtitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
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

	titleFrame.Parent = informationHolder

	informationHolder.Parent = information

	информация.Родитель = боковая панель

	local sidebarGroup = Instance.new("Frame")
	sidebarGroup.Name = "SidebarGroup"
	sidebarGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sidebarGroup.BackgroundTransparency = 1
	sidebarGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
	sidebarGroup.BorderSizePixel = 0
	sidebarGroup.Position = UDim2.fromOffset(0, 91)
	sidebarGroup.Size = UDim2.new(1, 0, 1, -91)

	local userInfo = Instance.new("Frame")
	userInfo.Name = "UserInfo"
	userInfo.AnchorPoint = Vector2.new(0, 1)
	userInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	userInfo.BackgroundTransparency = 1
	userInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	userInfo.BorderSizePixel = 0
	userInfo.Position = UDim2.fromScale(0, 1)
	userInfo.Size = UDim2.new(1, 0, 0, 107)

	local informationGroup = Instance.new("Frame")
	informationGroup.Name = "InformationGroup"
	informationGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	informationGroup.BackgroundTransparency = 1
	informationGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
	informationGroup.BorderSizePixel = 0
	informationGroup.Size = UDim2.fromScale(1, 1)

	local informationGroupUIPadding = Instance.new("UIPadding")
	informationGroupUIPadding.Name = "InformationGroupUIPadding"
	informationGroupUIPadding.PaddingBottom = UDim.new(0, 17)
	informationGroupUIPadding.PaddingLeft = UDim.new(0, 25)
	informationGroupUIPadding.Parent = informationGroup

	local informationGroupUIListLayout = Instance.new("UIListLayout")
	informationGroupUIListLayout.Name = "InformationGroupUIListLayout"
	InformationGroupUIListLayout.FillDirection = Enum.FillDirection.Horizontal
	informationGroupUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	informationGroupUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	informationGroupUIListLayout.Parent = informationGroup

	local userId = LocalPlayer.UserId
	local thumbType = Enum.ThumbnailType.AvatarBust
	local thumbSize = Enum.ThumbnailSize.Size48x48
	local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	локальный снимок экрана = Instance.new("ImageLabel")
	headshot.Name = "Headshot"
	headshot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	headshot.BackgroundTransparency = 1
	headshot.BorderColor3 = Color3.fromRGB(0, 0, 0)
	headshot.BorderSizePixel = 0
	headshot.Size = UDim2.fromOffset(32, 32)
	headshot.Image = (isReady and headshotImage) or "rbxassetid://0"

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

	headshot.Parent = informationGroup

	local userAndDisplayFrame = Instance.new("Frame")
	userAndDisplayFrame.Name = "UserAndDisplayFrame"
	userAndDisplayFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	userAndDisplayFrame.BackgroundTransparency = 1
	userAndDisplayFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	userAndDisplayFrame.BorderSizePixel = 0
	userAndDisplayFrame.LayoutOrder = 1
	userAndDisplayFrame.Size = UDim2.new(1, -42, 0, 32)

	local displayName = Instance.new("TextLabel")
	displayName.Name = "DisplayName"
	displayName.FontFace = Font.new(
		assets.interFont,
		Enum.FontWeight.SemiBold,
		Enum.FontStyle.Normal
	)
	displayName.Text = LocalPlayer.DisplayName
	displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
	displayName.TextSize = 13
	displayName.TextTransparency = 0.2
	displayName.TextTruncate = Enum.TextTruncate.SplitWord
	displayName.TextXAlignment = Enum.TextXAlignment.Left
	displayName.TextYAlignment = Enum.TextYAlignment.Top
	displayName.AutomaticSize = Enum.AutomaticSize.XY
	displayName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	displayName.BackgroundTransparency = 1
	displayName.BorderColor3 = Color3.fromRGB(0, 0, 0)
	displayName.BorderSizePixel = 0
	displayName.Parent = userAndDisplayFrame
	displayName.Size = UDim2.fromScale(1,0)

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
	username.Name = "Имя пользователя"
	username.FontFace = Font.new(
		assets.interFont,
		Enum.FontWeight.SemiBold,
		Enum.FontStyle.Normal
	)
	username.Text = "@"..LocalPlayer.Name
	имя пользователя.TextColor3 = Color3.fromRGB(255, 255, 255)
	username.TextSize = 12
	username.TextTransparency = 0.8
	username.TextTruncate = Enum.TextTruncate.SplitWord
	username.TextXAlignment = Enum.TextXAlignment.Left
	username.TextYAlignment = Enum.TextYAlignment.Top
	username.AutomaticSize = Enum.AutomaticSize.XY
	username.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	username.BackgroundTransparency = 1
	username.BorderColor3 = Color3.fromRGB(0, 0, 0)
	username.BorderSizePixel = 0
	username.LayoutOrder = 1
	username.Parent = userAndDisplayFrame
	username.Size = UDim2.fromScale(1,0)

	userAndDisplayFrame.Parent = informationGroup

	informationGroup.Parent = userInfo

	local userInfoUIPadding = Instance.new("UIPadding")
	userInfoUIPadding.Name = "UserInfoUIPadding"
	userInfoUIPadding.PaddingLeft = UDim.new(0, 10)
	userInfoUIPadding.PaddingRight = UDim.new(0, 10)
	userInfoUIPadding.Parent = userInfo

	userInfo.Parent = sidebarGroup

	local sidebarGroupUIPadding = Instance.new("UIPadding")
	sidebarGroupUIPadding.Name = "SidebarGroupUIPadding"
	sidebarGroupUIPadding.PaddingLeft = UDim.new(0, 10)
	sidebarGroupUIPadding.PaddingRight = UDim.new(0, 10)
	sidebarGroupUIPadding.PaddingTop = UDim.new(0, 31)
	sidebarGroupUIPadding.Parent = sidebarGroup

	local tabSwitchers = Instance.new("Frame")
	tabSwitchers.Name = "TabSwitchers"
	tabSwitchers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tabSwitchers.BackgroundTransparency = 1
	tabSwitchers.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tabSwitchers.BorderSizePixel = 0
	tabSwitchers.Size = UDim2.new(1, 0, 1, -107)

	local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
	tabSwitchersScrollingFrame.Name = "TabSwitchersScrollingFrame"
	tabSwitchersScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabSwitchersScrollingFrame.BottomImage = ""
	tabSwitchersScrollingFrame.CanvasSize = UDim2.new()
	tabSwitchersScrollingFrame.ScrollBarImageTransparency = 0.8
	tabSwitchersScrollingFrame.ScrollBarThickness = 1
	tabSwitchersScrollingFrame.TopImage = ""
	tabSwitchersScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tabSwitchersScrollingFrame.BackgroundTransparency = 1
	tabSwitchersScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tabSwitchersScrollingFrame.BorderSizePixel = 0
	tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)

	local tabSwitchersScrollingFrameUIListLayout = Instance.new("UIListLayout")
	tabSwitchersScrollingFrameUIListLayout.Name = "TabSwitchersScrollingFrameUIListLayout"
	tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, 17)
	tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame

	local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
	tabSwitchersScrollingFrameUIPadding.Name = "TabSwitchersScrollingFrameUIPadding"
	tabSwitchersScrollingFrameUIPadding.PaddingTop = UDim.new(0, 2)
	tabSwitchersScrollingFrameUIPadding.Parent = tabSwitchersScrollingFrame

	tabSwitchersScrollingFrame.Parent = tabSwitchers

	tabSwitchers.Parent = sidebarGroup

	sidebarGroup.Parent = sidebar

	sidebar.Parent = base

	локальное содержимое = Instance.new("Frame")
	content.Name = "Content"
	content.AnchorPoint = Vector2.new(1, 0)
	content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	content.BackgroundTransparency = 1
	content.BorderColor3 = Color3.fromRGB(0, 0, 0)
	content.BorderSizePixel = 0
	content.Position = UDim2.fromScale(1, 4.69e-08)
	content.Size = UDim2.fromScale(0.675, 1)

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topbar.BackgroundTransparency = 1
	topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(1, 0, 0, 63)

	local divider4 = Instance.new("Frame")
	divider4.Name = "Разделитель"
	divider4.AnchorPoint = Vector2.new(0, 1)
	divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider4.BackgroundTransparency = 0.9
	divider4.BorderColor3 = Color3.fromRGB(0, 0, 0)
	divider4.BorderSizePixel = 0
	divider4.Position = UDim2.fromScale(0, 1)
	divider4.Size = UDim2.new(1, 0, 0, 1)
	divider4.Parent = topbar

	локальные элементы = Instance.new("Frame")
	elements.Name = "Elements"
	elements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	elements.BackgroundTransparency = 1
	elements.BorderColor3 = Color3.fromRGB(0, 0, 0)
	elements.BorderSizePixel = 0
	elements.Size = UDim2.fromScale(1, 1)

	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.Name = "UIPadding"
	uIPadding2.PaddingLeft = UDim.new(0, 20)
	uIPadding2.PaddingRight = UDim.new(0, 20)
	uIPadding2.Parent = elements

	local moveIcon = Instance.new("ImageButton")
	moveIcon.Name = "MoveIcon"
	moveIcon.Image = "rbxassetid://10734900011"
	moveIcon.ImageTransparency = 0.5
	moveIcon.AnchorPoint = Vector2.new(1, 0.5)
	moveIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	moveIcon.BackgroundTransparency = 1
	moveIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	moveIcon.BorderSizePixel = 0
	moveIcon.Position = UDim2.fromScale(1, 0.5)
	moveIcon.Size = UDim2.fromOffset(15, 15)
	moveIcon.Parent = elements
	moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1
	
	local interact = Instance.new("TextButton")
	interact.Name = "Interact"
	interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	interact.Text = ""
	interact.TextColor3 = Color3.fromRGB(0, 0, 0)
	interact.TextSize = 14
	interact.AnchorPoint = Vector2.new(0.5, 0.5)
	interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	interact.BackgroundTransparency = 1
	interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
	interact.BorderSizePixel = 0
	interact.Position = UDim2.fromScale(0.5, 0.5)
	interact.Size = UDim2.fromOffset(30, 30)
	interact.Parent = moveIcon

	локальная функция ChangemoveIconState(State)
		если State == "Default", то
			Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Прозрачность изображения = 0,5
			}):Играть()
		elseif State == "Hover" then
			Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Прозрачность изображения = 0,2
			}):Играть()
		конец
	конец

	interact.MouseEnter:Connect(function()
		ChangemoveIconState("Hover")
	конец)
	interact.MouseLeave:Connect(function()
		ChangemoveIconState("Default")
	конец)

	--// РђРґР°РїС‚РёСЂРѕРІР°РЅРЅР°СЏ Р»РѕРіРёРєР° РїРµСЂРµС‚Р°СЃРєРёРІР°РЅРёСЏ РїРѕРґ СЃРμРЅСЃРѕСЂРЅС‹Р№ РІРІРѕРґ на UIScale
	local dragging_ = false
	локальный перетаскивающий ввод
	локальный dragStart
	локальная стартовая позиция

	локальная функция update(input)
		local delta = input.Position - dragStart
		local currentScale = (baseUIScale and baseUIScale.Scale > 0) and baseUIScale.Scale or 1
		
		-- РљРѕСЂСЂРµРєС‚РёСЂСѓРµРј СЃРјРµС‰РµРЅРёРµ СЃ СѓС‡С'С‚РѕРј С‚РµРєСѓС‰РµРіРѕ Доступ к UIScale
		local adjustedDeltaX = delta.X / currentScale
		local adjustedDeltaY = delta.Y / currentScale
		base.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + adjustedDeltaX,
			startPos.Y.Scale,
			startPos.Y.Offset + скорректированнаяDeltaY
		)
	конец

	локальная функция onDragStart(input)
		если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
			dragging_ = true
			dragStart = input.Position
			startPos = base.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging_ = false
				конец
			конец)
		конец
	конец

	локальная функция onDragUpdate(input)
		Если dragging_ и (input.UserInputType == Enum.UserInputType.MouseMovement или input.UserInputType == Enum.UserInputType.Touch), то
			dragInput = input
		конец
	конец

	если Settings.DragStyle не равно 1, то
		interact.InputBegan:Connect(function(input)
			если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
				onDragStart(input)
			конец
		конец)

		interact.InputChanged:Connect(onDragUpdate)

		UserInputService.InputChanged:Connect(function(input)
			если input == dragInput и dragging_ тогда
				обновить(вход)
			конец
		конец)

		interact.InputEnded:Connect(function(input)
			если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
				dragging_ = false
			конец
		конец)
	elseif Settings.DragStyle == 2 then
		base.InputBegan:Connect(function(input)
			если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
				onDragStart(input)
			конец
		конец)

		base.InputChanged:Connect(onDragUpdate)

		UserInputService.InputChanged:Connect(function(input)
			если input == dragInput и dragging_ тогда
				обновить(вход)
			конец
		конец)

		base.InputEnded:Connect(function(input)
			если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
				dragging_ = false
			конец
		конец)
	конец

	local currentTab = Instance.new("TextLabel")
	currentTab.Name = "CurrentTab"
	currentTab.FontFace = Font.new(
		assets.interFont,
		Enum.FontWeight.SemiBold,
		Enum.FontStyle.Normal
	)
	currentTab.RichText = true
	currentTab.Text = "Tab"
	currentTab.RichText = true
	currentTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentTab.TextSize = 15
	currentTab.TextTransparency = 0.5
	currentTab.TextTruncate = Enum.TextTruncate.SplitWord
	currentTab.TextXAlignment = Enum.TextXAlignment.Left
	currentTab.TextYAlignment = Enum.TextYAlignment.Top
	currentTab.AnchorPoint = Vector2.new(0, 0.5)
	currentTab.AutomaticSize = Enum.AutomaticSize.Y
	currentTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	currentTab.BackgroundTransparency = 1
	currentTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
	currentTab.BorderSizePixel = 0
	currentTab.Position = UDim2.fromScale(0, 0.5)
	currentTab.Size = UDim2.fromScale(0.9, 0)
	currentTab.Parent = elements

	elements.Parent = topbar

	topbar.Parent = content

	content.Parent = base

	local globalSettings = Instance.new("Frame")
	globalSettings.Name = "GlobalSettings"
	globalSettings.AutomaticSize = Enum.AutomaticSize.XY
	globalSettings.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	globalSettings.BorderColor3 = Color3.fromRGB(0, 0, 0)
	globalSettings.BorderSizePixel = 0
	globalSettings.Position = UDim2.fromScale(0.298, 0.104)

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
	globalSettings.Parent = base
	base.Parent = macLib

	function WindowFunctions:UpdateTitle(NewTitle)
		title.Text = NewTitle
	конец

	function WindowFunctions:UpdateSubtitle(NewSubtitle)
		subtitle.Text = NewSubtitle
	конец

	локальное зависание
	local toggled = globalSettingsUIScale.Scale == 1 and true or false
	локальная функция toggle()
		если не включено, то
			local intween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Масштаб = 1
			})
			intween:Play()
			intween.Completed:Wait()
			toggled = true
		иначе если переключено тогда
			local outtween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Масштаб = 0
			})
			outtween:Play()
			outtween.Completed:Wait()
			toggled = false
		конец
	конец
	globalSettingsButton.MouseButton1Click:Connect(function()
		if not hasGlobalSetting then return end
		переключать()
	конец)
	globalSettings.MouseEnter:Connect(function()
		hovering = true
	конец)
	globalSettings.MouseLeave:Connect(function()
		hovering = false
	конец)
	UserInputService.InputEnded:Connect(function(inp)
		Если inp.UserInputType == Enum.UserInputType.MouseButton1 и кнопка переключена, а не находится под курсором, то
			переключать()
		конец
	конец)

	local BlurTarget = base

	local HS = game:GetService('HttpService')
	локальная камера = рабочая область.ТекущаяКамера
	local MTREL = "Стекло"
	локальные привязки = {}
	local wedgeguid = HS:GenerateGUID(true)

	локальная глубина резкости

	for _,v in pairs(game:GetService("Lighting"):GetChildren()) do
		if not v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
			DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
			DepthOfField.FarIntensity = 0
			DepthOfField.FocusDistance = 51.6
			DepthOfField.InFocusRadius = 50
			DepthOfField.NearIntensity = 1
			DepthOfField.Name = HS:GenerateGUID(true)
			DepthOfField:AddTag()."
		elseif v:IsA("DepthOfFieldEffect") and v:HasTag()" then
			Глубина резкости = v
		конец
	конец

	если не глубина резкости, то
		DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
		DepthOfField.FarIntensity = 0
		DepthOfField.FocusDistance = 51.6
		DepthOfField.InFocusRadius = 50
		DepthOfField.NearIntensity = 1
		DepthOfField.Name = HS:GenerateGUID(true)
		DepthOfField:AddTag()."
	конец

	local frame = Instance.new('Frame')
	frame.Parent = BlurTarget
	frame.Size = UDim2.new(0.97, 0, 0.97, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Name = HS:GenerateGUID(true)

	делать
		локальная функция IsNotNaN(x)
			return x == x
		конец
		local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		пока не продолжать делать
			RunService.RenderStepped:wait()
			continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		конец
	конец

	local DrawQuad; do
		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
		локальный sz = 0.2

		локальная функция DrawTriangle(v1, v2, v3, p0, p1)
			локальный s1 = (v1 - v2).величина
			локальный s2 = (v2 - v3).величина
			локальный s3 = (v3 - v1).величина
			local smax = max(s1, s2, s3)
			местный A, B, C
			если s1 == smax, то
				A, B, C = v1, v2, v3
			иначе, если s2 == smax тогда
				A, B, C = v2, v3, v1
			elseif s3 == smax then
				A, B, C = v3, v1, v2
			конец

			локальный параграф = ( (BA).x*(CA).x + (BA).y*(CA).y + (BA).z*(CA).z ) / (AB).величина
			локальный перп = sqrt((CA).величина^2 - пара*пара)
			локальный dif_para = (A - B).величина - пункт

			local st = CFrame.new(B, A)
			локальный za = CFrame.Angles(pi/2,0,0)

			локальный cf0 = ст

			local Top_Look = (cf0 * za).lookVector
			local Mid_Point = A + CFrame.new(A, B).lookVector * para
			local Needed_Look = CFrame.new(Mid_Point, C).lookVector
			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

			local ac = CFrame.Angles(0, 0, acos(dot))

			cf0 = cf0 * ac
			если ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 тогда
				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
			конец
			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
			если ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 тогда
				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
			конец
			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

			если не p0, то
				p0 = Instance.new('Part')
				p0.FormFactor = 'Custom'
				p0.TopSurface = 0
				p0.BottomSurface = 0
				p0.Anchored = true
				p0.CanCollide = false
				p0.CastShadow = false
				p0.Материал = MTREL
				p0.Size = Vector3.new(sz, sz, sz)
				p0.Name = HS:GenerateGUID(true)
				локальная сетка = Instance.new('SpecialMesh', p0)
				mesh.MeshType = 2
				mesh.Name = wedgeguid
			конец
			p0[wedgeguid].Scale = Vector3.new(0, perp/sz, para/sz)
			p0.CFrame = cf0

			если не p1, то
				p1 = p0:clone()
			конец
			p1[wedgeguid].Scale = Vector3.new(0, perp/sz, dif_para/sz)
			p1.CFrame = cf1

			возвращаем p0, p1
		конец

		функция DrawQuad(v1, v2, v3, v4, части)
			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
		конец
	конец

	если binds[frame] then
		return binds[frame].parts
	конец

	локальные части = {}

	локальные родители = {}
	делать
		локальная функция add(child)
			если child:IsA'GuiObject' then
				родители[#родителей + 1] = ребенок
				добавить(child.Parent)
			конец
		конец
		добавить(фрейм)
	конец

	локальная функция IsVisible(instance)
		пока экземпляр делает
			если instance:IsA("GuiObject") then
				если не instance.Visible, то
					вернуть false
				конец
			elseif instance:IsA("ScreenGui") then
				Если не включен экземпляр, то
					вернуть false
				конец
				перерыв
			конец
			instance = instance.Parent
		конец
		вернуть true
	конец

	локальная функция UpdateOrientation(fetchProps)
		if not IsVisible(frame) or not acrylicBlur then
			for _, pt in pairs(parts) do
				pt.Parent = nil
				DepthOfField.Enabled = false
			конец
			возвращаться
		конец
		DepthOfField.Enabled = true
		локальные свойства = {
			Прозрачность = 0,98;
			BrickColor = BrickColor.new('Institutional white');
		}
		local zIndex = 1 - 0.05*frame.ZIndex

		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		делать
			локальное гниение = 0;
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			конец
			если rot ≤ 0 и rot%180 ≤ 0, то
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				локальный вектор = tl
				tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
				tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
				bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
				br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
			конец
		конец
		DrawQuad(
			camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
			camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
			camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
			camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
			детали
		)
		если fetchProps тогда
			for _, pt in pairs(parts) do
				pt.Parent = camera
			конец
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(parts) do
					pt[propName] = propValue
				конец
			конец
		конец
	конец

	UpdateOrientation(true)

	RunService.RenderStepped:connect(UpdateOrientation)

	function WindowFunctions:GlobalSetting(Settings)
		hasGlobalSetting = true
		local GlobalSettingFunctions = {}
		local globalSetting = Instance.new("TextButton")
		globalSetting.Name = "GlobalSetting"
		globalSetting.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		globalSetting.Text = ""
		globalSetting.TextColor3 = Color3.fromRGB(0, 0, 0)
		globalSetting.TextSize = 14
		globalSetting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		globalSetting.BackgroundTransparency = 1
		globalSetting.BorderColor3 = Color3.fromRGB(0, 0, 0)
		globalSetting.BorderSizePixel = 0
		globalSetting.Size = UDim2.fromOffset(200, 30)

		local globalSettingToggleUIPadding = Instance.new("UIPadding")
		globalSettingToggleUIPadding.Name = "GlobalSettingToggleUIPadding"
		globalSettingToggleUIPadding.PaddingLeft = UDim.new(0, 15)
		globalSettingToggleUIPadding.Parent = globalSetting

		local settingName = Instance.new("TextLabel")
		settingName.Name = "SettingName"
		settingName.FontFace = Font.new(
			assets.interFont,
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		)
		settingName.Text = Settings.Name
		settingName.RichText = true
		settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
		settingName.TextSize = 13
		settingName.TextTransparency = 0.5
		settingName.TextTruncate = Enum.TextTruncate.SplitWord
		settingName.TextXAlignment = Enum.TextXAlignment.Left
		settingName.TextYAlignment = Enum.TextYAlignment.Top
		settingName.AnchorPoint = Vector2.new(0, 0.5)
		settingName.AutomaticSize = Enum.AutomaticSize.Y
		settingName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		settingName.BackgroundTransparency = 1
		settingName.BorderColor3 = Color3.fromRGB(0, 0, 0)
		settingName.BorderSizePixel = 0
		settingName.Position = UDim2.fromScale(1.3e-07, 0.5)
		settingName.Size = UDim2.new(1,-40,0,0)
		settingName.Parent = globalSetting

		local globalSettingToggleUIListLayout = Instance.new("UIListLayout")
		globalSettingToggleUIListLayout.Name = "GlobalSettingToggleUIListLayout"
		globalSettingToggleUIListLayout.Padding = UDim.new(0, 10)
		globalSettingToggleUIListLayout.FillDirection = Enum.FillDirection.Horizontal
		globalSettingToggleUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		globalSettingToggleUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		globalSettingToggleUIListLayout.Parent = globalSetting

		локальная галочка = Instance.new("TextLabel")
		checkmark.Name = "Checkmark"
		checkmark.FontFace = Font.new(
			assets.interFont,
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		)
		checkmark.Text = "вњ“"
		checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
		checkmark.TextSize = 13
		checkmark.TextTransparency = 1
		checkmark.TextXAlignment = Enum.TextXAlignment.Left
		checkmark.TextYAlignment = Enum.TextYAlignment.Top
		checkmark.AnchorPoint = Vector2.new(0, 0.5)
		checkmark.AutomaticSize = Enum.AutomaticSize.Y
		checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		checkmark.BackgroundTransparency = 1
		checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
		checkmark.BorderSizePixel = 0
		checkmark.LayoutOrder = -1
		checkmark.Position = UDim2.fromScale(1.3e-07, 0.5)
		checkmark.Size = UDim2.fromOffset(-10, 0)
		checkmark.Parent = globalSetting

		globalSetting.Parent = globalSettings

		локальные настройки твитов = {
			длительность = 0,2,
			easingStyle = Enum.EasingStyle.Quint,
			прозрачностьIn = 0,2,
			transparencyOut = 0.5,
			checkSizeIncrease = 12,
			checkSizeDecrease = -globalSettingToggleUIListLayout.Padding.Offset,
			waitTime = 1
		}

		локальные анимации = {
			checkIn = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
				Размер = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
			}),
			checkOut = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
				Размер = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
			}),
			nameIn = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
				TextTransparency = tweensettings.transparencyIn
			}),
			nameOut = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
				TextTransparency = tweensettings.transparencyOut
			})
		}

		локальная функция Toggle(State)
			если не штат, то
				tweens.checkOut:Play()
				tweens.nameOut:Play()
				checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					Если checkmark.AbsoluteSize.X <= 0, то
						checkmark.TextTransparency = 1
					конец
				конец)
			еще
				tweens.checkIn:Play()
				tweens.nameIn:Play()
				checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					если checkmark.AbsoluteSize.X > 0, то
						checkmark.TextTransparency = 0
					конец
				конец)
			конец
		конец

		local toggled = Settings.Default
		Toggle(toggled)

		globalSetting.MouseButton1Click:Connect(function()
			включено = не включено
			Toggle(toggled)

			task.spawn(function()
				если Settings.Callback тогда
					Настройки.Обратный вызов (отключено)
				конец
			конец)
		конец)

		функция GlobalSettingFunctions:UpdateName(NewName)
			settingName.Text = NewName
		конец

		функция GlobalSettingFunctions:UpdateState(NewState)
			Toggle(NewState)
			toggled = NewState
			task.spawn(function()
				если Settings.Callback тогда
					Настройки.Обратный вызов (отключено)
				конец
			конец)
		конец

		return GlobalSettingFunctions
	конец

	функция WindowFunctions:TabGroup()
		local SectionFunctions = {}

		local tabGroup = Instance.new("Frame")
		tabGroup.Name = "Section"
		tabGroup.AutomaticSize = Enum.AutomaticSize.Y
		tabGroup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabGroup.BackgroundTransparency = 1
		tabGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
		tabGroup.BorderSizePixel = 0
		tabGroup.Size = UDim2.fromScale(1, 0)

		local divider3 = Instance.new("Frame")
		divider3.Name = "Разделитель"
		divider3.AnchorPoint = Vector2.new(0.5, 1)
		divider3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		divider3.BackgroundTransparency = 0.9
		divider3.BorderColor3 = Color3.fromRGB(0, 0, 0)
		divider3.BorderSizePixel = 0
		divider3.Position = UDim2.fromScale(0.5, 1)
		divider3.Size = UDim2.new(1, -21, 0, 1)
		divider3.Parent = tabGroup

		local sectionTabSwitchers = Instance.new("Frame")
		sectionTabSwitchers.Name = "SectionTabSwitchers"
		sectionTabSwitchers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sectionTabSwitchers.BackgroundTransparency = 1
		sectionTabSwitchers.BorderColor3 = Color3.fromRGB(0, 0, 0)
		sectionTabSwitchers.BorderSizePixel = 0
		sectionTabSwitchers.Size = UDim2.fromScale(1, 1)

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

		sectionTabSwitchers.Parent = tabGroup
		tabGroup.Parent = tabSwitchersScrollingFrame

		функция SectionFunctions:Tab(Settings)
			local TabFunctions = {}
			local tabSwitcher = Instance.new("TextButton")
			tabSwitcher.Name = "TabSwitcher"
			tabSwitcher.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			tabSwitcher.Text = ""
			tabSwitcher.TextColor3 = Color3.fromRGB(0, 0, 0)
			tabSwitcher.TextSize = 14
			tabSwitcher.AutoButtonColor = false
			tabSwitcher.AnchorPoint = Vector2.new(0.5, 0)
			tabSwitcher.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			tabSwitcher.BackgroundTransparency = 1
			tabSwitcher.BorderColor3 = Color3.fromRGB(0, 0, 0)
			tabSwitcher.BorderSizePixel = 0
			tabSwitcher.Position = UDim2.fromScale(0.5, 0)
			tabSwitcher.Size = UDim2.new(1, -21, 0, 40)

			tabIndex += 1
			tabSwitcher.LayoutOrder = tabIndex

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

			если Settings.Image тогда
				local tabImage = Instance.new("ImageLabel")
				tabImage.Name = "TabImage"
				tabImage.Image = Settings.Image
				tabImage.ImageTransparency = 0.4
				tabImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				tabImage.BackgroundTransparency = 1
				tabImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
				tabImage.BorderSizePixel = 0
				tabImage.Size = UDim2.fromOffset(16, 16)
				tabImage.Parent = tabSwitcher
			конец

			local tabSwitcherName = Instance.new("TextLabel")
			tabSwitcherName.Name = "TabSwitcherName"
			tabSwitcherName.FontFace = Font.new(
				assets.interFont,
				Enum.FontWeight.SemiBold,
				Enum.FontStyle.Normal
			)
			tabSwitcherName.Text = Settings.Name
			tabSwitcherName.RichText = true
			tabSwitcherName.TextColor3 = Color3.fromRGB(255, 255, 255)
			tabSwitcherName.TextSize = 16
			tabSwitcherName.TextTransparency = 0.4
			tabSwitcherName.TextTruncate = Enum.TextTruncate.SplitWord
			tabSwitcherName.TextXAlignment = Enum.TextXAlignment.Left
			tabSwitcherName.TextYAlignment = Enum.TextYAlignment.Top
			tabSwitcherName.AutomaticSize = Enum.AutomaticSize.Y
			tabSwitcherName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			tabSwitcherName.BackgroundTransparency = 1
			tabSwitcherName.BorderColor3 = Color3.fromRGB(0, 0, 0)
			tabSwitcherName.BorderSizePixel = 0
			tabSwitcherName.Size = UDim2.fromScale(1, 0)
			tabSwitcherName.Parent = tabSwitcher
			tabSwitcherName.LayoutOrder = 1

			local tabSwitcherUIPadding = Instance.new("UIPadding")
			tabSwitcherUIPadding.Name = "TabSwitcherUIPadding"
			tabSwitcherUIPadding.PaddingLeft = UDim.new(0, 24)
			tabSwitcherUIPadding.PaddingRight = UDim.new(0, 35)
			tabSwitcherUIPadding.PaddingTop = UDim.new(0, 1)
			tabSwitcherUIPadding.Parent = tabSwitcher

			tabSwitcher.Parent = sectionTabSwitchers

			local elements1 = Instance.new("Frame")
			elements1.Name = "Elements"
			elements1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elements1.BackgroundTransparency = 1
			elements1.BorderColor3 = Color3.fromRGB(0, 0, 0)
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
			elementsScrolling.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			elementsScrolling.BackgroundTransparency = 1
			elementsScrolling.BorderColor3 = Color3.fromRGB(0, 0, 0)
			elementsScrolling.BorderSizePixel = 0
			elementsScrolling.Size = UDim2.fromScale(1, 1)

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
			left.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			left.BackgroundTransparency = 1
			left.BorderColor3 = Color3.fromRGB(0, 0, 0)
			left.BorderSizePixel = 0
			left.Position = UDim2.fromScale(0.512, 0)
			left.Size = UDim2.new(0.5, -10, 0, 0)

			local leftUIListLayout = Instance.new("UIListLayout")
			leftUIListLayout.Name = "LeftUIListLayout"
			leftUIListLayout.Padding = UDim.new(0, 15)
			leftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			leftUIListLayout.Parent = left

			left.Parent = elementsScrolling

			local right = Instance.new("Frame")
			right.Name = "Right"
			right.AutomaticSize = Enum.AutomaticSize.Y
			right.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			right.BackgroundTransparency = 1
			right.BorderColor3 = Color3.fromRGB(0, 0, 0)
			right.BorderSizePixel = 0
			right.LayoutOrder = 1
			right.Position = UDim2.fromScale(0.512, 0)
			right.Size = UDim2.new(0.5, -10, 0, 0)

			local rightUIListLayout = Instance.new("UIListLayout")
			rightUIListLayout.Name = "RightUIListLayout"
			rightUIListLayout.Padding = UDim.new(0, 15)
			rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rightUIListLayout.Parent = right

			right.Parent = elementsScrolling

			elementsScrolling.Parent = elements1

			функция TabFunctions:Section(Settings)
				local SectionFunctions = {}
				локальный раздел = Instance.new("Frame")
				section.Name = "Section"
				section.AutomaticSize = Enum.AutomaticSize.Y
				section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				section.BackgroundTransparency = 0.98
				section.BorderColor3 = Color3.fromRGB(0, 0, 0)
				section.BorderSizePixel = 0
				section.Position = UDim2.fromScale(0, 6.78e-08)
				section.Size = UDim2.fromScale(1, 0)
				section.Parent = Settings.Side == "Left" and left or right

				local sectionUICorner = Instance.new("UICorner")
				sectionUICorner.Name = "SectionUICorner"
				sectionUICorner.Parent = section

				local sectionUIStroke = Instance.new("UIStroke")
				sectionUIStroke.Name = "SectionUIStroke"
				sectionUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				sectionUIStroke.Color = Color3.fromRGB(255, 255, 255)
				sectionUIStroke.Transparency = 0.95
				sectionUIStroke.Parent = section

				local sectionUIListLayout = Instance.new("UIListLayout")
				sectionUIListLayout.Name = "SectionUIListLayout"
				sectionUIListLayout.Padding = UDim.new(0, 10)
				sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				sectionUIListLayout.Parent = section

				local sectionUIPadding = Instance.new("UIPadding")
				sectionUIPadding.Name = "SectionUIPadding"
				sectionUIPadding.PaddingBottom = UDim.new(0, 20)
				sectionUIPadding.PaddingLeft = UDim.new(0, 20)
				sectionUIPadding.PaddingRight = UDim.new(0, 18)
				sectionUIPadding.PaddingTop = UDim.new(0, 22)
				sectionUIPadding.Parent = section

				function SectionFunctions:Button(Settings)
					local ButtonFunctions = {}
					локальная кнопка = Instance.new("Frame")
					button.Name = "Button"
					button.AutomaticSize = Enum.AutomaticSize.Y
					button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					button.BackgroundTransparency = 1
					button.BorderColor3 = Color3.fromRGB(0, 0, 0)
					button.BorderSizePixel = 0
					button.Size = UDim2.new(1, 0, 0, 38)
					button.Parent = section

					local buttonInteract = Instance.new("TextButton")
					buttonInteract.Name = "ButtonInteract"
					buttonInteract.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					buttonInteract.RichText = true
					buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
					buttonInteract.TextSize = 13
					buttonInteract.TextTransparency = 0.5
					buttonInteract.TextTruncate = Enum.TextTruncate.AtEnd
					buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
					buttonInteract.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					buttonInteract.BackgroundTransparency = 1
					buttonInteract.BorderColor3 = Color3.fromRGB(0, 0, 0)
					buttonInteract.BorderSizePixel = 0
					buttonInteract.Size = UDim2.fromScale(1, 1)
					buttonInteract.Parent = button
					buttonInteract.Text = Settings.Name

					local buttonImage = Instance.new("ImageLabel")
					buttonImage.Name = "ButtonImage"
					buttonImage.Image = assets.buttonImage
					buttonImage.ImageTransparency = 0.5
					buttonImage.AnchorPoint = Vector2.new(1, 0.5)
					buttonImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					buttonImage.BackgroundTransparency = 1
					buttonImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
					buttonImage.BorderSizePixel = 0
					buttonImage.Position = UDim2.fromScale(1, 0.5)
					buttonImage.Size = UDim2.fromOffset(15, 15)
					buttonImage.Parent = button

					local TweenSettings = {
						DefaultTransparency = 0.5,
						HoverTransparency = 0.3,

						EasingStyle = Enum.EasingStyle.Sine
					}

					локальная функция ChangeState(State)
						если State == "Idle", то
							Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
								TextTransparency = TweenSettings.DefaultTransparency
							}):Играть()
							Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
								ImageTransparency = TweenSettings.DefaultTransparency
							}):Играть()
						elseif State == "Hover" then
							Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
								TextTransparency = TweenSettings.HoverTransparency
							}):Играть()
							Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
								ImageTransparency = TweenSettings.HoverTransparency
							}):Играть()
						конец
					конец

					локальная функция Callback()
						если Settings.Callback тогда
							Settings.Callback()
						конец
					конец

					buttonInteract.MouseEnter:Connect(function()
						ChangeState("Hover")
					конец)
					buttonInteract.MouseLeave:Connect(function()
						ChangeState("Idle")
					конец)

					buttonInteract.MouseButton1Click:Connect(Callback)
					функция ButtonFunctions:UpdateName(Name)
						buttonInteract.Text = Имя
					конец
					функция ButtonFunctions:SetVisibility(State)
						button.Visible = State
					конец
					return ButtonFunctions
				конец

				function SectionFunctions:Toggle(Settings)
					local ToggleFunctions = {}
					local toggle = Instance.new("Frame")
					toggle.Name = "Toggle"
					toggle.AutomaticSize = Enum.AutomaticSize.Y
					toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					toggle.BackgroundTransparency = 1
					toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
					toggle.BorderSizePixel = 0
					toggle.Size = UDim2.new(1, 0, 0, 38)
					toggle.Parent = section

					local toggleName = Instance.new("TextLabel")
					toggleName.Name = "ToggleName"
					toggleName.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					toggleName.Text = Settings.Name
					toggleName.RichText = true
					toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
					toggleName.TextSize = 13
					toggleName.TextTransparency = 0.5
					toggleName.TextTruncate = Enum.TextTruncate.AtEnd
					toggleName.TextXAlignment = Enum.TextXAlignment.Left
					toggleName.TextYAlignment = Enum.TextYAlignment.Top
					toggleName.AnchorPoint = Vector2.new(0, 0.5)
					toggleName.AutomaticSize = Enum.AutomaticSize.Y
					toggleName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					toggleName.BackgroundTransparency = 1
					toggleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
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
					toggle1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					toggle1.BackgroundTransparency = 1
					toggle1.BorderColor3 = Color3.fromRGB(0, 0, 0)
					toggle1.BorderSizePixel = 0
					toggle1.Position = UDim2.fromScale(1, 0.5)
					toggle1.Size = UDim2.fromOffset(41, 21)

					local toggleUIPadding = Instance.new("UIPadding")
					toggleUIPadding.Name = "ToggleUIPadding"
					toggleUIPadding.PaddingBottom = UDim.new(0, 1)
					toggleUIPadding.PaddingLeft = UDim.new(0, -2)
					toggleUIPadding.PaddingRight = UDim.new(0, 3)
					toggleUIPadding.PaddingTop = UDim.new(0, 1)
					toggleUIPadding.Parent = toggle1

					local togglerHead = Instance.new("ImageLabel")
					togglerHead.Name = "TogglerHead"
					togglerHead.Image = "rbxassetid://18772309008"
					togglerHead.ImageColor3 = Color3.fromRGB(91, 91, 91)
					togglerHead.AnchorPoint = Vector2.new(1, 0.5)
					togglerHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					togglerHead.BackgroundTransparency = 1
					togglerHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
					togglerHead.BorderSizePixel = 0
					togglerHead.Position = UDim2.fromScale(0.5, 0.5)
					togglerHead.Size = UDim2.fromOffset(15, 15)
					togglerHead.ZIndex = 2
					togglerHead.Parent = toggle1

					toggle1.Parent = toggle

					local TweenSettings = {
						Info = TweenInfo.new(0.2, Enum.EasingStyle.Sine),

						EnabledColors = {Toggle = Color3.fromRGB(87, 86, 86), ToggleHead = Color3.fromRGB(255, 255, 255)},
						DisabledColors = {Toggle = Color3.fromRGB(61, 61, 61), ToggleHead = Color3.fromRGB(91, 91, 91)},

						EnabledPosition = UDim2.new(1, 0, 0.5, 0),
						DisabledPosition = UDim2.new(0.5, 0, 0.5, 0),
					}

					локальная функция ToggleState(State)
						если штат, то
							Tween(toggle1, TweenSettings.Info, {
								ImageColor3 = TweenSettings.EnabledColors.Toggle
							}):Играть()

							Tween(togglerHead, TweenSettings.Info, {
								ImageColor3 = TweenSettings.EnabledColors.ToggleHead
							}):Играть()

							Tween(togglerHead, TweenSettings.Info, {
								Позиция = TweenSettings.EnabledPosition
							}):Играть()
						еще
							Tween(toggle1, TweenSettings.Info, {
								ImageColor3 = TweenSettings.DisabledColors.Toggle
							}):Играть()

							Tween(togglerHead, TweenSettings.Info, {
								ImageColor3 = TweenSettings.DisabledColors.ToggleHead
							}):Играть()

							Tween(togglerHead, TweenSettings.Info, {
								Позиция = TweenSettings.DisabledPosition
							}):Играть()
						конец
						
						ToggleFunctions.State = State
					конец

					local togglebool = Settings.Default
					ToggleState(togglebool)

					локальная функция Toggle()
						togglebool = not togglebool
						ToggleState(togglebool)
						если Settings.Callback тогда
							Settings.Callback(togglebool)
						конец
					конец

					toggle1.MouseButton1Click:Connect(Toggle)

					функция ToggleFunctions:Toggle()
						Переключать()
					конец
					function ToggleFunctions:UpdateState(State)
						togglebool = State
						ToggleState(togglebool)
						если Settings.Callback тогда
							Settings.Callback(togglebool)
						конец
					конец
					функция ToggleFunctions:GetState()
						return togglebool
					конец
					функция ToggleFunctions:UpdateName(Name)
						toggleName.Text = Имя
					конец
					функция ToggleFunctions:SetVisibility(State)
						toggle.Visible = State
					конец
					return ToggleFunctions
				конец

				функция SectionFunctions:Slider(Settings)
					local SliderFunctions = {}
					local slider = Instance.new("Frame")
					slider.Name = "Slider"
					slider.AutomaticSize = Enum.AutomaticSize.Y
					slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					slider.BackgroundTransparency = 1
					slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
					slider.BorderSizePixel = 0
					slider.Size = UDim2.new(1, 0, 0, 38)
					slider.Parent = section

					local sliderName = Instance.new("TextLabel")
					sliderName.Name = "SliderName"
					sliderName.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					sliderName.Text = Settings.Name
					sliderName.RichText = true
					Имя слайдера.TextColor3 = Цвет3.fromRGB(255, 255, 255)
					sliderName.TextSize = 13
					sliderName.TextTransparency = 0.5
					sliderName.TextTruncate = Enum.TextTruncate.AtEnd
					sliderName.TextXAlignment = Enum.TextXAlignment.Left
					sliderName.TextYAlignment = Enum.TextYAlignment.Top
					sliderName.AnchorPoint = Vector2.new(0, 0.5)
					sliderName.AutomaticSize = Enum.AutomaticSize.XY
					sliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderName.BackgroundTransparency = 1
					sliderName.BorderColor3 = Color3.fromRGB(0, 0, 0)
					sliderName.BorderSizePixel = 0
					Имя слайдера.Позиция = UDim2.fromScale(1.3e-07, 0.5)
					sliderName.Parent = slider

					local sliderElements = Instance.new("Frame")
					sliderElements.Name = "SliderElements"
					sliderElements.AnchorPoint = Vector2.new(1, 0)
					sliderElements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderElements.BackgroundTransparency = 1
					sliderElements.BorderColor3 = Color3.fromRGB(0, 0, 0)
					sliderElements.BorderSizePixel = 0
					sliderElements.Position = UDim2.fromScale(1, 0)
					sliderElements.Size = UDim2.fromScale(1, 1)

					local sliderValue = Instance.new("TextBox")
					sliderValue.Name = "SliderValue"
					sliderValue.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					sliderValue.Text = "100%"
					слайдерЗначение.TextColor3 = Color3.fromRGB(255, 255, 255)
					sliderValue.TextSize = 12
					sliderValue.TextTransparency = 0.4
					sliderValue.TextTruncate = Enum.TextTruncate.AtEnd
					sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderValue.BackgroundTransparency = 0.95
					sliderValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
					sliderValue.BorderSizePixel = 0
					sliderValue.LayoutOrder = 1
					sliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
					sliderValue.Size = UDim2.fromOffset(41, 21)

					local sliderValueUICorner = Instance.new("UICorner")
					sliderValueUICorner.Name = "SliderValueUICorner"
					sliderValueUICorner.CornerRadius = UDim.new(0, 4)
					sliderValueUICorner.Parent = sliderValue

					local sliderValueUIStroke = Instance.new("UIStroke")
					sliderValueUIStroke.Name = "SliderValueUIStroke"
					sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					sliderValueUIStroke.Color = Color3.fromRGB(255, 255, 255)
					sliderValueUIStroke.Transparency = 0.9
					sliderValueUIStroke.Parent = sliderValue

					local sliderValueUIPadding = Instance.new("UIPadding")
					sliderValueUIPadding.Name = "SliderValueUIPadding"
					sliderValueUIPadding.PaddingLeft = UDim.new(0, 2)
					sliderValueUIPadding.PaddingRight = UDim.new(0, 2)
					sliderValueUIPadding.Parent = sliderValue

					sliderValue.Parent = sliderElements

					local sliderElementsUIListLayout = Instance.new("UIListLayout")
					sliderElementsUIListLayout.Name = "SliderElementsUIListLayout"
					sliderElementsUIListLayout.Padding = UDim.new(0, 20)
					SliderElementsUIListLayout.FillDirection = Enum.FillDirection.Horizontal
					sliderElementsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
					sliderElementsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					sliderElementsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					sliderElementsUIListLayout.Parent = sliderElements

					local sliderBar = Instance.new("ImageLabel")
					sliderBar.Name = "SliderBar"
					sliderBar.Image = "rbxassetid://18772615246"
					sliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
					sliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderBar.BackgroundTransparency = 1
					sliderBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
					sliderBar.BorderSizePixel = 0
					sliderBar.Position = UDim2.fromScale(0.219, 0.457)
					sliderBar.Size = UDim2.fromOffset(123, 3)

					local sliderHead = Instance.new("ImageButton")
					sliderHead.Name = "SliderHead"
					sliderHead.Image = "rbxassetid://18772834246"
					sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
					sliderHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					sliderHead.BackgroundTransparency = 1
					sliderHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
					sliderHead.BorderSizePixel = 0
					sliderHead.Position = UDim2.fromScale(1, 0.5)
					sliderHead.Size = UDim2.fromOffset(12, 12)
					sliderHead.Parent = sliderBar

					sliderBar.Parent = sliderElements

					local sliderElementsUIPadding = Instance.new("UIPadding")
					sliderElementsUIPadding.Name = "SliderElementsUIPadding"
					sliderElementsUIPadding.PaddingTop = UDim.new(0, 3)
					sliderElementsUIPadding.Parent = sliderElements

					sliderElements.Parent = slider

					локальное перетаскивание = false

					local DisplayMethods = {
						Сотые доли = функция(sliderValue)
							return string.format("%.2f", sliderValue)
						конец,
						Десятые доли = функция(sliderValue)
							return string.format("%.1f", sliderValue)
						конец,
						Round = function(sliderValue)
							return tostring(math.round(sliderValue))
						конец,
						Градусы = функция(sliderValue)
							return tostring(math.round(sliderValue)) .. "В°"
						конец,
						Процент = функция(sliderValue)
							локальный процент = (sliderValue - Settings.Minimum) / (Settings.Maximum - Settings.Minimum) * 100
							return tostring(math.round(percentage)) .. "%"
						конец,
						Значение = функция(sliderValue)
							return tostring(sliderValue)
						конец
					}

					local ValueDisplayMethod = DisplayMethods[Settings.DisplayMethod]
					локальное финальное значение

					локальная функция SetValue(val, ignorecallback)
						локальный posXScale

						если typeof(val) == "Instance", то
							локальный ввод = значение
							posXScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
						еще
							локальное значение = значение
							posXScale = (value - Settings.Minimum) / (Settings.Maximum - Settings.Minimum)
						конец

						local pos = UDim2.new(posXScale, 0, 0.5, 0)
						sliderHead.Position = pos

						finalValue = posXScale * (Settings.Maximum - Settings.Minimum) + Settings.Minimum
						sliderValue.Text = ValueDisplayMethod(finalValue)

						если не игнорировать обратный вызов, то
							task.spawn(function()
								если Settings.Callback тогда
									Settings.Callback(finalValue)
								конец
							конец)
						конец
						
						SliderFunctions.Value = finalValue
					конец

					SetValue(Settings.Default, true)

					sliderHead.InputBegan:Connect(function(input)
						если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
							перетаскивание = true
							SetValue(input)
						конец
					конец)

					sliderHead.InputEnded:Connect(function(input)
						если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
							перетаскивание = false
						конец
					конец)

					sliderValue.FocusLost:Connect(function(enterPressed)
						local inputText = sliderValue.Text
						локальное значение, isPercent = inputText:match("^(%-?%d+%.?%d*)(%%?)$")

						если значение тогда
							значение = tonumber(значение)
							isPercent = isPercent == "%"

							если isPercent тогда
								значение = Settings.Minimum + (значение / 100) * (Settings.Maximum - Settings.Minimum)
							конец

							local newValue = math.clamp(value, Settings.Minimum, Settings.Maximum)
							SetValue(newValue)
						еще
							sliderValue.Text = ValueDisplayMethod(sliderValue)
						конец
					конец)

					UserInputService.InputChanged:Connect(function(input)
						Если выполняется перетаскивание и (input.UserInputType == Enum.UserInputType.MouseMovement или input.UserInputType == Enum.UserInputType.Touch), то
							SetValue(input)
						конец
					конец)

					локальная функция updateSliderBarSize()
						local padding = sliderElementsUIListLayout.Padding.Offset
						local sliderValueWidth = sliderValue.AbsoluteSize.X
						local sliderNameWidth = sliderName.AbsoluteSize.X
						local totalWidth = sliderElements.AbsoluteSize.X

						local newBarWidth = totalWidth - (padding + sliderValueWidth + sliderNameWidth + 20)
						sliderBar.Size = UDim2.new(sliderBar.Size.X.Scale, newBarWidth, sliderBar.Size.Y.Scale, sliderBar.Size.Y.Offset)
					конец

					updateSliderBarSize()

					sliderName:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)
					section:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSliderBarSize)

					функция SliderFunctions:UpdateName(Name)
						sliderName = Имя
					конец
					функция SliderFunctions:SetVisibility(State)
						slider.Visible = State
					конец
					функция SliderFunctions:UpdateValue(Value)
						SetValue(Value)
					конец
					функция SliderFunctions:GetValue()
						return finalValue
					конец
					return SliderFunctions
				конец

				функция SectionFunctions:Input(Settings)
					local InputFunctions = {}
					local input = Instance.new("Frame")
					input.Name = "Input"
					input.AutomaticSize = Enum.AutomaticSize.Y
					input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					input.BackgroundTransparency = 1
					input.BorderColor3 = Color3.fromRGB(0, 0, 0)
					input.BorderSizePixel = 0
					input.Size = UDim2.new(1, 0, 0, 38)
					input.Parent = section

					local inputName = Instance.new("TextLabel")
					inputName.Name = "InputName"
					inputName.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputName.Text = Settings.Name
					inputName.RichText = true
					inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputName.TextSize = 13
					inputName.TextTransparency = 0.5
					inputName.TextTruncate = Enum.TextTruncate.AtEnd
					inputName.TextXAlignment = Enum.TextXAlignment.Left
					inputName.TextYAlignment = Enum.TextYAlignment.Top
					inputName.AnchorPoint = Vector2.new(0, 0.5)
					inputName.AutomaticSize = Enum.AutomaticSize.XY
					inputName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputName.BackgroundTransparency = 1
					inputName.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputName.BorderSizePixel = 0
					inputName.Position = UDim2.fromScale(0, 0.5)
					inputName.Parent = input

					local inputBox = Instance.new("TextBox")
					inputBox.Name = "InputBox"
					inputBox.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputBox.Text = "Привет, мир!"
					inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputBox.TextSize = 12
					inputBox.TextTransparency = 0.4
					inputBox.AnchorPoint = Vector2.new(1, 0.5)
					inputBox.AutomaticSize = Enum.AutomaticSize.X
					inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputBox.BackgroundTransparency = 0.95
					inputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputBox.BorderSizePixel = 0
					inputBox.ClipsDescendants = true
					inputBox.LayoutOrder = 1
					inputBox.Position = UDim2.fromScale(1, 0.5)
					inputBox.Size = UDim2.fromOffset(21, 21)

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

					inputBox.Parent = input

					локальный ввод = ввод
					local InputBox = inputBox
					local InputName = inputName
					local Constraint = inputBoxUISizeConstraint

					local CharacterSubs = {
						All = function(value)
							возвращаемое значение
						конец,
						Числовое значение = функция(значение)
							return value:match("^%-?%d*$") and value or value:gsub("[^%d-]", ""):gsub("(%-)", function(match, pos, original)
								если pos == 1, то
									ответный матч
								еще
									возвращаться ""
								конец
							конец)
						конец,
						Алфавитный = функция(значение)
							возвращаемое значение: gsub("[^a-zA-Z ]", "")
						конец,
					}

					local AcceptedCharacters = CharacterSubs[Settings.AcceptedCharacters] or CharacterSubs.All

					InputBox.AutomaticSize = Enum.AutomaticSize.X

					локальная функция checkSize()
						local nameWidth = InputName.AbsoluteSize.X
						local totalWidth = Input.AbsoluteSize.X

						local maxWidth = totalWidth - nameWidth - 20
						Constraint.MaxSize = Vector2.new(maxWidth, 9e9)
					конец

					checkSize()
					InputName:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkSize)

					InputBox.FocusLost:Connect(function()
						local inputText = InputBox.Text
						local filteredText = AcceptedCharacters(inputText)
						InputBox.Text = filteredText
						task.spawn(function()
							если Settings.Callback тогда
								Settings.Callback(filteredText)
							конец
						конец)
					конец)
					InputBox.Text = Settings.Default or ""
					InputBox.PlaceholderText = Settings.Placeholder or ""

					InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						InputBox.Text = AcceptedCharacters(InputBox.Text)
						Если Settings.onChanged, то
							Settings.onChange(InputBox.Text)
						конец
						InputFunctions.Text = InputBox.Text
					конец)

					функция InputFunctions:UpdateName(Name)
						inputName.Text = Имя
					конец
					функция InputFunctions:SetVisibility(State)
						input.Visible = State
					конец
					функция InputFunctions:GetInput()
						return InputBox.Text
					конец
					функция InputFunctions:UpdatePlaceholder(Placeholder)
						inputBox.PlaceholderText = Placeholder
					конец
					функция InputFunctions:UpdateText(Text)
						inputBox.Text = Текст
					конец
					return InputFunctions
				конец

				function SectionFunctions:Keybind(Settings)
					local KeybindFunctions = {}
					local keybind = Instance.new("Frame")
					keybind.Name = "Keybind"
					keybind.AutomaticSize = Enum.AutomaticSize.Y
					keybind.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					keybind.BackgroundTransparency = 1
					keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
					keybind.BorderSizePixel = 0
					keybind.Size = UDim2.new(1, 0, 0, 38)
					keybind.Parent = section

					local keybindName = Instance.new("TextLabel")
					keybindName.Name = "KeybindName"
					keybindName.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					keybindName.Text = Settings.Name
					keybindName.RichText = true
					keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
					keybindName.TextSize = 13
					keybindName.TextTransparency = 0.5
					keybindName.TextTruncate = Enum.TextTruncate.AtEnd
					keybindName.TextXAlignment = Enum.TextXAlignment.Left
					keybindName.TextYAlignment = Enum.TextYAlignment.Top
					keybindName.AnchorPoint = Vector2.new(0, 0.5)
					keybindName.AutomaticSize = Enum.AutomaticSize.XY
					keybindName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					keybindName.BackgroundTransparency = 1
					keybindName.BorderColor3 = Color3.fromRGB(0, 0, 0)
					keybindName.BorderSizePixel = 0
					keybindName.Position = UDim2.fromScale(0, 0.5)
					keybindName.Parent = keybind

					local binderBox = Instance.new("TextBox")
					binderBox.Name = "BinderBox"
					binderBox.CursorPosition = -1
					binderBox.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					binderBox.PlaceholderText = "..."
					binderBox.Text = ""
					BinderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
					binderBox.TextSize = 12
					binderBox.TextTransparency = 0.4
					binderBox.AnchorPoint = Vector2.new(1, 0.5)
					binderBox.AutomaticSize = Enum.AutomaticSize.X
					binderBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					binderBox.BackgroundTransparency = 0.95
					binderBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
					binderBox.BorderSizePixel = 0
					binderBox.ClipsDescendants = true
					binderBox.LayoutOrder = 1
					binderBox.Position = UDim2.fromScale(1, 0.5)
					binderBox.Size = UDim2.fromOffset(21, 21)

					local binderBoxUICorner = Instance.new("UICorner")
					binderBoxUICorner.Name = "BinderBoxUICorner"
					binderBoxUICorner.CornerRadius = UDim.new(0, 4)
					binderBoxUICorner.Parent = binderBox

					local binderBoxUIStroke = Instance.new("UIStroke")
					binderBoxUIStroke.Name = "BinderBoxUIStroke"
					binderBoxUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					binderBoxUIStroke.Color = Color3.fromRGB(255, 255, 255)
					binderBoxUIStroke.Transparency = 0.9
					binderBoxUIStroke.Parent = binderBox

					local binderBoxUIPadding = Instance.new("UIPadding")
					BinderBoxUIPadding.Name = "BinderBoxUIPadding"
					binderBoxUIPadding.PaddingLeft = UDim.new(0, 5)
					binderBoxUIPadding.PaddingRight = UDim.new(0, 5)
					binderBoxUIPadding.Parent = binderBox

					local binderBoxUISizeConstraint = Instance.new("UISizeConstraint")
					binderBoxUISizeConstraint.Name = "BinderBoxUISizeConstraint"
					binderBoxUISizeConstraint.Parent = binderBox

					binderBox.Parent = keybind

					ориентированный на местный рынок
					local binded = Settings.Default
					если связано, то
						binderBox.Text = binded.Name
					конец

					binderBox.Focused:Connect(function()
						focused = true
					конец)
					binderBox.FocusLost:Connect(function()
						focused = false
					конец)
				
					UserInputService.InputEnded:Connect(function(inp)
						если macLib ≤ nil, то
							Если фокус и inp.KeyCode.Name ~= "Unknown", то
								binded = inp.KeyCode
								KeybindFunctions.Bind = binded
								binderBox.Text = inp.KeyCode.Name
								binderBox:ReleaseFocus()
								Если Settings.onBinded, то
									Settings.onBinded(binded)
								конец
							elseif inp.KeyCode == binded then
								если Settings.Callback тогда
									Settings.Callback(binded)
								конец
							конец
						конец
					конец)
					функция KeybindFunctions:Bind(Key)
						привязанный = ключ
						binderBox.Text = Key.Name
					конец
					функция KeybindFunctions:Unbind()
						привязано = нул
						binderBox.Text = ""
					конец
					функция KeybindFunctions:GetBind()
						возврат связанного
					конец
					функция KeybindFunctions:UpdateName(Name)
						keybindName = Name
					конец
					функция KeybindFunctions:SetVisibility(State)
						keybind.Visible = State
					конец
					return KeybindFunctions
				конец

				функция SectionFunctions:Dropdown(Settings)
					local DropdownFunctions = {}
					local Selected = {}
					local OptionObjs = {}

					local dropdown = Instance.new("Frame")
					dropdown.Name = "Выпадающий список"
					dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					dropdown.BackgroundTransparency = 0.985
					dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
					dropdown.BorderSizePixel = 0
					dropdown.Size = UDim2.new(1, 0, 0, 38)
					выпадающий список. Родительский раздел
					dropdown.ClipsDescendants = true
					
					local dropdownUIPadding = Instance.new("UIPadding")
					dropdownUIPadding.Name = "DropdownUIPadding"
					dropdownUIPadding.PaddingLeft = UDim.new(0, 15)
					dropdownUIPadding.PaddingRight = UDim.new(0, 15)
					dropdownUIPadding.Parent = dropdown

					local interact = Instance.new("TextButton")
					interact.Name = "Interact"
					interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
					interact.Text = ""
					interact.TextColor3 = Color3.fromRGB(0, 0, 0)
					interact.TextSize = 14
					interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					interact.BackgroundTransparency = 1
					interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
					interact.BorderSizePixel = 0
					interact.Size = UDim2.new(1, 0, 0, 38)
					interact.Parent = dropdown

					local dropdownName = Instance.new("TextLabel")
					dropdownName.Name = "DropdownName"
					dropdownName.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					dropdownName.Text = Settings.Name
					dropdownName.RichText = true
					dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
					dropdownName.TextSize = 13
					dropdownName.TextTransparency = 0.5
					dropdownName.TextTruncate = Enum.TextTruncate.SplitWord
					dropdownName.TextXAlignment = Enum.TextXAlignment.Left
					dropdownName.AutomaticSize = Enum.AutomaticSize.Y
					dropdownName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					dropdownName.BackgroundTransparency = 1
					dropdownName.BorderColor3 = Color3.fromRGB(0, 0, 0)
					dropdownName.BorderSizePixel = 0
					dropdownName.Size = UDim2.new(1, -20, 0, 38)
					dropdownName.Parent = dropdown

					local dropdownUIStroke = Instance.new("UIStroke")
					dropdownUIStroke.Name = "DropdownUIStroke"
					dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					dropdownUIStroke.Color = Color3.fromRGB(255, 255, 255)
					dropdownUIStroke.Transparency = 0.95
					dropdownUIStroke.Parent = dropdown

					local dropdownUICorner = Instance.new("UICorner")
					dropdownUICorner.Name = "DropdownUICorner"
					dropdownUICorner.CornerRadius = UDim.new(0, 6)
					dropdownUICorner.Parent = dropdown

					local dropdownImage = Instance.new("ImageLabel")
					dropdownImage.Name = "DropdownImage"
					dropdownImage.Image = "rbxassetid://18865373378"
					dropdownImage.ImageTransparency = 0.5
					dropdownImage.AnchorPoint = Vector2.new(1, 0)
					dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					dropdownImage.BackgroundTransparency = 1
					dropdownImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
					dropdownImage.BorderSizePixel = 0
					dropdownImage.Position = UDim2.new(1, 0, 0, 12)
					dropdownImage.Size = UDim2.fromOffset(14, 14)
					dropdownImage.Parent = dropdown

					local dropdownFrame = Instance.new("Frame")
					dropdownFrame.Name = "DropdownFrame"
					dropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					dropdownFrame.BackgroundTransparency = 1
					dropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					dropdownFrame.BorderSizePixel = 0
					dropdownFrame.ClipsDescendants = true
					dropdownFrame.Size = UDim2.fromScale(1, 1)
					dropdownFrame.Visible = false
					dropdownFrame.AutomaticSize = Enum.AutomaticSize.Y

					local dropdownFrameUIPadding = Instance.new("UIPadding")
					dropdownFrameUIPadding.Name = "DropdownFrameUIPadding"
					dropdownFrameUIPadding.PaddingTop = UDim.new(0, 38)
					dropdownFrameUIPadding.PaddingBottom = UDim.new(0, 10)
					dropdownFrameUIPadding.Parent = dropdownFrame

					local dropdownFrameUIListLayout = Instance.new("UIListLayout")
					dropdownFrameUIListLayout.Name = "DropdownFrameUIListLayout"
					dropdownFrameUIListLayout.Padding = UDim.new(0, 5)
					dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					dropdownFrameUIListLayout.Parent = dropdownFrame
					
					локальный поиск = Instance.new("Frame")
					search.Name = "Search"
					search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					search.BackgroundTransparency = 0.95
					search.BorderColor3 = Color3.fromRGB(0, 0, 0)
					search.BorderSizePixel = 0
					search.LayoutOrder = -1
					search.Size = UDim2.new(1, 0, 0, 30)
					search.Parent = dropdownFrame
					search.Visible = Settings.Search

					local sectionUICorner = Instance.new("UICorner")
					sectionUICorner.Name = "SectionUICorner"
					sectionUICorner.Parent = search

					local searchIcon = Instance.new("ImageLabel")
					searchIcon.Name = "SearchIcon"
					searchIcon.Image = assets.searchIcon
					searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
					searchIcon.AnchorPoint = Vector2.new(0, 0.5)
					searchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					searchIcon.BackgroundTransparency = 1
					searchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
					searchIcon.BorderSizePixel = 0
					searchIcon.Position = UDim2.fromScale(0, 0.5)
					searchIcon.Size = UDim2.fromOffset(12, 12)
					searchIcon.Parent = search

					local uIPadding = Instance.new("UIPadding")
					uIPadding.Name = "UIPadding"
					uIPadding.PaddingLeft = UDim.new(0, 15)
					uIPadding.Parent = search

					local searchBox = Instance.new("TextBox")
					searchBox.Name = "SearchBox"
					searchBox.CursorPosition = -1
					searchBox.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
					searchBox.PlaceholderText = "Поиск..."
					searchBox.Text = ""
					searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
					searchBox.TextSize = 14
					searchBox.TextXAlignment = Enum.TextXAlignment.Left
					searchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					searchBox.BackgroundTransparency = 1
					searchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
					searchBox.BorderSizePixel = 0
					searchBox.Size = UDim2.fromScale(1, 1)
					
					локальная функция CalculateDropdownSize()
						локальный totalHeight = 0
						local visibleChildrenCount = 0
						local padding = dropdownFrameUIPadding.PaddingTop.Offset + dropdownFrameUIPadding.PaddingBottom.Offset

						for _, v in pairs(dropdownFrame:GetChildren()) do
							if not v:IsA("UIComponent") and v.Visible then
								totalHeight += v.AbsoluteSize.Y
								visibleChildrenCount += 1
							конец
						конец

						local spacing = dropdownFrameUIListLayout.Padding.Offset * (visibleChildrenCount - 1)

						return totalHeight + spacing + padding
					конец

					локальная функция findOption()
						local searchTerm = searchBox.Text:lower()

						for _, v in pairs(OptionObjs) do
							local optionText = v.NameLabel.Text:lower()
							local isVisible = string.find(optionText, searchTerm) ~= nil

							если v.Button.Visible ~= isVisible, то
								v.Button.Visible = isVisible
							конец
						конец

						dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
					конец

					searchBox:GetPropertyChangedSignal("Text"):Connect(findOption)

					local uIPadding1 = Instance.new("UIPadding")
					uIPadding1.Name = "UIPadding"
					uIPadding1.PaddingLeft = UDim.new(0, 23)
					uIPadding1.Parent = searchBox

					searchBox.Parent = search
					
					локальные настройки твитов = {
						длительность = 0,2,
						easingStyle = Enum.EasingStyle.Quint,
						прозрачностьIn = 0,2,
						transparencyOut = 0.5,
						checkSizeIncrease = 12,
						checkSizeDecrease = -13,
						waitTime = 1
					}
					
					локальная функция Toggle(optionName, State)
						локальная опция = OptionObjs[optionName]

						Если нет варианта, то вернуться к концу.

						локальная галочка = опция.Галочка
						local optionNameLabel = option.NameLabel

						если штат, то
							Если Settings.Multi, то
								if not table.find(Selected, optionName) then
									table.insert(Selected, optionName)
									DropdownFunctions.Value = Selected
								конец
							еще
								для имени, выберите в парах (OptionObjs) do
									если name ~= optionName тогда
										Tween(opt.Checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
											Размер = UDim2.new(opt.Checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, opt.Checkmark.Size.Y.Scale, opt.Checkmark.Size.Y.Offset)
										}):Играть()
										Tween(opt.NameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
											TextTransparency = tweensettings.transparencyOut
										}):Играть()
										opt.Checkmark.TextTransparency = 1
									конец
								конец
								Выбрано = {optionName}
								DropdownFunctions.Value = Selected[1]
							конец
							Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
								Размер = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
							}):Играть()
							Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
								TextTransparency = tweensettings.transparencyIn
							}):Играть()
							checkmark.TextTransparency = 0
						еще
							Если Settings.Multi, то
								local idx = table.find(Selected, optionName)
								если idx тогда
									table.remove(Selected, idx)
								конец
							еще
								Выбрано = {}
							конец
							Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
								Размер = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
							}):Играть()
							Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
								TextTransparency = tweensettings.transparencyOut
							}):Играть()
							checkmark.TextTransparency = 1
						конец

						Если Settings.Required и #Selected == 0 и не State, то
							возвращаться
						конец

						если #Selected > 0, то
							dropdownName.Text = Settings.Name .. " вЂў " .. table.concat(Selected, ", ")
						еще
							dropdownName.Text = Settings.Name
						конец
					конец

					local dropped = false
					локальная база данных = false
					
					локальная функция ToggleDropdown()
						если база данных, то вернуть конец
						db = true
						local defaultDropdownSize = 38
						local isDropdownOpen = not dropped
						local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)

						local tween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
							Размер = целевойРазмер
						})

						tween:Play()

						если isDropdownOpen тогда
							dropdownFrame.Visible = true
							tween.Completed:Connect(function()
								db = false
							конец)
						еще
							tween.Completed:Connect(function()
								dropdownFrame.Visible = false
								db = false
							конец)
						конец

						dropped = isDropdownOpen
					конец

					interact.MouseButton1Click:Connect(ToggleDropdown)
					
					локальная функция addOption(i, v)
						local option = Instance.new("TextButton")
						option.Name = "Option"
						option.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
						option.Text = ""
						option.TextColor3 = Color3.fromRGB(0, 0, 0)
						option.TextSize = 14
						option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						option.BackgroundTransparency = 1
						option.BorderColor3 = Color3.fromRGB(0, 0, 0)
						option.BorderSizePixel = 0
						option.Size = UDim2.new(1, 0, 0, 30)

						local optionUIPadding = Instance.new("UIPadding")
						optionUIPadding.Name = "OptionUIPadding"
						optionUIPadding.PaddingLeft = UDim.new(0, 15)
						optionUIPadding.Parent = option

						local optionName = Instance.new("TextLabel")
						optionName.Name = "OptionName"
						optionName.FontFace = Font.new(
							assets.interFont,
							Enum.FontWeight.Medium,
							Enum.FontStyle.Normal
						)
						optionName.Text = v
						optionName.RichText = true
						optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
						optionName.TextSize = 13
						optionName.TextTransparency = 0.5
						optionName.TextTruncate = Enum.TextTruncate.AtEnd
						optionName.TextXAlignment = Enum.TextXAlignment.Left
						optionName.TextYAlignment = Enum.TextYAlignment.Top
						optionName.AnchorPoint = Vector2.new(0, 0.5)
						optionName.AutomaticSize = Enum.AutomaticSize.XY
						optionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						optionName.BackgroundTransparency = 1
						optionName.BorderColor3 = Color3.fromRGB(0, 0, 0)
						optionName.BorderSizePixel = 0
						optionName.Position = UDim2.fromScale(1.3e-07, 0.5)
						optionName.Parent = option

						local optionUIListLayout = Instance.new("UIListLayout")
						optionUIListLayout.Name = "OptionUIListLayout"
						optionUIListLayout.Padding = UDim.new(0, 10)
						optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
						optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
						optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
						optionUIListLayout.Parent = option

						локальная галочка = Instance.new("TextLabel")
						checkmark.Name = "Checkmark"
						checkmark.FontFace = Font.new(
							assets.interFont,
							Enum.FontWeight.Medium,
							Enum.FontStyle.Normal
						)
						checkmark.Text = "вњ“"
						checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
						checkmark.TextSize = 13
						checkmark.TextTransparency = 1
						checkmark.TextXAlignment = Enum.TextXAlignment.Left
						checkmark.TextYAlignment = Enum.TextYAlignment.Top
						checkmark.AnchorPoint = Vector2.new(0, 0.5)
						checkmark.AutomaticSize = Enum.AutomaticSize.Y
						checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						checkmark.BackgroundTransparency = 1
						checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
						checkmark.BorderSizePixel = 0
						checkmark.LayoutOrder = -1
						checkmark.Position = UDim2.fromScale(1.3e-07, 0.5)
						checkmark.Size = UDim2.fromOffset(-10, 0)
						checkmark.Parent = option

						option.Parent = dropdownFrame

						dropdownFrame.Parent = dropdown
						OptionObjs[v] = {
							Индекс = i,
							Кнопка = опция,
							NameLabel = optionName,
							Галочка = галочка
						}

						локальные настройки твитов = {
							длительность = 0,2,
							easingStyle = Enum.EasingStyle.Quint,
							прозрачностьIn = 0,2,
							transparencyOut = 0.5,
							checkSizeIncrease = 12,
							checkSizeDecrease = -optionUIListLayout.Padding.Offset,
							waitTime = 1
						}
						локальные анимации = {
							checkIn = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
								Размер = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
							}),
							checkOut = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
								Размер = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
							}),
							nameIn = Tween(optionName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
								TextTransparency = tweensettings.transparencyIn
							}),
							nameOut = Tween(optionName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
								TextTransparency = tweensettings.transparencyOut
							})
						}

						local isSelected = false
						Если Settings.Default, то
							Если Settings.Multi, то
								isSelected = table.find(Settings.Default, v) and true or false
							еще
								isSelected = (Settings.Default == i) and true or false
							конец
						конец
						Toggle(v, isSelected)

						local option = OptionObjs[v].Button

						option.MouseButton1Click:Connect(function()
							local isSelected = table.find(Selected, v) and true or false
							local newSelected = not isSelected

							Если Settings.Required не равно newSelected и #Selected <= 1, то
								возвращаться
							конец

							Toggle(v, newSelected)

							task.spawn(function()
								Если Settings.Multi, то
									локальный Return = {}
									for _, opt in ipairs(Selected) do
										Возвращать[opt] = true
									конец
									если Settings.Callback тогда
										Settings.Callback(Return)
									конец

								еще
									Если newSelected и Settings.Callback, то
										Settings.Callback(Selected[1] or nil)
									конец
								конец
							конец)
						конец)
						
						если уронить, то
							dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
						конец
					конец

					for i, v in pairs(Settings.Options) do
						addOption(i, v)
					конец
					
					function DropdownFunctions:UpdateName(New)
						dropdownName.Text = New
					конец
					function DropdownFunctions:SetVisibility(State)
						dropdown.Visible = State
					конец
					function DropdownFunctions:UpdateSelection(newSelection)
						если type(newSelection) == "number", то
							для опции данные в парах (OptionObjs) делают
								local isSelected = data.Index == newSelection
								Toggle(option, isSelected)
							конец
						elseif type(newSelection) == "table" then
							для опции данные в парах (OptionObjs) делают
								local isSelected = table.find(newSelection, option) ~= nil
								Toggle(option, isSelected)
							конец
						конец
					конец
					function DropdownFunctions:InsertOptions(newOptions)
						Settings.Options = newOptions
						for i, v in pairs(newOptions) do
							addOption(i, v)
						конец
					конец
					функция DropdownFunctions:ClearOptions()
						for _, optionData in pairs(OptionObjs) do
							optionData.Button:Destroy()
						конец
						OptionObjs = {}
						Выбрано = {}
						
						если уронить, то
							dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
						конец
					конец
					функция DropdownFunctions:GetOptions()
						local optionsStatus = {}

						для опции данные в парах (OptionObjs) делают
							local isSelected = table.find(Selected, option) and true or false
							optionsStatus[option] = isSelected
						конец

						возвращаемые параметры статуса
					конец
					
					function DropdownFunctions:RemoveOptions(remove)
						for _, optionName in ipairs(remove) do
							local optionData = OptionObjs[optionName]

							если optionData тогда
								for i = #Selected, 1, -1 do
									если Selected[i] == optionName тогда
										table.remove(Selected, i)
									конец
								конец

								optionData.Button:Destroy()

								OptionObjs[optionName] = nil
							конец
						конец
						
						если уронить, то
							dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
						конец
					конец
					function DropdownFunctions:IsOption(optionName)
						return OptionObjs[optionName] ~= nil
					конец

					return DropdownFunctions
				конец
				
				function SectionFunctions:Colorpicker(Settings)
					local ColorpickerFunctions = {}
					
					local isAlpha = Settings.Alpha and true or false
					ColorpickerFunctions.Color = Settings.Default
					ColorpickerFunctions.Alpha = isAlpha and Settings.Alpha
					
					local colorpicker = Instance.new("Frame")
					colorpicker.Name = "Colorpicker"
					colorpicker.AutomaticSize = Enum.AutomaticSize.Y
					colorpicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					colorpicker.BackgroundTransparency = 1
					colorpicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorpicker.BorderSizePixel = 0
					colorpicker.Size = UDim2.new(1, 0, 0, 38)
					colorpicker.Parent = section

					local colorpickerName = Instance.new("TextLabel")
					colorpickerName.Name = "KeybindName"
					colorpickerName.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					colorpickerName.Text = Settings.Name
					colorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
					colorpickerName.TextSize = 13
					colorpickerName.TextTransparency = 0.5
					colorpickerName.RichText = true
					colorpickerName.TextTruncate = Enum.TextTruncate.AtEnd
					colorpickerName.TextXAlignment = Enum.TextXAlignment.Left
					colorpickerName.TextYAlignment = Enum.TextYAlignment.Top
					colorpickerName.AnchorPoint = Vector2.new(0, 0.5)
					colorpickerName.AutomaticSize = Enum.AutomaticSize.XY
					colorpickerName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					colorpickerName.BackgroundTransparency = 1
					colorpickerName.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorpickerName.BorderSizePixel = 0
					colorpickerName.Position = UDim2.fromScale(0, 0.5)
					colorpickerName.Parent = colorpicker

					local colorCbg = Instance.new("ImageLabel")
					colorCbg.Name = "NewColor"
					colorCbg.Image = "rbxassetid://121484455191370"
					colorCbg.ScaleType = Enum.ScaleType.Tile
					colorCbg.TileSize = UDim2.fromOffset(500, 500)
					colorCbg.AnchorPoint = Vector2.new(1, 0.5)
					colorCbg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					colorCbg.BackgroundTransparency = 1
					colorCbg.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorCbg.BorderSizePixel = 0
					colorCbg.Position = UDim2.fromScale(1, 0.5)
					colorCbg.Size = UDim2.fromOffset(21, 21)

					local colorC = Instance.new("Frame")
					colorC.Name = "Color"
					colorC.AnchorPoint = Vector2.new(0,5, 0,5)
					colorC.BackgroundColor3 = ColorpickerFunctions.Color
					colorC.BorderSizePixel = 0
					colorC.Position = UDim2.fromScale(0,5, 0,5)
					colorC.Size = UDim2.fromScale(1, 1)
					colorC.BackgroundTransparency = ColorpickerFunctions.Alpha or 0

					local uICorner = Instance.new("UICorner")
					uICorner.Name = "UICorner"
					uICorner.CornerRadius = UDim.new(0, 6)
					uICorner.Parent = colorC

					local interact = Instance.new("TextButton")
					interact.Name = "Interact"
					interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
					interact.Text = ""
					interact.TextColor3 = Color3.fromRGB(0, 0, 0)
					interact.TextSize = 14
					interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					interact.BackgroundTransparency = 1
					interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
					interact.BorderSizePixel = 0
					interact.Size = UDim2.fromScale(1, 1)
					interact.Parent = colorC

					colorC.Parent = colorCbg

					local uICorner1 = Instance.new("UICorner")
					uICorner1.Name = "UICorner"
					uICorner1.CornerRadius = UDim.new(0, 8)
					uICorner1.Parent = colorCbg

					colorCbg.Parent = colorpicker

					local colorPicker = Instance.new("Frame")
					colorPicker.Name = "ColorPicker"
					colorPicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					colorPicker.BackgroundTransparency = 0.5
					colorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorPicker.BorderSizePixel = 0
					colorPicker.Size = UDim2.fromScale(1, 1)
					colorPicker.Visible = false
					
					local baseUICorner = Instance.new("UICorner")
					baseUICorner.Name = "BaseUICorner"
					baseUICorner.CornerRadius = UDim.new(0, 10)
					baseUICorner.Parent = colorPicker

					local prompt = Instance.new("Frame")
					prompt.Name = "Prompt"
					prompt.AnchorPoint = Vector2.new(0.5, 0.5)
					prompt.AutomaticSize = Enum.AutomaticSize.Y
					prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
					prompt.BorderColor3 = Color3.fromRGB(0, 0, 0)
					prompt.BorderSizePixel = 0
					prompt.Position = UDim2.fromScale(0.5, 0.5)
					prompt.Size = UDim2.fromOffset(420, 0)

					local globalSettingsUIStroke = Instance.new("UIStroke")
					globalSettingsUIStroke.Name = "GlobalSettingsUIStroke"
					globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
					globalSettingsUIStroke.Transparency = 0.9
					globalSettingsUIStroke.Parent = prompt

					local globalSettingsUICorner = Instance.new("UICorner")
					globalSettingsUICorner.Name = "GlobalSettingsUICorner"
					globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
					globalSettingsUICorner.Parent = prompt

					local uIListLayout = Instance.new("UIListLayout")
					uIListLayout.Name = "UIListLayout"
					uIListLayout.Padding = UDim.new(0, 10)
					uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout.Parent = prompt

					local colorOptions = Instance.new("Frame")
					colorOptions.Name = "ColorOptions"
					colorOptions.AutomaticSize = Enum.AutomaticSize.XY
					colorOptions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					colorOptions.BackgroundTransparency = 1
					colorOptions.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorOptions.BorderSizePixel = 0
					colorOptions.LayoutOrder = 1
					colorOptions.Size = UDim2.fromScale(1, 0)

					локальное значение = Instance.new("TextButton")
					value.Name = "Value"
					value.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
					value.Text = ""
					value.TextColor3 = Color3.fromRGB(0, 0, 0)
					value.TextSize = 14
					value.AutoButtonColor = false
					value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					value.BorderColor3 = Color3.fromRGB(0, 0, 0)
					value.BorderSizePixel = 0
					value.LayoutOrder = 1
					value.Position = UDim2.fromScale(0.092, 0.886)
					value.Size = UDim2.new(1, 0, 0, 15)

					local uIGradient = Instance.new("UIGradient")
					uIGradient.Name = "UIGradient"
					uIGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
					})
					uIGradient.Parent = значение

					local slide = Instance.new("Frame")
					slide.Name = "Слайд"
					slide.AnchorPoint = Vector2.new(0, 0.5)
					slide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					slide.BorderColor3 = Color3.fromRGB(27, 42, 53)
					slide.BorderSizePixel = 0
					slide.Position = UDim2.fromScale(0, 0.5)
					slide.Size = UDim2.new(0, 13, 1, 8)

					local uICorner = Instance.new("UICorner")
					uICorner.Name = "UICorner"
					uICorner.CornerRadius = UDim.new(1, 0)
					uICorner.Parent = slide

					local uIStroke = Instance.new("UIStroke")
					uIStroke.Name = "UIStroke"
					uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					uIStroke.Transparency = 0.5
					uIStroke.Parent = slide

					slide.Parent = value

					local uICorner1 = Instance.new("UICorner")
					uICorner1.Name = "UICorner"
					uICorner1.CornerRadius = UDim.new(0, 6)
					uICorner1.Parent = value

					local uIStroke1 = Instance.new("UIStroke")
					uIStroke1.Name = "UIStroke"
					uIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					uIStroke1.Color = Color3.fromRGB(255, 255, 255)
					uIStroke1.Transparency = 0.9

					local uIGradient1 = Instance.new("UIGradient")
					uIGradient1.Name = "UIGradient"
					uIGradient1.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
					})
					uIGradient1.Rotation = 180
					uIGradient1.Parent = uIStroke1

					uIStroke1.Parent = value

					value.Parent = colorOptions

					local uIListLayout1 = Instance.new("UIListLayout")
					uIListLayout1.Name = "UIListLayout"
					uIListLayout1.Padding = UDim.new(0, 25)
					uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout1.Parent = colorOptions

					local wheel = Instance.new("Frame")
					wheel.Name = "Колесо"
					wheel.AutomaticSize = Enum.AutomaticSize.Y
					wheel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					wheel.BackgroundTransparency = 1
					wheel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					wheel.BorderSizePixel = 0
					wheel.Size = UDim2.new(1, 0, 0, 100)

					local wheel1 = Instance.new("ImageButton")
					wheel1.Name = "Колесо"
					wheel1.Image = "rbxassetid://2849458409"
					wheel1.AutoButtonColor = false
					wheel1.Active = false
					wheel1.BackgroundColor3 = Color3.fromRGB(248, 248, 248)
					wheel1.BackgroundTransparency = 1
					wheel1.BorderColor3 = Color3.fromRGB(27, 42, 53)
					wheel1.Selectable = false
					wheel1.Size = UDim2.fromOffset(220, 220)
					wheel1.SizeConstraint = Enum.SizeConstraint.RelativeYY
		
					local target = Instance.new("ImageLabel")
					target.Name = "Target"
					target.Image = "rbxassetid://73265255323268"
					target.ImageColor3 = Color3.fromRGB(0, 0, 0)
					target.AnchorPoint = Vector2.new(0.5, 0.5)
					target.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					target.BackgroundTransparency = 1
					target.BorderColor3 = Color3.fromRGB(27, 42, 53)
					target.Position = UDim2.fromScale(0.5, 0.5)
					target.Size = UDim2.fromOffset(22, 22)
					target.SizeConstraint = Enum.SizeConstraint.RelativeYY
					target.Parent = wheel1

					wheel1.Parent = wheel

					локальные входные данные = Instance.new("Frame")
					inputs.Name = "Inputs"
					inputs.AnchorPoint = Vector2.new(1, 0.5)
					inputs.AutomaticSize = Enum.AutomaticSize.XY
					inputs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputs.BackgroundTransparency = 1
					inputs.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputs.BorderSizePixel = 0
					inputs.LayoutOrder = 1
					inputs.Position = UDim2.fromScale(1, 0.5)

					local uIListLayout2 = Instance.new("UIListLayout")
					uIListLayout2.Name = "UIListLayout"
					uIListLayout2.Padding = UDim.new(0, 5)
					uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout2.Parent = inputs

					local red = Instance.new("Frame")
					red.Name = "Red"
					red.AutomaticSize = Enum.AutomaticSize.XY
					red.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					red.BackgroundTransparency = 1
					red.BorderColor3 = Color3.fromRGB(0, 0, 0)
					red.BorderSizePixel = 0
					red.LayoutOrder = 1
					red.Size = UDim2.fromOffset(0, 38)

					local inputName = Instance.new("TextLabel")
					inputName.Name = "InputName"
					inputName.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputName.Text = "Красный"
					inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputName.TextSize = 13
					inputName.TextTransparency = 0.5
					inputName.TextTruncate = Enum.TextTruncate.AtEnd
					inputName.TextXAlignment = Enum.TextXAlignment.Left
					inputName.TextYAlignment = Enum.TextYAlignment.Top
					inputName.AnchorPoint = Vector2.new(0, 0.5)
					inputName.AutomaticSize = Enum.AutomaticSize.XY
					inputName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputName.BackgroundTransparency = 1
					inputName.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputName.BorderSizePixel = 0
					inputName.LayoutOrder = 2
					inputName.Position = UDim2.fromScale(0, 0.5)
					inputName.Parent = red

					local uIListLayout3 = Instance.new("UIListLayout")
					uIListLayout3.Name = "UIListLayout"
					uIListLayout3.Padding = UDim.new(0, 15)
					uIListLayout3.FillDirection = Enum.FillDirection.Horizontal
					uIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
					uIListLayout3.Parent = red

					local inputBox = Instance.new("TextBox")
					inputBox.Name = "InputBox"
					inputBox.ClearTextOnFocus = false
					inputBox.CursorPosition = -1
					inputBox.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputBox.Text = "255"
					inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputBox.TextSize = 12
					inputBox.TextTransparency = 0.4
					inputBox.TextXAlignment = Enum.TextXAlignment.Left
					inputBox.AnchorPoint = Vector2.new(1, 0.5)
					inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputBox.BackgroundTransparency = 0.95
					inputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputBox.BorderSizePixel = 0
					inputBox.ClipsDescendants = true
					inputBox.LayoutOrder = 1
					inputBox.Position = UDim2.fromScale(1, 0.5)
					inputBox.Size = UDim2.fromOffset(75, 25)

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

					local inputBoxUISizeConstraint = Instance.new("UISizeConstraint")
					inputBoxUISizeConstraint.Name = "InputBoxUISizeConstraint"
					inputBoxUISizeConstraint.Parent = inputBox

					local inputBoxUIPadding = Instance.new("UIPadding")
					inputBoxUIPadding.Name = "InputBoxUIPadding"
					inputBoxUIPadding.PaddingLeft = UDim.new(0, 8)
					inputBoxUIPadding.PaddingRight = UDim.new(0, 10)
					inputBoxUIPadding.Parent = inputBox

					inputBox.Parent = red

					red.Parent = inputs

					local green = Instance.new("Frame")
					green.Name = "Green"
					green.AutomaticSize = Enum.AutomaticSize.XY
					green.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					green.BackgroundTransparency = 1
					green.BorderColor3 = Color3.fromRGB(0, 0, 0)
					green.BorderSizePixel = 0
					green.LayoutOrder = 2
					green.Size = UDim2.fromOffset(0, 38)

					local inputName1 = Instance.new("TextLabel")
					inputName1.Name = "InputName"
					inputName1.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputName1.Text = "Зеленый"
					inputName1.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputName1.TextSize = 13
					inputName1.TextTransparency = 0.5
					inputName1.TextTruncate = Enum.TextTruncate.AtEnd
					inputName1.TextXAlignment = Enum.TextXAlignment.Left
					inputName1.TextYAlignment = Enum.TextYAlignment.Top
					inputName1.AnchorPoint = Vector2.new(0, 0.5)
					inputName1.AutomaticSize = Enum.AutomaticSize.XY
					inputName1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputName1.BackgroundTransparency = 1
					inputName1.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputName1.BorderSizePixel = 0
					inputName1.LayoutOrder = 2
					inputName1.Position = UDim2.fromScale(0, 0.5)
					inputName1.Parent = green

					local uIListLayout4 = Instance.new("UIListLayout")
					uIListLayout4.Name = "UIListLayout"
					uIListLayout4.Padding = UDim.new(0, 15)
					uIListLayout4.FillDirection = Enum.FillDirection.Horizontal
					uIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout4.VerticalAlignment = Enum.VerticalAlignment.Center
					uIListLayout4.Parent = green

					local inputBox1 = Instance.new("TextBox")
					inputBox1.Name = "InputBox"
					inputBox1.ClearTextOnFocus = false
					inputBox1.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputBox1.Text = "255"
					inputBox1.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputBox1.TextSize = 12
					inputBox1.TextTransparency = 0.4
					inputBox1.TextXAlignment = Enum.TextXAlignment.Left
					inputBox1.AnchorPoint = Vector2.new(1, 0.5)
					inputBox1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputBox1.BackgroundTransparency = 0.95
					inputBox1.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputBox1.BorderSizePixel = 0
					inputBox1.ClipsDescendants = true
					inputBox1.LayoutOrder = 1
					inputBox1.Position = UDim2.fromScale(1, 0.5)
					inputBox1.Size = UDim2.fromOffset(75, 25)

					local inputBoxUICorner1 = Instance.new("UICorner")
					inputBoxUICorner1.Name = "InputBoxUICorner"
					inputBoxUICorner1.CornerRadius = UDim.new(0, 4)
					inputBoxUICorner1.Parent = inputBox1

					local inputBoxUIStroke1 = Instance.new("UIStroke")
					inputBoxUIStroke1.Name = "InputBoxUIStroke"
					inputBoxUIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					inputBoxUIStroke1.Color = Color3.fromRGB(255, 255, 255)
					inputBoxUIStroke1.Transparency = 0.9
					inputBoxUIStroke1.Parent = inputBox1

					local inputBoxUISizeConstraint1 = Instance.new("UISizeConstraint")
					inputBoxUISizeConstraint1.Name = "InputBoxUISizeConstraint"
					inputBoxUISizeConstraint1.Parent = inputBox1

					local inputBoxUIPadding1 = Instance.new("UIPadding")
					inputBoxUIPadding1.Name = "InputBoxUIPadding"
					inputBoxUIPadding1.PaddingLeft = UDim.new(0, 8)
					inputBoxUIPadding1.PaddingRight = UDim.new(0, 10)
					inputBoxUIPadding1.Parent = inputBox1

					inputBox1.Parent = green

					green.Parent = inputs

					local blue = Instance.new("Frame")
					blue.Name = "Blue"
					blue.AutomaticSize = Enum.AutomaticSize.XY
					blue.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					blue.BackgroundTransparency = 1
					blue.BorderColor3 = Color3.fromRGB(0, 0, 0)
					blue.BorderSizePixel = 0
					blue.LayoutOrder = 3
					blue.Size = UDim2.fromOffset(0, 38)

					local inputName2 = Instance.new("TextLabel")
					inputName2.Name = "InputName"
					inputName2.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputName2.Text = "Blue"
					inputName2.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputName2.TextSize = 13
					inputName2.TextTransparency = 0.5
					inputName2.TextTruncate = Enum.TextTruncate.AtEnd
					inputName2.TextXAlignment = Enum.TextXAlignment.Left
					inputName2.TextYAlignment = Enum.TextYAlignment.Top
					inputName2.AnchorPoint = Vector2.new(0, 0.5)
					inputName2.AutomaticSize = Enum.AutomaticSize.XY
					inputName2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputName2.BackgroundTransparency = 1
					inputName2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputName2.BorderSizePixel = 0
					inputName2.LayoutOrder = 2
					inputName2.Position = UDim2.fromScale(0, 0.5)
					inputName2.Parent = blue

					local uIListLayout5 = Instance.new("UIListLayout")
					uIListLayout5.Name = "UIListLayout"
					uIListLayout5.Padding = UDim.new(0, 15)
					uIListLayout5.FillDirection = Enum.FillDirection.Horizontal
					uIListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout5.VerticalAlignment = Enum.VerticalAlignment.Center
					uIListLayout5.Parent = blue

					local inputBox2 = Instance.new("TextBox")
					inputBox2.Name = "InputBox"
					inputBox2.ClearTextOnFocus = false
					inputBox2.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputBox2.Text = "255"
					inputBox2.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputBox2.TextSize = 12
					inputBox2.TextTransparency = 0.4
					inputBox2.TextXAlignment = Enum.TextXAlignment.Left
					inputBox2.AnchorPoint = Vector2.new(1, 0.5)
					inputBox2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputBox2.BackgroundTransparency = 0.95
					inputBox2.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputBox2.BorderSizePixel = 0
					inputBox2.ClipsDescendants = true
					inputBox2.LayoutOrder = 1
					inputBox2.Position = UDim2.fromScale(1, 0.5)
					inputBox2.Size = UDim2.fromOffset(75, 25)

					local inputBoxUICorner2 = Instance.new("UICorner")
					inputBoxUICorner2.Name = "InputBoxUICorner"
					inputBoxUICorner2.CornerRadius = UDim.new(0, 4)
					inputBoxUICorner2.Parent = inputBox2

					local inputBoxUIStroke2 = Instance.new("UIStroke")
					inputBoxUIStroke2.Name = "InputBoxUIStroke"
					inputBoxUIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					inputBoxUIStroke2.Color = Color3.fromRGB(255, 255, 255)
					inputBoxUIStroke2.Transparency = 0.9
					inputBoxUIStroke2.Parent = inputBox2

					local inputBoxUISizeConstraint2 = Instance.new("UISizeConstraint")
					inputBoxUISizeConstraint2.Name = "InputBoxUISizeConstraint"
					inputBoxUISizeConstraint2.Parent = inputBox2

					local inputBoxUIPadding2 = Instance.new("UIPadding")
					inputBoxUIPadding2.Name = "InputBoxUIPadding"
					inputBoxUIPadding2.PaddingLeft = UDim.new(0, 8)
					inputBoxUIPadding2.PaddingRight = UDim.new(0, 10)
					inputBoxUIPadding2.Parent = inputBox2

					inputBox2.Parent = blue

					blue.Parent = inputs

					local alpha = Instance.new("Frame")
					alpha.Name = "Alpha"
					alpha.AutomaticSize = Enum.AutomaticSize.XY
					alpha.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					alpha.BackgroundTransparency = 1
					alpha.BorderColor3 = Color3.fromRGB(0, 0, 0)
					alpha.BorderSizePixel = 0
					alpha.LayoutOrder = 4
					alpha.Size = UDim2.fromOffset(0, 38)
					alpha.Visible = isAlpha

					local inputName3 = Instance.new("TextLabel")
					inputName3.Name = "InputName"
					inputName3.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputName3.Text = "Alpha"
					inputName3.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputName3.TextSize = 13
					inputName3.TextTransparency = 0.5
					inputName3.TextTruncate = Enum.TextTruncate.AtEnd
					inputName3.TextXAlignment = Enum.TextXAlignment.Left
					inputName3.TextYAlignment = Enum.TextYAlignment.Top
					inputName3.AnchorPoint = Vector2.new(0, 0.5)
					inputName3.AutomaticSize = Enum.AutomaticSize.XY
					inputName3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputName3.BackgroundTransparency = 1
					inputName3.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputName3.BorderSizePixel = 0
					inputName3.LayoutOrder = 2
					inputName3.Position = UDim2.fromScale(0, 0.5)
					inputName3.Parent = alpha

					local uIListLayout6 = Instance.new("UIListLayout")
					uIListLayout6.Name = "UIListLayout"
					uIListLayout6.Padding = UDim.new(0, 15)
					uIListLayout6.FillDirection = Enum.FillDirection.Horizontal
					uIListLayout6.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout6.VerticalAlignment = Enum.VerticalAlignment.Center
					uIListLayout6.Parent = alpha

					local inputBox3 = Instance.new("TextBox")
					inputBox3.Name = "InputBox"
					inputBox3.ClearTextOnFocus = false
					inputBox3.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputBox3.Text = "0"
					inputBox3.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputBox3.TextSize = 12
					inputBox3.TextTransparency = 0.4
					inputBox3.TextXAlignment = Enum.TextXAlignment.Left
					inputBox3.AnchorPoint = Vector2.new(1, 0.5)
					inputBox3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputBox3.BackgroundTransparency = 0.95
					inputBox3.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputBox3.BorderSizePixel = 0
					inputBox3.ClipsDescendants = true
					inputBox3.LayoutOrder = 1
					inputBox3.Position = UDim2.fromScale(1, 0.5)
					inputBox3.Size = UDim2.fromOffset(75, 25)

					local inputBoxUICorner3 = Instance.new("UICorner")
					inputBoxUICorner3.Name = "InputBoxUICorner"
					inputBoxUICorner3.CornerRadius = UDim.new(0, 4)
					inputBoxUICorner3.Parent = inputBox3

					local inputBoxUIStroke3 = Instance.new("UIStroke")
					inputBoxUIStroke3.Name = "InputBoxUIStroke"
					inputBoxUIStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					inputBoxUIStroke3.Color = Color3.fromRGB(255, 255, 255)
					inputBoxUIStroke3.Transparency = 0.9
					inputBoxUIStroke3.Parent = inputBox3

					local inputBoxUISizeConstraint3 = Instance.new("UISizeConstraint")
					inputBoxUISizeConstraint3.Name = "InputBoxUISizeConstraint"
					inputBoxUISizeConstraint3.Parent = inputBox3

					local inputBoxUIPadding3 = Instance.new("UIPadding")
					inputBoxUIPadding3.Name = "InputBoxUIPadding"
					inputBoxUIPadding3.PaddingLeft = UDim.new(0, 8)
					inputBoxUIPadding3.PaddingRight = UDim.new(0, 10)
					inputBoxUIPadding3.Parent = inputBox3

					inputBox3.Parent = alpha

					alpha.Parent = inputs

					local hex = Instance.new("Frame")
					hex.Name = "Hex"
					hex.AutomaticSize = Enum.AutomaticSize.XY
					hex.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					hex.BackgroundTransparency = 1
					hex.BorderColor3 = Color3.fromRGB(0, 0, 0)
					hex.BorderSizePixel = 0
					hex.Size = UDim2.fromOffset(0, 38)

					local inputName4 = Instance.new("TextLabel")
					inputName4.Name = "InputName"
					inputName4.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputName4.Text = "Hex"
					inputName4.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputName4.TextSize = 13
					inputName4.TextTransparency = 0.5
					inputName4.TextTruncate = Enum.TextTruncate.AtEnd
					inputName4.TextXAlignment = Enum.TextXAlignment.Left
					inputName4.TextYAlignment = Enum.TextYAlignment.Top
					inputName4.AnchorPoint = Vector2.new(0, 0.5)
					inputName4.AutomaticSize = Enum.AutomaticSize.XY
					inputName4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputName4.BackgroundTransparency = 1
					inputName4.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputName4.BorderSizePixel = 0
					inputName4.LayoutOrder = 2
					inputName4.Position = UDim2.fromScale(0, 0.5)
					inputName4.Parent = hex

					local uIListLayout7 = Instance.new("UIListLayout")
					uIListLayout7.Name = "UIListLayout"
					uIListLayout7.Padding = UDim.new(0, 15)
					uIListLayout7.FillDirection = Enum.FillDirection.Horizontal
					uIListLayout7.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout7.VerticalAlignment = Enum.VerticalAlignment.Center
					uIListLayout7.Parent = hex

					local inputBox4 = Instance.new("TextBox")
					inputBox4.Name = "InputBox"
					inputBox4.ClearTextOnFocus = false
					inputBox4.CursorPosition = -1
					inputBox4.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					inputBox4.Text = "255"
					inputBox4.TextColor3 = Color3.fromRGB(255, 255, 255)
					inputBox4.TextSize = 12
					inputBox4.TextTransparency = 0.4
					inputBox4.TextXAlignment = Enum.TextXAlignment.Left
					inputBox4.AnchorPoint = Vector2.new(1, 0.5)
					inputBox4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					inputBox4.BackgroundTransparency = 0.95
					inputBox4.BorderColor3 = Color3.fromRGB(0, 0, 0)
					inputBox4.BorderSizePixel = 0
					inputBox4.ClipsDescendants = true
					inputBox4.LayoutOrder = 1
					inputBox4.Position = UDim2.fromScale(1, 0.5)
					inputBox4.Size = UDim2.fromOffset(75, 25)

					local inputBoxUICorner4 = Instance.new("UICorner")
					inputBoxUICorner4.Name = "InputBoxUICorner"
					inputBoxUICorner4.CornerRadius = UDim.new(0, 4)
					inputBoxUICorner4.Parent = inputBox4

					local inputBoxUIStroke4 = Instance.new("UIStroke")
					inputBoxUIStroke4.Name = "InputBoxUIStroke"
					inputBoxUIStroke4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					inputBoxUIStroke4.Color = Color3.fromRGB(255, 255, 255)
					inputBoxUIStroke4.Transparency = 0.9
					inputBoxUIStroke4.Parent = inputBox4

					local inputBoxUISizeConstraint4 = Instance.new("UISizeConstraint")
					inputBoxUISizeConstraint4.Name = "InputBoxUISizeConstraint"
					inputBoxUISizeConstraint4.Parent = inputBox4

					local inputBoxUIPadding4 = Instance.new("UIPadding")
					inputBoxUIPadding4.Name = "InputBoxUIPadding"
					inputBoxUIPadding4.PaddingLeft = UDim.new(0, 8)
					inputBoxUIPadding4.PaddingRight = UDim.new(0, 10)
					inputBoxUIPadding4.Parent = inputBox4

					inputBox4.Parent = hex

					hex.Parent = inputs

					inputs.Parent = wheel

					local uIPadding = Instance.new("UIPadding")
					uIPadding.Name = "UIPadding"
					uIPadding.PaddingRight = UDim.new(0, 5)
					uIPadding.Parent = wheel

					wheel.Parent = colorOptions

					local colorWells = Instance.new("Frame")
					colorWells.Name = "ColorWells"
					colorWells.AutomaticSize = Enum.AutomaticSize.Y
					colorWells.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					colorWells.BackgroundTransparency = 1
					colorWells.BorderColor3 = Color3.fromRGB(0, 0, 0)
					colorWells.BorderSizePixel = 0
					colorWells.LayoutOrder = 2
					colorWells.Size = UDim2.fromScale(1, 0)

					local uIGridLayout = Instance.new("UIGridLayout")
					uIGridLayout.Name = "UIGridLayout"
					uIGridLayout.CellPadding = UDim2.fromOffset(10, 0)
					uIGridLayout.CellSize = UDim2.new(0.5, -5, 0, 30)
					uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
					uIGridLayout.Parent = colorWells

					local newColor = Instance.new("ImageLabel")
					newColor.Name = "NewColor"
					newColor.Image = "rbxassetid://121484455191370"
					новыйЦвет.ТипМасштаба = Перечисление.ТипМасштаба.Плитка
					newColor.TileSize = UDim2.fromOffset(500, 500)
					newColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					newColor.BackgroundTransparency = 1
					newColor.BorderColor3 = Color3.fromRGB(0, 0, 0)
					newColor.BorderSizePixel = 0
					newColor.Size = UDim2.fromOffset(100, 100)

					local uICorner2 = Instance.new("UICorner")
					uICorner2.Name = "UICorner"
					uICorner2.Parent = newColor

					локальный цвет = Instance.new("Frame")
					color.Name = "Color"
					color.AnchorPoint = Vector2.new(0.5, 0.5)
					color.BorderColor3 = Color3.fromRGB(27, 42, 53)
					color.BorderSizePixel = 0
					color.Position = UDim2.fromScale(0.5, 0.5)
					color.Size = UDim2.new(1, 1, 1, 1)

					local uICorner3 = Instance.new("UICorner")
					uICorner3.Name = "UICorner"
					uICorner3.Parent = color

					color.Parent = newColor

					newColor.Parent = colorWells

					local oldColor = Instance.new("ImageLabel")
					oldColor.Name = "OldColor"
					oldColor.Image = "rbxassetid://121484455191370"
					oldColor.ScaleType = Enum.ScaleType.Tile
					oldColor.TileSize = UDim2.fromOffset(500, 500)
					oldColor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					oldColor.BackgroundTransparency = 1
					oldColor.BorderColor3 = Color3.fromRGB(0, 0, 0)
					oldColor.BorderSizePixel = 0
					oldColor.LayoutOrder = 1
					oldColor.Size = UDim2.fromOffset(100, 100)

					local uICorner4 = Instance.new("UICorner")
					uICorner4.Name = "UICorner"
					uICorner4.Parent = oldColor

					local color1 = Instance.new("Frame")
					color1.Name = "Color"
					color1.AnchorPoint = Vector2.new(0.5, 0.5)
					color1.BorderColor3 = Color3.fromRGB(27, 42, 53)
					color1.BorderSizePixel = 0
					color1.Position = UDim2.fromScale(0.5, 0.5)
					color1.Size = UDim2.new(1, 1, 1, 1)

					local uICorner5 = Instance.new("UICorner")
					uICorner5.Name = "UICorner"
					uICorner5.Parent = color1

					color1.Parent = oldColor

					oldColor.Parent = colorWells

					colorWells.Parent = colorOptions

					colorOptions.Parent = prompt

					локальные взаимодействия = Instance.new("Frame")
					interactions.Name = "Interactions"
					interactions.AutomaticSize = Enum.AutomaticSize.Y
					interactions.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					interactions.BackgroundTransparency = 1
					interactions.BorderColor3 = Color3.fromRGB(0, 0, 0)
					interactions.BorderSizePixel = 0
					interactions.LayoutOrder = 2
					interactions.Size = UDim2.fromScale(1, 0)

					local uIListLayout8 = Instance.new("UIListLayout")
					uIListLayout8.Name = "UIListLayout"
					uIListLayout8.Padding = UDim.new(0, 10)
					uIListLayout8.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout8.Parent = interactions

					local confirm = Instance.new("TextButton")
					confirm.Name = "Confirm"
					confirm.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.SemiBold,
						Enum.FontStyle.Normal
					)
					confirm.Text = "Подтвердить"
					Confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
					confirm.TextSize = 15
					confirm.TextTransparency = 0.5
					подтвердите.TextTruncate = Enum.TextTruncate.AtEnd
					confirm.AutoButtonColor = false
					confirm.AutomaticSize = Enum.AutomaticSize.Y
					confirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
					confirm.BorderColor3 = Color3.fromRGB(0, 0, 0)
					confirm.BorderSizePixel = 0
					confirm.Size = UDim2.fromScale(1, 0)

					local uIPadding1 = Instance.new("UIPadding")
					uIPadding1.Name = "UIPadding"
					uIPadding1.PaddingBottom = UDim.new(0, 9)
					uIPadding1.PaddingLeft = UDim.new(0, 10)
					uIPadding1.PaddingRight = UDim.new(0, 10)
					uIPadding1.PaddingTop = UDim.new(0, 9)
					uIPadding1.Parent = confirm

					local baseUICorner = Instance.new("UICorner")
					baseUICorner.Name = "BaseUICorner"
					baseUICorner.CornerRadius = UDim.new(0, 10)
					baseUICorner.Parent = confirm

					confirm.Parent = interactions

					local cancel = Instance.new("TextButton")
					cancel.Name = "Отмена"
					cancel.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.SemiBold,
						Enum.FontStyle.Normal
					)
					cancel.Text = "Отмена"
					cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
					cancel.TextSize = 15
					cancel.TextTransparency = 0.5
					cancel.TextTruncate = Enum.TextTruncate.AtEnd
					cancel.AutoButtonColor = false
					cancel.AutomaticSize = Enum.AutomaticSize.Y
					cancel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
					cancel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					cancel.BorderSizePixel = 0
					cancel.Size = UDim2.fromScale(1, 0)

					local baseUICorner1 = Instance.new("UICorner")
					baseUICorner1.Name = "BaseUICorner"
					baseUICorner1.CornerRadius = UDim.new(0, 10)
					baseUICorner1.Parent = cancel

					local uIPadding2 = Instance.new("UIPadding")
					uIPadding2.Name = "UIPadding"
					uIPadding2.PaddingBottom = UDim.new(0, 9)
					uIPadding2.PaddingLeft = UDim.new(0, 10)
					uIPadding2.PaddingRight = UDim.new(0, 10)
					uIPadding2.PaddingTop = UDim.new(0, 9)
					uIPadding2.Parent = cancel

					cancel.Parent = interactions

					local uIPadding3 = Instance.new("UIPadding")
					uIPadding3.Name = "UIPadding"
					uIPadding3.PaddingTop = UDim.new(0, 10)
					uIPadding3.Parent = interactions

					interactions.Parent = prompt

					local globalSettingsUIPadding = Instance.new("UIPadding")
					globalSettingsUIPadding.Name = "GlobalSettingsUIPadding"
					globalSettingsUIPadding.PaddingBottom = UDim.new(0, 20)
					globalSettingsUIPadding.PaddingLeft = UDim.new(0, 20)
					globalSettingsUIPadding.PaddingRight = UDim.new(0, 20)
					globalSettingsUIPadding.PaddingTop = UDim.new(0, 20)
					globalSettingsUIPadding.Parent = prompt

					локальный абзац = Instance.new("Frame")
					paragraph.Name = "Paragraph"
					paragraph.AutomaticSize = Enum.AutomaticSize.Y
					paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					paragraph.BackgroundTransparency = 1
					paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
					paragraph.BorderSizePixel = 0
					paragraph.Size = UDim2.fromScale(1, 0)

					local paragraphHeader = Instance.new("TextLabel")
					paragraphHeader.Name = "ParagraphHeader"
					paragraphHeader.FontFace = Font.new(
						"rbxassetid://12187365364",
						Enum.FontWeight.SemiBold,
						Enum.FontStyle.Normal
					)
					параграфHeader.RichText = правда
					paragraphHeader.Text = Settings.Name
					абзацHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
					paragraphHeader.TextSize = 18
					paragraphHeader.TextTransparency = 0.4
					paragraphHeader.TextWrapped = true
					paragraphHeader.TextYAlignment = Enum.TextYAlignment.Top
					paragraphHeader.AutomaticSize = Enum.AutomaticSize.XY
					paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					paragraphHeader.BackgroundTransparency = 1
					paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
					paragraphHeader.BorderSizePixel = 0
					paragraphHeader.Size = UDim2.fromScale(1, 0)
					paragraphHeader.Parent = paragraph

					local uIListLayout9 = Instance.new("UIListLayout")
					uIListLayout9.Name = "UIListLayout"
					uIListLayout9.Padding = UDim.new(0, 15)
					uIListLayout9.HorizontalAlignment = Enum.HorizontalAlignment.Center
					uIListLayout9.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout9.Parent = paragraph

					local uIPadding4 = Instance.new("UIPadding")
					uIPadding4.Name = "UIPadding"
					uIPadding4.PaddingBottom = UDim.new(0, 15)
					uIPadding4.Parent = paragraph

					локальная строка = Instance.new("Frame")
					line.Name = "Line"
					line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					line.BackgroundTransparency = 0.9
					line.BorderColor3 = Color3.fromRGB(0, 0, 0)
					line.BorderSizePixel = 0
					line.LayoutOrder = 1
					line.Size = UDim2.new(1, 0, 0, 1)
					line.Parent = paragraph

					paragraph.Parent = prompt

					prompt.Parent = colorPicker

					colorPicker.Parent = base
					
					local fromHSV, fromRGB, v2, udim2 = Color3.fromHSV, Color3.fromRGB, Vector2.new, UDim2.new

					локальное колесо = колесо1
					локальное кольцо = цель
					локальный ползунок = значение
					локальный цвет = цвет

					локальный модификаторВходов = {
						Hex = hex.InputBox,
						Красный = red.InputBox,
						Зеленый = green.InputBox,
						Синий = blue.InputBox,
						Альфа = alpha.InputBox
					}

					local Mouse = LocalPlayer:GetMouse()

					local WheelDown, SlideDown = false, false
					локальный оттенок, насыщенность, яркость = 0, 0, 1

					локальная функция toPolar(v)
						return math.atan2(vy, vx), v.magnitude
					конец

					локальная функция radToDeg(x)
						return ((x + math.pi) / (2 * math.pi)) * 360
					конец

					локальная функция degToRad(degrees)
						градусов возврата * (math.pi / 180)
					конец

					локальная функция hexToRGB(hex)
						hex = hex:gsub("#","")
						если #hex ~= 6, то вернуть 0, 0, 0.
						local r = tonumber(hex:sub(1, 2), 16) or 0
						local g = tonumber(hex:sub(3, 4), 16) or 0
						local b = tonumber(hex:sub(5, 6), 16) or 0
						возвращать r, g, b
					конец

					локальная функция clampInput(value, min, max)
						local num = tonumber(value)
						если число тогда
							return math.clamp(num, min, max)
						конец
						возврат мин
					конец

					локальная функция update()
						local c = fromHSV(hue, saturation, value)
						colour.BackgroundColor3 = c
						colour.BackgroundTransparency = clampInput(modifierInputs.Alpha.Text, 0, 1)

						modifierInputs.Red.Text = tostring(math.floor(cr * 255 + 0.5))
						modifierInputs.Green.Text = tostring(math.floor(cg * 255 + 0.5))
						modifierInputs.Blue.Text = tostring(math.floor(cb * 255 + 0.5))
						modifierInputs.Alpha.Text = clampInput(modifierInputs.Alpha.Text, 0, 1)

						local hexColor = string.format("#%02X%02X%02X",
							math.floor(cr * 255 + 0.5),
							math.floor(cg * 255 + 0.5),
							math.floor(cb * 255 + 0.5))
						modifierInputs.Hex.Text = hexColor
					конец

					локальная функция UpdateSlide(iX)
						local rY = iX - slider.AbsolutePosition.X
						local cY = math.clamp(rY, 0, slider.AbsoluteSize.X - slide.AbsoluteSize.X)
						slide.Position = udim2(0, cY, 0.5, 0)
						значение = 1 - (cY / (slider.AbsoluteSize.X - slide.AbsoluteSize.X))
						обновлять()
					конец

					локальная функция UpdateRing(iX, iY)
						local r = wheel.AbsoluteSize.x / 2
						local d = v2(iX, iY) - wheel.AbsolutePosition - wheel.AbsoluteSize / 2

						если d:Dot(d) > r * r тогда
							d = d.единица * r
						конец

						ring.Position = udim2(0.5, dx, 0.5, dy)
						локальное фи, len = toPolar(d * v2(1, -1))
						оттенок, насыщенность = radToDeg(phi) / 360, math.clamp(len / r, 0, 1)
						slider.BackgroundColor3 = fromHSV(hue, saturation, 1)
						обновлять()
					конец

					локальная функция UpdateSlideFromValue(value)
						local cY = (1 - value) * (slider.AbsoluteSize.X - slide.AbsoluteSize.X)
						slide.Position = UDim2.new(0, cY, 0.5, 0)
					конец

					локальная функция UpdateRingFromHSV(hue, saturation)
						local r = wheel.AbsoluteSize.X / 2
						локальное фи = degToRad (оттенок * 360)
						локальная длина = насыщенность * r
						local x = len * math.cos(phi)
						local y = len * math.sin(phi)

						ring.Position = UDim2.new(0.5, -x, 0.5, y)
						slider.BackgroundColor3 = fromHSV(hue, saturation, 1)
					конец

					локальная функция updateFromRGB()
						local r = clampInput(modifierInputs.Red.Text, 0, 255)
						local g = clampInput(modifierInputs.Green.Text, 0, 255)
						local b = clampInput(modifierInputs.Blue.Text, 0, 255)
						modifierInputs.Red.Text = r
						modifierInputs.Green.Text = g
						modifierInputs.Blue.Text = b

						оттенок, насыщенность, значение = Color3.fromRGB(r, g, b):ToHSV()

						UpdateSlideFromValue(value)
						UpdateRingFromHSV(hue, saturation)
						обновлять()
					конец

					локальная функция updateFromHex()
						local hex = modifierInputs.Hex.Text
						local r, g, b = hexToRGB(hex)

						r = clampInput(r, 0, 255)
						g = clampInput(g, 0, 255)
						b = clampInput(b, 0, 255)

						modifierInputs.Red.Text = r
						modifierInputs.Green.Text = g
						modifierInputs.Blue.Text = b

						оттенок, насыщенность, значение = Color3.fromRGB(r, g, b):ToHSV()
						UpdateSlideFromValue(value)
						UpdateRingFromHSV(hue, saturation)
						обновлять()
					конец
					
					локальная функция updateFromSettings()
						local r = math.floor(ColorpickerFunctions.Color.R * 255 + 0.5)
						local g = math.floor(ColorpickerFunctions.Color.G * 255 + 0.5)
						local b = math.floor(ColorpickerFunctions.Color.B * 255 + 0.5)
						modifierInputs.Red.Text = r
						modifierInputs.Green.Text = g
						modifierInputs.Blue.Text = b
						modifierInputs.Alpha.Text = isAlpha and ColorpickerFunctions.Alpha or 0
						
						local hexColor = string.format("#%02X%02X%02X", r,g,b)
						modifierInputs.Hex.Text = hexColor

						оттенок, насыщенность, значение = Color3.fromRGB(r, g, b):ToHSV()
						
						color1.BackgroundColor3 = ColorpickerFunctions.Color
						color1.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0

						colour.BackgroundColor3 = Color3.fromRGB(r,g,b)
						colour.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0

						UpdateSlideFromValue(value)
						UpdateRingFromHSV(hue, saturation)
					конец

					wheel.InputBegan:Connect(function(input)
						если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
							WheelDown = true
							UpdateRing(Mouse.X, Mouse.Y)
						конец
					конец)

					slider.InputBegan:Connect(function(input)
						если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
							SlideDown = true
							UpdateSlide(Mouse.X)
						конец
					конец)

					slider.InputEnded:Connect(function(input)
						если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
							SlideDown = false
						конец
					конец)

					wheel.InputEnded:Connect(function(input)
						если input.UserInputType == Enum.UserInputType.MouseButton1 или input.UserInputType == Enum.UserInputType.Touch тогда
							WheelDown = false
						конец
					конец)

					UserInputService.InputChanged:Connect(function(input)
						Если input.UserInputType == Enum.UserInputType.MouseMovement или input.UserInputType == Enum.UserInputType.Touch, то
							если SlideDown тогда
								UpdateSlide(Mouse.X)
							elseif WheelDown then
								UpdateRing(Mouse.X, Mouse.Y)
							конец
						конец
					конец)

					локальная функция onFocusEnter(instance)
						локальный заполнитель = экземпляр.текст
						instance.Text = ""
						instance.PlaceholderText = placeholder
					конец

					modifierInputs.Hex.FocusLost:Connect(updateFromHex)
					modifierInputs.Red.FocusLost:Connect(updateFromRGB)
					modifierInputs.Green.FocusLost:Connect(updateFromRGB)
					modifierInputs.Blue.FocusLost:Connect(updateFromRGB)
					modifierInputs.Alpha.FocusLost:Connect(update)

					modifierInputs.Hex.Focused:Connect(function()
						onFocusEnter(modifierInputs.Hex)
					конец)
					modifierInputs.Red.Focused:Connect(function()
						onFocusEnter(modifierInputs.Red)
					конец)
					modifierInputs.Green.Focused:Connect(function()
						onFocusEnter(modifierInputs.Green)
					конец)
					modifierInputs.Blue.Focused:Connect(function()
						onFocusEnter(modifierInputs.Blue)
					конец)
					modifierInputs.Alpha.Focused:Connect(function()
						onFocusEnter(modifierInputs.Alpha)
					конец)
					
					локальная функция makeCanvas()
						local ColorPickerCanvas = Instance.new("CanvasGroup")
						ColorPickerCanvas.Name = "ColorPickerCanvas"
						ColorPickerCanvas.BackgroundTransparency = 1
						ColorPickerCanvas.BorderSizePixel = 0
						ColorPickerCanvas.Size = UDim2.fromScale(1, 1)
						ColorPickerCanvas.ZIndex = 5
						ColorPickerCanvas.GroupTransparency = 1
						ColorPickerCanvas.Parent = base
						ColorPickerCanvas.Visible = false
						return ColorPickerCanvas
					конец

					локальная функция transition(isIn)
						local canvas = makeCanvas()
						local tweenTransparency = isIn and 0 or 1
						local stateTransparency = isIn and 1 or 0
						local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
						local canvasTween = Tween(canvas, tweenInfo, { GroupTransparency = tweenTransparency })

						colorPicker.Visible = true
						colorPicker.Parent = canvas
						canvas.Visible = true
						canvas.GroupTransparency = stateTransparency
						canvasTween:Play()
						canvasTween.Completed:Wait()

						если не isIn тогда
							colorPicker.Visible = false
							canvas.Visible = false
						конец

						colorPicker.Parent = base
						canvas:Destroy()
					конец

					локальная функция colorpickerIn()
						переход(истина)
					конец

					локальная функция colorpickerOut()
						transition(false)
					конец

					interact.MouseButton1Click:Connect(colorpickerIn)
					
					cancel.MouseButton1Click:Connect(colorpickerOut)
					confirm.MouseButton1Click:Connect(function()
						colorpickerOut()
						local c = fromHSV(hue, saturation, value)
						ColorpickerFunctions.Color = Color3.fromRGB(cr * 255, cg * 255, cb * 255)
						ColorpickerFunctions.Alpha = isAlpha and clampInput(modifierInputs.Alpha.Text, 0, 1)
						
						color1.BackgroundColor3 = ColorpickerFunctions.Color
						color1.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
						
						colorC.BackgroundColor3 = ColorpickerFunctions.Color
						colorC.BackgroundTransparency = isAlpha and ColorpickerFunctions.Alpha or 0
						
						если Settings.Callback тогда
							task.spawn(function()
								Settings.Callback(ColorpickerFunctions.Color, isAlpha and ColorpickerFunctions.Alpha)
							конец)
						конец
					конец)
					
					updateFromSettings()
					
					функция ColorpickerFunctions:UpdateName(New)
						colorpickerName.Text = New
					конец
					функция ColorpickerFunctions:SetVisibility(State)
						colorpicker.Visible = State
					конец
			
					функция ColorpickerFunctions:SetColor(color3)
						ColorpickerFunctions.Color = color3
						colorC.BackgroundColor3 = color3
						
						local r = math.floor(ColorpickerFunctions.Color.R * 255 + 0.5)
						local g = math.floor(ColorpickerFunctions.Color.G * 255 + 0.5)
						local b = math.floor(ColorpickerFunctions.Color.B * 255 + 0.5)
						modifierInputs.Red.Text = r
						modifierInputs.Green.Text = g
						modifierInputs.Blue.Text = b

						local hexColor = string.format("#%02X%02X%02X", r,g,b)
						modifierInputs.Hex.Text = hexColor

						оттенок, насыщенность, значение = Color3.fromRGB(r, g, b):ToHSV()

						color1.BackgroundColor3 = ColorpickerFunctions.Color
						colour.BackgroundColor3 = Color3.fromRGB(r,g,b)

						UpdateSlideFromValue(value)
						UpdateRingFromHSV(hue, saturation)
					конец
					
					функция ColorpickerFunctions:SetAlpha(alpha)
						ColorpickerFunctions.Alpha = alpha
						colorC.Transparency = alpha
						updateFromSettings()
					конец
					
					return ColorpickerFunctions
				конец
				
				функция SectionFunctions:Header(Settings)
					local HeaderFunctions = {}
					
					локальный заголовок = Instance.new("Frame")
					header.Name = "Header"
					header.AutomaticSize = Enum.AutomaticSize.Y
					header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					header.BackgroundTransparency = 1
					header.BorderColor3 = Color3.fromRGB(0, 0, 0)
					header.BorderSizePixel = 0
					header.LayoutOrder = 0
					header.Size = UDim2.fromScale(1, 0)
					header.Parent = section
					
					local uIPadding = Instance.new("UIPadding")
					uIPadding.Name = "UIPadding"
					uIPadding.PaddingBottom = UDim.new(0, 5)
					uIPadding.Parent = header

					local headerText = Instance.new("TextLabel")
					headerText.Name = "HeaderText"
					headerText.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.SemiBold,
						Enum.FontStyle.Normal
					)
					headerText.RichText = true
					headerText.Text = Settings.Text or Settings.Name
					headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
					headerText.TextSize = 16
					headerText.TextTransparency = 0.4
					headerText.TextWrapped = true
					headerText.TextXAlignment = Enum.TextXAlignment.Left
					headerText.AutomaticSize = Enum.AutomaticSize.Y
					headerText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					headerText.BackgroundTransparency = 1
					headerText.BorderColor3 = Color3.fromRGB(0, 0, 0)
					headerText.BorderSizePixel = 0
					headerText.Size = UDim2.fromScale(1, 0)
					headerText.Parent = header
					
					функция HeaderFunctions:UpdateName(New)
						headerText.Text = Новый
					конец
					функция HeaderFunctions:SetVisibility(State)
						header.Visible = State
					конец
					
					return HeaderFunctions
				конец
				
				функция SectionFunctions:Label(Settings)
					local LabelFunctions = {}
					
					локальная метка = Instance.new("Frame")
					label.Name = "Label"
					label.AutomaticSize = Enum.AutomaticSize.Y
					label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					label.BackgroundTransparency = 1
					label.BorderColor3 = Color3.fromRGB(0, 0, 0)
					label.BorderSizePixel = 0
					label.Size = UDim2.new(1, 0, 0, 38)
					label.Parent = section

					local labelText = Instance.new("TextLabel")
					labelText.Name = "LabelText"
					labelText.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					labelText.RichText = true
					labelText.Text = Settings.Text или Settings.Name -- Settings.Name Устарело
					labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
					labelText.TextSize = 13
					labelText.TextTransparency = 0,5
					labelText.TextWrapped = true
					labelText.TextXAlignment = Enum.TextXAlignment.Left
					labelText.AutomaticSize = Enum.AutomaticSize.Y
					labelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					labelText.BackgroundTransparency = 1
					labelText.BorderColor3 = Color3.fromRGB(0, 0, 0)
					labelText.BorderSizePixel = 0
					labelText.Size = UDim2.fromScale(1, 1)
					labelText.Parent = label
					
					функция LabelFunctions:UpdateName(New)
						labelText.Text = Новый
					конец
					функция LabelFunctions:SetVisibility(State)
						label.Visible = State
					конец
					
					return LabelFunctions
				конец
				
				function SectionFunctions:SubLabel(Settings)
					local SubLabelFunctions = {}

					local subLabel = Instance.new("Frame")
					subLabel.Name = "SubLabel"
					subLabel.AutomaticSize = Enum.AutomaticSize.Y
					subLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					subLabel.BackgroundTransparency = 1
					subLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					subLabel.BorderSizePixel = 0
					subLabel.Size = UDim2.new(1, 0, 0, 0)
					subLabel.Parent = section

					local subLabelText = Instance.new("TextLabel")
					subLabelText.Name = "SubLabelText"
					subLabelText.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					subLabelText.RichText = true
					subLabelText.Text = Settings.Text или Settings.Name -- Settings.Name Устарело
					subLabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
					subLabelText.TextSize = 11
					subLabelText.TextTransparency = 0.7
					subLabelText.TextWrapped = true
					subLabelText.TextXAlignment = Enum.TextXAlignment.Left
					subLabelText.AutomaticSize = Enum.AutomaticSize.Y
					subLabelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					subLabelText.BackgroundTransparency = 1
					subLabelText.BorderColor3 = Color3.fromRGB(0, 0, 0)
					subLabelText.BorderSizePixel = 0
					subLabelText.Size = UDim2.fromScale(1, 1)
					subLabelText.Parent = subLabel

					функция SubLabelFunctions:UpdateName(New)
						subLabelText.Text = "Новый"
					конец
					функция SubLabelFunctions:SetVisibility(State)
						subLabel.Visible = State
					конец

					return SubLabelFunctions
				конец
				
				функция SectionFunctions:Paragraph(Settings)
					local ParagraphFunctions = {}

					локальный абзац = Instance.new("Frame")
					paragraph.Name = "Paragraph"
					paragraph.AutomaticSize = Enum.AutomaticSize.Y
					paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					paragraph.BackgroundTransparency = 1
					paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
					paragraph.BorderSizePixel = 0
					paragraph.Size = UDim2.new(1, 0, 0, 38)
					paragraph.Parent = section

					local paragraphHeader = Instance.new("TextLabel")
					paragraphHeader.Name = "ParagraphHeader"
					paragraphHeader.FontFace = Font.new(
						assets.interFont,
						Enum.FontWeight.Medium,
						Enum.FontStyle.Normal
					)
					параграфHeader.RichText = правда
					paragraphHeader.Text = Settings.Header
					абзацHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
					paragraphHeader.TextSize = 16
					paragraphHeader.TextTransparency = 0.4
					paragraphHeader.TextWrapped = true
					paragraphHeader.TextXAlignment = Enum.TextXAlignment.Left
					paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
					paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					paragraphHeader.BackgroundTransparency = 1
					paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
					paragraphHeader.BorderSizePixel = 0
					paragraphHeader.Size = UDim2.fromScale(1, 0)
					paragraphHeader.Parent = paragraph

					local uIListLayout = Instance.new("UIListLayout")
					uIListLayout.Name = "UIListLayout"
					uIListLayout.Padding = UDim.new(0, 5)
					uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout.Parent = paragraph

					local paragraphBody = Instance.new("TextLabel")
					paragraphBody.Name = "ParagraphBody"
					paragraphBody.FontFace = Font.new(assets.interFont)
					paragraphBody.RichText = true
					paragraphBody.Text = Settings.Body
					параграфBody.TextColor3 = Color3.fromRGB(255, 255, 255)
					paragraphBody.TextSize = 13
					paragraphBody.TextTransparency = 0.5
					paragraphBody.TextWrapped = true
					paragraphBody.TextXAlignment = Enum.TextXAlignment.Left
					paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
					paragraphBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					paragraphBody.BackgroundTransparency = 1
					paragraphBody.BorderColor3 = Color3.fromRGB(0, 0, 0)
					paragraphBody.BorderSizePixel = 0
					paragraphBody.LayoutOrder = 1
					paragraphBody.Size = UDim2.fromScale(1, 0)
					paragraphBody.Parent = paragraph

					функция ParagraphFunctions:UpdateHeader(New)
						paragraphHeader.Text = New
					конец
					функция ParagraphFunctions:UpdateBody(New)
						paragraphBody.Text = New
					конец
					функция ParagraphFunctions:SetVisibility(State)
						paragraph.Visible = State
					конец

					return ParagraphFunctions
				конец
				
				функция SectionFunctions:Divider()
					local DividerFunctions = {}
					
					local divider = Instance.new("Frame")
					divider.Name = "Разделитель"
					divider.AnchorPoint = Vector2.new(0, 1)
					divider.AutomaticSize = Enum.AutomaticSize.Y
					divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					divider.BackgroundTransparency = 1
					divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
					divider.BorderSizePixel = 0
					divider.Position = UDim2.fromScale(0, 1)
					divider.Size = UDim2.new(1, 0, 0, 1)
					divider.Parent = section

					local uIPadding = Instance.new("UIPadding")
					uIPadding.Name = "UIPadding"
					uIPadding.PaddingBottom = UDim.new(0, 8)
					uIPadding.PaddingTop = UDim.new(0, 8)
					uIPadding.Parent = divider

					local uIListLayout = Instance.new("UIListLayout")
					uIListLayout.Name = "UIListLayout"
					uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					uIListLayout.Parent = divider

					локальная строка = Instance.new("Frame")
					line.Name = "Line"
					line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					line.BackgroundTransparency = 0.9
					line.BorderColor3 = Color3.fromRGB(0, 0, 0)
					line.BorderSizePixel = 0
					line.Size = UDim2.new(1, 0, 0, 1)
					line.Parent = divider
					
					функция DividerFunctions:Remove()
						divider:Destroy()
					конец
					функция DividerFunctions:SetVisibility(State)
						divider.Visible = State
					конец
					
					return DividerFunctions
				конец
				
				функция SectionFunctions:Spacer()
					local SpacerFunctions = {}

					local spacer = Instance.new("Frame")
					spacer.Name = "Spacer"
					spacer.AnchorPoint = Vector2.new(0, 1)
					spacer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					spacer.BackgroundTransparency = 1
					spacer.BorderColor3 = Color3.fromRGB(0, 0, 0)
					spacer.BorderSizePixel = 0
					spacer.Position = UDim2.fromScale(0, 1)
					spacer.Parent = section

					функция SpacerFunctions:Remove()
						spacer:Destroy()
					конец
					функция SpacerFunctions:SetVisibility(State)
						spacer.Visible = State
					конец

					return SpacerFunctions
				конец
				return SectionFunctions
			конец

			локальная функция SelectCurrentTab()
				local easetime = 0.15

				если currentTabInstance, то
					currentTabInstance.Parent = nil
				конец

				for _, v in pairs(tabSwitchersScrollingFrame:GetDescendants()) do
					если v.Name == "TabSwitcher", то
						Tween(v, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
							BackgroundTransparency = 1
						}):Играть()
						Tween(v:FindFirstChild("TabSwitcherUIStroke"), TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
							Прозрачность = 1
						}):Играть()
					конец
				конец

				tabs[tabSwitcher].Parent = content
				currentTabInstance = tabs[tabSwitcher]
				currentTab.Text = Settings.Name

				Tween(tabSwitcher, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
					Прозрачность фона = 0,98
				}):Играть()
				Tween(tabSwitcherUIStroke, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
					Прозрачность = 0,95
				}):Играть()
			конец

			tabSwitcher.MouseButton1Click:Connect(function()
				SelectCurrentTab()
			конец)

			функция TabFunctions:Select()
				SelectCurrentTab()
			конец

			tabs[tabSwitcher] = elements1
			return TabFunctions
		конец

		return SectionFunctions
	конец

	function WindowFunctions:Notify(Settings)
		local NotificationFunctions = {}
		
		локальное уведомление = Instance.new("Frame")
		notification.Name = "Уведомление"
		notification.AnchorPoint = Vector2.new(0.5, 0.5)
		notification.AutomaticSize = Enum.AutomaticSize.Y
		notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notification.BorderSizePixel = 0
		notification.Position = UDim2.fromScale(0.5, 0.5)
		notification.Size = UDim2.fromOffset(Settings.SizeX or 250, 0)
		
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
		notificationUIScale.Parent = notification
		notificationUIScale.Scale = 0

		local notificationInformation = Instance.new("Frame")
		notificationInformation.Name = "NotificationInformation"
		notificationInformation.AutomaticSize = Enum.AutomaticSize.Y
		notificationInformation.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationInformation.BackgroundTransparency = 1
		notificationInformation.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationInformation.BorderSizePixel = 0
		notificationInformation.Size = UDim2.fromScale(1, 1)

		local notificationTitle = Instance.new("TextLabel")
		notificationTitle.Name = "NotificationTitle"
		notificationTitle.FontFace = Font.new(
			assets.interFont,
			Enum.FontWeight.SemiBold,
			Enum.FontStyle.Normal
		)
		notificationTitle.RichText = true
		notificationTitle.Text = Settings.Title
		NotificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationTitle.TextSize = 13
		notificationTitle.TextTransparency = 0.2
		notificationTitle.TextTruncate = Enum.TextTruncate.SplitWord
		notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
		notificationTitle.TextYAlignment = Enum.TextYAlignment.Top
		notificationTitle.AutomaticSize = Enum.AutomaticSize.XY
		notificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationTitle.BackgroundTransparency = 1
		notificationTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationTitle.BorderSizePixel = 0
		notificationTitle.Size = UDim2.new(1, -12, 0, 0)

		local notificationTitleUIPadding = Instance.new("UIPadding")
		notificationTitleUIPadding.Name = "NotificationTitleUIPadding"
		notificationTitleUIPadding.PaddingRight = UDim.new(0, 25)
		notificationTitleUIPadding.Parent = notificationTitle

		notificationTitle.Parent = notificationInformation

		local notificationDescription = Instance.new("TextLabel")
		notificationDescription.Name = "NotificationDescription"
		notificationDescription.FontFace = Font.new(
			assets.interFont,
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		)
		notificationDescription.Text = Settings.Description
		NotificationDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationDescription.TextSize = 11
		notificationDescription.TextTransparency = 0.5
		notificationDescription.TextWrapped = true
		notificationDescription.RichText = true
		notificationDescription.TextXAlignment = Enum.TextXAlignment.Left
		notificationDescription.TextYAlignment = Enum.TextYAlignment.Top
		notificationDescription.AutomaticSize = Enum.AutomaticSize.XY
		notificationDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationDescription.BackgroundTransparency = 1
		notificationDescription.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationDescription.BorderSizePixel = 0
		notificationDescription.Size = UDim2.new(1, -12, 0, 0)

		local notificationDescriptionUIPadding = Instance.new("UIPadding")
		notificationDescriptionUIPadding.Name = "NotificationDescriptionUIPadding"
		notificationDescriptionUIPadding.PaddingRight = UDim.new(0, 25)
		notificationDescriptionUIPadding.PaddingTop = UDim.new(0, 17)
		notificationDescriptionUIPadding.Parent = notificationDescription

		notificationDescription.Parent = notificationInformation

		local notificationUIPadding = Instance.new("UIPadding")
		notificationUIPadding.Name = "NotificationUIPadding"
		notificationUIPadding.PaddingBottom = UDim.new(0, 12)
		notificationUIPadding.PaddingLeft = UDim.new(0, 10)
		notificationUIPadding.PaddingRight = UDim.new(0, 10)
		notificationUIPadding.PaddingTop = UDim.new(0, 10)
		notificationUIPadding.Parent = notificationInformation

		notificationInformation.Parent = notification

		local notificationControls = Instance.new("Frame")
		notificationControls.Name = "NotificationControls"
		notificationControls.AutomaticSize = Enum.AutomaticSize.Y
		notificationControls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationControls.BackgroundTransparency = 1
		notificationControls.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationControls.BorderSizePixel = 0
		notificationControls.Size = UDim2.fromScale(1, 1)

		local interactable = Instance.new("TextButton")
		interactable.Name = "Interactable"
		interactable.FontFace = Font.new(assets.interFont)
		interactable.Text = "вњ“"
		интерактивный.TextColor3 = Color3.fromRGB(255, 255, 255)
		interactable.TextSize = 17
		interactable.TextTransparency = 0.2
		interactable.AnchorPoint = Vector2.new(1, 0.5)
		interactable.AutomaticSize = Enum.AutomaticSize.XY
		interactable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		interactable.BackgroundTransparency = 1
		interactable.BorderColor3 = Color3.fromRGB(0, 0, 0)
		interactable.BorderSizePixel = 0
		interactable.LayoutOrder = 1
		interactable.Position = UDim2.fromScale(1, 0.5)
		interactable.Parent = notificationControls

		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingBottom = UDim.new(0, 6)
		uIPadding.PaddingRight = UDim.new(0, 13)
		uIPadding.PaddingTop = UDim.new(0, 6)
		uIPadding.Parent = notificationControls

		notificationControls.Parent = notification
		
		локальные анимации = {
			In = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Масштаб = Settings.Scale или 1
			}),
			Out = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Масштаб = 0
			}),
		}
		
		локальные стили = {
			None = function() interactable:Destroy() end,
			Confirm = function() interactable.Text = "вњ"" end,
			Отмена = функция() interactable.Text = "вњ—" конец
		}

		local style = styles[Settings.Style] or function() interactable:Destroy() end
		стиль()

		если он интерактивный, то
			interactable.MouseButton1Click:Connect(function()
				NotificationFunctions:Cancel()
				если Settings.Callback тогда
					task.spawn(Settings.Callback)
				конец
			конец)
		конец
	
		local AnimateNotification = task.spawn(function()
			tweens.In:Play()
			
			Settings.Lifetime = Settings.Lifetime или 3

			Если Settings.Lifetime ≤ 0, то
				task.wait(Settings.Lifetime)

				local out = tweens.Out
				out:Play()
				out.Completed:Wait()
				уведомление:Уничтожить()
			конец
		конец)
		
		функция NotificationFunctions:UpdateTitle(New)
			notificationTitle.Text = "Новый"
		конец
		
		функция NotificationFunctions:UpdateDescription(New)
			notificationDescription.Text = Новый
		конец
		
		функция NotificationFunctions:Resize(X)
			локальная цель = X или 250
			notification.Size = UDim2.fromOffset(targ, 0)
		конец
		
		функция NotificationFunctions:Cancel()
			task.cancel(AnimateNotification)
			
			local out = tweens.Out
			out:Play()
			out.Completed:Wait()
			уведомление:Уничтожить()
		конец
		
		return NotificationFunctions
	конец
	
	function WindowFunctions:Dialog(Settings)
		local DialogFunctions = {}
		
		local dialogCanvas = Instance.new("CanvasGroup")
		dialogCanvas.Name = "DialogCanvas"
		dialogCanvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dialogCanvas.BackgroundTransparency = 1
		dialogCanvas.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dialogCanvas.BorderSizePixel = 0
		dialogCanvas.Size = UDim2.fromScale(1, 1)
		dialogCanvas.GroupTransparency = 1
		dialogCanvas.Parent = base

		local dialog = Instance.new("Frame")
		dialog.Name = "Диалог"
		dialog.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dialog.BackgroundTransparency = 0.5
		dialog.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dialog.BorderSizePixel = 0
		dialog.Size = UDim2.fromScale(1, 1)

		local baseUICorner = Instance.new("UICorner")
		baseUICorner.Name = "BaseUICorner"
		baseUICorner.CornerRadius = UDim.new(0, 10)
		baseUICorner.Parent = dialog

		local prompt = Instance.new("Frame")
		prompt.Name = "Prompt"
		prompt.AnchorPoint = Vector2.new(0.5, 0.5)
		prompt.AutomaticSize = Enum.AutomaticSize.Y
		prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		prompt.BorderColor3 = Color3.fromRGB(0, 0, 0)
		prompt.BorderSizePixel = 0
		prompt.Position = UDim2.fromScale(0.5, 0.5)
		prompt.Size = UDim2.fromOffset(280, 0)

		local globalSettingsUIStroke = Instance.new("UIStroke")
		globalSettingsUIStroke.Name = "GlobalSettingsUIStroke"
		globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
		globalSettingsUIStroke.Transparency = 0.9
		globalSettingsUIStroke.Parent = prompt

		local globalSettingsUICorner = Instance.new("UICorner")
		globalSettingsUICorner.Name = "GlobalSettingsUICorner"
		globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
		globalSettingsUICorner.Parent = prompt

		local globalSettingsUIPadding = Instance.new("UIPadding")
		globalSettingsUIPadding.Name = "GlobalSettingsUIPadding"
		globalSettingsUIPadding.PaddingBottom = UDim.new(0, 20)
		globalSettingsUIPadding.PaddingLeft = UDim.new(0, 20)
		globalSettingsUIPadding.PaddingRight = UDim.new(0, 20)
		globalSettingsUIPadding.PaddingTop = UDim.new(0, 20)
		globalSettingsUIPadding.Parent = prompt

		локальный абзац = Instance.new("Frame")
		paragraph.Name = "Paragraph"
		paragraph.AutomaticSize = Enum.AutomaticSize.Y
		paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		paragraph.BackgroundTransparency = 1
		paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paragraph.BorderSizePixel = 0
		paragraph.Size = UDim2.new(1, 0, 0, 38)

		local paragraphHeader = Instance.new("TextLabel")
		paragraphHeader.Name = "ParagraphHeader"
		paragraphHeader.FontFace = Font.new(
			assets.interFont,
			Enum.FontWeight.SemiBold,
			Enum.FontStyle.Normal
		)
		параграфHeader.RichText = правда
		paragraphHeader.Text = Settings.Title
		абзацHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
		paragraphHeader.TextSize = 18
		paragraphHeader.TextTransparency = 0.4
		paragraphHeader.TextWrapped = true
		paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
		paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		paragraphHeader.BackgroundTransparency = 1
		paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paragraphHeader.BorderSizePixel = 0
		paragraphHeader.Size = UDim2.fromScale(1, 0)
		paragraphHeader.Parent = paragraph

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 15)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = paragraph

		local paragraphBody = Instance.new("TextLabel")
		paragraphBody.Name = "ParagraphBody"
		paragraphBody.FontFace = Font.new(
			assets.interFont,
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		)
		paragraphBody.RichText = true
		paragraphBody.Text = Settings.Description
		параграфBody.TextColor3 = Color3.fromRGB(255, 255, 255)
		paragraphBody.TextSize = 14
		paragraphBody.TextTransparency = 0.5
		paragraphBody.TextWrapped = true
		paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
		paragraphBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		paragraphBody.BackgroundTransparency = 1
		paragraphBody.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paragraphBody.BorderSizePixel = 0
		paragraphBody.LayoutOrder = 1
		paragraphBody.Size = UDim2.fromScale(1, 0)
		paragraphBody.Parent = paragraph

		paragraph.Parent = prompt

		локальные взаимодействия = Instance.new("Frame")
		interactions.Name = "Interactions"
		interactions.AutomaticSize = Enum.AutomaticSize.Y
		interactions.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		interactions.BackgroundTransparency = 1
		interactions.BorderColor3 = Color3.fromRGB(0, 0, 0)
		interactions.BorderSizePixel = 0
		interactions.LayoutOrder = 1
		interactions.Size = UDim2.fromScale(1, 0)

		local uIListLayout1 = Instance.new("UIListLayout")
		uIListLayout1.Name = "UIListLayout"
		uIListLayout1.Padding = UDim.new(0, 10)
		uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout1.Parent = interactions

		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingTop = UDim.new(0, 20)
		uIPadding.Parent = interactions

		interactions.Parent = prompt

		local uIListLayout2 = Instance.new("UIListLayout")
		uIListLayout2.Name = "UIListLayout"
		uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout2.Parent = prompt

		prompt.Parent = dialog

		dialog.Parent = dialogCanvas
		
		local canvasIn = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			GroupTransparency = 0,
		})
		local canvasOut = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			GroupTransparency = 1,
		})
		
		локальная функция dialogIn()
			canvasIn:Play()
			canvasIn.Completed:Wait()
			dialog.Parent = base
		конец
		
		локальная функция dialogOut()
			dialog.Parent = dialogCanvas

			canvasOut:Play()
			canvasOut.Completed:Wait()
			dialogCanvas:Destroy()
		конец
		
		for _, v in pairs(Settings.Buttons) do
			локальная кнопка = Instance.new("TextButton")
			button.Name = "Button"
			button.FontFace = Font.new(
				assets.interFont,
				Enum.FontWeight.SemiBold,
				Enum.FontStyle.Normal
			)
			button.Text = v.Name
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.TextSize = 15
			button.TextTransparency = 0.5
			button.TextTruncate = Enum.TextTruncate.AtEnd
			button.AutoButtonColor = false
			button.AutomaticSize = Enum.AutomaticSize.Y
			button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			button.BorderColor3 = Color3.fromRGB(0, 0, 0)
			button.BorderSizePixel = 0
			button.Size = UDim2.fromScale(1, 0)

			local uIPadding1 = Instance.new("UIPadding")
			uIPadding1.Name = "UIPadding"
			uIPadding1.PaddingBottom = UDim.new(0, 9)
			uIPadding1.PaddingLeft = UDim.new(0, 10)
			uIPadding1.PaddingRight = UDim.new(0, 10)
			uIPadding1.PaddingTop = UDim.new(0, 9)
			uIPadding1.Parent = button

			local baseUICorner1 = Instance.new("UICorner")
			baseUICorner1.Name = "BaseUICorner"
			baseUICorner1.CornerRadius = UDim.new(0, 10)
			baseUICorner1.Parent = button

			button.Parent = interactions
			
			local TweenSettings = {
				DefaultTransparency = 0,
				DefaultTransparency2 = 0.5,
				HoverTransparency = 0.3,
				HoverTransparency2 = 0.6,

				EasingStyle = Enum.EasingStyle.Sine
			}
			
			локальная функция ChangeState(State)
				если State == "Idle", то
					Tween(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
						BackgroundTransparency = TweenSettings.DefaultTransparency,
						TextTransparency = TweenSettings.DefaultTransparency2
					}):Играть()
				elseif State == "Hover" then
					Tween(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
						BackgroundTransparency = TweenSettings.HoverTransparency,
						TextTransparency = TweenSettings.HoverTransparency2
					}):Играть()
				конец
			конец
			
			button.MouseButton1Click:Connect(function()
				if dialogCanvas.GroupTransparency ~= 0 then return end
				если v.Callback тогда
					v.Callback()
				конец
				
				dialog.Parent = dialogCanvas
				
				dialogOut()
			конец)
			
			button.MouseEnter:Connect(function()
				ChangeState("Hover")
			конец)
			button.MouseLeave:Connect(function()
				ChangeState("Idle")
			конец)
		конец
		
		dialogIn()
		
		функция DialogFunctions:UpdateTitle(New)
			paragraphHeader.Text = New
		конец
		функция DialogFunctions:UpdateDescription(New)
			paragraphBody.Text = New
		конец
		
		функция DialogFunctions:Cancel()
			dialogOut()
		конец
		
		return DialogFunctions
	конец

	функция WindowFunctions:SetNotificationsState(State)
		notifications.Visible = State
	конец

	function WindowFunctions:GetNotificationsState(State)
		уведомления о возврате.Видимо
	конец

	функция WindowFunctions:SetState(State)
		windowState = State
		base.Visible = State
	конец

	функция WindowFunctions:GetState()
		return windowState
	конец
	
	локальный onUnloadCallback

	функция WindowFunctions:Unload()
		если onUnloadCallback тогда
			onUnloadCallback()  
		конец
		macLib:Destroy()
	конец

	function WindowFunctions.onUnloaded(callback)
		onUnloadCallback = callback
	конец

	local MenuKeybind = Settings.Keybind or Enum.KeyCode.RightControl

	локальная функция ToggleMenu()
		local state = not WindowFunctions:GetState()
		WindowFunctions:SetState(состояние)
		WindowFunctions:Notify({
			Заголовок = Настройки.Заголовок,
			Описание = (состояние и "Развернуто" или "Свернуто") .. "меню. Используйте " .. tostring(MenuKeybind.Name) .. " для переключения."
			Продолжительность жизни = 5
		})
	конец

	UserInputService.InputEnded:Connect(function(inp, gpe)
		если gpe, то вернуть конец
		если inp.KeyCode == MenuKeybind, то
			ToggleMenu()
		конец
	конец)

	minimize.MouseButton1Click:Connect(ToggleMenu)
	exit.MouseButton1Click:Connect(function()
		WindowFunctions:Unload()
	конец)

	функция WindowFunctions:SetKeybind(Keycode)
		MenuKeybind = Keycode
	конец

	function WindowFunctions:SetAcrylicBlurState(State)
		acrylicBlur = State
		base.BackgroundTransparency = State and 0.05 or 0
	конец

	функция WindowFunctions:GetAcrylicBlurState()
		возврат акрилРазмытие
	конец

	локальная функция _SetUserInfoState(State)
		если штат, то
			headshot.Image = (isReady and headshotImage) or "rbxassetid://0"
			username.Text = "@"..LocalPlayer.Name
			displayName.Text = LocalPlayer.DisplayName
		еще
			headshot.Image = assets.userInfoBlurred
			local nameLength = #LocalPlayer.Name
			local displayNameLength = #LocalPlayer.DisplayName
			username.Text = "@"..string.rep(".", nameLength)
			displayName.Text = string.rep(".", displayNameLength)
		конец
	конец

	local showUserInfo
	Если Settings.ShowUserInfo ≤ nil, то
		showUserInfo = Settings.ShowUserInfo
	еще
		showUserInfo = true
	конец

	_SetUserInfoState(showUserInfo)

	функция WindowFunctions:SetUserInfoState(State)
		_SetUserInfoState(State)
	конец
	функция WindowFunctions:GetUserInfoState(State)
		return showUserInfo
	конец
	
	функция WindowFunctions:SetSize(Size)
		base.Size = Размер
	конец
	функция WindowFunctions:GetSize(Size)
		возврат базы.Размер
	конец
	
	функция WindowFunctions:SetScale(Scale)
		baseUIScale.Scale = Scale
	конец
	функция WindowFunctions:GetScale()
		return baseUIScale.Scale
	конец

	macLib.Enabled = false
	
	local assetList = {}
	for _, assetId in pairs(assets) do
		table.insert(assetList, assetId)
	конец
	
	ContentProvider:PreloadAsync(assetList)
	macLib.Enabled = true
	windowState = true

	return WindowFunctions
конец

функция MacLib:Demo()
	local Window = MacLib:Window({
		Заголовок = "Демонстрация MacLib",
		Субтитры = "Это субтитры."
		Размер = UDim2.fromOffset(868, 650),
		DragStyle = 1,
		DisabledWindowControls = {},
		ShowUserInfo = true,
		Keybind = Enum.KeyCode.RightControl,
		AcrylicBlur = true,
	})

	локальные глобальные настройки = {
		UIBlurToggle = Window:GlobalSetting({
			Name = "UI Blur",
			Default = Window:GetAcrylicBlurState(),
			Функция обратного вызова = function(bool)
				Window:SetAcrylicBlurState(bool)
				Window:Notify({
					Заголовок = "Демонстрация MacLib",
					Описание = (логическое значение и "Включено" или "Отключено") .. "Размытие пользовательского интерфейса",
					Продолжительность жизни = 5
				})
			конец,
		}),
		NotificationToggler = Window:GlobalSetting({
			Имя = "Уведомления",
			По умолчанию = Window:GetNotificationsState(),
			Функция обратного вызова = function(bool)
				Window:SetNotificationsState(bool)
				Window:Notify({
					Заголовок = "Демонстрация MacLib",
					Описание = (логическое значение и "Включено" или "Отключено") .. "Уведомления",
					Продолжительность жизни = 5
				})
			конец,
		}),
		ShowUserInfo = Window:GlobalSetting({
			Имя = "Показать информацию о пользователе",
			По умолчанию = Window:GetUserInfoState(),
			Функция обратного вызова = function(bool)
				Window:SetUserInfoState(bool)
				Window:Notify({
					Заголовок = "Демонстрация MacLib",
					Описание = (логическое значение и "Отображается" или "Засекречено") .. "Информация о пользователе",
					Продолжительность жизни = 5
				})
			конец,
		})
	}
	
	local tabGroups = {
		TabGroup1 = Window:TabGroup()
	}

	локальные вкладки = {
		Main = tabGroups.TabGroup1:Tab({ Name = "Demo", Image = "rbxassetid://18821914323" })
	}
	
	локальные разделы = {
		MainSection1 = tabs.Main:Section({ Side = "Left" })
	}

	sections.MainSection1:Header({
		Имя = "Заголовок №1"
	})

	sections.MainSection1:Button({
		Имя = "Кнопка",
		Функция обратного вызова = function()
			Window:Dialog({
				Заголовок = "Демонстрация MacLib",
				Описание = "Lorem ipsum odor amet, consectetuer adipiscing elit. Eros вестибулум aliquet mattis, ex Platea nunc.",
				Кнопки = {
					{
						Имя = "Подтвердить",
						Функция обратного вызова = function()
							print("Подтверждено!")
						конец,
					},
					{
						Имя = "Отмена"
					}
				}
			})
		конец,
	})

	sections.MainSection1:Input({
		Имя = "Ввод",
		Заполнитель = "Ввод",
		AcceptedCharacters = "All",
		Функция обратного вызова = function(input)
			Window:Notify({
				Заголовок = "Демонстрация MacLib",
				Описание = "Входной сигнал успешно установлен на " .. вход
			})
		конец,
		onChanged = function(input)
			print("Ввод теперь ".. input)
		конец,
	})

	разделы.MainSection1:Slider({
		Имя = "Слайдер",
		По умолчанию = 50,
		Минимум = 0,
		Максимум = 100,
		DisplayMethod = "Percent",
		Функция обратного вызова = function(Value)
			print("Изменено на ".. Значение)
		конец,
	})

	sections.MainSection1:Toggle({
		Имя = "Переключатель",
		По умолчанию = false,
		Функция обратного вызова = function(value)
			Window:Notify({
				Заголовок = "Демонстрация MacLib",
				Описание = (значение и "Включено" или "Выключено") .. "Переключатель"
			})
		конец,
	})

	sections.MainSection1:Keybind({
		Имя = "Привязка клавиш",
		Функция обратного вызова = function(binded)
			Window:Notify({
				Заголовок = "Демонстрационное окно",
				Описание = "Нажата комбинация клавиш - "..tostring(binded.Name),
				Продолжительность жизни = 3
			})
		конец,
		onBinded = function(bind)
			Window:Notify({
				Заголовок = "Демонстрационное окно",
				Описание = "Успешно назначена клавиша для - "..tostring(bind.Name),
				Продолжительность жизни = 3
			})
		конец,
	})

	разделы.MainSection1:Colorpicker({
		Имя = "Выбор цвета",
		По умолчанию = Color3.fromRGB(0, 255, 255),
		Функция обратного вызова = function(color)
			print("Цвет: ", color)
		конец,
	})

	local alphaColorPicker = sections.MainSection1:Colorpicker({
		Имя = "Выбор цвета прозрачности",
		По умолчанию = Color3.fromRGB(255,0,0),
		Альфа = 0,
		Функция обратного вызова = function(color, alpha)
			print("Цвет: ", color, " Альфа: ", alpha)
		конец,
	})
	
	локальный rainbowActive
	локальное радужное соединение
	локальный оттенок = 0

	sections.MainSection1:Toggle({
		Имя = "Радуга",
		По умолчанию = false,
		Функция обратного вызова = function(value)
			rainbowActive = значение
			если rainbowActive тогда
				rainbowConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
					оттенок = (оттенок + deltaTime * 0,1) % 1
					local newColor = Color3.fromHSV(hue, 1, 1)
					alphaColorPicker:SetColor(newColor)
				конец)
			еще
				если rainbowConnection, то
					rainbowConnection:Disconnect()
					rainbowConnection = nil
				конец
			конец
		конец,
	})
	
	local optionTable = {}
	
	для i = 1,10 do
		local formatted = "Option ".. tostring(i)
		table.insert(optionTable, formatted)
	конец

	local Dropdown = sections.MainSection1:Dropdown({
		Имя = "Выпадающий список",
		Multi = false,
		Обязательно = true,
		Options = optionTable,
		По умолчанию = 1,
		Функция обратного вызова = function(Value)
			print("Изменение выпадающего списка: ".. Значение)
		конец,
	})

	local MultiDropdown = sections.MainSection1:Dropdown({
		Название = "Множественный выпадающий список",
		Поиск = true,
		Multi = true,
		Обязательно = false,
		Options = optionTable,
		По умолчанию = {"Вариант 1", "Вариант 3"},
		Функция обратного вызова = function(Value)
			локальные значения = {}
			для значения, состояние в следующем, значение сделать
				table.insert(Values, Value)
			конец
			print("Изменение в выпадающем списке:", table.concat(Values, ", "))
		конец,
	})

	sections.MainSection1:Button({
		Имя = "Обновить выбранное",
		Функция обратного вызова = function()
			Выпадающий список:ОбновитьВыбор(4)
			MultiDropdown:UpdateSelection({"Вариант 2", "Вариант 5"})
		конец,
	})

	sections.MainSection1:Divider()

	sections.MainSection1:Header({
		Текст = "Заголовок #2"
	})

	sections.MainSection1:Paragraph({
		Заголовок = "Абзац",
		Body = "Тело абзаца. Lorem ipsum odor amet, consectetuer adipiscing elit. Morbi tempus netus aliquet per velit est gradida."
	})

	sections.MainSection1:Label({
		Text = "Этикетка. Lorem ipsum odor amet, consectetuer adipiscing elit."
	})

	sections.MainSection1:SubLabel({
		Text = "Подэтикетка. Lorem ipsum odor amet, consectetuer adipiscing elit."
	})
	
	Window.onUnloaded(function()
		print("Unloaded!")
	конец)

	tabs.Main:Select()
конец

вернуть MacLib
