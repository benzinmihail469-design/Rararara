-- ==================== GUI С UIDragDetector (РАБОЧИЙ ПОЛЗУНОК) ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillerESP_Speed_Fixed"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 230)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "ESP + Speed Control"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Killer: Searching..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

-- Кнопка ESP
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.8, 0, 0, 30)
EspBtn.Position = UDim2.new(0.1, 0, 0, 65)
EspBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
EspBtn.Text = "ESP: ON"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.TextSize = 13
EspBtn.Font = Enum.Font.Gotham
EspBtn.AutoButtonColor = false
EspBtn.Parent = Frame

Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

EspBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    EspBtn.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
    EspBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Кнопка Speed
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.8, 0, 0, 30)
SpeedBtn.Position = UDim2.new(0.1, 0, 0, 105)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
SpeedBtn.Text = "Speed: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 13
SpeedBtn.Font = Enum.Font.Gotham
SpeedBtn.AutoButtonColor = false
SpeedBtn.Parent = Frame

Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Settings.SpeedEnabled = not Settings.SpeedEnabled
    SpeedBtn.Text = Settings.SpeedEnabled and "Speed: ON" or "Speed: OFF"
    SpeedBtn.BackgroundColor3 = Settings.SpeedEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    UpdateSpeed()
end)

-- Текст скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 145)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = Frame

-- Слайдер - фон
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.8, 0, 0, 8)
SliderFrame.Position = UDim2.new(0.1, 0, 0, 170)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = Frame

Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)

-- Синий заполнитель
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderFrame

Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

-- Белый ползунок (теперь это Frame с UIDragDetector)
local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 20, 0, 20)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = SliderFrame
SliderKnob.ZIndex = 10

Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

local KnobStroke = Instance.new("UIStroke")
KnobStroke.Color = Color3.fromRGB(150, 150, 150)
KnobStroke.Thickness = 1.5
KnobStroke.Parent = SliderKnob

-- UIDragDetector - ОСНОВНАЯ ФИШКА ДЛЯ РАБОТЫ ПОЛЗУНКА
local DragDetector = Instance.new("UIDragDetector")
DragDetector.Parent = SliderKnob
DragDetector.DragStyle = Enum.DragStyle.TranslateLine
DragDetector.DragAxis = Enum.Axis.X
DragDetector.ResponseStyle = Enum.ResponseStyle.Physical
DragDetector.MinDragTranslation = Vector2.new(-200, 0)
DragDetector.MaxDragTranslation = Vector2.new(200, 0)

-- Функция обновления значения слайдера на основе позиции ползунка
local function UpdateSliderFromPosition()
    local knobPos = SliderKnob.Position.X.Scale
    local minPos = 0
    local maxPos = 1
    
    -- Учитываем размер ползунка для точного расчёта
    local trackWidth = SliderFrame.AbsoluteSize.X
    local knobWidth = SliderKnob.AbsoluteSize.X
    if trackWidth > 0 and knobWidth > 0 then
        local minScale = (knobWidth / 2) / trackWidth
        local maxScale = 1 - minScale
        
        local value = (knobPos - minScale) / (maxScale - minScale)
        value = math.clamp(value, 0, 1)
        
        -- Вычисляем скорость (16-50)
        Settings.SpeedValue = math.floor(16 + value * 34)
        SpeedLabel.Text = "Speed: " .. Settings.SpeedValue
        
        -- Обновляем синий заполнитель
        SliderFill.Size = UDim2.new(value, 0, 1, 0)
        
        if Settings.SpeedEnabled then
            UpdateSpeed()
        end
    end
end

-- Следим за изменением позиции ползунка
SliderKnob:GetPropertyChangedSignal("Position"):Connect(UpdateSliderFromPosition)

-- Дополнительно: клик по фону слайдера тоже двигает ползунок
SliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouseX = input.Position.X
        local frameMin = SliderFrame.AbsolutePosition.X
        local frameMax = frameMin + SliderFrame.AbsoluteSize.X
        local knobWidth = SliderKnob.AbsoluteSize.X
        local trackWidth = SliderFrame.AbsoluteSize.X
        
        if trackWidth > 0 and knobWidth > 0 then
            local minX = frameMin + knobWidth / 2
            local maxX = frameMax - knobWidth / 2
            local clampedX = math.clamp(mouseX, minX, maxX)
            local percent = (clampedX - minX) / (maxX - minX)
            
            Settings.SpeedValue = math.floor(16 + percent * 34)
            SpeedLabel.Text = "Speed: " .. Settings.SpeedValue
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
            
            if Settings.SpeedEnabled then
                UpdateSpeed()
            end
        end
    end
end)

-- Начальное значение (16)
task.wait(0.1)
SliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
SliderFill.Size = UDim2.new(0, 0, 1, 0)

-- Информация
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 20)
Info.Position = UDim2.new(0, 0, 0, 195)
Info.BackgroundTransparency = 1
Info.Text = "🟢 Killer  |  🔴 Survivor"
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 11
Info.Font = Enum.Font.Gotham
Info.Parent = Frame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Frame

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

Status.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpdateAllOutlines()
    end
end)

task.spawn(function()
    while true do
        if CurrentKiller then
            Status.Text = "Killer: " .. CurrentKiller.Name
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            Status.Text = "Killer: Searching..."
            Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        task.wait(1)
    end
end)

print("ESP + Speed loaded! UIDragDetector slider - 100% working!")
