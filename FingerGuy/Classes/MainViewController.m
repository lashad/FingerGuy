//
//  MainViewController.m
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "PTThermometerView.h"
#import "MBProgressHUD.h"


@interface MainViewController ()

@end

@implementation MainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if([UIScreen mainScreen].bounds.size.height == 568.0) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background-568.png"]];
        
        leaveMessageButton.frame =  CGRectMake([UIScreen mainScreen].bounds.size.width - 76,170,48,48);
        backlightButton.frame =  CGRectMake([UIScreen mainScreen].bounds.size.width - 146,168,48,48);
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
        
        leaveMessageButton.frame =  CGRectMake([UIScreen mainScreen].bounds.size.width - 90,130,48,48);
        backlightButton.frame =  CGRectMake([UIScreen mainScreen].bounds.size.width - 160,128,48,48);
    }
    
    // NSLog(@"Aba %@", self.view);
    
    PTThermometerView *thermometerView = [[PTThermometerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 120, (self.view.frame.size.height / 2) - 50, 120, 100)];
    
    thermometerView.thermometerImage = [UIImage imageNamed:@"Thermometer.png"];
    thermometerView.barImage = [UIImage imageNamed:@"Thermometer_Bar.png"];
    thermometerView.headImage = [UIImage imageNamed:@"Thermometer_Head.png"];
    thermometerView.temperature = 0;
    thermometerView.temperatureMax = 0;
    thermometerView.temperatureMin = 0;
    thermometerView.tag = 100;
    [self.view addSubview:thermometerView];
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceAddress = [defaults objectForKey:@"DeviceAddress"];
    if(deviceAddress == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"There is no device"
                              message: @"Please click on 'i' button to select device !"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self selector:@selector(timerFireMethod:)
                                   userInfo:nil repeats:YES];
    [self timerFireMethod:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
    [nodeNetConnector setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //    } else {
    //        return YES;
    //    }
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *deviceAddress = [defaults objectForKey:@"DeviceAddress"];
    if(deviceAddress != nil) {
        [nodeNetConnector requestTemperature:[deviceAddress intValue]];
    }
}



#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [(FlipsideViewController*)[[segue destinationViewController] topViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}


-(IBAction) send:(id)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceAddress = [defaults objectForKey:@"DeviceAddress"];
    
    if(deviceAddress != nil) {
        PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
        [nodeNetConnector setDelegate:self];
        [nodeNetConnector requestUnlockDoor:[deviceAddress intValue]];
    }
}

-(IBAction) leaveMessage:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Leave а message" message:@"Enter ASCII text max 40 character" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Leave а message";
    alertTextField.delegate = self;
    [alert show];
}

-(IBAction) backLight:(id)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceAddress = [defaults objectForKey:@"DeviceAddress"];
    
    if(deviceAddress != nil) {
        PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
        [nodeNetConnector setDelegate:self];
        [nodeNetConnector requestBacklight:[deviceAddress intValue] turn:!backlightButton.selected];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* messageString = alertTextField.text;
    
    if ([alertTextField.text length] <= 0 || buttonIndex == 0){
        return;
    }
    if (buttonIndex == 1 && [alertTextField.text length] > MAX_MESSAGE_LENGTH) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"max 40 character" message:nil
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else if (buttonIndex == 1) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *deviceAddress = [defaults objectForKey:@"DeviceAddress"];
        PTNodeNetConnector *nodeNetConnector = [PTNodeNetConnector sharedInstance];
        [nodeNetConnector setDelegate:self];
        [nodeNetConnector requestSendMessage:[deviceAddress intValue] string:messageString];
        
        NSLog(@"Message was sent '%@'", messageString);

    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    NSCharacterSet* tSet = [NSCharacterSet characterSetWithCharactersInString:
                            @"abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ><?.,\"\\/][{}=+-_)(*&^%$#@!':; "];
    NSCharacterSet* invSet = [tSet invertedSet];

    
    
    if ([string rangeOfCharacterFromSet:invSet].location != NSNotFound)
        return NO;
    
    
    return (newLength > MAX_MESSAGE_LENGTH) ? NO : YES;
}

#pragma mark - Node network delegate

- (void)processDidFinishCommandTemperature:(PTNodeNetConnector *)nodeNetConnector
                               temperature:(NSInteger)temperature;
{
    //NSLog(@"Temperature is %d\n", temperature);
    
    PTThermometerView *thermometerView = (PTThermometerView*)[self.view viewWithTag:100];
    
    if(thermometerView.temperature != temperature) {
        thermometerView.temperature = temperature;
    }
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *deviceAddress = [defaults objectForKey:@"DeviceAddress"];
    if(deviceAddress != nil) {
        [nodeNetConnector requestBacklightState:[deviceAddress intValue]];
    }
}

- (void)processDidFinishCommandUnlockDoor:(PTNodeNetConnector *)nodeNetConnector
{
    NSLog(@"Door unlocked successfully.");
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Door unlocked successfully.";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)processDidFinishCommandMessage:(PTNodeNetConnector *)nodeNetConnector
{
    NSLog(@"Your message was sent successfully.");

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Your message was sent.";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)processDidFinishCommandLcdBacklight:(PTNodeNetConnector *)nodeNetConnector state:(BOOL)state
{
    NSLog(@"Backlight status set.");

    if(state) {
        [backlightButton setSelected:YES];
    } else {
        [backlightButton setSelected:NO];
    }
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeCustomView;
//    hud.labelText = [NSString stringWithFormat:@"Backlight was %@", (state == NO) ? @"Off": @"On" ];
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.1 * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    });
    
    
}
@end
