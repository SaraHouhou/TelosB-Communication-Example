#include <Timer.h>
#include <stdio.h>
#include <string.h>
#include "packets.h"

module Project2TempC{
	uses { //General
		interface Boot;
		interface Leds;
	}
	uses { //Timers
		interface Timer<TMilli> as TempTimer;
		interface Timer<TMilli> as NetworkTimer;
	}

	uses interface Read<uint16_t> as TempRead;

	uses {// Networking
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
		interface Receive;
	}
}
implementation{

	bool _radioBusy = FALSE;

	uint16_t centigrade, fahrenheit;
	uint8_t tempBool;
	message_t _packet;

	event void Boot.booted(){
		call TempTimer.startPeriodic(2000);
		call NetworkTimer.startPeriodic(4000);
		call AMControl.start();
		call Leds.led0On();
	}

	event void TempTimer.fired(){
		if (!(call TempRead.read() == SUCCESS))
			call Leds.led0Off();
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

	event void NetworkTimer.fired(){
		if (_radioBusy == FALSE) {
			//Create Packet
			TempMsg_t* msg = call Packet.getPayload(& _packet, sizeof(TempMsg_t));
			msg->NodeId = TOS_NODE_ID;
			msg->tempBool = tempBool;

			//Send Packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &_packet, sizeof(TempMsg_t)) == SUCCESS) {
				_radioBusy = TRUE;
			}
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

	event void AMSend.sendDone(message_t *msg, error_t error) {
		if (msg == &_packet) {
			_radioBusy = FALSE;
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len) {
		if (len == sizeof(LightMsg_t)) {
			LightMsg_t * incomingpacket = (LightMsg_t*) payload;

			uint8_t lightBool = incomingpacket->lightBool;

			if (lightBool == 1) {
				call Leds.led1On();
			}
			else {
				call Leds.led1Off();
			}
		}
		return msg;
	}
}
