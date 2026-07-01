local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("HoshiMM2Gui") then
    PlayerGui.HoshiMM2Gui:Destroy()
end

-- ТВОИ ОРИГИНАЛЬНЫЕ НАСТРОЙКИ И ПЕРЕМЕННЫЕ LOGIC
local MasterControl = nil
local CharacterScripts = LocalPlayer:FindFirstChild("PlayerScripts")
if CharacterScripts then
    local PlayerModule = CharacterScripts:FindFirstChild("PlayerModule")
    if PlayerModule then
        local requireModule = require(PlayerModule)
        if requireModule and requireModule.GetControls then
            MasterControl = requireModule:GetControls()
        end
    end
end

local Flying = false
local FlySpeed = 35 
local NormalWalkSpeed = 16
local WalkSpeedEnabled = false 
local AutoFarmEnabled = false  
local AutoFarmSpeed = 16 
local ESPEnabled = false
local AutoKillEnabled = false 
local AutoShootMurdererEnabled = false 
local AutoGetGunEnabled = false
local FlyConnection = nil
local NoclipConnection = nil
local WalkSpeedConnection = nil
local AutoFarmConnection = nil
local NextScanTime = 0
local CachedCoin = nil

local BVelocity = nil
local BGyro = nil

-- СОЗДАНИЕ КРАСИВОГО ИНТЕРФЕЙСА HOSHI HUB
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoshiMM2Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 620, 0, 360)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(35, 38, 47)
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Верхняя панель (Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 9)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 80, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoshi"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local TagFrame = Instance.new("Frame")
TagFrame.Size = UDim2.new(0, 50, 0, 18)
TagFrame.Position = UDim2.new(0, 75, 0.5, -9)
TagFrame.BackgroundColor3 = Color3.fromRGB(30, 33, 43)
TagFrame.Parent = Header
Instance.new("UICorner", TagFrame).CornerRadius = UDim.new(0, 4)

local TagLabel = Instance.new("TextLabel")
TagLabel.Size = UDim2.new(1, 0, 1, 0)
TagLabel.BackgroundTransparency = 1
TagLabel.Font = Enum.Font.GothamBold
TagLabel.Text = "FREE"
TagLabel.TextColor3 = Color3.fromRGB(160, 165, 180)
TagLabel.TextSize = 9
TagLabel.Parent = TagFrame

local VerFrame = Instance.new("Frame")
VerFrame.Size = UDim2.new(0, 50, 0, 18)
VerFrame.Position = UDim2.new(0, 132, 0.5, -9)
VerFrame.BackgroundColor3 = Color3.fromRGB(30, 33, 43)
VerFrame.Parent = Header
Instance.new("UICorner", VerFrame).CornerRadius = UDim.new(0, 4)

local VerLabel = Instance.new("TextLabel")
VerLabel.Size = UDim2.new(1, 0, 1, 0)
VerLabel.BackgroundTransparency = 1
VerLabel.Font = Enum.Font.GothamMedium
VerLabel.Text = "v1.4.0"
VerLabel.TextColor3 = Color3.fromRGB(160, 165, 180)
VerLabel.TextSize = 9
VerLabel.Parent = VerFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(120, 125, 140)
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -72, 0.5, -16)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.GothamMedium
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(120, 125, 140)
MinBtn.TextSize = 14
MinBtn.Parent = Header

-- Боковая панель навигации (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(30, 33, 43)
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = Sidebar

local ContainerPadding = Instance.new("UIPadding")
ContainerPadding.PaddingTop = UDim.new(0, 10)
ContainerPadding.PaddingLeft = UDim.new(0, 8)
ContainerPadding.PaddingRight = UDim.new(0, 8)
ContainerPadding.Parent = Sidebar

-- Контейнер для страниц
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -140, 1, -42)
PagesContainer.Position = UDim2.new(0, 140, 0, 42)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- Система перетаскивания (ПК + Телефоны)
local dragging, dragInput, dragStart, startPos
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
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

-- Сворачивание
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 620, 0, 42) or UDim2.new(0, 620, 0, 360)
    MinBtn.Text = isMinimized and "+" or "—"
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

local tabs = {}
local activeTab = nil

local function CreateTab(name, order)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(55, 58, 70)
    Page.Visible = false
    Page.Parent = PagesContainer

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 12)
    PagePadding.PaddingLeft = UDim.new(0, 14)
    PagePadding.PaddingRight = UDim.new(0, 14)
    PagePadding.Parent = Page

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = Page

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 25)
    end)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(140, 145, 160)
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.LayoutOrder = order
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 14)
    Indicator.Position = UDim2.new(0, 2, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = 1
    Indicator.Parent = TabBtn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)

    local function select()
        if activeTab then
            TweenService:Create(activeTab.TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(140, 145, 160), BackgroundTransparency = 1}):Play()
            TweenService:Create(activeTab.Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            activeTab.Page.Visible = false
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(24, 26, 34), BackgroundTransparency = 0}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        Page.Visible = true
        activeTab = {TabBtn = TabBtn, Page = Page, Indicator = Indicator}
    end

    TabBtn.MouseButton1Click:Connect(select)
    tabs[name] = {TabBtn = TabBtn, Page = Page, Select = select}
    return Page
end

local function CreateSection(parentPage, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 35)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = parentPage

    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.Padding = UDim.new(0, 6)
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Parent = SectionFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = string.upper(title)
    Label.TextColor3 = Color3.fromRGB(170, 175, 190)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SectionFrame

    SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SectionFrame.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y)
    end)
    return SectionFrame
end

local function CreateToggle(parentSection, text, default, callback)
    local TglFrame = Instance.new("Frame")
    TglFrame.Size = UDim2.new(1, 0, 0, 38)
    TglFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    TglFrame.BorderSizePixel = 0
    TglFrame.Parent = parentSection
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(30, 33, 43)
    Stroke.Parent = TglFrame

    local TglLabel = Instance.new("TextLabel")
    TglLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TglLabel.Position = UDim2.new(0, 12, 0, 0)
    TglLabel.BackgroundTransparency = 1
    TglLabel.Font = Enum.Font.GothamMedium
    TglLabel.Text = text
    TglLabel.TextColor3 = Color3.fromRGB(210, 215, 225)
    TglLabel.TextSize = 12
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left
    TglLabel.Parent = TglFrame

    local TglBtn = Instance.new("TextButton")
    TglBtn.Size = UDim2.new(0, 38, 0, 20)
    TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
    TglBtn.BackgroundColor3 = default and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(32, 35, 45)
    TglBtn.Text = ""
    TglBtn.Parent = TglFrame
    Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 10)

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 14, 0, 14)
    Switch.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Switch.BackgroundColor3 = default and Color3.fromRGB(20, 22, 28) or Color3.fromRGB(150, 155, 165)
    Switch.Parent = TglBtn
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 7)

    local state = default
    TglBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetBg = state and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(32, 35, 45)
        local targetBall = state and Color3.fromRGB(20, 22, 28) or Color3.fromRGB(150, 155, 165)
        local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        TweenService:Create(TglBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetBall}):Play()
        callback(state)
    end)
end

local function CreateSlider(parentSection, text, min, max, default, callback)
    local SldFrame = Instance.new("Frame")
    SldFrame.Size = UDim2.new(1, 0, 0, 46)
    SldFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    SldFrame.Parent = parentSection
    Instance.new("UICorner", SldFrame).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(30, 33, 43)
    Stroke.Parent = SldFrame

    local SldLabel = Instance.new("TextLabel")
    SldLabel.Size = UDim2.new(0.6, 0, 0, 22)
    SldLabel.Position = UDim2.new(0, 12, 0, 4)
    SldLabel.BackgroundTransparency = 1
    SldLabel.Font = Enum.Font.GothamMedium
    SldLabel.Text = text
    SldLabel.TextColor3 = Color3.fromRGB(210, 215, 225)
    SldLabel.TextSize = 12
    SldLabel.TextXAlignment = Enum.TextXAlignment.Left
    SldLabel.Parent = SldFrame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 22)
    ValLabel.Position = UDim2.new(1, -48, 0, 4)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    ValLabel.TextSize = 11
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = SldFrame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -24, 0, 4)
    SliderBar.Position = UDim2.new(0, 12, 0, 32)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    SliderBar.Text = ""
    SliderBar.Parent = SldFrame
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0, 2)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 2)

    local function MoveSlider(input)
        local totalWidth = SliderBar.AbsoluteSize.X
        local clickX = input.Position.X - SliderBar.AbsolutePosition.X
        local scale = math.clamp(clickX / totalWidth, 0, 1)
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        local value = math.floor(min + (max - min) * scale)
        ValLabel.Text = tostring(value)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            MoveSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            MoveSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- =========================================================================
-- ТВОИ ОРИГИНАЛЬНЫЕ ФУНКЦИИ ЛОГИКИ (ВЕРНУТЫ 1 В 1, БЕЗ СЖАТИЯ И ИЗМЕНЕНИЙ)
-- =========================================================================

local function StopFlying()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if BVelocity then
        BVelocity:Destroy()
        BVelocity = nil
    end
    if BGyro then
        BGyro:Destroy()
        BGyro = nil
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

local function StartFlying()
    StopFlying()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    hum.PlatformStand = true

    BVelocity = Instance.new("BodyVelocity", root)
    BVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    BVelocity.Velocity = Vector3.new(0, 0, 0)

    BGyro = Instance.new("BodyGyro", root)
    BGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    BGyro.P = 15000
    BGyro.D = 100
    BGyro.CFrame = root.CFrame

    local cam = workspace.CurrentCamera

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying or not root or not LocalPlayer.Character then
            StopFlying()
            return
        end
        if AutoFarmEnabled then return end

        BGyro.CFrame = cam.CFrame
        local moveDir = Vector3.new(0, 0, 0)

        if MasterControl and MasterControl.GetMoveVector then
            local moveVector = MasterControl:GetMoveVector()
            if moveVector.Magnitude > 0 then
                moveDir = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
            end
        end

        if moveDir.Magnitude == 0 and UserInputService.KeyboardEnabled then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        end

        if moveDir.Magnitude > 0 then
            BVelocity.Velocity = moveDir.Unit * FlySpeed
        else
            BVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function GetTargetCoinGlobal()
    if CachedCoin and CachedCoin.Parent and CachedCoin:IsA("BasePart") and CachedCoin.Transparency < 1 then
        return CachedCoin
    end
    if tick() < NextScanTime then return nil end
    NextScanTime = tick() + 0.3

    local coinContainer = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map") or workspace:FindFirstChild("CoinContainer")
    if coinContainer then
        for _, child in pairs(coinContainer:GetDescendants()) do
            if child:IsA("BasePart") and (string.find(child.Name:lower(), "coin") or child.Name == "Coin_Server") and child.Transparency < 1 then
                CachedCoin = child
                return child
            end
        end
    end
    for _, child in pairs(workspace:GetDescendants()) do
        if child:IsA("BasePart") and not child:IsDescendantOf(Players) and (string.find(child.Name:lower(), "coin") or child.Name == "Coin_Server" or child:FindFirstChild("CoinVisual")) and child.Transparency < 1 and child.Parent ~= nil then
            CachedCoin = child
            return child
        end
    end
    return nil
end

local function StopAutoFarm()
    if AutoFarmConnection then
        AutoFarmConnection:Disconnect()
        AutoFarmConnection = nil
    end
    if not Flying then StopFlying() end
end

local function StartAutoFarm()
    StopAutoFarm()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    hum.PlatformStand = true
    if not BVelocity or not BVelocity.Parent then
        BVelocity = Instance.new("BodyVelocity", root)
        BVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    end
    if not BGyro or not BGyro.Parent then
        BGyro = Instance.new("BodyGyro", root)
        BGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        BGyro.CFrame = root.CFrame
    end

    AutoFarmConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled then
            StopAutoFarm()
            return
        end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        
        local coin = GetTargetCoinGlobal()
        if coin and coin.Parent then
            BGyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(coin.Position.X, root.Position.Y, coin.Position.Z))
            local dir = (coin.Position - root.Position)
            if dir.Magnitude > 1.5 then
                BVelocity.Velocity = dir.Unit * AutoFarmSpeed
            else
                root.CFrame = coin.CFrame
                BVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        else
            BVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    local root = newChar:WaitForChild("HumanoidRootPart", 5)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if root and hum then
        task.wait(0.5)
        if AutoFarmEnabled then StartAutoFarm()
        elseif Flying then StartFlying() end
    end
end)

WalkSpeedConnection = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not Flying and not AutoFarmEnabled then
        hum.WalkSpeed = WalkSpeedEnabled and NormalWalkSpeed or 16
    end
end)

local function GetPlayerRoleAndTool(player)
    local isMurderer = false
    local isSheriff = false
    local specialTool = nil

    local function check(container)
        if not container then return end
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("Tool") then
                if item:FindFirstChild("KnifeServer") or item:FindFirstChild("KnifeClient") then
                    isMurderer = true
                    specialTool = item
                elseif item:FindFirstChild("GunScript") or item:FindFirstChild("GunClient") then
                    isSheriff = true
                    specialTool = item
                end
            end
        end
    end

    check(player:FindFirstChild("Backpack"))
    if player.Character then check(player.Character) end

    return isMurderer, isSheriff, specialTool
end

local function IsPlayerInGame(player)
    if not player or not player.Character then return false end
    
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChild("Humanoid")
    if not root or not hum or hum.Health <= 0 then return false end
    
    local map = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map")
    if not map then return false end 
    
    local mapPart = map:FindFirstChildWhichIsA("BasePart", true)
    if not mapPart then return false end 
    
    local distance = (root.Position - mapPart.Position).Magnitude
    if distance > 600 then 
        return false 
    end
    
    return true
end

local function ForceMobileShoot(gun, targetPos)
    if not gun or not targetPos then return false end
    
    for i = 1, 3 do
        gun:Activate()
        task.wait(0.02)
    end
    
    local cam = workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToScreenPoint(targetPos)
    
    if onScreen then
        VirtualInput:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
    else
        local viewportSize = cam.ViewportSize
        local centerX = viewportSize.X / 2
        local centerY = viewportSize.Y / 2
        VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end
    
    return true
end

-- ESP ПОКАЗЫВАЕТ СКВОЗЬ СТЕНЫ
task.spawn(function()
    while task.wait(0.2) do
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local char = player.Character
                    local hum = char:FindFirstChild("Humanoid")
                    
                    if hum and hum.Health > 0 then
                        local isMurd, isSher = GetPlayerRoleAndTool(player)
                        local color = Color3.fromRGB(50, 255, 100)
                        if isMurd then color = Color3.fromRGB(255, 30, 30) end
                        if isSher then color = Color3.fromRGB(30, 144, 255) end
                        
                        local hl = char:FindFirstChild("MM2_RoleESP")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "MM2_RoleESP"
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0.2
                            hl.Parent = char
                        end
                        hl.FillColor = color
                        hl.OutlineColor = color
                    else
                        local hl = char:FindFirstChild("MM2_RoleESP")
                        if hl then hl:Destroy() end
                    end
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local hl = player.Character:FindFirstChild("MM2_RoleESP")
                    if hl then hl:Destroy() end
                end
            end
        end
    end
end)

-- Auto Kill для МАНЬЯКА
task.spawn(function()
    while task.wait(0.25) do
        if AutoKillEnabled then
            local isMurderer, _, knife = GetPlayerRoleAndTool(LocalPlayer)
            
            if isMurderer and knife and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if myHum and knife.Parent ~= LocalPlayer.Character then
                    myHum:EquipTool(knife)
                    task.wait(0.1)
                end

                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and IsPlayerInGame(target) then
                        local targetIsMurderer, _, _ = GetPlayerRoleAndTool(target)
                        local targetHum = target.Character:FindFirstChild("Humanoid")
                        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        
                        if not targetIsMurderer and targetHum and targetHum.Health > 0 and not targetHum.PlatformStand then
                            myRoot.Velocity = Vector3.new(0, 0, 0)
                            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.5)
                            task.wait(0.1)
                            knife:Activate()
                            task.wait(0.3)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Shoot Murderer для ШЕРИФА (Исправлено для мобильных)
task.spawn(function()
    while task.wait(0.2) do
        if AutoShootMurdererEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if myHum and myHum.Health > 0 then
                    local _, isSheriff, gun = GetPlayerRoleAndTool(LocalPlayer)
                    
                    if isSheriff and gun then
                        if gun.Parent ~= LocalPlayer.Character then
                            myHum:EquipTool(gun)
                            task.wait(0.2)
                        end
                        
                        local murdererRoot = nil
                        
                        for _, target in pairs(Players:GetPlayers()) do
                            if target ~= LocalPlayer and IsPlayerInGame(target) then
                                local targetIsMurderer, _, _ = GetPlayerRoleAndTool(target)
                                if targetIsMurderer and target.Character then
                                    local targetHum = target.Character:FindFirstChild("Humanoid")
                                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                                    
                                    if targetHum and targetHum.Health > 0 and targetRoot then
                                        murdererRoot = targetRoot
                                        break
                                    end
                                end
                            end
                        end
                        
                        if murdererRoot then
                            local cam = workspace.CurrentCamera
                            cam.CameraType = Enum.CameraType.Scriptable
                            
                            myRoot.Velocity = Vector3.new(0,0,0)
                            myRoot.CFrame = murdererRoot.CFrame * CFrame.new(0, 0, 5)
                            
                            local aimCFrame = CFrame.lookAt(cam.CFrame.Position, murdererRoot.Position)
                            cam.CFrame = aimCFrame
                            
                            task.wait(0.1)
                            
                            ForceMobileShoot(gun, murdererRoot.Position)
                            
                            cam.CameraType = Enum.CameraType.Custom
                            task.wait(1.5)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if AutoGetGunEnabled then
            local _, isSheriff, _ = GetPlayerRoleAndTool(LocalPlayer)
            
            if not isSheriff and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                if myHum and myHum.Health > 0 then
                    local gunDrop = nil
                    local dropContainers = {
                        workspace:FindFirstChild("Normal"),
                        workspace:FindFirstChild("Map"),
                        workspace:FindFirstChild("Drops"),
                        workspace:FindFirstChild("Items"),
                        workspace:FindFirstChild("Weapons")
                    }
                    
                    for _, container in pairs(dropContainers) do
                        if container then
                            for _, obj in pairs(container:GetDescendants()) do
                                if obj:IsA("BasePart") and obj.Parent and not obj:IsDescendantOf(Players) then
                                    local objName = obj.Name:lower()
                                    if objName == "gundrop" or 
                                       objName == "gun_drop" or 
                                       objName == "gun" or
                                       (objName:find("gun") and obj:FindFirstChild("GunScript")) or
                                       (obj:FindFirstChild("GunScript") and obj:FindFirstChild("Handle")) then
                                        gunDrop = obj
                                        break
                                    end
                                end
                            end
                        end
                        if gunDrop then break end
                    end
                    
                    if not gunDrop then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj.Parent and not obj:IsDescendantOf(Players) then
                                local objName = obj.Name:lower()
                                if objName == "gundrop" or objName == "gun_drop" or 
                                   (objName:find("gun") and obj:FindFirstChild("GunScript")) then
                                    gunDrop = obj
                                    break
                                end
                            end
                        end
                    end
                    
                    if gunDrop and gunDrop:IsA("BasePart") and gunDrop.Parent and not gunDrop:IsDescendantOf(Players) then
                        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            myRoot.CFrame = gunDrop.CFrame * CFrame.new(0, 0, 1)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end
end)

-- =========================================================================
-- ИНИЦИАЛИЗАЦИЯ ВКЛАДОК И СЕКЦИЙ ИНТЕРФЕЙСА С ТВОИМИ КНОПКАМИ
-- =========================================================================

local MainTab = CreateTab("Главная", 1)
local PlayerTab = CreateTab("Игрок", 2)
local VisualTab = CreateTab("Визуал", 3)
local KillerTab = CreateTab("Киллер", 4)
local SheriffTab = CreateTab("Шериф", 5)

-- Вкладка: Главная
local FarmSec = CreateSection(MainTab, "Авто-Фарм Монет")
CreateToggle(FarmSec, "Универсальный Авто-Фарм Монет", false, function(state)
    AutoFarmEnabled = state
    if state then StartAutoFarm() else StopAutoFarm() end
end)

CreateSlider(FarmSec, "Скорость авто-фарма", 10, 25, 16, function(value)
    AutoFarmSpeed = value
end)

-- Вкладка: Игрок
local FlySec = CreateSection(PlayerTab, "Режимы Полета")
CreateToggle(FlySec, "Bypass Fly", false, function(state)
    Flying = state
    if state then StartFlying() else StopFlying() end
end)

CreateSlider(FlySec, "Скорость полета", 15, 90, 35, function(value)
    FlySpeed = value
end)

local WalkSec = CreateSection(PlayerTab, "Характеристики")
CreateToggle(WalkSec, "Toggle WalkSpeed", false, function(state)
    WalkSpeedEnabled = state
end)

CreateSlider(WalkSec, "WalkSpeed", 16, 120, 16, function(value)
    NormalWalkSpeed = value
end)

local WallSec = CreateSection(PlayerTab, "Окружение")
CreateToggle(WallSec, "Noclip (Сквозь стены)", false, function(state)
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

CreateToggle(WallSec, "Inf Jump", false, function(state)
    _G.InfJump = state
    if state then
        UserInputService.JumpRequest:Connect(function()
            if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- Вкладка: Визуал
local EspSec = CreateSection(VisualTab, "Отображение Ролей")
CreateToggle(EspSec, "MM2 ESP (Роли)", false, function(state)
    ESPEnabled = state
end)

-- Вкладка: Киллер
local KillSec = CreateSection(KillerTab, "Функции Убийцы")
CreateToggle(KillSec, "Auto Kill (Всех)", false, function(state)
    AutoKillEnabled = state
end)

-- Вкладка: Шериф
local SheriffSec = CreateSection(SheriffTab, "Функции Защиты")
CreateToggle(SheriffSec, "Авто-Убийство маньяка", false, function(state)
    AutoShootMurdererEnabled = state
end)

CreateToggle(SheriffSec, "Авто-подбор пистолета (Невиновным)", false, function(state)
    AutoGetGunEnabled = state
end)

if tabs["Главная"] then
    tabs["Главная"].Select()
end

CloseBtn.MouseButton1Click:Connect(function()
    Flying = false
    AutoFarmEnabled = false
    WalkSpeedEnabled = false
    ESPEnabled = false 
    AutoKillEnabled = false
    AutoShootMurdererEnabled = false 
    AutoGetGunEnabled = false
    StopFlying()
    StopAutoFarm()
    
    if NoclipConnection then NoclipConnection:Disconnect() end
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
    
    ScreenGui:Destroy()
end)
