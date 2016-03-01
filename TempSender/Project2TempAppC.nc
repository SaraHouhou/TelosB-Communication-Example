configuration Project2TempAppC{
	//
}
implementation{

	//General
	components MainC, LedsC;
	components Project2TempC as App;

	App.Boot -> MainC;
	App.Leds -> LedsC;

	//Timers
	components new TimerMilliC() as TempTimer;
	components new TimerMilliC() as NetworkTimer;

	App.TempTimer -> TempTimer;
	App.NetworkTimer -> NetworkTimer;

	//print
	components SerialPrintfC;

	//temp
	components new SensirionSht11C() as TempAndHumid;
	App.TempRead -> TempAndHumid.Temperature;

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
