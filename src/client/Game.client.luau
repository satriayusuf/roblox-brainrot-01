
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameData"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local stats = player:WaitForChild("leaderstats")
local notifyRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Notify")

local gui = Instance.new("ScreenGui")
gui.Name = "CoveHud"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function label(parent, name, size, position, anchor, textSize, color, font)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = position
	l.AnchorPoint = anchor or Vector2.new(0, 0)
	l.BackgroundTransparency = 1
	l.Font = font or Enum.Font.FredokaOne
	l.TextSize = textSize
	l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	l.TextStrokeTransparency = 0.5
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local panel = Instance.new("Frame")
panel.Name = "StatsPanel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -14, 0, 14)
panel.Size = UDim2.fromOffset(262, 112)
panel.BackgroundColor3 = Color3.fromRGB(20, 35, 55)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local cashLabel = label(panel, "Cash", UDim2.new(1, -16, 0, 40), UDim2.new(0, 12, 0, 6), nil, 30, Color3.fromRGB(140, 255, 150))
local perSecLabel = label(panel, "PerSec", UDim2.new(1, -16, 0, 26), UDim2.new(0, 12, 0, 48), nil, 19, Color3.fromRGB(255, 235, 160))
local rebirthLabel = label(panel, "Rebirths", UDim2.new(1, -16, 0, 26), UDim2.new(0, 12, 0, 76), nil, 19, Color3.fromRGB(150, 230, 255))

local function refreshStats()
	cashLabel.Text = "💰 " .. GameData.FormatCash(stats.Cash.Value)
	perSecLabel.Text = "📈 +" .. GameData.FormatCash(stats.PerSec.Value) .. " /s"
	local rebirths = stats.Rebirths.Value
	rebirthLabel.Text = string.format("⭐ Rebirths: %d  (x%.1f income)", rebirths, GameData.MultiplierFor(rebirths))
end
stats.Cash.Changed:Connect(refreshStats)
stats.PerSec.Changed:Connect(refreshStats)
stats.Rebirths.Changed:Connect(refreshStats)
refreshStats()

local hint = label(gui, "Hint", UDim2.new(0, 520, 0, 24), UDim2.new(0, 14, 1, -34), nil, 15, Color3.fromRGB(255, 255, 255))
hint.Text = "🛒 Buy off the belt - 🥷 steal from unlocked bases - 🔒 lock yours - 🌊 hide in YOUR base when the wave comes!"

local carryLabel = label(gui, "Carrying", UDim2.new(0, 700, 0, 30), UDim2.new(0.5, 0, 1, -76), Vector2.new(0.5, 0), 20, Color3.fromRGB(255, 220, 120))
carryLabel.TextXAlignment = Enum.TextXAlignment.Center
carryLabel.Text = ""

local toast = label(gui, "Toast", UDim2.new(0, 860, 0, 44), UDim2.new(0.5, 0, 0.32, 0), Vector2.new(0.5, 0.5), 30)
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.Text = ""
local toastToken = 0
local function showToast(text, color, seconds)
	toastToken += 1
	local token = toastToken
	toast.Text = text
	toast.TextColor3 = color
	toast.TextTransparency = 0
	task.spawn(function()
		task.wait(seconds)
		if token ~= toastToken then
			return
		end
		for i = 1, 10 do
			if token ~= toastToken then
				return
			end
			toast.TextTransparency = i / 10
			task.wait(0.04)
		end
	end)
end

local banner = Instance.new("Frame")
banner.Name = "WaveBanner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 14)
banner.Size = UDim2.fromOffset(620, 58)
banner.BackgroundColor3 = Color3.fromRGB(200, 30, 40)
banner.BackgroundTransparency = 0.15
banner.BorderSizePixel = 0
banner.Visible = false
banner.Parent = gui
local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(0, 14)
bannerCorner.Parent = banner
local bannerLabel = label(banner, "Text", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), nil, 30)
bannerLabel.TextXAlignment = Enum.TextXAlignment.Center
bannerLabel.TextYAlignment = Enum.TextYAlignment.Center

local waveToken = 0
local function startCountdown(seconds)
	waveToken += 1
	local token = waveToken
	banner.Visible = true
	task.spawn(function()
		for s = seconds, 1, -1 do
			if token ~= waveToken then
				return
			end
			bannerLabel.Text = "🌊 TSUNAMI IN " .. s .. " - GET TO YOUR BASE! 🌊"
			task.wait(1)
		end
	end)
end

local function watchPrompt(d)
	if d:IsA("ProximityPrompt") then
		local po = d:GetAttribute("PickUpOwner")
		if d:GetAttribute("StealOwner") == player.Name or (po and po ~= player.Name) then
			d.Enabled = false
			d:GetPropertyChangedSignal("Enabled"):Connect(function()
				if d.Enabled then
					d.Enabled = false
				end
			end)
		end
	end
end
workspace.DescendantAdded:Connect(watchPrompt)
for _, descendant in ipairs(workspace:GetDescendants()) do
	watchPrompt(descendant)
end

notifyRemote.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end
	if payload.Kind == "Info" then
		showToast(payload.Text, Color3.fromRGB(255, 255, 255), 2.5)
	elseif payload.Kind == "Stolen" then
		showToast("⚠ " .. payload.Text, Color3.fromRGB(255, 90, 90), 4.5)
	elseif payload.Kind == "Washed" then
		showToast("🌊 " .. payload.Text, Color3.fromRGB(140, 210, 255), 3.5)
	elseif payload.Kind == "Carrying" then
		carryLabel.Text = payload.Text
	elseif payload.Kind == "WaveWarning" then
		startCountdown(payload.Seconds or 10)
	elseif payload.Kind == "WaveSweep" then
		waveToken += 1
		banner.Visible = true
		bannerLabel.Text = "🌊 TSUNAMI! 🌊"
	elseif payload.Kind == "WaveEnd" then
		waveToken += 1
		banner.Visible = false
	end
end)
