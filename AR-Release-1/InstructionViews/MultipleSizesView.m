//
//  MultipleSizesView.m
//  AR-Release-1
//
//  Created by Mohonish Chakraborty on 12/10/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "MultipleSizesView.h"

@implementation MultipleSizesView

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)updateSizesWithDistance:(CGFloat)distance forGender:(enum Gender)gender andSizeChart:(SizeChart*)sizeChart {
    printf("\n MultipleSize CM = %fd", distance);
    NSString* formattedString = [NSString stringWithFormat:@"%.2f", distance];
    [self.sizeLabelCM setText:[NSString stringWithFormat:@"(%@ cm)",formattedString]];
    CGFloat cms = formattedString.floatValue;
    if(sizeChart != nil) {
        switch (gender) {
            case Men: {
                //EU Size
                [self.sizeLabel00 setText:@"-"];
                [self.sizeLabel01 setText:@"-"];
                NSArray *euSize = [sizeChart getEUSizeFromCM:cms];
                if (euSize != nil && euSize.count > 0) {
                    if (euSize.count > 1) { //More than one results in range. Change state.
                        [self.sizeLabel00 setText:euSize[0]?:@"-"];
                        [self.sizeLabel01 setText:euSize[1]?:@"-"];
                    }
                }
                //US Size
                [self.sizeLabel10 setText:@"-"];
                [self.sizeLabel11 setText:@"-"];
                NSArray *usSize = [sizeChart getUSSizeFromCM:cms];
                if (usSize != nil && usSize.count > 0) {
                    if (usSize.count > 1) { //More than one results in range. Change state.
                        [self.sizeLabel10 setText:usSize[0]?:@"-"];
                        [self.sizeLabel11 setText:usSize[1]?:@"-"];
                    }
                }
                //UK Size
                [self.sizeLabel20 setText:@"-"];
                [self.sizeLabel21 setText:@"-"];
                NSArray *ukSize = [sizeChart getUKSizeFromCM:cms];
                if (ukSize != nil && ukSize.count > 0) {
                    if (ukSize.count > 1) { //More than one results in range. Change state.
                        [self.sizeLabel20 setText:ukSize[0]?:@"-"];
                        [self.sizeLabel21 setText:ukSize[1]?:@"-"];
                    }
                }
                break;
            }
            case Women: {
                [self.sizeLabel20 setText:@"-"];
                [self.sizeLabel21 setText:@"-"];
                NSArray *euSize = [sizeChart getEUSizeFromCM:cms];
                if (euSize != nil && euSize.count > 0) {
                    if (euSize.count > 1) { //More than one results in range. Change state.
                        [self.sizeLabel20 setText:euSize[0]?:@"-"];
                        [self.sizeLabel21 setText:euSize[1]?:@"-"];
                    }
                }
            }
        }
    }
}

@end
