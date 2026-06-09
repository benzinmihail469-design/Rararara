local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("MM2FlyFollowGui") then
    PlayerGui.MM2FlyFollowGui:Destroy()
end

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
Title.Text = "MM2 AUTOFARM & FLY"
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

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 300)
    MinBtn.Text = isMinimized and "+" or "-"
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
end)

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

local function CreateToggle(parentPage, text, default, callback)
    local TglFrame = Instance.new("Frame")
    TglFrame.Size = UDim2.new(1, -6, 0, 40)
    TglFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TglFrame.Parent = parentPage
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)

    local TglLabel = Instance.new("TextLabel")
    TglLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TglLabel.Position = UDim2.new(0, 10, 0, 0)
    TglLabel.BackgroundTransparency = 1
    TglLabel.Font = Enum.Font.GothamSemibold
    TglLabel.Text = text
    TglLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TglLabel.TextSize = 13
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left
    TglLabel.Parent = TglFrame

    local TglBtn = Instance.new("TextButton")
    TglBtn.Size = UDim2.new(0, 45, 0, 22)
    TglBtn.Position = UDim2.new(1, -55, 0.5, -11)
    TglBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(50, 50, 55)
    TglBtn.Text = ""
    TglBtn.Parent = TglFrame
    Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 11)

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 16, 0, 16)
    Switch.Position = default and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    Switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Switch.Parent = TglBtn
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 8)

    local state = default
    TglBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(50, 50, 55)
        local targetPos = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        TweenService:Create(TglBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2), {Position = targetPos}):Play()
        callback(state)
    end)
end

local function CreateSlider(parentPage, text, min, max, default, callback)
    local SldFrame = Instance.new("Frame")
    SldFrame.Size = UDim2.new(1, -6, 0, 50)
    SldFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    SldFrame.Parent = parentPage
    Instance.new("UICorner", SldFrame).CornerRadius = UDim.new(0, 6)

    local SldLabel = Instance.new("TextLabel")
    SldLabel.Size = UDim2.new(0.6, 0, 0, 25)
    SldLabel.Position = UDim2.new(0, 10, 0, 2)
    SldLabel.BackgroundTransparency = 1
    SldLabel.Font = Enum.Font.GothamSemibold
    SldLabel.Text = text
    SldLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    SldLabel.TextSize = 13
    SldLabel.TextXAlignment = Enum.TextXAlignment.Left
    SldLabel.Parent = SldFrame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValLabel.Position = UDim2.new(0.7, -10, 0, 2)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
    ValLabel.TextSize = 13
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = SldFrame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 34)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Text = ""
    SliderBar.Parent = SldFrame
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0, 3)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 3)

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
    if not root or not hum then
        return
    end
    
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
        if AutoFarmEnabled then
            return
        end

        BGyro.CFrame = cam.CFrame
        local moveDir = Vector3.new(0, 0, 0)

        if MasterControl and MasterControl.GetMoveVector then
            local moveVector = MasterControl:GetMoveVector()
            if moveVector.Magnitude > 0 then
                moveDir = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
            end
        end

        if moveDir.Magnitude == 0 and UserInputService.KeyboardEnabled then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
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
    if tick() < NextScanTime then
        return nil
    end
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
    if not Flying then
        StopFlying()
    end
end

local function StartAutoFarm()
    StopAutoFarm()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then
        return
    end
    
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
        if not root then
            return
        end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
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
        if AutoFarmEnabled then
            StartAutoFarm()
        elseif Flying then
            StartFlying()
        end
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
        if not container then
            return
        end
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or item:FindFirstChild("KnifeServer") or item:FindFirstChild("Slash") then
                    isMurderer = true
                    specialTool = item
                elseif name:find("gun") or name:find("revolver") or item:FindFirstChild("GunScript") then
                    isSheriff = true
                    specialTool = item
                end
            end
        end
    end

    check(player:FindFirstChild("Backpack"))
    if player.Character then
        check(player.Character)
    end

    return isMurderer, isSheriff, specialTool
end

-- ИСПРАВЛЕНИЕ: Стабильный ESP без мерцания
task.spawn(function()
    while task.wait(0.2) do
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local char = player.Character
                    local hum = char:FindFirstChild("Humanoid")
                    
                    if hum and hum.Health > 0 then
                        local isMurd, isSher = GetPlayerRoleAndTool(player)
                        local color = Color3.fromRGB(50, 255, 100) -- Innocent
                        if isMurd then color = Color3.fromRGB(255, 30, 30) end -- Murderer
                        if isSher then color = Color3.fromRGB(30, 144, 255) end -- Sheriff
                        
                        local hl = char:FindFirstChild("MM2_RoleESP")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "MM2_RoleESP"
                            hl.FillTransparency = 0.65
                            hl.OutlineTransparency = 0.1
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

task.spawn(function()
    while task.wait(0.2) do
        if AutoKillEnabled then
            local _, _, knife = GetPlayerRoleAndTool(LocalPlayer)
            
            if knife and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if myHum and knife.Parent ~= LocalPlayer.Character then
                    myHum:EquipTool(knife)
                    task.wait(0.1)
                end

                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHum = target.Character:FindFirstChild("Humanoid")
                        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        
                        if targetHum and targetHum.Health > 0 and not targetHum.PlatformStand then
                            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.5)
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

-- ИСПРАВЛЕНИЕ: Функция выстрела с конвертацией 3D позиции в 2D координаты экрана
local function ForceMobileShoot(gun, targetPos)
    if not gun or not targetPos then
        return false
    end
    
    for i = 1, 3 do
        gun:Activate()
        task.wait(0.02)
    end
    
    local cam = workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToScreenPoint(targetPos)
    
    if onScreen then
        -- Эмулируем "Тап" по экрану прямо в координаты, где сейчас убийца
        VirtualInput:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
    else
        -- Запасной вариант на случай, если убийца вылетел за пределы экрана
        local viewportSize = cam.ViewportSize
        local centerX = viewportSize.X / 2
        local centerY = viewportSize.Y / 2
        VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end
    
    return true
end

-- ИСПРАВЛЕНИЕ: Логика AutoShootMurdererEnabled с передачей позиции
task.spawn(function()
    while task.wait(0.15) do
        if AutoShootMurdererEnabled then
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(0.5)
            else
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not myHum or myHum.Health <= 0 then
                    task.wait(0.5)
                else
                    local _, isSheriff, gun = GetPlayerRoleAndTool(LocalPlayer)
                    
                    if isSheriff and gun then
                        if gun.Parent ~= LocalPlayer.Character then
                            myHum:EquipTool(gun)
                            task.wait(0.2)
                        end
                        
                        local murdererRoot = nil
                        
                        for _, target in pairs(Players:GetPlayers()) do
                            if target ~= LocalPlayer then
                                local targetMurd, _, _ = GetPlayerRoleAndTool(target)
                                if targetMurd and target.Character then
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
                            -- Телепортируемся на дистанцию для идеального обзора
                            myRoot.CFrame = murdererRoot.CFrame * CFrame.new(0, 0, 4)
                            task.wait(0.1)
                            
                            local cam = workspace.CurrentCamera
                            local lookAtCFrame = CFrame.lookAt(myRoot.Position, murdererRoot.Position)
                            
                            myRoot.CFrame = lookAtCFrame
                            cam.CFrame = lookAtCFrame
                            
                            task.wait(0.1)
                            
                            -- Вызываем нашу новую функцию выстрела с наводкой (aimbot)
                            for i = 1, 4 do
                                ForceMobileShoot(gun, murdererRoot.Position)
                                task.wait(0.1)
                            end
                            
                            task.wait(0.5)
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
                        if gunDrop then
                            break
                        end
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

local MainTab = CreateTab("Главная", 1)
local PlayerTab = CreateTab("Игрок", 2)
local VisualTab = CreateTab("Визуал", 3)
local KillerTab = CreateTab("Киллер", 4)
local SheriffTab = CreateTab("Шериф", 5) 

CreateToggle(MainTab, "Универсальный Авто-Фарм Монет", false, function(state)
    AutoFarmEnabled = state
    if state then
        StartAutoFarm()
    else
        StopAutoFarm()
    end
end)

CreateSlider(MainTab, "Скорость авто-фарма", 10, 25, 16, function(value)
    AutoFarmSpeed = value
end)

CreateToggle(PlayerTab, "Bypass Fly", false, function(state)
    Flying = state
    if state then
        StartFlying()
    else
        StopFlying()
    end
end)

CreateSlider(PlayerTab, "Скорость полета", 15, 90, 35, function(value)
    FlySpeed = value
end)

CreateToggle(PlayerTab, "Toggle WalkSpeed", false, function(state)
    WalkSpeedEnabled = state
end)

CreateSlider(PlayerTab, "WalkSpeed", 16, 120, 16, function(value)
    NormalWalkSpeed = value
end)

CreateToggle(PlayerTab, "Noclip (Сквозь стены)", false, function(state)
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
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
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

CreateToggle(PlayerTab, "Inf Jump", false, function(state)
    _G.InfJump = state
    if state then
        UserInputService.JumpRequest:Connect(function()
            if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

CreateToggle(VisualTab, "MM2 ESP (Роли)", false, function(state)
    ESPEnabled = state
end)

CreateToggle(KillerTab, "Auto Kill (Всех)", false, function(state)
    AutoKillEnabled = state
end)

CreateToggle(SheriffTab, "Авто-Убийство маньяка", false, function(state)
    AutoShootMurdererEnabled = state
end)

CreateToggle(SheriffTab, "Авто-подбор пистолета (Невиновным)", false, function(state)
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
    
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end
    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
    end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
    end
    
    ScreenGui:Destroy()
end) 
