local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("MM2FlyFollowGui") then
	PlayerGui.MM2FlyFollowGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2FlyFollowGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 255, 140)
Stroke.Transparency = 0.2
Stroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "GUI TEMPLATE (TABS ONLY)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 14
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabPanel = Instance.new("Frame")
TabPanel.Name = "TabPanel"
TabPanel.Size = UDim2.new(0, 130, 1, -50)
TabPanel.Position = UDim2.new(0, 10, 0, 45)
TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabPanel.Parent = MainFrame
Instance.new("UICorner", TabPanel).CornerRadius = UDim.new(0, 8)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabPanel

local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -160, 1, -50)
PagesContainer.Position = UDim2.new(0, 150, 0, 45)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- Перетаскивание интерфейса
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function update(input)
	local delta = input.Position - dragStart
	local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = targetPos}):Play()
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
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
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Сворачивание интерфейса
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetSize = isMinimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 300)
	MinBtn.Text = isMinimized and "+" or "-"
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
end)

-- Создание вкладок
local tabs = {}
local activeTab = nil

local function CreateTab(name, order)
	local Page = Instance.new("ScrollingFrame")
	Page.Name = name .. "Page"
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 3
	Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
	Page.Visible = false
	Page.Parent = PagesContainer

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Padding = UDim.new(0, 8)
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Parent = Page
	ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
	end)

	local TabBtn = Instance.new("TextButton")
	TabBtn.Name = name .. "Tab"
	TabBtn.Size = UDim2.new(1, -10, 0, 35)
	TabBtn.Position = UDim2.new(0, 5, 0, 0)
	TabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	TabBtn.Font = Enum.Font.GothamSemibold
	TabBtn.Text = name
	TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
	TabBtn.TextSize = 13
	TabBtn.LayoutOrder = order
	TabBtn.Parent = TabPanel
	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

	local function select()
		if activeTab then
			activeTab.TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
			activeTab.TabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
			activeTab.Page.Visible = false
		end
		TabBtn.TextColor3 = Color3.fromRGB(0, 255, 140)
		TabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
		Page.Visible = true
		activeTab = {TabBtn = TabBtn, Page = Page}
	end

	TabBtn.MouseButton1Click:Connect(select)
	tabs[name] = {TabBtn = TabBtn, Page = Page, Select = select}
	
	return Page
end

-- Инициализация пустых вкладок (пустые страницы без кнопок и слайдеров)
local MainTab = CreateTab("Главная", 1)
local PlayerTab = CreateTab("Игрок", 2)
local VisualTab = CreateTab("Визуал", 3)
local KillerTab = CreateTab("Киллер", 4)
local SheriffTab = CreateTab("Шериф", 5)

-- Выбор первой вкладки по умолчанию
if tabs["Главная"] then
	tabs["Главная"].Select()
end

-- Закрытие и удаление интерфейса
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
