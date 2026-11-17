local GameData = {}

GameData.StartCash = 100

GameData.Rarities = {
	{ Name = "Common", Color = Color3.fromRGB(168, 175, 186) },
	{ Name = "Rare", Color = Color3.fromRGB(64, 156, 255) },
	{ Name = "Epic", Color = Color3.fromRGB(176, 84, 255) },
	{ Name = "Legendary", Color = Color3.fromRGB(255, 176, 32) },
	{ Name = "Mythic", Color = Color3.fromRGB(255, 64, 96) },
}

GameData.RarityIndex = {}
for i, rarity in ipairs(GameData.Rarities) do
	GameData.RarityIndex[rarity.Name] = i
end

GameData.Characters = {
	{ Id = "tungtung", Name = "Tung Tung Tung Sahur", Rarity = "Common", Income = 1, Scale = 0.71, Body = Color3.fromRGB(150, 100, 55), Head = Color3.fromRGB(172, 122, 70) },
	{ Id = "chimpanzini", Name = "Chimpanzini Bananini", Rarity = "Common", Income = 2, Scale = 0.78, Body = Color3.fromRGB(255, 214, 64), Head = Color3.fromRGB(122, 84, 52) },
	{ Id = "trippi", Name = "Trippi Troppi", Rarity = "Common", Income = 3, Scale = 0.71, Body = Color3.fromRGB(255, 128, 58), Head = Color3.fromRGB(255, 166, 66) },
	{ Id = "boneca", Name = "Boneca Ambalabu", Rarity = "Rare", Income = 5, Scale = 0.87, Body = Color3.fromRGB(32, 32, 38), Head = Color3.fromRGB(84, 204, 84) },
	{ Id = "lirili", Name = "Lirili Larila", Rarity = "Rare", Income = 7, Scale = 0.8, Body = Color3.fromRGB(64, 176, 84), Head = Color3.fromRGB(163, 163, 173) },
	{ Id = "bombombini", Name = "Bombombini Gusini", Rarity = "Rare", Income = 9, Scale = 0.8, Body = Color3.fromRGB(246, 246, 246), Head = Color3.fromRGB(246, 246, 246) },
	{ Id = "ballerina", Name = "Ballerina Cappuccina", Rarity = "Epic", Income = 14, Scale = 0.94, Body = Color3.fromRGB(255, 150, 196), Head = Color3.fromRGB(250, 246, 238) },
	{ Id = "assassino", Name = "Cappuccino Assassino", Rarity = "Epic", Income = 18, Scale = 1.06, Body = Color3.fromRGB(247, 242, 233), Head = Color3.fromRGB(247, 242, 233) },
	{ Id = "patapim", Name = "Brr Brr Patapim", Rarity = "Epic", Income = 22, Scale = 0.9, Body = Color3.fromRGB(122, 82, 45), Head = Color3.fromRGB(122, 82, 45) },
	{ Id = "tralalero", Name = "Tralalero Tralala", Rarity = "Legendary", Income = 40, Scale = 1.22, Body = Color3.fromRGB(66, 132, 222), Head = Color3.fromRGB(66, 132, 222) },
	{ Id = "bombardiro", Name = "Bombardiro Crocodilo", Rarity = "Legendary", Income = 55, Scale = 1.11, Body = Color3.fromRGB(141, 150, 130), Head = Color3.fromRGB(84, 176, 74) },
	{ Id = "vaca", Name = "La Vaca Saturno Saturnita", Rarity = "Mythic", Income = 120, Scale = 1.37, Body = Color3.fromRGB(246, 246, 246), Head = Color3.fromRGB(246, 246, 246) },
	{ Id = "giraffa", Name = "Giraffa Celeste", Rarity = "Mythic", Income = 160, Scale = 0.82, Body = Color3.fromRGB(36, 42, 96), Head = Color3.fromRGB(46, 54, 116) },
	{ Id = "glorbo", Name = "Glorbo Fruttodrillo", Rarity = "Mythic", Income = 200, Scale = 1.6, Body = Color3.fromRGB(52, 176, 74), Head = Color3.fromRGB(74, 164, 62) },
}

GameData.CharacterById = {}
GameData.CharactersByRarity = {}
for _, def in ipairs(GameData.Characters) do
	GameData.CharacterById[def.Id] = def
	local bucket = GameData.CharactersByRarity[def.Rarity]
	if not bucket then
		bucket = {}
		GameData.CharactersByRarity[def.Rarity] = bucket
	end
	table.insert(bucket, def)
end

GameData.Mutations = {
	{ Name = "Diamond", Chance = 0.02, Multiplier = 6, Tint = Color3.fromRGB(170, 240, 255) },
	{ Name = "Gold", Chance = 0.08, Multiplier = 3, Tint = Color3.fromRGB(255, 205, 60) },
}

GameData.SpawnWeights = { Common = 50, Rare = 32, Epic = 13, Legendary = 4, Mythic = 1 }
GameData.Belt = { IntervalMin = 4, IntervalMax = 6, PriceFactor = 75, Speed = 8 }

function GameData.PriceFor(income)
	return math.floor(income * GameData.Belt.PriceFactor / 5 + 0.5) * 5
end

GameData.Lock = { Base = 60, PerRebirth = 10, Cooldown = 60 }
GameData.Bat = { Cooldown = 1.2, Range = 7.5 }

GameData.BasePads = 4
GameData.MaxPads = 8
GameData.PadPrices = { [5] = 400, [6] = 1200, [7] = 3500, [8] = 9000 }

GameData.RebirthCost = 5000
GameData.RebirthStep = 0.5

function GameData.MultiplierFor(rebirths)
	return 1 + GameData.RebirthStep * rebirths
end

GameData.Wave = {
	FirstDelay = 45,
	Interval = 150,
	Warning = 10,
	SweepTime = 7,
	FromX = -260,
	ToX = 260,
}

function GameData.RollSpawn()
	local total = 0
	for _, rarity in ipairs(GameData.Rarities) do
		total += GameData.SpawnWeights[rarity.Name] or 0
	end
	local roll = math.random() * total
	local picked = GameData.Rarities[1].Name
	for _, rarity in ipairs(GameData.Rarities) do
		local weight = GameData.SpawnWeights[rarity.Name] or 0
		if roll < weight then
			picked = rarity.Name
			break
		end
		roll -= weight
	end
	local bucket = GameData.CharactersByRarity[picked]
	local def = bucket[math.random(1, #bucket)]
	local mutation = nil
	local mroll = math.random()
	local seen = 0
	for _, m in ipairs(GameData.Mutations) do
		seen += m.Chance
		if mroll < seen then
			mutation = m
			break
		end
	end
	return def, mutation
end

function GameData.FormatCash(amount)
	local n = math.floor(amount)
	local text = tostring(n)
	local out = ""
	while #text > 3 do
		out = "," .. string.sub(text, -3) .. out
		text = string.sub(text, 1, -4)
	end
	return "$" .. text .. out
end

return GameData
