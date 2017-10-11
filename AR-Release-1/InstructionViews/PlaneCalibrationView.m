//
//  PlaneCalibrationView.m
//  AR-Release-1
//
//  Created by Mohonish Chakraborty on 11/10/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "PlaneCalibrationView.h"
@import CoreMotion;

#define ROLL_EXTENT 30
#define PITCH_EXTENT 30
#define TILT_LEFT_TEXT @"Tilt your phone clockwise till the arrow touches the left edge of the screen"
#define TILT_RIGHT_TEXT @"Tilt your phone anti-clockwise till the arrow touches the right edge of the screen"
#define TILT_TOP_TEXT @"Tilt your phone forward till the arrow touches the top of the screen"
#define TILT_BOTTOM_TEXT @"Tilt your phone backward till the arrow reaches the bottom of the screen"

@interface PlaneCalibrationView()

@property (nonatomic, strong) NSOperationQueue *defaultQueue;
@property (nonatomic, strong) CMMotionManager *motionManager;

@property enum PlaneCalibrationState currentState;

@property double initialRoll;
@property double initialPitch;

@property double roll;
@property double pitch;

@property CGRect screenBounds;

@end

@implementation PlaneCalibrationView

-(void)awakeFromNib{
    [super awakeFromNib];
    _currentState = Inactive;
    _initialRoll = 0;
    _initialPitch = 0;
    _screenBounds = [[UIScreen mainScreen] bounds];
    [self createGradient];
}

-(void)createGradient {
    UIColor *colorOne = [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:174.0/255.0 alpha:0.7];
    UIColor *colorTwo = [UIColor colorWithRed:147.0/255.0 green:61.0/255.0 blue:224.0/255.0 alpha:0.7];
    NSNumber *locationOne = [NSNumber numberWithFloat:0.3];
    NSNumber *locationTwo = [NSNumber numberWithFloat:0.7];
    NSArray *locationArray = @[locationOne, locationTwo];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    gradientLayer.frame = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
    gradientLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer.locations = locationArray;
    [self.backgroundView.layer insertSublayer:gradientLayer atIndex:0];
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.frame = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
    gradientLayer2.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer2.locations = locationArray;
    [self.endMessageView.layer insertSublayer:gradientLayer2 atIndex:0];
}

-(void)beginPlaneCalibration {
    _currentState = TiltLeft;
    _motionManager = [[CMMotionManager alloc] init];
    _defaultQueue = [[NSOperationQueue alloc] init];
    [_motionManager setDeviceMotionUpdateInterval:0.1];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:_defaultQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CMQuaternion quat = motion.attitude.quaternion;
            _pitch = [self radiansToDegrees:(atan2(2 * (quat.x * quat.w + quat.y * quat.z), 1 - 2 * quat.x * quat.x - 2 * quat.z * quat.z))];
            _roll = [self radiansToDegrees:(atan2(2 * (quat.y * quat.w - quat.x * quat.z), 1 - 2 * quat.y * quat.y - 2 * quat.z * quat.z))];
            [self updateStateUI];
        }];
    }];
}

-(void)updateStateUI {
    switch (_currentState) {
        case Inactive:
            break;
        case TiltLeft:
            [self calibrateLeftRoll];
            break;
        case TiltRight:
            [self calibrateRightRoll];
            break;
        case TiltTop:
            [self calibrateTopPitch];
            break;
        case TiltBottom:
            [self calibrateBottomPitch];
            break;
        case UpDownMessage:
            break;
    }
}

-(void)calibrateLeftRoll {
    if(_initialRoll == 0) {
        _initialRoll = _roll;
    }
    double currentRollExtent = _initialRoll - _roll;
    double currentRollPercentage = currentRollExtent / ROLL_EXTENT;
    double requiredRollDistance = (_mapImageView.bounds.size.width / 2) - (_indicatorImageView.bounds.size.width / 2);
    double currentRollDistance = requiredRollDistance*currentRollPercentage;
    if(currentRollPercentage > 0) {
        [_centerXConstraint setConstant:-currentRollDistance];
        if(currentRollPercentage > 0.95) {
            [self moveForwardState];
        }
    }
}

-(void)calibrateRightRoll {
    if(_initialRoll == 0) {
        _initialRoll = _roll;
    }
    double currentRollExtent = _initialRoll - _roll;
    double currentRollPercentage = currentRollExtent / ROLL_EXTENT;
    double requiredRollDistance = (_mapImageView.bounds.size.width / 2) - (_indicatorImageView.bounds.size.width / 2);
    double currentRollDistance = requiredRollDistance*currentRollPercentage;
    NSLog(@"\n%fd\n%fd", currentRollPercentage, currentRollDistance);
    if(currentRollPercentage < 1.05) {
        [_centerXConstraint setConstant:-currentRollDistance];
        if(currentRollPercentage < -1) {
            [_centerXConstraint setConstant:0];
            [self moveForwardState];
        }
    }
}

-(void)calibrateTopPitch {
    if(_initialPitch == 0) {
        _initialPitch = _pitch;
    }
    double currentPitchExtent = _initialPitch - _pitch;
    double currentPitchPercentage = currentPitchExtent / PITCH_EXTENT;
    double requiredPitchDistance = (_mapImageView.bounds.size.height / 2) - (_indicatorImageView.bounds.size.height / 2);
    double currentPitchDistance = requiredPitchDistance*currentPitchPercentage;
    NSLog(@"\n%fd\n%fd", currentPitchPercentage, currentPitchDistance);
    if(currentPitchPercentage > -1.05 && currentPitchPercentage < 1.05) {
        [_centerYConstrant setConstant:-currentPitchDistance];
        if(currentPitchPercentage > 0.95) {
            [self moveForwardState];
        }
    }
}

-(void)calibrateBottomPitch {
    if(_initialPitch == 0) {
        _initialPitch = _pitch;
    }
    double currentPitchExtent = _initialPitch - _pitch;
    double currentPitchPercentage = currentPitchExtent / PITCH_EXTENT;
    double requiredPitchDistance = (_mapImageView.bounds.size.height / 2) - (_indicatorImageView.bounds.size.height / 2);
    double currentPitchDistance = requiredPitchDistance*currentPitchPercentage;
    NSLog(@"\n%fd\n%fd", currentPitchPercentage, currentPitchDistance);
    if(currentPitchPercentage > -1.05 && currentPitchPercentage < 1.05) {
        [_centerYConstrant setConstant:-currentPitchDistance];
        if(currentPitchPercentage < -0.95) {
            [self moveForwardState];
        }
    }
}

-(void)moveForwardState {
    switch (_currentState) {
        case Inactive:
            _currentState = TiltLeft;
            [_mapImageView setImage:[UIImage imageNamed:@"1"]];
            break;
        case TiltLeft:
            _currentState = TiltRight;
            [_mapImageView setImage:[UIImage imageNamed:@"2"]];
            break;
        case TiltRight:
            _currentState = TiltTop;
            [_mapImageView setImage:[UIImage imageNamed:@"3"]];
            break;
        case TiltTop:
            _currentState = TiltBottom;
            [_mapImageView setImage:[UIImage imageNamed:@"4"]];
            break;
        case TiltBottom:
            _currentState = UpDownMessage;
            [self stopPlaneCalibration];
            [self.backgroundView setHidden:true];
            [self.endMessageView setHidden:false];
            break;
        case UpDownMessage:
            break;
    }
}

-(void)stopPlaneCalibration {
    _motionManager = nil;
    _defaultQueue = nil;
}

-(double)radiansToDegrees:(double)radians {
    return radians * (180.0 / M_PI);
}

@end
