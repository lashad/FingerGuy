//
//  PTThermometerView.h
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPTThermometerViewMain             1
#define kPTThermometerViewHead             2
#define kPTThermometerViewBar              3



#define kPTThermometerViewNoTemperature         -2000

@interface PTThermometerView : UIView


@property (strong, nonatomic) UILabel *temperatureLabel;
@property (strong, nonatomic) UILabel *temperatureMaxLabel;
@property (strong, nonatomic) UILabel *temperatureMinLabel;
@property (strong, nonatomic) UIImage *barImage;
@property (strong, nonatomic) UIImage *headImage;
@property (strong, nonatomic) UIImage *thermometerImage;
@property (assign, nonatomic) int temperature;
@property (assign, nonatomic) int temperatureMax;
@property (assign, nonatomic) int temperatureMin;
@end
