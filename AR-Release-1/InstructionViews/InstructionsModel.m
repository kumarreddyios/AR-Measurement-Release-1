//
//  InstructionsModel.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/28/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "InstructionsModel.h"

@implementation InstructionsModel

+(NSArray*)prepareInstructionsDataset{
    NSMutableArray *instructionsDS = [[NSMutableArray alloc] init];
    InstructionsModel *iModel1 = [[InstructionsModel alloc] init];
    iModel1.mainTitle = @"Let's get started";
    iModel1.subTitle = @"Remove your footwear and sit comfortably. Bend a little and point your phone towards the floor";
    iModel1.imageName = @"sittingIllustration";
    iModel1.buttonTitle = @"NEXT";
    iModel1.type = ARIntroduction;
    [instructionsDS addObject:iModel1];

    InstructionsModel *iModel2 = [[InstructionsModel alloc] init];
    iModel2.mainTitle = @"Surface Detection";
    iModel2.subTitle = @"Slowly move your phone up and down till dots appear on the screen and you see a highlited area on the floor.";
    iModel2.imageName = @"planeDetection";
    iModel2.buttonTitle = @"Try Now";
    iModel2.type = ARPlane;
    [instructionsDS addObject:iModel2];

    InstructionsModel *iModel3 = [[InstructionsModel alloc] init];
    iModel3.mainTitle = @"Place a Base Marker";
    iModel3.subTitle = @"Tap on the screen to place a base marker towards the bottom of the detected plane.";
    iModel3.imageName = @"baseMarkerGraphics";
    iModel3.buttonTitle = @"Try Now";
    iModel3.type = ARMarker;
    [instructionsDS addObject:iModel3];

    InstructionsModel *iModel4 = [[InstructionsModel alloc] init];
    iModel4.mainTitle = @"Measure Your Foot";
    iModel4.subTitle = @"Place your foot so that the bottom marker touches the base of your foot. Now, slide the marker to the tip of your toe.";
    iModel4.imageName = @"scaleIllusion";
    iModel4.buttonTitle = @"Try Now";
    iModel4.type = ARMeasure;
    [instructionsDS addObject:iModel4];

    return instructionsDS;
}
@end
