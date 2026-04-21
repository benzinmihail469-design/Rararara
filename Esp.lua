-- Celeron's GUI - Ultra Light (No Lags)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Настройки
local ESP_Enabled = true
local Generator_ESP = true
local Speed_Enabled = false
local Sprint_Enabled = false
local Noclip_Enabled = false

-- Обход античита
pcall(function()
    for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:find("Anti") then v:Destroy() end
    end
    local old = hookmetamethod(game, "__index", function(self, k)
        if self == LocalPlayer and (k == "Stamina" or k == "Energy") then return 100 end
        if k == "WalkSpeed" then return 16 end
        return old(self, k)
    end)
end)

-- Функции
local function GetRoot(m)
    return m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildOfClass("BasePart"))
end
local function GetHumanoid(m)
    return m and m:FindFirstChildOfClass("Humanoid")
end

-- Поиск убийцы (кеш 3 сек)
local killer, killerTime = nil, 0
local function FindKiller()
    if tick() - killerTime < 3 then return killer end
    killerTime = tick()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and GetHumanoid(p.Character) and GetHumanoid(p.Character).MaxHealth > 500 then
            killer = p; return p
        end
    end
    return killer
end

-- Поиск генераторов (кеш 3 сек)
local gens, gensTime = {}, 0
local function FindGenerators()
    if tick() - gensTime < 3 then return gens end
    gensTime = tick()
    local t = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if (o:IsA("Model") and o.Name:lower():find("generator")) or (o:IsA("ProximityPrompt") and o.Parent and o.Parent.Name:lower():find("generator")) then
            local obj = o:IsA("Model") and o or o.Parent
            local found = false
            for _, g in ipairs(t) do if g == obj then found = true break end end
            if not found then table.insert(t, obj) end
        end
    end
    gens = t
    return t
end

-- ESP (макс. легко)
local ESPs = {}
local ObjESPs = {}
local camPos = Vector3.new()
local lastESP = 0
local function UpdateESP()
    local now = tick()
    if now - lastESP < 0.2 then return end  -- 5 FPS
    lastESP = now
    camPos = Camera.CFrame.Position
    local k = FindKiller()

    if ESP_Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not ESPs[p] then
                    local c = (p == k) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    ESPs[p] = {Box=Drawing.new("Square"), Name=Drawing.new("Text")}
                    ESPs[p].Box.Color, ESPs[p].Box.Thickness, ESPs[p].Box.Filled = c, 2, false
                    ESPs[p].Name.Color, ESPs[p].Name.Size, ESPs[p].Name.Center, ESPs[p].Name.Text = c, 13, true, p.Name
                end
            end
        end
        if Generator_ESP then
            for _, g in ipairs(FindGenerators()) do
                local id = g:GetFullName()
                if not ObjESPs[id] then
                    ObjESPs[id] = {Box=Drawing.new("Square"), Name=Drawing.new("Text"), Obj=g}
                    ObjESPs[id].Box.Color, ObjESPs[id].Box.Thickness, ObjESPs[id].Box.Filled = Color3.fromRGB(255,255,0), 2, false
                    ObjESPs[id].Name.Color, ObjESPs[id].Name.Size, ObjESPs[id].Name.Center, ObjESPs[id].Name.Text = Color3.fromRGB(255,255,0), 12, true, "GEN"
                end
            end
        end
    end

    for p, d in pairs(ESPs) do
        local plr = type(p)=="string" and Players:FindFirstChild(p) or p
        if not plr or not plr.Character then d.Box.Visible=false; d.Name.Visible=false; continue end
        local root = GetRoot(plr.Character)
        if not root then d.Box.Visible=false; d.Name.Visible=false; continue end
        local dist = (camPos - root.Position).Magnitude
        if dist > 1500 or not ESP_Enabled then d.Box.Visible=false; d.Name.Visible=false; continue end
        local pos, on = Camera:WorldToViewportPoint(root.Position)
        if not on then d.Box.Visible=false; d.Name.Visible=false; continue end
        local h = 1200 / dist; local w = h * 0.45
        d.Box.Visible, d.Box.Size, d.Box.Position = true, Vector2.new(w, h), Vector2.new(pos.X - w/2, pos.Y - h/2)
        d.Name.Visible, d.Name.Position = true, Vector2.new(pos.X, pos.Y - h/2 - 15)
    end

    for _, d in pairs(ObjESPs) do
        if not ESP_Enabled or not Generator_ESP then d.Box.Visible=false; d.Name.Visible=false; continue end
        local o = d.Obj
        if not o or not o.Parent then d.Box.Visible=false; d.Name.Visible=false; continue end
        local root = o:IsA("BasePart") and o or o.PrimaryPart or o:FindFirstChildOfClass("BasePart")
        if not root then d.Box.Visible=false; d.Name.Visible=false; continue end
        local dist = (camPos - root.Position).Magnitude
        if dist > 1500 then d.Box.Visible=false; d.Name.Visible=false; continue end
        local pos, on = Camera:WorldToViewportPoint(root.Position)
        if not on then d.Box.Visible=false; d.Name.Visible=false; continue end
        local h = 1000 / dist; local w = h * 0.8
        d.Box.Visible, d.Box.Size, d.Box.Position = true, Vector2.new(w, h), Vector2.new(pos.X - w/2, pos.Y - h/2)
        d.Name.Visible, d.Name.Position = true, Vector2.new(pos.X, pos.Y - h/2 - 15)
    end
end

-- Задачи
local tasks = {}
local function ToggleSpeed()
    if tasks.Speed then tasks.Speed:Disconnect() end
    if not Speed_Enabled then return end
    tasks.Speed = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            local h = GetHumanoid(LocalPlayer.Character)
            if h then h.WalkSpeed = 40 end
        end
    end)
end
local function ToggleSprint()
    if tasks.Sprint then tasks.Sprint:Disconnect() end
    if not Sprint_Enabled then return end
    tasks.Sprint = RunService.Heartbeat:Connect(function()
        LocalPlayer:SetAttribute("Stamina", 100)
        LocalPlayer:SetAttribute("Energy", 100)
    end)
end
local function ToggleNoclip()
    if tasks.Noclip then tasks.Noclip:Disconnect() end
    if not Noclip_Enabled then return end
    tasks.Noclip = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

-- GUI (кнопки в ряд)
local gui = Instance.new("ScreenGui", CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 35)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)

local function AddButton(text, x, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 70, 0, 25)
    btn.Position = UDim2.new(0, x, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local espBtn = AddButton("ESP ON", 5, function()
    ESP_Enabled = not ESP_Enabled
    espBtn.Text = ESP_Enabled and "ESP ON" or "ESP OFF"
    espBtn.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)
espBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)

local genBtn = AddButton("GEN ON", 80, function()
    Generator_ESP = not Generator_ESP
    genBtn.Text = Generator_ESP and "GEN ON" or "GEN OFF"
    genBtn.BackgroundColor3 = Generator_ESP and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)
genBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)

local spdBtn = AddButton("SPEED", 155, function()
    Speed_Enabled = not Speed_Enabled
    spdBtn.Text = Speed_Enabled and "SPEED 40" or "SPEED"
    spdBtn.BackgroundColor3 = Speed_Enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    ToggleSpeed()
end)

local sprBtn = AddButton("SPRINT", 230, function()
    Sprint_Enabled = not Sprint_Enabled
    sprBtn.Text = Sprint_Enabled and "SPRINT" or "SPRINT"
    sprBtn.BackgroundColor3 = Sprint_Enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    ToggleSprint()
end)

local noclipBtn = AddButton("NOCLIP", 305, function()
    Noclip_Enabled = not Noclip_Enabled
    noclipBtn.Text = Noclip_Enabled and "NOCLIP" or "NOCLIP"
    noclipBtn.BackgroundColor3 = Noclip_Enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    ToggleNoclip()
end)

-- Перетаскивание панели
local drag, startPos, pos = false
frame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        startPos = i.Position
        pos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - startPos
        frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() drag = false end)

-- Запуск
RunService.RenderStepped:Connect(UpdateESP)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if Speed_Enabled then ToggleSpeed() end
    if Sprint_Enabled then ToggleSprint() end
    if Noclip_Enabled then ToggleNoclip() end
end)
