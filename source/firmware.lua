local Utils = require("utils")

local gpioIndex = 3 -- Input pin (detects the press of the button)
local gpioIndex_Led = 4

local ledStatus = false
local ledBlinking = true

local Wifi_Connected = 5

local counter = 0 -- counts how often the button was pressed (for debug purposes)

require("config")

-- callback function (handles interrupt)
function buttonPressed(level)
	print("Trigger (" .. counter .. ")")

	counter = counter + 1
	
	sendRequest(counter)
end

-- create a conenction to the webserver and call the /setGcmId action for testing purposes 
function sendRequest(number)
	conn=net.createConnection(net.TCP, false) 

	conn:on("receive", function(conn, payload) print(c) end )

	print("Connecting to " .. config.SERVER_HOSTNAME .. "")
	conn:connect(config.SERVER_PORT, config.SERVER_HOSTNAME)

	conn:on("receive", function(conn, payload)
	    print(payload)
	    end) 
	conn:on("disconnection", function(conn,payload)
	     print("disconnect")
	     conn:close()
	end)

	conn:on("connection", function(conn,payload)
	     print("sending...")
	     conn:send("GET " .. config.SERVER_URL .. "/ring/ HTTP/1.0\r\n") 
	     conn:send("Host: " .. config.SERVER_HOSTNAME .. "\r\n") 
	     conn:send("Accept: */*\r\n") 
	     conn:send("User-Agent: Mozilla/4.0 (compatible; ESP8266;)\r\n") 
	     conn:send("\r\n") 
	end)
end

function setStatusLed(value)
	if (value) then
		gpio.write(gpioIndex_Led, gpio.HIGH)
	else 
		gpio.write(gpioIndex_Led, gpio.LOW)
	end
end

tmr.alarm(0, 100, 1, 
	function() 
		if ledBlinking then
			ledStatus = not ledStatus
			setStatusLed(ledStatus)
		end

		if wifi.sta.status() == Wifi_Connected then -- stop blinking if Wifi is successfully connected
			ledBlinking = false
			setStatusLed(true)
		else
			ledBlinking = true
		end
    end 
    )

gpio.mode(gpioIndex, gpio.INT)
gpio.trig(gpioIndex, "up", Utils.debounce(buttonPressed))

gpio.mode(gpioIndex_Led, gpio.OUTPUT)
gpio.write(gpioIndex_Led, gpio.LOW)

print "Running."