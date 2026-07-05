local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("HoshiHubMM2") then
	PlayerGui.HoshiHubMM2:Destroy()
end

-- [ === ФУНКЦИОНАЛ ИГРЫ (Оставлен без изменений) === ]
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

local Flying, FlySpeed, NormalWalkSpeed = false, 35, 16
local WalkSpeedEnabled, AutoFarmEnabled, AutoFarmSpeed = false, false, 16
local ESPEnabled, AutoKillEnabled, AutoShootMurdererEnabled, AutoGetGunEnabled = false, false, false, false
local FlyConnection, NoclipConnection, WalkSpeedConnection, AutoFarmConnection = nil, nil, nil, nil
local NextScanTime, CachedCoin, BVelocity, BGyro = 0, nil, nil, nil

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
		if moveDir.Magnitude > 0 then
			BVelocity.Velocity = moveDir.Unit * FlySpeed
		else
			BVelocity.Velocity = Vector3.new(0, 0, 0)
		end
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
	if not BVelocity or not BVelocity.Parent then
		BVelocity = Instance.new("BodyVelocity", root)
		BVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	end
	if not BGyro or not BGyro.Parent then
		BGyro = Instance.new("BodyGyro", root)
		BGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		BGyro.CFrame = root.CFrame
	end
	AutoFarmConnection = RunService.Heartbeat:Connect(function()
		if not AutoFarmEnabled then StopAutoFarm() return end
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
		local coin = GetTargetCoinGlobal()
		if coin and coin.Parent then
			BGyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(coin.Position.X, root.Position.Y, coin.Position.Z))
			local dir = (coin.Position - root.Position)
			if dir.Magnitude > 1.5 then
				BVelocity.Velocity = dir.Unit * AutoFarmSpeed
			else
				root.CFrame = coin.CFrame
				BVelocity.Velocity = Vector3.new(0, 0, 0)
			end
		else
			BVelocity.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

WalkSpeedConnection = RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and not Flying and not AutoFarmEnabled then
		hum.WalkSpeed = WalkSpeedEnabled and NormalWalkSpeed or 16
	end
end)

local function GetPlayerRoleAndTool(player)
	local isMurderer, isSheriff, specialTool = false, false, nil
	local function check(container)
		if not container then return end
		for _, item in pairs(container:GetChildren()) do
			if item:IsA("Tool") then
				if item:FindFirstChild("KnifeServer") or item:FindFirstChild("KnifeClient") then
					isMurderer = true specialTool = item
				elseif item:FindFirstChild("GunScript") or item:FindFirstChild("GunClient") then
					isSheriff = true specialTool = item
				end
			end
		end
	end
	check(player:FindFirstChild("Backpack"))
	if player.Character then check(player.Character) end
	return isMurderer, isSheriff, specialTool
end

local function IsPlayerInGame(player)
	if not player.Character then return false end
	if player.Character:FindFirstChildOfClass("Tool") then return true end
	local backpack = player:FindFirstChild("Backpack")
	if backpack and #backpack:GetChildren() > 0 then return true end
	return false
end

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
							hl = Instance.new("Highlight")
							hl.Name = "MM2_RoleESP"
							hl.FillTransparency = 0.5
							hl.OutlineTransparency = 0.2
							hl.Parent = char
						end
						hl.FillColor = color
						hl.OutlineColor = color
					else
						local hl = char:FindFirstChild("MM2_RoleESP")
						if hl then hl:Destroy() end
					end
				end
			end
		else
			for _, player in pairs(Players:GetPlayers()) do
				if player.Character then
					local hl = player.Character:FindFirstChild("MM2_RoleESP")
					if hl then hl:Destroy() end
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(0.25) do
		if AutoKillEnabled then
			local isMurderer, _, knife = GetPlayerRoleAndTool(LocalPlayer)
			if isMurderer and knife and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
				local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if myHum and knife.Parent ~= LocalPlayer.Character then
					myHum:EquipTool(knife) task.wait(0.1)
				end
				for _, target in pairs(Players:GetPlayers()) do
					if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
						local targetIsMurderer = GetPlayerRoleAndTool(target)
						local targetHum = target.Character:FindFirstChild("Humanoid")
						local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
						if not targetIsMurderer and targetHum and targetHum.Health > 0 and not targetHum.PlatformStand and IsPlayerInGame(target) then
							myRoot.Velocity = Vector3.new(0, 0, 0)
							myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.5)
							task.wait(0.1)
							knife:Activate()
							task.wait(0.5)
							break
						end
					end
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(0.2) do
		if AutoShootMurdererEnabled then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
				local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if myHum and myHum.Health > 0 then
					local _, isSheriff, gun = GetPlayerRoleAndTool(LocalPlayer)
					if isSheriff and gun then
						if gun.Parent ~= LocalPlayer.Character then
							myHum:EquipTool(gun) task.wait(0.2)
						end
						local murdererRoot = nil
						for _, target in pairs(Players:GetPlayers()) do
							if target ~= LocalPlayer then
								local targetIsMurderer = GetPlayerRoleAndTool(target)
								if targetIsMurderer and target.Character then
									local targetHum = target.Character:FindFirstChild("Humanoid")
									local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
									if targetHum and targetHum.Health > 0 and targetRoot and IsPlayerInGame(target) then
										murdererRoot = targetRoot break
									end
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
							for i = 1, 3 do gun:Activate() task.wait(0.1) end
							cam.CameraType = Enum.CameraType.Custom
							task.wait(1.5)
						end
					end
				end
			end
		end
	end
end)

task.spawn(function()
	while task.wait(0.3) do
		if AutoGetGunEnabled then
			local _, isSheriff = GetPlayerRoleAndTool(LocalPlayer)
			if not isSheriff and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
				if myHum and myHum.Health > 0 then
					local gunDrop = nil
					local dropContainers = { workspace:FindFirstChild("Normal"), workspace:FindFirstChild("Map"), workspace:FindFirstChild("Drops"), workspace:FindFirstChild("Items"), workspace:FindFirstChild("Weapons") }
					for _, container in pairs(dropContainers) do
						if container then
							for _, obj in pairs(container:GetDescendants()) do
								if obj:IsA("BasePart") and obj.Parent and not obj:IsDescendantOf(Players) then
									local objName = obj.Name:lower()
									if objName == "gundrop" or objName == "gun_drop" or objName == "gun" or (objName:find("gun") and obj:FindFirstChild("GunScript")) or (obj:FindFirstChild("GunScript") and obj:FindFirstChild("Handle")) then
										gunDrop = obj break
									end
								end
							end
						end
						if gunDrop then break end
					end
					if not gunDrop then
						for _, obj in pairs(workspace:GetDescendants()) do
							if obj:IsA("BasePart") and obj.Parent and not obj:IsDescendantOf(Players) then
								local objName = obj.Name:lower()
								if objName == "gundrop" or objName == "gun_drop" or (objName:find("gun") and obj:FindFirstChild("GunScript")) then
									gunDrop = obj break
								end
							end
						end
					end
					if gunDrop and gunDrop:IsA("BasePart") and gunDrop.Parent and not gunDrop:IsDescendantOf(Players) then
						local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if myRoot then
							myRoot.CFrame = gunDrop.CFrame * CFrame.new(0, 0, 1)
							task.wait(0.2)
						end
					end
				end
			end
		end
	end
end)

-- [ === HOSHI HUB UI СИСТЕМА === ]

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoshiHubMM2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 450)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Верхняя панель (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 120, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoshi"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local BadgesFrame = Instance.new("Frame")
BadgesFrame.Size = UDim2.new(0, 400, 1, 0)
BadgesFrame.Position = UDim2.new(0, 110, 0, 0)
BadgesFrame.BackgroundTransparency = 1
BadgesFrame.Parent = TopBar

local BadgeLayout = Instance.new("UIListLayout")
BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
BadgeLayout.Padding = UDim.new(0, 10)
BadgeLayout.Parent = BadgesFrame

local function CreateBadge(text, color)
	local b = Instance.new("TextLabel")
	b.Size = UDim2.new(0, 0, 0, 22)
	b.AutomaticSize = Enum.AutomaticSize.X
	b.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
	b.Text = "  " .. text .. "  "
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 11
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.Parent = BadgesFrame
end
CreateBadge("FREE", Color3.fromRGB(40, 40, 55))
CreateBadge("v1.4.0")
CreateBadge("Murder Mystery 2")

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Перетаскивание
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging, dragStart, startPos = true, input.Position, MainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
TopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Боковая панель (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 2)
TabLayout.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -40)
ContentArea.Position = UDim2.new(0, 140, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Система вкладок и секций
local tabs = {}
local activeTabBtn = nil

local function CreateTab(name)
	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 2
	Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
	Page.Visible = false
	Page.Parent = ContentArea

	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Padding = UDim.new(0, 15)
	PageLayout.FillDirection = Enum.FillDirection.Horizontal
	PageLayout.Parent = Page
	
	local LeftCol = Instance.new("Frame")
	LeftCol.Size = UDim2.new(0.5, -20, 1, 0)
	LeftCol.BackgroundTransparency = 1
	LeftCol.Parent = Page
	local LeftLayout = Instance.new("UIListLayout")
	LeftLayout.Padding = UDim.new(0, 10) LeftLayout.Parent = LeftCol
	
	local RightCol = Instance.new("Frame")
	RightCol.Size = UDim2.new(0.5, -10, 1, 0)
	RightCol.BackgroundTransparency = 1
	RightCol.Parent = Page
	local RightLayout = Instance.new("UIListLayout")
	RightLayout.Padding = UDim.new(0, 10) RightLayout.Parent = RightCol

	local TabBtn = Instance.new("TextButton")
	TabBtn.Size = UDim2.new(1, 0, 0, 35)
	TabBtn.BackgroundTransparency = 1
	TabBtn.Font = Enum.Font.Gotham
	TabBtn.Text = "   " .. name
	TabBtn.TextColor3 = Color3.fromRGB(130, 130, 140)
	TabBtn.TextSize = 13
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left
	TabBtn.Parent = Sidebar

	local function SelectTab()
		if activeTabBtn then
			activeTabBtn.TextColor3 = Color3.fromRGB(130, 130, 140)
			activeTabBtn.BackgroundTransparency = 1
		end
		for _, v in pairs(ContentArea:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
		TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
		TabBtn.BackgroundTransparency = 0
		Page.Visible = true
		activeTabBtn = TabBtn
	end

	TabBtn.MouseButton1Click:Connect(SelectTab)
	if not activeTabBtn then SelectTab() end

	return {Left = LeftCol, Right = RightCol}
end

local function CreateSection(parentCol, title)
	local SecFrame = Instance.new("Frame")
	SecFrame.Size = UDim2.new(1, 0, 0, 0)
	SecFrame.AutomaticSize = Enum.AutomaticSize.Y
	SecFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	SecFrame.BorderColor3 = Color3.fromRGB(35, 35, 45)
	SecFrame.BorderSizePixel = 1
	SecFrame.Parent = parentCol
	Instance.new("UICorner", SecFrame).CornerRadius = UDim.new(0, 6)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(40, 40, 50)
	UIStroke.Parent = SecFrame

	local SecTitle = Instance.new("TextLabel")
	SecTitle.Size = UDim2.new(1, -20, 0, 30)
	SecTitle.Position = UDim2.new(0, 10, 0, 5)
	SecTitle.BackgroundTransparency = 1
	SecTitle.Font = Enum.Font.GothamBold
	SecTitle.Text = string.upper(title)
	SecTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	SecTitle.TextSize = 11
	SecTitle.TextXAlignment = Enum.TextXAlignment.Left
	SecTitle.Parent = SecFrame

	local ItemsContainer = Instance.new("Frame")
	ItemsContainer.Size = UDim2.new(1, -20, 0, 0)
	ItemsContainer.Position = UDim2.new(0, 10, 0, 35)
	ItemsContainer.AutomaticSize = Enum.AutomaticSize.Y
	ItemsContainer.BackgroundTransparency = 1
	ItemsContainer.Parent = SecFrame

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Padding = UDim.new(0, 8)
	ListLayout.Parent = ItemsContainer
	
	local Spacer = Instance.new("Frame")
	Spacer.Size = UDim2.new(1,0,0,5) Spacer.BackgroundTransparency=1 Spacer.Parent = ItemsContainer

	return ItemsContainer
end

local function CreateToggle(parent, text, default, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, 0, 0, 30)
	Frame.BackgroundTransparency = 1
	Frame.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -50, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(180, 180, 190)
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(0, 34, 0, 18)
	ToggleBtn.Position = UDim2.new(1, -34, 0.5, -9)
	ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 50)
	ToggleBtn.Text = ""
	ToggleBtn.Parent = Frame
	Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

	local Circle = Instance.new("Frame")
	Circle.Size = UDim2.new(0, 14, 0, 14)
	Circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
	Circle.BackgroundColor3 = default and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(150, 150, 160)
	Circle.Parent = ToggleBtn
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

	local state = default
	ToggleBtn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 50)}):Play()
		TweenService:Create(Circle, TweenInfo.new(0.2), {
			Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
			BackgroundColor3 = state and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(150, 150, 160)
		}):Play()
		callback(state)
	end)
end

local function CreateSlider(parent, text, min, max, default, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, 0, 0, 45)
	Frame.BackgroundTransparency = 1
	Frame.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -40, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(180, 180, 190)
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	local ValLabel = Instance.new("TextLabel")
	ValLabel.Size = UDim2.new(0, 40, 0, 20)
	ValLabel.Position = UDim2.new(1, -40, 0, 0)
	ValLabel.BackgroundTransparency = 1
	ValLabel.Font = Enum.Font.GothamBold
	ValLabel.Text = tostring(default)
	ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ValLabel.TextSize = 12
	ValLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValLabel.Parent = Frame

	local SliderBG = Instance.new("TextButton")
	SliderBG.Size = UDim2.new(1, 0, 0, 4)
	SliderBG.Position = UDim2.new(0, 0, 0, 30)
	SliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	SliderBG.Text = ""
	SliderBG.Parent = Frame
	Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Fill.Parent = SliderBG
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	local sliding = false
	local function Move(input)
		local scale = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
		Fill.Size = UDim2.new(scale, 0, 1, 0)
		local val = math.floor(min + ((max - min) * scale))
		ValLabel.Text = tostring(val)
		callback(val)
	end
	SliderBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true Move(input) end end)
	UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Move(input) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
end

-- Сборка интерфейса по вкладкам
local FarmTab = CreateTab("Auto Farm")
local PlayerTab = CreateTab("Player Settings")
local RoleTab = CreateTab("Role Actions")

-- Вкладка 1: Фарм (Левая и Правая колонки)
local FarmSec = CreateSection(FarmTab.Left, "Coin Farming")
CreateToggle(FarmSec, "Auto Farm Coins", false, function(s) AutoFarmEnabled = s if s then StartAutoFarm() else StopAutoFarm() end end)
CreateSlider(FarmSec, "Farm Speed", 10, 35, 16, function(v) AutoFarmSpeed = v end)

local ESPsSec = CreateSection(FarmTab.Right, "Visuals")
CreateToggle(ESPsSec, "Role ESP", false, function(s) ESPEnabled = s end)

-- Вкладка 2: Игрок
local MoveSec = CreateSection(PlayerTab.Left, "Movement")
CreateToggle(MoveSec, "Bypass Fly", false, function(s) Flying = s if s then StartFlying() else StopFlying() end end)
CreateSlider(MoveSec, "Fly Speed", 15, 100, 35, function(v) FlySpeed = v end)
CreateToggle(MoveSec, "Toggle WalkSpeed", false, function(s) WalkSpeedEnabled = s end)
CreateSlider(MoveSec, "WalkSpeed Value", 16, 120, 16, function(v) NormalWalkSpeed = v end)

local UtilSec = CreateSection(PlayerTab.Right, "Utility")
CreateToggle(UtilSec, "Noclip", false, function(s)
	if s then
		NoclipConnection = RunService.Stepped:Connect(function()
			if LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
		end)
	else
		if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
		if LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
	end
end)
CreateToggle(UtilSec, "Infinite Jump", false, function(s)
	_G.InfJump = s
	if s then
		UserInputService.JumpRequest:Connect(function()
			if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
				LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
			end
		end)
	end
end)

-- Вкладка 3: Роли
local MurderSec = CreateSection(RoleTab.Left, "Murderer")
CreateToggle(MurderSec, "Auto Kill Everyone", false, function(s) AutoKillEnabled = s end)

local SheriffSec = CreateSection(RoleTab.Right, "Sheriff / Innocent")
CreateToggle(SheriffSec, "Auto Shoot Murderer", false, function(s) AutoShootMurdererEnabled = s end)
CreateToggle(SheriffSec, "Auto Get Gun (Dropped)", false, function(s) AutoGetGunEnabled = s end)
