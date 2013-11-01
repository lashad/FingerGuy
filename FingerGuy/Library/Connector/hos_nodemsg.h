/*
 *	hos_nodemsg.h
 *
 *	Copyright (c) 2010 Picktek LLC
 *
 *	This file is part of Hyperios.
 *
 *	Hyperios is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	Hyperios is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with Hyperios.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _HOS_NODEMSG_H
#define _HOS_NODEMSG_H

#include "hos_nodemsg_cfg.h"

#include <string.h>
#include <stdint.h>
#include <stdlib.h>

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

/* Wireless device physical address ( Must be unique in node network ) */
#define HOS_NODEMSG_DEVICE_ADDRESS             HOS_MY_ADDRESS   
#define HOS_NODEMSG_DEVICE_ADDRESS_BROADCAST   0xFFFF   

/* Packet header identifier */
#define HOS_NODEMSG_HEADER                      0xFE   


/* Error messages */
#define HOS_NODEMSG_ERROR_NO                    0
#define HOS_NODEMSG_ERROR_FORIEGN_PACKET        1
#define HOS_NODEMSG_ERROR_INVALID_PACKET        2
#define HOS_NODEMSG_ERROR_INVALID_HEADER        3
#define HOS_NODEMSG_ERROR_INVALID_CHECKSUM      4

#define HOS_NODEMSG_ERROR_INVALID_PARAMETER    -36


// Data types
#define HOS_NODEMSG_TYPE_INT8                   10
#define HOS_NODEMSG_TYPE_INT16                  20
#define HOS_NODEMSG_TYPE_INT32                  30
#define HOS_NODEMSG_TYPE_STRING                 40
#define HOS_NODEMSG_TYPE_BINARY                 50

// request/response
#define HOS_NODEMSG_REQUEST                     200
#define HOS_NODEMSG_RESPONSE                    201


// Command definitions
#define HOS_NODEMSG_COMMAND_INFO                251
#define HOS_NODEMSG_COMMAND_SET_DEF_CONFIG      253

// Info command modules
#define HOS_NODEMSG_COMMAND_INFO_MODULE_DESC           1
#define HOS_NODEMSG_COMMAND_INFO_MODULE_BEEP           3
#define HOS_NODEMSG_COMMAND_INFO_MODULE_DEVICE_REBOOT  7



// Monitoring flags
#define HOS_NODEMSG_MONITOR_SWITCH_INPUT        1
#define HOS_NODEMSG_MONITOR_TEMPERATURE         2
#define HOS_NODEMSG_MONITOR_COOLER              4
#define HOS_NODEMSG_MONITOR_SWITCH_SHUTDOWN     8
#define HOS_NODEMSG_MONITOR_LIGHT               16

// Input/Output flags
#define HOS_NODEMSG_INDICATOR_INPUT_ON          1
#define HOS_NODEMSG_INDICATOR_OUTPUT_ON         2

// Low level i/o function definitions
#define HOS_NODEMSG_WRITE_BYTE(b)   
//serialTransmit(b)
#define HOS_NODEMSG_READ_BYTE()     
//uart_getc()




typedef struct _hos_nodemsg_packet hos_nodemsg_packet;
typedef struct _hos_nodemsg_stack hos_nodemsg_stack;


struct _hos_nodemsg_packet
{
    uint8_t     header;              // Should be 0xFE
	uint16_t    src_address;         // Source address Should be 16 bit Physical address
	uint16_t    dest_address;        // Destination address Should be 16 bit Physical address
	uint8_t     packet_sequence_num; // Packet sequence number
	uint8_t     ttl;                 // Packet time to live in seconds (default is 3 sec)
	uint16_t    checksum;            // Packet checksum
	uint8_t     method;              // Method (request/response)
	uint8_t     command;             // Command
	uint8_t     param_count;         // param count	
	uint8_t     data[];              // Data buffer
} __attribute__ ((__packed__));

struct _hos_nodemsg_stack
{
    hos_nodemsg_packet *input;
    hos_nodemsg_packet *output;   
    int                 offset; 
    uint8_t             param_offset;
};



int32_t hos_nodemsg_packet_receive(uint8_t *data, uint8_t len);
int hos_nodemsg_packet_check(hos_nodemsg_packet *packet, uint16_t len);
int hos_nodemsg_packet_validate(hos_nodemsg_packet *packet, uint16_t len);
uint16_t hos_nodemsg_calc_checksum(hos_nodemsg_packet *packet, uint16_t len);

uint8_t hos_nodemsg_get_param_string(hos_nodemsg_packet *packet, uint8_t index, char **val, uint8_t *len);
uint8_t hos_nodemsg_get_param_int(hos_nodemsg_packet *packet, uint8_t index, int *val, uint8_t *len);
uint16_t hos_nodemsg_add_next_param(uint16_t handler, hos_nodemsg_packet *packet, uint8_t type,  void *value, uint8_t size);
uint16_t hos_nodemsg_add_first_param(hos_nodemsg_packet *packet, uint8_t type, void *value, uint8_t size);

void hos_nodemsg_fill_defaults(hos_nodemsg_packet *packet, uint16_t dest_address);
void hos_nodemsg_create_request(hos_nodemsg_packet *packet, uint16_t des_address, uint8_t command);



#endif /* _HOS_NODEMSG_H */
