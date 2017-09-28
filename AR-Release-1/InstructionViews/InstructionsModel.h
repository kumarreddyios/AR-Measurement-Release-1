//
//  InstructionsModel.h
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/28/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

enum InstructionTypes{
    ARIntroduction,
    ARPlane,
    ARMarker,
    ARMeasure
};

@interface InstructionsModel : NSObject

@property (nonatomic, strong) NSString *mainTitle;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *buttonTitle;
@property enum InstructionTypes type;

+(NSArray*)prepareInstructionsDataset;

@end
