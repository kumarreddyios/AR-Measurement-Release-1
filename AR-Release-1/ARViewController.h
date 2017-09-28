//
//  ViewController.h
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/20/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "BaseInstructionVIew.h"

@interface ARViewController : UIViewController<InstructionDelegate>

@property enum Gender gender;
+(ARViewController*)getARViewController;

@end
