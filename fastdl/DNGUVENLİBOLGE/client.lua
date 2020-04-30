function onPDamage()
	if getElementData (source, "greenzone") then
		cancelEvent()
	end
end
addEventHandler ("onClientPlayerDamage", localPlayer, onPDamage)

function onPSKill(target)
	if getElementData (target, "greenzone") then
		cancelEvent()
	end
end
addEventHandler ("onClientPlayerStealthKill", localPlayer, onPSKill)

function renderGreenzoneTag()
	local streamedPlayers = getElementsByType ("player", root, true)
	if streamedPlayers and #streamedPlayers ~= 0 then
		local lpos = {getElementPosition(localPlayer)}
		for _,p in ipairs (streamedPlayers) do
			if p and isElement (p) then
				if getElementData (p, "greenzone") then
					local ppos = {getElementPosition(p)}
					if getDistanceBetweenPoints3D (lpos[1], lpos[2], lpos[3], ppos[1], ppos[2], ppos[3]) <= 20 then
						local x, y = getScreenFromWorldPosition (ppos[1], ppos[2], ppos[3]+1.2)
						if x and y then
							dxDrawText ("GÜVENDESİN", x+1, y+1, x, y, tocolor (0, 0, 0), 0.5, "bankgothic", "center")
							dxDrawText ("GÜVENDESİN", x, y, x, y, tocolor (0, 220, 0), 0.5, "bankgothic", "center")
						end
					end
				end
			end
		end
	end
end
addEventHandler ("onClientRender", root, renderGreenzoneTag)