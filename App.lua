-- Gerekli Servisler
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Ayarlar
local Config = {
    Colors = {
        Background = Color3.fromRGB(0, 0, 0), -- Amoled Siyah
        Primary = Color3.fromRGB(15, 15, 15), -- Koyu Gri
        Secondary = Color3.fromRGB(25, 25, 25), -- Biraz daha açık Koyu Gri
        Accent = Color3.fromRGB(0, 120, 255),
        AccentPale = Color3.fromRGB(70, 130, 220),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 150),
        Red = Color3.fromRGB(231, 76, 60),
        SwitchOff = Color3.fromRGB(60, 60, 60),
        White = Color3.fromRGB(255, 255, 255)
    },
    DefaultWalkSpeed = 16, MaxWalkSpeed = 200, DiscordLink = "discord.gg/CxhgqUu9Ry", Version = "FINAL 2.3"
}

-- Durum Değişkenleri
local States = { OndenTroll = { running = false, loop = nil, animTrack = nil, target = nil, originalGravity = nil }, ArkadanTroll = { running = false, loop = nil, target = nil }, Speed = { running = false, originalSpeed = Config.DefaultWalkSpeed }, Noclip = { running = false, loop = nil }, InfinityJump = { running = false, connection = nil }, ESP = { loop = nil, drawings = {}, Names = false, Tracers = false, Glows = false } }
local originalPosition = UDim2.new(0.5, -250, 0.5, -150)
local trollHistory = {}
local isGuiVisible = true
local f5Cooldown = false

-- Arayüzü Sıfırla
if CoreGui:FindFirstChild("MegTeamPanelFinal_2_3") then CoreGui.MegTeamPanelFinal_2_3:Destroy() end

-- ANA GUI OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "MegTeamPanelFinal_2_3"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local NotificationSound = Instance.new("Sound", ScreenGui); NotificationSound.SoundId = "rbxassetid://246114798"; NotificationSound.Volume = 0.6
local MainFrame = Instance.new("Frame"); MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Config.Colors.Background; MainFrame.Size = UDim2.new(0, 500, 0, 300); MainFrame.Position = originalPosition; MainFrame.Active = true; MainFrame.Draggable = false;
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8); MainFrame.BorderSizePixel = 0
local TitleBar = Instance.new("Frame"); TitleBar.Parent = MainFrame; TitleBar.BackgroundColor3 = Config.Colors.Primary; TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.BorderSizePixel = 0.7
local NavbarBorder = Instance.new("Frame", TitleBar); NavbarBorder.BackgroundColor3 = Config.Colors.Accent; NavbarBorder.BorderSizePixel = 0; NavbarBorder.Size = UDim2.new(1, 0, 0, 2); NavbarBorder.AnchorPoint = Vector2.new(0, 1); NavbarBorder.Position = UDim2.new(0, 0, 1, 0); NavbarBorder.BackgroundTransparency = 0
local Title = Instance.new("TextButton"); Title.Parent = TitleBar; Title.BackgroundTransparency = 1; Title.Size = UDim2.new(1, 0, 1, 0); Title.Font = Enum.Font.GothamBold; Title.Text = "MEG PANEL"; Title.TextColor3 = Config.Colors.TextPrimary; Title.TextSize = 18; Title.AutoButtonColor = false; local titlePadding = Instance.new("UIPadding", Title);
local CloseButton = Instance.new("TextButton"); CloseButton.Parent = TitleBar; CloseButton.Size = UDim2.new(0, 18, 0, 18); CloseButton.Position = UDim2.new(1, -28, 0.5, -9); CloseButton.BackgroundColor3 = Config.Colors.Red; CloseButton.Text = ""; Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1, 0)
local MinimizeButton = Instance.new("TextButton"); MinimizeButton.Parent = TitleBar; MinimizeButton.Size = UDim2.new(0, 18, 0, 18); MinimizeButton.Position = UDim2.new(1, -52, 0.5, -9); MinimizeButton.BackgroundColor3 = Color3.fromRGB(241, 196, 15); MinimizeButton.Text = ""; Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(1, 0)
local Container = Instance.new("Frame"); Container.Parent = MainFrame; Container.BackgroundTransparency = 1; Container.Size = UDim2.new(1, 0, 1, -40); Container.Position = UDim2.new(0, 0, 0, 40); Container.BorderSizePixel = 0
local TabContainer = Instance.new("Frame"); TabContainer.Parent = Container; TabContainer.Size = UDim2.new(0, 130, 1, 0); TabContainer.BackgroundColor3 = Config.Colors.Primary; local tabListLayout = Instance.new("UIListLayout", TabContainer); tabListLayout.Padding = UDim.new(0, 8); tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 10); TabContainer.BorderSizePixel = 0
local ContentContainer = Instance.new("Frame"); ContentContainer.Parent = Container; ContentContainer.BackgroundTransparency = 1; ContentContainer.Size = UDim2.new(1, -130, 1, 0); ContentContainer.Position = UDim2.new(0, 130, 0, 0)
local ESP_Container = Instance.new("ScreenGui"); ESP_Container.Name = "ESP_Container"; ESP_Container.Parent = ScreenGui; ESP_Container.ResetOnSpawn = false; ESP_Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- YARDIMCI FONKSİYONLAR
local activeTab = nil
-- [[ DEĞİŞTİRİLDİ: Sekme butonu fonksiyonu artık bir 'indicator' (gösterge) de döndürüyor ]]
local function CreateTabButton(text)
    local button = Instance.new("TextButton"); button.Parent = TabContainer; button.BackgroundColor3 = Config.Colors.Secondary; button.BorderSizePixel = 0; button.Size = UDim2.new(1, -20, 0, 35); button.AutoButtonColor = false; button.Font = Enum.Font.GothamSemibold; button.Text = text; button.TextColor3 = Config.Colors.TextSecondary; button.TextSize = 15; Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    
    local indicator = Instance.new("Frame", button)
    indicator.BackgroundColor3 = Config.Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.new(0, 0, 0, 0)
    indicator.Size = UDim2.new(0, 0, 1, 0) -- Başlangıçta genişliği 0
    
    button.MouseEnter:Connect(function() if activeTab ~= button then TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.Lerp(Config.Colors.Secondary, Config.Colors.Background, 0.5) }):Play() end end)
    button.MouseLeave:Connect(function() if activeTab ~= button then TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = Config.Colors.Secondary }):Play() end end)
    return button, indicator
end

local function CreatePage(name, addLayout)
    addLayout = addLayout == nil and true or addLayout
    local page = Instance.new("Frame"); page.Name = name; page.Parent = ContentContainer; page.BackgroundTransparency = 1; page.Size = UDim2.new(1, 0, 1, 0); page.Visible = false;
    if addLayout then
        local listLayout = Instance.new("UIListLayout", page); listLayout.Padding = UDim.new(0, 15); listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
        local padding = Instance.new("UIPadding", page); padding.PaddingTop = UDim.new(0, 15); padding.PaddingLeft = UDim.new(0, 20); padding.PaddingRight = UDim.new(0, 20);
    end
    return page
end
local function CreateTextBox(parent, placeholder)
    local textBox = Instance.new("TextBox", parent); textBox.BackgroundColor3 = Config.Colors.Primary; textBox.Size = UDim2.new(1, 0, 0, 40); textBox.Font = Enum.Font.Gotham; textBox.PlaceholderText = placeholder; textBox.PlaceholderColor3 = Config.Colors.TextSecondary; textBox.TextColor3 = Config.Colors.TextPrimary; textBox.TextSize = 14; textBox.TextXAlignment = Enum.TextXAlignment.Center; textBox.TextTransparency = 0
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8); return textBox
end
local function CreateCompactButton(parent, text) local button = Instance.new("TextButton", parent); button.BackgroundColor3 = Config.Colors.AccentPale; button.Size = UDim2.new(0.5, -5, 0, 35); button.Font = Enum.Font.GothamBold; button.Text = text; button.TextColor3 = Config.Colors.TextPrimary; button.TextSize = 15; Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8); button.Changed:Connect(function(prop) if prop == "Text" then local state = button.Text ~= text; TweenService:Create(button, TweenInfo.new(0.3), { BackgroundColor3 = state and Config.Colors.Red or Config.Colors.AccentPale }):Play() end end); return button end
local function CreateWideButton(parent, text) local button = Instance.new("TextButton", parent); button.BackgroundColor3 = Config.Colors.Accent; button.Size = UDim2.new(1, 0, 0, 35); button.Font = Enum.Font.GothamBold; button.Text = text; button.TextColor3 = Config.Colors.TextPrimary; button.TextSize = 15; Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8); return button end
local function CreateFeatureToggle(parent, text, callback) local container = Instance.new("Frame", parent); container.BackgroundTransparency = 1; container.Size = UDim2.new(1, 0, 0, 30); local label = Instance.new("TextLabel", container); label.BackgroundTransparency = 1; label.Size = UDim2.new(1, -70, 1, 0); label.Font = Enum.Font.Gotham; label.Text = text; label.TextColor3 = Config.Colors.TextSecondary; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; local switch = Instance.new("TextButton", container); switch.BackgroundColor3 = Config.Colors.SwitchOff; switch.Size = UDim2.new(0, 50, 0, 26); switch.Position = UDim2.new(1, 0, 0.5, 0); switch.AnchorPoint = Vector2.new(1, 0.5); switch.Text = ""; Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0); local nub = Instance.new("Frame", switch); nub.BackgroundColor3 = Config.Colors.TextPrimary; nub.Size = UDim2.new(0, 20, 0, 20); nub.Position = UDim2.new(0, 3, 0.5, 0); nub.AnchorPoint = Vector2.new(0, 0.5); Instance.new("UICorner", nub).CornerRadius = UDim.new(1, 0); local enabled = false; switch.MouseButton1Click:Connect(function() enabled = not enabled; TweenService:Create(nub, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = enabled and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), AnchorPoint = enabled and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)}):Play(); TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Config.Colors.Accent or Config.Colors.SwitchOff}):Play(); if callback then callback(enabled) end end); return switch end
local function CreateSlider(parent, text, min, max, default) local container = Instance.new("Frame", parent); container.BackgroundTransparency = 1; container.Size = UDim2.new(1, 0, 0, 30); local label = Instance.new("TextLabel", container); label.BackgroundTransparency = 1; label.Size = UDim2.new(0.4, 0, 1, 0); label.Font = Enum.Font.Gotham; label.TextColor3 = Config.Colors.TextSecondary; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = text .. ": " .. default; local sliderFrame = Instance.new("Frame", container); sliderFrame.Size = UDim2.new(0.6, -10, 0, 8); sliderFrame.Position = UDim2.new(1, 0, 0.5, 0); sliderFrame.AnchorPoint = Vector2.new(1, 0.5); sliderFrame.BackgroundColor3 = Config.Colors.Primary; Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(1, 0); local fill = Instance.new("Frame", sliderFrame); fill.BackgroundColor3 = Config.Colors.Accent; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0); local value = default; local valueChanged = Instance.new("BindableEvent"); local function updateSlider(input) local pos = input.Position.X - sliderFrame.AbsolutePosition.X; local percentage = math.clamp(pos / sliderFrame.AbsoluteSize.X, 0, 1); value = math.floor(min + (max - min) * percentage); fill.Size = UDim2.new(percentage, 0, 1, 0); label.Text = text .. ": " .. value; valueChanged:Fire(value) end; sliderFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then updateSlider(input); local moveConn, releaseConn; moveConn = UserInputService.InputChanged:Connect(function(moveInput) if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then updateSlider(moveInput) end end); releaseConn = UserInputService.InputEnded:Connect(function(endInput) if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then moveConn:Disconnect(); releaseConn:Disconnect() end end) end end); fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); return { Value = function() return value end, ValueChanged = valueChanged.Event } end
local function CreateDiscordElement(parent) local button = Instance.new("TextButton", parent); button.BackgroundTransparency = 1; button.Size = UDim2.new(1, 0, 0, 80); button.Text = ""; local list = Instance.new("UIListLayout", button); list.HorizontalAlignment = Enum.HorizontalAlignment.Center; list.Padding = UDim.new(0, 8); local icon = Instance.new("ImageLabel", button); icon.Image = "rbxassetid://3938254921"; icon.BackgroundTransparency = 1; icon.Size = UDim2.new(0, 50, 0, 50); local label = Instance.new("TextLabel", button); label.BackgroundTransparency = 1; label.Size = UDim2.new(1, 0, 0, 20); label.Font = Enum.Font.Gotham; label.Text = Config.DiscordLink; label.TextColor3 = Config.Colors.TextSecondary; label.TextSize = 14; return button end
local function CreateHistoryEntry(parent, text, clickCallback) local button = Instance.new("TextButton", parent); button.BackgroundColor3 = Config.Colors.Secondary; button.Size = UDim2.new(1, 0, 0, 30); button.Font = Enum.Font.Gotham; button.Text = text; button.TextColor3 = Config.Colors.TextSecondary; button.TextSize = 14; Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6); button.MouseButton1Click:Connect(clickCallback); return button end
local function ShowNotification(message) NotificationSound:Play(); local notifFrame = Instance.new("Frame", ScreenGui); notifFrame.BackgroundColor3 = Config.Colors.Primary; notifFrame.Size = UDim2.new(0, 300, 0, 65); notifFrame.Position = UDim2.new(1, -315, 1, 75); notifFrame.AnchorPoint = Vector2.new(0, 1); Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8); local notifLabel = Instance.new("TextLabel", notifFrame); notifLabel.BackgroundTransparency = 1; notifLabel.Size = UDim2.new(1, 0, 1, 0); notifLabel.Font = Enum.Font.Gotham; notifLabel.Text = message; notifLabel.TextColor3 = Config.Colors.TextPrimary; notifLabel.TextSize = 14; notifLabel.TextWrapped = true; notifLabel.TextXAlignment = Enum.TextXAlignment.Center; notifLabel.TextYAlignment = Enum.TextYAlignment.Center; local padding = Instance.new("UIPadding", notifLabel); padding.PaddingLeft = UDim.new(0, 10); padding.PaddingRight = UDim.new(0, 10); notifFrame:TweenPosition(UDim2.new(1, -315, 1, -15), "Out", "Back", 0.4); task.wait(3); notifFrame:TweenPosition(UDim2.new(1, -315, 1, 75), "In", "Back", 0.4, true, function() notifFrame:Destroy() end) end

-- SEKMELER VE SAYFALAR
local tabs, pages, indicators = {}, {}, {} -- [[ YENİ: Göstergeler için 'indicators' tablosu ]]
local TrollTab, TrollIndicator = CreateTabButton("Troll"); local OyuncuTab, OyuncuIndicator = CreateTabButton("Oyuncu"); local ESPTab, ESPIndicator = CreateTabButton("ESP"); local BilgiTab, BilgiIndicator = CreateTabButton("Bilgi")
table.insert(tabs, TrollTab); table.insert(indicators, TrollIndicator)
table.insert(tabs, OyuncuTab); table.insert(indicators, OyuncuIndicator)
table.insert(tabs, ESPTab); table.insert(indicators, ESPIndicator)
table.insert(tabs, BilgiTab); table.insert(indicators, BilgiIndicator)

-- TROLL SAYFASI
local TrollPage = CreatePage("TrollPage", true); TrollPage.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local TrollUsernameBox = CreateTextBox(TrollPage, "Kullanıcı adı"); TrollUsernameBox.LayoutOrder = 1
local TrollButtonContainer = Instance.new("Frame", TrollPage); TrollButtonContainer.LayoutOrder = 2; TrollButtonContainer.BackgroundTransparency = 1; TrollButtonContainer.Size = UDim2.new(1, 0, 0, 35); local TrollButtonLayout = Instance.new("UIListLayout", TrollButtonContainer); TrollButtonLayout.FillDirection = Enum.FillDirection.Horizontal; TrollButtonLayout.Padding = UDim.new(0, 10)
local OndenTrollToggleButton = CreateCompactButton(TrollButtonContainer, "Önden"); local ArkadanTrollToggleButton = CreateCompactButton(TrollButtonContainer, "Arkadan")
local TrollHistoryFrame = Instance.new("ScrollingFrame", TrollPage); TrollHistoryFrame.LayoutOrder = 3; TrollHistoryFrame.BackgroundTransparency = 1; TrollHistoryFrame.Size = UDim2.new(1, 0, 0.4, 0); TrollHistoryFrame.CanvasSize = UDim2.new(); TrollHistoryFrame.BorderSizePixel = 0; local historyLayout = Instance.new("UIListLayout", TrollHistoryFrame); historyLayout.Padding = UDim.new(0, 5)

-- OYUNCU SAYFASI
local OyuncuPage = CreatePage("OyuncuPage", true); OyuncuPage.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local PlayerTeleportContainer = Instance.new("Frame", OyuncuPage); PlayerTeleportContainer.BackgroundTransparency = 1; PlayerTeleportContainer.Size = UDim2.new(1, 0, 0, 35); PlayerTeleportContainer.LayoutOrder = 1
local tpcLayout = Instance.new("UIListLayout", PlayerTeleportContainer); tpcLayout.FillDirection = Enum.FillDirection.Horizontal; tpcLayout.Padding = UDim.new(0, 10)
local PlayerTeleportBox = CreateTextBox(PlayerTeleportContainer, "Kullanıcı Adı"); PlayerTeleportBox.Size = UDim2.new(0.7, -5, 1, 0)
local PlayerTeleportButton = CreateWideButton(PlayerTeleportContainer, "Işınlan"); PlayerTeleportButton.Size = UDim2.new(0.3, -5, 1, 0)
local SpeedToggle = CreateFeatureToggle(OyuncuPage, "Hızlı Koşma", function(enabled) ShowNotification("Hızlı Koşma " .. (enabled and "Aktif" or "Devre Dışı")) end); SpeedToggle.LayoutOrder = 2
local SpeedSlider = CreateSlider(OyuncuPage, "Koşu Hızı", Config.DefaultWalkSpeed, Config.MaxWalkSpeed, 50); SpeedSlider.LayoutOrder = 3
local NoclipToggle = CreateFeatureToggle(OyuncuPage, "Duvardan Geçme", function(enabled) ShowNotification("Duvardan Geçme " .. (enabled and "Aktif" or "Devre Dışı")) end); NoclipToggle.LayoutOrder = 4
local InfinityJumpToggle = CreateFeatureToggle(OyuncuPage, "Sınırsız Zıpla", function(enabled) ShowNotification("Sınırsız Zıpla " .. (enabled and "Aktif" or "Devre Dışı")) end); InfinityJumpToggle.LayoutOrder = 5

-- ESP SAYFASI
local ESPPage = CreatePage("ESPPage", true);
local ESPNamesToggle = CreateFeatureToggle(ESPPage, "İsimler", function(enabled) States.ESP.Names = enabled; UpdateESP() end);
local ESPTracersToggle = CreateFeatureToggle(ESPPage, "Çizgiler", function(enabled) States.ESP.Tracers = enabled; UpdateESP() end);
local ESPGlowsToggle = CreateFeatureToggle(ESPPage, "Parlama", function(enabled) States.ESP.Glows = enabled; UpdateESP() end);

-- BİLGİ SAYFASI
local BilgiPage = CreatePage("BilgiPage", false)
local WelcomeLabel = Instance.new("TextLabel", BilgiPage); WelcomeLabel.Size = UDim2.new(1, 0, 0, 40); WelcomeLabel.BackgroundTransparency = 1; WelcomeLabel.Font = Enum.Font.GothamBold; WelcomeLabel.Text = "MEG PANEL'E HOŞ GELDİN!"; WelcomeLabel.TextColor3 = Config.Colors.Accent; WelcomeLabel.TextSize = 22; WelcomeLabel.Position = UDim2.new(0.5, 0, 0, 30); WelcomeLabel.AnchorPoint = Vector2.new(0.5, 0)
local DiscordButton = CreateDiscordElement(BilgiPage); DiscordButton.Size = UDim2.new(1, 0, 0, 60); DiscordButton.Position = UDim2.new(0.5, 0, 0.5, 0); DiscordButton.AnchorPoint = Vector2.new(0.5, 0.5)
local F5_Container = Instance.new("Frame", BilgiPage); F5_Container.Size = UDim2.new(1, -40, 0, 30); F5_Container.BackgroundTransparency = 1; F5_Container.Position = UDim2.new(0.5, 0, 1, -30); F5_Container.AnchorPoint = Vector2.new(0.5, 1); local F5_Layout = Instance.new("UIListLayout", F5_Container); F5_Layout.FillDirection = Enum.FillDirection.Horizontal; F5_Layout.VerticalAlignment = Enum.VerticalAlignment.Center; F5_Layout.Padding = UDim.new(0, 10); F5_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local F5_Label = Instance.new("TextLabel", F5_Container); F5_Label.Size = UDim2.new(0, 160, 1, 0); F5_Label.BackgroundTransparency = 1; F5_Label.Font = Enum.Font.Gotham; F5_Label.Text = "Paneli küçült/büyüt:"; F5_Label.TextColor3 = Config.Colors.TextSecondary; F5_Label.TextSize = 14; F5_Label.TextXAlignment = Enum.TextXAlignment.Right
local F5_Keycap = Instance.new("Frame", F5_Container); F5_Keycap.Size = UDim2.new(0, 40, 0, 25); F5_Keycap.BackgroundColor3 = Config.Colors.Secondary; Instance.new("UICorner", F5_Keycap).CornerRadius = UDim.new(0, 4); local F5_KeycapLabel = Instance.new("TextLabel", F5_Keycap); F5_KeycapLabel.Size = UDim2.new(1, 0, 1, 0); F5_KeycapLabel.BackgroundTransparency = 1; F5_KeycapLabel.Font = Enum.Font.GothamBold; F5_KeycapLabel.Text = "F5"; F5_KeycapLabel.TextColor3 = Config.Colors.TextPrimary; F5_KeycapLabel.TextSize = 14

table.insert(pages, TrollPage); table.insert(pages, OyuncuPage); table.insert(pages, ESPPage); table.insert(pages, BilgiPage)

-- ÖZELLİK DURDURMA FONKSİYONLARI
local function StopOndenTroll() if not States.OndenTroll.running then return end; States.OndenTroll.running = false; if States.OndenTroll.loop then States.OndenTroll.loop:Disconnect() end; if States.OndenTroll.animTrack then States.OndenTroll.animTrack:Stop(); States.OndenTroll.animTrack:Destroy() end; if States.OndenTroll.originalGravity then workspace.Gravity = States.OndenTroll.originalGravity end; States.OndenTroll.loop, States.OndenTroll.animTrack, States.OndenTroll.target, States.OndenTroll.originalGravity = nil, nil, nil, nil; OndenTrollToggleButton.Text = "Önden" end
local function StopArkadanTroll() if not States.ArkadanTroll.running then return end; States.ArkadanTroll.running = false; if States.ArkadanTroll.loop then task.cancel(States.ArkadanTroll.loop) end; States.ArkadanTroll.loop = nil; ArkadanTrollToggleButton.Text = "Arkadan" end
local function StopSpeed() if not States.Speed.running then return end; States.Speed.running = false; local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = States.Speed.originalSpeed end end
local function StopNoclip() if not States.Noclip.running then return end; States.Noclip.running = false; if States.Noclip.loop then States.Noclip.loop:Disconnect(); States.Noclip.loop = nil end end
local function StopInfinityJump() if not States.InfinityJump.running then return end; States.InfinityJump.running = false; if States.InfinityJump.connection then States.InfinityJump.connection:Disconnect(); States.InfinityJump.connection = nil end end
function StopESP()
    if States.ESP.loop then States.ESP.loop:Disconnect(); States.ESP.loop = nil end
    ESP_Container:ClearAllChildren(); for _, p in ipairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESP_Glow") then p.Character.ESP_Glow:Destroy() end end; States.ESP.drawings = {}
end

-- GUI MANTIĞI
-- [[ DEĞİŞTİRİLDİ: Sekme değiştirme fonksiyonu gösterge animasyonunu da içeriyor ]]
local function SwitchTab(tabToActivate)
    if activeTab == tabToActivate then return end
    for i, tab in ipairs(tabs) do
        local page = pages[i]
        local indicator = indicators[i]
        if tab == tabToActivate then
            page.Visible = true
            activeTab = tab
            TweenService:Create(tab, TweenInfo.new(0.2), { TextColor3 = Config.Colors.TextPrimary }):Play()
            indicator:TweenSize(UDim2.new(0, 4, 1, 0), "Out", "Quad", 0.2)
        else
            page.Visible = false
            TweenService:Create(tab, TweenInfo.new(0.2), { TextColor3 = Config.Colors.TextSecondary }):Play()
            indicator:TweenSize(UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.2)
        end
    end
end
for i, tab in ipairs(tabs) do tab.MouseButton1Click:Connect(function() SwitchTab(tab) end) end

local minimized = false
local function ToggleMinimize()
    minimized = not minimized; Container.Visible = not minimized
    if minimized then if MainFrame.Position.Y.Scale < 1 then originalPosition = MainFrame.Position end; Title.Text = Config.DiscordLink; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; titlePadding.PaddingLeft = UDim.new(0, 10); MainFrame:TweenSize(UDim2.new(0, 240, 0, 35), "Out", "Quad", 0.2); MainFrame:TweenPosition(UDim2.new(1, -255, 1, -50), "Out", "Quad", 0.2)
    else Title.Text = "MEG PANEL"; Title.TextSize = 18; Title.TextXAlignment = Enum.TextXAlignment.Center; titlePadding.PaddingLeft = UDim.new(0, 0); MainFrame:TweenSize(UDim2.new(0, 500, 0, 300), "Out", "Quad", 0.2); MainFrame:TweenPosition(originalPosition, "Out", "Quad", 0.2) end
end
MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)

local function FullShutdown() StopOndenTroll(); StopArkadanTroll(); StopSpeed(); StopNoclip(); StopInfinityJump(); StopESP(); task.wait(0.1); ScreenGui:Destroy() end
CloseButton.MouseButton1Click:Connect(FullShutdown)
UserInputService.InputBegan:Connect(function(input, gpe) if gpe then return end; if input.KeyCode == Enum.KeyCode.F5 then if f5Cooldown then return end; f5Cooldown = true; ToggleMinimize(); task.wait(0.5); f5Cooldown = false end end)

-- SÜRÜKLEME MANTIĞI
local dragging = false
local dragStart, frameStart
Title.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; frameStart = MainFrame.Position; local moveConnection, releaseConnection; moveConnection = UserInputService.InputChanged:Connect(function(moveInput) if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then local delta = moveInput.Position - dragStart; MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y) end end); releaseConnection = UserInputService.InputEnded:Connect(function(releaseInput) if releaseInput.UserInputType == Enum.UserInputType.MouseButton1 or releaseInput.UserInputType == Enum.UserInputType.Touch then dragging = false; moveConnection:Disconnect(); releaseConnection:Disconnect() end end) end end)
Title.MouseButton1Click:Connect(function() if minimized and setclipboard then setclipboard(Config.DiscordLink); ShowNotification("Discord linki kopyalandı!") end end)

-- ÖZELLİK FONKSİYONLARI
local function FindTargetPlayer(name) local victim = name:lower(); if victim == "" then return nil end; for _, p in ipairs(Players:GetPlayers()) do if p.Name:lower():find(victim, 1, true) or p.DisplayName:lower():find(victim, 1, true) then return p end end; return nil end
local function UpdateTrollHistoryList() TrollHistoryFrame:ClearAllChildren(); for _, name in ipairs(trollHistory) do CreateHistoryEntry(TrollHistoryFrame, name, function() TrollUsernameBox.Text = name end) end end

-- TROLL
local function HandleTroll(target)
    if not target then return end
    if not table.find(trollHistory, target.Name) then
        table.insert(trollHistory, 1, target.Name)
        if #trollHistory > 3 then
            table.remove(trollHistory, 4)
        end
        UpdateTrollHistoryList()
    end
end
OndenTrollToggleButton.MouseButton1Click:Connect(function() if States.OndenTroll.running then StopOndenTroll() else StopArkadanTroll(); local target = FindTargetPlayer(TrollUsernameBox.Text); HandleTroll(target); if not target then return end; States.OndenTroll.target = target; local lpc, hrp, trp = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), target.Character and target.Character:FindFirstChild("HumanoidRootPart"); if not (lpc and hrp and trp) then return end; States.OndenTroll.running = true; OndenTrollToggleButton.Text = "Durdur"; States.OndenTroll.originalGravity = workspace.Gravity; workspace.Gravity = 0; task.spawn(function() while States.OndenTroll.running and hrp and hrp.Position.Y <= 44 do hrp.CFrame *= CFrame.new(0, 1.5, 0); task.wait() end end); task.wait(1); States.OndenTroll.loop = RunService.Stepped:Connect(function() if hrp and trp and trp.Parent then hrp.CFrame = trp.CFrame * CFrame.new(0, 2.3, -1.1) * CFrame.Angles(0, math.pi, 0); hrp.Velocity = Vector3.new() else StopOndenTroll() end end); task.wait(1); local anim = Instance.new('Animation'); anim.AnimationId = "rbxassetid://5918726674"; if lpc:FindFirstChildOfClass("Humanoid") then States.OndenTroll.animTrack = lpc.Humanoid.Animator:LoadAnimation(anim); States.OndenTroll.animTrack:Play() end end end)
ArkadanTrollToggleButton.MouseButton1Click:Connect(function() if States.ArkadanTroll.running then StopArkadanTroll() else StopOndenTroll(); local target = FindTargetPlayer(TrollUsernameBox.Text); HandleTroll(target); if not target or not target.Character then return end; States.ArkadanTroll.target = target; States.ArkadanTroll.running = true; ArkadanTrollToggleButton.Text = "Durdur"; States.ArkadanTroll.loop = task.spawn(function() while States.ArkadanTroll.running do local cr, tr = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart, States.ArkadanTroll.target and States.ArkadanTroll.target.Character and States.ArkadanTroll.target.Character.HumanoidRootPart; if not(cr and tr and tr.Parent) then break end; local tf = TweenService:Create(cr, TweenInfo.new(0.2), {CFrame = tr.CFrame * CFrame.new(0, 0, 1)}); tf:Play(); tf.Completed:Wait(); if not States.ArkadanTroll.running then break end; local tb = TweenService:Create(cr, TweenInfo.new(0.2), {CFrame = tr.CFrame * CFrame.new(0, 0, 2.5)}); tb:Play(); tb.Completed:Wait() end; StopArkadanTroll() end) end end)

-- OYUNCU
SpeedToggle.MouseButton1Click:Connect(function() if States.Speed.running then StopSpeed() else States.Speed.running = true; local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if not hum then StopSpeed(); return end; States.Speed.originalSpeed = hum.WalkSpeed; hum.WalkSpeed = SpeedSlider.Value() end end)
SpeedSlider.ValueChanged:Connect(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum and States.Speed.running then hum.WalkSpeed = SpeedSlider.Value() end end)
NoclipToggle.MouseButton1Click:Connect(function() if States.Noclip.running then StopNoclip() else States.Noclip.running = true; States.Noclip.loop = RunService.Stepped:Connect(function() if LocalPlayer.Character then for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end end)
InfinityJumpToggle.MouseButton1Click:Connect(function() if States.InfinityJump.running then StopInfinityJump() else States.InfinityJump.running = true; States.InfinityJump.connection = UserInputService.JumpRequest:Connect(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) end end)
PlayerTeleportButton.MouseButton1Click:Connect(function() local target = FindTargetPlayer(PlayerTeleportBox.Text); if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame; ShowNotification(target.Name .. " adlı oyuncuya ışınlanıldı.") else ShowNotification("Oyuncu bulunamadı veya ışınlanılamadı.") end end)

-- ESP
function UpdateESP()
    local anyOn = States.ESP.Names or States.ESP.Tracers or States.ESP.Glows
    if anyOn and not States.ESP.loop then
        States.ESP.loop = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            for player, data in pairs(States.ESP.drawings) do
                if not player.Parent or not player:IsA("Player") then if data.NameLabel then data.NameLabel:Destroy() end; if data.TracerLine then data.TracerLine:Destroy() end; if data.Highlight then data.Highlight:Destroy() end; States.ESP.drawings[player] = nil end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                if player ~= LocalPlayer and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local root = char.HumanoidRootPart; local head = char:FindFirstChild("Head"); local data = States.ESP.drawings[player] or {}; States.ESP.drawings[player] = data
                    local screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
                    if States.ESP.Names and onScreen and head then
                        if not data.NameLabel then data.NameLabel = Instance.new("TextLabel", ESP_Container); data.NameLabel.Font = Enum.Font.Gotham; data.NameLabel.TextSize = 14; data.NameLabel.TextColor3 = Config.Colors.TextPrimary; data.NameLabel.BackgroundTransparency = 1; data.NameLabel.TextStrokeTransparency = 0.5; data.NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0); data.NameLabel.AnchorPoint = Vector2.new(0.5, 1) end
                        local headPos = cam:WorldToViewportPoint(head.Position)
                        data.NameLabel.Text = player.DisplayName .. " ["..math.floor((root.Position - cam.CFrame.Position).Magnitude).."m]"; data.NameLabel.Position = UDim2.fromOffset(headPos.X, headPos.Y - 20); data.NameLabel.Visible = true
                    elseif data.NameLabel then data.NameLabel.Visible = false end
                    if States.ESP.Tracers and onScreen then
                        if not data.TracerLine then data.TracerLine = Instance.new("Frame", ESP_Container); data.TracerLine.BackgroundColor3 = Config.Colors.Accent; data.TracerLine.BorderSizePixel = 0; data.TracerLine.AnchorPoint = Vector2.new(0.5, 0.5) end
                        local startPoint = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y); local endPoint = Vector2.new(screenPos.X, screenPos.Y); local distance = (startPoint - endPoint).Magnitude; local position = (startPoint + endPoint) / 2; local rotation = math.deg(math.atan2(endPoint.Y - startPoint.Y, endPoint.X - startPoint.X))
                        data.TracerLine.Size = UDim2.fromOffset(distance, 1.5); data.TracerLine.Position = UDim2.fromOffset(position.X, position.Y); data.TracerLine.Rotation = rotation; data.TracerLine.Visible = true
                    elseif data.TracerLine then data.TracerLine.Visible = false end
                    if States.ESP.Glows then
                        if not data.Highlight or not data.Highlight.Parent then data.Highlight = Instance.new("Highlight", char); data.Highlight.Name = "ESP_Glow"; data.Highlight.FillColor = Config.Colors.White; data.Highlight.OutlineTransparency = 1; data.Highlight.FillTransparency = 0.5 end
                        data.Highlight.Enabled = true
                    elseif data.Highlight then data.Highlight.Enabled = false end
                else
                    if States.ESP.drawings[player] then
                        local data = States.ESP.drawings[player]; if data.NameLabel then data.NameLabel:Destroy() end; if data.TracerLine then data.TracerLine:Destroy() end; if data.Highlight then data.Highlight:Destroy() end; States.ESP.drawings[player] = nil
                    end
                end
            end
        end)
    elseif not anyOn and States.ESP.loop then
        StopESP()
    end
end

-- BİLGİ
DiscordButton.MouseButton1Click:Connect(function() if setclipboard then setclipboard(Config.DiscordLink); ShowNotification("Discord linki kopyalandı!") end end)

-- BAŞLANGIÇ
SwitchTab(BilgiTab)
ShowNotification("MEG PANEL yüklendi!")
