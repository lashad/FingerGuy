//
//  FlipsideViewController.h
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTNodeNetConnector.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, PTNodeNetConnectorDelegate>
{
    IBOutlet UITableView             *tableView;
    IBOutlet UITableViewCell         *nodeNetCell;
    NSTimer                          *repeatingTimer;
    
    NSMutableArray                   *devices;
}

@property (weak, nonatomic) IBOutlet id <FlipsideViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSTimer *repeatingTimer;
@property (retain, nonatomic) NSMutableArray *devices;
@property (nonatomic, retain) IBOutlet UITableViewCell *nodeNetCell;


- (IBAction)done:(id)sender;

@end
