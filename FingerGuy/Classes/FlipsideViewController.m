//
//  FlipsideViewController.m
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "NodeDeviceViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

@synthesize delegate = _delegate;
@synthesize tableView;
@synthesize nodeNetCell;
@synthesize repeatingTimer;
@synthesize devices = _devices;

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                      target:self selector:@selector(timerFireMethod:)
                                                    userInfo:nil repeats:YES];
    self.repeatingTimer = timer;
    
    self.devices = [NSMutableArray arrayWithCapacity:10];
    
    [self timerFireMethod:self.repeatingTimer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Unschedule timer
    [repeatingTimer invalidate];
    self.repeatingTimer = nil;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    BOOL reload = NO;
    
    /* Remove old devices from list */
    for(NSDictionary *dic in self.devices) {
       
        if([dic objectForKey:@"ShouldRemove"] != nil) {
            [self.devices removeObject:dic];
            reload = YES;
        }
    }
    
    if(reload) {
        [self.tableView reloadData];
    }

    for(NSDictionary *dic in self.devices) {
        /* Mark as _> should we delete ? */
        [dic setValue:@"NextTime" forKey:@"ShouldRemove"];
    }
    
    PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
    [nodeNetConnector setDelegate:self];
    [nodeNetConnector requestCall:HOS_NODEMSG_DEVICE_ADDRESS_BROADCAST];
}

- (void)processDidFinishCommandInfo:(PTNodeNetConnector *)nodeNetConnector 
                         attributes:(NSDictionary*)attributes
{
    NSLog(@"Dump dictionary %@\n", attributes);
    
    BOOL find = FALSE;
    for(NSMutableDictionary *dic in self.devices) {
        
        if([[dic objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS] 
            isEqualToString:[attributes objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS]]) {
            find = TRUE;
            
            if([dic objectForKey:@"ShouldRemove"] != nil) {
                /* Restore */
                [dic removeObjectForKey:@"ShouldRemove"]; 

            }
        } 
    }
    
    if(!find) {
        if([attributes count] > 0) {
            [self.devices addObject:attributes];
            [self.tableView reloadData];
        }
    }
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.devices count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([self.devices count] > 0) {
        return @"Choose device";
    }
    
    return @"There is no device";    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyNodeNetCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        
            [[NSBundle mainBundle] loadNibNamed:@"NodeNetCell" owner:self options:nil];
            cell = nodeNetCell;
            self.nodeNetCell = nil;

        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }

    if([self.devices count] > 0 ) {
        NSDictionary *attribute = [self.devices objectAtIndex:indexPath.row];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        UILabel *label;
        label = (UILabel *)[cell viewWithTag:10];
        label.text = [attribute objectForKey:PTNODEMSG_ATTRIBUTE_MODELNAME];
        
        label = (UILabel *)[cell viewWithTag:20];
        label.text = [NSString stringWithFormat:@"%@ (%@)", [attribute objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS],
                      [attribute objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEIP]];
        
        
        UIImageView *checkView = (UIImageView *)[cell viewWithTag:30];
        
        if([[defaults objectForKey:@"DeviceAddress"] isEqualToString:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS]]) {
            checkView.hidden = NO;
        } else {
            checkView.hidden = YES;
        }
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showNodeNet"]) {
       // [[segue destinationViewController] setDelegate:self];
       NodeDeviceViewController *deviceViewController = (NodeDeviceViewController*)[segue destinationViewController];
        
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        NSDictionary *attribute = [self.devices objectAtIndex:indexPath.row];
        
        
        [deviceViewController setTitle:[NSString stringWithFormat:@"Device %@", [attribute objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS]]];
        
        [deviceViewController setFirmwareVersion:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_FIRMWAREVERSION]];
        [deviceViewController setFirmwareReleaseDate:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_RELEASEDATE]];
        [deviceViewController setTimeStamp:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_TIME]];
        [deviceViewController setModelName:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_MODELNAME]];
        [deviceViewController setDeviceAddress:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS]];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.devices count] > 0 ) {
        NSDictionary *attribute = [self.devices objectAtIndex:indexPath.row];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        if(![[defaults objectForKey:@"DeviceAddress"] isEqualToString:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS]]) {
            [defaults setValue:[attribute objectForKey:PTNODEMSG_ATTRIBUTE_DEVICEADDRESS] forKey:@"DeviceAddress"];
        } else {
            [defaults removeObjectForKey:@"DeviceAddress"];
        }
        [defaults synchronize];
        
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
        
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showNodeNet" sender:indexPath];
}


@end
