
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GameData"))

local Tsunami = {}

Tsunami.OnWarning = nil
Tsunami.OnSweepStart = nil
Tsunami.OnPlayerSweep = nil
Tsunami.OnWaveEnd = nil

local state = "Idle"
local wall, foam

local function buildWave()
	local folder = Instance.new("Folder")
	folder.Name = "TsunamiWave"
	folder.Parent = workspace
	wall = Instance.new("Part")
	wall.Name = "WaveWall"
	wall.Size = Vector3.new(10, 64, 520)
	wall.Color = Color3.fromRGB(35, 130, 225)
	wall.Material = Enum.Material.Glass
	wall.Transparency = 1
	wall.Anchored = true
	wall.CanCollide = false
	wall.CanQuery = false
	wall.CanTouch = false
	wall.CFrame = CFrame.new(GameData.Wave.FromX, 26, 0)
	wall.Parent = folder
	foam = Instance.new("Part")
	foam.Name = "WaveFoam"
	foam.Size = Vector3.new(11, 7, 520)
	foam.Color = Color3.fromRGB(240, 250, 255)
	foam.Material = Enum.Material.SmoothPlastic
	foam.Transparency = 1
	foam.Anchored = true
	foam.CanCollide = false
	foam.CanQuery = false
	foam.CanTouch = false
	foam.CFrame = CFrame.new(GameData.Wave.FromX, 57, 0)
	foam.Parent = folder
end

local function setWaveX(x)
	wall.CFrame = CFrame.new(x, 26, 0)
	foam.CFrame = CFrame.new(x, 57, 0)
end

local function runSequence()
	if state ~= "Idle" then
		return
	end
	if not wall then
		buildWave()
	end
	state = "Warning"
	setWaveX(GameData.Wave.FromX)
	wall.Transparency = 0.3
	foam.Transparency = 0.1
	if Tsunami.OnWarning then
		Tsunami.OnWarning(GameData.Wave.Warning)
	end
	task.wait(GameData.Wave.Warning)

	state = "Sweeping"
	if Tsunami.OnSweepStart then
		Tsunami.OnSweepStart()
	end
	local checked = {}
	local started = os.clock()
	local duration = GameData.Wave.SweepTime
	while true do
		local progress = (os.clock() - started) / duration
		if progress >= 1 then
			break
		end
		local waveX = GameData.Wave.FromX + (GameData.Wave.ToX - GameData.Wave.FromX) * progress
		setWaveX(waveX)
		for _, player in ipairs(Players:GetPlayers()) do
			if not checked[player] then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and root.Position.X <= waveX then
					checked[player] = true
					if Tsunami.OnPlayerSweep then
						Tsunami.OnPlayerSweep(player)
					end
				end
			end
		end
		RunService.Heartbeat:Wait()
	end
	setWaveX(GameData.Wave.ToX)

	wall.Transparency = 1
	foam.Transparency = 1
	state = "Idle"
	if Tsunami.OnWaveEnd then
		Tsunami.OnWaveEnd()
	end
end

function Tsunami.Start()
	if not wall then
		buildWave()
	end
	task.spawn(function()
		task.wait(GameData.Wave.FirstDelay)
		while true do
			runSequence()
			task.wait(GameData.Wave.Interval)
		end
	end)
end

function Tsunami.TriggerNow(_arg)
	task.spawn(runSequence)
end

return Tsunami
