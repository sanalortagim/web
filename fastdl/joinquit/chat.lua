local sx,sy = guiGetScreenSize()
local px = 40
local py = sy/2 - 40
local counter = 250
local fadeOut = nil

cMessages = {}

function dxDrawColorText(str, ax, ay, bx, by, color, scale, font, alpha)
  local pat = "(.-)#(%x%x%x%x%x%x)"
  local s, e, cap, col = str:find(pat, 1)
  local last = 1
  while s do
    if cap == "" and col then color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), alpha) end
    if s ~= 1 or cap ~= "" then
      local w = dxGetTextWidth(cap, scale, font)
      dxDrawText(cap, ax, ay, ax + w, by, color, scale, font, "left", "center")
      ax = ax + w
      color = tocolor(tonumber("0x"..col:sub(1, 2)), tonumber("0x"..col:sub(3, 4)), tonumber("0x"..col:sub(5, 6)), alpha)
    end
    last = e + 1
    s, e, cap, col = str:find(pat, last)
  end
  if last <= #str then
    cap = str:sub(last)
    local w = dxGetTextWidth(cap, scale, font)
    dxDrawText(cap, ax, ay, ax + w, by, color, scale, font, "left", "center")
  end
end

addEventHandler("onClientRender", root, 
	function()
		if getElementData(localPlayer, "guiDisabled") then return end
		counter = counter - 1
		if counter == 20 and cMessages[1] then
			fadeOut = cMessages[1]
			table.remove(cMessages, 1)
		end
		
		if counter <= 20 and counter > 0 then
			py = sy/2 - 40 + counter
		elseif counter == 0 then
			py = sy/2 - 40
			counter = 200
		end
		
		if fadeOut then
			fadeOut[3] = math.max(fadeOut[3] - 0.05, 0)		
			for i = 1,2 do dxDrawImage(px - 20, 2 + py - 20, 18,16, fadeOut[2]..".png", 0,0,0,tocolor(255,255,255,255*fadeOut[3])) end
			dxDrawText(string.gsub ( fadeOut[1], '#%x%x%x%x%x%x', ''), px+1, 1+py - 20, px + 101, 1+py, tocolor(0,0,0,200*fadeOut[3]), 1, "default-bold", "left", "center" )
			dxDrawColorText(fadeOut[1], px, py -20, px + 100, py, tocolor(255,255,255,255*fadeOut[3]), 1, "default-bold", 255*fadeOut[3] )
			if fadeOut[5] and fExists(fadeOut[5]) and fadeOut[4] == 1 then
				dxDrawImage(px - 25, 2 + py - 20, 18,16, fadeOut[5], 0,0,0,tocolor(255,255,255,255*fadeOut[3]))
			end
			if fadeOut[3] == 0 then fadeOut = nil end
		end
		
		
		for id, message in ipairs(cMessages) do
			if id > 4 then return end			
			cMessages[id][3] = math.min(cMessages[id][3] + 0.05, 1)		
			for i = 1,2 do dxDrawImage(px - 20, 2 + py + ( id - 1 ) * 20, 18,16, message[2]..".png", 0,0,0,tocolor(255,255,255,255*cMessages[id][3])) end
			dxDrawText(string.gsub ( message[1], '#%x%x%x%x%x%x', ''), px+1, 1+py + (id-1)*20, px + 101, 1+py + id*20, tocolor(0,0,0,200*cMessages[id][3]), 1, "default-bold", "left", "center" )
			dxDrawColorText(message[1], px, py + (id-1)*20, px + 100, py + id*20, tocolor(255,255,255,255*cMessages[id][3]), 1, "default-bold", 255*cMessages[id][3] )
			
			if message[5] and fExists(message[5]) and message[4] == 1 then
				dxDrawImage(px - 25, 2 + py + ( id - 1 ) * 20, 18,16,message[5],0,0,0,tocolor(255,255,255,255*message[3]))
			end
			
		end
	end
)

function outputCrapBox( mType, message, more )
	if #cMessages == 0 then counter = 300 end
	local intMType
	if mType == "join" then
		intMType = 1
	elseif mType == "quit" then
		intMType = 2
	elseif mType == "login" then
		intMType = 3
	elseif mType == "nickchange" then
		intMType = 4
	elseif mType == "mute" then
		intMType = 5
		
	else
		return
	end
	if more then
		more = ":admin/client/images/flags/"..more..".png"
	end
	table.insert( cMessages, { message, mType, 0, intMType, more } )
end

addEvent("onClientCrapBox", true)
addEventHandler("onClientCrapBox", root, 
	function( mType, message, more )
		outputCrapBox( mType, message, more )
	end
)

addEventHandler('onClientPlayerChangeNick', root,
	function(oldNick, newNick)
		outputCrapBox("nickchange", oldNick.." #FFFFFFİsmini değiştirdi. "..newNick..".")
	end
)

flExists = {}
flChecked = {}

function fExists( filename )
	if flChecked[filename] then return flExists[filename] end
	flChecked[filename] = true
	flExists[filename] = fileExists(filename)
	return flExists[filename]
end