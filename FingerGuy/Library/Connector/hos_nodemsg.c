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

/* Shared node message stack */
hos_nodemsg_stack *nodemsg_stack = NULL;

/**
 * Initialize network layer
 * 
 * @return network layer stack
 */
hos_nodemsg_stack *hos_nodemsg_init() 
{
    hos_nodemsg_stack *stack = (hos_nodemsg_stack*)HOS_NODEMSG_MEM_ALLOC(sizeof(hos_nodemsg_stack));
    
    // We get out of memory :(
    if(stack == NULL) {
        return NULL;
    }
    
    stack->input = HOS_NODEMSG_MEM_ALLOC(sizeof(hos_nodemsg_packet));

    // We get out of memory :(
    if(stack->input == NULL) {
        hos_nodemsg_destroy(stack);
        return NULL;
    }

    stack->output = HOS_NODEMSG_MEM_ALLOC(sizeof(hos_nodemsg_packet));

    // We get out of memory :(
    if(stack->output == NULL) {
        hos_nodemsg_destroy(stack);
        return NULL;
    }
    
    memset(stack->input, 0xFF, sizeof(sizeof(hos_nodemsg_packet)));
    memset(stack->output, 0xFF, sizeof(sizeof(hos_nodemsg_packet)));
    
    return stack;
}

/* 
 * Get shared nodemsg stack.
 *
 * @return stack pointer success, or 0 otherwise.
 */
hos_nodemsg_stack *hos_nodemsg_sharedstack()
{
    if(!nodemsg_stack) {
        nodemsg_stack = hos_nodemsg_init();
    }
    
    return nodemsg_stack;
}


/**
 * Destroy network layer and free all resources 
 *
 * @param network layer stack 
 */
void hos_nodemsg_destroy(hos_nodemsg_stack *stack) 
{
    if(stack != NULL) {
    
        if(stack->input != NULL) {
            HOS_NODEMSG_MEM_FREE(stack->input);
            stack->input = 0;
        }

        if(stack->output != NULL) {
            HOS_NODEMSG_MEM_FREE(stack->output);
            stack->output = 0;
        }
        
        HOS_NODEMSG_MEM_FREE(stack);
        nodemsg_stack = NULL;
    }
}


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
uint16_t  hos_nodemsg_calc_checksum(hos_nodemsg_packet *packet) 
{
    uint16_t checksum = packet->method;

    checksum += packet->command;
    checksum += packet->param_count;
    
    for(int i = 0; i < sizeof(packet->data); i++) {
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
 * @param stack network stack.
 * @param index parameter index.
 * @param val value to be placed.  
 * @param len value length.  
 * @return 0 if success otherwise -1
 */
uint8_t hos_nodemsg_get_param_string(hos_nodemsg_stack *stack, uint8_t index, char **val, uint8_t *len)
{
    int offset = 0;

    unsigned char *param = stack->input->data;
    uint8_t count = stack->input->param_count;

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
 * @param stack network stack.
 * @param index parameter index.
 * @param val value to be placed.
 * @param len value length.  
 * @return 0 if success otherwise -1
 *
 */
uint8_t hos_nodemsg_get_param_int(hos_nodemsg_stack *stack, uint8_t index, int *val, uint8_t *len)
{
    int offset = 0;

    unsigned char *param = stack->input->data;
    uint8_t count = stack->input->param_count;

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
 * @param stack node stack pointer.
 * @param packet packet pointer to which packet to be added.
 * @param type parameter type.
 * @param value parameter value.
 * @param value size - for BINARY type only.
 */
void hos_nodemsg_add_next_param(hos_nodemsg_stack *stack, hos_nodemsg_packet *packet, uint8_t type, const void *value, uint8_t size)
{
    packet->param_count++;
    packet->data[stack->param_offset++] = type;
    
    if(type == HOS_NODEMSG_TYPE_INT8) {
        packet->data[stack->param_offset++] = *((int8_t*)value);
    }
    
    if(type == HOS_NODEMSG_TYPE_INT16) {
        memcpy(packet->data + stack->param_offset, (int16_t*)value, sizeof(int16_t));
        stack->param_offset += sizeof(int16_t);
    }
    
    if(type == HOS_NODEMSG_TYPE_INT32) {
        memcpy(packet->data + stack->param_offset, (int32_t*)value, sizeof(int32_t));
        stack->param_offset += sizeof(int32_t);
    }
    
    if(type == HOS_NODEMSG_TYPE_STRING) {
        packet->data[stack->param_offset++] = strlen((const char*)value);
        memcpy(packet->data + stack->param_offset, value, packet->data[stack->param_offset - 1]);
        stack->param_offset += packet->data[stack->param_offset - 1];
    }
    
    if(type == HOS_NODEMSG_TYPE_BINARY) {
        packet->data[stack->param_offset++] = size;
        memcpy(packet->data + stack->param_offset, value, packet->data[stack->param_offset - 1]);
        stack->param_offset += packet->data[stack->param_offset - 1];
    }
}

    
/**
 * Add first value to the parameter stream.
 *
 * @param stack node stack pointer.
 * @param packet packet pointer to which packet to be added.
 * @param type parameter type.
 * @param value parameter value.
 * @param value size - for BINARY type only.
 */
void hos_nodemsg_add_first_param(hos_nodemsg_stack *stack, hos_nodemsg_packet *packet, uint8_t type, void *value, uint8_t size)
{
    stack->param_offset = 0;
    packet->param_count = 0;
    
    memset(&stack->output->data, 0xFF, sizeof(stack->output->data));
    hos_nodemsg_add_next_param(stack, packet, type, value, size);
}


/**
 * Fill default packet values
 * 
 *
 * @param stack network stack.
 * @param packet network paket to fill.
 */
void hos_nodemsg_fill_defaults(hos_nodemsg_stack *stack, hos_nodemsg_packet *packet) 
{
    packet->header = HOS_NODEMSG_HEADER;                                 // Should be 0xFE
	packet->src_address = HOS_NODEMSG_DEVICE_ADDRESS;                    // Source address Should be 16 bit Physical address
	packet->dest_address = stack->input->src_address;                    // Destination address Should be 16 bit Physical address
	packet->packet_sequence_num = stack->input->packet_sequence_num + 1; // Packet sequence number
	packet->ttl = 3;                                                     // Packet time to live in seconds (default is 3 sec)
	packet->method = HOS_NODEMSG_RESPONSE;                               // Method (request/response)
	packet->command = stack->input->command;                             // Command
	packet->param_count = 0;                                             // Param count	
}


/**
 * Create request packet by given command.
 * 
 *
 * @param stack network stack.
 * @param packet network paket to fill.
 * @param command command packet. 
 */
void hos_nodemsg_create_request(hos_nodemsg_stack *stack, hos_nodemsg_packet *packet, uint16_t des_address, uint8_t command)
{
    /* Fill default values */
    hos_nodemsg_fill_defaults(stack, packet);
    
    stack->output->dest_address = des_address;             // Destination address Should be 16 bit Physical address
    stack->output->packet_sequence_num = 1;
	stack->output->method = HOS_NODEMSG_REQUEST;           // Method (request/response)
	stack->output->command = command;                      // Command
}

/**
 * Process incoming raw data from UART or other low level layer 
 * and check if this is our packet
 *
 * @param network layer stack 
 * @return commmand code if sccessfuely received, otherwise -1. 
 */
int32_t hos_nodemsg_packet_receive(hos_nodemsg_stack *stack, uint8_t *buffer, uint8_t size)
{   
    unsigned char *data = (unsigned char*)stack->input;
    hos_nodemsg_packet *packet = (hos_nodemsg_packet *)data;

    if(size == sizeof(hos_nodemsg_packet)) {
   
      memcpy(data, buffer, sizeof(hos_nodemsg_packet));

        if( hos_nodemsg_packet_check(packet) == HOS_NODEMSG_ERROR_NO) {
         
            // Request packet ?
            if(packet->method == HOS_NODEMSG_REQUEST) {
                 
                memset(stack->output, 0xFF, sizeof(hos_nodemsg_packet));

                return packet->command;
            }
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
int hos_nodemsg_packet_check(hos_nodemsg_packet *packet) 
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
        uint16_t checksum = hos_nodemsg_calc_checksum(packet);
        
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
int hos_nodemsg_packet_validate(hos_nodemsg_packet *packet) 
{
    /* WTF */
    if(packet == NULL) {
        return HOS_NODEMSG_ERROR_INVALID_PACKET;
    }
    
    /* Valid header ? */
    if(packet->header != HOS_NODEMSG_HEADER) {
        return HOS_NODEMSG_ERROR_INVALID_HEADER;
    }
     
    packet->checksum = hos_nodemsg_calc_checksum(packet);
    
    return HOS_NODEMSG_ERROR_NO;
}
