//
//  ResourceManager.m
//  earth
//
//  Created by Feicun on 15/4/10.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "ResourceManager.h"

@interface ResourceManager()

@property (strong, nonatomic) NSArray *citiesInfo;
@property (strong, nonatomic) NSDictionary *allInfoDict;
@property (strong, nonatomic) NSArray *allProvincesInfo;
@end

@implementation ResourceManager

static id instance = nil;

+ (instancetype)sharedInstance {
    //dispatch_once_t 一般用来写单例
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.allInfoDict = [self getAllInfoFromPlist];
        //self.infoDict = [[NSDictionary alloc] initWithDictionary:[self getAllInfoFromPlist]];
        //self.provinceArray = [self.infoDict allKeys];
        self.provinceArray = [self getAllProvince];//[self getAll];
    }
    return self;
}

- (NSDictionary *)getAllInfoFromPlist {
    NSDictionary *infoDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Area" ofType:@"plist"]];
    return infoDict;
}

- (NSArray *)getAllProvince {
    NSArray *components = [self.allInfoDict allKeys];
    NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSMutableArray *provinceTmp = [[NSMutableArray alloc] init];
    NSMutableArray *provinceInfoTmp = [[NSMutableArray alloc] init];
    for (int i = 0; i < [sortedArray count]; i++) {
        NSString *index = [sortedArray objectAtIndex:i];
        NSArray *tmp = [[self.allInfoDict objectForKey:index] allKeys];
        [provinceInfoTmp addObject:[self.allInfoDict objectForKey:index]];
        [provinceTmp addObject:[tmp objectAtIndex:0]];
    }
    self.allProvincesInfo = [[NSArray alloc] initWithArray:provinceInfoTmp];
    NSArray *province = [[NSArray alloc] initWithArray:provinceTmp];
    return province;
}

- (NSDictionary *)getProvinceInfo:(NSString *)province {
    NSString *index = [NSString stringWithFormat:@"%lu", (unsigned long)[self.provinceArray indexOfObject:province]];
    NSDictionary *provinceDict = [[self.allInfoDict objectForKey:index] objectForKey:province];
    return provinceDict;
}

- (NSString *)getProvinceWB:(NSString *)province {
    return [[self getProvinceInfo:province] objectForKey:@"省"];
}

- (NSDictionary *)getCityDict:(NSString *)city ofProvince:(NSString *)province {
    NSArray *cities = [self getAllCitiesOfProvince:province];
    NSDictionary *cityDict = [[self.citiesInfo objectAtIndex:[cities indexOfObject:city]] objectForKey:city];
    return cityDict;
}

- (NSString *)getCityWB:(NSString *)city ofProvince:(NSString *)province {
    NSString *wb = [[self getCityDict:city ofProvince:province] objectForKey:@"微博"];
    return wb;
}

- (NSString *)getCityCode:(NSString *)city ofProvince:(NSString *)province {
    NSString *ac = [[self getCityDict:city ofProvince:province] objectForKey:@"区号"];
    return ac;
}

- (NSArray *)getAllCitiesOfProvince:(NSString *)province {
    NSDictionary *proDict = [self getProvinceInfo:province];
    NSMutableArray *components = [[NSMutableArray alloc] initWithArray:[proDict allKeys]];
    if ([components containsObject:@"省"]) {
        [components removeObject:@"省"];
    }
    NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSMutableArray *cityTmp = [[NSMutableArray alloc] init];
    NSMutableArray *cityInfoTmp = [[NSMutableArray alloc] init];
    for (int i = 0; i < [sortedArray count]; i++) {
        NSString *index = [sortedArray objectAtIndex:i];
        NSArray *tmp = [[proDict objectForKey:index] allKeys];
        [cityTmp addObject:[tmp objectAtIndex:0]];
        [cityInfoTmp addObject:[proDict objectForKey:index]];
    }
    self.citiesInfo = [[NSArray alloc] initWithArray:cityInfoTmp];
    NSArray *cities = [[NSArray alloc] initWithArray:cityTmp];
    return cities;
}

//- (NSDictionary *)getAllInfoFromPlist {
//    NSDictionary *infoDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CityWB" ofType:@"plist"]];
//    return infoDict;
//}
//
//- (NSString *)getAreaCode:(NSString *)province ofCity:(NSString *)city {
//    NSDictionary *provinceDict = [self.infoDict objectForKey:province];
//    NSDictionary *cityDict = [provinceDict objectForKey:city];
//    NSString *areaCode = [[cityDict objectForKey:@"区号"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    return areaCode;
//}
//
//- (NSString *)getProvinceWB:(NSString *)province {
//    NSDictionary *provinceDict = [self.infoDict objectForKey:province];
//    NSString *provinceWB = [[provinceDict objectForKey:@"省"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    return provinceWB;
//}
//
//- (NSString *)getWB:(NSString *)province ofCity:(NSString *)city {
//    NSDictionary *provinceDict = [self.infoDict objectForKey:province];
//    NSDictionary *cityDict = [provinceDict objectForKey:city];
//    NSString *cityWB = [[cityDict objectForKey:@"微博"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    return cityWB;
//}
//
//- (NSArray *)allCitiesOfProvince:(NSString *)province {
//    NSMutableArray *cityArray = [[NSMutableArray alloc] initWithArray:[[self.infoDict objectForKey:province] allKeys]];
//    if ([cityArray containsObject:@"省"]) {
//        [cityArray removeObject:@"省"];
//    }
//    return cityArray;
//}
@end
