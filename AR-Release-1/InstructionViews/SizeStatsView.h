//
//  SizeStatsView.h
//  AR-Release-1
//
//  Created by Mohonish Chakraborty on 12/10/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipleSizesView.h"

enum SizeStatState {
    SingleSize,
    MultipleSize,
    NoSize
};

@interface SizeStatsView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *topArrowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *botArrowImageView;

@property (nonatomic, weak) IBOutlet UIView *containerViewTypeSingle;
@property (nonatomic, weak) IBOutlet MultipleSizesView *containerViewTypeMultiple;

@property (nonatomic, weak) IBOutlet UILabel *sizeLabel1;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel2;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel3;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabelCM;

@property enum SizeStatState currentState;
@property enum Gender currentGender;

-(void)loadSizeChart;
-(void)setActiveState:(enum SizeStatState)state;
-(void)updateSizesWithDistance:(CGFloat)distance;
-(BOOL)isExpandable;
-(CGFloat)getToggleAnimationHeight;

@end
