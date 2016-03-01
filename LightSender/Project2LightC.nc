#include <Timer.h>
#include <stdio.h>
#include <string.h>
#include "packets.h"

module Project2LightC{
	uses { //General
		interface Boot;
		interface Leds;
	}

	uses { //Timers
		interface Timer<TMilli> as LightTimer;
		interface Timer<TMilli> as NetworkTimer;
	}

	uses interface Read<uint16_t> as LightRead;

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

		uint16_t luminance;
		uint8_t lightBool;
		message_t _packet;

	event void Boot.booted(){
		call LightTimer.startPeriodic(1000);
		call NetworkTimer.startPeriodic(4000);
		call AMControl.start();
		call Leds.led0On();
	}

	event void LightTimer.fired(){
		if (!(call LightRead.read() == SUCCESS))
			call Leds.led0Off();
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

	event void NetworkTimer.fired(){
		if (_radioBusy == FALSE) {
			//Create Packet
			LightMsg_t* msg = call Packet.getPayload(& _packet, sizeof(LightMsg_t));
			msg->NodeId = TOS_NODE_ID;
			msg->lightBool = lightBool;

			//Send Packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &_packet, sizeof(LightMsg_t)) == SUCCESS) {
				_radioBusy = TRUE;
			}
		}
	}

		event void AMControl.startDone(error_t error) {
			if (!(error == SUCCESS))
				call AMControl.start();
		}

		event void AMControl.stopDone(error_t error) {

		}

		event void AMSend.sendDone(message_t *msg, error_t error) {
			if (msg == &_packet) {
				_radioBusy = FALSE;
			}
		}

		event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len) {
			if (len == sizeof(TempMsg_t)) {
				TempMsg_t * incomingpacket = (TempMsg_t*) payload;

				uint8_t tempBool = incomingpacket->tempBool;

				if (tempBool == 1) {
					call Leds.led1On();
				}
				else {
					call Leds.led1Off();
				}
			}
			return msg;
		}
}
