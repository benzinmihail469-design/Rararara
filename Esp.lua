local cloneref = cloneref or function(i) return i end
local TweenService = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local Players = cloneref(game:GetService('Players'))
local LocalPlayer = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or cloneref(game:FindFirstChild('CoreGui')) or cloneref(LocalPlayer.PlayerGui)
local ProtectGui = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s end

local NeverLose = {}
NeverLose.IsMobile = UserInputService.TouchEnabled

NeverLose.BuiltInRegular = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
NeverLose.BuiltInBold = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)

NeverLose.Scales = {
    Small   = UDim2.fromOffset(460, 300),
    Mobile  = UDim2.fromOffset(480, 310),
    Default = UDim2.fromOffset(600, 400),
    Large   = UDim2.fromOffset(750, 500)
}

local GlobalWindow = Instance.new('ScreenGui')
ProtectGui(GlobalWindow)
GlobalWindow.Name = "NL_Mobile_UI_" .. tostring(math.random(1000, 9999))
GlobalWindow.IgnoreGuiInset = true
GlobalWindow.ZIndexBehavior = Enum.ZIndexBehavior.Global
GlobalWindow.ResetOnSpawn = false
GlobalWindow.Parent = CoreGui

NeverLose.ScreenGui = GlobalWindow

function NeverLose:SetIconMode(Label, IconName)
    local useBold = string.lower(string.sub(IconName, -5)) == '-bold'
    if useBold then
        Label.Text = IconName:sub(1, -6)
        Label.FontFace = NeverLose.BuiltInBold
    else
        Label.Text = IconName
        Label.FontFace = NeverLose.BuiltInRegular
    end
end

function NeverLose:Drag(InputFrame, MoveFrame, Speed)
    local dragToggle, dragStart, startPos = false, nil, nil
    local Tween = TweenInfo.new(Speed or 0.1)

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(MoveFrame, Tween, {Position = position}):Play()
    end

    InputFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = MoveFrame.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                    conn:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
            updateInput(input)
        end
    end)
end

function NeverLose:CreateWindow(TitleText)
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    local TargetSize = NeverLose.IsMobile and NeverLose.Scales.Mobile or NeverLose.Scales.Default

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = GlobalWindow
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = TargetSize
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(35, 40, 52)
    MainStroke.Thickness = 1

    local Header = Instance.new("Frame", MainFrame)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
    Header.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(10, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = TitleText or "Neverlose"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = NeverLose.IsMobile and 12 or 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    NeverLose:Drag(Header, MainFrame, 0.1)

    local TabBar = Instance.new("Frame", MainFrame)
    TabBar.Name = "TabBar"
    TabBar.Position = UDim2.fromOffset(0, 36)
    TabBar.Size = UDim2.new(0, NeverLose.IsMobile and 45 or 120, 1, -36)
    TabBar.BackgroundColor3 = Color3.fromRGB(13, 16, 23)
    TabBar.BorderSizePixel = 0

    local TabListLayout = Instance.new("UIListLayout", TabBar)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)

    local TabPadding = Instance.new("UIPadding", TabBar)
    TabPadding.PaddingTop = UDim.new(0, 6)
    TabPadding.PaddingLeft = UDim.new(0, 4)
    TabPadding.PaddingRight = UDim.new(0, 4)

    local ContainerArea = Instance.new("Frame", MainFrame)
    ContainerArea.Name = "ContainerArea"
    ContainerArea.Position = UDim2.new(0, NeverLose.IsMobile and 45 or 120, 0, 36)
    ContainerArea.Size = UDim2.new(1, -(NeverLose.IsMobile and 45 or 120), 1, -36)
    ContainerArea.BackgroundTransparency = 1

    function Window:CreateTab(Name, IconName)
        local Tab = {}

        local TabBtn = Instance.new("TextButton", TabBar)
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false

        local TabBtnCorner = Instance.new("UICorner", TabBtn)
        TabBtnCorner.CornerRadius = UDim.new(0, 6)

        local IconLabel = Instance.new("TextLabel", TabBtn)
        IconLabel.Size = UDim2.new(0, 24, 1, 0)
        IconLabel.Position = UDim2.fromOffset(6, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.TextColor3 = Color3.fromRGB(160, 165, 180)
        IconLabel.TextSize = 16

        if IconName then
            NeverLose:SetIconMode(IconLabel, IconName)
        end

        local TabTitle = Instance.new("TextLabel", TabBtn)
        TabTitle.Size = UDim2.new(1, -35, 1, 0)
        TabTitle.Position = UDim2.fromOffset(32, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = Name
        TabTitle.TextColor3 = Color3.fromRGB(160, 165, 180)
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 12
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Visible = not NeverLose.IsMobile

        local TabContent = Instance.new("ScrollingFrame", ContainerArea)
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.ScrollBarThickness = 2
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(78, 127, 252)

        local ContentPadding = Instance.new("UIPadding", TabContent)
        ContentPadding.PaddingTop = UDim.new(0, 8)
        ContentPadding.PaddingLeft = UDim.new(0, 8)
        ContentPadding.PaddingRight = UDim.new(0, 8)

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)

        local function Select()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                TweenService:Create(t.Icon, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(160, 165, 180)}):Play()
                if not NeverLose.IsMobile then
                    TweenService:Create(t.Text, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(160, 165, 180)}):Play()
                end
            end

            TabContent.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            TweenService:Create(IconLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(78, 127, 252)}):Play()
            if not NeverLose.IsMobile then
                TweenService:Create(TabTitle, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
            Window.CurrentTab = Tab
        end

        TabBtn.MouseButton1Click:Connect(Select)
        TabBtn.TouchTap:Connect(Select)

        Tab.Button = TabBtn
        Tab.Icon = IconLabel
        Tab.Text = TabTitle
        Tab.Content = TabContent

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Select()
        end

        return Tab
    end

    return Window
end

return NeverLose
