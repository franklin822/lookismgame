-- AnimationHandler.client.luau
-- Handles loading and playing animations on the client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- animation tracker so we dont reload the same animation twice
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

-- listen for animation requests from server
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AnimationRemote = Remotes:WaitForChild("AnimationRemote")

AnimationRemote.OnClientEvent:Connect(function(action, animationId, fadeTime, speed)
	if action == "Play" then
		AnimationHandler.PlayAnimation(animationId, fadeTime, speed)
	elseif action == "Stop" then
		AnimationHandler.StopAnimation(animationId, fadeTime)
	elseif action == "StopAll" then
		AnimationHandler.StopAll(fadeTime)
	end
end)

return AnimationHandler