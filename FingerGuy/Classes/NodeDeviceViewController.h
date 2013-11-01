//
//  NodeDeviceViewController.h
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PTNodeNetConnector.h"



@interface NodeDeviceViewController : UITableViewController <PTNodeNetConnectorDelegate>
{
    IBOutlet UITableViewCell         *firmwareCell;
    IBOutlet UITableViewCell         *firmwarereleaseDateCell;
    IBOutlet UITableViewCell         *timeCell;
    IBOutlet UITableViewCell         *modelNameCell;
    IBOutlet UITableViewCell         *deviceAddressCell;
    IBOutlet UITableViewCell         *rebootCell;
    IBOutlet UITableViewCell         *firmwareUpdateCell;
    IBOutlet UITableViewCell         *beepCell;
    
    NSString                         *firmwareVersion;
    NSDate                           *firmwareReleaseDate;
    NSString                         *modelName;    
    NSString                         *deviceAddress;
    

}

@property (nonatomic, retain) IBOutlet UITableViewCell *firmwareCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *firmwarereleaseDateCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *timeCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *modelNameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *deviceAddressCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *rebootCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *firmwareUpdateCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *beepCell;

@property (nonatomic, retain) IBOutlet NSString *firmwareVersion;
@property (nonatomic, retain) IBOutlet NSDate *firmwareReleaseDate;
@property (nonatomic, retain) IBOutlet NSDate *timeStamp;
@property (nonatomic, retain) IBOutlet NSString *modelName;
@property (nonatomic, retain) IBOutlet NSString *deviceAddress;

@end
