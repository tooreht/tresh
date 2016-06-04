/*  
 *  ------ Waspmote Pro Code Example -------- 
 *  
 *  Explanation: This is the basic Code for Waspmote Pro
 *  
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
 */

#include <WaspSX1272.h>

// SX1272
uint8_t node_address = 10; // address of this node
uint8_t rx_address = 2; // define the destination address to send packets

int8_t e; // status variable

void setup() {
   PWR.ifHibernate(); // Checks if we come from a normal reset or an hibernate reset
   USB.ON();
   RTC.ON();
    
   USB.printf("%s\n", "Enabling PWR_5V");
   delay(200);
   PWR.setSensorPower(SENS_5V, SENS_ON);
   delay(200);
    
   USB.println(F("Setting LORA configuration")); 

  sx1272.ON();   // Init sx1272 module
  e = sx1272.setChannel(CH_11_868);  // Select frequency channel
  e = sx1272.setHeaderON();   // Select implicit (off) or explicit (on) header mode
  e = sx1272.setMode(10);  // Select mode: from 1 to 10
  e = sx1272.setCRC_ON();  // Select CRC on or off
  e = sx1272.setPower('H'); // Select output power (Max, High or Low)
  e = sx1272.setNodeAddress(node_address); // Select the node address value: from 2 to 255
  e = sx1272.setRetries(3);    // Select the maximum number of retries: from '0' to '5'

  pinMode(DIGITAL7,OUTPUT); // Trigger for Ultrasonic Sensor
  pinMode(DIGITAL6,INPUT); // Receiver for Ultrasonic Sensor

  delay(500);
}

void loop() {
  long duration;
  uint16_t dist = 0; // Distance
  int distMin = 0;
  int distMax = 0;
  int distCount = 0;
  int distMinCnt = 0;
  int distMaxCnt = 0;
  
  uint16_t batt=0; // Battery
  int battMin = 0;
  int battMax = 0; 
  int battCount = 0;
  int battMinCnt = 0;
  int battMaxCnt = 0;

  uint16_t temp = 0; // Temperature

  int distance[10];
  int battery[10];
  
  USB.println("Measuring");
  for (int i=0; i <= 9; i++){       
      // initiate measurement
      digitalWrite(DIGITAL7, LOW);
      delayMicroseconds(10);
      digitalWrite(DIGITAL7, HIGH);
      delayMicroseconds(10);
      digitalWrite(DIGITAL7, LOW);
      // measure echo
      duration = pulseIn(DIGITAL6, HIGH);
  
      // calculate & show distance in cm
      distance[i] = duration / 29 / 2;
      //delay(100);
      battery[i] = PWR.getBatteryLevel();
   }
   
   distMax = distance[0];
   distMin = distance[0];
   
   battMax = battery[0];
   battMin = battery[0];
   
   for (int i=0; i <= 9; i++){ // read 10 times the Distance and batery
     if ( distance[i] > distMax) {
       distMax = distance[i];
     } else if ( distance[i] < distMin) {
       distMin = distance[i];
     }
     if ( battery[i] > battMax) {
       battMax = battery[i];
     } else if ( battery[i] < battMin) {
       battMin = battery[i];
     }
    }
    
    for (int i=0; i <= 9; i++){ // evaluate the min and max of the 10 measurements
     if ( distance[i] < distMax && distance[i] > distMin) {
      distCount++;
      dist = dist + distance[i];
     } else if (distance[i] == distMax) {
       distMaxCnt++; 
     } else if (distance[i] == distMin)
       distMinCnt++;
     
     if ( battery[i] < battMax && battery[i] > battMin) {
      battCount++;
      batt = batt + battery[i];
     } else if (battery[i] == battMax) {
       battMaxCnt++; 
     } else if (battery[i] == battMin) {
       battMinCnt++;
     }  
   }
    
    

    if (distCount > 0 && distMax - distMin > 1) { // substract min and max values if there are values in between
      dist = dist / distCount;
    } else {
      if (distMaxCnt > distMinCnt && distMaxCnt > 2) {
        dist = distMax;
      } else if (distMinCnt > distMaxCnt && distMinCnt > 2) {
       dist = distMin; 
      } else {
       dist = distMin + distMax / 2; 
      }
    }
    
    if (battCount > 0 && battMax - battMin > 1) {
      batt = batt / battCount;
    } else {
      if (battMaxCnt > battMinCnt && battMaxCnt > 2) {
        batt = battMax;
      } else if (battMinCnt > battMaxCnt && battMinCnt > 2) {
       batt = battMin; 
      } else {
       batt = battMin + battMax / 2; 
      }
    }

//     SX1272 Temperature - always 12
//     e = sx1272.getTemp();
//    if( e == 0 ) 
//    { 
//     temp = sx1272._temp;
//    }

    temp = RTC.getTemperature();
        
    char res[48];
    sprintf(res, "\"distance\": %d, \"battery\": %d, \"temp\": %d", dist, batt, temp);
  
    USB.printf(res);
    USB.println();

  uint8_t bts[7]; //bytes to send

    // Split 16 bit int in 2 8 bit int  
    bts[0] = dist & 0xFF;
    bts[1] = (dist >> 8);
    bts[2] = batt & 0xFF;
    bts[3] = (batt >> 8);
    bts[4] = temp & 0xFF;
    bts[5] = (temp >> 8);
    bts[6] = '0';
  
  // Show int-array for troubleshooting
//    for (int i = 0; i <= 6; i++) {
//      USB.printf("i %d: ", i);
//      USB.printHex(bts[i]);
//      USB.println();
//    }
//    USB.println();   
  
// // // Manual Packet construction for troubleshooting  
//  // SetDest
//  e = sx1272.setDestination (rx_address);
//  if( e == 0 ) 
//  {
//    USB.println(F("SetDest OK"));     
//  }
//  else 
//  {
//    USB.print(F("Error SetDest"));  
//    USB.print(F("state: "));
//    USB.println(e, DEC);
//  }
//  
// 
//// SetPayload
// e = sx1272.setPayload(bts);
//  if( e == 0 ) 
//  {
//    USB.println(F("SetPayload OK"));     
//  }
//  else 
//  {
//    USB.print(F("Error SetPayload."));  
//    USB.print(F("state: "));
//    USB.println(e, DEC);
//  }
//  
//  //  // SetPacket
//  e = sx1272.setPacket(rx_address, bts);
//  if( e == 0 ) 
//  {
//    USB.println(F("SetPacket OK"));     
//  }
//  else 
//  {
//    USB.print(F("Error SetPayload."));  
//    USB.print(F("state: "));
//    USB.println(e, DEC);
//  }
//
//  // SetPayloadLength
//  e = sx1272.setTimeout();
//  if( e == 0 ) 
//  {
//    USB.println(F("setTimeout OK"));     
//  }
//  else 
//  {
//    USB.print(F("Error setTimeout."));  
//    USB.print(F("state: "));
//    USB.println(e, DEC);
//  }
//  
//  
//  // Sending packet
//  e = sx1272.sendWithMAXTimeout();
//  if( e == 0 ) 
//  {
//    USB.println(F("Packet sent OK"));     
//  }
//  else 
//  {
//    USB.print(F("Error sending the packet."));  
//    USB.print(F("state: "));
//    USB.println(e, DEC);
//  }
//     
    
  // Sending packet, with retries if failure, and waiting an ACK response
  e = sx1272.sendPacketTimeoutACKRetries( rx_address, bts, 7);
  // Check sending statusno
  if( e == 0 ) 
  {
    USB.println(F("Packet sent OK"));     
  }
  else 
  { 
    if(e == 9) //Ack lost even with retries -> wait random time and retry ONCE
    {
      USB.print("Failed to send, retrying after ");
      uint16_t wait = (dist * abs(random())) % 10000 ;
      USB.print(wait);
      USB.println("ms");
      delay(wait);
      e = sx1272.sendPacketTimeoutACKRetries( rx_address, bts, 7);
      if(e == 0) {
       USB.println("Sending now successfull");
      } else {
       USB.println("Sending failed again, giving up"); 
      }
    } else {
    USB.print(F("Error sending the packet."));  
    USB.print(F("state: "));
    USB.println(e, DEC);
    }
  }

  USB.println("Going to sleep for 20s");
  USB.OFF();
  sx1272.OFF();
  PWR.setSensorPower(SENS_5V, SENS_OFF);
  PWR.hibernate("00:00:00:20", RTC_OFFSET, RTC_ALM1_MODE2);
    
   
}

