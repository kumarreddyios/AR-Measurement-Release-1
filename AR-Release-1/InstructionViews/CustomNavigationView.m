//
//  CustomNavigationView.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/28/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "CustomNavigationView.h"
#import <UIKit/UIKit.h>

@implementation CustomNavigationView

-(void)initwithRootView:(UIView*)view{
    self.viewStack = [[NSMutableArray alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.mainView addSubview:view];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mainView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
     NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.mainView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.mainView addConstraint:topConstraint];
    [self.mainView addConstraint:bottomConstraint];
    [self.mainView addConstraint:leadConstraint];
    [self.mainView addConstraint:trailConstraint];
    [self.mainView bringSubviewToFront:view];
}

-(void)pushView:(UIView *)view animated:(BOOL)animation{

}

-(UIView*)popView:(BOOL)animation{
    return [[UIView alloc] init];
}

@end
