//
//  ResourceManager.h
//  earth
//
//  Created by Feicun on 15/4/10.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceManager : NSObject

@property (strong, nonatomic) NSArray *provinceArray;

+ (instancetype)sharedInstance;

- (NSString *)getProvinceWB:(NSString *)province;
- (NSString *)getCityWB:(NSString *)city ofProvince:(NSString *)province;
- (NSString *)getCityCode:(NSString *)city ofProvince:(NSString *)province;
- (NSArray *)getAllCitiesOfProvince:(NSString *)province;
//- (NSString *)getAreaCode:(NSString *)province ofCity:(NSString *)city;
//- (NSString *)getProvinceWB:(NSString *)province;
//- (NSString *)getWB:(NSString *)province ofCity:(NSString *)city;
//- (NSArray *)allCitiesOfProvince:(NSString *)province;

@end
