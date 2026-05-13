-- Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local IYMouse = player:GetMouse()

-- ===== ПЕРЕМЕННЫЕ =====
local ActiveNoCooldownPrompt = false
local ActiveDistanceEsp = false
local ActiveBigPrompt = false
local DisableLimitRangerEsp = false
local LimitRangerEsp = 100
local ValueRunSpeed = 24
local ActiveSpeedBoost = false
local ValueWalkSpeed = 15
local ActiveSpeedBoost2 = false
local ActiveEspKillers = false
local ActiveEspSurvivors = false
local ActiveEspGen = false
local AutoEscape = false
local AutoGen = false
local ActiveEspFuseBoxes = false
local FighterAutoParry = false
local ActiveEspBattery = false
local AutoBarricade = false
local AutoSafeSpot = false
local HitboxExpender = false
local ValueHE = 15
local ActiveEspTraps = false
local ActiveEspWireEyes = false
local AutoShakeWireEyes = false
local ActiveInfiniteStamina = false
local CanShake = true
local NoBlindness = false
local CanGenerator = true
local ShakeTime = 0.5
local SizeBoxBarricade = 0.3
local InvisibilityKiller = false
local ActiveNoclip = false
local ActivateFly = false
local AutoFarm = false
local CanGo = true
local ActivateJumping = false
local JumpPowerValue = 50
local State = "Idle"
local TimeForGenerator = 1.25
local AutoHighlightKillerCamera = false
local AutoPhase = false
local Teleported = false
local AntiConfusion = false
local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1
local SPEED = 30
local CanPhase = true
local LastAction = 0
local Cooldown = 0.5
local LineESPEnabled = false
local SavedCFrame = nil
local TimeAutoHighlight = 0.1
local CanParry = true

local ESPs = {}
local flyKeyDown, flyKeyUp

-- ===== ФУНКЦИИ =====

-- Создание ESP
local function CreateEsp(Char, Color, Text, Parent)
    if not Char or not Parent then return end
    if Char:FindFirstChild("ESP") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = Char
    highlight.FillColor = Color
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = Char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(10, 0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, -2, 0)
    billboard.Adornee = Parent
    billboard.Enabled = true
    billboard.Parent = Parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = Text
    label.TextColor3 = Color
    label.TextScaled = true
    label.Parent = billboard

    table.insert(ESPs, {
        Char = Char,
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Part = Parent,
        Text = Text,
        Color = Color
    })
end

-- Удаление ESP
local function KeepEsp(Char)
    if not Char then return end
    for i = #ESPs, 1, -1 do
        local esp = ESPs[i]
        if esp.Char == Char then
            if esp.Highlight then esp.Highlight:Destroy() end
            if esp.Billboard then esp.Billboard:Destroy() end
            table.remove(ESPs, i)
        end
    end
end

-- Очистка всех ESP
local function ClearAllESP()
    for _, esp in pairs(ESPs) do
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
    end
    ESPs = {}
end

-- Обновление ESP Survivors
local function UpdateEspSurvivors()
    ClearAllESP()
    if ActiveEspSurvivors then
        for _, plr in pairs(Workspace.PLAYERS.ALIVE:GetChildren()) do
            if plr:IsA("Model") and plr.PrimaryPart and not plr.PrimaryPart:FindFirstChild("ESP") then
                CreateEsp(plr, Color3.fromRGB(0, 255, 0), plr.Name, plr.PrimaryPart)
            end
        end
    end
end

-- Обновление ESP Killers
local function UpdateEspKillers()
    if ActiveEspKillers then
        for _, plr in pairs(Workspace.PLAYERS.KILLER:GetChildren()) do
            if plr:IsA("Model") then
                local part = plr:FindFirstChild("RootPart") or plr:FindFirstChild("HumanoidRootPart")
                if part and not part:FindFirstChild("ESP") then
                    CreateEsp(plr, Color3.fromRGB(255, 0, 0), plr.Name, part)
                end
            end
        end
    end
end

-- Обновление ESP Generators
local function UpdateEspGenerators()
    if ActiveEspGen and Workspace.MAPS:FindFirstChild("GAME MAP") then
        for _, gen in pairs(Workspace.MAPS["GAME MAP"].Generators:GetChildren()) do
            if gen:IsA("Model") and gen.PrimaryPart and not gen.PrimaryPart:FindFirstChild("ESP") then
                CreateEsp(gen, Color3.fromRGB(255, 255, 0), "Generator", gen.PrimaryPart)
            end
        end
    end
end

-- Обновление ESP Fuse Boxes
local function UpdateEspFuseBoxes()
    if ActiveEspFuseBoxes and Workspace.MAPS:FindFirstChild("GAME MAP") then
        local fuseFolder = Workspace.MAPS["GAME MAP"]:FindFirstChild("FuseBoxes")
        if fuseFolder then
            for _, fuse in pairs(fuseFolder:GetChildren()) do
                if fuse:IsA("Model") and fuse.PrimaryPart and not fuse.PrimaryPart:FindFirstChild("ESP") then
                    CreateEsp(fuse, Color3.fromRGB(0, 0, 255), "Fuse Box", fuse.PrimaryPart)
                end
            end
        end
    end
end

-- Обновление ESP Battery
local function UpdateEspBattery()
    if ActiveEspBattery then
        for _, battery in pairs(Workspace.IGNORE:GetChildren()) do
            if battery:IsA("BasePart") and battery.Name == "Battery" and not battery:FindFirstChild("ESP") then
                CreateEsp(battery, Color3.fromRGB(0, 0, 255), "Battery", battery)
            end
        end
    end
end

-- Обновление ESP Traps
local function UpdateEspTraps()
    if ActiveEspTraps then
        for _, trap in pairs(Workspace.IGNORE:GetChildren()) do
            if trap:IsA("Model") and trap.Name == "Trap" and trap.PrimaryPart and not trap.PrimaryPart:FindFirstChild("ESP") then
                CreateEsp(trap, Color3.fromRGB(255, 0, 0), "Trap", trap.PrimaryPart)
            end
        end
    end
end

-- Функция Noclip
local function Noclip()
    if ActiveNoclip then
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- Функция TweenTo
local function TweenTo(character, cf)
    local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not root then return end
    local distance = (root.Position - cf.Position).Magnitude
    local time = distance / SPEED
    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

-- Функция Fly для PC
local function sFLY()
    if FLYING then return end
    FLYING = true
    local character = player.Character
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart")
    
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = root.CFrame
    bg.Parent = root
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not FLYING or not root or not root.Parent then
            connection:Disconnect()
            bg:Destroy()
            bv:Destroy()
            if character:FindFirstChildOfClass("Humanoid") then
                character:FindFirstChildOfClass("Humanoid").PlatformStand = false
            end
            return
        end
        
        character:FindFirstChildOfClass("Humanoid").PlatformStand = true
        bg.CFrame = Camera.CFrame
        
        local speed = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            bv.Velocity = Camera.CFrame.LookVector * (iyflyspeed * 50)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
            bv.Velocity = -Camera.CFrame.LookVector * (iyflyspeed * 50)
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function NOFLY()
    FLYING = false
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

-- Функция авто-багрикады
local function getNewestDot()
    for _, child in pairs(player.PlayerGui:GetChildren()) do
        if child.Name == "Dot" then return child end
    end
    return nil
end

-- Функция инвиза для киллера
local function ApplyInvisibility(enabled)
    local character = player.Character
    if not character or not enabled then return end
    
    if character:GetAttribute("Team") == "Killer" then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0.5
            end
        end
    end
end

-- ===== ЦВЕТА =====
local colors = {
    bg = Color3.fromRGB(15, 5, 20),
    titleBg = Color3.fromRGB(25, 10, 35),
    tabBg = Color3.fromRGB(20, 8, 30),
    tabActive = Color3.fromRGB(80, 20, 100),
    tabInactive = Color3.fromRGB(30, 12, 45),
    accent = Color3.fromRGB(180, 50, 220),
    gold = Color3.fromRGB(255, 180, 50),
    text = Color3.fromRGB(220, 200, 230),
    textDark = Color3.fromRGB(150, 130, 160),
    close = Color3.fromRGB(180, 30, 30),
    stroke = Color3.fromRGB(100, 50, 130),
    toggleOn = Color3.fromRGB(100, 30, 160),
    toggleOff = Color3.fromRGB(35, 15, 55),
    toggleCircle = Color3.fromRGB(220, 180, 255),
    buttonBg = Color3.fromRGB(50, 20, 80),
    buttonHover = Color3.fromRGB(70, 30, 110),
}

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkFantasy_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = colors.bg
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = colors.stroke

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 2)
TitleBar.BackgroundColor3 = colors.titleBg
TitleBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Text = "BBN Script"
Title.Size = UDim2.new(0, 100, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

local MinimizeBtn = Instance.new("TextButton", Main)
MinimizeBtn.Text = "_"
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -52, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.ZIndex = 10
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 5)
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local CollapsibleContent = Instance.new("Frame", Main)
CollapsibleContent.Size = UDim2.new(1, 0, 1, -32)
CollapsibleContent.Position = UDim2.new(0, 0, 0, 32)
CollapsibleContent.BackgroundTransparency = 1

local TabFrame = Instance.new("Frame", CollapsibleContent)
TabFrame.Size = UDim2.new(1, 0, 0, 26)
TabFrame.BackgroundColor3 = colors.tabBg

local layout = Instance.new("UIListLayout", TabFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 2)

local ContentFrame = Instance.new("Frame", CollapsibleContent)
ContentFrame.Size = UDim2.new(1, -16, 1, -32)
ContentFrame.Position = UDim2.new(0, 8, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(10, 3, 15)
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 8)

-- Функция создания кнопки
local function CreateButton(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Text = name
    btn.Size = UDim2.new(1, -16, 0, 28)
    btn.Position = UDim2.new(0, 8, 0, 2)
    btn.BackgroundColor3 = colors.buttonBg
    btn.TextColor3 = colors.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Функция создания тоггла
local function CreateToggle(parent, name, default, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    
    local label = Instance.new("TextButton", container)
    label.Text = name
    label.Size = UDim2.new(1, -50, 0, 24)
    label.Position = UDim2.new(0, 8, 0, 3)
    label.BackgroundColor3 = Color3.fromRGB(30, 12, 45)
    label.TextColor3 = colors.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BorderSizePixel = 0
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 5)
    
    local toggle = Instance.new("Frame", container)
    toggle.Size = UDim2.new(0, 36, 0, 18)
    toggle.Position = UDim2.new(1, -42, 0, 6)
    toggle.BackgroundColor3 = default and colors.toggleOn or colors.toggleOff
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 9)
    
    local circle = Instance.new("Frame", toggle)
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    circle.BackgroundColor3 = default and colors.toggleCircle or Color3.fromRGB(100, 80, 120)
    circle.BorderSizePixel = 0
    Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 7)
    
    local isOn = default
    
    local clickBtn = Instance.new("TextButton", toggle)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 8
    
    local function update()
        isOn = not isOn
        toggle.BackgroundColor3 = isOn and colors.toggleOn or colors.toggleOff
        circle.BackgroundColor3 = isOn and colors.toggleCircle or Color3.fromRGB(100, 80, 120)
        circle.Position = isOn and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
        callback(isOn)
    end
    
    clickBtn.MouseButton1Click:Connect(update)
    label.MouseButton1Click:Connect(update)
    
    return container
end

-- Вкладки
local tabs = {}
local tabNames = {"Main", "Player", "Esp", "Info", "Discord"}

local function SwitchTab(name)
    for n, content in pairs(tabs) do
        content.Visible = (n == name)
    end
end

for _, name in ipairs(tabNames) do
    local tabContent = Instance.new("Frame", ContentFrame)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabs[name] = tabContent
    
    local tabBtn = Instance.new("TextButton", TabFrame)
    tabBtn.Text = name
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.BackgroundColor3 = colors.tabInactive
    tabBtn.TextColor3 = colors.textDark
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 10
    tabBtn.BorderSizePixel = 0
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)
    
    tabBtn.MouseButton1Click:Connect(function()
        SwitchTab(name)
        for _, btn in pairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = colors.tabInactive
            end
        end
        tabBtn.BackgroundColor3 = colors.tabActive
    end)
end

SwitchTab("Main")

-- ===== ЗАПОЛНЕНИЕ ВКЛАДОК =====

local mainTab = tabs["Main"]
local playerTab = tabs["Player"]
local espTab = tabs["Esp"]

-- Main функции
CreateToggle(mainTab, "Auto Farm", false, function(val) AutoFarm = val end)
CreateToggle(mainTab, "Auto Parry", false, function(val) FighterAutoParry = val end):Position = UDim2.new(0, 0, 0, 32)
CreateToggle(mainTab, "Auto Generator", false, function(val) AutoGen = val end):Position = UDim2.new(0, 0, 0, 64)
CreateToggle(mainTab, "Auto Escape", false, function(val) AutoEscape = val end):Position = UDim2.new(0, 0, 0, 96)
CreateToggle(mainTab, "Auto Barricade", false, function(val) AutoBarricade = val end):Position = UDim2.new(0, 0, 0, 128)
CreateToggle(mainTab, "Invisible Killer", false, function(val) InvisibilityKiller = val; ApplyInvisibility(val) end):Position = UDim2.new(0, 0, 0, 160)
CreateToggle(mainTab, "Hitbox Expender", false, function(val) HitboxExpender = val end):Position = UDim2.new(0, 0, 0, 192)
CreateToggle(mainTab, "Instant Prompt", false, function(val) ActiveNoCooldownPrompt = val end):Position = UDim2.new(0, 0, 0, 224)

CreateButton(mainTab, "Delete Doors", function()
    local doors = Workspace.MAPS:FindFirstChild("GAME MAP") and Workspace.MAPS["GAME MAP"]:FindFirstChild("Doors")
    if doors then doors:Destroy() end
end).Position = UDim2.new(0, 8, 0, 262)

CreateButton(mainTab, "Skip Cutscene", function()
    local rigs = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Cutscenes"):WaitForChild("Rigs")
    for _, name in ipairs({"IntroCam", "KillCam", "OutroCam"}) do
        local rig = rigs:FindFirstChild(name)
        if rig then rig:Destroy() end
    end
end).Position = UDim2.new(0, 8, 0, 295)

-- Player функции
CreateToggle(playerTab, "Noclip", false, function(val) ActiveNoclip = val; Noclip() end)
CreateToggle(playerTab, "Fly", false, function(val)
    ActivateFly = val
    if val then sFLY() else NOFLY() end
end):Position = UDim2.new(0, 0, 0, 32)
CreateToggle(playerTab, "Infinity Jump", false, function(val) ActivateJumping = val end):Position = UDim2.new(0, 0, 0, 64)
CreateToggle(playerTab, "Infinite Stamina", false, function(val) ActiveInfiniteStamina = val end):Position = UDim2.new(0, 0, 0, 96)
CreateToggle(playerTab, "Speed Boost", false, function(val) ActiveSpeedBoost = val end):Position = UDim2.new(0, 0, 0, 128)

-- ESP функции
CreateToggle(espTab, "ESP Survivors", false, function(val) ActiveEspSurvivors = val; UpdateEspSurvivors() end)
CreateToggle(espTab, "ESP Killers", false, function(val) ActiveEspKillers = val; UpdateEspKillers() end):Position = UDim2.new(0, 0, 0, 32)
CreateToggle(espTab, "ESP Generators", false, function(val) ActiveEspGen = val; UpdateEspGenerators() end):Position = UDim2.new(0, 0, 0, 64)
CreateToggle(espTab, "ESP Fuse Boxes", false, function(val) ActiveEspFuseBoxes = val; UpdateEspFuseBoxes() end):Position = UDim2.new(0, 0, 0, 96)
CreateToggle(espTab, "ESP Battery", false, function(val) ActiveEspBattery = val; UpdateEspBattery() end):Position = UDim2.new(0, 0, 0, 128)
CreateToggle(espTab, "ESP Traps", false, function(val) ActiveEspTraps = val; UpdateEspTraps() end):Position = UDim2.new(0, 0, 0, 160)

-- Перетаскивание
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Сворачивание
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    CollapsibleContent.Visible = not minimized
    Main.Size = minimized and UDim2.new(0, 200, 0, 32) or UDim2.new(0, 520, 0, 360)
end)

-- Закрытие
CloseBtn.MouseButton1Click:Connect(function()
    ClearAllESP()
    NOFLY()
    ScreenGui:Destroy()
end)

-- Игровой цикл
RunService.RenderStepped:Connect(function()
    if not player.Character then return end
    
    -- Noclip
    if ActiveNoclip then Noclip() end
    
    -- Speed Boost
    if ActiveSpeedBoost then
        player.Character:SetAttribute("RunSpeed", ValueRunSpeed)
    end
    
    -- Infinite Stamina
    if ActiveInfiniteStamina then
        player.Character:SetAttribute("Stamina", 100)
    end
    
    -- Jump Power
    if ActivateJumping and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").JumpPower = JumpPowerValue
    end
end)

-- Auto Farm цикл
task.spawn(function()
    while true do
        task.wait(1)
        if AutoFarm and player.Character and CanGo then
            -- Поиск батарейки
            for _, item in pairs(Workspace.IGNORE:GetChildren()) do
                if item.Name == "Battery" and item:IsA("BasePart") then
                    local prompt = item:FindFirstChild("Attachment") and item.Attachment:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        player.Character:PivotTo(item.CFrame)
                        fireproximityprompt(prompt)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

print("BBN Script загружен и работает!")
