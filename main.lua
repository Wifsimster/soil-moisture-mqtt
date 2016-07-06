require('config')
local ntp = require('ntp')

TOPIC = "/sensors/"..LOCATION.."/hydrometer/data"

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

ip = wifi.sta.getip()

m:lwt("/offline", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

ntp.sync()

GREEN_LED = 4  -- GPIO_2
YELLOW_LED = 3 -- GPIO_0
RED_LED = 2 -- GPIO_4

-- Set leds mode
gpio.mode(GREEN_LED, gpio.OUTPUT)
gpio.mode(YELLOW_LED, gpio.OUTPUT)
gpio.mode(RED_LED, gpio.OUTPUT)

-- Init leds
gpio.write(GREEN_LED, gpio.LOW)
gpio.write(YELLOW_LED, gpio.LOW)
gpio.write(RED_LED, gpio.LOW)

function readData() 
    data = adc.read(0)
    print('data:'..data)
    return data
end

function setLeds(data)
    if data >= 1010 then
        gpio.write(GREEN_LED, gpio.LOW)
        gpio.write(YELLOW_LED, gpio.LOW)
        gpio.write(RED_LED, gpio.HIGH)
        return "air"
    elseif data >= 850 and data < 1010 then
        gpio.write(GREEN_LED, gpio.LOW)
        gpio.write(YELLOW_LED, gpio.HIGH)
        gpio.write(RED_LED, gpio.LOW)
        return "dry"
    elseif data >= 750 and data < 850 then
        gpio.write(GREEN_LED, gpio.HIGH)
        gpio.write(YELLOW_LED, gpio.LOW)
        gpio.write(RED_LED, gpio.LOW)
        return "wet"
    elseif data >= 0 and data < 750 then
        gpio.write(GREEN_LED, gpio.LOW)
        gpio.write(YELLOW_LED, gpio.LOW)
        gpio.write(RED_LED, gpio.HIGH)
        return "water"
    end
end

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    tmr.alarm(1, REFRESH_RATE, 1, function()
        hum = readData()
        msg = setLeds(hum)
        DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'",'
        DATA = DATA..'"date":"'..ntp.date()..'","time":"'..ntp.time()..'",'
        DATA = DATA..'"hum":"'..hum..'", "message":"'..msg..'"}'
        -- Publish a message (QoS = 0, retain = 0)       
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
        end)
    end)
end)
