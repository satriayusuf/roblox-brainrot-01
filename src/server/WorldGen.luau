
local GameData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GameData"))

local WorldGen = {}

local TOP_Y = 1
local WHT = Color3.fromRGB(255, 255, 255)
local BASE_COLORS = {
	Color3.fromRGB(255, 110, 110), Color3.fromRGB(255, 170, 70), Color3.fromRGB(255, 225, 90),
	Color3.fromRGB(110, 220, 120), Color3.fromRGB(90, 200, 235), Color3.fromRGB(110, 140, 255),
	Color3.fromRGB(190, 120, 255), Color3.fromRGB(255, 130, 200),
}

local function part(parent, name, size, cframe, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if transparency then
		p.Transparency = transparency
	end
	p.Anchored = true
	p.Parent = parent
	return p
end

local function sign(parent, name, size, cframe, title, sub, bg, titleColor)
	local board = part(parent, name, size, cframe, bg, Enum.Material.SmoothPlastic)
	board.CanCollide = false
	local labels = {}
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.Parent = board
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.new(1, 0, sub and 0.58 or 1, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.Font = Enum.Font.FredokaOne
		titleLabel.TextScaled = true
		titleLabel.TextColor3 = titleColor or WHT
		titleLabel.Parent = gui
		table.insert(labels, titleLabel)
		if sub then
			local subLabel = Instance.new("TextLabel")
			subLabel.Name = "Sub"
			subLabel.Position = UDim2.new(0, 0, 0.58, 0)
			subLabel.Size = UDim2.new(1, 0, 0.42, 0)
			subLabel.BackgroundTransparency = 1
			subLabel.Text = sub
			subLabel.Font = Enum.Font.FredokaOne
			subLabel.TextScaled = true
			subLabel.TextColor3 = WHT
			subLabel.Parent = gui
			table.insert(labels, subLabel)
		end
	end
	return board, labels
end

local function prompt(parent, actionText, objectText, distance)
	local pr = Instance.new("ProximityPrompt")
	pr.ActionText = actionText
	pr.ObjectText = objectText
	pr.HoldDuration = 0
	pr.MaxActivationDistance = distance or 12
	pr.RequiresLineOfSight = false
	pr.Parent = parent
	return pr
end

local function palm(parent, x, z, lean)
	local group = Instance.new("Model")
	group.Name = "Palm"
	group.Parent = parent
	local trunk = part(group, "Trunk", Vector3.new(6, 0.8, 0.8), CFrame.new(x, TOP_Y + 2.6, z) * CFrame.Angles(0, 0, math.rad(90) + lean), Color3.fromRGB(140, 100, 60), Enum.Material.Wood)
	trunk.Shape = Enum.PartType.Cylinder
	local topX, topZ = x + math.sin(lean) * 2.2, z
	for i = 1, 5 do
		local a = (i - 1) * (math.pi * 2 / 5)
		local leaf = part(group, "Leaf", Vector3.new(3.6, 0.4, 1.3), CFrame.new(topX + math.cos(a) * 1.5, TOP_Y + 5.6, topZ + math.sin(a) * 1.5) * CFrame.Angles(0, -a, math.rad(18)), Color3.fromRGB(60, 175, 75), Enum.Material.Grass)
		leaf.Shape = Enum.PartType.Ball
	end
end

function WorldGen.Build()
	local starterBaseplate = workspace:FindFirstChild("Baseplate")
	if starterBaseplate then
		starterBaseplate.Position = Vector3.new(0, -80, 0)
	end

	local world = { Bases = {} }
	local root = Instance.new("Folder")
	root.Name = "Cove"
	root.Parent = workspace

	local sea = part(root, "Sea", Vector3.new(720, 1, 720), CFrame.new(0, 0.1, 0), Color3.fromRGB(26, 148, 218), Enum.Material.Glass, 0.35)
	sea.CanCollide = false
	part(root, "IslandSkirt", Vector3.new(126, 7, 126), CFrame.new(0, -3.4, 0), Color3.fromRGB(120, 105, 90), Enum.Material.Rock)
	part(root, "Plaza", Vector3.new(120, 2, 120), CFrame.new(0, 0, 0), Color3.fromRGB(106, 190, 64), Enum.Material.Grass)
	local wood = Color3.fromRGB(165, 120, 75)
	part(root, "BoardwalkN", Vector3.new(128, 2.2, 6), CFrame.new(0, 0, -61), wood, Enum.Material.WoodPlanks)
	part(root, "BoardwalkS", Vector3.new(128, 2.2, 6), CFrame.new(0, 0, 61), wood, Enum.Material.WoodPlanks)
	part(root, "BoardwalkE", Vector3.new(6, 2.2, 116), CFrame.new(61, 0, 0), wood, Enum.Material.WoodPlanks)
	part(root, "BoardwalkW", Vector3.new(6, 2.2, 116), CFrame.new(-61, 0, 0), wood, Enum.Material.WoodPlanks)
	local medallion = part(root, "Medallion", Vector3.new(0.25, 34, 34), CFrame.new(0, TOP_Y + 0.06, -4) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 127, 100), Enum.Material.SmoothPlastic)
	medallion.Shape = Enum.PartType.Cylinder

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "CoveSpawn"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(0, TOP_Y + 0.1, 44)
	spawn.Color = Color3.fromRGB(140, 255, 170)
	spawn.Material = Enum.Material.Neon
	spawn.Transparency = 0.35
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Parent = root
	world.SpawnPos = Vector3.new(0, TOP_Y + 3, 44)
	sign(root, "WelcomeSign", Vector3.new(30, 6.5, 0.8), CFrame.new(0, TOP_Y + 5.5, 33), "TSUNAMI BRAINROT COVE", "Buy off the belt - steal from rivals - lock your base - beat the wave!", Color3.fromRGB(30, 110, 180))

	local machine = Instance.new("Model")
	machine.Name = "EggOMatic"
	machine.Parent = root
	part(machine, "Cabinet", Vector3.new(10, 5, 6), CFrame.new(0, TOP_Y + 2.5, -8), Color3.fromRGB(235, 70, 80))
	part(machine, "Counter", Vector3.new(11, 0.6, 7), CFrame.new(0, TOP_Y + 5.3, -8), Color3.fromRGB(255, 205, 70), Enum.Material.Metal)
	local dome = part(machine, "Dome", Vector3.new(7.5, 7.5, 7.5), CFrame.new(0, TOP_Y + 8.6, -8), Color3.fromRGB(200, 240, 255), Enum.Material.Glass, 0.45)
	dome.Shape = Enum.PartType.Ball
	dome.CanCollide = false
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 220, 150)
	glow.Range = 24
	glow.Brightness = 1.5
	glow.Parent = dome
	for i, eggColor in ipairs({ Color3.fromRGB(240, 230, 200), Color3.fromRGB(120, 220, 255), Color3.fromRGB(255, 120, 200) }) do
		local egg = part(machine, "DisplayEgg", Vector3.new(1.7, 2.2, 1.7), CFrame.new((i - 2) * 2.2, TOP_Y + 6.6, -8), eggColor)
		egg.Shape = Enum.PartType.Ball
	end
	sign(machine, "MachineSign", Vector3.new(13, 3.2, 0.6), CFrame.new(0, TOP_Y + 13.6, -8), "EGG-O-MATIC (RETIRED)", "The belt does the hatching now", Color3.fromRGB(150, 40, 140))

	local belt = Instance.new("Model")
	belt.Name = "ConveyorBelt"
	belt.Parent = root
	part(belt, "BeltBed", Vector3.new(106, 1, 5), CFrame.new(0, TOP_Y + 0.5, 16), Color3.fromRGB(48, 48, 58), Enum.Material.Metal)
	for _, side in ipairs({ -1, 1 }) do
		part(belt, "BeltRail", Vector3.new(106, 0.35, 0.4), CFrame.new(0, TOP_Y + 1.1, 16 + side * 2.6), Color3.fromRGB(150, 150, 165), Enum.Material.Metal)
		part(belt, "BeltStripe", Vector3.new(106, 0.14, 0.5), CFrame.new(0, TOP_Y + 1.03, 16 + side * 1.9), Color3.fromRGB(255, 205, 70), Enum.Material.Neon)
	end
	for _, x in ipairs({ -52, 52 }) do
		part(belt, "BeltPost", Vector3.new(1, 3.4, 6.4), CFrame.new(x, TOP_Y + 1.7, 16), Color3.fromRGB(90, 90, 105), Enum.Material.Metal)
	end
	sign(belt, "BeltSign", Vector3.new(15, 3, 0.6), CFrame.new(-52, TOP_Y + 5.6, 16), "BRAINROT BELT", "Buy one before it swims away!", Color3.fromRGB(30, 110, 180))
	world.Belt = { Z = 16, FromX = -48, ToX = 48, TopY = TOP_Y + 1 }

	local shrine = Instance.new("Model")
	shrine.Name = "RebirthShrine"
	shrine.Parent = root
	local shrineBase = part(shrine, "ShrineBase", Vector3.new(0.5, 15, 15), CFrame.new(0, TOP_Y + 0.25, -48) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(80, 70, 120), Enum.Material.Slate)
	shrineBase.Shape = Enum.PartType.Cylinder
	for _, side in ipairs({ -1, 1 }) do
		local pillar = Instance.new("WedgePart")
		pillar.Name = "ShrinePillar"
		pillar.Size = Vector3.new(1.6, 7, 1.6)
		pillar.CFrame = CFrame.new(side * 4.5, TOP_Y + 3.5, -48)
		pillar.Color = Color3.fromRGB(100, 90, 150)
		pillar.Material = Enum.Material.Slate
		pillar.Anchored = true
		pillar.Parent = shrine
	end
	local core = part(shrine, "ShrineCore", Vector3.new(2.8, 2.8, 2.8), CFrame.new(0, TOP_Y + 5.2, -48), Color3.fromRGB(120, 240, 255), Enum.Material.Neon)
	core.Shape = Enum.PartType.Ball
	core.CanCollide = false
	local coreLight = Instance.new("PointLight")
	coreLight.Color = Color3.fromRGB(120, 240, 255)
	coreLight.Range = 22
	coreLight.Brightness = 2
	coreLight.Parent = core
	sign(shrine, "ShrineSign", Vector3.new(13, 2.8, 0.5), CFrame.new(0, TOP_Y + 9.6, -48), "REBIRTH SHRINE", "Trade " .. GameData.FormatCash(GameData.RebirthCost) .. " + your crew for +50% income, forever", Color3.fromRGB(50, 40, 90))
	world.ShrinePrompt = prompt(core, "Rebirth", "Needs " .. GameData.FormatCash(GameData.RebirthCost), 14)

	for i = 1, 8 do
		local a = math.rad((i - 1) * 45)
		local px, pz = math.cos(a) * 100, math.sin(a) * 100
		local baseCFrame = CFrame.lookAt(Vector3.new(px, 0, pz), Vector3.new(0, 0, 0))
		local base = { Index = i, CFrame = baseCFrame, Center = Vector3.new(px, TOP_Y, pz), Pads = {}, Color = BASE_COLORS[i] }
		local model = Instance.new("Model")
		model.Name = "Base" .. i
		model.Parent = root
		part(model, "Platform", Vector3.new(36, 2, 24), baseCFrame, Color3.fromRGB(106, 190, 64), Enum.Material.Grass)
		-- Start at the plaza edge.
		local bl, bz = 30, -25
		if i % 2 == 0 then
			bl, bz = 5, -12.5
		end
		part(model, "Bridge", Vector3.new(8, 1, bl), baseCFrame * CFrame.new(0, 0.5, bz), wood, Enum.Material.WoodPlanks)
		part(model, "Trim", Vector3.new(36.6, 0.8, 24.6), baseCFrame * CFrame.new(0, 0.55, 0), base.Color, Enum.Material.Neon)
		part(model, "BackWall", Vector3.new(36, 3.2, 1), baseCFrame * CFrame.new(0, 2.6, 11.5), base.Color, Enum.Material.WoodPlanks)
		part(model, "SideWallL", Vector3.new(1, 3.2, 24), baseCFrame * CFrame.new(-17.5, 2.6, 0), base.Color, Enum.Material.WoodPlanks)
		part(model, "SideWallR", Vector3.new(1, 3.2, 24), baseCFrame * CFrame.new(17.5, 2.6, 0), base.Color, Enum.Material.WoodPlanks)
		local _, signLabels = sign(model, "OwnerSign", Vector3.new(17, 4.2, 0.6), baseCFrame * CFrame.new(0, 5.9, 11.5), "EMPTY BASE", "Join and it is yours", Color3.fromRGB(45, 45, 60))
		base.SetSign = function(title, sub)
			for _, label in ipairs(signLabels) do
				if label.Name == "Title" then
					label.Text = title
				else
					label.Text = sub
				end
			end
		end
		for padIndex = 1, GameData.MaxPads do
			local lx = -13.5 + ((padIndex - 1) % 4) * 9
			local lz = padIndex <= 4 and -5.5 or 5.5
			local padCFrame = baseCFrame * CFrame.new(lx, TOP_Y + 0.2, lz)
			local pad = part(model, "Pad" .. padIndex, Vector3.new(0.4, 4.6, 4.6), padCFrame * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(200, 200, 205), Enum.Material.SmoothPlastic)
			pad.Shape = Enum.PartType.Cylinder
			local pr = prompt(pad, "Place", "", 11)
			base.Pads[padIndex] = { Part = pad, Prompt = pr, CFrame = padCFrame }
		end

		local lockBtn = part(model, "LockButton", Vector3.new(1.1, 1.1, 1.1), baseCFrame * CFrame.new(15, TOP_Y + 0.55, -9), Color3.fromRGB(255, 90, 90), Enum.Material.Neon)
		lockBtn.Shape = Enum.PartType.Ball
		base.LockPrompt = prompt(lockBtn, "Lock Base", "", 10)
		local lockGui = Instance.new("BillboardGui")
		lockGui.Name = "LockGui"
		lockGui.Size = UDim2.fromOffset(150, 42)
		lockGui.StudsOffset = Vector3.new(0, 2.4, 0)
		lockGui.AlwaysOnTop = true
		lockGui.Parent = lockBtn
		local lockLabel = Instance.new("TextLabel")
		lockLabel.Size = UDim2.new(1, 0, 1, 0)
		lockLabel.BackgroundTransparency = 1
		lockLabel.Text = "🔓 READY"
		lockLabel.Font = Enum.Font.FredokaOne
		lockLabel.TextSize = 20
		lockLabel.TextColor3 = WHT
		lockLabel.TextStrokeTransparency = 0.4
		lockLabel.Parent = lockGui
		base.LockLabel = lockLabel
		base.Barriers = {}
		for _, spec in ipairs({
			{ Vector3.new(36, 11, 1), CFrame.new(0, TOP_Y + 5.5, -11.5) },
			{ Vector3.new(36, 11, 1), CFrame.new(0, TOP_Y + 5.5, 11.5) },
			{ Vector3.new(1, 11, 24), CFrame.new(-17.5, TOP_Y + 5.5, 0) },
			{ Vector3.new(1, 11, 24), CFrame.new(17.5, TOP_Y + 5.5, 0) },
		}) do
			local barrier = part(model, "Barrier", spec[1], baseCFrame * spec[2], Color3.fromRGB(120, 220, 255), Enum.Material.Glass, 1)
			barrier.CanCollide = false
			barrier.CanQuery = false
			barrier.CanTouch = false
			table.insert(base.Barriers, barrier)
		end
		base.SetBarriers = function(on)
			for _, barrier in ipairs(base.Barriers) do
				barrier.Transparency = on and 0.45 or 1
				barrier.CanCollide = on
			end
		end
		world.Bases[i] = base
	end

	local function bunting(x1, z1, x2, z2)
		local p1, p2 = Vector3.new(x1, TOP_Y + 6.3, z1), Vector3.new(x2, TOP_Y + 6.3, z2)
		local d = p2 - p1
		part(root, "Rope", Vector3.new(.09, .09, d.Magnitude), CFrame.lookAt((p1 + p2) / 2, p2), WHT)
		for i = 1, 9 do
			local t = i / 10
			local pos = p1:Lerp(p2, t) - Vector3.new(0, math.sin(t * math.pi) * .9 + .6, 0)
			part(root, "Flag", Vector3.new(.95, 1.1, .08), CFrame.new(pos) * CFrame.Angles(0, math.atan2(d.X, d.Z), 0), BASE_COLORS[i % 8 + 1])
		end
	end
	bunting(-52, -52, 52, -52)
	bunting(52, -52, 52, 52)
	bunting(52, 52, -52, 52)
	bunting(-52, 52, -52, -52)

	for _, spot in ipairs({ { -52, -52 }, { 52, -52 }, { -52, 52 }, { 52, 52 }, { -34, 55 }, { 34, 55 }, { -55, 20 }, { 55, -20 } }) do
		palm(root, spot[1], spot[2], math.rad(spot[1] > 0 and -6 or 6))
	end
	for i, spot in ipairs({ { -44, -30, 2.6 }, { -41, -33, 2 }, { 46, 28, 3 }, { 20, -52, 2.2 }, { -18, 50, 2.8 }, { 48, -34, 2.4 } }) do
		part(root, "Crate" .. i, Vector3.new(spot[3], spot[3], spot[3]), CFrame.new(spot[1], TOP_Y + spot[3] / 2, spot[2]) * CFrame.Angles(0, math.rad(i * 27), 0), Color3.fromRGB(175, 130, 80), Enum.Material.WoodPlanks)
	end
	for i, spot in ipairs({ { -24, 40, Color3.fromRGB(255, 100, 130) }, { 26, 42, Color3.fromRGB(90, 200, 255) }, { -46, 6, Color3.fromRGB(255, 205, 70) } }) do
		local pole = part(root, "UmbrellaPole" .. i, Vector3.new(3.6, 0.22, 0.22), CFrame.new(spot[1], TOP_Y + 1.8, spot[2]) * CFrame.Angles(0, 0, math.rad(90)), WHT)
		pole.Shape = Enum.PartType.Cylinder
		local top = part(root, "UmbrellaTop" .. i, Vector3.new(0.35, 5.2, 5.2), CFrame.new(spot[1], TOP_Y + 3.7, spot[2]) * CFrame.Angles(0, 0, math.rad(90)), spot[3])
		top.Shape = Enum.PartType.Cylinder
	end

	return world
end

return WorldGen
