//
//  MultipleSizesView.h
//  AR-Release-1
//
//  Created by Mohonish Chakraborty on 12/10/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SizeChart.h"

@interface MultipleSizesView : UIView

@property (nonatomic, weak) IBOutlet UILabel *sizeLabel00;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel01;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel10;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel11;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel20;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel21;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabelCM;

@property (nonatomic, weak) IBOutlet UIImageView *topArrowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *botArrowImageView;

-(void)updateSizesWithDistance:(CGFloat)distance forGender:(enum Gender)gender andSizeChart:(SizeChart*)sizeChart;

@end
