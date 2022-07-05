/*
    ------ WIFI Example --------

    Explanation: This example shows how to configure the WiFi module
    to join a specific Access Point. So, ESSID and password must be
    defined.

    Copyright (C) 2021 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Version:           3.0
    Implementation:    Yuri Carmona
*/


#include <WaspWIFI_PRO_V3.h>
#include <WaspFrame.h>
#include <WaspSensorEvent_v30.h>
#include <WaspSensorGas_v30.h>
// CO2 Sensor must be connected physically in SOCKET_2
CO2SensorClass CO2Sensor;



// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
///////////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
///////////////////////////////////////
char SSID[] = "V2028";
char PASSW[] = "11223344";
///////////////////////////////////////

// choose HTTP server settings
///////////////////////////////////////
char type[] = "http";
char host[] = "82.78.81.171";
uint16_t port = 80;
///////////////////////////////////////

// define variables
uint8_t error;
uint8_t status;
unsigned long previous;

// define the Waspmote ID 
char moteID[] = "MitreanuSilviu";


void setup()
{  USB.ON();
  USB.println(F("Start program"));
  //////////////////////////////////////////////////
  // 1. Switch ON the WiFi module
  //////////////////////////////////////////////////
  error = WIFI_PRO_V3.ON(socket);

  if (error == 0)
  {
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }


  //////////////////////////////////////////////////
  // 2. Reset to default values
  //////////////////////////////////////////////////
  error = WIFI_PRO_V3.resetValues();

  if (error == 0)
  {
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.print(F("2. WiFi reset to default error: "));
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////////
  // 3. Configure mode (Station or AP)
  //////////////////////////////////////////////////
  error = WIFI_PRO_V3.configureMode(WaspWIFI_v3::MODE_STATION);

  if (error == 0)
  {
    USB.println(F("3. WiFi configured OK"));
  }
  else
  {
    USB.print(F("3. WiFi configured error: "));
    USB.println(error, DEC);
  }

  // get current time
  previous = millis();


  //////////////////////////////////////////////////
  // 4. Configure SSID and password and autoconnect
  //////////////////////////////////////////////////
  error = WIFI_PRO_V3.configureStation(SSID, PASSW, WaspWIFI_v3::AUTOCONNECT_ENABLED);

  if (error == 0)
  {
    USB.println(F("4. WiFi configured SSID OK"));
  }
  else
  {
    USB.print(F("4. WiFi configured SSID error: "));
    USB.println(error, DEC);
  }


  if (error == 0)
  {
    USB.println(F("5. WiFi connected to AP OK"));

    USB.print(F("SSID: "));
    USB.println(WIFI_PRO_V3._essid);
    
    USB.print(F("Channel: "));
    USB.println(WIFI_PRO_V3._channel, DEC);

    USB.print(F("Signal strength: "));
    USB.print(WIFI_PRO_V3._power, DEC);
    USB.println("dB");

    USB.print(F("IP address: "));
    USB.println(WIFI_PRO_V3._ip);

    USB.print(F("GW address: "));
    USB.println(WIFI_PRO_V3._gw);

    USB.print(F("Netmask address: "));
    USB.println(WIFI_PRO_V3._netmask);

    WIFI_PRO_V3.getMAC();

    USB.print(F("MAC address: "));
    USB.println(WIFI_PRO_V3._mac);
  }
  else
  {
    USB.print(F("5. WiFi connect error: "));
    USB.println(error, DEC);

    USB.print(F("Disconnect status: "));
    USB.println(WIFI_PRO_V3._status, DEC);

    USB.print(F("Disconnect reason: "));
    USB.println(WIFI_PRO_V3._reason, DEC);


  }
    frame.setID(moteID);  
}



void loop()
{

  // Check if module is connected
  if (WIFI_PRO_V3.isConnected() == true)
  {
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);

    USB.println(F("\n*** Program stops ***"));

///////////////////////////////
    // 3.1. Create a new Frame 
    ///////////////////////////////
      float CO2PPM = CO2Sensor.readConcentration();
    // create new frame (only ASCII)
    frame.createFrame(ASCII); 
     Events.ON();
    // add sensor fields
    frame.addSensor(SENSOR_STR, "Level");
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.addSensor(SENSOR_GASES_TC,Events.getTemperature());
    frame.addSensor(SENSOR_CO2,CO2Sensor.readConcentration());
    
        
    // print frame
    frame.showFrame();  


    ///////////////////////////////
    // 3.2. Send Frame to Meshlium
    ///////////////////////////////

    // http frame
    error = WIFI_PRO_V3.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);

    // check response
    if (error == 0)
    {
      USB.println(F("Send frame to meshlium done"));
    }
    else
    {
      USB.println(F("Error sending frame"));
      if (WIFI_PRO_V3._httpResponseStatus)
      {
        USB.print(F("HTTP response status: "));  
        USB.println(WIFI_PRO_V3._httpResponseStatus);  
      }
    }
    
  }
  else
  {
    USB.print(F("WiFi is connected ERROR"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
  }

  delay(10000);

}

