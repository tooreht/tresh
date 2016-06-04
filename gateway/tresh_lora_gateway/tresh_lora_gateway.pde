/*  
 *  ------ [SX_04b] - RX LoRa with ACKs and Retries -------- 
 *
 *  Explanation: This example shows how to configure the semtech 
 *  module in LoRa mode and then receive packets with plain-text payloads
 *  sending an acknowledgement (ACK) to the sender. The sender retries
 *  the sending for several attempts in the case the ACK is not received
 *  
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 *  
 *  Version:           0.1
 *  Design:            David Gascón 
 *  Implementation:    Covadonga Albiñana, Yuri Carmona
 */
     
// Include this library to transmit with sx1272
#include <WaspSX1272.h>
#include <WaspFrame.h>

// status variable
int8_t e;


void setup() 
{
  // Init USB port
  USB.ON();
    
  // Init sx1272 module
  sx1272.ON();
  e = sx1272.setChannel(CH_11_868);  // Select frequency channel
  e = sx1272.setHeaderON();   // Select implicit (off) or explicit (on) header mode
  e = sx1272.setMode(10);   // Select mode (mode 10 is the faster)  
  e = sx1272.setCRC_ON();   // Select CRC on or off
  e = sx1272.setPower('H');   // Select output power (Max, High or Low)
  e = sx1272.setNodeAddress(2);   // Select the node address value: from 2 to 255

  delay(500);  
}


void loop()
{
 char data[60] ; 
 char out[100];
  
  // Receiving packet and sending an ACK response
  e = sx1272.receivePacketTimeoutACK(10000);

  // check rx status
  if( e == 0 )
  {

   //int stop = 0;
    // show packet received
   //for(unsigned int i = 0; i < sx1272.packet_received.length - OFFSET_PAYLOADLENGTH; i++)
    {
//      if (data[i] == 'z') {
//        stop = 1;
//      }
//      if (stop == 0) {
        //data[i] = sx1272.packet_received.data[i];
      //}
    }
   // USB.println(sx1272.packet_received.length - OFFSET_PAYLOADLENGTH);
    uint16_t dist, batt, temp, address;
    
    
    uint8_t bts[7]; //bytes to receive 
    
    // put the bytes into array
    bts[0] = sx1272.packet_received.data[0];
    bts[1] = sx1272.packet_received.data[1];
    bts[2] = sx1272.packet_received.data[2];
    bts[3] = sx1272.packet_received.data[3];
    bts[4] = sx1272.packet_received.data[4];
    bts[5] = sx1272.packet_received.data[5];

    //merge each 2 bytes to 16bit int
    dist = (bts[1] << 8) | bts[0];
    batt = (bts[3] << 8) | bts[2];
    temp = (bts[5] << 8) | bts[4];
    
    address = sx1272.packet_received.src;
    e = sx1272.getSNR();
    e = sx1272.getRSSIpacket();
    // check status
    if( e == 0 ) 
    {
     sprintf(out, "{\"address\": %d, \"distance\": %d, \"battery\": %d, \"temp\": %d, \"SNR\": %i, \"RSSI\": %i}", address, dist, batt, temp, sx1272._SNR, sx1272._RSSIpacket);
    }
     USB.println(out);
 
  }
  else
  {
    // timeout-message commented out since timeouts are normal on a sensor network which updates all X minutes
    // USB.print(F("\nReceiving packet TIMEOUT, state "));
    // USB.println(e, DEC);  
  } 
 
   
  
}

