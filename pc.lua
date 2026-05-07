local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")


local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
if setclipboard then setclipboard("discord.gg/seluwia") end

-- theme config
local theme = {
    bg = Color3.fromRGB(12, 12, 15),
    surface = Color3.fromRGB(18, 18, 22),
    surfaceHigh = Color3.fromRGB(25, 25, 30),
    accent = Color3.fromRGB(160, 160, 255),
    text = Color3.fromRGB(240, 240, 240),
    muted = Color3.fromRGB(150, 150, 160),
    border = Color3.fromRGB(50, 50, 80),
    green = Color3.fromRGB(0, 200, 100),
    red = Color3.fromRGB(200, 50, 50)
}

local font = Enum.Font.Arcade
local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- simple helper funcs
local function addStroke(obj, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or theme.border
    s.Thickness = thick or 1
    s.Parent = obj
    return s
end

local function tween(obj, props)
    local t = TweenService:Create(obj, tInfo, props)
    t:Play()
    return t
end

local core = {
    tabs = {},
    active = nil,
    save = {
        auto = false,
        crash = false,
        cps = 1,
        key = "",
        loops = {}
    }
}

function core:saveData()
    local data = {
        AutoFire = self.save.auto,
        CrashMode = self.save.crash,
        CPS = self.save.cps,
        Key = self.save.key
    }
    pcall(function()
        if writefile then
            writefile("seluwia.xyz.json", HttpService:JSONEncode(data))
        end
    end)
end

function core:loadData()
    pcall(function()
        if isfile and isfile("seluwia.xyz.json") then
            local data = HttpService:JSONDecode(readfile("seluwia.xyz.json"))
            if data then
                self.save.auto = data.AutoFire or false
                self.save.crash = data.CrashMode or false
                self.save.cps = data.CPS or 1
                self.save.key = data.Key or ""
            end
        end
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "SeluwiaRecode"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 600, 0, 400)
main.Position = UDim2.new(0.5, -300, 0.5, -200)
main.BackgroundColor3 = theme.bg
main.BorderSizePixel = 0
main.Visible = true 
main.Parent = gui
addStroke(main, theme.border, 1.5)

-- drag logic
do
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--// Navigation Setup
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = theme.surface
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Logo"
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "seluwia.xyz"
title.TextColor3 = theme.accent
title.TextSize = 18
title.Font = font
title.Parent = sidebar

local nav = Instance.new("Frame")
nav.Name = "Navigation"
nav.Size = UDim2.new(1, -20, 1, -120)
nav.Position = UDim2.new(0, 10, 0, 70)
nav.BackgroundTransparency = 1
nav.Parent = sidebar

local navList = Instance.new("UIListLayout")
navList.Padding = UDim.new(0, 5)
navList.Parent = nav

local bottom = Instance.new("Frame")
bottom.Name = "BottomNav"
bottom.Size = UDim2.new(1, -20, 0, 40)
bottom.Position = UDim2.new(0, 10, 1, -50)
bottom.BackgroundTransparency = 1
bottom.Parent = sidebar

local version = Instance.new("TextLabel")
version.Name = "Version"
version.Size = UDim2.new(1, 0, 0, 20)
version.Position = UDim2.new(0, 0, 1, -20)
version.BackgroundTransparency = 1
version.Text = "v0.2"
version.TextColor3 = theme.muted
version.TextSize = 10
version.Font = font
version.Parent = sidebar

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -170, 1, -20)
content.Position = UDim2.new(0, 170, 0, 10)
content.BackgroundTransparency = 1
content.Parent = main

--// Tab System
function core:switchTab(name)
    if self.active == name then return end
    self.active = name
    
    for tName, data in pairs(self.tabs) do
        local isActive = (tName == name)
        data.Page.Visible = isActive
        
        tween(data.Button, {
            BackgroundColor3 = isActive and theme.surfaceHigh or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = isActive and 0 or 1
        })
        
        tween(data.Button:FindFirstChildOfClass("TextLabel"), {
            TextColor3 = isActive and theme.accent or theme.muted,
            TextSize = isActive and 16 or 14
        })
        tween(data.Button:FindFirstChildOfClass("UIStroke"), {
            Color = isActive and theme.accent or theme.border,
            Transparency = isActive and 0 or 0.5
        })
    end
end

function core:newTab(name, scrollable, par)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = par or nav
    addStroke(button)
    
    if par == bottom then
        button.Size = UDim2.new(1, 0, 1, 0)
    end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.muted
    label.TextSize = 14
    label.Font = font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local page = scrollable and Instance.new("ScrollingFrame") or Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = content
    
    if scrollable then
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = theme.accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    end
    
    self.tabs[name] = {Button = button, Page = page}
    button.MouseButton1Click:Connect(function() self:switchTab(name) end)
    
    return page
end

local home = core:newTab("Home", false)
local listener = core:newTab("Listener", false)
local console = core:newTab("Console", true)

-- home content
local userCard = Instance.new("Frame")
userCard.Name = "UserCard"
userCard.Size = UDim2.new(1, -10, 0, 100)
userCard.BackgroundColor3 = theme.surface
userCard.Parent = home
addStroke(userCard)

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(0, 80, 0, 80)
avatar.Position = UDim2.new(0, 10, 0, 10)
avatar.BackgroundColor3 = theme.surfaceHigh
avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", lp.UserId)
avatar.Parent = userCard

local displayName = Instance.new("TextLabel")
displayName.Name = "DisplayName"
displayName.Size = UDim2.new(1, -110, 0, 25)
displayName.Position = UDim2.new(0, 100, 0, 20)
displayName.BackgroundTransparency = 1
displayName.Text = lp.DisplayName
displayName.TextColor3 = theme.text
displayName.TextSize = 18
displayName.Font = font
displayName.TextXAlignment = Enum.TextXAlignment.Left
displayName.Parent = userCard

local handle = Instance.new("TextLabel")
handle.Name = "Handle"
handle.Size = UDim2.new(1, -110, 0, 20)
handle.Position = UDim2.new(0, 100, 0, 45)
handle.BackgroundTransparency = 1
handle.Text = "@" .. lp.Name
handle.TextColor3 = theme.muted
handle.TextSize = 14
handle.Font = font
handle.TextXAlignment = Enum.TextXAlignment.Left
handle.Parent = userCard

--// Discord Integration
-- discord section
local function getAsset(url, name)
    local ok, asset = pcall(function()
        if writefile and getcustomasset and readfile and game.HttpGet then
            local path = "seluwia_" .. name .. ".png"
            if not isfile(path) then
                writefile(path, game:HttpGet(url))
            end
            return getcustomasset(path)
        end
    end)
    return ok and asset or "rbxassetid://13834161834"
end

local dCard = Instance.new("Frame")
dCard.Name = "DiscordCard"
dCard.Size = UDim2.new(1, -10, 0, 100)
dCard.Position = UDim2.new(0, 0, 0, 110)
dCard.BackgroundColor3 = theme.surface
dCard.Parent = home
addStroke(dCard)

local dIcon = Instance.new("ImageLabel")
dIcon.Name = "Icon"
dIcon.Size = UDim2.new(0, 80, 0, 80)
dIcon.Position = UDim2.new(0, 10, 0, 10)
dIcon.BackgroundTransparency = 1
dIcon.Image = getAsset("https://cdn.discordapp.com/icons/1495800737429585950/69bc2ae1ac454a5b4ade5f86738c59e2.webp", "server_icon")
dIcon.Parent = dCard

local dTitle = Instance.new("TextLabel")
dTitle.Name = "Title"
dTitle.Size = UDim2.new(1, -110, 0, 25)
dTitle.Position = UDim2.new(0, 100, 0, 20)
dTitle.BackgroundTransparency = 1
dTitle.Text = "seluwia.xyz"
dTitle.TextColor3 = theme.text
dTitle.TextSize = 18
dTitle.Font = font
dTitle.TextXAlignment = Enum.TextXAlignment.Left
dTitle.Parent = dCard

local dJoin = Instance.new("TextButton")
dJoin.Name = "JoinButton"
dJoin.Size = UDim2.new(0, 100, 0, 30)
dJoin.Position = UDim2.new(0, 100, 0, 50)
dJoin.BackgroundColor3 = theme.accent
dJoin.Text = "Join"
dJoin.TextColor3 = theme.bg
dJoin.Font = font
dJoin.TextSize = 14
dJoin.Parent = dCard

dJoin.MouseButton1Click:Connect(function()
    local inv = "https://discord.gg/seluwia"
    if setclipboard then
        setclipboard(inv)
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 200, 0, 40)
        toast.Position = UDim2.new(0.5, -100, 1, 10)
        toast.BackgroundColor3 = theme.surfaceHigh
        toast.Parent = gui
        addStroke(toast, theme.accent)
        
        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, 0, 1, 0)
        msg.BackgroundTransparency = 1
        msg.Text = "Link Copied!"
        msg.TextColor3 = theme.text
        msg.Font = font
        msg.TextSize = 12
        msg.Parent = toast
        
        tween(toast, {Position = UDim2.new(0.5, -100, 1, -60)})
        task.delay(2, function()
            tween(toast, {Position = UDim2.new(0.5, -100, 1, 10)})
            task.wait(0.2)
            toast:Destroy()
        end)
    end
end)

-- listener tab
local lHeader = Instance.new("Frame")
lHeader.Size = UDim2.new(1, 0, 0, 30)
lHeader.BackgroundTransparency = 1
lHeader.Parent = listener

local clear = Instance.new("TextButton")
clear.Size = UDim2.new(0, 60, 0, 20)
clear.Position = UDim2.new(1, -65, 0, 5)
clear.BackgroundColor3 = theme.surfaceHigh
clear.Text = "Clear"
clear.TextColor3 = theme.muted
clear.Font = font
clear.TextSize = 10
clear.Parent = lHeader
addStroke(clear)

local lScroll = Instance.new("ScrollingFrame")
lScroll.Size = UDim2.new(1, 0, 1, -30)
lScroll.Position = UDim2.new(0, 0, 0, 30)
lScroll.BackgroundTransparency = 1
lScroll.ScrollBarThickness = 2
lScroll.ScrollBarImageColor3 = theme.accent
lScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
lScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
lScroll.Parent = listener

local lList = Instance.new("UIListLayout")
lList.Padding = UDim.new(0, 8)
lList.SortOrder = Enum.SortOrder.LayoutOrder
lList.Parent = lScroll

clear.MouseButton1Click:Connect(function()
    for _, stop in pairs(core.save.loops) do stop() end
    core.save.loops = {}
    for _, obj in pairs(lScroll:GetChildren()) do
        if obj:IsA("Frame") then obj:Destroy() end
    end
end)

local function newEvent(lbl, id, sType, n)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, -10, 0, 60)
    entry.BackgroundColor3 = theme.surface
    entry.LayoutOrder = -tick()
    entry.Parent = lScroll
    addStroke(entry)
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -120, 0, 25)
    nameLbl.Position = UDim2.new(0, 12, 0, 8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = n or "Unknown Asset"
    nameLbl.TextColor3 = theme.text
    nameLbl.TextSize = 14
    nameLbl.Font = font
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = entry
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -120, 0, 20)
    info.Position = UDim2.new(0, 12, 0, 30)
    info.BackgroundTransparency = 1
    info.Text = string.format("%s | ID: %s", lbl, tostring(id))
    info.TextColor3 = theme.muted
    info.TextSize = 12
    info.Font = font
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = entry
    
    local run = Instance.new("TextButton")
    run.Size = UDim2.new(0, 80, 0, 30)
    run.Position = UDim2.new(1, -90, 0.5, -15)
    run.BackgroundColor3 = theme.accent
    run.Text = "Run"
    run.TextColor3 = theme.bg
    run.Font = font
    run.TextSize = 12
    run.Parent = entry
    
    run.MouseButton1Click:Connect(function()
        local function trigger(silent)
            pcall(function()
                if sType == "Product" then MarketplaceService:SignalPromptProductPurchaseFinished(lp.UserId, id, true)
                elseif sType == "Gamepass" then MarketplaceService:SignalPromptGamePassPurchaseFinished(lp, id, true)
                elseif sType == "Bulk" then MarketplaceService:SignalPromptBulkPurchaseFinished(lp.UserId, id, true)
                elseif sType == "Purchase" then MarketplaceService:SignalPromptPurchaseFinished(lp.UserId, id, true) end
                if not silent then
                    print(("[Seluwia] EXECUTED: %s for ID %s"):format(sType, tostring(id)))
                end
            end)
        end

        if core.save.crash then
            print("[Seluwia] CRASH MODE ACTIVE")
            
            local rs = game:GetService("RunService")
            local sg = game:GetService("StarterGui")
            pcall(function() rs:Set3dRenderingEnabled(false) end)
            pcall(function() sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)

            task.spawn(function()
                local t = 100000000000
                local c = 0
                while c < t and entry.Parent do
                    for _ = 1, 5000 do 
                        trigger(true) 
                        c = c + 1
                    end
                    task.wait()
                end
                
                pcall(function() rs:Set3dRenderingEnabled(true) end)
                pcall(function() sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
                print("[Seluwia] 100B BURST DONE")
            end)
        elseif core.save.auto then
            task.spawn(function()
                while entry.Parent do
                    local cps = core.save.cps
                    trigger()
                    if cps > 60 then
                        for _ = 1, math.floor(cps / 60) - 1 do
                            if not entry.Parent then break end
                            trigger(true)
                        end
                        task.wait(1/60)
                    else
                        task.wait(1/cps)
                    end
                end
            end)
        else
            trigger()
        end
    end)
end

-- console tab
local cContainer = Instance.new("ScrollingFrame")
cContainer.Size = UDim2.new(1, -10, 1, -10)
cContainer.Position = UDim2.new(0, 5, 0, 5)
cContainer.BackgroundTransparency = 1
cContainer.ScrollBarThickness = 2
cContainer.ScrollBarImageColor3 = theme.accent
cContainer.Parent = console

local cList = Instance.new("UIListLayout")
cList.Padding = UDim.new(0, 4)
cList.Parent = cContainer

local function addLog(msg, mType)
    local col = theme.text
    if mType == Enum.MessageType.MessageWarning then col = Color3.fromRGB(255, 200, 0)
    elseif mType == Enum.MessageType.MessageError then col = theme.red
    elseif mType == Enum.MessageType.MessageInfo then col = theme.accent end
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.format("[%s] %s", os.date("%H:%M:%S"), msg)
    lbl.TextColor3 = col
    lbl.TextSize = 12
    lbl.Font = Enum.Font.RobotoMono
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.LayoutOrder = -tick()
    lbl.Parent = cContainer
end

-- settings tab
core:loadData()
local sPage = core:newTab("Settings", false, bottom)
Instance.new("UIListLayout", sPage).Padding = UDim.new(0, 10)

local autoF = Instance.new("Frame", sPage)
autoF.Size, autoF.BackgroundTransparency = UDim2.new(1, -10, 0, 40), 1

local autoL = Instance.new("TextLabel", autoF)
autoL.Size, autoL.BackgroundTransparency, autoL.Text, autoL.TextColor3, autoL.Font, autoL.TextSize, autoL.TextXAlignment = UDim2.new(0.5, 0, 1, 0), 1, "Auto Fire", theme.text, font, 14, Enum.TextXAlignment.Left

local autoB = Instance.new("TextButton", autoF)
autoB.Size, autoB.Position, autoB.BackgroundColor3, autoB.Text, autoB.TextColor3, autoB.Font, autoB.TextSize = UDim2.new(0, 80, 0, 30), UDim2.new(1, -80, 0.5, -15), theme.surfaceHigh, "OFF", theme.red, font, 14
addStroke(autoB)

local function syncAuto()
    autoB.Text = core.save.auto and "ON" or "OFF"
    autoB.TextColor3 = core.save.auto and theme.green or theme.red
end
syncAuto()

autoB.MouseButton1Click:Connect(function()
    core.save.auto = not core.save.auto
    syncAuto()
    core:saveData()
end)

local cpsF = Instance.new("Frame", sPage)
cpsF.Size, cpsF.BackgroundTransparency = UDim2.new(1, -10, 0, 40), 1

local cpsL = Instance.new("TextLabel", cpsF)
cpsL.Size, cpsL.BackgroundTransparency, cpsL.Text, cpsL.TextColor3, cpsL.Font, cpsL.TextSize, cpsL.TextXAlignment = UDim2.new(0.5, 0, 1, 0), 1, "CPS (No Limit)", theme.text, font, 14, Enum.TextXAlignment.Left

local cpsI = Instance.new("TextBox", cpsF)
cpsI.Size, cpsI.Position, cpsI.BackgroundColor3, cpsI.Text, cpsI.TextColor3, cpsI.Font, cpsI.TextSize = UDim2.new(0, 80, 0, 30), UDim2.new(1, -80, 0.5, -15), theme.surfaceHigh, tostring(core.save.cps), theme.text, font, 14
addStroke(cpsI)

cpsI.FocusLost:Connect(function()
    local n = tonumber(cpsI.Text)
    if n then
        core.save.cps = math.max(n, 1)
        cpsI.Text = tostring(core.save.cps)
        core:saveData()
    else
        cpsI.Text = tostring(core.save.cps)
    end
end)

local crashF = Instance.new("Frame", sPage)
crashF.Size, crashF.BackgroundTransparency = UDim2.new(1, -10, 0, 40), 1

local crashL = Instance.new("TextLabel", crashF)
crashL.Size, crashL.BackgroundTransparency, crashL.Text, crashL.TextColor3, crashL.Font, crashL.TextSize, crashL.TextXAlignment = UDim2.new(0.5, 0, 1, 0), 1, "Crash Mode", theme.text, font, 14, Enum.TextXAlignment.Left

local crashB = Instance.new("TextButton", crashF)
crashB.Size, crashB.Position, crashB.BackgroundColor3, crashB.Text, crashB.TextColor3, crashB.Font, crashB.TextSize = UDim2.new(0, 80, 0, 30), UDim2.new(1, -80, 0.5, -15), theme.surfaceHigh, "OFF", theme.red, font, 14
addStroke(crashB)

local function syncCrash()
    crashB.Text = core.save.crash and "ON" or "OFF"
    crashB.TextColor3 = core.save.crash and theme.green or theme.red
end
syncCrash()

crashB.MouseButton1Click:Connect(function()
    core.save.crash = not core.save.crash
    syncCrash()
    core:saveData()
end)

--// Logic Integration
local StartTime = tick()
local NameCache = {}

local function getName(id, sType)
    if cache[id] then return cache[id] end
    local n = nil
    pcall(function()
        local iType = Enum.InfoType.Asset
        if sType == "Product" then iType = Enum.InfoType.Product
        elseif sType == "Gamepass" then iType = Enum.InfoType.GamePass end
        local info = MarketplaceService:GetProductInfo(id, iType)
        if info and info.Name then n = info.Name end
    end)
    if n then cache[id] = n end
    return n or "Unknown Asset"
end

LogService.MessageOut:Connect(function(msg, mType)
    if tick() - start < 0.5 then return end
    local low = msg:lower()
    if low == "destruct" or low == "/destruct" or low == "!destruct" then
        gui:Destroy()
        return
    end
    addLog(msg, mType)
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, id)
    if p == lp or p == lp.UserId then newEvent("Product", id, "Product", getName(id, "Product")) end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, id)
    if p == lp or p == lp.UserId then newEvent("Gamepass", id, "Gamepass", getName(id, "Gamepass")) end
end)

MarketplaceService.PromptPurchaseFinished:Connect(function(p, id)
    if p == lp or p == lp.UserId then newEvent("Purchase", id, "Purchase", getName(id, "Purchase")) end
end)

UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Delete then main.Visible = not main.Visible end
end)

core:switchTab("Home")
task.spawn(function()
    local watermark = [[
  ____        _                _                        
 / ___|  ___| |_   ___      _(_) __ _   __  ___   _ ____
 \___ \ / _ \ | | | \ \ /\ / / |/ _` | \ \/ / | | |_  /
  ___) |  __/ | |_| |\ V  V /| | (_| |_ >  <| |_| |/ / 
 |____/ \___|_|\__,_| \_/\_/ |_|\__,_(_)_/\_\\__, /___|
                                              |___/    
seluwia.xyz | script made by seluwia
]]
    print(watermark)
    for line in watermark:gmatch("[^\r\n]+") do 
        addLog(line, Enum.MessageType.MessageInfo) 
    end
end)
