-- HitboxHandler.server.luau
-- Spawns and manages hitboxes during attacks

local HitboxHandler = {}

function HitboxHandler.CreateHitbox(character, size, offset, duration)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- create hitbox part
	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = size
	hitbox.CFrame = rootPart.CFrame * CFrame.new(offset)
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Transparency = 0
    hitbox.Parent = workspace

    -- track hits so m1 lands once
	local hits = {}

	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		hitbox.CFrame = rootPart.CFrame * CFrame.new(offset)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = {character}
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude

		local parts = workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size, overlapParams)

		for _, part in parts do
			local victim = part.Parent
			local humanoid = victim:FindFirstChildWhichIsA("Humanoid")

			if humanoid and not hits[victim] then
				hits[victim] = true
				HitboxHandler.OnHit(character, victim, humanoid)
			end
		end
	end)

	task.delay(duration, function()
		connection:Disconnect()
		hitbox:Destroy()
	end)
end

function HitboxHandler.OnHit(attacker, victim, humanoid)
	print(`[Hitbox] {attacker.Name} hit {victim.Name}`)
end

return HitboxHandler