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
        self.sizeChart = [[NSMutableDictionary alloc] init];
        [self buildChartFromDictionary:sizeDictionary];
    }
    return self;
}

-(void)buildChartFromDictionary:(NSDictionary*)dictionary {
    NSArray *menSizeArray = dictionary [@"men"];
    NSArray *womenSizeArray = dictionary[@"women"];

    if (menSizeArray.count > 0) {
        NSMutableArray *sizeClasses = [[NSMutableArray alloc] init];
        self.sizeChart[@"men"] = sizeClasses;
        for (NSDictionary *data in menSizeArray) {
            SizeClass *sizeClass = [[SizeClass alloc] initWith:data];
            [sizeClasses addObject:sizeClass];
        }
    }

    if(womenSizeArray.count > 0){
        NSMutableArray *sizeClasses = [[NSMutableArray alloc] init];
        self.sizeChart[@"women"] = sizeClasses;
        for (NSDictionary *data in womenSizeArray) {
            SizeClass *sizeClass = [[SizeClass alloc] initWith:data];
            [sizeClasses addObject:sizeClass];
        }
    }
}

-(NSMutableArray*)getDataArray {
    switch (self.gender) {
        case Men:
            return [self.sizeChart objectForKey:@"men"];
            break;
        case Women:
            return [self.sizeChart objectForKey:@"women"];
        default:
            break;
    }
    return [[NSMutableArray alloc] init];
}

-(SizeClass* _Nullable)getSizeClassForCM:(CGFloat)cms {
    NSMutableArray *dataArray = [self getDataArray];
    for (SizeClass *sizeClass in dataArray) {
        if (cms >= sizeClass.startCms && cms < sizeClass.endCms) {
            return sizeClass;
        }
    }
    return nil;
}

-(NSString* _Nullable)getUKSizeFromCM:(CGFloat)cms {
    SizeClass *sizeClass = [self getSizeClassForCM:cms];
    if(sizeClass != nil) {
        return [NSString stringWithFormat:@"EU %@",sizeClass.ukSize];
    }
    return nil;
}

-(NSString* _Nullable)getUSSizeFromCM:(CGFloat)cms {
    SizeClass *sizeClass = [self getSizeClassForCM:cms];
    if(sizeClass != nil) {
        return [NSString stringWithFormat:@"EU %@",sizeClass.usSize];
    }
    return nil;
}

-(NSString* _Nullable)getEUSizeFromCM:(CGFloat)cms {
    SizeClass *sizeClass = [self getSizeClassForCM:cms];
    if(sizeClass != nil) {
        return [NSString stringWithFormat:@"EU %@",sizeClass.euroSize];
    }
    return nil;
}

@end

@implementation SizeClass

-(instancetype)initWith:(NSDictionary*)dictionary{
    self = [super init];
    if (self){
        self.startCms = ((NSString*)dictionary[@"startCms"]).floatValue;
        self.endCms = ((NSString*)dictionary[@"endCms"]).floatValue;
        self.ukSize = dictionary[@"uk"];
        self.usSize = dictionary[@"us"];
        self.euroSize = dictionary[@"euro"];
    }
    return self;
}

@end
