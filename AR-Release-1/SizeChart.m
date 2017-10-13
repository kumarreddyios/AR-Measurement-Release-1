//
//  SizeChart.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/21/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "SizeChart.h"

#define OVERLAP_RANGE 0.3

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

//Returns the exact size class corresponding to the cm value.
-(SizeClass* _Nullable)getSizeClassForCM:(CGFloat)cms {
    NSMutableArray *dataArray = [self getDataArray];
    for (SizeClass *sizeClass in dataArray) {
        if (cms >= sizeClass.startCms && cms < sizeClass.endCms) {
            return sizeClass;
        }
    }
    return nil;
}

//Returns an array of size classes corresponding to the cm value and the overlap range.
-(NSArray* _Nullable)getSizeClassArrayForCM:(CGFloat)cms {
    NSMutableArray *dataArray = [self getDataArray];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (SizeClass *sizeClass in dataArray) {
        if (cms >= sizeClass.startCms && cms < sizeClass.endCms) { //Find actual range size class.
            //Now find auxillary size classes less than or more than this range
            //according to the overlap value.
            SizeClass *lowerClass = [self getSizeClassForCM:(cms - OVERLAP_RANGE)];
            SizeClass *upperClass = [self getSizeClassForCM:(cms + OVERLAP_RANGE)];
            if(lowerClass != nil && lowerClass != sizeClass) { //Add lower range.
                [resultArray addObject:lowerClass];
            }
            [resultArray addObject:sizeClass]; //add actual range.
            if (upperClass != nil && upperClass != sizeClass) {
                [resultArray addObject:upperClass]; //add upper range.
            }
            printf("\nCM: %fd | ResultArray Count - %d", cms, (int)resultArray.count);
            return resultArray;
        }
    }
    return nil;
}

-(NSArray* _Nullable)getUKSizeFromCM:(CGFloat)cms {
    NSArray *sizeClass = [self getSizeClassArrayForCM:cms];
    if(sizeClass != nil && sizeClass.count > 0) {
        NSMutableArray* dataArray = [[NSMutableArray alloc] init];
        SizeClass *firstSize = (SizeClass*) sizeClass[0];
        [dataArray addObject:[NSString stringWithFormat:@"UK %@",firstSize.ukSize]];
        if(sizeClass.count > 1) {
            SizeClass *secondSize = (SizeClass*) sizeClass[1];
            [dataArray addObject:[NSString stringWithFormat:@"UK %@",secondSize.ukSize]];
        }
        return dataArray;
    }
    return nil;
}

-(NSArray* _Nullable)getUSSizeFromCM:(CGFloat)cms {
    NSArray *sizeClass = [self getSizeClassArrayForCM:cms];
    if(sizeClass != nil && sizeClass.count > 0) {
        NSMutableArray* dataArray = [[NSMutableArray alloc] init];
        SizeClass *firstSize = (SizeClass*) sizeClass[0];
        [dataArray addObject:[NSString stringWithFormat:@"US %@",firstSize.usSize]];
        if(sizeClass.count > 1) {
            SizeClass *secondSize = (SizeClass*) sizeClass[1];
            [dataArray addObject:[NSString stringWithFormat:@"US %@",secondSize.usSize]];
        }
        return dataArray;
    }
    return nil;
}

-(NSArray* _Nullable)getEUSizeFromCM:(CGFloat)cms {
    NSArray *sizeClass = [self getSizeClassArrayForCM:cms];
    if(sizeClass != nil && sizeClass.count > 0) {
        NSMutableArray* dataArray = [[NSMutableArray alloc] init];
        SizeClass *firstSize = (SizeClass*) sizeClass[0];
        [dataArray addObject:[NSString stringWithFormat:@"EU %@",firstSize.euroSize]];
        if(sizeClass.count > 1) {
            SizeClass *secondSize = (SizeClass*) sizeClass[1];
            [dataArray addObject:[NSString stringWithFormat:@"EU %@",secondSize.euroSize]];
        }
        return dataArray;
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
