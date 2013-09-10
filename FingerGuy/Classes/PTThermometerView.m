//
//  PTThermometerView.m
//  FingerGuy
//
//  Created by Lasha Dolidze on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTThermometerView.h"

@implementation PTThermometerView


@synthesize barImage = _barImage;
@synthesize headImage = _headImage;
@synthesize thermometerImage = _thermometerImage;
@synthesize temperature = _temperature;
@synthesize temperatureMax = _temperatureMax;
@synthesize temperatureMin = _temperatureMin;
@synthesize temperatureLabel = _temperatureLabel;
@synthesize temperatureMaxLabel = _temperatureMaxLabel;
@synthesize temperatureMinLabel = _temperatureMinLabel;

- (void)baseInit 
{
    _barImage = nil;
    _headImage = nil;
    _thermometerImage = nil;
    _temperature = kPTThermometerViewNoTemperature;

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tag = kPTThermometerViewMain;
    [self addSubview:imageView];
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tag = kPTThermometerViewHead;
    [self addSubview:imageView];
    
    for(int i = 0; i < 8; i++) {
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = kPTThermometerViewBar + i;
        [self addSubview:imageView];
    }
    
    _temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, self.frame.size.width, 30)];
    _temperatureLabel.backgroundColor = [UIColor clearColor];
    _temperatureLabel.textColor = [UIColor colorWithRed:255.0/255 green:205.0/255 blue:5.0/255 alpha:1];
    _temperatureLabel.font = [UIFont systemFontOfSize:30];
    _temperatureLabel.text = @"";
    [self addSubview:_temperatureLabel];

    _temperatureMaxLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 35, self.frame.size.width, 30)];
    _temperatureMaxLabel.backgroundColor = [UIColor clearColor];
    _temperatureMaxLabel.textColor = [UIColor colorWithRed:251.0/255 green:138.0/255 blue:111.0/255 alpha:1];
    _temperatureMaxLabel.font = [UIFont systemFontOfSize:18];
    _temperatureMaxLabel.text = @"";
    _temperatureMaxLabel.textAlignment = UITextAlignmentLeft;
    _temperatureMaxLabel.hidden = YES;
    [self addSubview:_temperatureMaxLabel];
    
    _temperatureMinLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 55, self.frame.size.width, 30)];
    _temperatureMinLabel.backgroundColor = [UIColor clearColor];
    _temperatureMinLabel.textColor = [UIColor colorWithRed:205.0/255 green:255.0/255 blue:5.0/255 alpha:1];
    _temperatureMinLabel.font = [UIFont systemFontOfSize:18];
    _temperatureMinLabel.text = @"";
    _temperatureMinLabel.textAlignment = UITextAlignmentLeft;
    _temperatureMinLabel.hidden = YES;
    
    [self addSubview:_temperatureMinLabel];
    

    
    //self.backgroundColor = [UIColor redColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

- (void)refresh 
{   
    int percent = ((_temperature / 10) * 14) / 100;
    int index = 0;
    int height = 0;
    
    if(percent <= 0) {
        index = 0;
    } else if(index > 7) {
        index = 7;
    } else {
        index = percent;
    }
    
    NSLog(@"%d\n", index);
    
    UIImageView *imageView = (UIImageView*)[self viewWithTag:kPTThermometerViewMain];
    CGRect imageFrame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
    imageView.frame = imageFrame;
    
    for(int i = 0; i < 8; i++) {
        imageView = (UIImageView*)[self viewWithTag:kPTThermometerViewBar + i];
        [imageView setHidden:YES];
    }
    
    for(int i = 0; i <= index; i++) {
        imageView = (UIImageView*)[self viewWithTag:kPTThermometerViewBar + i];
        height = imageView.image.size.height;
        imageFrame = CGRectMake(11, 2 + height + (height * 7) - (i * height), imageView.image.size.width, imageView.image.size.height);
        imageView.frame = imageFrame;
        [imageView setHidden:NO];
    }
    
    imageView = (UIImageView*)[self viewWithTag:kPTThermometerViewHead];
    imageFrame = CGRectMake(11, 4 + (height * 7) - (height * index), imageView.image.size.width, imageView.image.size.height);
    imageView.frame = imageFrame;

}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    [self refresh];
}

- (void) setBarImage:(UIImage *)barImage
{
    _barImage = barImage;
    
    for(int i = 0; i < 8; i++) {
        UIImageView *imageView = (UIImageView*)[self viewWithTag:kPTThermometerViewBar + i];
        imageView.image = _barImage;
    }
    
    [self refresh];
}

- (void) setHeadImage:(UIImage *)headImage
{
    UIImageView *imageView = (UIImageView*)[self viewWithTag:kPTThermometerViewHead];
    _headImage = headImage;
    imageView.image = _headImage;
    
    [self refresh];
}

- (void) setThermometerImage:(UIImage *)thermometerImage
{
    UIImageView *imageView = (UIImageView*)[self viewWithTag:kPTThermometerViewMain];
    _thermometerImage = thermometerImage;    
    imageView.image = _thermometerImage;
    
    [self refresh];
}

- (void) setTemperature:(int)temperature
{
    [_temperatureLabel setAlpha:0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _temperatureLabel.text = [NSString stringWithFormat:@"%d.%d° C", (temperature / 10), abs((temperature % 10))];
    _temperature = temperature;
    [_temperatureLabel setAlpha:1];
    [UIView commitAnimations];   
    
    [self refresh];
}

- (void) setTemperatureMin:(int)temperature
{
    [_temperatureMinLabel setAlpha:0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _temperatureMinLabel.text = [NSString stringWithFormat:@"%d.%d° C", (temperature / 10), abs((temperature % 10))];
    _temperatureMin = temperature;
    [_temperatureMinLabel setAlpha:1];
    [UIView commitAnimations];   
    
    [self refresh];
}

- (void) setTemperatureMax:(int)temperature
{
    [_temperatureMaxLabel setAlpha:0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _temperatureMaxLabel.text = [NSString stringWithFormat:@"%d.%d° C", (temperature / 10), abs((temperature % 10))];
    _temperatureMax = temperature;
    [_temperatureMaxLabel setAlpha:1];
    [UIView commitAnimations];   

    
    [self refresh];
}

@end
