
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
local notify = Instance.new("RemoteEvent")
notify.Name = "Notify"
notify.Parent = remotes
remotes.Parent = ReplicatedStorage

local WorldGen = require(script:WaitForChild("WorldGen"))
local GameServer = require(script:WaitForChild("GameServer"))
local Tsunami = require(script:WaitForChild("Tsunami"))

local world = WorldGen.Build()
GameServer.Init(world, remotes)
Tsunami.Start()

print("Tsunami Brainrot Cove is open.")
