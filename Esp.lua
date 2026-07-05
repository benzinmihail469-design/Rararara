-- Pulse Hub Style GUI (Mobile/PC Adaptive)
-- БЕЗ БИБЛИОТЕК

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PulseHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

-- Background Blur
local Blur = Instance.new("BlurEffect")
Blur.Size = 8
Blur.Parent = game:GetService("Lighting")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 650)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Glass effect (rounded corners)
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local GlassBorder = Instance.new("Frame")
GlassBorder.Size = UDim2.new(1, 0, 1, 0)
GlassBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassBorder.BackgroundTransparency = 0.97
GlassBorder.BorderSizePixel = 0
GlassBorder.Parent = MainFrame
local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 12)
BorderCorner.Parent = GlassBorder

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BackgroundTransparency = 0.5
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Title Text
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Pulse Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- Subtitle (Murder Mystery 2)
local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0.5, 0, 1, 0)
SubTitle.Position = UDim2.new(0.3, 0, 0, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Murder Mystery 2"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
SubTitle.TextSize = 14
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Font = Enum.Font.Gotham
SubTitle.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BackgroundTransparency = 0.8
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.3)
    MainFrame.Visible = false
end)

-- Make draggable
MakeDraggable(TitleBar)

-- Content Container (scrollable)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -70)
Container.Position = UDim2.new(0, 10, 0, 60)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
Container.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.FillDirection = Enum.FillDirection.Vertical
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Container

-- Category function
local function CreateCategory(title)
    local CatFrame = Instance.new("Frame")
    CatFrame.Size = UDim2.new(1, 0, 0, 35)
    CatFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    CatFrame.BackgroundTransparency = 0.3
    CatFrame.BorderSizePixel = 0
    CatFrame.Parent = Container
    
    local CatCorner = Instance.new("UICorner")
    CatCorner.CornerRadius = UDim.new(0, 6)
    CatCorner.Parent = CatFrame
    
    local CatLabel = Instance.new("TextLabel")
    CatLabel.Size = UDim2.new(1, -20, 1, 0)
    CatLabel.Position = UDim2.new(0, 10, 0, 0)
    CatLabel.BackgroundTransparency = 1
    CatLabel.Text = title
    CatLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    CatLabel.TextSize = 16
    CatLabel.TextXAlignment = Enum.TextXAlignment.Left
    CatLabel.Font = Enum.Font.GothamBold
    CatLabel.Parent = CatFrame
    
    return CatFrame
end

-- Button function (toggle style)
local function CreateToggle(text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    Frame.BackgroundTransparency = 0.5
    Frame.BorderSizePixel = 0
    Frame.Parent = Container
    
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 28)
    ToggleBtn.Position = UDim2.new(1, -70, 0, 6)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 60, 70)
    ToggleBtn.BackgroundTransparency = 0.3
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame
    
    local TBtnCorner = Instance.new("UICorner")
    TBtnCorner.CornerRadius = UDim.new(0, 4)
    TBtnCorner.Parent = ToggleBtn
    
    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 60, 70)
        ToggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return ToggleBtn
end

-- Button function (action)
local function CreateActionButton(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel = 0
    Frame.Parent = Container
    
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 1, -6)
    Btn.Position = UDim2.new(0, 10, 0, 3)
    Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    Btn.BackgroundTransparency = 0.5
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 15
    Btn.Font = Enum.Font.Gotham
    Btn.BorderSizePixel = 0
    Btn.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(75, 75, 85)
    end)
    Btn.MouseLeave:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    end)
    
    return Btn
end

-- === BUILD UI ===

-- MAIN Section
CreateCategory("⚡ Main")

CreateActionButton("👮 Sheriff", function()
    print("Sheriff mode activated")
    -- Твой код для шерифа
end)

CreateActionButton("🔪 Murder", function()
    print("Murder mode activated")
    -- Твой код для убийцы
end)

CreateToggle("🔄 Auto Farm", false, function(state)
    print("Auto Farm:", state)
    -- Твой код автофарма
end)

CreateToggle("📦 Auto-Respawning", true, function(state)
    print("Auto-Respawning:", state)
end)

CreateToggle("🛡️ Anti-Fling", true, function(state)
    print("Anti-Fling:", state)
end)

CreateToggle("👤 Avoid Murderer", false, function(state)
    print("Avoid Murderer:", state)
end)

-- TELEPORT Section
CreateCategory("🌀 Teleport")

CreateActionButton("📍 Teleport to Murderer", function()
    print("Teleporting to Murderer...")
    -- Код телепорта к убийце
end)

CreateActionButton("📍 Teleport to Sheriff", function()
    print("Teleporting to Sheriff...")
    -- Код телепорта к шерифу
end)

-- FUN/TROLL Section
CreateCategory("🎭 Fun / Troll")

CreateActionButton("💨 Fling Players", function()
    print("Flinging players...")
    -- Код флинга
end)

CreateActionButton("👻 Invisible", function()
    print("Toggling invisibility...")
end)

-- VISUALS Section
CreateCategory("👁️ Visuals")

CreateToggle("🌈 ESP Boxes", false, function(state)
    print("ESP:", state)
end)

CreateToggle("📏 Name Tags", true, function(state)
    print("Name Tags:", state)
end)

CreateToggle("🎯 Aimbot", false, function(state)
    print("Aimbot:", state)
end)

-- KILL AURA Section
CreateCategory("⚔️ Kill Aura")

CreateToggle("💀 Kill Aura", false, function(state)
    print("Kill Aura:", state)
end)

CreateToggle("🎯 Auto Aim", true, function(state)
    print("Auto Aim:", state)
end)

-- Settings Section
CreateCategory("⚙️ Settings")

CreateActionButton("🔄 Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

CreateActionButton("🚪 Leave Game", function()
    game:Shutdown()
end)

-- Footer (as in screenshot)
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 30)
Footer.Position = UDim2.new(0, 0, 1, -30)
Footer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Footer.BackgroundTransparency = 0.5
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 12)
FooterCorner.Parent = Footer

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(0.7, 0, 1, 0)
FooterText.Position = UDim2.new(0.02, 0, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "discord.gg/pulsezone  •  Session 02:39"
FooterText.TextColor3 = Color3.fromRGB(130, 130, 140)
FooterText.TextSize = 13
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.Font = Enum.Font.Gotham
FooterText.Parent = Footer

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0.3, 0, 1, 0)
FPSLabel.Position = UDim2.new(0.7, 0, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "⚡ 163 FPS"
FPSLabel.TextColor3 = Color3.fromRGB(0, 200, 80)
FPSLabel.TextSize = 13
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Parent = Footer

-- Show/Hide GUI with keybind (P)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        if MainFrame.Visible then
            MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            task.wait(0.3)
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
            MainFrame:TweenSize(UDim2.new(0, 420, 0, 650), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        end
    end
end)
