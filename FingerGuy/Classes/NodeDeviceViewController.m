//
//  NodeDeviceViewController.m
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeDeviceViewController.h"
#import "AppDelegate.h"

@interface NodeDeviceViewController ()

@end

@implementation NodeDeviceViewController
@synthesize firmwareCell;
@synthesize firmwarereleaseDateCell;
@synthesize timeCell;
@synthesize modelNameCell;
@synthesize deviceAddressCell;
@synthesize rebootCell;
@synthesize firmwareUpdateCell;
@synthesize beepCell;
@synthesize firmwareVersion;
@synthesize firmwareReleaseDate;
@synthesize timeStamp;
@synthesize modelName;
@synthesize deviceAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSBundle mainBundle] loadNibNamed:@"DeviceDetails" owner:self options:nil];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
 
    
    NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
    [dateFormatterForTime setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatterForTime setTimeStyle:NSDateFormatterShortStyle];
    
    
    firmwareCell.detailTextLabel.text = firmwareVersion;
    firmwarereleaseDateCell.detailTextLabel.text = [dateFormatter stringFromDate:firmwareReleaseDate];
    timeCell.detailTextLabel.text = [dateFormatterForTime stringFromDate:timeStamp];
    modelNameCell.detailTextLabel.text = modelName;
    deviceAddressCell.detailTextLabel.text = deviceAddress;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 5;
    }
    
    return 3;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Details";
    }
    
    return @"Additions";
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row == 0) {
        NSLog(@"Reboot device");
        
        PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
        [nodeNetConnector setDelegate:self];
        [nodeNetConnector requestReboot:[deviceAddress intValue]];
    }

    if(indexPath.section == 1 && indexPath.row == 1) {
        NSLog(@"Beep device");
        
        PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
        [nodeNetConnector setDelegate:self];
        [nodeNetConnector requestBeep:[deviceAddress intValue]];
    }
    
    if(indexPath.section == 1 && indexPath.row == 2) {
        NSLog(@"Firmware update");
        
        PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
        [nodeNetConnector setDelegate:self];
        [nodeNetConnector requestFlash:[deviceAddress intValue]];
    }

}



- (void)processDidFinishCommandFlash:(PTNodeNetConnector *)nodeNetConnector
{
    [AppDelegate showHudMessage:self.view message:@"Firmware update preparing."];
}


- (void)processDidFinishCommandBeep:(PTNodeNetConnector *)nodeNetConnector
{
    [AppDelegate showHudMessage:self.view message:@"Beep..."];
}


- (void)processDidFinishCommandRestart:(PTNodeNetConnector *)nodeNetConnector
{
    [AppDelegate showHudMessage:self.view message:@"Restarting..."];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            return firmwareCell;
        }

        if(indexPath.row == 1) {
            return firmwarereleaseDateCell;
        }

        if(indexPath.row == 2) {
            return timeCell;
        }
        
        if(indexPath.row == 3) {
            return modelNameCell;
        }

        if(indexPath.row == 4) {
            return deviceAddressCell;
        }
    }
    if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            return rebootCell;
        }
        
        if(indexPath.row == 1) {
            return beepCell;
        }
        if(indexPath.row == 2) {
            return firmwareUpdateCell;
        }
    }
    
    return rebootCell;
}



@end
