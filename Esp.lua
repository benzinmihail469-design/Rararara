local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старый интерфейс, если он был
if PlayerGui:FindFirstChild("HoshiMM2Gui") then
    PlayerGui.HoshiMM2Gui:Destroy()
end

-- ==========================================
-- ВСЕ ТВОИ НАСТРОЙКИ И ПЕРЕМЕННЫЕ ЛОГИКИ
-- ==========================================
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

-- ==========================================
-- ОСНОВНЫЕ ФУНКЦИИ (ПОЛНАЯ ОРИГИНАЛЬНАЯ ЛОГИКА)
-- ==========================================
local function StopFlying()
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if BVelocity then BVelocity:Destroy() BVelocity = nil end
    if BGyro then BGyro:Destroy() BGyro = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
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
        if not Flying or not root or not LocalPlayer.Character then StopFlying() return end
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

        if moveDir.Magnitude > 0 then BVelocity.Velocity = moveDir.Unit * FlySpeed else BVelocity.Velocity = Vector3.new(0, 0, 0) end
    end)
end

local function GetTargetCoinGlobal()
    if CachedCoin and CachedCoin.Parent and CachedCoin:IsA("BasePart") and CachedCoin.Transparency < 1 then return CachedCoin end
    if tick() < NextScanTime then return nil end
    NextScanTime = tick() + 0.3

    local coinContainer = workspace:FindFirstChild("Normal") or workspace:FindFirstChild("Map") or workspace:FindFirstChild("CoinContainer")
    if coinContainer then
        for _, child in pairs(coinContainer:GetDescendants()) do
            if child:IsA("BasePart") and (string.find(child.Name:lower(), "coin") or child.Name == "Coin_Server") and child.Transparency < 1 then
                CachedCoin = child return child
            end
        end
    end
    for _, child in pairs(workspace:GetDescendants()) do
        if child:IsA("BasePart") and not child:IsDescendantOf(Players) and (string.find(child.Name:lower(), "coin") or child.Name == "Coin_Server" or child:FindFirstChild("CoinVisual")) and child.Transparency < 1 and child.Parent ~= nil then
            CachedCoin = child return child
        end
    end
    return nil
end

local function StopAutoFarm()
    if AutoFarmConnection then AutoFarmConnection:Disconnect() AutoFarmConnection = nil end
    if not Flying then StopFlying() end
end

local function StartAutoFarm()
    StopAutoFarm()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    hum.PlatformStand = true
    if not BVelocity or not BVelocity.Parent then BVelocity = Instance.new("BodyVelocity", root) BVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5) end
    if not BGyro or not BGyro.Parent then BGyro = Instance.new("BodyGyro", root) BGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5) BGyro.CFrame = root.CFrame end

    AutoFarmConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled then StopAutoFarm() return end
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
            if dir.Magnitude > 1.5 then BVelocity.Velocity = dir.Unit * AutoFarmSpeed else root.CFrame = coin.CFrame BVelocity.Velocity = Vector3.new(0, 0, 0) end
        else
            BVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function GetPlayerRoleAndTool(player)
    local isMurderer, isSheriff, specialTool = false, false, nil
    local function check(container)
        if not container then return end
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("Tool") then
                if item:FindFirstChild("KnifeServer") or item:FindFirstChild("KnifeClient") then isMurderer = true specialTool = item
                elseif item:FindFirstChild("GunScript") or item:FindFirstChild("GunClient") then isSheriff = true specialTool = item end
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
    return (root.Position - mapPart.Position).Magnitude <= 600
end

local function ForceMobileShoot(gun, targetPos)
    if not gun or not targetPos then return false end
    for i = 1, 3 do gun:Activate() task.wait(0.02) end
    local cam = workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToScreenPoint(targetPos)
    if onScreen then
        VirtualInput:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0) task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
    else
        local viewportSize = cam.ViewportSize
        VirtualInput:SendMouseButtonEvent(viewportSize.X / 2, viewportSize.Y / 2, 0, true, game, 0) task.wait(0.05)
        VirtualInput:SendMouseButtonEvent(viewportSize.X / 2, viewportSize.Y / 2, 0, false, game, 0)
    end
    return true
end

-- ==========================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (ПРЯМАЯ ОТРИСОВКА)
-- ==========================================
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
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(35, 38, 47)
MainStroke.Transparency = 0.3

-- Верхняя панель (Header)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 9)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoshi Hub — MM2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(120, 125, 140)
CloseBtn.TextSize = 14

-- Боковая Панель Навигации
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)

-- Контейнер для страниц
local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Size = UDim2.new(1, -140, 1, -42)
PagesContainer.Position = UDim2.new(0, 140, 0, 42)
PagesContainer.BackgroundTransparency = 1

-- Специфическая функция создания кнопки переключения дизайна кнопок
local function StyleElement(frame)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", frame)
    s.Thickness = 1
    s.Color = Color3.fromRGB(30, 33, 43)
end

-- ==========================================
-- СОЗДАНИЕ ЯВНЫХ СТРАНИЦ (ФРЭЙМОВ)
-- ==========================================
local function CreatePageFrame(name)
    local pf = Instance.new("ScrollingFrame", PagesContainer)
    pf.Name = name .. "Page"
    pf.Size = UDim2.new(1, 0, 1, 0)
    pf.BackgroundTransparency = 1
    pf.BorderSizePixel = 0
    pf.ScrollBarThickness = 2
    pf.Visible = false
    local l = Instance.new("UIListLayout", pf)
    l.Padding = UDim.new(0, 8)
    local p = Instance.new("UIPadding", pf)
    p.PaddingTop = UDim.new(0, 12) p.PaddingLeft = UDim.new(0, 12) p.PaddingRight = UDim.new(0, 12)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pf.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 20)
    end)
    return pf
end

local MainPage = CreatePageFrame("Main")
local PlayerPage = CreatePageFrame("Player")
local VisualPage = CreatePageFrame("Visual")
local KillerPage = CreatePageFrame("Killer")
local SheriffPage = CreatePageFrame("Sheriff")

-- ==========================================
-- ЯВНЫЕ КНОПКИ НАВИГАЦИИ (ВКЛАДКИ)
-- ==========================================
local function CreateTabButton(text, order)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundTransparency = 1
    b.Font = Enum.Font.GothamMedium
    b.Text = "  " .. text
    b.TextColor3 = Color3.fromRGB(140, 145, 160)
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.LayoutOrder = order
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local MainBtn = CreateTabButton("Главная", 1)
local PlayerBtn = CreateTabButton("Игрок", 2)
local VisualBtn = CreateTabButton("Визуал", 3)
local KillerBtn = CreateTabButton("Киллер", 4)
local SheriffBtn = CreateTabButton("Шериф", 5)

-- Переключение страниц (ПРЯМАЯ КЛИК-ЛОГИКА)
local function SwitchToPage(targetPage, targetBtn)
    MainPage.Visible = (MainPage == targetPage)
    PlayerPage.Visible = (PlayerPage == targetPage)
    VisualPage.Visible = (VisualPage == targetPage)
    KillerPage.Visible = (KillerPage == targetPage)
    SheriffPage.Visible = (SheriffPage == targetPage)

    MainBtn.TextColor3 = Color3.fromRGB(140, 145, 160) MainBtn.BackgroundTransparency = 1
    PlayerBtn.TextColor3 = Color3.fromRGB(140, 145, 160) PlayerBtn.BackgroundTransparency = 1
    VisualBtn.TextColor3 = Color3.fromRGB(140, 145, 160) VisualBtn.BackgroundTransparency = 1
    KillerBtn.TextColor3 = Color3.fromRGB(140, 145, 160) KillerBtn.BackgroundTransparency = 1
    SheriffBtn.TextColor3 = Color3.fromRGB(140, 145, 160) SheriffBtn.BackgroundTransparency = 1

    targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    targetBtn.BackgroundTransparency = 0
end

MainBtn.MouseButton1Click:Connect(function() SwitchToPage(MainPage, MainBtn) end)
PlayerBtn.MouseButton1Click:Connect(function() SwitchToPage(PlayerPage, PlayerBtn) end)
VisualBtn.MouseButton1Click:Connect(function() SwitchToPage(VisualPage, VisualBtn) end)
KillerBtn.MouseButton1Click:Connect(function() SwitchToPage(KillerPage, KillerBtn) end)
SheriffBtn.MouseButton1Click:Connect(function() SwitchToPage(SheriffPage, SheriffBtn) end)

-- Открываем первую вкладку по дефолту
SwitchToPage(MainPage, MainBtn)

-- ==========================================
-- ПРЯМОЕ НАПОЛНЕНИЕ КНОПКАМИ И ФУНКЦИЯМИ
-- ==========================================

local function AddToggle(parent, text, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    StyleElement(f)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 215, 225)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 38, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(32, 35, 45)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local sw = Instance.new("Frame", btn)
    sw.Size = UDim2.new(0, 14, 0, 14)
    sw.Position = UDim2.new(0, 3, 0.5, -7)
    sw.BackgroundColor3 = Color3.fromRGB(150, 155, 165)
    Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 7)

    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        local bg = toggled and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(32, 35, 45)
        local ball = toggled and Color3.fromRGB(20, 22, 28) or Color3.fromRGB(150, 155, 165)
        local pos = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = bg}):Play()
        TweenService:Create(sw, TweenInfo.new(0.15), {Position = pos, BackgroundColor3 = ball}):Play()
        callback(toggled)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 46)
    f.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    StyleElement(f)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.6, 0, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 215, 225)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.3, 0, 0, 22)
    val.Position = UDim2.new(1, -48, 0, 4)
    val.BackgroundTransparency = 1
    val.Font = Enum.Font.GothamBold
    val.Text = tostring(default)
    val.TextColor3 = Color3.fromRGB(240, 240, 245)
    val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, -24, 0, 4)
    bar.Position = UDim2.new(0, 12, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    bar.Text = ""
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    local function update(input)
        local scale = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(scale, 0, 1, 0)
        local value = math.floor(min + (max - min) * scale)
        val.Text = tostring(value)
        callback(value)
    end

    local sliding = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
end

-- --- ВКЛАДКА: ГЛАВНАЯ ---
AddToggle(MainPage, "Универсальный Авто-Фарм Монет", function(state)
    AutoFarmEnabled = state
    if state then StartAutoFarm() else StopAutoFarm() end
end)
AddSlider(MainPage, "Скорость авто-фарма", 10, 25, 16, function(value)
    AutoFarmSpeed = value
end)

-- --- ВКЛАДКА: ИГРОК ---
AddToggle(PlayerPage, "Bypass Fly (Полет)", function(state)
    Flying = state
    if state then StartFlying() else StopFlying() end
end)
AddSlider(PlayerPage, "Скорость полета", 15, 90, 35, function(value)
    FlySpeed = value
end)
AddToggle(PlayerPage, "Toggle WalkSpeed", function(state)
    WalkSpeedEnabled = state
end)
AddSlider(PlayerPage, "WalkSpeed (Бег)", 16, 120, 16, function(value)
    NormalWalkSpeed = value
end)
AddToggle(PlayerPage, "Noclip (Сквозь стены)", function(state)
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)
AddToggle(PlayerPage, "Inf Jump (Беск. Прыжки)", function(state)
    _G.InfJump = state
    if state then
        UserInputService.JumpRequest:Connect(function()
            if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- --- ВКЛАДКА: ВИЗУАЛ ---
AddToggle(VisualPage, "MM2 ESP (Подсветка Ролей)", function(state)
    ESPEnabled = state
end)

-- --- ВКЛАДКА: КИЛЛЕР ---
AddToggle(KillerPage, "Auto Kill (Убивать всех)", function(state)
    AutoKillEnabled = state
end)

-- --- ВКЛАДКА: ШЕРИФ ---
AddToggle(SheriffPage, "Авто-Убийство маньяка", function(state)
    AutoShootMurdererEnabled = state
end)
AddToggle(SheriffPage, "Авто-подбор пистолета", function(state)
    AutoGetGunEnabled = state
end)

-- ==========================================
-- ПОТОКИ ПРОВЕРОК И ЦИКЛЫ ХЕНДЛЕРОВ
-- ==========================================

-- Поток для ESP
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
                            hl = Instance.new("Highlight", char)
                            hl.Name = "MM2_RoleESP"
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0.2
                        end
                        hl.FillColor = color hl.OutlineColor = color
                    else
                        local hl = char:FindFirstChild("MM2_RoleESP") if hl then hl:Destroy() end
                    end
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then local hl = player.Character:FindFirstChild("MM2_RoleESP") if hl then hl:Destroy() end end
            end
        end
    end
end)

-- Поток для Auto Kill (Маньяк)
task.spawn(function()
    while task.wait(0.25) do
        if AutoKillEnabled then
            local isMurderer, _, knife = GetPlayerRoleAndTool(LocalPlayer)
            if isMurderer and knife and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHum and knife.Parent ~= LocalPlayer.Character then myHum:EquipTool(knife) task.wait(0.1) end

                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and IsPlayerInGame(target) then
                        local targetIsMurderer = GetPlayerRoleAndTool(target)
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

-- Поток для Auto Shoot Murderer (Шериф)
task.spawn(function()
    while task.wait(0.2) do
        if AutoShootMurdererEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHum and myHum.Health > 0 then
                    local _, isSheriff, gun = GetPlayerRoleAndTool(LocalPlayer)
                    if isSheriff and gun then
                        if gun.Parent ~= LocalPlayer.Character then myHum:EquipTool(gun) task.wait(0.2) end
                        local murdererRoot = nil
                        for _, target in pairs(Players:GetPlayers()) do
                            if target ~= LocalPlayer and IsPlayerInGame(target) then
                                local targetIsMurderer = GetPlayerRoleAndTool(target)
                                if targetIsMurderer and target.Character then
                                    local targetHum = target.Character:FindFirstChild("Humanoid")
                                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                                    if targetHum and targetHum.Health > 0 and targetRoot then murdererRoot = targetRoot break end
                                end
                            end
                        end
                        if murdererRoot then
                            local cam = workspace.CurrentCamera
                            cam.CameraType = Enum.CameraType.Scriptable
                            myRoot.Velocity = Vector3.new(0,0,0)
                            myRoot.CFrame = murdererRoot.CFrame * CFrame.new(0, 0, 5)
                            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, murdererRoot.Position)
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

-- Поток для автоматического сбора выпавшего пистолета
task.spawn(function()
    while task.wait(0.3) do
        if AutoGetGunEnabled then
            local _, isSheriff = GetPlayerRoleAndTool(LocalPlayer)
            if not isSheriff and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
                if myHum and myHum.Health > 0 then
                    local gunDrop = nil
                    local dropContainers = {workspace:FindFirstChild("Normal"), workspace:FindFirstChild("Map"), workspace:FindFirstChild("Drops"), workspace:FindFirstChild("Items")}
                    for _, container in pairs(dropContainers) do
                        if container then
                            for _, obj in pairs(container:GetDescendants()) do
                                if obj:IsA("BasePart") and obj.Parent and not obj:IsDescendantOf(Players) then
                                    local n = obj.Name:lower()
                                    if n == "gundrop" or n == "gun_drop" or n == "gun" or obj:FindFirstChild("GunScript") then gunDrop = obj break end
                                end
                            end
                        end
                        if gunDrop then break end
                    end
                    if gunDrop and gunDrop:IsA("BasePart") and gunDrop.Parent and not gunDrop:IsDescendantOf(Players) then
                        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then myRoot.CFrame = gunDrop.CFrame * CFrame.new(0, 0, 1) task.wait(0.2) end
                    end
                end
            end
        end
    end
end)

-- Респавн хендлер
LocalPlayer.CharacterAdded:Connect(function(newChar)
    local root = newChar:WaitForChild("HumanoidRootPart", 5)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if root and hum then
        task.wait(0.5)
        if AutoFarmEnabled then StartAutoFarm() elseif Flying then StartFlying() end
    end
end)

-- Хендлер бега
WalkSpeedConnection = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not Flying and not AutoFarmEnabled then
        hum.WalkSpeed = WalkSpeedEnabled and NormalWalkSpeed or 16
    end
end)

-- Система Драга GUI (ПК + Мобилки)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

-- Закрытие GUI
CloseBtn.MouseButton1Click:Connect(function()
    Flying = false AutoFarmEnabled = false WalkSpeedEnabled = false ESPEnabled = false AutoKillEnabled = false AutoShootMurdererEnabled = false AutoGetGunEnabled = false
    StopFlying() StopAutoFarm()
    if NoclipConnection then NoclipConnection:Disconnect() end
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
    ScreenGui:Destroy()
end)
