/*
 *	PTNodeNetConnector.h
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

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"

#include "hos_nodemsg.h"


#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \


/* Default UDP transport port */
#define PTBODENET_UDP_PORT                    1233

/* Default UDP transport Broadcast address */
//#define PTBODENET_UDP_BROADCAST               @"94.240.230.4"
#define PTBODENET_UDP_BROADCAST               @"192.168.1.255"
//#define PTBODENET_UDP_BROADCAST               @"172.16.236.255"
//#define PTBODENET_UDP_BROADCAST               @"10.0.1.255"
//#define PTBODENET_UDP_BROADCAST               @"192.168.1.109"



/* Attribue names for Command - INFO */
#define PTNODEMSG_ATTRIBUTE_FIRMWAREVERSION   @"FirmwareVersion"
#define PTNODEMSG_ATTRIBUTE_MODELNAME         @"ModelName"
#define PTNODEMSG_ATTRIBUTE_RELEASEDATE       @"ReleaseDate"
#define PTNODEMSG_ATTRIBUTE_TIME              @"Timestamp"
#define PTNODEMSG_ATTRIBUTE_DEVICEADDRESS     @"DeviceAddress"
#define PTNODEMSG_ATTRIBUTE_DEVICEIP          @"DeviceIP"


@protocol PTNodeNetConnectorDelegate;

@interface PTNodeNetConnector : NSObject 
{
     AsyncUdpSocket                  *udpSocket;
     id <PTNodeNetConnectorDelegate>  delegate;
}


@property (nonatomic, retain) AsyncUdpSocket      *udpSocket; 
@property (nonatomic, strong) id <PTNodeNetConnectorDelegate> delegate;


+ (id)sharedInstance;
- (BOOL)requestCall:(NSUInteger)toAddress;
- (BOOL)requestBeep:(NSUInteger)toAddress;
- (BOOL)requestReboot:(NSUInteger)toAddress;
- (BOOL)requestTemperature:(NSUInteger)toAddress;
- (BOOL)requestBacklightState:(NSUInteger)toAddress;
- (BOOL)requestBacklight:(NSUInteger)toAddress turn:(BOOL)turn;
- (BOOL)requestUnlockDoor:(NSUInteger)toAddress;

- (BOOL)requestSendMessage:(NSUInteger)toAddress string:(NSString*)string;
- (BOOL)requestFlash:(NSUInteger)toAddress;

@end



@protocol PTNodeNetConnectorDelegate <NSObject>
@optional

- (void)processDidFinishCommandInfo:(PTNodeNetConnector *)nodeNetConnector 
                         attributes:(NSDictionary*)attributes;

- (void)processDidFinishCommandTemperature:(PTNodeNetConnector *)nodeNetConnector
                               temperature:(NSInteger)temperature;
- (void)processDidFinishCommandLcdBacklight:(PTNodeNetConnector *)nodeNetConnector
                               state:(BOOL)state;
- (void)processDidFinishCommandUnlockDoor:(PTNodeNetConnector *)nodeNetConnector;
- (void)processDidFinishCommandMessage:(PTNodeNetConnector *)nodeNetConnector;
- (void)processDidFinishCommandFlash:(PTNodeNetConnector *)nodeNetConnector;

- (void)processDidFinishCommandRestart:(PTNodeNetConnector *)nodeNetConnector;

- (void)processDidFinishCommandBeep:(PTNodeNetConnector *)nodeNetConnector;


@end

