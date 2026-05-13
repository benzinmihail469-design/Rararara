-- =============================================
--  Тёмный Fantasy GUI - Полная версия
--  Собрано из 5 частей | Оптимизировано
-- =============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = player:GetMouse()

-- ==================== ПЕРЕМЕННЫЕ ====================
local ActiveNoCooldownPrompt = false
local HitboxExpender = false
local ValueHE = 15
local ValueRunSpeed = 24
local ValueWalkSpeed = 15
local ActiveSpeedBoost = false
local ActiveSpeedBoost2 = false

local ActiveEspSurvivors = false
local ActiveEspKillers = false
local ActiveEspGen = false
local ActiveEspFuseBoxes = false
local ActiveEspBattery = false
local ActiveEspTraps = false
local ActiveEspWireEyes = false

local AutoFarm = false
local AutoGen = false
local AutoEscape = false
local AutoBarricade = false
local AutoShakeWireEyes = false
local FighterAutoParry = false
local AutoPhase = false
local AntiConfusion = false
local InvisibilityKiller = false

local ActiveNoclip = false
local ActivateFly = false
local ActivateJumping = false
local JumpPowerValue = 50
local ActiveInfiniteStamina = false

local ShakeTime = 0.5
local SizeBoxBarricade = 0.3
local TimeForGenerator = 1.25
local Cooldown = 0.5
local LastAction = 0
local CanGo = true
local CanShake = true
local CanParry = true
local CanPhase = true
local Teleported = false

local FLYING = false
local iyflyspeed = 1
local QEfly = true

local ESPs = {}
local flyKeyDown, flyKeyUp

-- ==================== ЦВЕТА ====================
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

-- ==================== БЕЗОПАСНЫЙ ВЫЗОВ ====================
local function safeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        warn("[DarkFantasy] Ошибка:", err)
    end
end

-- ==================== ФУНКЦИИ ====================

local function sFLY()
    if FLYING then return end
    FLYING = true

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        FLYING = false return 
    end

    local root = character.HumanoidRootPart
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}

    local BG = Instance.new("BodyGyro")
    local BV = Instance.new("BodyVelocity")
    BG.P = 9e4
    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.Parent = root

    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Parent = root

    flyKeyDown = Mouse.KeyDown:Connect(function(key)
        key = key:lower()
        if key == 'w' then CONTROL.F = iyflyspeed
        elseif key == 's' then CONTROL.B = -iyflyspeed
        elseif key == 'a' then CONTROL.L = -iyflyspeed
        elseif key == 'd' then CONTROL.R = iyflyspeed
        elseif QEfly and key == 'e' then CONTROL.Q = iyflyspeed * 2
        elseif QEfly and key == 'q' then CONTROL.E = -iyflyspeed * 2
        end
    end)

    flyKeyUp = Mouse.KeyUp:Connect(function(key)
        key = key:lower()
        if key == 'w' then CONTROL.F = 0
        elseif key == 's' then CONTROL.B = 0
        elseif key == 'a' then CONTROL.L = 0
        elseif key == 'd' then CONTROL.R = 0
        elseif key == 'e' then CONTROL.Q = 0
        elseif key == 'q' then CONTROL.E = 0
        end
    end)

    task.spawn(function()
        while FLYING and character.Parent do
            RunService.RenderStepped:Wait()
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end

            local moveDir = Camera.CFrame:VectorToWorldSpace(Vector3.new(
                CONTROL.L + CONTROL.R, 
                (CONTROL.Q + CONTROL.E) * 0.7, 
                CONTROL.F + CONTROL.B
            ))

            BV.Velocity = moveDir * 50
            BG.CFrame = Camera.CFrame
        end

        if BG then BG:Destroy() end
        if BV then BV:Destroy() end
        safeCall(function()
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end)
    end)
end

local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    safeCall(function()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end

local function Noclip()
    safeCall(function()
        if not player.Character then return end
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if ActiveNoclip then
                    if not part:GetAttribute("OldCollide") then
                        part:SetAttribute("OldCollide", part.CanCollide)
                    end
                    part.CanCollide = false
                elseif part:GetAttribute("OldCollide") ~= nil then
                    part.CanCollide = part:GetAttribute("OldCollide")
                end
            end
        end
    end)
end

local function doShake(wireyesUI)
    safeCall(function()
        local client = wireyesUI:WaitForChild("WireyesClient", 2)
        local remote = client and client:WaitForChild("WireyesEvent", 2)
        if not remote then return end

        CanShake = false
        task.delay(ShakeTime, function() CanShake = true end)

        remote:FireServer("Shaking")
        task.wait(0.05)
        remote:FireServer("TakeOff", Workspace:GetServerTimeNow())
    end)
end

local function ApplyInvisibility(enabled)
    safeCall(function()
        local char = player.Character
        if not char or not enabled then return end
        if char:GetAttribute("Team") == "Killer" then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        print("✅ Ссылка скопирована")
    else
        warn("setclipboard не поддерживается")
    end
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkFantasy_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 540, 0, 380)
Main.Position = UDim2.new(0.5, -270, 0.5, -190)
Main.BackgroundColor3 = colors.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", Main)
stroke.Color = colors.stroke
stroke.Thickness = 1.6

local AccentLine = Instance.new("Frame", Main)
AccentLine.Size = UDim2.new(1, 0, 0, 3)
AccentLine.BackgroundColor3 = colors.accent
Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(0, 14)

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = colors.titleBg
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Тёмный Fantasy"
Title.TextColor3 = colors.gold
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -72, 0, 3)
MinimizeBtn.Text = "—"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 70)
MinimizeBtn.TextColor3 = colors.gold
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 3)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = colors.close
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local TabButtonsFrame = Instance.new("Frame", Main)
TabButtonsFrame.Size = UDim2.new(1, -20, 0, 34)
TabButtonsFrame.Position = UDim2.new(0, 10, 0, 46)
TabButtonsFrame.BackgroundColor3 = colors.tabBg
Instance.new("UICorner", TabButtonsFrame).CornerRadius = UDim.new(0, 8)

local ContentContainer = Instance.new("Frame", Main)
ContentContainer.Size = UDim2.new(1, -20, 1, -95)
ContentContainer.Position = UDim2.new(0, 10, 0, 85)
ContentContainer.BackgroundColor3 = Color3.fromRGB(12, 4, 18)
ContentContainer.BackgroundTransparency = 0.4
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 10)

local tabs = {}
local tabButtons = {}

local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 1, 0)
    btn.BackgroundColor3 = (name == "Main") and colors.tabActive or colors.tabInactive
    btn.Text = name
    btn.TextColor3 = (name == "Main") and colors.gold or colors.textDark
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = TabButtonsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for n, content in pairs(tabs) do
            content.Visible = (n == name)
        end
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = (b == btn) and colors.tabActive or colors.tabInactive
            b.TextColor3 = (b == btn) and colors.gold or colors.textDark
        end
    end)
    tabButtons[name] = btn
end

local function createTabContent(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 5
    frame.ScrollBarImageColor3 = colors.accent
    frame.Visible = (name == "Main")
    frame.Parent = ContentContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    tabs[name] = frame
    return frame
end

for _, name in ipairs({"Main", "Player", "ESP", "Info", "Настройки"}) do
    createTabButton(name)
    createTabContent(name)
end

-- ==================== Toggle и Button функции ====================
local function createToggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 36)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = colors.buttonBg
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", bg)
    label.Size = UDim2.new(0.72, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = colors.text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("Frame", bg)
    switch.Size = UDim2.new(0, 42, 0, 20)
    switch.Position = UDim2.new(1, -54, 0.5, -10)
    switch.BackgroundColor3 = default and colors.toggleOn or colors.toggleOff
    Instance.new("UICorner", switch).CornerRadius = UDim.new(0, 10)

    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = colors.toggleCircle
    Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 8)

    local enabled = default

    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            switch.BackgroundColor3 = enabled and colors.toggleOn or colors.toggleOff
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = enabled and UDim2.new(0,22,0.5,-8) or UDim2.new(0,2,0.5,-8)
            }):Play()
            if callback then callback(enabled) end
        end
    end)
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.BackgroundColor3 = colors.buttonBg
    btn.Text = text
    btn.TextColor3 = colors.text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(callback or function() end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = colors.buttonHover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = colors.buttonBg}):Play() end)
end

-- Заполнение вкладок
createToggle(tabs.Main, "⚡ Auto Farm", false, function(v) AutoFarm = v end)
createToggle(tabs.Main, "🎯 Auto Parry (Fighter)", false, function(v) FighterAutoParry = v end)
createToggle(tabs.Main, "🔧 Auto Generator", false, function(v) AutoGen = v end)
createToggle(tabs.Main, "🚪 Auto Escape", false, function(v) AutoEscape = v end)
createToggle(tabs.Main, "📦 Auto Barricade", false, function(v) AutoBarricade = v end)
createToggle(tabs.Main, "👁️ Invisible Killer", false, function(v) InvisibilityKiller = v; ApplyInvisibility(v) end)
createToggle(tabs.Main, "💥 Hitbox Expander", false, function(v) HitboxExpender = v end)
createToggle(tabs.Main, "⚡ No Cooldown Prompt", false, function(v) ActiveNoCooldownPrompt = v end)
createToggle(tabs.Main, "🔮 Auto Phase", false, function(v) AutoPhase = v end)
createToggle(tabs.Main, "🛡️ Anti Confusion", false, function(v) AntiConfusion = v end)

createToggle(tabs.Player, "🚫 Noclip", false, function(v) ActiveNoclip = v; Noclip() end)
createToggle(tabs.Player, "✈️ Fly (F)", false, function(v) ActivateFly = v; if v then sFLY() else NOFLY() end end)
createToggle(tabs.Player, "🦘 Infinity Jump", false, function(v) ActivateJumping = v end)
createToggle(tabs.Player, "⚡ Infinite Stamina", false, function(v) ActiveInfiniteStamina = v end)

createToggle(tabs.ESP, "👥 ESP Survivors", false, function(v) ActiveEspSurvivors = v end)
createToggle(tabs.ESP, "🔴 ESP Killers", false, function(v) ActiveEspKillers = v end)
createToggle(tabs.ESP, "⚡ ESP Generators", false, function(v) ActiveEspGen = v end)
createToggle(tabs.ESP, "📦 ESP Fuse Boxes", false, function(v) ActiveEspFuseBoxes = v end)
createToggle(tabs.ESP, "🔋 ESP Battery", false, function(v) ActiveEspBattery = v end)
createToggle(tabs.ESP, "🪤 ESP Traps", false, function(v) ActiveEspTraps = v end)
createToggle(tabs.ESP, "👁️ ESP Wire Eyes", false, function(v) ActiveEspWireEyes = v end)

-- ==================== ИГРОВАЯ ЛОГИКА ====================
player.CharacterAdded:Connect(function() task.wait(0.5); Noclip() end)

Workspace.DescendantAdded:Connect(function(child)
    if FighterAutoParry and child:IsA("Highlight") and child.Name == "Highlight" then
        -- Логика Auto Parry (можно расширить)
    end
    if HitboxExpender and child:IsA("BoxHandleAdornment") then
        child.Size = Vector3.new(ValueHE, ValueHE, ValueHE)
    end
    if ActiveNoCooldownPrompt and child:IsA("ProximityPrompt") then
        child.HoldDuration = 0.1
    end
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end

    if ActiveInfiniteStamina then
        char:SetAttribute("Stamina", char:GetAttribute("MaxStamina") or 100)
    end
    if ActiveSpeedBoost then char:SetAttribute("RunSpeed", ValueRunSpeed) end
    if ActiveSpeedBoost2 then char:SetAttribute("WalkSpeed", ValueWalkSpeed) end
    if ActivateJumping then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = JumpPowerValue end
    end

    if AutoShakeWireEyes and CanShake then
        local wire = player.PlayerGui:FindFirstChild("WireyesUI")
        if wire then doShake(wire) end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F and ActivateFly then
        if FLYING then NOFLY() else sFLY() end
    end
end)

-- Закрытие
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    NOFLY()
end)

print("✅ Тёмный Fantasy GUI успешно загружен и готов к использованию!")

-- Анимация появления
TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
    Position = UDim2.new(0.5, -270, 0.5, -190)
}):Play()
