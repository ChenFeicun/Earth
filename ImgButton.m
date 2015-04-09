//
//  ImgButton.m
//  earth
//
//  Created by Feicun on 15/4/5.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "ImgButton.h"

@interface ImgButton()

//@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation ImgButton

- (instancetype)initWithFrame:(CGRect)frame withImgName:(NSString *)name {
    CGRect realFrame = CGRectMake(frame.origin.x + 10, frame.origin.y + 10, frame.size.width - 20, frame.size.width - 20);
    self = [super initWithFrame:realFrame];
    if (self) {

//        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20)];
//        self.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
        //self.imgName = name;
        [self setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]] forState:UIControlStateNormal];
        //[self setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"dis%@.png", name]] forState:UIControlStateHighlighted];
        self.backgroundColor = SKY_BLUE;
        //self.adjustsImageWhenHighlighted = NO;
        //self.layer.cornerRadius = frame.size.width / 2;
        //[self addSubview:self.imgView];
    }
    return self;
}

//- (void)showBorder {
//    self.layer.borderWidth = 6;
//    self.layer.borderColor = [CommonMethod getColorFromRed:255 Green:255 Blue:255 Alpha:255];
//}
//
//- (void)hiddenBorder {
//    self.layer.borderWidth = 0;
//}


@end
