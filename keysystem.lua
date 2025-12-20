--[[
    VORAHUB 2026 KEYSYSTEM – FULL VERSION DENGAN CLIENTID + LOG F9
    FITUR:
    • Menggunakan Roblox ClientId (GetUserIdentifier)
    • 1 Key = 1 Device + 1 Akun SELAMANYA
    • Device/akun berbeda → langsung KICK
    • UI selalu muncul
    • Auto redeem kalau ada _G.script_key
    • LOG CLIENTID KE F9 CONSOLE (untuk user copy kalau perlu reset)
]]

local API_KEY = "AIzaSyDSzv4tvzV8oxk4TVVacAa54F-KS2kBQoM"
local PROJECT_ID = "vorahub-3e462"
local BASE = "https://firestore.googleapis.com/v1/projects/"..PROJECT_ID.."/databases/(default)/documents"

local Http = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Tween = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Universal HTTP request
local function request(url, post, body)
    local success, response = pcall(function()
        if syn and syn.request then
            return syn.request({
                Url = url,
                Method = post and "POST" or "GET",
                Headers = {["Content-Type"] = "application/json"},
                Body = body
            }).Body
        elseif http_request then
            return http_request({
                Url = url,
                Method = post and "POST" or "GET",
                Body = body
            }).Body
        elseif request then
            return request({
                Url = url,
                Method = post and "POST" or "GET",
                Body = body
            }).Body
        else
            return post and Http:HttpPost(Http, url, body, Enum.HttpContentType.ApplicationJson) or Http:HttpGet(Http, url)
        end
    end)
    return success and response or nil
end

-- Dapatkan ClientId Roblox
local function getClientId()
    local success, clientId = pcall(function()
        return LocalPlayer:GetUserIdentifier()
    end)
    if success and clientId and clientId ~= "" then
        return clientId:upper()
    else
        return Http:GenerateGUID(false):upper()
    end
end

local CURRENT_CLIENTID = getClientId()

-- LOG KE F9 CONSOLE (HWID = ClientId)
print("\n========================================")
print("HWID: " .. CURRENT_CLIENTID)
print("========================================\n")
-- User bisa tekan F9 → lihat HWID ini → copy kalau perlu reset

-- Fungsi redeem key
local function redeem(key)
    key = key:gsub("%s", ""):upper()
    if #key < 6 then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB",
            Text = "Key terlalu pendek!",
            Duration = 5,
            Icon = "rbxassetid://6031082533"
        })
        return false
    end

    StarterGui:SetCore("SendNotification", {
        Title = "VORAHUB",
        Text = "Memeriksa key...",
        Duration = 6,
        Icon = "rbxassetid://6031075938"
    })

    local data = request(BASE.."/keys/"..key.."?key="..API_KEY)
    if not data or data:find("error") then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB",
            Text = "Key tidak valid atau tidak ditemukan!",
            Duration = 6,
            Icon = "rbxassetid://6031082533"
        })
        return false
    end

    local json = Http:JSONDecode(data)
    if not json.fields then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB",
            Text = "Error membaca data key!",
            Duration = 6,
            Icon = "rbxassetid://6031082533"
        })
        return false
    end

    local isUsed = json.fields.used and json.fields.used.booleanValue or false
    local boundClientId = json.fields.clientId and json.fields.clientId.stringValue or ""

    if isUsed then
        if boundClientId == CURRENT_CLIENTID then
            StarterGui:SetCore("SendNotification", {
                Title = "VORAHUB 2026",
                Text = "Key valid! Loading script...",
                Duration = 4,
                Icon = "rbxassetid://6031075938"
            })
            wait(2)
            StarterGui:SetCore("SendNotification", {
                Title = "LOADED!",
                Text = "Selamat datang, "..LocalPlayer.Name.."!",
                Duration = 6,
                Icon = "rbxassetid://6031075938"
            })
            return true
        else
            StarterGui:SetCore("SendNotification", {
                Title = "ACCESS DENIED",
                Text = "Key terikat ke device/akun lain!\nKamu akan dikeluarkan.",
                Duration = 8,
                Icon = "rbxassetid://6031082533"
            })
            wait(3)
            LocalPlayer:Kick("\n[VORAHUB 2026]\nKey terikat ke device & akun lain.\nHWID kamu: "..CURRENT_CLIENTID.."\nHubungi admin Discord untuk reset.")
            return false
        end
    end

    -- Bind key baru
    local body = Http:JSONEncode({
        writes = {{
            update = {
                name = "projects/"..PROJECT_ID.."/databases/(default)/documents/keys/"..key,
                fields = {
                    used = {booleanValue = true},
                    usedBy = {stringValue = LocalPlayer.Name},
                    clientId = {stringValue = CURRENT_CLIENTID},
                    usedAt = {timestampValue = os.date("!%Y-%m-%dT%H:%M:%SZ")}
                }
            }
        }}
    })

    local commitSuccess = request(BASE.."/:commit?key="..API_KEY, true, body)
    if not commitSuccess then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB",
            Text = "Gagal bind key ke device!",
            Duration = 6,
            Icon = "rbxassetid://6031082533"
        })
        return false
    end

    StarterGui:SetCore("SendNotification", {
        Title = "VORAHUB 2026",
        Text = "Key berhasil di-bind!\nLoading...",
        Duration = 4,
        Icon = "rbxassetid://6031075938"
    })
    wait(2)
    StarterGui:SetCore("SendNotification", {
        Title = "LOADED!",
        Text = "Selamat datang, "..LocalPlayer.Name.."!",
        Duration = 6,
        Icon = "rbxassetid://6031075938"
    })

    return true
end

-- ==================== UI ====================
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 460, 0, 340)
main.Position = UDim2.new(0.5, -230, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 24)

local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 10, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 30))
}
grad.Rotation = 135

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(120, 80, 255)
stroke.Thickness = 3

local title = Instance.new("TextLabel", main)
title.Text = "VORAHUB 2026"
title.Size = UDim2.new(1, 0, 0, 90)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(180, 120, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 48

local box = Instance.new("TextBox", main)
box.PlaceholderText = "Masukkan key disini..."
box.Position = UDim2.new(0.08, 0, 0, 100)
box.Size = UDim2.new(0.84, 0, 0, 65)
box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.GothamBold
box.TextSize = 28
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 16)

local redeemBtn = Instance.new("TextButton", main)
redeemBtn.Text = "REDEEM KEY"
redeemBtn.Position = UDim2.new(0.08, 0, 0, 180)
redeemBtn.Size = UDim2.new(0.84, 0, 0, 75)
redeemBtn.Font = Enum.Font.GothamBlack
redeemBtn.TextSize = 34
redeemBtn.TextColor3 = Color3.new(1, 1, 1)
local rg = Instance.new("UIGradient", redeemBtn)
rg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 200))
}
Instance.new("UICorner", redeemBtn).CornerRadius = UDim.new(0, 20)

local getkeyBtn = Instance.new("TextButton", main)
getkeyBtn.Text = "GET KEY (DISCORD)"
getkeyBtn.Position = UDim2.new(0.08, 0, 0, 270)
getkeyBtn.Size = UDim2.new(0.84, 0, 0, 55)
getkeyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
getkeyBtn.Font = Enum.Font.GothamBold
getkeyBtn.TextSize = 28
getkeyBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", getkeyBtn).CornerRadius = UDim.new(0, 16)

local status = Instance.new("TextLabel", main)
status.Position = UDim2.new(0, 0, 0.85, 0)
status.Size = UDim2.new(1, 0, 0.12, 0)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200, 200, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 22
status.Text = "Masukkan key untuk melanjutkan"

-- Animasi UI
main.Position = UDim2.new(0.5, -230, -0.5, 0)
Tween:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -230, 0.5, -170)}):Play()

-- Auto redeem kalau ada _G.script_key
if _G.script_key and _G.script_key ~= "" then
    box.Text = _G.script_key
    spawn(function()
        wait(1.5)
        if redeem(_G.script_key) then
            wait(3)
            sg:Destroy()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Andrazx23/vorahub/refs/heads/main/main.lua"))()
        end
    end)
end

-- Redeem manual
redeemBtn.MouseButton1Click:Connect(function()
    if redeem(box.Text) then
        wait(3)
        sg:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Andrazx23/vorahub/refs/heads/main/main.lua"))()
    end
end)

-- Get key
getkeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/vorahub")
    StarterGui:SetCore("SendNotification", {
        Title = "VORAHUB",
        Text = "Link Discord telah di-copy!",
        Duration = 4
    })
end)
