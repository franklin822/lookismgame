-- InputHandler.client.luau
-- Detects player input and fires combat actions to the server

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CombatRemote = Remotes:WaitForChild("CombatRemote")

-- Input settings
local SPRINT_KEY = Enum.KeyCode.LeftShift
local BLOCK_KEY = Enum.KeyCode.F
local HEAVY_KEY = Enum.KeyCode.R

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == SPRINT_KEY then
		CombatRemote:FireServer("Sprint", true)

	elseif input.KeyCode == BLOCK_KEY then
		CombatRemote:FireServer("Block", true)

	elseif input.KeyCode == HEAVY_KEY then
		CombatRemote:FireServer("HeavyAttack")
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == SPRINT_KEY then
		CombatRemote:FireServer("Sprint", false)

	elseif input.KeyCode == BLOCK_KEY then
		CombatRemote:FireServer("Block", false)
	end
end)

-- M1 on click
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
	if UserInputService:GetFocusedTextBox() then return end
	CombatRemote:FireServer("M1")
end)