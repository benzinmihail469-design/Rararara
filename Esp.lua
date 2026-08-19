-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local TweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Dynamic Dimensions Configuration
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local MainWidth = IsMobile and 530 or 570
local MainHeight = IsMobile and 320 or 340
local SidebarWidth = IsMobile and 140 or 150
local HeaderHeight = 36
local FooterHeight = 42

-- Parent Container Detection
local TargetParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- 1. ScreenGui Initialization
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeverloseMainWindow"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- 2. Main Window Frame
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainFrame"
MainWindow.Size = UDim2.new(0, MainWidth, 0, MainHeight)
MainWindow.Position = UDim2.new(0.5, -MainWidth / 2, 0.5, -MainHeight / 2)
MainWindow.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(28, 33, 46)
MainStroke.Thickness = 1
MainStroke.Parent = MainWindow

-- 3. Left Sidebar (Navigation & Profile)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

-- Brand Logo
local LogoText = Instance.new("TextLabel")
LogoText.Name = "Logo"
LogoText.Size = UDim2.new(1, -20, 0, HeaderHeight)
LogoText.Position = UDim2.new(0, 12, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "NEVERLOSE"
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 14
LogoText.TextColor3 = Color3.fromRGB(0, 162, 255)
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = Sidebar

-- Tab Navigation Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -16, 1, -(HeaderHeight + FooterHeight + 20))
TabContainer.Position = UDim2.new(0, 8, 0, HeaderHeight + 5)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabContainer

-- User Profile Widget (Footer)
local UserProfile = Instance.new("Frame")
UserProfile.Name = "UserProfile"
UserProfile.Size = UDim2.new(1, -16, 0, FooterHeight)
UserProfile.Position = UDim2.new(0, 8, 1, -(FooterHeight + 8))
UserProfile.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
UserProfile.BorderSizePixel = 0
UserProfile.Parent = Sidebar

local UserProfileCorner = Instance.new("UICorner")
UserProfileCorner.CornerRadius = UDim.new(0, 6)
UserProfileCorner.Parent = UserProfile

local AvatarSize = FooterHeight - 12
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Name = "Avatar"
AvatarImage.Size = UDim2.new(0, AvatarSize, 0, AvatarSize)
AvatarImage.Position = UDim2.new(0, 6, 0.5, -AvatarSize / 2)
AvatarImage.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
AvatarImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
AvatarImage.Parent = UserProfile

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImage

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Name = "Username"
UsernameLabel.Size = UDim2.new(1, -(AvatarSize + 16), 0, 15)
UsernameLabel.Position = UDim2.new(0, AvatarSize + 12, 0, 6)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.DisplayName
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 11
UsernameLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.Parent = UserProfile

local SubLabel = Instance.new("TextLabel")
SubLabel.Name = "Subscription"
SubLabel.Size = UDim2.new(1, -(AvatarSize + 16), 0, 13)
SubLabel.Position = UDim2.new(0, AvatarSize + 12, 0, 21)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Lifetime"
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 10
SubLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = UserProfile

-- 4. Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, -SidebarWidth, 0, HeaderHeight)
Header.Position = UDim2.new(0, SidebarWidth, 0, 0)
Header.BackgroundTransparency = 1
Header.Parent = MainWindow

local ActiveTabTitle = Instance.new("TextLabel")
ActiveTabTitle.Name = "ActiveTabTitle"
ActiveTabTitle.Size = UDim2.new(0, 150, 1, 0)
ActiveTabTitle.Position = UDim2.new(0, 15, 0, 0)
ActiveTabTitle.BackgroundTransparency = 1
ActiveTabTitle.Text = "RAGEBOT"
ActiveTabTitle.Font = Enum.Font.GothamBold
ActiveTabTitle.TextSize = 13
ActiveTabTitle.TextColor3 = Color3.fromRGB(240, 245, 255)
ActiveTabTitle.TextXAlignment = Enum.TextXAlignment.Left
ActiveTabTitle.Parent = Header

local WatermarkInfo = Instance.new("TextLabel")
WatermarkInfo.Name = "WatermarkInfo"
WatermarkInfo.Size = UDim2.new(0, 180, 1, 0)
WatermarkInfo.Position = UDim2.new(1, -195, 0, 0)
WatermarkInfo.BackgroundTransparency = 1
WatermarkInfo.Text = "neverlose.cc | roblox"
WatermarkInfo.Font = Enum.Font.GothamMedium
WatermarkInfo.TextSize = 11
WatermarkInfo.TextColor3 = Color3.fromRGB(90, 98, 115)
WatermarkInfo.TextXAlignment = Enum.TextXAlignment.Right
WatermarkInfo.Parent = Header

-- 5. Content Container (Two-Column Layout)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -(SidebarWidth + 20), 1, -(HeaderHeight + 10))
ContentContainer.Position = UDim2.new(0, SidebarWidth + 10, 0, HeaderHeight)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainWindow

local LeftColumn = Instance.new("ScrollingFrame")
LeftColumn.Name = "LeftColumn"
LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
LeftColumn.Position = UDim2.new(0, 0, 0, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.ScrollBarThickness = 2
LeftColumn.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
LeftColumn.Parent = ContentContainer

local RightColumn = Instance.new("ScrollingFrame")
RightColumn.Name = "RightColumn"
RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.ScrollBarThickness = 2
RightColumn.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
RightColumn.Parent = ContentContainer

-- Column Layout Setup
for _, col in ipairs({LeftColumn, RightColumn}) do
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = col
end

-- 6. Helper Function: Create Tabs
local ActiveTabButton = nil

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = TabContainer

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabButton

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -12, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 11
    Title.TextColor3 = Color3.fromRGB(110, 118, 135)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TabButton

    TabButton.MouseButton1Click:Connect(function()
        if ActiveTabButton then
            TweenService:Create(ActiveTabButton, TweenInfoFast, {BackgroundTransparency = 1}):Play()
            TweenService:Create(ActiveTabButton:FindFirstChildOfClass("TextLabel"), TweenInfoFast, {TextColor3 = Color3.fromRGB(110, 118, 135)}):Play()
        end
        ActiveTabButton = TabButton
        ActiveTabTitle.Text = string.upper(name)
        TweenService:Create(TabButton, TweenInfoFast, {BackgroundTransparency = 0}):Play()
        TweenService:Create(Title, TweenInfoFast, {TextColor3 = Color3.fromRGB(240, 245, 255)}):Play()
    end)

    return TabButton
end

-- Populate Tabs
local Tabs = {"Ragebot", "Legitbot", "Visuals", "World", "Misc", "Settings"}
for i, tabName in ipairs(Tabs) do
    local btn = CreateTab(tabName)
    if i == 1 then
        ActiveTabButton = btn
        btn.BackgroundTransparency = 0
        btn:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(240, 245, 255)
    end
end

-- 7. Smooth Dragging Mechanism
local Dragging, DragInput, DragStart, StartPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainWindow.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = input.Position - DragStart
        TweenService:Create(MainWindow, TweenInfoFast, {
            Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        }):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)
