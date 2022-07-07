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
#include <WaspSensorGas_Pro.h>

bmeGasesSensor  bme;



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

// NO2 Sensor must be connected physically in SOCKET_2///////
NO2SensorClass NO2Sensor(SOCKET_2); 
// Concentrations used in calibration process
#define POINT1_PPM_NO2 10.0   // <-- Normal concentration in air
#define POINT2_PPM_NO2 50.0   
#define POINT3_PPM_NO2 100.0 

// Calibration voltages obtained during calibration process (in KOHMs)
#define POINT1_RES_NO2 45.25  // <-- Rs at normal concentration in air
#define POINT2_RES_NO2 25.50
#define POINT3_RES_NO2 3.55

// Define the number of calibration points
#define numPoints 3

float concentrations[] = {POINT1_PPM_NO2, POINT2_PPM_NO2, POINT3_PPM_NO2};
float voltages[] =       {POINT1_RES_NO2, POINT2_RES_NO2, POINT3_RES_NO2};
///////////////////////////////////////////////////////////////////////////
// O2 Sensor must be connected in SOCKET_6
O2SensorClass O2Sensor(SOCKET_6);

// Percentage values of Oxygen
#define POINT1_PERCENTAGE 0.0    
#define POINT2_PERCENTAGE 5.0  

// Calibration Voltage Obtained during calibration process (in mV)
#define POINT1_VOLTAGE 0.35
#define POINT2_VOLTAGE 2.0

float concentrationso2[] = {POINT1_PERCENTAGE, POINT2_PERCENTAGE};
float voltageso2[] =       {POINT1_VOLTAGE, POINT2_VOLTAGE};

// O3 Sensor can be connected in SOCKET_5
O3SensorClass O3Sensor(SOCKET_5);

// Concentratios used in calibration process (PPM VALUE)
#define POINT1_PPM_O3 100.0   //  <--- Ro value at this concentration
#define POINT2_PPM_O3 300.0   
#define POINT3_PPM_O3 1000.0  

// Calibration resistances obtained during calibration process (in KOhms)
#define POINT1_RES_O3 7.00  //  <-- Ro Resistance at 100 ppm. Necessary value.
#define POINT2_RES_O3 20.66 
#define POINT3_RES_O3 60.30


float concentrationso3[] = { POINT1_PPM_O3, POINT2_PPM_O3, POINT3_PPM_O3 };
float resValueso3[] =      { POINT1_RES_O3, POINT2_RES_O3, POINT3_RES_O3 };







void setup()
{ 
  USB.ON();
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

// Calculate the slope and the intersection of the logarithmic function
  NO2Sensor.setCalibrationPoints(voltages, concentrations, numPoints);
  O2Sensor.setCalibrationPoints(voltageso2, concentrationso2);
  O3Sensor.setCalibrationPoints(resValueso3, concentrationso3, numPoints);
// Switch ON and configure the Gases Board
  Gases.ON();  
  // Switch ON the sensor socket
  NO2Sensor.ON();
   O2Sensor.ON();
   O3Sensor.ON();
///////////////////////////////////////

/////////////////////////Setup O2 

  
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
    // Read the sensors and compensate with the temperature internally


///////////////////////////////
    // 3.1. Create a new Frame 
    ///////////////////////////////
      
    // create new frame (only ASCII)
    frame.createFrame(ASCII); 

     bme.ON();
 
    // add sensor fields
    frame.addSensor(SENSOR_STR, "Level");
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.addSensor(SENSOR_GASES_PRO_TC,bme.getTemperature());
    frame.addSensor(SENSOR_GASES_PRO_HUM,bme.getHumidity());
    frame.addSensor(SENSOR_GASES_PRO_PRES,bme.getPressure());
    frame.addSensor(SENSOR_GASES_PRO_NO2,NO2Sensor.readConcentration());
  //  frame.addSensor(SENSOR_GASES_PRO_O2,O2Sensor.readConcentration());
 //  frame.addSensor(SENSOR_GASES_PRO_O3,O3Sensor.readConcentration());
    
    
    
        
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

  bme.OFF();
  
  delay(10000);

}

