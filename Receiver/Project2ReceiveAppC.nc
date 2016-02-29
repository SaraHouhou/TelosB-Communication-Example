configuration Project2ReceiveAppC{
	//
}
implementation{

	//General
	components MainC, LedsC;
	components Project2ReceiveC as App;

	App.Boot -> MainC;
	App.Leds -> LedsC;

	//Radio
	components ActiveMessageC;
	components new AMReceiverC(AM_RADIO);

	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;
}
