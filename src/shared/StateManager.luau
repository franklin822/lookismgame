-- StateManager.luau
-- Tracks the combat state of any character

local StateManager = {}
StateManager.__index = StateManager

export type State = "Idle" | "Attacking" | "Blocking" | "Stunned" | "Sprinting" | "Walking" | "Dashing" | "Ragdolled"

function StateManager.new()
	local self = setmetatable({}, StateManager)
	self.currentState = "Idle"
	self.previousState = "Idle"
	return self
end

function StateManager:GetState()
	return self.currentState
end

function StateManager:SetState(newState: State)
	self.previousState = self.currentState
	self.currentState = newState
	print(`[StateManager] {self.previousState} → {newState}`)
end

function StateManager:CanAttack()
	return self.currentState ~= "Blocking" 
		and self.currentState ~= "Stunned"
		and self.currentState ~= "Ragdolled"
		and self.currentState ~= "Attacking"
end

function StateManager:CanBlock()
	return self.currentState ~= "Attacking"
		and self.currentState ~= "Stunned"
		and self.currentState ~= "Ragdolled"
end

function StateManager:IsBlocking()
	return self.currentState == "Blocking"
end

function StateManager:Reset()
	self:SetState("Idle")
end

return StateManager