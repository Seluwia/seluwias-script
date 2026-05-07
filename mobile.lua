local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()


local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local MPS = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("SeluwiaMobileUI") then
    CoreGui.SeluwiaMobileUI:Destroy()
end

local theme = {
    bg = Color3.fromRGB(12, 12, 14),
    surface = Color3.fromRGB(18, 18, 22),
    surfaceHi = Color3.fromRGB(28, 28, 34),
    border = Color3.fromRGB(40, 40, 48),
    accent = Color3.fromRGB(255, 255, 255),
    green = Color3.fromRGB(0, 255, 150),
    red = Color3.fromRGB(255, 80,  80),
    text = Color3.fromRGB(240, 240, 240),
    muted = Color3.fromRGB(140, 140, 150),
}

local uiVisible = true
local events = 0

local PW = 245
local PH = 210

local function corner(inst, r)
    local c = Instance.new("UICorner", inst)
    c.CornerRadius = UDim.new(0, r or 10)
    return c
end

local function stroke(inst, col, t, trans)
    local s = Instance.new("UIStroke", inst)
    s.Color     = col or C.border
    s.Thickness = t or 1
    s.Transparency = trans or 0
    return s
end

local function tw(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function makeDraggable(obj, handle)
    handle = handle or obj
    local active = false
    local start, pos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            start = input.Position
            pos = obj.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - start
            obj.Position = UDim2.new(
                pos.X.Scale, pos.X.Offset + delta.X,
                pos.Y.Scale, pos.Y.Offset + delta.Y
            )
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)
end

local sg = Instance.new("ScreenGui")
sg.Name            = "SeluwiaMobileUI"
sg.ResetOnSpawn    = false
sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset  = true
sg.Parent          = CoreGui

local toggle = Instance.new("TextButton")
toggle.Name = "ToggleIcon"
toggle.Size = UDim2.new(0, 42, 0, 42)
toggle.Position = UDim2.new(0.05, 0, 0.2, 0)
toggle.BackgroundColor3 = theme.surfaceHi
toggle.Text = "S"
toggle.TextColor3 = theme.accent
toggle.TextSize = 20
toggle.Font = Enum.Font.GothamBold
toggle.Parent = sg
corner(toggle, 21)
stroke(toggle, theme.accent, 1.5, 0.2)
makeDraggable(toggle)

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, PW, 0, PH)
panel.Position = UDim2.new(0.5, -PW/2, 0.5, -PH/2)
panel.BackgroundColor3 = theme.bg
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = sg
UI_Panel = panel
corner(panel, 12)
stroke(panel, theme.accent, 1, 0.8)

local tb = Instance.new("Frame")
tb.Size = UDim2.new(1, 0, 0, 34)
tb.BackgroundTransparency = 1
tb.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Seluwia Listener"
title.TextColor3 = theme.accent
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.Parent = tb

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 22, 0, 22)
close.Position = UDim2.new(1, -30, 0.5, -11)
close.BackgroundColor3 = theme.surfaceHi
close.Text = "X"
close.TextColor3 = theme.red
close.TextSize = 10
close.Font = Enum.Font.GothamBold
close.Parent = tb
addCorner(close, 6)

makeDraggable(panel, tb)

toggle.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    panel.Visible = uiVisible
    tw(toggle, TweenInfo.new(0.3), {Rotation = uiVisible and 0 or 180})
end)
close.MouseButton1Click:Connect(function() sg:Destroy() end)

local logArea = Instance.new("ScrollingFrame")
logArea.Size = UDim2.new(1, -16, 1, -45)
logArea.Position = UDim2.new(0, 8, 0, 38)
logArea.BackgroundTransparency = 1
logArea.BorderSizePixel = 0
logArea.ScrollBarThickness = 0
logArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
logArea.CanvasSize = UDim2.new(0, 0, 0, 0)
logArea.Parent = panel

local list = Instance.new("UIListLayout", logArea)
list.Padding = UDim.new(0, 5)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder

local empty = Instance.new("TextLabel")
empty.Size = UDim2.new(1, 0, 0, 40)
empty.BackgroundTransparency = 1
empty.Text = "Waiting for events..."
empty.TextColor3 = theme.muted
empty.TextSize = 11
empty.Font = Enum.Font.Gotham
empty.Parent = logArea

local function addLog(lbl, id, sType)
    empty.Visible = false
    events = events + 1
    
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, 38)
    entry.BackgroundColor3 = theme.surface
    entry.LayoutOrder = -events
    entry.Parent = logArea
    addCorner(entry, 8)
    addStroke(entry, theme.border, 1, 0.4)

    local idLbl = Instance.new("TextLabel")
    idLbl.Size = UDim2.new(1, -60, 1, 0)
    idLbl.Position = UDim2.new(0, 10, 0, 0)
    idLbl.BackgroundTransparency = 1
    idLbl.Text = string.format("[%s] %s", lbl:sub(1,1), tostring(id))
    idLbl.TextColor3 = theme.text
    idLbl.TextSize = 11
    idLbl.Font = Enum.Font.GothamBold
    idLbl.TextXAlignment = Enum.TextXAlignment.Left
    idLbl.Parent = entry

    local run = Instance.new("TextButton")
    run.Size = UDim2.new(0, 44, 0, 24)
    run.Position = UDim2.new(1, -50, 0.5, -12)
    run.BackgroundColor3 = theme.bg
    run.Text = "RUN"
    run.TextColor3 = theme.green
    run.TextSize = 9
    run.Font = Enum.Font.GothamBold
    run.Parent = entry
    addCorner(run, 6)
    addStroke(run, theme.green, 1, 0.6)
    
    run.MouseButton1Click:Connect(function()
        pcall(function()
            if sType == "Product" then MPS:SignalPromptProductPurchaseFinished(lp.UserId, id, true)
            elseif sType == "Gamepass" then MPS:SignalPromptGamePassPurchaseFinished(lp, id, true)
            elseif sType == "Purchase" then MPS:SignalPromptPurchaseFinished(lp.UserId, id, true)
            end
        end)
        run.TextColor3 = theme.accent
        task.wait(0.4)
        run.TextColor3 = theme.green
    end)
end

local function hook(sig, lbl, sType)
    pcall(function()
        sig:Connect(function(_, id)
            addLog(lbl, id, sType)
        end)
    end)
end

hook(MPS.PromptProductPurchaseFinished, "Product", "Product")
hook(MPS.PromptGamePassPurchaseFinished, "Gamepass", "Gamepass")
hook(MPS.PromptPurchaseFinished, "Purchase", "Purchase")

print("[Seluwia Mobile] Loaded")
