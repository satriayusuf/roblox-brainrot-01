
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local GameData = require(Shared:WaitForChild("GameData"))
local CharacterFactory = require(script.Parent:WaitForChild("CharacterFactory"))
local Tsunami = require(script.Parent:WaitForChild("Tsunami"))

local GameServer = {}

local world
local notifyRemote
local catchesFolder
local states = {}
local beltEntries = {}
local dropped = {}
local idles = {}
local FULL = "Hands full! You can only carry one brainrot."

local function startIdle(model, cf)
	idles[model] = { CF = cf, Ph = math.random() * 6.3 }
end

local function stopIdle(model)
	idles[model] = nil
end

local function multiplier(st)
	return GameData.MultiplierFor(st.Rebirths)
end

local function perSec(st)
	return st.BaseIncome * multiplier(st)
end

local function notify(player, payload)
	if notifyRemote then
		notifyRemote:FireClient(player, payload)
	end
end

local function notifyAll(payload)
	if notifyRemote then
		notifyRemote:FireAllClients(payload)
	end
end

local function info(player, text)
	notify(player, { Kind = "Info", Text = text })
end

local function clearCarry(p)
	notify(p, { Kind = "Carrying", Text = "" })
end

local function rootOf(player)
	local ch = player.Character
	return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function faceCFrame(pos, target)
	local flat = Vector3.new(target.X, pos.Y, target.Z)
	if (flat - pos).Magnitude < 0.01 then
		flat = pos + Vector3.new(0, 0, 1)
	end
	return CFrame.lookAt(pos, flat) * CFrame.Angles(0, math.pi, 0)
end

-- Belt frame: faces +X, up +Y (yaw + banking roll).
local function beltCF(pos, roll)
	return CFrame.new(pos) * CFrame.Angles(0, math.pi / 2, roll or 0)
end

local function refreshStats(st)
	local stats = st.Player:FindFirstChild("leaderstats")
	if stats then
		stats.Cash.Value = math.floor(st.Cash)
		stats.PerSec.Value = math.floor(perSec(st))
		stats.Rebirths.Value = st.Rebirths
	end
	if st.Base then
		st.Base.SetSign(
			string.upper(st.Player.DisplayName) .. "'S BASE",
			string.format("Rebirths: %d (x%.1f)  -  %s/s  -  Pads %d/%d", st.Rebirths, multiplier(st), GameData.FormatCash(perSec(st)), st.PadsOwned, GameData.MaxPads)
		)
	end
end

local function setPadLook(base, padIndex, mode, rarityColor)
	local pad = base.Pads[padIndex]
	-- One neutral look for every empty pad.
	pad.Part.Color = mode == "Occupied" and rarityColor or Color3.fromRGB(205, 205, 210)
	pad.Part.Transparency = 0
end

local function resetPads(base)
	for padIndex = 1, GameData.MaxPads do
		local pad = base.Pads[padIndex]
		pad.Prompt.Enabled = false
		setPadLook(base, padIndex, padIndex <= GameData.BasePads and "Owned" or "Locked")
	end
end

local function refreshPads(st)
	local base = st.Base
	if not base then
		return
	end
	for padIndex = 1, GameData.MaxPads do
		local pad = base.Pads[padIndex]
		if st.Placed[padIndex] then
			pad.Prompt.Enabled = false
		elseif padIndex <= st.PadsOwned then
			pad.Prompt.Enabled = true
			pad.Prompt.ActionText = "Place"
			pad.Prompt.ObjectText = "Your pad"
			setPadLook(base, padIndex, "Owned")
		elseif padIndex == st.PadsOwned + 1 then
			pad.Prompt.Enabled = true
			pad.Prompt.ActionText = "Buy Pad"
			pad.Prompt.ObjectText = GameData.FormatCash(GameData.PadPrices[padIndex])
			setPadLook(base, padIndex, "Next")
		else
			pad.Prompt.Enabled = false
			setPadLook(base, padIndex, "Locked")
		end
	end
end

local function destroyModel(model)
	if model then
		stopIdle(model)
		model:Destroy()
	end
end

local function isInBase(pos, base)
	local localPos = base.CFrame:PointToObjectSpace(pos)
	return math.abs(localPos.X) <= 18 and math.abs(localPos.Z) <= 12
end

local function isLocked(base)
	return os.clock() < (base.LockUntil or 0)
end

local function refreshStealPrompts(base)
	local st = base.Owner and states[base.Owner]
	if not st then
		return
	end
	for _, placed in pairs(st.Placed) do
		if placed.Prompt then
			placed.Prompt.Enabled = not isLocked(base)
		end
	end
end

local function onLockTriggered(base, player)
	local st = states[player]
	if not st then
		return
	end
	if st.Base ~= base then
		info(player, "Only the owner can lock this base!")
		return
	end
	local now = os.clock()
	if isLocked(base) then
		info(player, "Already locked - " .. math.ceil(base.LockUntil - now) .. "s to go!")
		return
	end
	if now < (base.LockReadyAt or 0) then
		info(player, "Lock recharging - " .. math.ceil(base.LockReadyAt - now) .. "s left!")
		return
	end
	base.LockUntil = now + GameData.Lock.Base + GameData.Lock.PerRebirth * st.Rebirths
	base.SetBarriers(true)
	refreshStealPrompts(base)
	info(player, "Base LOCKED for " .. math.ceil(base.LockUntil - now) .. "s - your crew is safe!")
end

local function carryNow(st, model, infoTable)
	st.Carrying = model
	st.CarryingInfo = infoTable
	notify(st.Player, { Kind = "Carrying", Text = "Carrying " .. infoTable.Def.Name .. " - get it home to your base!" })
end

local function removeBeltEntry(entry)
	for i, e in ipairs(beltEntries) do
		if e == entry then
			table.remove(beltEntries, i)
			break
		end
	end
end

local function buyBelt(player, entry)
	local st = states[player]
	if not st or not st.Base then
		return
	end
	if st.Carrying then
		info(player, "Hands full! Carry your catch home first.")
		return
	end
	if st.Cash < entry.Price then
		info(player, "You can't afford " .. entry.Info.Def.Name .. " (" .. GameData.FormatCash(entry.Price) .. ") - keep collecting!")
		return
	end
	st.Cash -= entry.Price
	removeBeltEntry(entry)
	if entry.Prompt then
		entry.Prompt:Destroy()
	end
	local plate = entry.Model.PrimaryPart:FindFirstChild("Nameplate")
	local priceLabel = plate and plate:FindFirstChild("PriceLabel")
	if priceLabel then
		priceLabel:Destroy()
	end
	carryNow(st, entry.Model, entry.Info)
	refreshStats(st)
end

local function spawnBelt()
	local def, mutation = GameData.RollSpawn()
	local income = def.Income * (mutation and mutation.Multiplier or 1)
	local price = GameData.PriceFor(income)
	local model
	local ok, err = pcall(function()
		model = CharacterFactory.Build(def, mutation, income, price)
		model:SetAttribute("CharacterId", def.Id)
		local belt = world.Belt
		local startPos = Vector3.new(belt.FromX, belt.TopY, belt.Z)
		model:PivotTo(beltCF(startPos, 0))
		model.Parent = catchesFolder
		local pr = Instance.new("ProximityPrompt")
		pr.ActionText = "Buy"
		pr.ObjectText = def.Name .. " " .. GameData.FormatCash(price)
		pr.HoldDuration = 0
		pr.MaxActivationDistance = 12
		pr.RequiresLineOfSight = false
		pr.Parent = model.PrimaryPart
		local entry = { Model = model, Info = { Def = def, Mutation = mutation, Income = income }, Price = price, X = belt.FromX, Prompt = pr, Ph = math.random() * 6.3 }
		table.insert(beltEntries, entry)
		pr.Triggered:Connect(function(player)
			buyBelt(player, entry)
		end)
	end)
	if not ok then
		warn("Belt spawn failed for " .. def.Name .. ": " .. tostring(err))
		if model then
			model:Destroy()
		end
	end
end

local function splashBelt(entry)
	removeBeltEntry(entry)
	if entry.Prompt then
		entry.Prompt:Destroy()
	end
	task.spawn(function()
		local pos = entry.Model:GetPivot().Position
		for _ = 1, 6 do
			pos += Vector3.new(0.9, -0.45, 0)
			entry.Model:PivotTo(beltCF(pos, 0))
			task.wait(0.07)
		end
		entry.Model:Destroy()
	end)
end

local function stealFrom(victimSt, padIndex, thief)
	local tst = states[thief]
	if not tst or not tst.Base then
		return
	end
	if thief == victimSt.Player then
		info(thief, "That brainrot is already yours!")
		return
	end
	local placed = victimSt.Placed[padIndex]
	if not placed then
		return
	end
	if tst.Carrying then
		info(thief, FULL)
		return
	end
	if isLocked(victimSt.Base) then
		info(thief, "That base is LOCKED - no stealing!")
		return
	end
	victimSt.Placed[padIndex] = nil
	stopIdle(placed.Model)
	victimSt.BaseIncome -= placed.Info.Income
	if placed.Prompt then
		placed.Prompt:Destroy()
	end
	placed.PickPrompt:Destroy()
	placed.Info.Stolen = true
	tst.Carrying = placed.Model
	tst.CarryingInfo = placed.Info
	notify(thief, { Kind = "Carrying", Text = "You stole " .. placed.Info.Def.Name .. " - get it to YOUR base!" })
	notify(victimSt.Player, { Kind = "Stolen", Text = thief.DisplayName .. " is stealing your " .. placed.Info.Def.Name .. "!" })
	refreshPads(victimSt)
	refreshStats(victimSt)
end

local function pickUp(st, padIndex, player)
	local placed = st.Placed[padIndex]
	if player ~= st.Player or not placed then
		return
	end
	if st.Carrying then
		info(player, FULL)
		return
	end
	st.Placed[padIndex] = nil
	stopIdle(placed.Model)
	st.BaseIncome -= placed.Info.Income
	placed.Prompt:Destroy()
	placed.PickPrompt:Destroy()
	carryNow(st, placed.Model, placed.Info)
	refreshPads(st)
	refreshStats(st)
end

local function placeOnPad(st, padIndex)
	local model = st.Carrying
	local infoTable = st.CarryingInfo
	local pad = st.Base.Pads[padIndex]
	local topPos = pad.CFrame.Position + Vector3.new(0, 0.2, 0)
	local placeCF = faceCFrame(topPos, Vector3.new(0, topPos.Y, 0))
	model:PivotTo(placeCF)
	startIdle(model, placeCF)
	model.Parent = catchesFolder
	infoTable.Stolen = nil
	local pr = Instance.new("ProximityPrompt")
	pr.ActionText = "Steal"
	pr.ObjectText = infoTable.Def.Name
	pr.HoldDuration = 0
	pr.MaxActivationDistance = 12
	pr.RequiresLineOfSight = false
	pr:SetAttribute("StealOwner", st.Player.Name)
	pr.Enabled = not isLocked(st.Base)
	pr.Parent = model.PrimaryPart
	local pk = pr:Clone()
	pk.ActionText = "Pick Up"
	pk:SetAttribute("StealOwner", nil)
	pk:SetAttribute("PickUpOwner", st.Player.Name)
	pk.Enabled = true
	pk.Parent = model.PrimaryPart
	st.Placed[padIndex] = { Model = model, Info = infoTable, Prompt = pr, PickPrompt = pk }
	pr.Triggered:Connect(function(other)
		stealFrom(st, padIndex, other)
	end)
	pk.Triggered:Connect(function(other)
		pickUp(st, padIndex, other)
	end)
	st.BaseIncome += infoTable.Income
	st.Carrying = nil
	st.CarryingInfo = nil
	local rarity = GameData.Rarities[GameData.RarityIndex[infoTable.Def.Rarity]]
	setPadLook(st.Base, padIndex, "Occupied", rarity.Color)
	clearCarry(st.Player)
	info(st.Player, infoTable.Def.Name .. " placed! +" .. GameData.FormatCash(infoTable.Income) .. "/s")
	refreshPads(st)
	refreshStats(st)
end

local function buyPad(st, padIndex)
	if padIndex ~= st.PadsOwned + 1 then
		info(st.Player, "Buy your pads in order - pad " .. (st.PadsOwned + 1) .. " is next!")
		return
	end
	local price = GameData.PadPrices[padIndex]
	if st.Cash < price then
		info(st.Player, "Pad " .. padIndex .. " costs " .. GameData.FormatCash(price) .. " - keep collecting!")
		return
	end
	st.Cash -= price
	st.PadsOwned += 1
	info(st.Player, "Pad " .. padIndex .. " unlocked!")
	refreshPads(st)
	refreshStats(st)
end

local function onPadTriggered(base, padIndex, other)
	local st = states[other]
	if not st then
		return
	end
	if st.Base ~= base then
		info(other, "Not your base - find yours by its sign!")
		return
	end
	if padIndex > st.PadsOwned then
		buyPad(st, padIndex)
	elseif st.Placed[padIndex] then
		return
	elseif not st.Carrying then
		info(other, "Nothing to place - buy off the belt first!")
	else
		placeOnPad(st, padIndex)
	end
end

local function dropCatch(st, pos)
	local model, infoTable = st.Carrying, st.CarryingInfo
	st.Carrying, st.CarryingInfo = nil, nil
	clearCarry(st.Player)
	info(st.Player, "Your catch was knocked loose!")
	local ground = Vector3.new(pos.X, world.SpawnPos.Y - 3, pos.Z)
	local dropCF = faceCFrame(ground, Vector3.new(0, ground.Y, 0))
	model:PivotTo(dropCF)
	startIdle(model, dropCF)
	local entry = { Model = model, Info = infoTable }
	table.insert(dropped, entry)
	local pr = Instance.new("ProximityPrompt")
	pr.ActionText = "Grab"
	pr.ObjectText = infoTable.Def.Name
	pr.HoldDuration = 0
	pr.MaxActivationDistance = 12
	pr.RequiresLineOfSight = false
	pr.Parent = model.PrimaryPart
	pr.Triggered:Connect(function(other)
		local ost = states[other]
		if not ost or not ost.Base then
			return
		end
		if ost.Carrying then
			info(other, FULL)
			return
		end
		for i, e in ipairs(dropped) do
			if e == entry then
				table.remove(dropped, i)
				break
			end
		end
		pr:Destroy()
		stopIdle(model)
		carryNow(ost, model, infoTable)
	end)
end

local function swingBat(player)
	local st = states[player]
	if not st then
		return
	end
	local now = os.clock()
	if now < (st.BatReady or 0) then
		return
	end
	st.BatReady = now + GameData.Bat.Cooldown
	local root = rootOf(player)
	if not root then
		return
	end
	for _, other in ipairs(Players:GetPlayers()) do
		local ost = states[other]
		local ochar = other.Character
		local oroot = rootOf(other)
		if other ~= player and ost and ost.Carrying and oroot then
			local delta = oroot.Position - root.Position
			if delta.Magnitude > 0.1 and delta.Magnitude <= GameData.Bat.Range and root.CFrame.LookVector:Dot(delta.Unit) > 0.2 then
				dropCatch(ost, oroot.Position)
				oroot.AssemblyLinearVelocity = delta.Unit * 26 + Vector3.new(0, 13, 0)
				local hum = ochar:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.WalkSpeed = 8
					task.delay(1.5, function()
						if hum.Parent then
							hum.WalkSpeed = 16
						end
					end)
				end
				info(player, "WHACK! You knocked " .. other.DisplayName .. "'s catch loose!")
				break
			end
		end
	end
end

local function buildBat()
	local tool = Instance.new("Tool")
	tool.Name = "Brainrot Bat"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.ToolTip = "Whack a carrier to knock their brainrot loose!"
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 3.6, 0.9)
	handle.Color = Color3.fromRGB(205, 145, 75)
	handle.Material = Enum.Material.Wood
	handle.CanCollide = false
	handle.Parent = tool
	tool.Parent = game:GetService("StarterPack")
end

local function rebirth(player)
	local st = states[player]
	if not st or not st.Base then
		return
	end
	if st.Cash < GameData.RebirthCost then
		info(player, "Rebirth needs " .. GameData.FormatCash(GameData.RebirthCost) .. " on hand - you have " .. GameData.FormatCash(st.Cash))
		return
	end
	for _, placed in pairs(st.Placed) do
		destroyModel(placed.Model)
	end
	st.Placed = {}
	destroyModel(st.Carrying)
	st.Carrying = nil
	st.CarryingInfo = nil
	st.BaseIncome = 0
	st.PadsOwned = GameData.BasePads
	st.Cash = GameData.StartCash
	st.Rebirths += 1
	clearCarry(player)
	info(player, string.format("REBIRTH! Your crew's income is now x%.1f, forever.", multiplier(st)))
	refreshPads(st)
	refreshStats(st)
end

local function onPlayerSweep(player)
	local st = states[player]
	local root = rootOf(player)
	if not root then
		return
	end
	local pos = root.Position
	local inAnyBase = false
	for _, base in ipairs(world.Bases) do
		if isInBase(pos, base) then
			inAnyBase = true
			break
		end
	end
	if st then
		local inOwnBase = st.Base and isInBase(pos, st.Base)
		if st.Carrying and not inOwnBase then
			destroyModel(st.Carrying)
			st.Carrying = nil
			st.CarryingInfo = nil
			clearCarry(player)
			notify(player, { Kind = "Washed", Text = "The tsunami washed away the brainrot you were carrying!" })
		end
	end
	if not inAnyBase then
		root.CFrame = CFrame.new(world.SpawnPos)
		notify(player, { Kind = "Washed", Text = "You got soaked and washed back to the beach!" })
	end
end

local function onPlayerAdded(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = GameData.StartCash
	cash.Parent = stats
	local perSecValue = Instance.new("IntValue")
	perSecValue.Name = "PerSec"
	perSecValue.Parent = stats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Parent = stats
	stats.Parent = player

	player:WaitForChild("Backpack").ChildAdded:Connect(function(child)
		if child.Name == "Brainrot Bat" then
			child.Activated:Connect(function()
				swingBat(player)
			end)
		end
	end)

	local base = nil
	for _, candidate in ipairs(world.Bases) do
		if not candidate.Owner then
			base = candidate
			break
		end
	end
	local st = {
		Player = player,
		Base = base,
		Cash = GameData.StartCash,
		Rebirths = 0,
		BaseIncome = 0,
		PadsOwned = GameData.BasePads,
		Placed = {},
		Carrying = nil,
		CarryingInfo = nil,
	}
	states[player] = st
	if base then
		base.Owner = player
		refreshPads(st)
		refreshStats(st)
		info(player, "Welcome! Your base is " .. player.DisplayName .. "'s - buy a brainrot off the belt!")
	else
		info(player, "Welcome to the Cove! All bases are taken - enjoy the chaos.")
	end
end

local function onPlayerRemoving(player)
	local st = states[player]
	if not st then
		return
	end
	for _, placed in pairs(st.Placed) do
		destroyModel(placed.Model)
	end
	destroyModel(st.Carrying)
	if st.Base then
		st.Base.Owner = nil
		st.Base.LockUntil = 0
		st.Base.WasLocked = false
		st.Base.LockReadyAt = 0
		st.Base.SetBarriers(false)
		st.Base.LockLabel.Text = "🔓 READY"
		st.Base.SetSign("EMPTY BASE", "Join and it is yours")
		resetPads(st.Base)
	end
	states[player] = nil
end

function GameServer.Init(worldRef, remotes)
	world = worldRef
	notifyRemote = remotes:WaitForChild("Notify")
	catchesFolder = Instance.new("Folder")
	catchesFolder.Name = "Catches"
	catchesFolder.Parent = workspace

	buildBat()
	world.ShrinePrompt.Triggered:Connect(function(player)
		rebirth(player)
	end)
	for _, base in ipairs(world.Bases) do
		base.LockPrompt.Triggered:Connect(function(player)
			onLockTriggered(base, player)
		end)
		resetPads(base)
		for padIndex, pad in ipairs(base.Pads) do
			pad.Prompt.Triggered:Connect(function(player)
				onPadTriggered(base, padIndex, player)
			end)
		end
	end

	Tsunami.OnWarning = function(seconds)
		notifyAll({ Kind = "WaveWarning", Seconds = seconds })
	end
	Tsunami.OnSweepStart = function()
		notifyAll({ Kind = "WaveSweep" })
	end
	Tsunami.OnWaveEnd = function()
		notifyAll({ Kind = "WaveEnd" })
	end
	Tsunami.OnPlayerSweep = onPlayerSweep

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	task.spawn(function()
		task.wait(2)
		while true do
			spawnBelt()
			task.wait(math.random(GameData.Belt.IntervalMin * 10, GameData.Belt.IntervalMax * 10) / 10)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(0.5)
			local now = os.clock()
			for _, base in ipairs(world.Bases) do
				if base.Owner then
					local locked = isLocked(base)
					if base.WasLocked and not locked then
						base.LockReadyAt = now + GameData.Lock.Cooldown
						base.SetBarriers(false)
						refreshStealPrompts(base)
					end
					base.WasLocked = locked
					base.LockLabel.Text = locked and ("🔒 " .. math.ceil(base.LockUntil - now) .. "s")
						or (now < (base.LockReadyAt or 0) and ("⏳ " .. math.ceil(base.LockReadyAt - now) .. "s") or "🔓 READY")
					if locked then
						for _, p in ipairs(Players:GetPlayers()) do
							if p ~= base.Owner then
								local r = rootOf(p)
								if r and isInBase(r.Position, base) then
									r.CFrame = base.CFrame * CFrame.new(0, 3, -17)
								end
							end
						end
					end
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(1)
			for _, st in pairs(states) do
				if st.BaseIncome > 0 then
					st.Cash += perSec(st)
					local stats = st.Player:FindFirstChild("leaderstats")
					if stats then
						stats.Cash.Value = math.floor(st.Cash)
					end
				end
			end
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		local t = os.clock()
		for i = #beltEntries, 1, -1 do
			local entry = beltEntries[i]
			entry.X += GameData.Belt.Speed * dt
			if entry.X >= world.Belt.ToX then
				splashBelt(entry)
			else
				local pos = Vector3.new(entry.X, world.Belt.TopY + math.sin(t * 3 + entry.Ph) * 0.09, world.Belt.Z)
				entry.Model:PivotTo(beltCF(pos, math.sin(t * 2.3 + entry.Ph) * 0.05))
			end
		end
		for _, st in pairs(states) do
			if st.Carrying then
				local root = rootOf(st.Player)
				if root then
					local pos = root.Position + Vector3.new(0, 2.4, 0)
					st.Carrying:PivotTo(faceCFrame(pos, pos + root.CFrame.LookVector))
				end
			end
		end
		for model, anim in pairs(idles) do
			if model.Parent then
				local bob = math.sin(t * 2 + anim.Ph) * 0.11
				local sway = math.sin(t * 1.4 + anim.Ph) * 0.045
				model:PivotTo(anim.CF * CFrame.new(0, bob, 0) * CFrame.Angles(sway, 0, sway * 0.7))
			else
				idles[model] = nil
			end
		end
	end)
end

return GameServer
