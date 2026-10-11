local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer

local NAME = "artihub|evade"
local ICON = "zap"
local ACCENT = Color3.fromRGB(140, 90, 255)
local ACCENT2 = Color3.fromRGB(0, 200, 255)
local MENU_KEY = Enum.KeyCode.RightControl

local alive = true
local conns = {}
local function bind(sig, fn)
    local c = sig:Connect(fn)
    table.insert(conns, c)
    return c
end

local function guiParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    return game:GetService("CoreGui")
end

local function getChar()
    local c = LP.Character
    return c, c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end

-- ================= THEME / WINDOW =================
WindUI:AddTheme({
    Name = "Arti",
    Accent = "#8c5aff",
    Dialog = "#12101c",
    Outline = "#8c5aff",
    Text = "#ffffff",
    Placeholder = "#8d86a8",
    Background = "#0d0b16",
    Button = "#241d3a",
    Icon = "#b9a2ff",
})
WindUI:SetTheme("Arti")

local Window = WindUI:CreateWindow({
    Title = NAME,
    Icon = ICON,
    Author = "by arti",
    Folder = "artihub_evade",
    Size = UDim2.fromOffset(580, 440),
    Transparent = true,
    Theme = "Arti",
    SideBarWidth = 180,
})

pcall(function()
    Window:EditOpenButton({
        Title = NAME,
        Icon = ICON,
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(ACCENT, ACCENT2),
        Draggable = true,
    })
end)
pcall(function() Window:Tag({ Title = "evade", Color = ACCENT }) end)
pcall(function() Window:SetToggleKey(MENU_KEY) end)

local function toggleMenu()
    pcall(function() Window:Toggle() end)
end

-- запасной вариант, если SetToggleKey не поддерживается версией WindUI
local hasToggleKey = pcall(function() assert(Window.SetToggleKey) end)
if not hasToggleKey then
    bind(UIS.InputBegan, function(i, gp)
        if not gp and i.KeyCode == MENU_KEY then toggleMenu() end
    end)
end

local MoveTab = Window:Tab({ Title = "Move", Icon = "move" })
local ThingsTab = Window:Tab({ Title = "Things", Icon = "box" })
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "wrench" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ================= WATERMARK =================
local wmGui = Instance.new("ScreenGui")
wmGui.Name = "ArtiUI"
wmGui.ResetOnSpawn = false
wmGui.IgnoreGuiInset = true
wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
wmGui.DisplayOrder = 999
wmGui.Parent = guiParent()

-- общая функция перетаскивания (мышь + тач)
local function makeDraggable(frame, onClick)
    local dragging, startInput, startPos, startMouse, moved = false, nil, nil, nil, false
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            startMouse = i.Position
            startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    if dragging and not moved and onClick then onClick() end
                    dragging = false
                end
            end)
        end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startMouse
            if d.Magnitude > 6 then moved = true end
            if moved then
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
end

local wm = Instance.new("Frame")
wm.Size = UDim2.fromOffset(340, 34)
wm.Position = UDim2.new(0, 14, 0, 14)
wm.BackgroundColor3 = Color3.fromRGB(13, 11, 22)
wm.BackgroundTransparency = 0.15
wm.BorderSizePixel = 0
wm.Parent = wmGui
Instance.new("UICorner", wm).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", wm)
stroke.Thickness = 1.8
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local sg = Instance.new("UIGradient", stroke)
sg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT),
    ColorSequenceKeypoint.new(0.5, ACCENT2),
    ColorSequenceKeypoint.new(1, ACCENT),
})

local wmIcon = Instance.new("TextLabel", wm)
wmIcon.BackgroundTransparency = 1
wmIcon.Size = UDim2.fromOffset(30, 34)
wmIcon.Position = UDim2.fromOffset(6, 0)
wmIcon.Font = Enum.Font.GothamBlack
wmIcon.TextSize = 18
wmIcon.Text = "⚡"
wmIcon.TextColor3 = ACCENT2

local label = Instance.new("TextLabel", wm)
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, -44, 1, 0)
label.Position = UDim2.new(0, 38, 0, 0)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextColor3 = Color3.new(1, 1, 1)
label.RichText = true
label.Text = NAME
makeDraggable(wm)

local rot, frames, acc = 0, 0, 0
bind(RunService.RenderStepped, function(dt)
    rot = (rot + dt * 90) % 360
    sg.Rotation = rot
    frames += 1
    acc += dt
    if acc >= 0.5 then
        local fps = math.floor(frames / acc + 0.5)
        frames, acc = 0, 0
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        label.Text = string.format(
            '<font color="#b9a2ff">arti</font>hub<font color="#8d86a8"> | </font>evade<font color="#8d86a8"> | </font>%d fps<font color="#8d86a8"> | </font>%d ms<font color="#8d86a8"> | </font>%s',
            fps, ping, os.date("%H:%M"))
    end
end)

-- ================= КНОПКА МЕНЮ (для телефона) =================
local menuBtn = Instance.new("Frame")
menuBtn.Name = "MenuButton"
menuBtn.Size = UDim2.fromOffset(52, 52)
menuBtn.Position = UDim2.new(1, -70, 0.5, -26)
menuBtn.BackgroundColor3 = Color3.fromRGB(13, 11, 22)
menuBtn.BackgroundTransparency = 0.1
menuBtn.BorderSizePixel = 0
menuBtn.Active = true
menuBtn.Parent = wmGui
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(1, 0)

local mbStroke = Instance.new("UIStroke", menuBtn)
mbStroke.Thickness = 2.4
mbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local mbGrad = Instance.new("UIGradient", mbStroke)
mbGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT),
    ColorSequenceKeypoint.new(0.5, ACCENT2),
    ColorSequenceKeypoint.new(1, ACCENT),
})

local mbText = Instance.new("TextLabel", menuBtn)
mbText.BackgroundTransparency = 1
mbText.Size = UDim2.fromScale(1, 1)
mbText.Font = Enum.Font.GothamBlack
mbText.TextSize = 26
mbText.Text = "⚡"
mbText.TextColor3 = Color3.new(1, 1, 1)
makeDraggable(menuBtn, toggleMenu)

bind(RunService.RenderStepped, function() mbGrad.Rotation = rot end)

-- ================= MOVE: BHOP =================
local bhopHold, bhopToggle, bhopKeyHeld = false, false, false
local bhopKey = Enum.KeyCode.X

bind(RunService.RenderStepped, function()
    local _, hum = getChar()
    if not hum or hum.Health <= 0 then return end
    local active = bhopToggle or (bhopHold and (UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump)) or bhopKeyHeld
    if active and hum.FloorMaterial ~= Enum.Material.Air then
        hum.Jump = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

bind(UIS.InputBegan, function(i, gp)
    if not gp and i.KeyCode == bhopKey then bhopKeyHeld = true end
end)
bind(UIS.InputEnded, function(i)
    if i.KeyCode == bhopKey then bhopKeyHeld = false end
end)

MoveTab:Section({ Title = "Bhop" })
MoveTab:Toggle({ Title = "Bhop Hold", Desc = "Bhop while holding Space / jump", Value = false,
    Callback = function(v) bhopHold = v end })
MoveTab:Toggle({ Title = "Bhop Toggle", Desc = "Always-on bhop", Value = false,
    Callback = function(v) bhopToggle = v end })
MoveTab:Keybind({ Title = "Bhop Key", Desc = "Bhop while holding this key", Value = "X",
    Callback = function(v)
        local ok, key = pcall(function() return Enum.KeyCode[v] end)
        if ok and key then bhopKey = key end
    end })

-- ================= MOVE: FLY =================
local flyOn, flySpeed = false, 50
local bv, bgyro

local function stopFly()
    if bv then bv:Destroy() bv = nil end
    if bgyro then bgyro:Destroy() bgyro = nil end
    local _, hum = getChar()
    if hum then hum.PlatformStand = false end
end

bind(RunService.RenderStepped, function()
    local _, hum, root = getChar()
    if not flyOn or not hum or not root or hum.Health <= 0 then
        if bv or bgyro then stopFly() end
        return
    end
    if not bv or bv.Parent ~= root then
        stopFly()
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = root
        bgyro = Instance.new("BodyGyro")
        bgyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bgyro.P = 1e4
        bgyro.Parent = root
    end
    hum.PlatformStand = true
    local cam = workspace.CurrentCamera
    bgyro.CFrame = cam.CFrame
    local dir = hum.MoveDirection
    local vel = dir * flySpeed
    -- вертикаль по взгляду камеры (работает и на телефоне)
    local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
    if flatLook.Magnitude > 0.01 and dir.Magnitude > 0.01 then
        local fwd = dir:Dot(flatLook.Unit)
        vel += Vector3.new(0, cam.CFrame.LookVector.Y * fwd * flySpeed, 0)
    end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, flySpeed, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0, flySpeed, 0) end
    bv.Velocity = vel
end)

MoveTab:Section({ Title = "Fly" })
MoveTab:Toggle({ Title = "Fly", Desc = "PC: Space/Ctrl. Mobile: смотри вверх/вниз и иди вперёд", Value = false,
    Callback = function(v) flyOn = v if not v then stopFly() end end })
MoveTab:Slider({ Title = "Fly Speed", Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(v) flySpeed = v end })

-- ================= MOVE: BOOSTS =================
local easyTrimp, trimpMult = false, 1.25
bind(UIS.JumpRequest, function()
    if not easyTrimp then return end
    local _, hum, root = getChar()
    if not hum or not root or hum.MoveDirection.Magnitude < 0.1 then return end
    task.defer(function()
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * trimpMult, v.Y, v.Z * trimpMult)
    end)
end)

local speedOn, speedVal = false, 30
local jumpOn, jumpVal = false, 60

-- скорость через CFrame: игра не может её сбросить
bind(RunService.Heartbeat, function(dt)
    local _, hum, root = getChar()
    if not hum or not root or hum.Health <= 0 then return end
    if speedOn and not flyOn and hum.MoveDirection.Magnitude > 0 then
        local extra = math.max(speedVal - 16, 0)
        root.CFrame = root.CFrame + hum.MoveDirection * extra * dt
    end
end)

-- прыжок через импульс: игра не может сбросить JumpPower
bind(UIS.JumpRequest, function()
    if not jumpOn then return end
    local _, hum, root = getChar()
    if not hum or not root then return end
    if hum.FloorMaterial ~= Enum.Material.Air then
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X, jumpVal, v.Z)
    end
end)

MoveTab:Section({ Title = "Boosts" })
MoveTab:Toggle({ Title = "Easy Trimp", Desc = "Extra horizontal speed on jump", Value = false,
    Callback = function(v) easyTrimp = v end })
MoveTab:Slider({ Title = "Trimp Power", Value = { Min = 100, Max = 200, Default = 125 },
    Callback = function(v) trimpMult = v / 100 end })
MoveTab:Toggle({ Title = "Speed Boost", Value = false, Callback = function(v) speedOn = v end })
MoveTab:Slider({ Title = "Speed Value", Value = { Min = 16, Max = 150, Default = 30 },
    Callback = function(v) speedVal = v end })
MoveTab:Toggle({ Title = "Jump Boost", Value = false, Callback = function(v) jumpOn = v end })
MoveTab:Slider({ Title = "Jump Value", Value = { Min = 30, Max = 200, Default = 60 },
    Callback = function(v) jumpVal = v end })

-- ================= MOVE: EXTRA =================
local noclip, infJump, spinOn = false, false, false
local spinSpeed = 10

bind(RunService.Stepped, function()
    local c, _, root = getChar()
    if noclip and c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    if spinOn and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
    end
end)

bind(UIS.JumpRequest, function()
    if not infJump then return end
    local _, hum = getChar()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

MoveTab:Section({ Title = "Extra" })
MoveTab:Toggle({ Title = "Noclip", Value = false, Callback = function(v) noclip = v end })
MoveTab:Toggle({ Title = "Infinite Jump", Value = false, Callback = function(v) infJump = v end })
MoveTab:Toggle({ Title = "Spin", Value = false, Callback = function(v) spinOn = v end })
MoveTab:Slider({ Title = "Spin Speed", Value = { Min = 1, Max = 40, Default = 10 },
    Callback = function(v) spinSpeed = v end })
MoveTab:Slider({ Title = "Gravity", Value = { Min = 20, Max = 196, Default = math.floor(workspace.Gravity) },
    Callback = function(v) workspace.Gravity = v end })

-- ================= ESP =================
local function applyESP(model, color, tag, text)
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end
    if not model:FindFirstChild(tag) then
        local h = Instance.new("Highlight")
        h.Name = tag
        h.FillColor = color
        h.OutlineColor = Color3.new(1, 1, 1)
        h.FillTransparency = 0.5
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = model
    end
    local bb = model:FindFirstChild(tag .. "_Tag")
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Name = tag .. "_Tag"
        bb.Adornee = root
        bb.Size = UDim2.fromOffset(160, 36)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local t = Instance.new("TextLabel", bb)
        t.Name = "T"
        t.Size = UDim2.fromScale(1, 1)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamBold
        t.TextSize = 13
        t.TextColor3 = color
        t.TextStrokeTransparency = 0.4
        bb.Parent = model
    end
    local _, _, myRoot = getChar()
    local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
    bb.T.Text = string.format("%s\n[%d studs]", text, dist)
end

local function clearTag(tag)
    for _, d in ipairs(workspace:GetDescendants()) do
        if d.Name == tag or d.Name == tag .. "_Tag" then d:Destroy() end
    end
end

local function ownerOf(m)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == m then return p end
    end
end

local espPlayers, espBots, botAlert = false, false, false
local alertDist = 60
local lastAlert = 0

local function getGameFolder()
    local g = workspace:FindFirstChild("Game")
    return g and g:FindFirstChild("Players")
end

task.spawn(function()
    while alive and task.wait(0.25) do
        if espPlayers then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    applyESP(p.Character, Color3.fromRGB(0, 255, 120), "ESP_Player", p.DisplayName)
                end
            end
        end
        local folder = getGameFolder()
        if (espBots or botAlert) and folder then
            local _, _, myRoot = getChar()
            for _, m in ipairs(folder:GetChildren()) do
                if m:IsA("Model") and not ownerOf(m) and m:FindFirstChildOfClass("Humanoid") then
                    if espBots then
                        applyESP(m, Color3.fromRGB(255, 50, 50), "ESP_Bot", m.Name)
                    end
                    if botAlert and myRoot then
                        local r = m:FindFirstChild("HumanoidRootPart")
                        if r and (r.Position - myRoot.Position).Magnitude < alertDist and tick() - lastAlert > 3 then
                            lastAlert = tick()
                            pcall(function()
                                WindUI:Notify({ Title = "Nextbot рядом!", Content = m.Name, Duration = 2, Icon = "alert-triangle" })
                            end)
                        end
                    end
                end
            end
        end
    end
end)

ThingsTab:Section({ Title = "ESP" })
ThingsTab:Toggle({ Title = "ESP Players", Value = false,
    Callback = function(v) espPlayers = v if not v then clearTag("ESP_Player") end end })
ThingsTab:Toggle({ Title = "ESP Nextbot", Value = false,
    Callback = function(v) espBots = v if not v then clearTag("ESP_Bot") end end })
ThingsTab:Toggle({ Title = "Nextbot Alert", Desc = "Уведомление, если бот близко", Value = false,
    Callback = function(v) botAlert = v end })
ThingsTab:Slider({ Title = "Alert Distance", Value = { Min = 20, Max = 200, Default = 60 },
    Callback = function(v) alertDist = v end })

-- ================= EMOTE CHANGER (FE) =================
local Emotes = {
    ["Dance 1"] = "rbxassetid://507771019",
    ["Dance 2"] = "rbxassetid://507776043",
    ["Dance 3"] = "rbxassetid://507777268",
    ["Wave"]    = "rbxassetid://507770239",
    ["Point"]   = "rbxassetid://507770453",
    ["Cheer"]   = "rbxassetid://507770677",
    ["Laugh"]   = "rbxassetid://507770818",
}
local emoteNames = {}
for n in pairs(Emotes) do table.insert(emoteNames, n) end
table.sort(emoteNames)

local slotKeys = { Enum.KeyCode.Z, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B, Enum.KeyCode.N, Enum.KeyCode.M }
local slots = { "Dance 1", "Dance 2", "Dance 3", "Wave", "Cheer", "Laugh" }
local currentLabels, currentTrack = {}, nil

local function playEmote(name)
    local _, hum = getChar()
    if not hum or not Emotes[name] then return end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    if currentTrack then currentTrack:Stop() currentTrack = nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = Emotes[name]
    currentTrack = animator:LoadAnimation(anim)
    currentTrack.Priority = Enum.AnimationPriority.Action
    currentTrack:Play()
end

bind(UIS.InputBegan, function(i, gp)
    if gp then return end
    for idx, key in ipairs(slotKeys) do
        if i.KeyCode == key then playEmote(slots[idx]) end
    end
end)

ThingsTab:Section({ Title = "Emote Changer FE (Z C V B N M)" })
for i = 1, 6 do
    currentLabels[i] = ThingsTab:Paragraph({ Title = "Current Emote " .. i, Desc = slots[i] })
end
for i = 1, 6 do
    ThingsTab:Dropdown({
        Title = "Select Emote " .. i,
        Values = emoteNames,
        Value = slots[i],
        Callback = function(v)
            slots[i] = v
            pcall(function() currentLabels[i]:SetDesc(v) end)
        end,
    })
    ThingsTab:Button({ Title = "Play Emote " .. i, Callback = function() playEmote(slots[i]) end })
end
ThingsTab:Button({ Title = "Stop Emote", Callback = function()
    if currentTrack then currentTrack:Stop() currentTrack = nil end
end })

-- ================= COSMETICS =================
local headless, korblox, korbloxPart = false, false, nil

local function applyHeadless(on)
    local head = LP.Character and LP.Character:FindFirstChild("Head")
    if not head then return end
    head.Transparency = on and 1 or 0
    for _, d in ipairs(head:GetChildren()) do
        if d:IsA("Decal") then d.Transparency = on and 1 or 0 end
    end
end

local function applyKorblox(on)
    local c = LP.Character
    if not c then return end
    for _, n in ipairs({ "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" }) do
        local p = c:FindFirstChild(n)
        if p then p.Transparency = on and 1 or 0 end
    end
    if korbloxPart then korbloxPart:Destroy() korbloxPart = nil end
    if on then
        local anchor = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg")
        if not anchor then return end
        local p = Instance.new("Part")
        p.Name = "FakeKorblox"
        p.Size = Vector3.new(1, 2, 1)
        p.CanCollide = false
        p.Massless = true
        local m = Instance.new("SpecialMesh", p)
        m.MeshId = "rbxassetid://101851696"
        m.TextureId = "rbxassetid://101851254"
        p.CFrame = anchor.CFrame
        local w = Instance.new("WeldConstraint", p)
        w.Part0, w.Part1 = p, anchor
        p.Parent = c
        korbloxPart = p
    end
end

bind(LP.CharacterAdded, function()
    task.wait(1)
    if headless then applyHeadless(true) end
    if korblox then applyKorblox(true) end
end)

ThingsTab:Section({ Title = "Cosmetics (client-side)" })
ThingsTab:Toggle({ Title = "Fake Headless", Value = false,
    Callback = function(v) headless = v applyHeadless(v) end })
ThingsTab:Toggle({ Title = "Fake Korblox", Value = false,
    Callback = function(v) korblox = v applyKorblox(v) end })

ThingsTab:Section({ Title = "Extra" })
ThingsTab:Button({
    Title = "FeBoombox",
    Desc = "Loads external script",
    Callback = function()
        loadstring(game:HttpGet("https://darahub.pages.dev/api/script/obfuscated/Fe/Boomboxs/EvadeOverhaul-RelicsXYZ.lua"))()
    end,
})

-- ================= VISUAL =================
local origLight = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
}
local fullbright, noFog, fovOn, fovVal = false, false, false, 90

bind(RunService.RenderStepped, function()
    if fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    end
    if noFog then Lighting.FogEnd = 1e6 end
    if fovOn then workspace.CurrentCamera.FieldOfView = fovVal end
end)

VisualTab:Section({ Title = "Lighting" })
VisualTab:Toggle({ Title = "Fullbright", Value = false, Callback = function(v)
    fullbright = v
    if not v then
        Lighting.Brightness = origLight.Brightness
        Lighting.ClockTime = origLight.ClockTime
        Lighting.GlobalShadows = origLight.GlobalShadows
        Lighting.Ambient = origLight.Ambient
    end
end })
VisualTab:Toggle({ Title = "No Fog", Value = false, Callback = function(v)
    noFog = v
    if not v then Lighting.FogEnd = origLight.FogEnd end
end })
VisualTab:Section({ Title = "Camera" })
VisualTab:Toggle({ Title = "Custom FOV", Value = false, Callback = function(v)
    fovOn = v
    if not v then workspace.CurrentCamera.FieldOfView = 70 end
end })
VisualTab:Slider({ Title = "FOV", Value = { Min = 40, Max = 120, Default = 90 },
    Callback = function(v) fovVal = v end })

-- ================= MISC =================
local antiAfk = false
bind(LP.Idled, function()
    if antiAfk then
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

MiscTab:Section({ Title = "Utility" })
MiscTab:Toggle({ Title = "Anti AFK", Value = false, Callback = function(v) antiAfk = v end })
MiscTab:Button({ Title = "Reset Character", Callback = function()
    local _, hum = getChar()
    if hum then hum.Health = 0 end
end })
MiscTab:Button({ Title = "Rejoin", Callback = function()
    TeleportService:Teleport(game.PlaceId, LP)
end })
MiscTab:Button({ Title = "Copy Job ID", Callback = function()
    pcall(function() setclipboard(game.JobId) end)
    pcall(function() WindUI:Notify({ Title = NAME, Content = "Job ID copied", Duration = 2 }) end)
end })

-- ================= SETTINGS =================
SettingsTab:Section({ Title = "Interface" })
SettingsTab:Toggle({ Title = "Watermark", Value = true, Callback = function(v) wm.Visible = v end })
SettingsTab:Toggle({ Title = "Mobile Menu Button", Value = true, Callback = function(v) menuBtn.Visible = v end })
SettingsTab:Keybind({ Title = "Menu Key", Desc = "Default: Right Ctrl", Value = "RightControl",
    Callback = function(v)
        local ok, key = pcall(function() return Enum.KeyCode[v] end)
        if ok and key then
            MENU_KEY = key
            pcall(function() Window:SetToggleKey(key) end)
        end
    end })
SettingsTab:Button({ Title = "Unload Script", Desc = "Выключить всё и закрыть", Callback = function()
    alive = false
    flyOn, noclip, speedOn, jumpOn, spinOn = false, false, false, false, false
    espPlayers, espBots, botAlert = false, false, false
    stopFly()
    clearTag("ESP_Player")
    clearTag("ESP_Bot")
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    wmGui:Destroy()
    pcall(function() Window:Destroy() end)
end })

pcall(function()
    WindUI:Notify({ Title = NAME, Content = "Loaded. Menu: Right Ctrl / кнопка ⚡", Duration = 5, Icon = "check" })
end)
