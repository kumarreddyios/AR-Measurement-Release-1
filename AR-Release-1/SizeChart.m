//
//  SizeChart.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/21/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "SizeChart.h"

@implementation SizeChart

-(instancetype)initWithSizeDictionary:(NSDictionary *)sizeDictionary{
    self = [super init];
    if (self) {
        [self buildChartFromDictionary:sizeDictionary];
    }
    return self;
}

-(void)buildChartFromDictionary:(NSDictionary*)dictionary {
    NSLog(@"dictionary %@",dictionary);
}

@end

@implementation SizeParameters

@end
