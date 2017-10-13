//
//  SizeChart.h
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/21/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SizeClass;

enum Gender{
    Men,
    Women
};

@interface SizeChart : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<SizeClass*>*> *sizeChart;
@property enum Gender gender;

-(instancetype)initWithSizeDictionary:(NSDictionary*)sizeDictionary;
-(NSArray* _Nullable)getUKSizeFromCM:(CGFloat)cms;
-(NSArray* _Nullable)getUSSizeFromCM:(CGFloat)cms;
-(NSArray* _Nullable)getEUSizeFromCM:(CGFloat)cms;

@end


@interface SizeClass : NSObject

@property (nonatomic) CGFloat startCms,endCms;
@property (nonatomic, strong) NSString *ukSize;
@property (nonatomic, strong) NSString *euroSize;
@property (nonatomic, strong) NSString *usSize;

-(instancetype)initWith:(NSDictionary*)dictionary;
@end

