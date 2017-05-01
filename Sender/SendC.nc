#include <Timer.h>
#include <stdio.h>
#include <string.h>
#include "packets.h"

module SendC{
	uses { //General
		interface Boot;
		interface Leds;
	}
	uses { //Timers
		interface Timer<TMilli> as LightTimer;
		interface Timer<TMilli> as TempTimer;
		interface Timer<TMilli> as NetworkTimer;
	}

	uses { //Sensors
		interface Read<uint16_t> as TempRead;
		interface Read<uint16_t> as HumidRead;
		interface Read<uint16_t> as LightRead;
	}
	uses {// Networking
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
	}
}
implementation{

	bool _radioBusy = FALSE;

	uint16_t centigrade, fahrenheit, humidity, luminance;
	uint8_t tempBool, lightBool, humidBool;
	message_t _packet;

	event void Boot.booted(){
		call LightTimer.startPeriodic(1000);
		call TempTimer.startPeriodic(2000);
		call NetworkTimer.startPeriodic(4000);
		call AMControl.start();
		Leds.led0On;
	}

	event void LightTimer.fired(){
		if (!(call LightRead.read() == SUCCESS))
			call Leds.led0Off();
	}

	event void TempTimer.fired(){
		if (!(call TempRead.read() == SUCCESS))
			call Leds.led0Off();
		if (!(call HumidRead.read() == SUCCESS))
			call Leds.led0Off();
	}

	event void NetworkTimer.fired(){
		if (_radioBusy == FALSE) {
			//Create Packet
			MoteMsg_t* msg = call Packet.getPayload(& _packet, sizeof(MoteMsg_t));
			msg->NodeId = TOS_NODE_ID;
			msg->tempBool = tempBool;
			msg->lightBool = lightBool;
			msg->humidBool = humidBool;

			//Send Packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &_packet, sizeof(MoteMsg_t)) == SUCCESS) {
				_radioBusy = TRUE;
			}
		}
	}

	event void AMSend.sendDone(message_t *msg, error_t error) {
		if (msg == &_packet) {
			_radioBusy = FALSE;
		}
	}

	event void TempRead.readDone(error_t result, uint16_t val){
		if (result == SUCCESS){
			//process val
			centigrade = -39.6 + .01*val;
			fahrenheit = (9/5)*centigrade + 32;
			printf("Current temp is: %d %d \r\n", centigrade, fahrenheit);
			if (fahrenheit > 85){
				call Leds.led1On();
				tempBool = 1;
			} else {
				call Leds.led1Off();
				tempBool = 0;
			}
		} else {
			//throw error
			printf("Error reading from sensor! \r\n");
		}
	}

	event void HumidRead.readDone(error_t result, uint16_t val){
		if (result == SUCCESS){
			//process val
			humidity = -4.0 + 0.0405*val + (-2.8 * pow(10.0,-6))*(pow(val,2));
			printf("Current humidity is: %d \r\n", humidity);
			if (humidity > 25){
				call Leds.led0On();
				humidBool = 1;
			} else {
				call Leds.led0Off();
				humidBool = 0;
			}

		}
		else {
			//throw error
			printf("Error reading from sensor! \r\n");
		}
	}

	event void LightRead.readDone(error_t result, uint16_t val){
		if (result == SUCCESS){
			//process val
			luminance = (2.5*6250.0/4096.0)*val;
			printf("Current light is: %d \r\n", luminance);
			if (luminance < 30){
				call Leds.led2On();
				lightBool = 1;
			} else {
				call Leds.led2Off();
				lightBool = 0;
			}
		} else {
			//throw error
			printf("Error reading from sensor! \r\n");
		}
	}

	event void AMControl.startDone(error_t error) {
		if (error == SUCCESS) {
			call Leds.led0On();
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error) {

	}
}
