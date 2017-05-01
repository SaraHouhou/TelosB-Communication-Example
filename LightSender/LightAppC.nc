configuration LightAppC{
	//
}
implementation{

	//General
	components MainC, LedsC;
	components LightC as App;

	App.Boot -> MainC;
	App.Leds -> LedsC;

	//Timers
	components new TimerMilliC() as LightTimer;
	components new TimerMilliC() as NetworkTimer;

	App.LightTimer -> LightTimer;
	App.NetworkTimer -> NetworkTimer;

	//print
	components SerialPrintfC;

	//light
	components new HamamatsuS10871TsrC() as LightSensor;
	App.LightRead -> LightSensor;

	//Radio
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO);

	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
}
