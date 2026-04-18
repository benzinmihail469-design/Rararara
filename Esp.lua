--[[
    Альтернативный GUI-скрипт для Roblox Studio
    Аналогичен визуальной части исходного скрипта, но без системы ключей и внешних вызовов.
]]

-- Сервисы Roblox
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Вспомогательные функции
local function CloneTable(t)
    local clone = {}
    for k, v in pairs(t) do
        clone[k] = v
    end
    return clone
end

-- Модуль GUI
local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(15, 12, 16),
    Inline = Color3.fromRGB(22, 20, 24),
    Border = Color3.fromRGB(41, 37, 45),
    Text = Color3.fromRGB(255, 255, 255),
    InactiveText = Color3.fromRGB(185, 185, 185),
    Accent = Color3.fromRGB(232, 186, 248),
    Element = Color3.fromRGB(36, 32, 39)
}
Library.Tween = {
    Time = 0.3,
    Style = Enum.EasingStyle.Quad,
    Direction = Enum.EasingDirection.Out
}
Library.Connections = {}
Library.Threads = {}
Library.NotifHolder = nil
Library.NotifLayoutOrder = 0

-- Безопасное получение родительского контейнера
local function SafeGetUI()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    if success and result then
        return result
    end
    return game:GetService("CoreGui")
end

-- Создание экземпляра
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        pcall(function()
            instance[prop] = value
        end)
    end
    return instance
end

-- Tween-обёртка
local function CreateTween(item, info, goal)
    info = info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
    local tween = TweenService:Create(item, info, goal)
    tween:Play()
    return tween
end

-- Уведомление
function Library:Notification(data)
    Library.NotifLayoutOrder = (Library.NotifLayoutOrder or 0) + 1
    
    local title = data.Title or "Notification"
    local description = data.Description or ""
    local duration = data.Duration or 5
    local color = data.Color or Library.Theme.Accent
    
    -- Создаём холдер уведомлений, если его нет
    if not Library.NotifHolder then
        Library.NotifHolder = CreateInstance("Frame", {
            Parent = SafeGetUI(),
            Name = "NotifHolder",
            Size = UDim2.new(0, 0, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X
        })
        
        local layout = CreateInstance("UIListLayout", {
            Parent = Library.NotifHolder,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 20)
        })
        
        local padding = CreateInstance("UIPadding", {
            Parent = Library.NotifHolder,
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        })
    end
    
    local paddingH = 6
    local paddingV = 5
    local gap = 5
    local barGap = 4
    local barH = 3
    local maxWidth = 330
    
    -- Простой расчёт размеров (можно доработать под TextService)
    local contentWidth = math.min(300, maxWidth)
    local titleH = 15
    local descH = 28
    local sizeY = paddingV + titleH + gap + descH + barGap + barH + paddingV
    
    local notifFrame = CreateInstance("Frame", {
        Parent = Library.NotifHolder,
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = Library.NotifLayoutOrder,
        Size = UDim2.new(0, contentWidth, 0, sizeY)
    })
    
    CreateInstance("UICorner", {
        Parent = notifFrame,
        CornerRadius = UDim.new(0, 5)
    })
    
    CreateInstance("UIPadding", {
        Parent = notifFrame,
        PaddingLeft = UDim.new(0, paddingH),
        PaddingRight = UDim.new(0, paddingH),
        PaddingTop = UDim.new(0, paddingV),
        PaddingBottom = UDim.new(0, paddingV)
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Parent = notifFrame,
        Size = UDim2.new(1, 0, 0, titleH),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = title,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextTransparency = 1
    })
    
    local descLabel = CreateInstance("TextLabel", {
        Parent = notifFrame,
        Size = UDim2.new(1, -paddingH*2, 0, descH),
        Position = UDim2.new(0, paddingH, 0, titleH + gap),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = description,
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        RichText = false,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    CreateInstance("UITextSizeConstraint", {
        Parent = descLabel,
        MinTextSize = 12,
        MaxTextSize = 12
    })
    
    local durationFrame = CreateInstance("Frame", {
        Parent = notifFrame,
        Size = UDim2.new(1, 0, 0, barH),
        Position = UDim2.new(0, 0, 0, titleH + gap + descH + barGap),
        BackgroundColor3 = Library.Theme.Inline,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    CreateInstance("UICorner", {
        Parent = durationFrame,
        CornerRadius = UDim.new(0, 5)
    })
    
    local accentBar = CreateInstance("Frame", {
        Parent = durationFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0
    })
    
    CreateInstance("UICorner", {
        Parent = accentBar,
        CornerRadius = UDim.new(0, 5)
    })
    
    -- Анимации
    local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local barInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    
    CreateTween(notifFrame, fadeInfo, {BackgroundTransparency = 0})
    CreateTween(titleLabel, fadeInfo, {TextTransparency = 0})
    CreateTween(descLabel, fadeInfo, {TextTransparency = 0.4})
    CreateTween(durationFrame, fadeInfo, {BackgroundTransparency = 0})
    
    CreateTween(accentBar, barInfo, {Size = UDim2.new(0, 0, 1, 0)})
    
    delay(duration + 0.1, function()
        CreateTween(notifFrame, fadeInfo, {BackgroundTransparency = 1})
        CreateTween(titleLabel, fadeInfo, {TextTransparency = 1})
        CreateTween(descLabel, fadeInfo, {TextTransparency = 1})
        CreateTween(durationFrame, fadeInfo, {BackgroundTransparency = 1})
        
        wait(0.5)
        notifFrame:Destroy()
    end)
end

-- Создание основного окна
function Library:CreateWindow(title, description)
    local screenGui = CreateInstance("ScreenGui", {
        Parent = SafeGetUI(),
        Name = "SolixLikeGUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 999,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    local overlay = CreateInstance("Frame", {
        Parent = screenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1
    })
    
    local mainFrame = CreateInstance("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    CreateInstance("UICorner", {
        Parent = mainFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    local mainStroke = CreateInstance("UIStroke", {
        Parent = mainFrame,
        Color = Library.Theme.Border,
        Thickness = 1,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = title or "Solix Hub Free 15+ Games",
        TextColor3 = Library.Theme.Accent,
        TextSize = 28,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        ZIndex = 2
    })
    
    local subtitleLabel = CreateInstance("TextLabel", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 65),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = description or "Lifetime key access is available for a one time payment of $15 via solixhub.com",
        TextColor3 = Library.Theme.InactiveText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        ZIndex = 2
    })
    
    local line = CreateInstance("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(0.84, 0, 0, 1),
        Position = UDim2.new(0.08, 0, 0, 95),
        BackgroundColor3 = Library.Theme.Border,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    local closeButton = CreateInstance("TextButton", {
        Parent = mainFrame,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        BackgroundColor3 = Library.Theme.Element,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Library.Theme.Text,
        TextSize = 18,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        TextTransparency = 1,
        ZIndex = 2
    })
    
    CreateInstance("UICorner", {
        Parent = closeButton,
        CornerRadius = UDim.new(0, 5)
    })
    
    local closeStroke = CreateInstance("UIStroke", {
        Parent = closeButton,
        Color = Library.Theme.Border,
        Thickness = 1,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    
    local function CloseUI()
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        CreateTween(overlay, tweenInfo, {BackgroundTransparency = 1})
        CreateTween(titleLabel, tweenInfo, {TextTransparency = 1})
        CreateTween(subtitleLabel, tweenInfo, {TextTransparency = 1})
        CreateTween(line, tweenInfo, {BackgroundTransparency = 1})
        CreateTween(closeButton, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1})
        CreateTween(closeStroke, tweenInfo, {Transparency = 1})
        CreateTween(mainStroke, tweenInfo, {Transparency = 1})
        CreateTween(mainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
        wait(0.35)
        screenGui:Destroy()
    end
    
    closeButton.MouseButton1Click:Connect(CloseUI)
    
    -- Анимация открытия
    wait()
    local openInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    mainFrame.Size = UDim2.new(0, 560, 0, 380)
    
    CreateTween(mainFrame, openInfo, {BackgroundTransparency = 0})
    CreateTween(titleLabel, openInfo, {TextTransparency = 0})
    CreateTween(subtitleLabel, openInfo, {TextTransparency = 0})
    CreateTween(line, openInfo, {BackgroundTransparency = 0})
    CreateTween(closeButton, openInfo, {BackgroundTransparency = 0, TextTransparency = 0})
    CreateTween(closeStroke, openInfo, {Transparency = 0})
    CreateTween(mainStroke, openInfo, {Transparency = 0})
    
    return {
        MainFrame = mainFrame,
        ScreenGui = screenGui,
        Close = CloseUI
    }
end

-- Функция для создания кнопок
function Library:CreateButton(parent, text, position, callback)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
    
    local button = CreateInstance("TextButton", {
        Parent = parent,
        Size = UDim2.new(0, isMobile and 320 or 220, 0, isMobile and 42 or 45),
        Position = position,
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Library.Theme.Element,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Library.Theme.Text,
        TextSize = isMobile and 13 or 15,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        TextTransparency = 1,
        ZIndex = 2
    })
    
    CreateInstance("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 5)
    })
    
    CreateInstance("UIGradient", {
        Parent = button,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(216, 216, 216))
        })
    })
    
    local stroke = CreateInstance("UIStroke", {
        Parent = button,
        Color = Library.Theme.Border,
        Thickness = 1,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    
    -- Анимации при наведении и нажатии
    button.MouseEnter:Connect(function()
        CreateTween(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = isMobile and UDim2.new(0, 330, 0, 45) or UDim2.new(0, 230, 0, 48)
        })
    end)
    
    button.MouseLeave:Connect(function()
        CreateTween(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = isMobile and UDim2.new(0, 320, 0, 42) or UDim2.new(0, 220, 0, 45)
        })
    end)
    
    button.MouseButton1Down:Connect(function()
        CreateTween(button, TweenInfo.new(0.08), {
            Size = isMobile and UDim2.new(0, 310, 0, 40) or UDim2.new(0, 210, 0, 42)
        })
    end)
    
    button.MouseButton1Up:Connect(function()
        CreateTween(button, TweenInfo.new(0.08), {
            Size = isMobile and UDim2.new(0, 320, 0, 42) or UDim2.new(0, 220, 0, 45)
        })
    end)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    -- Анимация появления
    local openInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    CreateTween(button, openInfo, {BackgroundTransparency = 0, TextTransparency = 0})
    CreateTween(stroke, openInfo, {Transparency = 0})
    
    return button
end

-- Пример использования
local function ExampleUsage()
    local window = Library:CreateWindow("Solix Hub Free 15+ Games", "Lifetime key access is available for a one time payment of $15 via solixhub.com")
    
    -- Создаём кнопки
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
    
    if isMobile then
        Library:CreateButton(window.MainFrame, "Get Key (Linkvertise)", UDim2.new(0.5, 0, 0, 185), function()
            Library:Notification({
                Title = "Link Copied",
                Description = "Linkvertise link copied to clipboard",
                Color = Color3.fromRGB(60, 255, 60),
                Duration = 5
            })
        end)
        
        Library:CreateButton(window.MainFrame, "Get Key (Rinku)", UDim2.new(0.5, 0, 0, 240), function()
            Library:Notification({
                Title = "Link Copied",
                Description = "Rinku link copied to clipboard",
                Color = Color3.fromRGB(60, 255, 60),
                Duration = 5
            })
        end)
        
        Library:CreateButton(window.MainFrame, "Join Discord", UDim2.new(0.5, 0, 0, 295), function()
                Library:Notification({
                    Title = "Discord",
                    Description = "Join our Discord community!",
                    Color = Color3.fromRGB(114, 137, 218),
                    Duration = 5
                })
        end)
        
        Library:CreateButton(window.MainFrame, "Buy Standard Key", UDim2.new(0.5, 0, 0, 350), function()
                Library:Notification({
                    Title = "Shop",
                    Description = "Visit our shop to purchase a key!",
                    Color = Color3.fromRGB(255, 215, 0),
                    Duration = 5
                })
        end)
    else
        Library:CreateButton(window.MainFrame, "Get Key (Linkvertise)", UDim2.new(0.25, 0, 0, 190), function()
            Library:Notification({
                Title = "Link Copied",
                Description = "Linkvertise link copied to clipboard",
                Color = Color3.fromRGB(60, 255, 60),
                Duration = 5
            })
        end)
        
        Library:CreateButton(window.MainFrame, "Get Key (Rinku)", UDim2.new(0.75, 0, 0, 190), function()
            Library:Notification({
                Title = "Link Copied",
                Description = "Rinku link copied to clipboard",
                Color = Color3.fromRGB(60, 255, 60),
                Duration = 5
            })
        end)
        
        Library:CreateButton(window.MainFrame, "Join Discord", UDim2.new(0.25, 0, 0, 255), function()
                Library:Notification({
                    Title = "Discord",
                    Description = "Join our Discord community!",
                    Color = Color3.fromRGB(114, 137, 218),
                    Duration = 5
                })
        end)
        
        Library:CreateButton(window.MainFrame, "Buy Standard Key", UDim2.new(0.75, 0, 0, 255), function()
                Library:Notification({
                    Title = "Shop",
                    Description = "Visit our shop to purchase a key!",
                    Color = Color3.fromRGB(255, 215, 0),
                    Duration = 5
                })
        end)
    end
    
    -- Пример уведомления при запуске
    wait(0.5)
    Library:Notification({
        Title = "Welcome",
        Description = "GUI successfully loaded!",
        Color = Color3.fromRGB(60, 255, 60),
        Duration = 5
    })
end

-- Запускаем пример
ExampleUsage()

return Library
