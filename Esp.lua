-- ПОЛНОСТЬЮ ПЕРЕРАБОТАННАЯ ВЕРСИЯ: ИМПУЛЬСНЫЙ ПРЫЖОК + ИНЕРЦИОННЫЙ НАКАТ (ОБХОД СЕРВЕРНОЙ СТАТИСТИКИ)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("MyUltimateGui") then
    playerGui["MyUltimateGui"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyUltimateGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 10

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 500, 0, 380)
frame.Position = UDim2.new(0.5, -250, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Скрипт перетаскивания меню
local dragToggle = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
        
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
                conn:Disconnect()
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle and dragStart and startPos then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 250, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 10)
titleLabel.Text = "PRO HUB MOBILE v2"
titleLabel.TextSize = 22
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -55, 0, 10)
closeBtn.Text = "✕"
closeBtn.TextSize = 24
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- КНОПКА 1: БЕСКОНЕЧНЫЙ ПРЫЖОК
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, 440, 0, 60)
jumpBtn.Position = UDim2.new(0, 30, 0, 100)
jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "Бесконечный прыжок: ВЫКЛ"
jumpBtn.TextSize = 20
jumpBtn.TextColor3 = Color3.new(1, 1, 1)
jumpBtn.Font = Enum.Font.SourceSansBold
jumpBtn.Parent = frame

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 8)
jumpCorner.Parent = jumpBtn

-- КНОПКА 2: ИНЕРЦИОННЫЙ НАКАТ (ВМЕСТО СТАМИНЫ)
local glideBtn = Instance.new("TextButton")
glideBtn.Size = UDim2.new(0, 440, 0, 60)
glideBtn.Position = UDim2.new(0, 30, 0, 180)
glideBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
glideBtn.BorderSizePixel = 0
glideBtn.Text = "Инерционный накат: ВЫКЛ"
glideBtn.TextSize = 20
glideBtn.TextColor3 = Color3.new(1, 1, 1)
glideBtn.Font = Enum.Font.SourceSansBold
glideBtn.Parent = frame

local glideCorner = Instance.new("UICorner")
glideCorner.CornerRadius = UDim.new(0, 8)
glideCorner.Parent = glideBtn

local jumpState = false
local glideState = false
local jumpButtonGui = nil
local mobileJumpButton = nil
local lastJump = 0
local glideConnection = nil

-- Функция безопасного прыжка
local function doSafeBypassJump()
    local randomCooldown = math.random(22, 28) / 100
    if tick() - lastJump < randomCooldown then return end
    
    pcall(function()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if rootPart and humanoid and humanoid.Health > 0 then
            lastJump = tick()
            local currentVelocity = rootPart.AssemblyLinearVelocity
            rootPart.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
            
            local jumpPower = humanoid.JumpPower > 0 and humanoid.JumpPower or 50
            rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, jumpPower, rootPart.AssemblyLinearVelocity.Z)
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end)
end

-- АЛЬТЕРНАТИВНАЯ МЕХАНИКА: Физический накат во избежание дебаффа стамины
local function toggleGlideBypass(enable)
    glideState = enable
    
    if enable then
        if glideConnection then return end
        
        glideConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                
                if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    -- Если персонаж идет, но сервер занижает скорость (из-за 0 стамины)
                    -- Мы не меняем WalkSpeed, мы добавляем микро-импульс к вектору движения
                    local direction = humanoid.MoveDirection
                    local currentVelocity = rootPart.AssemblyLinearVelocity
                    
                    -- Проверяем текущую горизонтальную скорость
                    local horizontalVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
                    
                    -- Если скорость ниже нормального бега (меньше 14)
                    if horizontalVelocity.Magnitude < 15 then
                        -- Добавляем легитимное ускорение по вектору направления движения
                        local pushForce = direction * 2.5
                        rootPart.AssemblyLinearVelocity = Vector3.new(
                            currentVelocity.X + pushForce.X,
                            currentVelocity.Y,
                            currentVelocity.Z + pushForce.Z
                        )
                    end
                end
            end)
        end)
    else
        if glideConnection then
            glideConnection:Disconnect()
            glideConnection = nil
        end
    end
end

-- Кнопка прыжка для мобильных устройств
local function toggleMobileJumpButton(enable)
    if enable then
        if jumpButtonGui then return end
        
        jumpButtonGui = Instance.new("ScreenGui")
        jumpButtonGui.Name = "InfJumpButtonGui"
        jumpButtonGui.Parent = playerGui
        jumpButtonGui.ResetOnSpawn = false
        jumpButtonGui.DisplayOrder = 999999
        
        mobileJumpButton = Instance.new("TextButton")
        mobileJumpButton.Name = "MobileInfJumpButton"
        mobileJumpButton.Parent = jumpButtonGui
        mobileJumpButton.Size = UDim2.new(0, 70, 0, 70)
        mobileJumpButton.Position = UDim2.new(0.85, -35, 0.7, -35)
        mobileJumpButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        mobileJumpButton.Text = "JUMP"
        mobileJumpButton.TextSize = 18
        mobileJumpButton.TextColor3 = Color3.new(1, 1, 1)
        mobileJumpButton.Font = Enum.Font.SourceSansBold
        mobileJumpButton.ZIndex = 10
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = mobileJumpButton
        
        local bDragToggle = false
        local bDragStart = nil
        local bStartPos = nil
        
        mobileJumpButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                bDragToggle = true
                bDragStart = input.Position
                bStartPos = mobileJumpButton.Position
                
                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        bDragToggle = false
                        conn:Disconnect()
                    end
                end)
            end
        end)
        
        mobileJumpButton.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and bDragToggle and bDragStart and bStartPos then
                local delta = input.Position - bDragStart
                mobileJumpButton.Position = UDim2.new(bStartPos.X.Scale, bStartPos.X.Offset + delta.X, bStartPos.Y.Scale, bStartPos.Y.Offset + delta.Y)
            end
        end)
        
        mobileJumpButton.MouseButton1Click:Connect(function()
            if jumpState then
                doSafeBypassJump()
            end
        end)
    else
        if jumpButtonGui then
            jumpButtonGui:Destroy()
            jumpButtonGui = nil
            mobileJumpButton = nil
        end
    end
end

local function updateJumpButton()
    if jumpState then
        jumpBtn.Text = "Бесконечный прыжок: ВКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        if UIS.TouchEnabled then
            toggleMobileJumpButton(true)
        end
    else
        jumpBtn.Text = "Бесконечный прыжок: ВЫКЛ"
        jumpBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        toggleMobileJumpButton(false)
    end
end

local function updateGlideButton()
    if glideState then
        glideBtn.Text = "Инерционный накат: ВКЛ"
        glideBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        toggleGlideBypass(true)
    else
        glideBtn.Text = "Инерционный накат: ВЫКЛ"
        glideBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        toggleGlideBypass(false)
    end
end

jumpBtn.MouseButton1Click:Connect(function()
    pcall(function()
        jumpState = not jumpState
        updateJumpButton()
    end)
end)

glideBtn.MouseButton1Click:Connect(function()
    pcall(function()
        glideState = not glideState
        updateGlideButton()
    end)
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and jumpState then
        doSafeBypassJump()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    toggleMobileJumpButton(false)
    toggleGlideBypass(false)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {BackgroundTransparency = 1, TextTransparency = 1}
    
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            TweenService:Create(child, tweenInfo, goal):Play()
        end
    end
    
    TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.35)
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end)

updateJumpButton()
updateGlideButton()
