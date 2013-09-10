//
//  MainViewController.h
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "PTNodeNetConnector.h"
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLRegion.h>

#define MAX_MESSAGE_LENGTH      40

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate, CLLocationManagerDelegate, PTNodeNetConnectorDelegate,UITextFieldDelegate>
{
    CLLocationManager *_locationManager;
    IBOutlet UIButton                *leaveMessageButton;
    IBOutlet UIButton                *backlightButton;

    UITextField                      *alertTextField;
}

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;


-(IBAction) send:(id)sender;
-(IBAction) leaveMessage:(id)sender;
-(IBAction) backLight:(id)sender;

@end
