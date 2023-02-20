--[[ TODO:
	1) implement unionizer to decrease part spawing lag
		a) union every part to a large shape as each part is spawned
		b) after each iteration, check the mass of the union.
		c) if union.mass divided by wall.mass is equal to 1.000 (rounded to thousandths place) then set stop equal to true
		d) if statement @ top of function: if stop == true then return
]]

-- Made in 2019

root = workspace.RedLittle --nanite (filler); needs to be positioned relative it's center; must be a cube
--note: Put the brick somewhere random, NOT already inside the object to fill!!

--note: found a bug where size of block can sometimes extend past the boundry of the fill
wall = workspace.Circle --object to fill; needs to be positioned relative it's center

--Jump-interval(N) for checking for each direction (ex: []--N-->[])
--If you want space in between each fill block (like a rubix cube) change zero to a larger number.
intv = root.Size.X + 0

function floodFill(curPos, dir)
	task.wait() --wait time between part spawning

	--two new variables for raychecking
	local ray
	local hit, hitpos

	--check if inside boundary for each direction (these might seem stupid but now we can fill any shape)
	if dir == "up" then --checking up
		ray = Ray.new(Vector3.new(curPos.X, curPos.Y, curPos.Z), Vector3.new(0, -intv, 0))
		local parts = findAllPartsOnRay(ray)

		if parts then
			return
		end
	end

	if dir == "down" then --checking down
		ray = Ray.new(Vector3.new(curPos.X, curPos.Y, curPos.Z), Vector3.new(0, intv, 0))
		local parts = findAllPartsOnRay(ray)

		if parts then
			return
		end
	end

	if dir == "left" then --checking left
		ray = Ray.new(Vector3.new(curPos.X, curPos.Y, curPos.Z), Vector3.new(intv, 0, 0))
		local parts = findAllPartsOnRay(ray)

		if parts then
			return
		end
	end

	if dir == "right" then --checking right
		ray = Ray.new(Vector3.new(curPos.X, curPos.Y, curPos.Z), Vector3.new(-intv, 0, 0))
		local parts = findAllPartsOnRay(ray)

		if parts then
			return
		end
	end

	if dir == "forward" then --checking forward
		ray = Ray.new(Vector3.new(curPos.X, curPos.Y, curPos.Z), Vector3.new(0, 0, -intv))
		local parts = findAllPartsOnRay(ray)

		if parts then
			return
		end
	end

	if dir == "backward" then --checking backward
		ray = Ray.new(Vector3.new(curPos.X, curPos.Y, curPos.Z), Vector3.new(0, 0, intv))
		local parts = findAllPartsOnRay(ray)

		if parts then
			return
		end
	end

	--goes a jump-interval spot above and goes down to check if filled
	ray = Ray.new(Vector3.new(curPos.X, curPos.Y + intv, curPos.Z), Vector3.new(0, -intv, 0))
	hit, hitpos = workspace:FindPartOnRay(ray, wall)

	if hit ~= nil then
		return --if current spot already filled, return
	end

	--fill the current spot with a brick
	local newNanite = root:Clone()
	newNanite.Parent = script.PartTable
	newNanite.Position = curPos

	--recurse all directions
	floodFill(Vector3.new(curPos.X, curPos.Y + intv, curPos.Z), "up") --up
	floodFill(Vector3.new(curPos.X, curPos.Y - intv, curPos.Z), "down") --down
	floodFill(Vector3.new(curPos.X - intv, curPos.Y, curPos.Z), "left") --left
	floodFill(Vector3.new(curPos.X + intv, curPos.Y, curPos.Z), "right") --right
	floodFill(Vector3.new(curPos.X, curPos.Y, curPos.Z + intv), "forward") --forward
	floodFill(Vector3.new(curPos.X, curPos.Y, curPos.Z - intv), "backward") --backward

	return
end

function findAllPartsOnRay(ray)
	local targets = {}

	repeat
		local target = game.Workspace:FindPartOnRayWithIgnoreList(ray, targets)
		if target ~= wall then
			table.insert(targets, target)
		else
			return true
		end

	until not target

	return false
end

if wall:IsA("Model") then
	local children = wall:GetChildren()

	for i, v in pairs(children) do
		if v:IsA("BasePart") then
			wall = v
			floodFill(wall.Position, "up")
		end
	end
else
	floodFill(wall.Position, "up") --starts at wall.position, should be in the center
end

wall:Remove()
print("DONE")
