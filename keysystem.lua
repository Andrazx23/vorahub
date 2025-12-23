-- VORAHUB 2026 KEYSYSTEM – KHUSUS FISH IT! (GameId: 6701277882)
-- VERSI SUPER LENGKAP DENGAN LEBIH BANYAK FITUR, KOMENTAR PANJANG, DAN BARIS LEBIH BANYAK
-- SEMUA FITUR DARI VERSI SEBELUMNYA DITAMBAHKAN & DIPERLUAS, BUKAN DIKURANGI
-- _G.script_key SUPPORT AUTO-REDEEM + MANUAL REDEEM TETAP ADA
-- TAMBAHAN: Log lebih detail, animasi lebih smooth, notif lebih banyak, anti tamper lebih kuat

local API_KEY = "AIzaSyDSzv4tvzV8oxk4TVVacAa54F-KS2kBQoM"  -- API Key Firestore (jangan diganti)
local PROJECT_ID = "vorahub-3e462"                          -- Project ID Firestore
local BASE = "https://firestore.googleapis.com/v1/projects/" .. PROJECT_ID .. "/databases/(default)/documents"  -- Base URL untuk akses database

-- Services Roblox yang diperlukan untuk script ini berjalan
local Http = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Tween = game:GetService("TweenService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==================================================
-- SECTION 1: PENGECEKAN GAME ID (KHUSUS FISH IT!)
-- ==================================================
if game.GameId ~= 6701277882 then
    StarterGui:SetCore("SendNotification", {
        Title = "VORAHUB ACCESS DENIED",
        Text = "Script ini KHUSUS untuk Fish It! 🐟",
        Duration = 12,
        Icon = "rbxassetid://6031082533"
    })
    task.wait(6)
    LocalPlayer:Kick("\n\n[VORAHUB 2026 PREMIUM KEYSYSTEM]\n\nScript ini hanya dapat digunakan di game Fish It!\n\nGame ID saat ini: " .. game.GameId .. "\nGame ID yang dibutuhkan: 6701277882\n\nJangan mencoba inject di game lain. Hubungi admin jika ada masalah.")
    return
end

print("[VORAHUB] Game ID valid: Fish It! (6701277882)")

-- ==================================================
-- SECTION 2: UNIVERSAL HTTP REQUEST (MULTI EXPLOIT SUPPORT)
-- ==================================================
local function request(url, method, body)
    local success, response = pcall(function()
        local req
        if syn and syn.request then
            req = syn.request
            print("[VORAHUB] Menggunakan syn.request")
        elseif http_request then
            req = http_request
            print("[VORAHUB] Menggunakan http_request")
        elseif request then
            req = request
            print("[VORAHUB] Menggunakan request")
        else
            print("[VORAHUB] Fallback ke Roblox HttpService")
            if method == "POST" then
                return Http:PostAsync(url, body or "", Enum.HttpContentType.ApplicationJson)
            else
                return Http:GetAsync(url)
            end
        end
        local res = req({
            Url = url,
            Method = method or "GET",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
        return res.Body or res
    end)
    if success then
        return response
    else
        warn("[VORAHUB] HTTP Request gagal: ", response)
        return nil
    end
end

-- ==================================================
-- SECTION 3: AMBIL HWID & COPY KE CLIPBOARD + LOG DETAIL
-- ==================================================
local HWID = RbxAnalyticsService:GetClientId()

print("\n==================================================")
print("               VORAHUB 2026 - FISH IT!")
print("               PREMIUM KEYSYSTEM LOG")
print("==================================================")
print("Player: " .. LocalPlayer.Name)
print("UserId: " .. LocalPlayer.UserId)
print("HWID: " .. HWID)
print("Game ID: " .. game.GameId)
print("Place ID: " .. game.PlaceId)
print("==================================================\n")

setclipboard(HWID)
StarterGui:SetCore("SendNotification", {
    Title = "VORAHUB PREMIUM",
    Text = "HWID telah berhasil di-copy ke clipboard!",
    Duration = 8,
    Icon = "rbxassetid://6031075938"
})

task.wait(1)
StarterGui:SetCore("SendNotification", {
    Title = "VORAHUB",
    Text = "Selamat datang di Vorahub Premium untuk Fish It! 🐟",
    Duration = 6,
    Icon = "rbxassetid://6031075938"
})

-- ==================================================
-- SECTION 4: FUNGSI REDEEM KEY (DENGAN VALIDASI LENGKAP)
-- ==================================================
local function redeem(key)
    key = key:gsub("%s+", ""):upper()  -- Bersihkan spasi & uppercase
    print("[VORAHUB] Mencoba redeem key: " .. key)

    if #key < 6 then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB ERROR",
            Text = "Key terlalu pendek atau kosong! Minimal 6 karakter.",
            Duration = 8,
            Icon = "rbxassetid://6031082533"
        })
        print("[VORAHUB] Redeem gagal: key terlalu pendek")
        return false
    end

    StarterGui:SetCore("SendNotification", {
        Title = "VORAHUB",
        Text = "Sedang memeriksa key di server...",
        Duration = 12,
        Icon = "rbxassetid://6031075938"
    })

    -- Ambil data key dari Firestore
    local data = request(BASE .. "/keys/" .. key .. "?key=" .. API_KEY)
    if not data then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB ERROR",
            Text = "Gagal terhubung ke server! Periksa koneksi internet.",
            Duration = 10,
            Icon = "rbxassetid://6031082533"
        })
        print("[VORAHUB] Redeem gagal: tidak bisa konek server")
        return false
    end

    -- Decode JSON response
    local success, json = pcall(function() return Http:JSONDecode(data) end)
    if not success or not json.fields then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB ERROR",
            Text = "Key tidak valid atau terjadi error di server!",
            Duration = 10,
            Icon = "rbxassetid://6031082533"
        })
        print("[VORAHUB] Redeem gagal: key tidak ditemukan atau JSON error")
        return false
    end

    -- Cek status penggunaan key
    local isUsed = json.fields.used and json.fields.used.booleanValue or false
    local boundHWID = json.fields.hwid and json.fields.hwid.stringValue or ""

    if isUsed then
        if boundHWID == HWID then
            StarterGui:SetCore("SendNotification", {
                Title = "VORAHUB SUCCESS",
                Text = "Key valid! Sedang memuat script premium...",
                Duration = 8,
                Icon = "rbxassetid://6031075938"
            })
            task.wait(2)
            StarterGui:SetCore("SendNotification", {
                Title = "LOADED!",
                Text = "Selamat datang kembali, " .. LocalPlayer.Name .. "! 🐟",
                Duration = 8,
                Icon = "rbxassetid://6031075938"
            })
            print("[VORAHUB] Key valid & sudah terikat ke HWID ini")
            return true
        else
            StarterGui:SetCore("SendNotification", {
                Title = "ACCESS DENIED",
                Text = "Key ini sudah terikat ke device lain!",
                Duration = 12,
                Icon = "rbxassetid://6031082533"
            })
            task.wait(4)
            LocalPlayer:Kick("\n\n[VORAHUB 2026 PREMIUM]\n\nKey ini sudah digunakan di device lain.\n\nHWID kamu: " .. HWID .. "\nHWID terikat: " .. boundHWID .. "\n\nKirim HWID kamu ke admin Discord untuk reset atau beli key baru.")
            print("[VORAHUB] Key sudah digunakan di HWID lain")
            return false
        end
    end

    -- Key belum digunakan → bind ke HWID ini
    print("[VORAHUB] Key baru ditemukan, sedang binding ke HWID...")

    local updateFields = {
        used = { booleanValue = true },
        usedBy = { stringValue = LocalPlayer.Name },
        hwid = { stringValue = HWID },
        usedAt = { timestampValue = os.date("!%Y-%m-%dT%H:%M:%SZ") },
        game = { stringValue = "Fish It!" },
        placeId = { integerValue = game.PlaceId }
    }

    local bodyTable = {
        writes = {{
            update = {
                name = "projects/" .. PROJECT_ID .. "/databases/(default)/documents/keys/" .. key,
                fields = updateFields
            },
            updateMask = {
                fieldPaths = { "used", "usedBy", "hwid", "usedAt", "game", "placeId" }
            }
        }}
    }

    local body = Http:JSONEncode(bodyTable)
    local commitResponse = request(BASE .. "/:commit?key=" .. API_KEY, "POST", body)

    local commitSuccess, commitJson = pcall(function() return Http:JSONDecode(commitResponse or "") end)
    if not commitResponse or not commitSuccess then
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB ERROR",
            Text = "Gagal bind key ke server! Coba lagi nanti.",
            Duration = 10,
            Icon = "rbxassetid://6031082533"
        })
        print("[VORAHUB] Gagal bind key")
        return false
    end

    StarterGui:SetCore("SendNotification", {
        Title = "VORAHUB SUCCESS",
        Text = "Key berhasil di-activate! Selamat menikmati fitur premium!",
        Duration = 8,
        Icon = "rbxassetid://6031075938"
    })
    task.wait(2)
    StarterGui:SetCore("SendNotification", {
        Title = "LOADED!",
        Text = "Selamat datang, " .. LocalPlayer.Name .. "! Script premium siap digunakan 🐟",
        Duration = 8,
        Icon = "rbxassetid://6031075938"
    })
    print("[VORAHUB] Key berhasil di-bind & activated")
    return true
end

-- ==================================================
-- SECTION 5: UI PREMIUM LENGKAP DENGAN ANIMASI
-- ==================================================
local sg = Instance.new("ScreenGui")
sg.Parent = CoreGui
sg.ResetOnSpawn = false
sg.Name = "VorahubFishItPremiumKeySystem2026"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 460, 0, 340)
main.Position = UDim2.new(0.5, -230, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
main.BorderSizePixel = 0
main.BackgroundTransparency = 1  -- Mulai transparan untuk animasi fade in
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
stroke.Transparency = 1  -- Mulai transparan

local title = Instance.new("TextLabel", main)
title.Text = "VORAHUB - FISH IT!"
title.Size = UDim2.new(1, 0, 0, 90)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(180, 120, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 42
title.TextTransparency = 1  -- Fade in

local box = Instance.new("TextBox", main)
box.PlaceholderText = "Masukkan key premium disini..."
box.Position = UDim2.new(0.08, 0, 0, 100)
box.Size = UDim2.new(0.84, 0, 0, 65)
box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.GothamBold
box.TextSize = 28
box.ClearTextOnFocus = false
box.BackgroundTransparency = 1
box.TextTransparency = 1
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 16)

local redeemBtn = Instance.new("TextButton", main)
redeemBtn.Text = "REDEEM KEY"
redeemBtn.Position = UDim2.new(0.08, 0, 0, 180)
redeemBtn.Size = UDim2.new(0.84, 0, 0, 75)
redeemBtn.Font = Enum.Font.GothamBlack
redeemBtn.TextSize = 34
redeemBtn.TextColor3 = Color3.new(1, 1, 1)
redeemBtn.BackgroundTransparency = 1
redeemBtn.TextTransparency = 1
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
getkeyBtn.BackgroundTransparency = 1
getkeyBtn.TextTransparency = 1
Instance.new("UICorner", getkeyBtn).CornerRadius = UDim.new(0, 16)

local status = Instance.new("TextLabel", main)
status.Position = UDim2.new(0, 0, 0.85, 0)
status.Size = UDim2.new(1, 0, 0.12, 0)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200, 200, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 22
status.Text = "Masukkan key premium untuk melanjutkan"
status.TextTransparency = 1

-- Animasi masuk UI (dari atas + fade in)
main.Position = UDim2.new(0.5, -230, -0.5, 0)
main.BackgroundTransparency = 1

Tween:Create(main, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -230, 0.5, -170),
    BackgroundTransparency = 0
}):Play()

Tween:Create(stroke, TweenInfo.new(1.5), {Transparency = 0}):Play()
Tween:Create(title, TweenInfo.new(1.8), {TextTransparency = 0}):Play()
Tween:Create(box, TweenInfo.new(2.0), {BackgroundTransparency = 0, TextTransparency = 0.3}):Play()
Tween:Create(redeemBtn, TweenInfo.new(2.2), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
Tween:Create(getkeyBtn, TweenInfo.new(2.4), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
Tween:Create(status, TweenInfo.new(2.6), {TextTransparency = 0}):Play()

-- ==================================================
-- SECTION 6: AUTO REDEEM DENGAN _G.script_key (DENGAN LOG LENGKAP)
-- ==================================================
if _G.script_key and typeof(_G.script_key) == "string" then
    local cleanedKey = _G.script_key:gsub("%s+", ""):upper()
    print("[VORAHUB] _G.script_key ditemukan: " .. cleanedKey)
    if #cleanedKey >= 6 then
        box.Text = cleanedKey
        box.TextTransparency = 0
        task.spawn(function()
            task.wait(2)
            print("[VORAHUB] Mulai auto-redeem...")
            if redeem(cleanedKey) then
                task.wait(4)
                -- Fade out UI sebelum destroy
                Tween:Create(main, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
                Tween:Create(stroke, TweenInfo.new(0.8), {Transparency = 1}):Play()
                task.wait(0.8)
                sg:Destroy()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Andrazx23/vorahub/refs/heads/main/main.lua"))()
            end
        end)
    else
        print("[VORAHUB] Auto-redeem skipped: key di _G.script_key terlalu pendek")
        StarterGui:SetCore("SendNotification", {
            Title = "VORAHUB",
            Text = "Key di _G.script_key terlalu pendek! Masukkan manual.",
            Duration = 10
        })
    end
else
    print("[VORAHUB] Tidak ada _G.script_key – UI manual akan muncul")
end

-- ==================================================
-- SECTION 7: MANUAL REDEEM BUTTON
-- ==================================================
redeemBtn.MouseButton1Click:Connect(function()
    print("[VORAHUB] Manual redeem dimulai oleh user")
    if redeem(box.Text) then
        task.wait(4)
        Tween:Create(main, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        Tween:Create(stroke, TweenInfo.new(0.8), {Transparency = 1}):Play()
        task.wait(0.8)
        sg:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Andrazx23/vorahub/refs/heads/main/main.lua"))()
    end
end)

-- ==================================================
-- SECTION 8: GET KEY BUTTON (COPY LINK DISCORD)
-- ==================================================
getkeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/vorahub")
    StarterGui:SetCore("SendNotification", {
        Title = "VORAHUB",
        Text = "Link Discord server telah di-copy ke clipboard!",
        Duration = 6,
        Icon = "rbxassetid://6031075938"
    })
    print("[VORAHUB] User mengklik GET KEY – link Discord di-copy")
end)

-- ==================================================
-- SECTION 9: ANTI DESTROY UI YANG LEBIH KUAT
-- ==================================================
sg.DescendantRemoving:Connect(function(child)
    if child == sg or child == main then
        print("[VORAHUB] DETEKSI PENGHAPUSAN UI – MELAKUKAN KICK!")
        task.spawn(function()
            while task.wait(0.1) do
                LocalPlayer:Kick("\n\n[VORAHUB 2026 PREMIUM]\n\nJANGAN COBA HAPUS KEYSYSTEM!\nScript premium ini dilindungi.\n\nHubungi admin jika ada masalah.")
            end
        end)
    end
end)

-- Anti close CoreGui
CoreGui.DescendantRemoving:Connect(function(child)
    if child.Name == sg.Name then
        LocalPlayer:Kick("[VORAHUB] Keysytem protected – jangan hapus!")
    end
end)

print("[VORAHUB] Keysytem premium berhasil dimuat – menunggu redeem")
