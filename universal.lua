-- GAK PERLU DI OBFUS SOALNYA CUMAN UNIVERSAL

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
local TrollTab = Window:CreateTab({ Name = "Troll", Icon = "zap" })

local State = {
    Fly = false,
    Noclip = false,
    Freeze = false,
    Invisible = false,
    InvisibleVoidMode = true,
    InvisibleGodcloneMode = false,
    InvisibleTransparency = 0.45,
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
    FlySpeed = 50,
    FlingLoop = false,
    AutoAim = false,
    AutoAimSmooth = 0.2,
    AutoAimRange = 300,
    TrollShake = false,
    TrollOrbit = false,
    TrollChaosVel = false,
    TrollCamFov = false,
    InstantPrompt = false,
}

local Connections = {}
local flyBV, flyBG
local flyControl = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local flyMobileJumpTimer = 0
local trollOrbitAngle = 0
local preTrollCamFov = nil
local invIllusionCF = nil
local INV_VOID_CF = CFrame.new(1482376, 9124563, 1829345)
local invisibleVoidSnapUsesPreSim = false
local invGhostClone = nil
local preGodcloneCamSubject = nil
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

local function applyInstantPromptToOne(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if State.InstantPrompt then
        if prompt:GetAttribute("VoraInstant_Hold") == nil then
            prompt:SetAttribute("VoraInstant_Hold", prompt.HoldDuration)
            pcall(function()
                prompt:SetAttribute("VoraInstant_GPHold", prompt.GamepadHoldDuration)
            end)
        end
        prompt.HoldDuration = 0
        pcall(function()
            prompt.GamepadHoldDuration = 0
        end)
    else
        local h = prompt:GetAttribute("VoraInstant_Hold")
        local gh = prompt:GetAttribute("VoraInstant_GPHold")
        if typeof(h) == "number" then
            prompt.HoldDuration = h
        end
        pcall(function()
            if typeof(gh) == "number" then
                prompt.GamepadHoldDuration = gh
            end
        end)
        prompt:SetAttribute("VoraInstant_Hold", nil)
        prompt:SetAttribute("VoraInstant_GPHold", nil)
    end
end

local function sweepInstantPrompts()
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            applyInstantPromptToOne(d)
        end
    end
end

local function toggleInstantPrompt(on)
    State.InstantPrompt = on
    clearConn("instantPromptDesc")
    sweepInstantPrompts()
    if on then
        setConn("instantPromptDesc", Workspace.DescendantAdded:Connect(function(inst)
            if not State.InstantPrompt then return end
            if inst:IsA("ProximityPrompt") then
                applyInstantPromptToOne(inst)
            end
        end))
    end
end

local function applyInvisibleToCharacter(on)
    local char = LocalPlayer.Character
    if not char then return end

    local transp = 0
    if on then
        transp = math.clamp(State.InvisibleTransparency or 0.45, 0.05, 0.98)
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            if on then
                if hum:GetAttribute("VoraInv_NameDist") == nil then
                    hum:SetAttribute("VoraInv_NameDist", hum.NameDisplayDistance)
                end
                if hum:GetAttribute("VoraInv_HealthDist") == nil then
                    hum:SetAttribute("VoraInv_HealthDist", hum.HealthDisplayDistance)
                end
                hum.NameDisplayDistance = 0
                hum.HealthDisplayDistance = 0
            else
                local nd = hum:GetAttribute("VoraInv_NameDist")
                local hd = hum:GetAttribute("VoraInv_HealthDist")
                if typeof(nd) == "number" then hum.NameDisplayDistance = nd end
                if typeof(hd) == "number" then hum.HealthDisplayDistance = hd end
                hum:SetAttribute("VoraInv_NameDist", nil)
                hum:SetAttribute("VoraInv_HealthDist", nil)
            end
        end)
    end

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = transp
            obj.CastShadow = transp < 0.25
            pcall(function()
                if on then
                    if obj:GetAttribute("VoraInv_CanQuery") == nil then
                        obj:SetAttribute("VoraInv_CanQuery", obj.CanQuery)
                    end
                    if obj:GetAttribute("VoraInv_CanTouch") == nil then
                        obj:SetAttribute("VoraInv_CanTouch", obj.CanTouch)
                    end
                    obj.CanQuery = false
                    obj.CanTouch = false
                else
                    local cq = obj:GetAttribute("VoraInv_CanQuery")
                    local ct = obj:GetAttribute("VoraInv_CanTouch")
                    if cq ~= nil then obj.CanQuery = cq end
                    if ct ~= nil then obj.CanTouch = ct end
                    obj:SetAttribute("VoraInv_CanQuery", nil)
                    obj:SetAttribute("VoraInv_CanTouch", nil)
                end
            end)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if on then
                if obj:GetAttribute("VoraInv_Trans") == nil then
                    obj:SetAttribute("VoraInv_Trans", obj.Transparency)
                end
                local base = obj:GetAttribute("VoraInv_Trans")
                if typeof(base) == "number" then
                    obj.Transparency = math.clamp(base + transp * (1 - base), 0, 1)
                else
                    obj.Transparency = transp
                end
            else
                local tr = obj:GetAttribute("VoraInv_Trans")
                if typeof(tr) == "number" then
                    obj.Transparency = tr
                end
                obj:SetAttribute("VoraInv_Trans", nil)
            end
        elseif obj:IsA("ProximityPrompt") then
            if on then
                if obj:GetAttribute("VoraInv_Prompt") == nil then
                    obj:SetAttribute("VoraInv_Prompt", obj.Enabled)
                end
                obj.Enabled = false
            else
                local pe = obj:GetAttribute("VoraInv_Prompt")
                if typeof(pe) == "boolean" then
                    obj.Enabled = pe
                end
                obj:SetAttribute("VoraInv_Prompt", nil)
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            if on then
                if obj:GetAttribute("VoraInv_Enabled") == nil then
                    obj:SetAttribute("VoraInv_Enabled", obj.Enabled)
                end
                obj.Enabled = false
            else
                local en = obj:GetAttribute("VoraInv_Enabled")
                if typeof(en) == "boolean" then
                    obj.Enabled = en
                end
                obj:SetAttribute("VoraInv_Enabled", nil)
            end
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            if on then
                if obj:GetAttribute("VoraInv_GuiEn") == nil then
                    obj:SetAttribute("VoraInv_GuiEn", obj.Enabled)
                end
                obj.Enabled = false
            else
                local ge = obj:GetAttribute("VoraInv_GuiEn")
                if typeof(ge) == "boolean" then
                    obj.Enabled = ge
                end
                obj:SetAttribute("VoraInv_GuiEn", nil)
            end
        end
    end
end

local function snapInvisibleRootToVoid()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not invIllusionCF then return end
    local _, yv, _ = invIllusionCF:ToOrientation()
    root.CFrame = CFrame.new(INV_VOID_CF.Position) * CFrame.fromOrientation(0, yv, 0)
end

local function cleanupInvisibleGodclone()
    clearConn("invisibleGodcloneHeartbeat")
    clearConn("invisibleGodcloneStepped")
    local cam = Workspace.CurrentCamera
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.CanCollide = true
                    v.AssemblyLinearVelocity = Vector3.zero
                end)
            end
        end
        if invGhostClone and invGhostClone.Parent and invGhostClone:FindFirstChild("HumanoidRootPart") and root then
            pcall(function()
                root.CFrame = invGhostClone.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
            end)
        end
        if hum then
            pcall(function()
                hum.PlatformStand = false
                hum.AutoRotate = true
                hum:ChangeState(Enum.HumanoidStateType.Landed)
            end)
            if cam then
                if preGodcloneCamSubject ~= nil then
                    cam.CameraSubject = preGodcloneCamSubject
                else
                    cam.CameraSubject = hum
                end
            end
        end
    end
    preGodcloneCamSubject = nil
    if invGhostClone then
        invGhostClone:Destroy()
        invGhostClone = nil
    end
end

-- Gerak clone: PlatformStand di tubuh asli sering bikin MoveDirection nol — pakai WASD + kamera + fallback MoveDirection (mobile).
local function computeGodcloneGhostMove(realHum)
    if not realHum then return Vector3.zero, false end
    local x = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
    local z = (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
    if math.abs(x) + math.abs(z) > 1e-3 then
        return Vector3.new(x, 0, -z), true
    end
    local gpMove = nil
    pcall(function()
        local gp = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
        for _, st in ipairs(gp) do
            if st.KeyCode == Enum.KeyCode.Thumbstick1 and st.Position.Magnitude > 0.15 then
                gpMove = Vector3.new(st.Position.X, 0, -st.Position.Y)
                break
            end
        end
    end)
    if gpMove then
        return gpMove, true
    end
    local flat = Vector3.new(realHum.MoveDirection.X, 0, realHum.MoveDirection.Z)
    if flat.Magnitude > 0.06 then
        return flat.Unit, false
    end
    return Vector3.zero, false
end

-- Pola God Mode EFTB: clone semi-transparan + kamera ke clone; tubuh asli noclip & HRP di bawah clone.
local function wireInvisibleGodcloneHooks()
    clearConn("invisibleGodcloneHeartbeat")
    clearConn("invisibleGodcloneStepped")
    if invGhostClone then
        invGhostClone:Destroy()
        invGhostClone = nil
    end
    if not State.Invisible or not State.InvisibleGodcloneMode then return end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    char.Archivable = true
    invGhostClone = char:Clone()
    invGhostClone.Parent = Workspace
    char.Archivable = false

    local ghostTransp = math.clamp(State.InvisibleTransparency or 0.45, 0.2, 0.85)
    for _, v in ipairs(invGhostClone:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
            v.Transparency = ghostTransp
        end
    end

    local cam = Workspace.CurrentCamera
    if cam then
        preGodcloneCamSubject = cam.CameraSubject
        local gh = invGhostClone:FindFirstChildOfClass("Humanoid")
        if gh then
            cam.CameraSubject = gh
        end
    end

    pcall(function()
        hum.PlatformStand = true
        hum.AutoRotate = false
    end)

    setConn("invisibleGodcloneStepped", RunService.Stepped:Connect(function()
        if not State.Invisible or not State.InvisibleGodcloneMode then return end
        local ch = LocalPlayer.Character
        if not ch then return end
        for _, v in ipairs(ch:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end))

    setConn("invisibleGodcloneHeartbeat", RunService.Heartbeat:Connect(function()
        if not State.Invisible or not State.InvisibleGodcloneMode then return end
        local ch = LocalPlayer.Character
        if not ch or not invGhostClone or not invGhostClone.Parent then
            cleanupInvisibleGodclone()
            return
        end
        local r = ch:FindFirstChild("HumanoidRootPart")
        local h = ch:FindFirstChildOfClass("Humanoid")
        local gRoot = invGhostClone:FindFirstChild("HumanoidRootPart")
        local gh = invGhostClone:FindFirstChildOfClass("Humanoid")
        if not r or not h or not gRoot or not gh then
            cleanupInvisibleGodclone()
            return
        end
        if h.Health <= 0 or gh.Health <= 0 then
            cleanupInvisibleGodclone()
            return
        end

        local cam = Workspace.CurrentCamera
        pcall(function()
            gh.WalkSpeed = math.max(h.WalkSpeed, State.WalkSpeed or 16)
            gh.JumpPower = h.JumpPower
        end)

        local moveVec, relativeCam = computeGodcloneGhostMove(h)
        if moveVec.Magnitude > 1e-3 then
            if relativeCam then
                gh:Move(moveVec, true)
            else
                gh:Move(moveVec)
            end
        else
            gh:Move(Vector3.zero)
        end

        local wantJump = h.Jump
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            wantJump = true
        end
        gh.Jump = wantJump

        r.CFrame = gRoot.CFrame * CFrame.new(0, -10, 0)
        r.AssemblyLinearVelocity = Vector3.zero
    end))
end

local function wireInvisibleVoidHooks()
    clearConn("invisibleVoidStep")
    clearConn("invisibleVoidRender")
    clearConn("invisibleVoidPreSim")
    clearConn("invisibleVoidPostSim")
    invisibleVoidSnapUsesPreSim = false
    if not State.Invisible or not State.InvisibleVoidMode or State.InvisibleGodcloneMode then return end

    local preSim = RunService.PreSimulation
    if typeof(preSim) == "RBXScriptSignal" then
        invisibleVoidSnapUsesPreSim = true
        setConn("invisibleVoidPreSim", preSim:Connect(function()
            if not State.Invisible or not State.InvisibleVoidMode then return end
            snapInvisibleRootToVoid()
        end))
    end

    -- Setelah physics/replikasi, paksa lagi ke void supaya skrip mob/client yang baca HRP setelah sim punya posisi jauh.
    local postSim = RunService.PostSimulation
    if typeof(postSim) == "RBXScriptSignal" then
        setConn("invisibleVoidPostSim", postSim:Connect(function()
            if not State.Invisible or not State.InvisibleVoidMode then return end
            snapInvisibleRootToVoid()
        end))
    end

    setConn("invisibleVoidStep", RunService.Heartbeat:Connect(function(dt)
        if not State.Invisible or not State.InvisibleVoidMode then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end
        if not invIllusionCF then
            invIllusionCF = root.CFrame
            return
        end

        dt = math.clamp(dt, 1 / 240, 1 / 20)
        local flatMd = hum.MoveDirection
        local horizFlat = Vector3.new(flatMd.X, 0, flatMd.Z)
        local horiz = Vector3.zero
        if horizFlat.Magnitude > 1e-4 then
            horiz = horizFlat.Unit * hum.WalkSpeed * dt
        end
        local vy = root.AssemblyLinearVelocity.Y
        local newPos = invIllusionCF.Position + horiz + Vector3.new(0, vy * dt, 0)
        local _, yPrev, _ = invIllusionCF:ToOrientation()
        local yAngle = yPrev
        if horizFlat.Magnitude > 1e-4 then
            local f = horizFlat.Unit
            yAngle = math.atan2(f.X, f.Z)
        end
        invIllusionCF = CFrame.new(newPos) * CFrame.fromOrientation(0, yAngle, 0)

        -- Kalau tidak ada PostSimulation, void dipaksa di sini (setelah physics).
        if not Connections.invisibleVoidPostSim then
            snapInvisibleRootToVoid()
        end
    end))

    setConn("invisibleVoidRender", RunService.RenderStepped:Connect(function()
        if not State.Invisible or not State.InvisibleVoidMode then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not invIllusionCF then return end
        local delta = invIllusionCF.Position - root.Position
        if delta.Magnitude < 0.001 then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CFrame = p.CFrame + delta
            end
        end
    end))
end

local function refreshInvisibleHooks()
    cleanupInvisibleGodclone()
    clearConn("invisibleVoidStep")
    clearConn("invisibleVoidRender")
    clearConn("invisibleVoidPreSim")
    clearConn("invisibleVoidPostSim")
    invisibleVoidSnapUsesPreSim = false
    if not State.Invisible then return end
    if State.InvisibleGodcloneMode then
        wireInvisibleGodcloneHooks()
    else
        wireInvisibleVoidHooks()
    end
end

local invisibleEnforceAccum = 0
local function toggleInvisible(on)
    State.Invisible = on
    clearConn("invisibleEnforce")
    clearConn("invisibleDescendant")
    clearConn("invisibleVoidStep")
    clearConn("invisibleVoidRender")
    clearConn("invisibleVoidPreSim")
    clearConn("invisibleVoidPostSim")
    clearConn("invisibleGodcloneHeartbeat")
    clearConn("invisibleGodcloneStepped")
    invisibleVoidSnapUsesPreSim = false
    invisibleEnforceAccum = 0

    if not on then
        cleanupInvisibleGodclone()
        local ch = LocalPlayer.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if root and invIllusionCF and State.InvisibleVoidMode and not State.InvisibleGodcloneMode then
            pcall(function()
                root.CFrame = invIllusionCF
            end)
        end
        invIllusionCF = nil
        applyInvisibleToCharacter(false)
        return
    end

    local ch0 = LocalPlayer.Character
    local root0 = ch0 and ch0:FindFirstChild("HumanoidRootPart")
    if root0 then
        invIllusionCF = root0.CFrame
    else
        invIllusionCF = nil
    end

    applyInvisibleToCharacter(true)

    local ch = LocalPlayer.Character
    if ch then
        setConn("invisibleDescendant", ch.DescendantAdded:Connect(function()
            if not State.Invisible then return end
            task.defer(function()
                applyInvisibleToCharacter(true)
            end)
        end))
    end

    refreshInvisibleHooks()

    setConn("invisibleEnforce", RunService.Heartbeat:Connect(function(dt)
        if not State.Invisible then return end
        invisibleEnforceAccum += dt
        if invisibleEnforceAccum < 0.2 then return end
        invisibleEnforceAccum = 0
        applyInvisibleToCharacter(true)
    end))
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

local function buildFlyDirection(cam, dt)
    dt = math.clamp(dt or 1 / 60, 1 / 120, 1 / 15)
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    local keyStrength = math.abs(flyControl.F - flyControl.B)
        + math.abs(flyControl.R - flyControl.L)
        + math.abs(flyControl.U - flyControl.D)
    local stickOrTouch = UserInputService.TouchEnabled
        or (UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled)
    local preferMobile = stickOrTouch and keyStrength < 0.01

    local hum = getHum()

    if preferMobile and hum then
        if hum.Jump then
            flyMobileJumpTimer = math.max(flyMobileJumpTimer, 1)
            pcall(function() hum.Jump = false end)
        end
        flyMobileJumpTimer = math.max(0, flyMobileJumpTimer - dt * 4.5)

        local md = hum.MoveDirection
        local flat = Vector3.new(md.X, 0, md.Z)
        local horiz = Vector3.zero
        if flat.Magnitude > 0.04 then
            flat = flat.Unit
            local lookH = Vector3.new(look.X, 0, look.Z)
            if lookH.Magnitude < 1e-3 then
                lookH = Vector3.new(0, 0, -1)
            else
                lookH = lookH.Unit
            end
            local rightH = Vector3.new(right.X, 0, right.Z)
            if rightH.Magnitude < 1e-3 then
                rightH = Vector3.new(1, 0, 0)
            else
                rightH = rightH.Unit
            end
            local f = flat:Dot(lookH)
            local r = flat:Dot(rightH)
            horiz = look * f + right * r
            if horiz.Magnitude > 0.01 then
                horiz = horiz.Unit
            end
        end

        local dir = horiz + Vector3.new(0, flyMobileJumpTimer, 0)
        if dir.Magnitude > 0.01 then
            return dir.Unit
        end
        return Vector3.zero
    end

    flyMobileJumpTimer = math.max(0, flyMobileJumpTimer - dt * 4.5)
    local dir =
        (look * (flyControl.F - flyControl.B)) +
        (right * (flyControl.R - flyControl.L)) +
        Vector3.new(0, flyControl.U - flyControl.D, 0)
    if dir.Magnitude > 0.01 then
        return dir.Unit
    end
    return Vector3.zero
end

local function toggleFly(on)
    State.Fly = on
    flyMobileJumpTimer = 0
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

        setConn("fly", RunService.RenderStepped:Connect(function(dt)
            local cam = Workspace.CurrentCamera
            if not cam or not flyBV or not flyBG then return end
            local dir = buildFlyDirection(cam, dt)
            flyBV.Velocity = dir * math.max(20, State.FlySpeed)
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

setConn("flyMobileJump", UserInputService.JumpRequest:Connect(function()
    if not State.Fly then return end
    if UserInputService.TouchEnabled
        or (UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled) then
        flyMobileJumpTimer = math.max(flyMobileJumpTimer, 1)
    end
end))

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

local function getNearestTargetPlayer()
    local myRoot = getRoot()
    if not myRoot then return nil end

    local nearestPlayer = nil
    local nearestDistance = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetHum = plr.Character:FindFirstChildOfClass("Humanoid")
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetHum and targetHum.Health > 0 and targetRoot then
                local dist = (targetRoot.Position - myRoot.Position).Magnitude
                if dist < nearestDistance then
                    nearestDistance = dist
                    nearestPlayer = plr
                end
            end
        end
    end
    return nearestPlayer
end

local function toggleFlingLoop(on)
    State.FlingLoop = on
    clearConn("flingLoop")
    if not on then return end

    setConn("flingLoop", RunService.Heartbeat:Connect(function()
        if not State.FlingLoop then return end
        local myChar = getChar()
        local myRoot = getRoot()
        local myHum = getHum()
        if not myChar or not myRoot or not myHum or myHum.Health <= 0 then return end

        local targetPlayer = getNearestTargetPlayer()
        if not targetPlayer or not targetPlayer.Character then return end
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.5)
        myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        myRoot.AssemblyAngularVelocity = Vector3.new(0, 280, 0)
    end))
end

local function getAutoAimTarget()
    local cam = Workspace.CurrentCamera
    local myChar = getChar()
    if not cam or not myChar then return nil end

    local bestTargetPart = nil
    local bestScore = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            local targetPart = head or root
            if hum and hum.Health > 0 and targetPart then
                local dist = (targetPart.Position - cam.CFrame.Position).Magnitude
                if dist <= State.AutoAimRange then
                    local onScreen, viewportPos = pcall(function()
                        return cam:WorldToViewportPoint(targetPart.Position)
                    end)
                    if onScreen and viewportPos and viewportPos.Z > 0 then
                        local screenCenter = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
                        local score = (Vector2.new(viewportPos.X, viewportPos.Y) - screenCenter).Magnitude
                        if score < bestScore then
                            bestScore = score
                            bestTargetPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return bestTargetPart
end

local function toggleAutoAim(on)
    State.AutoAim = on
    clearConn("autoAim")
    if not on then return end

    setConn("autoAim", RunService.RenderStepped:Connect(function()
        if not State.AutoAim or State.Freecam then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end

        local targetPart = getAutoAimTarget()
        if not targetPart then return end

        local desired = CFrame.lookAt(cam.CFrame.Position, targetPart.Position)
        local smooth = math.clamp(State.AutoAimSmooth, 0.01, 1)
        cam.CFrame = cam.CFrame:Lerp(desired, smooth)
    end))
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

local function toggleTrollShake(on)
    State.TrollShake = on
    clearConn("trollShake")
    if not on then return end
    setConn("trollShake", RunService.Heartbeat:Connect(function()
        if not State.TrollShake then return end
        local root = getRoot()
        if not root then return end
        local j = 0.22
        root.CFrame = root.CFrame * CFrame.new(
            (math.random() - 0.5) * 2 * j,
            (math.random() - 0.5) * 2 * j,
            (math.random() - 0.5) * 2 * j
        )
    end))
end

local function toggleTrollOrbit(on)
    State.TrollOrbit = on
    clearConn("trollOrbit")
    trollOrbitAngle = 0
    if not on then return end
    setConn("trollOrbit", RunService.Heartbeat:Connect(function(dt)
        if not State.TrollOrbit then return end
        local root = getRoot()
        if not root then return end
        local target = getNearestTargetPlayer()
        if not target or not target.Character then return end
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        if not tr then return end
        trollOrbitAngle += dt * 3.2
        local radius = 14
        local yOff = 4
        local offset = Vector3.new(math.cos(trollOrbitAngle) * radius, yOff, math.sin(trollOrbitAngle) * radius)
        local pos = tr.Position + offset
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(pos, tr.Position + Vector3.new(0, 2, 0))
    end))
end

local function toggleTrollChaosVel(on)
    State.TrollChaosVel = on
    clearConn("trollChaosVel")
    if not on then return end
    setConn("trollChaosVel", RunService.Heartbeat:Connect(function()
        if not State.TrollChaosVel then return end
        local root = getRoot()
        if not root then return end
        local v = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)
        if v.Magnitude < 0.05 then v = Vector3.new(0.3, 1, 0.2) end
        root.AssemblyLinearVelocity = v.Unit * (180 + math.random() * 120)
        root.AssemblyAngularVelocity = Vector3.new(math.random() * 40 - 20, math.random() * 40 - 20, math.random() * 40 - 20)
    end))
end

local function toggleTrollCamFov(on)
    State.TrollCamFov = on
    clearConn("trollCamFov")
    if on then
        local cam = Workspace.CurrentCamera
        if cam then preTrollCamFov = cam.FieldOfView end
        setConn("trollCamFov", RunService.RenderStepped:Connect(function()
            local c = Workspace.CurrentCamera
            if not c or not State.TrollCamFov then return end
            c.FieldOfView = 55 + math.sin(tick() * 16) * 40
        end))
    else
        local cam = Workspace.CurrentCamera
        if cam and preTrollCamFov then
            cam.FieldOfView = preTrollCamFov
        end
        preTrollCamFov = nil
    end
end

local function trollRagdollSelf()
    local hum = getHum()
    if not hum then return end
    pcall(function()
        hum.PlatformStand = true
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end)
end

local function trollMegaFlingSelf()
    local root = getRoot()
    if not root then return end
    local v = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)
    if v.Magnitude < 0.05 then v = Vector3.new(1, 0.4, 0.2) end
    v = v.Unit
    root.AssemblyLinearVelocity = v * (2200 + math.random() * 800)
    root.AssemblyAngularVelocity = Vector3.new(math.random() * 200 - 100, math.random() * 200 - 100, math.random() * 200 - 100)
end

local function trollLaunchUp()
    local root = getRoot()
    if not root then return end
    root.AssemblyLinearVelocity = Vector3.new(0, 3500, 0)
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
            local aliveMap = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local name = "ESP_" .. plr.Name
                    aliveMap[name] = true
                    local hl = espFolder:FindFirstChild(name)
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = name
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = Color3.fromRGB(255, 80, 80)
                        hl.OutlineColor = Color3.fromRGB(255, 160, 160)
                        hl.FillTransparency = 0.55
                        hl.OutlineTransparency = 0.05
                        hl.Parent = espFolder
                    end
                    hl.Adornee = plr.Character
                end
            end
            for _, item in ipairs(espFolder:GetChildren()) do
                if not aliveMap[item.Name] then
                    item:Destroy()
                end
            end
        end))
    end
end

-- Main tab
MainTab:CreateSection({ Name = "Movement" })
MainTab:CreateParagraph({
    Title = "Info",
    Desc = "Fly PC: WASD + Space/Ctrl. Fly mobile: joystick gerak + tombol jump naik (ikut arah kamera). Freecam: WASD/IJKL + Space/Ctrl (Q/E) + Mouse"
})

MainTab:CreateToggle({
    Name = "Fly",
    Default = false,
    Callback = toggleFly
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Min = 20,
    Max = 300,
    Default = 50,
    Callback = function(v)
        State.FlySpeed = v
    end
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

MainTab:CreateToggle({
    Name = "Freecam",
    Default = false,
    Callback = toggleFreecam
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

MainTab:CreateSection({ Name = "Combat Assist" })
MainTab:CreateParagraph({
    Title = "Combat Notes",
    Desc = "Auto Aim target terdekat dari tengah layar. Auto Fling akan loop ke target player terdekat."
})
MainTab:CreateToggle({
    Name = "Auto Aim",
    Default = false,
    Callback = toggleAutoAim
})

MainTab:CreateSlider({
    Name = "Auto Aim Smooth",
    Min = 1,
    Max = 100,
    Default = 20,
    Callback = function(v)
        State.AutoAimSmooth = v / 100
    end
})

MainTab:CreateSlider({
    Name = "Auto Aim Range",
    Min = 50,
    Max = 1000,
    Default = 300,
    Callback = function(v)
        State.AutoAimRange = v
    end
})

MainTab:CreateToggle({
    Name = "Auto Fling (Loop)",
    Default = false,
    Callback = toggleFlingLoop
})

MainTab:CreateButton({
    Name = "Fling (Pulse)",
    Callback = flingPulse
})

MainTab:CreateSection({ Name = "Keybind" })
MainTab:CreateParagraph({
    Title = "Shortcut",
    Desc = "Atur hotkey untuk toggle cepat. Kosongkan: klik kanan pada kotak keybind, atau klik lalu tekan Esc / Backspace (tampil None — tidak memicu apa pun). Pastikan lib.lua terbaru dari repo VoraHub kalau masih pakai HttpGet lama."
})
MainTab:CreateKeybind({
    Name = "Toggle Fly",
    Default = Enum.KeyCode.F,
    Callback = function()
        toggleFly(not State.Fly)
    end
})

MainTab:CreateKeybind({
    Name = "Toggle Auto Aim",
    Default = Enum.KeyCode.H,
    Callback = function()
        toggleAutoAim(not State.AutoAim)
    end
})

MainTab:CreateKeybind({
    Name = "Toggle Auto Fling",
    Default = Enum.KeyCode.G,
    Callback = function()
        toggleFlingLoop(not State.FlingLoop)
    end
})

-- Player tab
PlayerTab:CreateSection({ Name = "Character Utility" })
PlayerTab:CreateParagraph({
    Title = "Character Notes",
    Desc = "Invisible: dua mode beda — Void (HRP jauh + offset render) atau Godclone (pola EFTB: clone semi-transparan, kamera ke clone, tubuh asli noclip & HRP ~10 stud di bawah clone). Jangan nyalakan Void + Godclone bareng (otomatis saling matiin). Fly bisa bentrok. AI server tetap pakai posisi server."
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    Default = false,
    Callback = toggleNoclip
})

PlayerTab:CreateKeybind({
    Name = "Keybind Toggle Noclip",
    Default = Enum.KeyCode.N,
    Callback = function()
        toggleNoclip(not State.Noclip)
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v)
        State.InfiniteJump = v
    end
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
    Name = "Invisible hitbox void (jauh)",
    Default = true,
    Callback = function(v)
        State.InvisibleVoidMode = v
        if v then
            State.InvisibleGodcloneMode = false
        end
        if State.Invisible then
            if not v and not State.InvisibleGodcloneMode and invIllusionCF then
                local ch = LocalPlayer.Character
                local root = ch and ch:FindFirstChild("HumanoidRootPart")
                if root then
                    pcall(function()
                        root.CFrame = invIllusionCF
                    end)
                end
            end
            refreshInvisibleHooks()
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Invisible godclone (EFTB God Mode)",
    Default = false,
    Callback = function(v)
        State.InvisibleGodcloneMode = v
        if v then
            State.InvisibleVoidMode = false
        end
        if State.Invisible then
            refreshInvisibleHooks()
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Transparansi invisible",
    Min = 5,
    Max = 95,
    Default = 45,
    Callback = function(v)
        State.InvisibleTransparency = v / 100
        if State.Invisible then
            applyInvisibleToCharacter(true)
            if State.InvisibleGodcloneMode and invGhostClone then
                local gt = math.clamp(State.InvisibleTransparency, 0.2, 0.85)
                for _, p in ipairs(invGhostClone:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Transparency = gt
                    end
                end
            end
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti Ragdoll",
    Default = false,
    Callback = function(v)
        applyAntiRagdoll(v)
    end
})

PlayerTab:CreateSection({ Name = "Character Stats" })
PlayerTab:CreateParagraph({
    Title = "Stats Notes",
    Desc = "Gunakan slider untuk set cepat, input untuk angka spesifik."
})

PlayerTab:CreateSlider({
    Name = "WalkSpeed Slider",
    Min = 1,
    Max = 300,
    Default = 16,
    Callback = function(v)
        applyWalkSpeed(v)
    end
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

PlayerTab:CreateToggle({
    Name = "Spin",
    Default = false,
    Callback = toggleSpin
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

PlayerTab:CreateSection({ Name = "Character Action" })
PlayerTab:CreateParagraph({
    Title = "Action",
    Desc = "Reset karakter jika stuck atau bug posisi."
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
TeleportTab:CreateParagraph({
    Title = "Teleport Notes",
    Desc = "Bisa teleport ke koordinat atau ke player. Gunakan refresh jika list player berubah."
})

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

-- Troll tab (local / self only; orbit butuh player lain di dekat)
TrollTab:CreateSection({ Name = "Troll (Local)" })
TrollTab:CreateParagraph({
    Title = "Catatan",
    Desc = "Efek di bawah hanya untuk karakter kamu. Orbit butuh player lain di server. Matikan sebelum serius main."
})
TrollTab:CreateToggle({
    Name = "Shake (getar posisi)",
    Default = false,
    Callback = toggleTrollShake
})
TrollTab:CreateToggle({
    Name = "Orbit player terdekat",
    Default = false,
    Callback = toggleTrollOrbit
})
TrollTab:CreateToggle({
    Name = "Chaos velocity (acak terbang)",
    Default = false,
    Callback = toggleTrollChaosVel
})
TrollTab:CreateToggle({
    Name = "Camera FOV gila-gilaan",
    Default = false,
    Callback = toggleTrollCamFov
})
TrollTab:CreateButton({
    Name = "Ragdoll diri",
    Callback = trollRagdollSelf
})
TrollTab:CreateButton({
    Name = "Mega fling diri (sekali)",
    Callback = trollMegaFlingSelf
})
TrollTab:CreateButton({
    Name = "Launch ke atas (jatuh)",
    Callback = trollLaunchUp
})

-- Misc tab
MiscTab:CreateSection({ Name = "Visual" })
MiscTab:CreateParagraph({
    Title = "Visual Notes",
    Desc = "ESP memakai highlight karakter, FullBright untuk map gelap, Solid World mencegah nembus model."
})
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

MiscTab:CreateSection({ Name = "Interaction" })
MiscTab:CreateParagraph({
    Title = "Prompt",
    Desc = "Instant Prompt: semua ProximityPrompt di workspace pakai HoldDuration 0 (satu kali tap). Nilai asli disimpan dan dikembalikan saat dimatikan."
})
MiscTab:CreateToggle({
    Name = "Instant Prompt",
    Default = false,
    Callback = toggleInstantPrompt
})

MiscTab:CreateSection({ Name = "Server" })
MiscTab:CreateParagraph({
    Title = "Server Notes",
    Desc = "Anti AFK untuk idle kick. Rejoin/Server Hop untuk pindah instance."
})
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
        toggleFlingLoop(false)
        toggleAutoAim(false)
        toggleESP(false)
        toggleFullBright(false)
        toggleSolidWorld(false)
        toggleInstantPrompt(false)
        toggleTrollShake(false)
        toggleTrollOrbit(false)
        toggleTrollChaosVel(false)
        toggleTrollCamFov(false)
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
