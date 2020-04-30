local xml = xmlLoadFile ( "settings.xml" )
local nodeColor = xmlFindChild ( xml, "color", 0 )
local nodeFont = xmlFindChild ( xml, "font", 0 )
local nodeRealism = xmlFindChild ( xml, "realism", 0 )
local nodeStations = xmlFindChild ( xml, "stations", 0 )
local label = guiCreateLabel ( 0, 0, 1, 0.1, "Radyo Kapali", true )
guiLabelSetColor ( label, xmlNodeGetAttribute ( nodeColor, "r" ), xmlNodeGetAttribute ( nodeColor, "g" ), xmlNodeGetAttribute ( nodeColor, "b" ) )
guiLabelSetHorizontalAlign ( label, "center" )
guiSetFont ( label, xmlNodeGetValue ( nodeFont ) )
guiSetVisible ( label, false )

addEventHandler ( "onClientResourceStart", getResourceRootElement (),
	function ()
		showPlayerHudComponent ( "radio", false )
		setElementData ( getLocalPlayer (), "liveradio.radio", 0 )

		for k, v in ipairs ( getElementsByType ( "vehicle" ) ) do
			setElementData ( v, "liveradio.radio0", false )
			setElementData ( v, "liveradio.radio1", false )
			setElementData ( v, "liveradio.radio2", false )
			setElementData ( v, "liveradio.radio3", false )
		end
	end
)

addEventHandler ( "onClientResourceStop", getResourceRootElement (),
	function ()
		showPlayerHudComponent ( "radio", true )
	end
)

addEventHandler ( "onClientPlayerVehicleEnter", getLocalPlayer (),
	function ( vehicle, seat )
		setRadioChannel ( 0 )
		setElementData ( getLocalPlayer (), "liveradio.seat", seat )

		if sound then
			if isElement ( sound ) then destroyElement ( sound ) end
		end

		if xmlNodeGetAttribute ( nodeRealism, "enabled" ) == "true" then
			if getElementData ( vehicle, "liveradio.radio0" ) then
				setElementData ( getLocalPlayer (), "liveradio.radio", getElementData ( vehicle, "liveradio.radio0" ) )
			else
				for k, v in ipairs ( xmlNodeGetChildren ( nodeStations ) ) do setElementData ( getLocalPlayer (), "liveradio.radio", k ) end

				setElementData ( getLocalPlayer (), "liveradio.radio", math.random ( getElementData ( getLocalPlayer (), "liveradio.radio" ) ) )
				setElementData ( vehicle, "liveradio.radio0", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
				setElementData ( vehicle, "liveradio.radio1", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
				setElementData ( vehicle, "liveradio.radio2", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
				setElementData ( vehicle, "liveradio.radio3", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
			end
		else
			if getElementData ( vehicle, "liveradio.radio" .. seat ) then
				setElementData ( getLocalPlayer (), "liveradio.radio", getElementData ( vehicle, "liveradio.radio" .. seat ) )
			else
				for k, v in ipairs ( xmlNodeGetChildren ( nodeStations ) ) do setElementData ( getLocalPlayer (), "liveradio.radio", k ) end

				setElementData ( getLocalPlayer (), "liveradio.radio", math.random ( getElementData ( getLocalPlayer (), "liveradio.radio" ) ) )
				setElementData ( vehicle, "liveradio.radio" .. seat, getElementData ( getLocalPlayer (), "liveradio.radio" ) )
			end
		end

		local nodeStation = xmlFindChild ( nodeStations, "station", getElementData ( vehicle, "liveradio.radio" .. seat ) - 1 )

		if nodeStation then
			local radioName = xmlNodeGetAttribute ( nodeStation, "name" )
			local radioURL = xmlNodeGetAttribute ( nodeStation, "URL" )
			sound = playSound ( radioURL )
			guiSetText ( label, radioName )
			guiSetVisible ( label, true )

			if isTimer ( timerLabel ) then killTimer ( timerLabel ) end

			timerLabel = setTimer ( guiSetVisible, 5000, 1, label, false )
		else
			guiSetText ( label, "Radyo Kapali" )
			guiSetVisible ( label, true )
			setElementData ( getLocalPlayer (), "liveradio.radio", 0 )

			if isTimer ( timerLabel ) then killTimer ( timerLabel ) end

			timerLabel = setTimer ( guiSetVisible, 5000, 1, label, false )
		end

		timerVehicle = setTimer (
			function ( vehicle )
				if isPedInVehicle ( getLocalPlayer () ) == false or getPedOccupiedVehicle ( getLocalPlayer () ) ~= vehicle or getElementHealth ( getLocalPlayer () ) <= 0 then
					if sound then
						if isElement ( sound ) then destroyElement ( sound ) end
					end

					killTimer ( timerVehicle )

					guiSetVisible ( label, false )
					setElementData ( getLocalPlayer (), "liveradio.radio", 0 )
				end
			end
		, 50, 0, vehicle )
	end
)

addEventHandler ( "onClientPlayerRadioSwitch", getLocalPlayer (),
	function ( station )
		if station ~= 0 then cancelEvent () end

		if xmlNodeGetAttribute ( nodeRealism, "enabled" ) ~= "true" or getElementData ( getLocalPlayer (), "liveradio.seat" ) == 0 or getPedOccupiedVehicle ( getLocalPlayer () ) == false then
			if station == 1 then
				setElementData ( getLocalPlayer (), "liveradio.radio", getElementData ( getLocalPlayer (), "liveradio.radio" ) + 1 )
			elseif station == 12 then
				setElementData ( getLocalPlayer (), "liveradio.radio", getElementData ( getLocalPlayer (), "liveradio.radio" ) - 1 )

				if getElementData ( getLocalPlayer (), "liveradio.radio" ) == -1 then
					for k, v in ipairs ( xmlNodeGetChildren ( nodeStations ) ) do setElementData ( getLocalPlayer (), "liveradio.radio", k ) end
				end
			end

			if sound then
				if isElement ( sound ) then destroyElement ( sound ) end
			end

			if getPedOccupiedVehicle ( getLocalPlayer () ) then
				setElementData ( getPedOccupiedVehicle ( getLocalPlayer () ), "liveradio.radio" .. getElementData ( getLocalPlayer (), "liveradio.seat" ), getElementData ( getLocalPlayer (), "liveradio.radio" ) )
			end

			local nodeStation = xmlFindChild ( nodeStations, "station", getElementData ( getLocalPlayer (), "liveradio.radio" ) - 1 )

			if nodeStation then
				local radioName = xmlNodeGetAttribute ( nodeStation, "name" )
				local radioURL = xmlNodeGetAttribute ( nodeStation, "URL" )
				sound = playSound ( radioURL )
				guiSetText ( label, radioName )
				guiSetVisible ( label, true )

				if isTimer ( timerLabel ) then killTimer ( timerLabel ) end

				timerLabel = setTimer ( guiSetVisible, 5000, 1, label, false )
			else
				guiSetText ( label, "Radyo Kapali" )
				guiSetVisible ( label, true )
				setElementData ( getLocalPlayer (), "liveradio.radio", 0 )

				if isTimer ( timerLabel ) then killTimer ( timerLabel ) end

				timerLabel = setTimer ( guiSetVisible, 5000, 1, label, false )
			end

			if xmlNodeGetAttribute ( nodeRealism, "enabled" ) == "true" and getPedOccupiedVehicle ( getLocalPlayer () ) then
				setElementData ( getPedOccupiedVehicle ( getLocalPlayer () ), "liveradio.radio0", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
				setElementData ( getPedOccupiedVehicle ( getLocalPlayer () ), "liveradio.radio1", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
				setElementData ( getPedOccupiedVehicle ( getLocalPlayer () ), "liveradio.radio2", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
				setElementData ( getPedOccupiedVehicle ( getLocalPlayer () ), "liveradio.radio3", getElementData ( getLocalPlayer (), "liveradio.radio" ) )
				triggerServerEvent ( "onPlayerRadioSwitch", getLocalPlayer (), getPedOccupiedVehicle ( getLocalPlayer () ) )
			end
		end
	end
)

addEventHandler ( "onClientVehicleStartExit", getRootElement (),
	function ( player )
		if player == getLocalPlayer () then
			if sound then
				if isElement ( sound ) then destroyElement ( sound ) end
			end

			if isTimer ( timerVehicle ) then killTimer ( timerVehicle ) end

			guiSetVisible ( label, false )
			setElementData ( player, "liveradio.radio", 0 )
		end
	end
)

addEvent ( "switchRadioChannel", true )
addEventHandler ( "switchRadioChannel", getLocalPlayer (),
	function ()
		if sound then
			if isElement ( sound ) then destroyElement ( sound ) end
		end

		local nodeStation = xmlFindChild ( nodeStations, "station", getElementData ( getPedOccupiedVehicle ( getLocalPlayer () ), "liveradio.radio0" ) - 1 )

		if nodeStation then
			local radioName = xmlNodeGetAttribute ( nodeStation, "name" )
			local radioURL = xmlNodeGetAttribute ( nodeStation, "URL" )
			sound = playSound ( radioURL )
			guiSetText ( label, radioName )
			guiSetVisible ( label, true )
			setElementData ( getLocalPlayer (), "liveradio.radio", getElementData ( getPedOccupiedVehicle ( getLocalPlayer () ), "liveradio.radio0" ) )

			if isTimer ( timerLabel ) then killTimer ( timerLabel ) end

			timerLabel = setTimer ( guiSetVisible, 5000, 1, label, false )
		else
			guiSetText ( label, "Radyo Kapali" )
			guiSetVisible ( label, true )
			setElementData ( getLocalPlayer (), "liveradio.radio", 0 )

			if isTimer ( timerLabel ) then killTimer ( timerLabel ) end

			timerLabel = setTimer ( guiSetVisible, 5000, 1, label, false )
		end
	end
)