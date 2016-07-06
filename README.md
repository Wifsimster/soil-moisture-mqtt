# Send soil moisture value to a MQTT broker

This LUA script is for ESP8266 hardware.

## Description

Read soil moisture sensor YL-69.

Send data every 5 secs to MQTT broker.

##Files
* ``config.lua``: Configuration variables
* ``init.lua``: Connect to a wifi AP and then execute main.lua file
* ``main.lua``: Main file
* ``ntp.lua``: Network time protocol lib

## Principle

1. Start a MQTT client and then try to connect to a MQTT broker
2. Publish data every 5 secs to broker

## Scheme

![scheme](https://github.com/Wifsimster/soil-moisture-mqtt/blob/master/sketch.png)
![scheme](https://github.com/Wifsimster/soil-moisture-mqtt/blob/master/IMG_20160706_105929.jpg)

The box is avaible to print here : http://www.thingiverse.com/thing:1660436
