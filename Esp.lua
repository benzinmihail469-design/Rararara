local LibraryVersion = "0.54"

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local function createUI(class, props)
	local inst = Instance.new(class)
	for prop, val in pairs(props) do
		inst[prop] = val
	end
	return inst
end

local library = {}

local function copyToClipboard(text)
	if setclipboard then
		setclipboard(text)
	else
		warn("setclipboard is not supported in this environment.")
	end
end

function library:CopyText(Text)
	copyToClipboard(Text)
end

-- ==================== DARK FANTASY THEME ====================
local Theme = {
	Default = {
		mainFrame = Color3.fromRGB(30, 30, 30),
		NotifyFrame = Color3.fromRGB(30, 30, 30),
		TextColor = Color3.fromRGB(255, 255, 255),
		TabContent = Color3.fromRGB(20, 20, 20),
		TabButtons = Color3.fromRGB(50, 50, 50),
		Top = Color3.fromRGB(45, 45, 45),
		Buttons = Color3.fromRGB(50, 50, 50),
	},

	-- ==================== НОВЫЙ ТЁМНЫЙ ФЭНТЕЗИ ТЕМА ====================
	["Dark Fantasy"] = {
		mainFrame     = Color3.fromRGB(18, 12, 18),      -- почти чёрный с лёгким фиолетовым оттенком
		NotifyFrame   = Color3.fromRGB(22, 10, 22),
		TextColor     = Color3.fromRGB(235, 220, 245),   -- бледно-фиолетово-белый (лунный свет)
		TabContent    = Color3.fromRGB(14, 8, 16),
		TabButtons    = Color3.fromRGB(45, 20, 45),      -- тёмно-пурпурный
		Top           = Color3.fromRGB(35, 15, 35),      -- верхняя панель — "обсидиановый трон"
		Buttons       = Color3.fromRGB(55, 25, 55),      -- кнопки с кроваво-пурпурным оттенком
	},

	-- Остальные темы оставлены без изменений (чтобы ничего не ломать)
	Light = { ... }, -- (твои старые темы)
	["Red Dark"] = { ... },
	["Blue Neon"] = { ... },
	["Green Matrix"] = { ... },
	["Purple Dream"] = { ... },
	Sunset = { ... },
	-- ... и все остальные твои темы
}

-- (Я не стал копировать все темы полностью, чтобы не раздувать сообщение. 
-- Просто заменил блок Theme = { ... } на код выше)

local function VisibleWindow(window, settings1, gui)
	local themeName = settings1.Theme or "Dark Fantasy"
	local selectedTheme = Theme[themeName] or Theme["Dark Fantasy"]  -- по умолчанию теперь Dark Fantasy

	local TweenService = game:GetService("TweenService")

	local mainFrame = createUI("Frame", {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = selectedTheme.mainFrame,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = gui,
	})

	-- Добавляем готическую обводку/тень через UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 30, 90)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.4
	stroke.Parent = mainFrame

	createUI("UICorner", {CornerRadius = UDim.new(0, 8), Parent = mainFrame})

	-- NotifyFrame с более зловещим видом
	local NotifyFrame = createUI("Frame", {
		Size = UDim2.new(0.28, 0, 1, 0),
		Position = UDim2.new(0.72, 0, -0.05, 0),
		BackgroundColor3 = selectedTheme.NotifyFrame,
		BackgroundTransparency = 0.15,
		AnchorPoint = Vector2.new(0, 0),
		Name = "NotifyFrame",
		Parent = gui,
	})

	-- ... (весь остальной код VisibleWindow остаётся **без изменений**, кроме цветов)

	-- Пример изменения цвета уведомления под стиль:
	-- Внутри window:Notify() можно добавить:
	-- durationBar.BackgroundColor3 = Color3.fromRGB(180, 40, 80) -- кроваво-красный

	-- Дальше идёт твой оригинальный код без изменений...
