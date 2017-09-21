//
//  SizeChart.h
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/21/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SizeParameters;

@interface SizeChart : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<SizeParameters*>*> *sizeChart;

-(instancetype)initWithSizeDictionary:(NSDictionary*)sizeDictionary;

@end


@interface SizeParameters : NSObject

@property (nonatomic) CGFloat centimeters;
@property (nonatomic, strong) NSString *ukSize;
@property (nonatomic, strong) NSString *euroSize;

@end

