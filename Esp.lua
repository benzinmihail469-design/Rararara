-- МАКСИМАЛЬНО ЗАЩИЩЕННАЯ ВЕРСИЯ: ИМПУЛЬСНЫЙ ПРЫЖОК С РАНДОМИЗАЦИЕЙ ТАЙМИНГОВ + АНТИ-ОТКАТ СТАМИНЫ
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- Очистка старых версий GUI
if playerGui:FindFirstChild("MyUltimateGui") then
    playerGui["MyUltimateGui"]:Destroy()
end

-- Создаём основной ScreenGui для меню
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyUltimateGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 10

-- Главная панель (500x380)
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

-- Скрипт перетаскивания ГЛАВНОЙ панели
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

-- Заголовок меню
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 250, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 10)
titleLabel.Text = "PRO HUB MOBILE"
titleLabel.TextSize = 22
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = frame

-- Кнопка закрытия (X)
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

-- ============================================================================
-- КНОПКА 1: БЕСКОНЕЧНЫЙ ПРЫЖОК
-- ============================================================================
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

-- ============================================================================
-- КНОПКА 2: БЕСКОНЕЧНАЯ СТАМИНА
-- ============================================================================
local staminaBtn = Instance.new("TextButton")
staminaBtn.Size = UDim2.new(0, 440, 0, 60)
staminaBtn.Position = UDim2.new(0, 30, 0, 180)
staminaBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
staminaBtn.BorderSizePixel = 0
staminaBtn.Text = "Бесконечная стамина: ВЫКЛ"
staminaBtn.TextSize = 20
staminaBtn.TextColor3 = Color3.new(1, 1, 1)
staminaBtn.Font = Enum.Font.SourceSansBold
staminaBtn.Parent = frame

local staminaCorner = Instance.new("UICorner")
staminaCorner.CornerRadius = UDim.new(0, 8)
staminaCorner.Parent = staminaBtn

-- Переменные состояния
local jumpState = false
local staminaState = false
local jumpButtonGui = nil
local mobileJumpButton = nil
local lastJump = 0
local staminaConnection = nil
local oldIndex = nil

-- УМНАЯ ФУНКЦИЯ ПРЫЖКА
local function doSafeBypassJump()
    local randomCooldown = math.random(18, 25) / 100
    if tick() - lastJump < randomCooldown then return end
    
    pcall(function()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if rootPart and humanoid and humanoid.Health > 0 then
            lastJump = tick()
            
            local currentVelocity = rootPart.AssemblyLinearVelocity
            rootPart.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
            
            local jumpPower = humanoid.JumpPower > 0 and humanoid.JumpPower or 52
            rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, jumpPower, rootPart.AssemblyLinearVelocity.Z)
            
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end)
end

-- ЛОГИКА БЕСКОНЕЧНОЙ СТАМИНЫ ДЛЯ FORSAKEN
local function toggleInfiniteStamina(enable)
    staminaState = enable
    
    -- Блок 1: Хукинг метатаблицы (Обход локальных проверок замедления)
    if hookmetamethod and setreadonly then
        if enable and not oldIndex then
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            
            oldIndex = hookmetamethod(game, "__index", function(self, key)
                if staminaState and not checkcaller() then
                    -- Если локальный скрипт пытается снизить скорость из-за "усталости"
                    if key == "WalkSpeed" and self:IsA("Humanoid") then
                        return 16 
                    end
                    -- Подменяем значение для UI игры, чтобы полоса стамины визуально казалась полной
                    if (key == "Value" or key == "value") and (self.Name == "Stamina" or self.Name == "Energy" or self.Name == "StaminaValue") then
                        local maxObj = self.Parent:FindFirstChild("Max" .. self.Name) or self.Parent:FindFirstChild("MaxStamina")
                        return maxObj and maxObj.Value or 100
                    end
                end
                return oldIndex(self, key)
            end)
            setreadonly(mt, true)
        end
    end

    -- Блок 2: Динамический инжект регенерации (Обход серверного отката)
    if enable then
        if staminaConnection then return end
        
        staminaConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local character = player.Character
                if character then
                    -- Проверяем все возможные места хранения стамины в Forsaken
                    local sourceList = {character, player, character:FindFirstChild("Stats"), player:FindFirstChild("leaderstats"), character:FindFirstChild("Attributes")}
                    for _, source in ipairs(sourceList) do
                        if source then
                            local stamObj = source:FindFirstChild("Stamina") or source:FindFirstChild("Energy") or source:FindFirstChild("StaminaValue")
                            if stamObj and (stamObj:IsA("NumberValue") or stamObj:IsA("IntValue")) then
                                local maxStamObj = source:FindFirstChild("MaxStamina") or source:FindFirstChild("MaxEnergy") or source:FindFirstChild("MaxStaminaValue")
                                local maxVal = maxStamObj and maxStamObj.Value or 100
                                
                                -- Вместо мгновенной установки "100" плавно подливаем порциями, обходя триггер античита
                                if stamObj.Value < maxVal then
                                    stamObj.Value = math.min(stamObj.Value + 4, maxVal)
                                end
                            end
                        end
                    end
                    
                    -- Обновление через Атрибуты движка
                    if character:GetAttribute("Stamina") then
                        local max = character:GetAttribute("MaxStamina") or 100
                        if character:GetAttribute("Stamina") < max then
                            character:SetAttribute("Stamina", math.min(character:GetAttribute("Stamina") + 4, max))
                        end
                    end
                end
            end)
        end)
    else
        if staminaConnection then
            staminaConnection:Disconnect()
            staminaConnection = nil
        end
    end
end

-- Функция создания перетаскиваемой кнопки прыжка
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

-- Обновление состояний кнопок в меню
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

local function updateStaminaButton()
    if staminaState then
        staminaBtn.Text = "Бесконечная стамина: ВКЛ"
        staminaBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        toggleInfiniteStamina(true)
    else
        staminaBtn.Text = "Бесконечная стамина: ВЫКЛ"
        staminaBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        toggleInfiniteStamina(false)
    end
end

jumpBtn.MouseButton1Click:Connect(function()
    pcall(function()
        jumpState = not jumpState
        updateJumpButton()
    end)
end)

staminaBtn.MouseButton1Click:Connect(function()
    pcall(function()
        staminaState = not staminaState
        updateStaminaButton()
    end)
end)

-- Управление ПК
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and jumpState then
        doSafeBypassJump()
    end
end)

-- Плавное закрытие
closeBtn.MouseButton1Click:Connect(function()
    toggleMobileJumpButton(false)
    toggleInfiniteStamina(false)
    
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
updateStaminaButton()
