local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Очистка старого GUI
pcall(function() if CoreGui:FindFirstChild("HoshiAnimalHospital") then CoreGui.HoshiAnimalHospital:Destroy() end end)

-- Создание основы Hoshi Style
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "HoshiAnimalHospital"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 18)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Header Hoshi
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(19, 21, 27)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Hoshi Hub | Animal Hospital"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Функция создания переключателей (Hoshi style)
local function AddToggle(name, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    btn.Text = "  " .. name
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        btn.BackgroundColor3 = toggled and Color3.fromRGB(95, 110, 255) or Color3.fromRGB(24, 26, 34)
        callback(toggled)
    end)
    return btn
end

-- Сетка элементов
local List = Instance.new("UIListLayout", MainFrame)
List.Padding = UDim.new(0, 10)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.Padding = UDim.new(0, 10)
Instance.new("UIPadding", MainFrame).PaddingTop = UDim.new(0, 50)

-- Функционал Animal Hospital (заглушки для логики)
AddToggle("Auto Treat Pets", function(state)
    print("Auto Treat: " .. tostring(state))
    -- Здесь будет логика поиска питомцев и применения лечения
end)

AddToggle("Auto Collect Money", function(state)
    print("Auto Collect: " .. tostring(state))
    -- Здесь будет логика сбора внутриигровой валюты
end)

-- Драг для Hoshi GUI
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
