--[[
	GridUtil
	Matematika grid yang dipakai bersama oleh client (preview) dan server (validasi),
	supaya hasil snap di client dan server selalu sama.

	Grid dihitung dari POJOK area build, jadi kotak-kotaknya selalu rapi
	mengikuti pinggir area (bukan mengambang bebas di dunia).
]]

local BuildConfig = require(script.Parent.BuildConfig)

local GridUtil = {}

-- Ukuran bounding box item setelah dirotasi (rotasi 90/270 menukar sumbu X dan Z)
function GridUtil.getRotatedSize(size: Vector3, rotationY: number): Vector3
	local rot = math.round(rotationY) % 180
	if rot == 90 then
		return Vector3.new(size.Z, size.Y, size.X)
	end
	return size
end

-- Ambil ukuran bounding box model + offset pivot-nya (dipanggil saat model masih belum dirotasi)
function GridUtil.getModelBounds(model: Model): (Vector3, CFrame)
	local bbCFrame, bbSize = model:GetBoundingBox()
	local pivotToBB = model:GetPivot():ToObjectSpace(bbCFrame)
	return bbSize, pivotToBB
end

-- Ambil CFrame + ukuran area build. Area boleh berupa BasePart (pakai CFrame/Size)
-- atau Model (pakai bounding box), karena Bawah<level> di plot bisa berupa keduanya.
function GridUtil.getAreaBounds(area: Instance): (CFrame, Vector3)
	if area:IsA("BasePart") then
		return area.CFrame, area.Size
	elseif area:IsA("Model") then
		return area:GetBoundingBox()
	end
	error("Area build harus BasePart atau Model, dapat: " .. area.ClassName)
end

-- Snap satu sumbu ke grid, dihitung dari pojok area.
-- Item selebar 1 kotak akan duduk di tengah kotak, item 2 kotak menempati 2 kotak penuh, dst.
local function snapAxis(localValue: number, itemSpan: number, grid: number, halfArea: number): number
	local cells = math.max(1, math.ceil((itemSpan - 0.001) / grid))
	local halfSpan = cells * grid / 2
	local fromCorner = localValue + halfArea
	local cellIndex = math.round((fromCorner - halfSpan) / grid)
	return cellIndex * grid + halfSpan - halfArea
end

-- worldPos = posisi target mentah (hasil raycast mouse).
-- Mengembalikan CFrame PUSAT bounding box item, sudah di-snap ke grid
-- dan duduk tepat di atas permukaan area.
function GridUtil.snapToGrid(area: Instance, worldPos: Vector3, itemSize: Vector3, rotationY: number): CFrame
	local grid = BuildConfig.GRID_SIZE
	local areaCFrame, areaSize = GridUtil.getAreaBounds(area)
	local rotatedSize = GridUtil.getRotatedSize(itemSize, rotationY)
	local localPos = areaCFrame:PointToObjectSpace(worldPos)

	local x = snapAxis(localPos.X, rotatedSize.X, grid, areaSize.X / 2)
	local z = snapAxis(localPos.Z, rotatedSize.Z, grid, areaSize.Z / 2)
	local y = areaSize.Y / 2 + itemSize.Y / 2

	return areaCFrame * CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(rotationY), 0)
end

-- Cek apakah seluruh footprint item masih berada di dalam area build
function GridUtil.isInsideArea(area: Instance, itemCFrame: CFrame, itemSize: Vector3, rotationY: number): boolean
	local areaCFrame, areaSize = GridUtil.getAreaBounds(area)
	local rotatedSize = GridUtil.getRotatedSize(itemSize, rotationY)
	local localPos = areaCFrame:PointToObjectSpace(itemCFrame.Position)
	local eps = 0.05
	return math.abs(localPos.X) + rotatedSize.X / 2 <= areaSize.X / 2 + eps
		and math.abs(localPos.Z) + rotatedSize.Z / 2 <= areaSize.Z / 2 + eps
end

return GridUtil
