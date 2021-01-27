local ClosestTeleport

function SetEntityCoordsAndHeadingNoOffset(entity, xPos, yPos, zPos, heading, p5, p6)
	return Citizen.InvokeNative(0x0918E3565C20F03C, entity, xPos, yPos, zPos, heading, p5, p6)
end

function BlipAddForCoord(blipHash, x, y, z)
	return Citizen.InvokeNative(0x554D9D53F696D002, blipHash, x, y, z)
end

function ActivateMoonshineShack(shack)
	for _, imap in ipairs(shack.imaps) do
		RequestImap(imap)
	end

	if IsValidInterior(shack.interiorId) then
		if IsInteriorEntitySetActive(shack.interiorId, shack.interiorEntitySets[1]) then
			print(shack.label .. " moonshine shack interior is already active")
		else
			for _, set in ipairs(shack.interiorEntitySets) do
				ActivateInteriorEntitySet(shack.interiorId, set)
			end

			print(shack.label .. " moonshine shack interior activated")
		end
	end

	shack.blip = BlipAddForCoord(1664425300, shack.entrance.xyz)
	SetBlipSprite(shack.blip, Config.BlipSprite, true)
end

function DeactivateMoonshineShack(shack)
	for _, imap in ipairs(shack.imaps) do
		RemoveImap(imap)
	end

	if IsValidInterior(shack.interiorId) then
		if IsInteriorEntitySetActive(shack.interiorId, shack.interiorEntitySets[1]) then
			for _, set in ipairs(shack.interiorEntitySets) do
				DeactivateInteriorEntitySet(shack.interiorId, set, true)
			end

			print(shack.label .. " moonshine shack interior deactived")
		else

			print(shack.label .. " moonshine shack interior is not active")
		end
	end

	RemoveBlip(shack.blip)
end

function DrawText3D(text, x, y, z)
	local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)

	SetTextScale(0.35, 0.35)
	SetTextFontForCurrentCommand(1)
	SetTextColor(255, 255, 255, 223)
	SetTextCentre(1)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), screenX, screenY)
end

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then
		return
	end

	for _, shack in ipairs(Config.MoonshineShacks) do
		DeactivateMoonshineShack(shack)
	end
end)

CreateThread(function()
	for _, shack in ipairs(Config.MoonshineShacks) do
		ActivateMoonshineShack(shack)
	end
end)

CreateThread(function()
	while true do
		local playerCoords = GetEntityCoords(PlayerPedId())
		local closestTeleport

		for _, shack in ipairs(Config.MoonshineShacks) do
			local distance = #(playerCoords - shack.entrance.xyz)

			if distance < Config.TeleportDistance then
				closestTeleport = {
					label = "enter " .. shack.label .. " moonshine shack",
					coords = shack.entrance,
					destination = shack.exit
				}

				break
			end

			distance = #(playerCoords - shack.exit.xyz)

			if distance < Config.TeleportDistance then
				closestTeleport = {
					label = "exit " .. shack.label .. " moonshine shack",
					coords = shack.exit,
					destination = shack.entrance
				}

				break
			end
		end

		ClosestTeleport = closestTeleport

		Wait(1000)
	end
end)

CreateThread(function()
	while true do
		if ClosestTeleport then
			DrawText3D("Press [E] to " .. ClosestTeleport.label, table.unpack(ClosestTeleport.coords))

			if IsControlJustPressed(0, Config.TeleportControl) then
				SetEntityCoordsAndHeadingNoOffset(PlayerPedId(), ClosestTeleport.destination)
			end
		end

		Wait(0)
	end
end)
