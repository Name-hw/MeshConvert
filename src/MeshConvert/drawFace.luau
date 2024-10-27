--!native
--!strict
local Part = Instance.new("Part")
Part.Anchored = true
Part.CanCollide = false
Part.CanTouch = false
Part.CanQuery = false
Part.TopSurface = Enum.SurfaceType.Smooth
Part.BottomSurface = Enum.SurfaceType.Smooth
local tolerance = 0.001

local function projectToPlane(point: Vector3, origin: Vector3, normal: Vector3): Vector2
	local upVector = Vector3.new(0, 1, 0)
	if math.abs(normal.Y) == 1 then
		upVector = Vector3.new(1, 0, 0)
	end

	local rightVector = upVector:Cross(normal).Unit
	local forwardVector = normal:Cross(rightVector).Unit

	local relativePoint = point - origin
	local x = relativePoint:Dot(rightVector)
	local y = relativePoint:Dot(forwardVector)

	return Vector2.new(x, y)
end

local function drawFace(vertices: { Vector3 }, parent: Instance?, partsToUpdate: { Part }?): { Part }
	local parts: { Part } = {}
	local a: Vector3 = vertices[1]
	local b: Vector3 = vertices[2]
	local c: Vector3 = vertices[3]
	local d: Vector3 = vertices[4]

	if #vertices == 3 then
		local ab, ac, bc = b - a, c - a, c - b
		local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

		if abd > acd and abd > bcd then
			c, a = a, c
		elseif acd > bcd and acd > abd then
			a, b = b, a
		end

		ab, ac, bc = b - a, c - a, c - b

		if math.abs(ab.Magnitude ^ 2 + ac.Magnitude ^ 2 - bc.Magnitude ^ 2) <= tolerance then
			local right = ab:Cross(ac).Unit
			local up = ac.Unit
			local back = bc.Unit

			local wedge

			if partsToUpdate then
				wedge = partsToUpdate[1]

				if partsToUpdate[2] then
					partsToUpdate[2]:Destroy()
				end
			else
				wedge = Part:Clone()
			end

			wedge.Shape = Enum.PartType.Wedge
			wedge.Size = Vector3.new(0, ac.Magnitude, ab.Magnitude)
			wedge.CFrame = CFrame.fromMatrix((b + c) / 2, right, up, back)
			wedge.Parent = parent

			table.insert(parts, wedge)
		else
			local right = ac:Cross(ab).Unit
			local up = bc:Cross(right).Unit
			local back = bc.Unit

			local height = math.abs(ab:Dot(up))

			local w1, w2

			if partsToUpdate and partsToUpdate[1] then
				w1 = partsToUpdate[1]
			else
				w1 = Part:Clone()
			end

			if partsToUpdate and partsToUpdate[2] then
				w2 = partsToUpdate[2]
			else
				w2 = Part:Clone()
			end

			w1.Shape = Enum.PartType.Wedge
			w1.Size = Vector3.new(0, height, math.abs(ab:Dot(back)))
			w1.CFrame = CFrame.fromMatrix((a + b) / 2, right, up, back)
			w1.Parent = parent

			w2.Shape = Enum.PartType.Wedge
			w2.Size = Vector3.new(0, height, math.abs(ac:Dot(back)))
			w2.CFrame = CFrame.fromMatrix((a + c) / 2, -right, up, -back)
			w2.Parent = parent

			table.insert(parts, w1)
			table.insert(parts, w2)
		end
	elseif #vertices == 4 then
		local normal = (b - a):Cross(c - a).Unit
		local centroid = (a + b + c + d) / 4

		table.sort(vertices, function(A: Vector3, B: Vector3)
			local projectedA = projectToPlane(A, centroid, normal)
			local projectedB = projectToPlane(B, centroid, normal)

			return math.atan2(projectedA.Y, projectedA.X) > math.atan2(projectedB.Y, projectedB.X)
		end)

		a, b, c, d = vertices[1], vertices[2], vertices[3], vertices[4]

		local da, ab, cb, dc = a - d, b - a, b - c, c - d

		if (ab - dc).Magnitude <= tolerance and (da - cb).Magnitude <= tolerance then
			local block

			if partsToUpdate then
				block = partsToUpdate[1]

				for index, part in ipairs(partsToUpdate) do
					if index ~= 1 then
						part:Destroy()
					end
				end
			else
				block = Part:Clone()
			end

			block.Shape = Enum.PartType.Block
			block.Size = Vector3.new(ab.Magnitude, cb.Magnitude, 0)
			block.CFrame = CFrame.lookAlong(centroid, normal, ab)
			block.Parent = parent

			table.insert(parts, block)
		else
			if partsToUpdate then
				for index, part in ipairs(partsToUpdate) do
					part:Destroy()
				end
			end

			local triangle1 = drawFace({ a, b, c }, parent)
			parts[1], parts[2] = triangle1[1], triangle1[2]

			local triangle2 = drawFace({ c, d, a }, parent)
			parts[3], parts[4] = triangle2[1], triangle2[2]
		end
	end

	return parts
end

return drawFace
