-- ==================== ФУНКЦИЯ БЕСКОНЕЧНОЙ СТАМИНЫ (ИСПРАВЛЕННАЯ) ====================

local StaminaConnection = nil
local StaminaLoop = nil

local function EnableInfiniteStamina()
    if StaminaConnection then
        StaminaConnection:Disconnect()
        StaminaConnection = nil
    end
    if StaminaLoop then
        StaminaLoop:Disconnect()
        StaminaLoop = nil
    end
    
    -- Способ 1: Через Player Attributes (работает в большинстве survival-игр)
    StaminaLoop = RunService.RenderStepped:Connect(function()
        pcall(function()
            -- Пробуем разные названия атрибутов
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("stamina", 100)
            LocalPlayer:SetAttribute("Energy", 100)
            LocalPlayer:SetAttribute("energy", 100)
            LocalPlayer:SetAttribute("Endurance", 100)
            LocalPlayer:SetAttribute("endurance", 100)
        end)
    end)
    
    -- Способ 2: Поиск UI стамины и блокировка её изменения
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                local name = gui.Name:lower()
                if name:find("stamina") or name:find("energy") or name:find("endurance") then
                    -- Нашли бар стамины, теперь ищем значение
                    local value = gui:FindFirstChild("Value") or gui:FindFirstChild("Bar") or gui.Parent:FindFirstChild("StaminaValue")
                    if value and (value:IsA("NumberValue") or value:IsA("IntValue")) then
                        StaminaConnection = RunService.RenderStepped:Connect(function()
                            pcall(function()
                                value.Value = value.Parent:FindFirstChild("MaxStamina") and value.Parent.MaxStamina.Value or 100
                            end)
                        end)
                        break
                    end
                end
            end
        end
    end
    
    -- Способ 3: Поиск RemoteEvent для стамины и его блокировка
    local repStorage = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(repStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("stamina") or name:find("energy") or name:find("sprint") then
                -- Блокируем FireServer для этого RemoteEvent
                local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if self == obj and method == "FireServer" then
                        return nil
                    end
                    return oldNamecall(self, ...)
                end)
                break
            end
        end
    end
end

local function DisableInfiniteStamina()
    if StaminaConnection then
        StaminaConnection:Disconnect()
        StaminaConnection = nil
    end
    if StaminaLoop then
        StaminaLoop:Disconnect()
        StaminaLoop = nil
    end
end

local function UpdateStamina()
    if Settings.StaminaEnabled then
        EnableInfiniteStamina()
    else
        DisableInfiniteStamina()
    end
end
