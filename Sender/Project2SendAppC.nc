configuration Project2SendAppC{
	//
}
implementation{

	//General
	components MainC, LedsC;
	components Project2SendC as App;

	App.Boot -> MainC;
	App.Leds -> LedsC;

	//Timers
	components new TimerMilliC() as LightTimer;
	components new TimerMilliC() as TempTimer;
	components new TimerMilliC() as NetworkTimer;

	App.LightTimer -> LightTimer;
	App.TempTimer -> TempTimer;
	App.NetworkTimer -> NetworkTimer;

	//print
	components SerialPrintfC;

	//temp
	components new SensirionSht11C() as TempAndHumid;
	App.TempRead -> TempAndHumid.Temperature;
	App.HumidRead -> TempAndHumid.Humidity;


	//light
	components new HamamatsuS10871TsrC() as LightSensor;
	App.LightRead -> LightSensor;

	//Radio
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);

	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;

}
