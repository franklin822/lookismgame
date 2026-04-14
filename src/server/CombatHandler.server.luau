-- CombatHandler.server.luau
-- Receives combat actions from client and processes them

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateManager = require(game.ReplicatedStorage.Shared.StateManager)
local HitboxHandler = require(game.ReplicatedStorage.Shared.HitboxHandler)

-- Setup Remotes
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local CombatRemote = Instance.new("RemoteEvent")
CombatRemote.Name = "CombatRemote"
CombatRemote.Parent = Remotes

local AnimationRemote = Instance.new("RemoteEvent")
AnimationRemote.Name = "AnimationRemote"
AnimationRemote.Parent = Remotes

-- Combo settings
local COMBO_RESET_TIME = 1.5 -- seconds before combo resets
local MAX_COMBO = 4

-- Track each player's state and combo
local playerStates = {}
local playerCombos = {}
local playerComboTimers = {}

Players.PlayerAdded:Connect(function(player)
	playerStates[player] = StateManager.new()
	playerCombos[player] = 0
end)

Players.PlayerRemoving:Connect(function(player)
	playerStates[player] = nil
	playerCombos[player] = nil
	playerComboTimers[player] = nil
end)

local function resetCombo(player)
	playerCombos[player] = 0
	playerComboTimers[player] = nil
end

local function playAnimation(player, animationId, fadeTime, speed)
	AnimationRemote:FireClient(player, "Play", animationId, fadeTime, speed)
end

local function handleM1(player, character, state)
	if not state:CanAttack() then return end
	state:SetState("Attacking")

	if playerComboTimers[player] then
		task.cancel(playerComboTimers[player])
		playerComboTimers[player] = nil
	end

	playerCombos[player] = playerCombos[player] + 1
	local comboCount = playerCombos[player]

	print(`[Combat] {player.Name} M1 combo {comboCount}`)

	local animations = {
		[1] = "rbxassetid://0",
		[2] = "rbxassetid://0",
		[3] = "rbxassetid://0",
		[4] = "rbxassetid://0",
	}
	playAnimation(player, animations[comboCount])

	HitboxHandler.CreateHitbox(
		character,
		Vector3.new(5, 5, 5),
		Vector3.new(0, 0, -4),
		0.3
	)

	local attackDuration = comboCount == MAX_COMBO and 0.8 or 0.5
	task.wait(attackDuration)

	if comboCount >= MAX_COMBO then
		resetCombo(player)
	else
		playerComboTimers[player] = task.delay(COMBO_RESET_TIME, function()
			resetCombo(player)
		end)
	end

	state:Reset()
end

local function handleHeavyAttack(player, character, state)
	if not state:CanAttack() then return end
	state:SetState("Attacking")

	print(`[Combat] {player.Name} heavy attack`)
	playAnimation(player, "rbxassetid://0")

	HitboxHandler.CreateHitbox(
		character,
		Vector3.new(6, 6, 6),
		Vector3.new(0, 0, -4),
		0.4
	)

	task.wait(0.8)
	state:Reset()
end

-- Handle incoming actions
CombatRemote.OnServerEvent:Connect(function(player, action, value)
	local state = playerStates[player]
	if not state then return end

	local character = player.Character
	if not character then return end

	if action == "M1" then
		handleM1(player, character, state)

	elseif action == "HeavyAttack" then
		handleHeavyAttack(player, character, state)

	elseif action == "Block" then
		if value == true then
			if not state:CanBlock() then return end
			state:SetState("Blocking")
			print(`[Combat] {player.Name} is blocking`)
		else
			state:Reset()
			print(`[Combat] {player.Name} stopped blocking`)
		end

	elseif action == "Sprint" then
		if value == true then
			state:SetState("Sprinting")
			print(`[Combat] {player.Name} is sprinting`)
		else
			state:Reset()
			print(`[Combat] {player.Name} stopped sprinting`)
		end
	end
end)