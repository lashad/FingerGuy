/*
 *	PTNodeNetConnector.m
 *
 *	Copyright (c) 2012 Picktek LLC
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

#import "PTNodeNetConnector.h"


@interface PTNodeNetConnector ()

@end

@implementation PTNodeNetConnector
@synthesize udpSocket;
@synthesize delegate;

+ (id)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        
        id instance = [[self alloc] init];
        
        AsyncUdpSocket *udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:instance];
        
        NSError *error = nil;
        
        if (![udpSocket bindToPort:0 error:&error]) {
            NSLog(@"Error AsyncUdpSocket binding: %@", error);
        } 

        if (![udpSocket enableBroadcast:YES error:&error]) {
            NSLog(@"Error AsyncUdpSocket enable broadcast messages: %@", error);
        }
        
        [udpSocket receiveWithTimeout:-1 tag:0];
        
//        [instance setNodeStack:hos_nodemsg_init()];
        [instance setUdpSocket:udpSocket];
        
        return instance;
    });
}

- (BOOL)requestCall:(NSUInteger)toAddress
{
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_INFO);
    
    int value = HOS_NODEMSG_COMMAND_INFO_MODULE_DESC;
    uint16_t handler = hos_nodemsg_add_first_param(&packet, HOS_NODEMSG_TYPE_INT8, &value, 0);
    
    if(hos_nodemsg_packet_validate(&packet, handler) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet) + handler];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];   
    }
    
    return NO;
}

- (BOOL)requestBeep:(NSUInteger)toAddress
{
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_INFO);
    
    int value = HOS_NODEMSG_COMMAND_INFO_MODULE_BEEP;
    uint16_t handler = hos_nodemsg_add_first_param(&packet, HOS_NODEMSG_TYPE_INT8, &value, 0);
    
    if(hos_nodemsg_packet_validate(&packet, handler) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet) + handler];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;
}

- (BOOL)requestReboot:(NSUInteger)toAddress
{
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_INFO);
    
    int value = HOS_NODEMSG_COMMAND_INFO_MODULE_DEVICE_REBOOT;
    uint16_t handler = hos_nodemsg_add_first_param(&packet, HOS_NODEMSG_TYPE_INT8, &value, 0);
    
    if(hos_nodemsg_packet_validate(&packet, handler) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet) + handler];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;
}

- (BOOL)requestTemperature:(NSUInteger)toAddress
{
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_GET_TEMPERATURE);
    
    if(hos_nodemsg_packet_validate(&packet, 0) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet)];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;
}

- (BOOL)requestBacklightState:(NSUInteger)toAddress
{
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_GET_LCDBACKLIGHT);
    
    int value = 0xFF;
    uint16_t handler = hos_nodemsg_add_first_param(&packet, HOS_NODEMSG_TYPE_INT8, &value, 0);
    
    if(hos_nodemsg_packet_validate(&packet, handler) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet) + handler];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;
}

- (BOOL)requestBacklight:(NSUInteger)toAddress turn:(BOOL)turn
{
    
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_GET_LCDBACKLIGHT);
    
    int value = (int)turn;
    uint16_t handler = hos_nodemsg_add_first_param(&packet, HOS_NODEMSG_TYPE_INT8, &value, 0);
    
    if(hos_nodemsg_packet_validate(&packet, handler) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet) + handler];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;
}


- (BOOL)requestUnlockDoor:(NSUInteger)toAddress
{
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_UNLOCK_DOOR);
    
    int value = 1;
    uint16_t handler = hos_nodemsg_add_first_param(&packet, HOS_NODEMSG_TYPE_INT8, &value, 0);
    
    if(hos_nodemsg_packet_validate(&packet, handler) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet) + handler];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;

}

- (BOOL)requestSendMessage:(NSUInteger)toAddress string:(NSString*)string
{
    uint8_t buffer[256];
    hos_nodemsg_packet *packet = (hos_nodemsg_packet*)buffer;
    
    hos_nodemsg_create_request(packet, toAddress, HOS_NODEMSG_COMMAND_SET_MESSAGE);
    
//    scrollBuf = [text cStringUsingEncoding:NSUTF16StringEncoding];
    const char *cstring = [string cStringUsingEncoding:NSUTF16StringEncoding];
    
    uint16_t handler = hos_nodemsg_add_first_param(packet, HOS_NODEMSG_TYPE_BINARY, (char*)cstring, [string length] * 2);
    
    if(hos_nodemsg_packet_validate(packet, handler) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:packet length:sizeof(hos_nodemsg_packet) + handler];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;
}

- (BOOL)requestFlash:(NSUInteger)toAddress
{
    hos_nodemsg_packet packet;
    
    hos_nodemsg_create_request(&packet, toAddress, HOS_NODEMSG_COMMAND_FLASH);
    
    if(hos_nodemsg_packet_validate(&packet, 0) == HOS_NODEMSG_ERROR_NO) {
        NSData* data = [NSData dataWithBytes:&packet length:sizeof(hos_nodemsg_packet)];
        
        return [udpSocket sendData:data toHost:PTBODENET_UDP_BROADCAST port:PTBODENET_UDP_PORT withTimeout:-1 tag:1];
    }
    
    return NO;
    
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    if(hos_nodemsg_packet_receive((uint8_t*)[data bytes], [data length])) {
        
        hos_nodemsg_packet *packet = (hos_nodemsg_packet *)[data bytes];
        
        // ----------------- START BLOCK COMMAND INFO
        if(packet->command == HOS_NODEMSG_COMMAND_INFO) {
            
            
            
            NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:4];
            
            int ival = 0;
            char    *sval;
            char     tmp[20];
            uint8_t  len;
            
            hos_nodemsg_get_param_int(packet, 0, &ival, &len);
            
            if(ival == HOS_NODEMSG_COMMAND_INFO_MODULE_DESC) {
            
                if(hos_nodemsg_get_param_int(packet, 1, &ival, &len)) {
                   [attributes setValue:[NSString stringWithFormat:@"%d.%d", ival >> 4, ival & 0xF] forKey:PTNODEMSG_ATTRIBUTE_FIRMWAREVERSION];
                } 
                
                if(hos_nodemsg_get_param_int(packet, 2, &ival, &len)) {
                    NSDateComponents *components = [[NSDateComponents alloc] init];
                    NSLog(@"%d", (ival >> 11) & 0x1F);
                    [components setDay:(ival >> 11) & 0x1F];
                    [components setMonth:(ival >> 7) & 0xF];
                    [components setYear:(ival & 0xF) + 2000];
                    [components setHour:14];
                    [components setMinute:0];
                    [components setSecond:0];
                    NSCalendar *gregorian = [[NSCalendar alloc]
                                             initWithCalendarIdentifier:NSGregorianCalendar];
                    [attributes setValue:[gregorian dateFromComponents:components] forKey:PTNODEMSG_ATTRIBUTE_RELEASEDATE];
                }

                if(hos_nodemsg_get_param_int(packet, 3, &ival, &len)) {
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ival];
                    
                    [attributes setValue:date forKey:PTNODEMSG_ATTRIBUTE_TIME];
                }
                
                if(hos_nodemsg_get_param_string(packet, 4, &sval, &len)) {
                    memcpy(tmp, sval, len);
                    tmp[len] = 0;
                    [attributes setValue:[NSString stringWithFormat:@"%s", tmp]  forKey:PTNODEMSG_ATTRIBUTE_MODELNAME];
                }
                
                uint16_t deviceid;
                if(hos_nodemsg_get_param_int(packet, 5, (int*)&deviceid, &len)) {
                    [attributes setValue:[NSString stringWithFormat:@"%d", deviceid]  forKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS];
                    [attributes setValue:host  forKey:PTNODEMSG_ATTRIBUTE_DEVICEIP];
                    
                }
                
                if ([self.delegate respondsToSelector:@selector(processDidFinishCommandInfo:attributes:)]) {
                    [self.delegate processDidFinishCommandInfo:self attributes:attributes];
                }
                
            } else if(ival == HOS_NODEMSG_COMMAND_INFO_MODULE_BEEP) {
                if ([self.delegate respondsToSelector:@selector(processDidFinishCommandBeep:)]) {
                    [self.delegate processDidFinishCommandBeep:self];
                }                
            } else if(ival == HOS_NODEMSG_COMMAND_INFO_MODULE_DEVICE_REBOOT) {
                if ([self.delegate respondsToSelector:@selector(processDidFinishCommandRestart:)]) {
                    [self.delegate processDidFinishCommandRestart:self];
                }
            }
        }
        // ----------------- END BLOCK COMMAND INFO
       
        
        if(packet->command == HOS_NODEMSG_COMMAND_GET_TEMPERATURE) {
            int temperature = 0;
            uint8_t len = 0;
            hos_nodemsg_get_param_int(packet, 0, &temperature, &len);
            
            if ([self.delegate respondsToSelector:@selector(processDidFinishCommandTemperature:temperature:)]) {
                [self.delegate processDidFinishCommandTemperature:self temperature:temperature];
            }
        }

        if(packet->command == HOS_NODEMSG_COMMAND_GET_LCDBACKLIGHT) {
            int state = NO;
            uint8_t len = 0;
            hos_nodemsg_get_param_int(packet, 0, &state, &len);
            
            if ([self.delegate respondsToSelector:@selector(processDidFinishCommandLcdBacklight:state:)]) {
                [self.delegate processDidFinishCommandLcdBacklight:self state:(BOOL)state];
            }
        }

        if(packet->command == HOS_NODEMSG_COMMAND_FLASH) {
            if ([self.delegate respondsToSelector:@selector(processDidFinishCommandFlash:)]) {
                [self.delegate processDidFinishCommandFlash:self];
            }
        }
        
        if(packet->command == HOS_NODEMSG_COMMAND_UNLOCK_DOOR) {
            if ([self.delegate respondsToSelector:@selector(processDidFinishCommandUnlockDoor:)]) {
                [self.delegate processDidFinishCommandUnlockDoor:self];
            }
        }

        if(packet->command == HOS_NODEMSG_COMMAND_SET_MESSAGE) {
            if ([self.delegate respondsToSelector:@selector(processDidFinishCommandMessage:)]) {
                [self.delegate processDidFinishCommandMessage:self];
            }
        }

    }
    
	[udpSocket receiveWithTimeout:-1 tag:0];
    
	return YES;
}




@end
