-- Заголовок в стиле "Foxname - SZA"
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 80)
headerFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

-- Левая цветная полоса
local colorBar = Instance.new("Frame")
colorBar.Size = UDim2.new(0, 5, 1, 0)
colorBar.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
colorBar.BorderSizePixel = 0
colorBar.Parent = headerFrame

-- Название
local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(1, -20, 0.4, 0)
mainTitle.Position = UDim2.new(0.02, 0, 0.2, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "Foxname - SZA"
mainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTitle.TextSize = 26
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
mainTitle.Font = Enum.Font.GothamBold
mainTitle.Parent = headerFrame

-- Подзаголовок с описанием
local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, -20, 0.3, 0)
subTitle.Position = UDim2.new(0.02, 0, 0.55, 0)
subTitle.BackgroundTransparency = 1
subTitle.Text = "Survive Zombie Arena Script"
subTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
subTitle.TextSize = 13
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Font = Enum.Font.Gotham
subTitle.Parent = headerFrame

-- Версия (v1.0.0)
local versionBadge = Instance.new("Frame")
versionBadge.Size = UDim2.new(0, 70, 0, 25)
versionBadge.Position = UDim2.new(1, -80, 0.2, 0)
versionBadge.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
versionBadge.BackgroundTransparency = 0.2
versionBadge.BorderSizePixel = 0
versionBadge.Parent = headerFrame

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(0, 6)
versionCorner.Parent = versionBadge

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(1, 0, 1, 0)
versionText.BackgroundTransparency = 1
versionText.Text = "v1.0.0"
versionText.TextColor3 = Color3.fromRGB(255, 80, 120)
versionText.TextSize = 12
versionText.Font = Enum.Font.GothamBold
versionText.Parent = versionBadge

-- Разделительная линия
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0.02, 0, 1, -5)
divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
divider.BorderSizePixel = 0
divider.Parent = headerFrame

-- Discord строка
local discordFrame = Instance.new("Frame")
discordFrame.Size = UDim2.new(1, -20, 0, 25)
discordFrame.Position = UDim2.new(0.02, 0, 1, -30)
discordFrame.BackgroundTransparency = 1
discordFrame.Parent = headerFrame

local discordIcon = Instance.new("TextLabel")
discordIcon.Size = UDim2.new(0, 20, 1, 0)
discordIcon.BackgroundTransparency = 1
discordIcon.Text = "🎮"
discordIcon.TextSize = 14
discordIcon.TextXAlignment = Enum.TextXAlignment.Left
discordIcon.Parent = discordFrame

local discordText = Instance.new("TextLabel")
discordText.Size = UDim2.new(1, -25, 1, 0)
discordText.Position = UDim2.new(0.02, 0, 0, 0)
discordText.BackgroundTransparency = 1
discordText.Text = "discord.gg/Foxname"
discordText.TextColor3 = Color3.fromRGB(100, 100, 200)
discordText.TextSize = 12
discordText.TextXAlignment = Enum.TextXAlignment.Left
discordText.Font = Enum.Font.Gotham
discordText.Parent = discordFrame
