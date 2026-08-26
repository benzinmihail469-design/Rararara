-- Standalone Neverlose-style UI Framework (Extracted & Mobile Adapted)
-- Features: Main Frame, Tab System, Full Builder Icons Engine[span_0](start_span)[span_0](end_span)

local cloneref = cloneref or function(i) return i end
local TweenService = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local Players = cloneref(game:GetService('Players'))
local LocalPlayer = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or cloneref(game:FindFirstChild('CoreGui')) or cloneref(LocalPlayer.PlayerGui)
local ProtectGui = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s end

local NeverLose = {}
NeverLose.IsMobile = UserInputService.TouchEnabled[span_1](start_span)[span_1](end_span)

-- System Icons & Roblox Fonts Setup[span_2](start_span)[span_2](end_span)
NeverLose.BuiltInRegular = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)[span_3](start_span)[span_3](end_span)
NeverLose.BuiltInBold = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)[span_4](start_span)[span_4](end_span)

-- Mobile-Optimized GUI Scales[span_5](start_span)[span_5](end_span)
NeverLose.Scales = {
    Small   = UDim2.fromOffset(460, 300),
    Mobile  = UDim2.fromOffset(480, 310), -- Aдаптированный компактный размер для мобильных устройств[span_6](start_span)[span_6](end_span)
    Default = UDim2.fromOffset(600, 400),
    Large   = UDim2.fromOffset(750, 500)
}[span_7](start_span)[span_7](end_span)

-- Create GUI Container[span_8](start_span)[span_8](end_span)
local GlobalWindow = Instance.new('ScreenGui')
ProtectGui(GlobalWindow)[span_9](start_span)[span_9](end_span)
GlobalWindow.Name = "NL_Mobile_UI_" .. tostring(math.random(1000, 9999))[span_10](start_span)[span_10](end_span)
GlobalWindow.IgnoreGuiInset = true[span_11](start_span)[span_11](end_span)
GlobalWindow.ZIndexBehavior = Enum.ZIndexBehavior.Global[span_12](start_span)[span_12](end_span)
GlobalWindow.ResetOnSpawn = false[span_13](start_span)[span_13](end_span)
GlobalWindow.Parent = CoreGui[span_14](start_span)[span_14](end_span)

NeverLose.ScreenGui = GlobalWindow[span_15](start_span)[span_15](end_span)

-- Icon Engine[span_16](start_span)[span_16](end_span)
function NeverLose:SetIconMode(Label: TextLabel, IconName: string)[span_17](start_span)[span_17](end_span)
    local useBold = string.lower(string.sub(IconName, -5)) == '-bold[span_18](start_span)'[span_18](end_span)
    if useBold then
        Label.Text = IconName:sub(1, -6)[span_19](start_span)[span_19](end_span)
        Label.FontFace = NeverLose.BuiltInBold[span_20](start_span)[span_20](end_span)
    else
        Label.Text = IconName[span_21](start_span)[span_21](end_span)
        Label.FontFace = NeverLose.BuiltInRegular[span_22](start_span)[span_22](end_span)
    end
end[span_23](start_span)[span_23](end_span)

-- Universal Dragging (Mouse & Touch Support)[span_24](start_span)[span_24](end_span)
function NeverLose:Drag(InputFrame: Frame, MoveFrame: Frame, Speed: number)[span_25](start_span)[span_25](end_span)
    local dragToggle, dragStart, startPos = false, nil, nil
    local Tween = TweenInfo.new(Speed or 0.1)[span_26](start_span)[span_26](end_span)

    local function updateInput(input)
        local delta = input.Position - dragStart[span_27](start_span)[span_27](end_span)
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)[span_28](start_span)[span_28](end_span)
        TweenService:Create(MoveFrame, Tween, {Position = position}):Play()[span_29](start_span)[span_29](end_span)
    end

    InputFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then[span_30](start_span)[span_30](end_span)
            dragToggle = true
            dragStart = input.Position[span_31](start_span)[span_31](end_span)
            startPos = MoveFrame.Position[span_32](start_span)[span_32](end_span)

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
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then[span_33](start_span)[span_33](end_span)
            updateInput(input)
        end
    end)
end[span_34](start_span)[span_34](end_span)

-- Main Window & Tab Engine Construction
function NeverLose:CreateWindow(TitleText: string)
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    -- Frame Size Selection based on Mobile status[span_35](start_span)[span_35](end_span)
    local TargetSize = NeverLose.IsMobile and NeverLose.Scales.Mobile or NeverLose.Scales.Default[span_36](start_span)[span_36](end_span)

    -- Main Container Frame[span_37](start_span)[span_37](end_span)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = GlobalWindow[span_38](start_span)[span_38](end_span)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = TargetSize[span_39](start_span)[span_39](end_span)
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(35, 40, 52)
    MainStroke.Thickness = 1

    -- Header / Title Bar (Drag Zone)[span_40](start_span)[span_40](end_span)
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

    NeverLose:Drag(Header, MainFrame, 0.1)[span_41](start_span)[span_41](end_span)

    -- Tab Navigation Bar (Left Side)
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

    -- Tab Content Display Area (Right Side)
    local ContainerArea = Instance.new("Frame", MainFrame)
    ContainerArea.Name = "ContainerArea"
    ContainerArea.Position = UDim2.new(0, NeverLose.IsMobile and 45 or 120, 0, 36)
    ContainerArea.Size = UDim2.new(1, -(NeverLose.IsMobile and 45 or 120), 1, -36)
    ContainerArea.BackgroundTransparency = 1

    -- Tab Creator System[span_42](start_span)[span_42](end_span)
    function Window:CreateTab(Name: string, IconName: string)
        local Tab = {}

        -- Tab Button
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
            NeverLose:SetIconMode(IconLabel, IconName)[span_43](start_span)[span_43](end_span)
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
        TabTitle.Visible = not NeverLose.IsMobile -- Скрываем текст во вкладках на мобилках для экономии места

        -- Content Frame
        local TabContent = Instance.new("ScrollingFrame", ContainerArea)
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.ScrollBarThickness = 2
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(78, 127, 252)[span_44](start_span)[span_44](end_span)

        local ContentPadding = Instance.new("UIPadding", TabContent)
        ContentPadding.PaddingTop = UDim.new(0, 8)
        ContentPadding.PaddingLeft = UDim.new(0, 8)
        ContentPadding.PaddingRight = UDim.new(0, 8)

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)

        -- Tab Select Functionality
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
            TweenService:Create(IconLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(78, 127, 252)}):Play()[span_45](start_span)[span_45](end_span)
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
