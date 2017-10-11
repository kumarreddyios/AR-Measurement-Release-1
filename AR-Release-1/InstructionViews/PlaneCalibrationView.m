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
#define PITCH_EXTENT 60
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
    [_topIndicatorImageView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    [_rightIndicatorImageView setTransform:CGAffineTransformMakeRotation(-M_PI)];
    [_bottomIndicatorImageView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    _initialRoll = 0;
    _initialPitch = 0;
    _screenBounds = [[UIScreen mainScreen] bounds];
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
            [self.primaryInstructionLabel setText:[NSString stringWithFormat:@"Pitch:%fd\nRoll:%fd",_pitch,_roll]];
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
    }
}

-(void)calibrateLeftRoll {
    if(_initialRoll == 0) {
        _initialRoll = _roll;
    }
    double currentRollExtent = _roll - _initialRoll;
    double currentRollPercentage = currentRollExtent / ROLL_EXTENT;
    double requiredRollDistance = ((_screenBounds.size.width / 2) - 90);
    NSLog(@"%fd", currentRollPercentage);
    if (currentRollPercentage < 1 && currentRollPercentage > 0) {
        double currentRollDistance = requiredRollDistance*(1-currentRollPercentage);
        [_leftIndicatorConstraint setConstant:currentRollDistance];
    } else if (currentRollPercentage > 1) {
        [self moveForwardState];
    }
}

-(void)calibrateRightRoll {
    if(_initialRoll == 0) {
        _initialRoll = _roll;
    }
    double currentRollExtent = _initialRoll - _roll;
    double currentRollPercentage = currentRollExtent / ROLL_EXTENT;
    double requiredRollDistance = ((_screenBounds.size.width / 2) - 90);
    NSLog(@"%fd", currentRollPercentage);
    if (currentRollPercentage < 1 && currentRollPercentage > 0) {
        double currentRollDistance = requiredRollDistance*(1-currentRollPercentage);
        [_rightIndicatorConstraint setConstant:currentRollDistance];
    } else if (currentRollPercentage > 1) {
        [self moveForwardState];
    }
}

-(void)calibrateTopPitch {
    if(_initialPitch == 0) {
        _initialPitch = _pitch;
    }
    double currentPitchExtent = _initialPitch - _pitch;
    double currentPitchPercentage = currentPitchExtent / PITCH_EXTENT;
    double requiredPitchDistance = ((_screenBounds.size.height / 2) - 120);
    NSLog(@"%fd", currentPitchPercentage);
    if (currentPitchPercentage < 1 && currentPitchPercentage > 0) {
        double currentRollDistance = requiredPitchDistance*(1-requiredPitchDistance);
        [_topIndicatorConstraint setConstant:currentRollDistance];
    } else if (requiredPitchDistance > 1) {
        [self moveForwardState];
    }
}

-(void)calibrateBottomPitch {
    if(_initialPitch == 0) {
        _initialPitch = _pitch;
    }
    double currentPitchExtent = _initialPitch - _pitch;
    double currentPitchPercentage = currentPitchExtent / PITCH_EXTENT;
    double requiredPitchDistance = ((_screenBounds.size.height / 2) - 120);
    NSLog(@"%fd", currentPitchPercentage);
    if (currentPitchPercentage < 1 && currentPitchPercentage > 0) {
        double currentRollDistance = requiredPitchDistance*(1-requiredPitchDistance);
        [_bottomIndicatorConstraint setConstant:currentRollDistance];
    } else if (requiredPitchDistance > 1) {
        [self moveForwardState];
    }
}

-(void)moveForwardState {
    [_leftIndicatorImageView setHidden:true];
    [_rightIndicatorImageView setHidden:true];
    [_topIndicatorImageView setHidden:true];
    [_bottomIndicatorImageView setHidden:true];
    switch (_currentState) {
        case Inactive:
            _currentState = TiltLeft;
            [_leftIndicatorImageView setHidden:false];
            [_primaryImageView setImage:[UIImage imageNamed:@"phone_left"]];
            [self.primaryInstructionLabel setText:TILT_LEFT_TEXT];
            break;
        case TiltLeft:
            _currentState = TiltRight;
            [_rightIndicatorImageView setHidden:false];
            [_primaryImageView setImage:[UIImage imageNamed:@"phone_right"]];
            [_primaryInstructionLabel setText:TILT_RIGHT_TEXT];
            break;
        case TiltRight:
            _currentState = TiltTop;
            [_topIndicatorImageView setHidden:false];
            [_primaryImageView setImage:[UIImage imageNamed:@"phone_top"]];
            [_primaryInstructionLabel setText:TILT_TOP_TEXT];
            break;
        case TiltTop:
            _currentState = TiltBottom;
            [_bottomIndicatorImageView setHidden:false];
            [_primaryImageView setImage:[UIImage imageNamed:@"phone_bottom"]];
            [_primaryInstructionLabel setText:TILT_BOTTOM_TEXT];
            break;
        case TiltBottom:
            _currentState = Inactive;
            [_primaryInstructionLabel setText:@"Detecting Plane..."];
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
