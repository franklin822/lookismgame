-- AnimationHandler.client.luau
-- Handles loading and playing animations on the client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animations = require(game.ReplicatedStorage.Shared.MoveConfigs.Animations)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Disable default Roblox animations
local animate = character:FindFirstChild("Animate")
if animate then
    animate.Enabled = false
end

-- Also stop any currently playing default tracks
for _, track in animator:GetPlayingAnimationTracks() do
    track:Stop(0)
end

-- Animation cache
local loadedAnimations = {}

local AnimationHandler = {}

function AnimationHandler.LoadAnimation(animationId)
	if loadedAnimations[animationId] then
		return loadedAnimations[animationId]
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	loadedAnimations[animationId] = track
	return track
end

function AnimationHandler.PlayAnimation(animationId, fadeTime, speed)
	local track = AnimationHandler.LoadAnimation(animationId)
	track:Play(fadeTime or 0.1, 1, speed or 1)
	return track
end

function AnimationHandler.StopAnimation(animationId, fadeTime)
	local track = loadedAnimations[animationId]
	if track then
		track:Stop(fadeTime or 0.1)
	end
end

function AnimationHandler.StopAll(fadeTime)
	for _, track in loadedAnimations do
		track:Stop(fadeTime or 0.1)
	end
end

-- Movement animation handler
local currentMovementAnim = nil

local function playMovementAnim(animationId)
	if currentMovementAnim == animationId then return end
	currentMovementAnim = animationId

	-- Stop all movement anims first
	AnimationHandler.StopAnimation(Animations.Default.Idle, 0.2)
	AnimationHandler.StopAnimation(Animations.Default.Walk, 0.2)
	AnimationHandler.StopAnimation(Animations.Default.Sprint, 0.2)

	AnimationHandler.PlayAnimation(animationId, 0.2)
end

-- Track sprint state
local isSprinting = false

-- Listen for sprint from server
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AnimationRemote = Remotes:WaitForChild("AnimationRemote")

AnimationRemote.OnClientEvent:Connect(function(action, animationId, fadeTime, speed)
	if action == "Play" then
		AnimationHandler.PlayAnimation(animationId, fadeTime, speed)
	elseif action == "Stop" then
		AnimationHandler.StopAnimation(animationId, fadeTime)
	elseif action == "StopAll" then
		AnimationHandler.StopAll(fadeTime)
	elseif action == "SetSprint" then
		isSprinting = animationId -- reusing param as boolean
	end
end)

-- Movement loop
RunService.Heartbeat:Connect(function()
	local moveDirection = humanoid.MoveDirection
	local speed = moveDirection.Magnitude

	if speed < 0.1 then
		playMovementAnim(Animations.Default.Idle)
	elseif isSprinting then
		playMovementAnim(Animations.Default.Sprint)
	else
		playMovementAnim(Animations.Default.Walk)
	end
end)

-- Preload animations
AnimationHandler.LoadAnimation(Animations.Default.Idle)
AnimationHandler.LoadAnimation(Animations.Default.Walk)
AnimationHandler.LoadAnimation(Animations.Default.Sprint)

return AnimationHandler