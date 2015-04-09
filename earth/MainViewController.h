//
//  ViewController.h
//  earth
//
//  Created by Feicun on 15/3/12.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CSqlite.h"

@interface MainViewController : UIViewController
@end

@interface CustomAnnotation : NSObject <MKAnnotation> {
    NSString *title;
    NSString *subtitle;
    CLLocationCoordinate2D coordinate;
}
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//@property (nonatomic, retain) NSString *title;
//@property (nonatomic, retain) NSString *subtitle;

- (id)initWithCoords:(CLLocationCoordinate2D) coords;
- (id)initWithCoords:(CLLocationCoordinate2D)coords andTitle:(NSString *)mapTitle Subtitle:(NSString *)mapSubtitle;
@end

