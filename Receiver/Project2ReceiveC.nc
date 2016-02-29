#include "packets.h"

module Project2ReceiveC{
	uses { //General
		interface Boot;
		interface Leds;
	}

	uses {// Networking
		interface Packet;
		interface AMPacket;
		interface SplitControl as AMControl;
		interface Receive;
	}
}
implementation{

	event void Boot.booted(){
		call AMControl.start();
	}


		event void AMControl.startDone(error_t error) {
			if (!(error == SUCCESS))
				call AMControl.start();
		}

		event void AMControl.stopDone(error_t error) {

		}

		event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len) {
			if (len == sizeof(MoteMsg_t)) {
				MoteMsg_t * incomingpacket = (MoteMsg_t*) payload;

				uint8_t tempBool = incomingpacket->tempBool;
				uint8_t lightBool = incomingpacket->lightBool;
				uint8_t humidBool = incomingpacket->humidBool;

				if (humidBool == 1) {
					call Leds.led0On();
				}
				else {
					call Leds.led0Off();
				}

				if (tempBool == 1) {
					call Leds.led1On();
				}
				else {
					call Leds.led1Off();
				}

				if (lightBool == 1) {
					call Leds.led2On();
				}
				else {
					call Leds.led2Off();
				}
			}
			return msg;
		}
}
