//
//  CustomNavigationView.h
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/28/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomNavigationView : NSObject

@property (nonatomic, weak) UIView *mainView;
@property (nonatomic, strong) NSMutableArray *viewStack;

-(void)initwithRootView:(UIView*)view;
-(void)pushView:(UIView *)view animated:(BOOL)animation;
-(UIView*)popView:(BOOL)animation;

@end
