/*
 *	hos_nodemsg.c
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

#include "hos_nodemsg.h"



/**
 * Calculate checksum by given packet.
 *
 * How to calculate checksum:
 * Checksum is the summer of all the bytes quantity from the packet method to the entire data,
 * including packet method.
 *
 * @param network layer packet
 * @return checksum of data
 */
uint16_t  hos_nodemsg_calc_checksum(hos_nodemsg_packet *packet, uint16_t len)
{
    uint16_t checksum = packet->method;
    
    checksum += packet->command;
    checksum += packet->param_count;
    
    for(int i = 0; i < len; i++) {
        checksum += packet->data[i];
    }
    
    return checksum;
}


/**
 * Get string parameter from param stack.
 *
 * Plase note: val variable is only pointer to the string parameter in input packet,
 * you MUST copy this value to the local buffer to avoid packet CORRUPTION.
 *
 * @param node message packet.
 * @param index parameter index.
 * @param val value to be placed.
 * @param len value length.
 * @return 0 if success otherwise -1
 */
uint8_t hos_nodemsg_get_param_string(hos_nodemsg_packet *packet, uint8_t index, char **val, uint8_t *len)
{
    int offset = 0;
    
    unsigned char *param = packet->data;
    uint8_t count = packet->param_count;
    
    for(int i = 0; i < count; i++) {
        
        if(param[offset] == HOS_NODEMSG_TYPE_INT8) {
            offset += 1;
            *len = 1;
        }
        
        if(param[offset] == HOS_NODEMSG_TYPE_INT16) {
            offset += 1;
            *len = 2;
        }
        
        if(param[offset] == HOS_NODEMSG_TYPE_INT32) {
            offset += 1;
            *len = 4;
        }
        
        if(param[offset] == HOS_NODEMSG_TYPE_STRING) {
            offset += 1;
            *len = param[offset];
            offset += 1;
            *val = (char*)(param + offset);
        }
        
        offset += *len;
        
        if(index == i) {
            return TRUE;
        }
    }
    
    return FALSE;
}


/**
 * Get Integer parameter from param stack
 *
 *
 * @param node message packet.
 * @param index parameter index.
 * @param val value to be placed.
 * @param len value length.
 * @return 0 if success otherwise -1
 *
 */
uint8_t hos_nodemsg_get_param_int(hos_nodemsg_packet *packet, uint8_t index, int *val, uint8_t *len)
{
    int offset = 0;
    
    unsigned char *param = packet->data;
    uint8_t count = packet->param_count;
    
    if(count > 10) return FALSE;
    
    for(int i = 0; i < count; i++) {
        
        if(param[offset] == HOS_NODEMSG_TYPE_INT8) {
            offset += 1;
            *val = param[offset];
            *len = 1;
        }
        
        if(param[offset] == HOS_NODEMSG_TYPE_INT16) {
            offset += 1;
            //*val = param[offset];
            memcpy(val, param + offset, sizeof(int16_t));
            *len = 2;
        }
        
        if(param[offset] == HOS_NODEMSG_TYPE_INT32) {
            offset += 1;
            //*val = param[offset];
            memcpy(val, param + offset, sizeof(int32_t));
            *len = 4;
        }
        
        if(param[offset] == HOS_NODEMSG_TYPE_STRING) {
            offset += 1;
            *len = param[offset];
            offset += 1;
        }
        
        offset += *len;
        
        if(index == i) {
            return TRUE;
        }
    }
    
    return FALSE;
}


/**
 * Add next param to the parameter stream.
 *
 * @param data offset handler (returned by hos_nodemsg_add_first_param).
 * @param packet packet pointer to which packet to be added.
 * @param type parameter type.
 * @param value parameter value.
 * @param value size - for BINARY type only.
 */
uint16_t hos_nodemsg_add_next_param(uint16_t handler, hos_nodemsg_packet *packet, uint8_t type,  void *value, uint8_t size)
{
    packet->param_count++;
    packet->data[handler++] = type;
    
    if(type == HOS_NODEMSG_TYPE_INT8) {
        packet->data[handler++] = *((int8_t*)value);
    }
    
    if(type == HOS_NODEMSG_TYPE_INT16) {
        memcpy(packet->data + handler, (int16_t*)value, sizeof(int16_t));
        handler += sizeof(int16_t);
    }
    
    if(type == HOS_NODEMSG_TYPE_INT32) {
        memcpy(packet->data + handler, (int32_t*)value, sizeof(int32_t));
        handler += sizeof(int32_t);
    }
    
    if(type == HOS_NODEMSG_TYPE_STRING) {
        packet->data[handler++] = strlen((const char*)value) + 1;
        memcpy(packet->data + handler, value, packet->data[handler - 1]);
        handler += packet->data[handler- 1];
    }
    
    if(type == HOS_NODEMSG_TYPE_BINARY) {
        packet->data[handler++] = size;
        memcpy(packet->data + handler, value, packet->data[handler - 1]);
        handler += packet->data[handler - 1];
    }
    
    return handler;
}

    
/**
 * Add first value to the parameter stream.
 *
 * @param stack node stack pointer.
 * @param packet packet pointer to which packet to be added.
 * @param type parameter type.
 * @param value parameter value.
 * @param value size - for BINARY type only.
 * @return first param offset handler
 */
uint16_t hos_nodemsg_add_first_param(hos_nodemsg_packet *packet, uint8_t type, void *value, uint8_t size)
{
    uint16_t handler = 0;
    return hos_nodemsg_add_next_param(handler, packet, type, value, size);
}



/**
 * Fill default packet values
 *
 *
 * @param packet network paket to fill.
 */
void hos_nodemsg_fill_defaults(hos_nodemsg_packet *packet, uint16_t dest_address)
{
    packet->header = HOS_NODEMSG_HEADER;                                 // Should be 0xFE
    packet->dest_address = dest_address;
	packet->src_address = HOS_NODEMSG_DEVICE_ADDRESS;                    // Source address Should be 16 bit Physical address
	packet->ttl = 3;                                                     // Packet time to live in seconds (default is 3 sec)
	packet->method = HOS_NODEMSG_RESPONSE;                               // Method (request/response)
	packet->param_count = 0;                                             // Param count
}


/**
 * Create request packet by given command.
 *
 *
 * @param packet network paket to fill.
 * @param command command packet.
 */
void hos_nodemsg_create_request(hos_nodemsg_packet *packet, uint16_t des_address, uint8_t command)
{
    /* Fill default values */
    hos_nodemsg_fill_defaults(packet, des_address);
    
    packet->packet_sequence_num = 1;
	packet->method = HOS_NODEMSG_REQUEST;           // Method (request/response)
	packet->command = command;                      // Command
}


/**
 * Process incoming raw data from UART or other low level layer
 * and check if this is our packet
 *
 * @param network packet data
 * @return commmand code if sccessfuely received, otherwise -1.
 */
int32_t hos_nodemsg_packet_receive(uint8_t *data, uint8_t len)
{
    hos_nodemsg_packet *packet = (hos_nodemsg_packet *)data;
    
    if(packet == NULL) {
        return -1;
    }
    
    if( hos_nodemsg_packet_check(packet, len) == HOS_NODEMSG_ERROR_NO) {
        
        // Request packet ?
        if(packet->method == HOS_NODEMSG_REQUEST) {
            return packet->command;
        }
    }
    
    return -1;
}



/**
 * Check incoming packet 
 *
 * @param network layer packet
 * @return 0 if success otherwise error code
 */
int hos_nodemsg_packet_check(hos_nodemsg_packet *packet, uint16_t len)
{
    /* WTF */
    if(packet == NULL) {
        return HOS_NODEMSG_ERROR_INVALID_PACKET;
    }
    
    /* Valid header ? */
    if(packet->header != HOS_NODEMSG_HEADER) {
        return HOS_NODEMSG_ERROR_INVALID_HEADER;
    }
    
    /* Check if this is foriegn packet and not broadcast */
    if(packet->dest_address != HOS_NODEMSG_DEVICE_ADDRESS && 
       packet->dest_address != HOS_NODEMSG_DEVICE_ADDRESS_BROADCAST) {
        return HOS_NODEMSG_ERROR_FORIEGN_PACKET;
    }
     
    /* Check if this is our packet */
    if(packet->dest_address == HOS_NODEMSG_DEVICE_ADDRESS) {
        uint16_t checksum = hos_nodemsg_calc_checksum(packet, len - sizeof(hos_nodemsg_packet));
        
        if(packet->checksum != checksum) {
            
            return HOS_NODEMSG_ERROR_INVALID_CHECKSUM;
        }
    }
    
    return HOS_NODEMSG_ERROR_NO;
}


/**
 * Add checksum to the packet and validate.
 *
 * @param network layer packet
 * @return 0 if success otherwise error code
 */
int hos_nodemsg_packet_validate(hos_nodemsg_packet *packet, uint16_t len)
{
    /* WTF */
    if(packet == NULL) {
        return HOS_NODEMSG_ERROR_INVALID_PACKET;
    }
    
    /* Valid header ? */
    if(packet->header != HOS_NODEMSG_HEADER) {
        return HOS_NODEMSG_ERROR_INVALID_HEADER;
    }
     
    packet->checksum = hos_nodemsg_calc_checksum(packet, len);
    
    return HOS_NODEMSG_ERROR_NO;
}
