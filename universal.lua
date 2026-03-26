local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local VoraLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/juansyahrz17-prog/vorahub/refs/heads/main/lib.lua"))()
local Window = VoraLib:CreateWindow({
    Title = "VoraHub Universal",
    LoadingTitle = "VoraHub Universal",
    LoadingSubtitle = "All Maps Utility",
    ConfigurationSaving = { Enabled = false },
})

local MainTab = Window:CreateTab({ Name = "Main", Icon = "home" })
local PlayerTab = Window:CreateTab({ Name = "Player", Icon = "user" })
local TeleportTab = Window:CreateTab({ Name = "Teleport", Icon = "gps" })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "settings" })

local State = {
    Fly = false,
    Noclip = false,
    Freeze = false,
    Invisible = false,
    Freecam = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    AntiAFK = false,
    FullBright = false,
    ClickTP = false,
    Spin = false,
    SpinSpeed = 45,
    ESP = false,
    SolidWorld = false,
    AntiRagdoll = false,
    Bhop = false,
}

local Connections = {}
local flyBV, flyBG
local flyControl = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local freecamControl = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local freecamPos, freecamRot = nil, Vector2.new()
local freecamTargetRot = Vector2.new()
local freecamVel = Vector3.zero
local preFreecam = {
    WalkSpeed = nil,
    JumpPower = nil,
    AutoRotate = nil,
    Anchored = nil,
    CameraType = nil,
    MouseBehavior = nil,
    MouseIconEnabled = nil,
}
local espFolder = Instance.new("Folder")
espFolder.Name = "VoraUniversalESP"
espFolder.Parent = Workspace
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHum()
    return getChar():FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    return getChar():FindFirstChild("HumanoidRootPart")
end

local function setConn(name, conn)
    if Connections[name] then
        Connections[name]:Disconnect()
    end
    Connections[name] = conn
end

local function clearConn(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

local function applyWalkSpeed(v)
    State.WalkSpeed = v
    local hum = getHum()
    if hum then hum.WalkSpeed = v end
end

local function applyJumpPower(v)
    State.JumpPower = v
    local hum = getHum()
    if hum then hum.JumpPower = v end
end

local function applyAntiRagdoll(on)
    State.AntiRagdoll = on
    local hum = getHum()
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not on)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not on)
        end)
    end
end

local function toggleNoclip(on)
    State.Noclip = on
    clearConn("noclip")
    if on then
        setConn("noclip", RunService.Stepped:Connect(function()
            for _, obj in ipairs(getChar():GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanCollide = false
                end
            end
        end))
    end
end

local function toggleFreeze(on)
    State.Freeze = on
    local root = getRoot()
    if root then root.Anchored = on end
end

local function toggleInvisible(on)
    State.Invisible = on
    for _, obj in ipairs(getChar():GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            obj.LocalTransparencyModifier = on and 1 or 0
        end
    end
end

local function toggleFullBright(on)
    State.FullBright = on
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end

local function toggleSolidWorld(on)
    State.SolidWorld = on
    clearConn("solidWorld")
    clearConn("solidWorldLoop")

    local function makeSolid(part)
        if not part or not part:IsA("BasePart") then return end
        local myChar = LocalPlayer.Character
        if myChar and part:IsDescendantOf(myChar) then return end
        if part.Name == "HumanoidRootPart" then return end

        -- Force map objects to be physically solid.
        part.CanCollide = true
        part.CanTouch = true
    end

    local function applySolid()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                makeSolid(obj)
            end
        end
    end

    if on then
        applySolid()
        setConn("solidWorld", Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("BasePart") then
                makeSolid(obj)
            end
        end))

        -- Some games repeatedly set CanCollide=false; enforce in loop so it stays solid.
        setConn("solidWorldLoop", RunService.Heartbeat:Connect(function()
            if not State.SolidWorld then return end
            applySolid()
        end))
    end
end

local function toggleFly(on)
    State.Fly = on
    local root = getRoot()
    if not root then return end

    clearConn("fly")
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end

    if on then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBV.Parent = root

        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBG.P = 1e5
        flyBG.Parent = root

        setConn("fly", RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            if not cam or not flyBV or not flyBG then return end
            local dir =
                (cam.CFrame.LookVector * (flyControl.F - flyControl.B)) +
                (cam.CFrame.RightVector * (flyControl.R - flyControl.L)) +
                Vector3.new(0, flyControl.U - flyControl.D, 0)
            if dir.Magnitude > 0 then
                dir = dir.Unit
            end
            flyBV.Velocity = dir * math.max(30, State.WalkSpeed)
            flyBG.CFrame = cam.CFrame
        end))
    end
end

local function toggleFreecam(on)
    State.Freecam = on
    clearConn("freecam")
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local hum = getHum()
    local root = getRoot()
    if on then
        preFreecam.WalkSpeed = hum and hum.WalkSpeed or State.WalkSpeed
        preFreecam.JumpPower = hum and hum.JumpPower or State.JumpPower
        preFreecam.AutoRotate = hum and hum.AutoRotate
        preFreecam.Anchored = root and root.Anchored or false
        preFreecam.CameraType = cam.CameraType
        preFreecam.MouseBehavior = UserInputService.MouseBehavior
        preFreecam.MouseIconEnabled = UserInputService.MouseIconEnabled

        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.AutoRotate = false
        end
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.Anchored = true
        end

        freecamPos = cam.CFrame.Position
        local x, y = cam.CFrame:ToEulerAnglesYXZ()
        freecamRot = Vector2.new(x, y)
        freecamTargetRot = freecamRot
        freecamVel = Vector3.zero
        cam.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false

        setConn("freecam", RunService.RenderStepped:Connect(function(dt)
            local speed = math.clamp(State.WalkSpeed / 10, 1, 20)
            local rotSmooth = math.clamp(dt * 14, 0, 1)
            local moveSmooth = math.clamp(dt * 10, 0, 1)
            freecamRot = freecamRot:Lerp(freecamTargetRot, rotSmooth)

            local maxPitch = math.rad(89)
            if freecamRot.X > maxPitch then freecamRot = Vector2.new(maxPitch, freecamRot.Y) end
            if freecamRot.X < -maxPitch then freecamRot = Vector2.new(-maxPitch, freecamRot.Y) end

            local look = CFrame.fromEulerAnglesYXZ(freecamRot.X, freecamRot.Y, 0)
            local move =
                (look.LookVector * (freecamControl.F - freecamControl.B)) +
                (look.RightVector * (freecamControl.R - freecamControl.L)) +
                Vector3.new(0, freecamControl.U - freecamControl.D, 0)

            if move.Magnitude > 0 then
                move = move.Unit * speed * 60 * dt
            end

            freecamVel = freecamVel:Lerp(move, moveSmooth)
            freecamPos += freecamVel
            cam.CFrame = CFrame.new(freecamPos) * look
        end))
    else
        freecamVel = Vector3.zero
        cam.CameraType = preFreecam.CameraType or Enum.CameraType.Custom
        UserInputService.MouseBehavior = preFreecam.MouseBehavior or Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = (preFreecam.MouseIconEnabled ~= false)
        if root then
            root.Anchored = preFreecam.Anchored == true
        end
        if hum then
            hum.WalkSpeed = preFreecam.WalkSpeed or State.WalkSpeed
            hum.JumpPower = preFreecam.JumpPower or State.JumpPower
            hum.AutoRotate = (preFreecam.AutoRotate ~= false)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.W then flyControl.F = 1 end
    if input.KeyCode == Enum.KeyCode.S then flyControl.B = 1 end
    if input.KeyCode == Enum.KeyCode.A then flyControl.L = 1 end
    if input.KeyCode == Enum.KeyCode.D then flyControl.R = 1 end
    if input.KeyCode == Enum.KeyCode.Space then flyControl.U = 1 end
    if input.KeyCode == Enum.KeyCode.LeftControl then flyControl.D = 1 end

    if input.KeyCode == Enum.KeyCode.I then freecamControl.F = 1 end
    if input.KeyCode == Enum.KeyCode.K then freecamControl.B = 1 end
    if input.KeyCode == Enum.KeyCode.J then freecamControl.L = 1 end
    if input.KeyCode == Enum.KeyCode.L then freecamControl.R = 1 end
    if input.KeyCode == Enum.KeyCode.E then freecamControl.U = 1 end
    if input.KeyCode == Enum.KeyCode.Q then freecamControl.D = 1 end
    if input.KeyCode == Enum.KeyCode.W then freecamControl.F = 1 end
    if input.KeyCode == Enum.KeyCode.S then freecamControl.B = 1 end
    if input.KeyCode == Enum.KeyCode.A then freecamControl.L = 1 end
    if input.KeyCode == Enum.KeyCode.D then freecamControl.R = 1 end
    if input.KeyCode == Enum.KeyCode.Space then freecamControl.U = 1 end
    if input.KeyCode == Enum.KeyCode.LeftControl then freecamControl.D = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyControl.F = 0 end
    if input.KeyCode == Enum.KeyCode.S then flyControl.B = 0 end
    if input.KeyCode == Enum.KeyCode.A then flyControl.L = 0 end
    if input.KeyCode == Enum.KeyCode.D then flyControl.R = 0 end
    if input.KeyCode == Enum.KeyCode.Space then flyControl.U = 0 end
    if input.KeyCode == Enum.KeyCode.LeftControl then flyControl.D = 0 end

    if input.KeyCode == Enum.KeyCode.I then freecamControl.F = 0 end
    if input.KeyCode == Enum.KeyCode.K then freecamControl.B = 0 end
    if input.KeyCode == Enum.KeyCode.J then freecamControl.L = 0 end
    if input.KeyCode == Enum.KeyCode.L then freecamControl.R = 0 end
    if input.KeyCode == Enum.KeyCode.E then freecamControl.U = 0 end
    if input.KeyCode == Enum.KeyCode.Q then freecamControl.D = 0 end
    if input.KeyCode == Enum.KeyCode.W then freecamControl.F = 0 end
    if input.KeyCode == Enum.KeyCode.S then freecamControl.B = 0 end
    if input.KeyCode == Enum.KeyCode.A then freecamControl.L = 0 end
    if input.KeyCode == Enum.KeyCode.D then freecamControl.R = 0 end
    if input.KeyCode == Enum.KeyCode.Space then freecamControl.U = 0 end
    if input.KeyCode == Enum.KeyCode.LeftControl then freecamControl.D = 0 end
end)

UserInputService.InputChanged:Connect(function(input, gp)
    if not State.Freecam then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        freecamTargetRot += Vector2.new(-input.Delta.Y, -input.Delta.X) * 0.0025
    end
end)

local function flingPulse()
    local root = getRoot()
    if not root then return end
    local av = Instance.new("BodyAngularVelocity")
    av.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    av.AngularVelocity = Vector3.new(0, 99999, 0)
    av.P = 12500
    av.Parent = root
    task.wait(0.35)
    av:Destroy()
end

local function toggleSpin(on)
    State.Spin = on
    clearConn("spin")
    if on then
        setConn("spin", RunService.Heartbeat:Connect(function(dt)
            local root = getRoot()
            if root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed) * dt, 0)
            end
        end))
    end
end

local function clearESP()
    for _, d in ipairs(espFolder:GetChildren()) do
        d:Destroy()
    end
end

local function toggleESP(on)
    State.ESP = on
    clearConn("esp")
    clearESP()
    if on then
        setConn("esp", RunService.RenderStepped:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local name = "ESP_" .. plr.Name
                    local box = espFolder:FindFirstChild(name)
                    if not box then
                        box = Instance.new("BoxHandleAdornment")
                        box.Name = name
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Size = Vector3.new(4, 6, 2)
                        box.Transparency = 0.45
                        box.Color3 = Color3.fromRGB(255, 70, 70)
                        box.Parent = espFolder
                    end
                    box.Adornee = plr.Character.HumanoidRootPart
                end
            end
        end))
    end
end

-- Main tab
MainTab:CreateSection({ Name = "Universal Utility" })
MainTab:CreateParagraph({
    Title = "Info",
    Desc = "Fly: WASD + Space/Ctrl | Freecam: WASD atau IJKL + Space/Ctrl (Q/E) + Mouse"
})

MainTab:CreateToggle({
    Name = "Fly",
    Default = false,
    Callback = toggleFly
})

MainTab:CreateToggle({
    Name = "Freecam",
    Default = false,
    Callback = toggleFreecam
})

MainTab:CreateButton({
    Name = "Fling (Pulse)",
    Callback = flingPulse
})

MainTab:CreateToggle({
    Name = "Click Teleport (Ctrl + Click)",
    Default = false,
    Callback = function(v)
        State.ClickTP = v
    end
})

MainTab:CreateToggle({
    Name = "Bunny Hop",
    Default = false,
    Callback = function(v)
        State.Bhop = v
    end
})

MainTab:CreateInput({
    Name = "Camera FOV",
    SideLabel = "Default 70",
    Placeholder = "e.g. 90",
    Default = "70",
    Callback = function(v)
        local n = tonumber(v)
        local cam = Workspace.CurrentCamera
        if n and cam then
            cam.FieldOfView = math.clamp(n, 20, 120)
        end
    end
})

-- Player tab
PlayerTab:CreateSection({ Name = "Character" })

PlayerTab:CreateToggle({
    Name = "Noclip",
    Default = false,
    Callback = toggleNoclip
})

PlayerTab:CreateToggle({
    Name = "Freeze",
    Default = false,
    Callback = toggleFreeze
})

PlayerTab:CreateToggle({
    Name = "Invisible",
    Default = false,
    Callback = toggleInvisible
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v)
        State.InfiniteJump = v
    end
})

PlayerTab:CreateToggle({
    Name = "Anti Ragdoll",
    Default = false,
    Callback = function(v)
        applyAntiRagdoll(v)
    end
})

PlayerTab:CreateToggle({
    Name = "Spin",
    Default = false,
    Callback = toggleSpin
})

PlayerTab:CreateInput({
    Name = "WalkSpeed",
    SideLabel = "Default 16",
    Placeholder = "e.g. 32",
    Default = "16",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then applyWalkSpeed(n) end
    end
})

PlayerTab:CreateInput({
    Name = "JumpPower",
    SideLabel = "Default 50",
    Placeholder = "e.g. 75",
    Default = "50",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then applyJumpPower(n) end
    end
})

PlayerTab:CreateInput({
    Name = "Spin Speed",
    SideLabel = "Default 45",
    Placeholder = "e.g. 120",
    Default = "45",
    Callback = function(v)
        local n = tonumber(v)
        if n then
            State.SpinSpeed = n
        end
    end
})

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end
})

-- Teleport tab
TeleportTab:CreateSection({ Name = "Teleport" })

local tpCoordsText = ""
TeleportTab:CreateInput({
    Name = "Coordinates (x,y,z)",
    SideLabel = "Teleport position",
    Placeholder = "0, 10, 0",
    Default = "",
    Callback = function(v)
        tpCoordsText = v or ""
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Coordinates",
    Callback = function()
        local root = getRoot()
        if not root then return end
        local x, y, z = tpCoordsText:match("^%s*(-?[%d%.]+)%s*,%s*(-?[%d%.]+)%s*,%s*(-?[%d%.]+)%s*$")
        if x and y and z then
            root.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end
})

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    table.sort(names)
    if #names == 0 then
        names = {"No Players"}
    end
    return names
end

local function findPlayerByText(text)
    if not text or text == "" then return nil end
    local q = string.lower(text)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local uname = string.lower(p.Name)
            local dname = string.lower(p.DisplayName)
            if uname == q or dname == q or uname:find(q, 1, true) or dname:find(q, 1, true) then
                return p
            end
        end
    end
    return nil
end

local selectedPlayer = nil
local playerSearchText = ""
local function getTopPlayer()
    local names = getPlayerNames()
    if #names == 0 or names[1] == "No Players" then return nil end
    return Players:FindFirstChild(names[1])
end

local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Items = getPlayerNames(),
    Default = getPlayerNames()[1],
    Callback = function(v)
        selectedPlayer = v
    end
})

TeleportTab:CreateInput({
    Name = "TP Player (Name/DisplayName)",
    SideLabel = "Manual search",
    Placeholder = "e.g. nebar",
    Default = "",
    Callback = function(v)
        playerSearchText = v or ""
    end
})

TeleportTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        local names = getPlayerNames()
        if playerDropdown and playerDropdown.Refresh then
            playerDropdown:Refresh(names)
        end
        if not selectedPlayer or selectedPlayer == "No Players" then
            selectedPlayer = names[1]
        end
    end
})

TeleportTab:CreateButton({
    Name = "TP to Player",
    Callback = function()
        local target = nil
        if selectedPlayer and selectedPlayer ~= "No Players" then
            target = Players:FindFirstChild(selectedPlayer)
        end
        if not target then
            target = findPlayerByText(playerSearchText)
        end
        if not target then
            target = getTopPlayer()
        end
        local root = getRoot()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

TeleportTab:CreateButton({
    Name = "TP Top Player",
    Callback = function()
        local target = getTopPlayer()
        local root = getRoot()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

TeleportTab:CreateButton({
    Name = "Copy My Position",
    Callback = function()
        local root = getRoot()
        if root and setclipboard then
            local p = root.Position
            setclipboard(("%0.3f, %0.3f, %0.3f"):format(p.X, p.Y, p.Z))
        end
    end
})

-- Misc tab
MiscTab:CreateSection({ Name = "Visual" })
MiscTab:CreateToggle({
    Name = "FullBright",
    Default = false,
    Callback = toggleFullBright
})
MiscTab:CreateToggle({
    Name = "ESP Players",
    Default = false,
    Callback = toggleESP
})
MiscTab:CreateToggle({
    Name = "Solid World (Anti Nembus Model)",
    Default = false,
    Callback = toggleSolidWorld
})

MiscTab:CreateSection({ Name = "Server" })
MiscTab:CreateToggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(v)
        State.AntiAFK = v
    end
})
MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
        task.wait(1)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

MiscTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        for k, conn in pairs(Connections) do
            if conn then conn:Disconnect() end
            Connections[k] = nil
        end
        toggleFly(false)
        toggleFreecam(false)
        toggleNoclip(false)
        toggleFreeze(false)
        toggleInvisible(false)
        toggleSpin(false)
        toggleESP(false)
        toggleFullBright(false)
        toggleSolidWorld(false)
        VoraLib:Destroy()
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyWalkSpeed(State.WalkSpeed)
    applyJumpPower(State.JumpPower)
    if State.AntiRagdoll then applyAntiRagdoll(true) end
    if State.Noclip then toggleNoclip(true) end
    if State.Freeze then toggleFreeze(true) end
    if State.Invisible then toggleInvisible(true) end
    if State.Spin then toggleSpin(true) end
end)

setConn("infiniteJump", UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

setConn("clickTP", UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not State.ClickTP then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
        local root = getRoot()
        if mouse and mouse.Hit and root then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end))

setConn("antiAFK", LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

setConn("bhop", RunService.Heartbeat:Connect(function()
    if not State.Bhop then return end
    local hum = getHum()
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

applyWalkSpeed(16)
applyJumpPower(50)
