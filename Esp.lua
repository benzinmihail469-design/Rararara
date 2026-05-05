-- =============================================
-- Zentrix GUI Library v0.54 - Dark Fantasy Edition
-- Оригинал: Iliankytb | Модифицировано под тёмную фэнтези
-- =============================================

local LibraryVersion = "0.54 - Dark Fantasy Edition"

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

-- ==================== ТЕМЫ ====================
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

	["Dark Fantasy"] = {
		mainFrame     = Color3.fromRGB(14, 9, 24),
		NotifyFrame   = Color3.fromRGB(20, 13, 33),
		TextColor     = Color3.fromRGB(240, 220, 255),
		TabContent    = Color3.fromRGB(20, 14, 36),
		TabButtons    = Color3.fromRGB(48, 26, 72),
		Top           = Color3.fromRGB(33, 19, 52),
		Buttons       = Color3.fromRGB(65, 32, 95),

		Accent        = Color3.fromRGB(175, 25, 255),
		Border        = Color3.fromRGB(105, 45, 165),
		Slider        = Color3.fromRGB(175, 25, 255),
		ToggleOn      = Color3.fromRGB(195, 20, 255),
	},

	["Red Dark"] = {
		mainFrame = Color3.fromRGB(45, 0, 0),
		NotifyFrame = Color3.fromRGB(30, 0, 0),
		TextColor = Color3.fromRGB(255, 200, 200),
		TabContent = Color3.fromRGB(25, 0, 0),
		TabButtons = Color3.fromRGB(60, 10, 10),
		Top = Color3.fromRGB(50, 0, 0),
		Buttons = Color3.fromRGB(70, 0, 0),
	},

	["Purple Dream"] = {
		mainFrame = Color3.fromRGB(40, 0, 50),
		NotifyFrame = Color3.fromRGB(30, 0, 40),
		TextColor = Color3.fromRGB(255, 200, 255),
		TabContent = Color3.fromRGB(60, 0, 80),
		TabButtons = Color3.fromRGB(120, 0, 150),
		Top = Color3.fromRGB(100, 0, 130),
		Buttons = Color3.fromRGB(90, 0, 120),
	},

	["Blue Neon"] = {
		mainFrame = Color3.fromRGB(10, 10, 30),
		NotifyFrame = Color3.fromRGB(15, 15, 40),
		TextColor = Color3.fromRGB(0, 200, 255),
		TabContent = Color3.fromRGB(20, 20, 50),
		TabButtons = Color3.fromRGB(0, 140, 255),
		Top = Color3.fromRGB(0, 120, 255),
		Buttons = Color3.fromRGB(0, 100, 200),
	},

	["Green Matrix"] = {
		mainFrame = Color3.fromRGB(0, 20, 0),
		NotifyFrame = Color3.fromRGB(0, 30, 0),
		TextColor = Color3.fromRGB(255, 255, 255),
		TabContent = Color3.fromRGB(0, 40, 0),
		TabButtons = Color3.fromRGB(0, 200, 0),
		Top = Color3.fromRGB(0, 180, 0),
		Buttons = Color3.fromRGB(0, 200, 0),
	},
}

function library:SetTheme(themeName)
	if Theme[themeName] then
		library.CurrentTheme = Theme[themeName]
		print("✅ Zentrix: Тема '" .. themeName .. "' применена!")
	else
		warn("❌ Тема '" .. themeName .. "' не найдена!")
	end
end

-- ==================== ОСНОВНЫЕ ФУНКЦИИ ====================

function library:CreateWindow(title)
	local CurrentTheme = library.CurrentTheme or Theme.Default

	local ScreenGui = createUI("ScreenGui", {
		Name = "ZentrixUI",
		Parent = game:GetService("CoreGui"),
		ResetOnSpawn = false,
	})

	local MainFrame = createUI("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = CurrentTheme.mainFrame,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(0.5, -310, 0.5, -210),
		Size = UDim2.new(0, 620, 0, 420),
	})

	-- Верхняя панель
	local TopBar = createUI("Frame", {
		Name = "TopBar",
		Parent = MainFrame,
		BackgroundColor3 = CurrentTheme.Top,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
	})

	local TitleLabel = createUI("TextLabel", {
		Name = "Title",
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = title or "Zentrix Dark Fantasy",
		TextColor3 = CurrentTheme.TextColor,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	-- Кнопка закрытия
	local CloseButton = createUI("TextButton", {
		Name = "Close",
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -40, 0, 0),
		Size = UDim2.new(0, 40, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "✕",
		TextColor3 = Color3.fromRGB(255, 80, 80),
		TextSize = 18,
	})

	CloseButton.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	-- Панель табов
	local TabHolder = createUI("Frame", {
		Name = "TabHolder",
		Parent = MainFrame,
		BackgroundColor3 = CurrentTheme.TabButtons,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(0, 140, 1, -40),
	})

	local TabList = createUI("UIListLayout", {
		Parent = TabHolder,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	})

	-- Контент
	local ContentFrame = createUI("Frame", {
		Name = "Content",
		Parent = MainFrame,
		BackgroundColor3 = CurrentTheme.TabContent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 140, 0, 40),
		Size = UDim2.new(1, -140, 1, -40),
	})

	local window = {
		ScreenGui = ScreenGui,
		MainFrame = MainFrame,
		ContentFrame = ContentFrame,
		Tabs = {},
	}

	function window:CreateTab(tabName)
		local TabButton = createUI("TextButton", {
			Name = tabName,
			Parent = TabHolder,
			BackgroundColor3 = CurrentTheme.TabButtons,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 35),
			Font = Enum.Font.GothamSemibold,
			Text = tabName,
			TextColor3 = CurrentTheme.TextColor,
			TextSize = 14,
		})

		local TabContent = createUI("ScrollingFrame", {
			Name = tabName .. "Content",
			Parent = ContentFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 4,
			Visible = false,
		})

		createUI("UIListLayout", {
			Parent = TabContent,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		})

		if #window.Tabs == 0 then
			TabContent.Visible = true
		end

		TabButton.MouseButton1Click:Connect(function()
			for _, tab in pairs(ContentFrame:GetChildren()) do
				if tab:IsA("ScrollingFrame") then
					tab.Visible = false
				end
			end
			TabContent.Visible = true
		end)

		local tab = {
			Button = TabButton,
			Content = TabContent,
		}

		table.insert(window.Tabs, tab)

		-- === ЭЛЕМЕНТЫ ===
		function tab:CreateButton(text, callback)
			local Button = createUI("TextButton", {
				Parent = tab.Content,
				BackgroundColor3 = CurrentTheme.Buttons,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -12, 0, 35),
				Font = Enum.Font.GothamSemibold,
				Text = text,
				TextColor3 = CurrentTheme.TextColor,
				TextSize = 14,
			})

			Button.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
			return Button
		end

		function tab:CreateToggle(text, default, callback)
			local toggled = default or false
			local ToggleFrame = createUI("Frame", {
				Parent = tab.Content,
				BackgroundColor3 = CurrentTheme.Buttons,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -12, 0, 35),
			})

			createUI("TextLabel", {
				Parent = ToggleFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0.7, 0, 1, 0),
				Font = Enum.Font.GothamSemibold,
				Text = text,
				TextColor3 = CurrentTheme.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local ToggleButton = createUI("Frame", {
				Parent = ToggleFrame,
				BackgroundColor3 = toggled and CurrentTheme.ToggleOn or Color3.fromRGB(60, 60, 60),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -55, 0.5, -10),
				Size = UDim2.new(0, 45, 0, 20),
			})

			local ToggleCircle = createUI("Frame", {
				Parent = ToggleButton,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
			})

			local function UpdateToggle()
				ToggleButton.BackgroundColor3 = toggled and CurrentTheme.ToggleOn or Color3.fromRGB(60, 60, 60)
				ToggleCircle.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			end

			ToggleFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					toggled = not toggled
					UpdateToggle()
					if callback then callback(toggled) end
				end
			end)

			return { Value = function() return toggled end }
		end

		function tab:CreateSlider(text, min, max, default, callback)
			local value = default or min
			local SliderFrame = createUI("Frame", {
				Parent = tab.Content,
				BackgroundColor3 = CurrentTheme.Buttons,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -12, 0, 50),
			})

			local SliderLabel = createUI("TextLabel", {
				Parent = SliderFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 5),
				Size = UDim2.new(1, -20, 0, 20),
				Font = Enum.Font.GothamSemibold,
				Text = text .. ": " .. value,
				TextColor3 = CurrentTheme.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local SliderBar = createUI("Frame", {
				Parent = SliderFrame,
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0.65, 0),
				Size = UDim2.new(1, -20, 0, 6),
			})

			local SliderFill = createUI("Frame", {
				Parent = SliderBar,
				BackgroundColor3 = CurrentTheme.Slider or CurrentTheme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new(((value - min) / (max - min)), 0, 1, 0),
			})

			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local conn
					conn = UserInputService.InputChanged:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseMovement then
							local percent = math.clamp((inp.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
							value = math.floor(min + (max - min) * percent)
							SliderFill.Size = UDim2.new(percent, 0, 1, 0)
							SliderLabel.Text = text .. ": " .. value
							if callback then callback(value) end
						end
					end)
					UserInputService.InputEnded:Connect(function() conn:Disconnect() end)
				end
			end)

			return { Value = value }
		end

		return tab
	end

	return window
end

-- Notify функция
function library:Notify(title, text, duration)
	duration = duration or 4
	local CurrentTheme = library.CurrentTheme or Theme.Default

	local NotifyGui = createUI("ScreenGui", { Parent = game:GetService("CoreGui"), ResetOnSpawn = false })
	local NotifyFrame = createUI("Frame", {
		Parent = NotifyGui,
		BackgroundColor3 = CurrentTheme.NotifyFrame,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -300, 0, 50),
		Size = UDim2.new(0, 280, 0, 80),
	})

	createUI("TextLabel", { Parent = NotifyFrame, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,8), Size = UDim2.new(1,-20,0,25), Font = Enum.Font.GothamBold, Text = title or "Zentrix", TextColor3 = CurrentTheme.TextColor, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left })
	createUI("TextLabel", { Parent = NotifyFrame, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,35), Size = UDim2.new(1,-20,0,40), Font = Enum.Font.Gotham, Text = text or "", TextColor3 = CurrentTheme.TextColor, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left })

	NotifyFrame.Position = UDim2.new(1, 20, 0, 50)
	game:GetService("TweenService"):Create(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -300, 0, 50)}):Play()

	task.delay(duration, function()
		game:GetService("TweenService"):Create(NotifyFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, 20, 0, 50)}):Play()
		task.wait(0.6)
		NotifyGui:Destroy()
	end)
end

-- ==================== ЗАПУСК ====================
print("Zentrix Dark Fantasy Edition " .. LibraryVersion .. " загружена")
task.spawn(function()
	task.wait(0.5)
	library:SetTheme("Dark Fantasy")
	library:Notify("Успешно", "Dark Fantasy тема загружена", 5)
end)

-- Пример использования:
-- local window = library:CreateWindow("Мой Скрипт")
-- local tab = window:CreateTab("Главная")
-- tab:CreateButton("Тест кнопка", function() print("Работает!") end)
-- tab:CreateToggle("Вкл/Выкл", false, function(v) print(v) end)

return library
