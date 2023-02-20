-- Render Distance Version 1 (2018)
-- TO USE: Place in StarterCharacterScripts, adjust render distance in areaMaker function (below)

local function SetPrimaryPart(m)
	for i, v in pairs(m:GetChildren()) do
		if v.ClassName == "Part" then
			m.PrimaryPart = v
		end
	end

	if m.PrimaryPart == nil then
		local ref = m:FindFirstChildWhichIsA("BasePart", true)
		local primTemp = ref:Clone()

		primTemp.Parent = m
		primTemp.CanCollide = false
		primTemp.Transparency = 1
		primTemp.Name = "--TEMP--"

		m.PrimaryPart = primTemp
	end
end

local function partSub(i, p) --substituting part with render brick
	local renderBrick = Instance.new("Part")
	renderBrick.Anchored = true
	renderBrick.CanCollide = false
	renderBrick.Transparency = 1
	renderBrick.Parent = workspace
	renderBrick.Name = i

	renderBrick.Position = p.Position
	renderBrick.Size = p.Size
	renderBrick.Orientation = p.Orientation
end

local function modelSub(i, m) --substituting model with render brick
	local renderBrick = Instance.new("Part")
	renderBrick.Anchored = true
	renderBrick.CanCollide = false
	renderBrick.Transparency = 1
	renderBrick.Parent = workspace
	renderBrick.Name = i

	if m.PrimaryPart == nil then
		SetPrimaryPart(m)
	end

	renderBrick.Position = m.PrimaryPart.Position
	renderBrick.Size = m.PrimaryPart.Size
	renderBrick.Orientation = m.PrimaryPart.Orientation
end

local function folderKill(f) --getting rid of folders
	local fchild = f:GetChildren()

	for i, v in pairs(fchild) do
		if v.ClassName ~= "Folder" then
			v.Parent = workspace
		else
			folderKill(v)
		end
	end
end

local function areaMaker(rad, char) --sets view distance (radius, plr.character)
	local cyl = Instance.new("Part", workspace)
	cyl.Name = "Render"
	cyl.Shape = "Ball"
	cyl.CFrame = CFrame.new(char.Position)
	cyl.Size = Vector3.new(rad * 2, rad * 2, rad * 2)
	cyl.Anchored = false
	cyl.Transparency = 1
	cyl.CanCollide = false

	local weld = Instance.new("Weld", cyl)
	weld.Part0 = cyl
	weld.Part1 = char

	--set fog (for smooth rendering)
	local lighting = game:GetService("Lighting")
	lighting.FogColor = Color3.fromRGB(136, 136, 136) --fog color
	lighting.FogEnd = rad
	lighting.FogStart = rad / 2
end

--start of the script
local fWork = game.Workspace:GetChildren()
for i, v in pairs(fWork) do --implement folderKill
	if v.ClassName == "Folder" then
		folderKill(v)
	end
end

local work = game.workspace:GetChildren()
local parts = {}

local player = game.Players.LocalPlayer
local character = workspace:WaitForChild(player.Name).HumanoidRootPart

areaMaker(100, character) --change the number to set the view distance in all directions

for i, v in pairs(work) do --running functions and getting everything that needs to be rendered
	if v.Name ~= player.Name then
		if v.ClassName == "Part" then
			partSub(i, v)

			v.Parent = game:GetService("ReplicatedStorage")

			parts[i] = v
		end

		if v.ClassName == "Model" then
			modelSub(i, v)

			v.Parent = game:GetService("ReplicatedStorage")

			parts[i] = v
		end

		if v.ClassName == "Folder" then
			folderKill(v)
		end
	end
end

print("Render V1 Loaded!")

game.Workspace.Render.Touched:Connect(function(part) --making parts appear
	if parts[tonumber(part.Name)] ~= nil then
		parts[tonumber(part.Name)].Parent = workspace
	end
end)

game.Workspace.Render.TouchEnded:Connect(function(part) --making parts disappear
	if parts[tonumber(part.Name)] ~= nil then
		parts[tonumber(part.Name)].Parent = game:GetService("ReplicatedStorage")
	end
end)
