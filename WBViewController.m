//
//  WeiboViewController.m
//  earth
//
//  Created by Feicun on 15/3/19.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "WBViewController.h"
#import "ImgButton.h"
#import "SCLAlertView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "GoogleMobileAds/GADBannerView.h"

@interface WBViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, WBHttpRequestDelegate> {
    GADBannerView *bannerView;
}

@property (strong, nonatomic) ImgButton *weibiBtn;
//@property (strong, nonatomic) ImgButton *photoLibraryBtn;
//@property (strong, nonatomic) ImgButton *cameraBtn;
@property (nonatomic) BOOL isSelectPic;
@property (strong, nonatomic) ImgButton *addBtn;
@property (strong, nonatomic) ImgButton *listBtn;
@property (strong, nonatomic) UILabel *addLabel;
@property (strong, nonatomic) UIImageView *contentImageView;
@property (strong, nonatomic) UIImage *chosenImage;
@property (strong, nonatomic) NSData *chosenImageData;
@property (nonatomic) BOOL isCamera;

@property (strong, nonatomic) NSString *provinceWB;
@property (strong, nonatomic) NSString *cityWB;


//@property (strong, nonatomic) PhotoTweakView *photoView;
@end

@implementation WBViewController

- (void)sendWeiboPic:(UIButton *)sender {
    WBMessageObject *message = [WBMessageObject message];
    NSString *msgText = [[NSString alloc] init];
    if (self.provinceWB) {
        msgText = [msgText stringByAppendingString:self.provinceWB];
    }
    if (self.cityWB) {
        msgText = [msgText stringByAppendingString:self.cityWB];
    }
    if (![self isExistWB]) {
        msgText = [msgText stringByAppendingString:@"@微言环保"];
    }
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBToken"];
    NSString *address = [[NSUserDefaults standardUserDefaults] objectForKey:@"Address"];
    message.text = msgText;
    if (address) {
         message.text = [msgText stringByAppendingString:[NSString stringWithFormat:@" 我在%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"Address"]]];
    }
   
    if (!self.chosenImage) {
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:token];
        request.userInfo = @{@"type": @"text"};
        [WeiboSDK sendRequest:request];
    } else {
        //发图片微博 发多图需要申请高级接口  并且先上传图片 获取pic_id然后才能发多图微博
        WBImageObject *image = [WBImageObject object];
        //image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"disdelete" ofType:@"png"]];
        self.chosenImageData = UIImageJPEGRepresentation(self.chosenImage, 1.0f);
        image.imageData = self.chosenImageData;
        message.imageObject = image;
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:token];
        request.userInfo = @{@"type": @"singlePic"};
        [WeiboSDK sendRequest:request];
    }
    //发送http请求
//    self.chosenImageData = UIImageJPEGRepresentation(self.chosenImage, 1.0f);
//    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBToken"];
//    //NSString *curUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBCurUserID"];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:token forKey:@"access_token"];
//    [dic setObject:@"nidaye" forKey:@"status"];
//    [dic setObject:self.chosenImageData forKey:@"pic"];
//
//    //用tag来标记不同的请求
//    [WBHttpRequest requestWithAccessToken:token url:@"https://upload.api.weibo.com/2/statuses/upload.json"  httpMethod:@"POST" params:dic delegate:self withTag:@"singlePic"];
}

- (void)addPicture:(UIButton *)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"相机" target:self selector:@selector(getPicFromCamera:)];
    [alert addButton:@"照片" target:self selector:@selector(getPicFromPhotoLibrary:)];
    [alert showTitle:self title:@"选择图片来源" subTitle:@"" style:Success closeButtonTitle:@"取消" duration:0.0f];
}

- (void)checkAllWB:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowAllWB" sender:self];
}

- (void)sendWBMsgSuccess:(NSNotification *)notification {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showTitle:self title:@"发布微博成功" subTitle:@"" style:Success closeButtonTitle:@"确定" duration:0.0f];
    NSString *type = [notification.userInfo objectForKey:@"type"];
    if ([type isEqualToString:@"singlePic"]) {
        //微博发送成功  上传至AVOS
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *username = [AVUser currentUser].username;//[[NSUserDefaults standardUserDefaults] objectForKey:@"WBUsername"];
            
            NSDate *date = [NSDate date];
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:date];
            //AVFile不能添加字段
            AVFile *file = [AVFile fileWithName:[NSString stringWithFormat:@"%@_%@.jpg", username, dateString] data:self.chosenImageData];
            //地理位置  发布时间  发布人
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    AVRelation *relation = [[AVUser currentUser] relationforKey:@"pictures"];
                    AVObject *obj = [AVObject objectWithClassName:@"Picture"];
                    [obj setObject:username forKey:@"publishUser"];
                    [obj setObject:dateString forKey:@"publishTime"];
                    [obj setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"Address"] forKey:@"publishAddress"];
                    [obj setObject:file forKey:@"pictureFile"];
                    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded && !error) {
                            [relation addObject:obj];
                            [[AVUser currentUser] saveInBackground];
                        }
                    }];
                }
            }];
        });
    }
}

- (void)sendWBMsgFail:(NSNotification *)notification {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showTitle:self title:@"发布微博失败" subTitle:@"" style:Error closeButtonTitle:@"确定" duration:0.0f];
}

- (void)getPicFromPhotoLibrary:(UIButton *)sender {
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum 从相册中取
    //UIImagePickerControllerSourceTypePhotoLibrary 图库(包括自己下载保存的)
    self.isCamera = NO;
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)getPicFromCamera:(UIButton *)sender {
    self.isCamera = YES;
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediatypes count] > 0) {
        NSArray *mediatypes=[UIImagePickerController availableMediaTypesForSourceType:sourceType];
        
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.mediaTypes = mediatypes;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [picker setMediaTypes:arrmediatypes];
        [self presentViewController:picker animated:YES completion:^{
            ;
        }];
    } else {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showTitle:self title:@"错误信息" subTitle:@"当前设备不支持拍摄功能!" style:Error closeButtonTitle:@"确定" duration:0.0f];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    //不知道会出什么错误 暂时可以不管 已经得到拍的照片了
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *lastChosenMediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([lastChosenMediaType isEqual:(NSString *) kUTTypeImage]) {
        self.chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.isSelectPic = YES;
        //相机拍的需要保存
        if (self.isCamera) {
            UIImageWriteToSavedPhotosAlbum(self.chosenImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        
        float width = self.chosenImage.size.width;
        float height = self.chosenImage.size.height;
        height = height / (width / (SCREEN_WIDTH - 2 * MAIN_PADDING));
        width = SCREEN_WIDTH - 2 * MAIN_PADDING;
        if (height > SCREEN_HEIGHT - 3 * MAIN_PADDING - BTN_SIZE) {
            width = width / (height / (SCREEN_HEIGHT - 3 * MAIN_PADDING - BTN_SIZE));
            height = SCREEN_HEIGHT - 3 * MAIN_PADDING - BTN_SIZE;
        }
        self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - width) / 2, (SCREEN_HEIGHT - 3 * MAIN_PADDING - BTN_SIZE - height) / 2 + MAIN_PADDING, width, height)];
        //self.contentImageView.center = CGPointMake(SCREEN_WIDTH / 2, );
        self.contentImageView.image = self.chosenImage;
        self.contentImageView.layer.borderWidth = 3;
        self.contentImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.view addSubview:self.contentImageView];
    }
    if ([lastChosenMediaType isEqual:(NSString *) kUTTypeMovie]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示信息!" message:@"系统只支持图片格式" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.isSelectPic) {
            self.addLabel.hidden = YES;
            self.addBtn.frame = CGRectMake(WB_PADDING + 10, SCREEN_HEIGHT - BTN_SIZE - MAIN_PADDING + 10, BTN_SIZE - 20, BTN_SIZE - 20);
            self.weibiBtn.frame = CGRectMake(2 * WB_PADDING + BTN_SIZE + 10, SCREEN_HEIGHT - BTN_SIZE - MAIN_PADDING + 10, BTN_SIZE - 20, BTN_SIZE - 20);
            self.listBtn.frame = CGRectMake(3 * WB_PADDING + BTN_SIZE * 2 + 10, SCREEN_HEIGHT - BTN_SIZE - MAIN_PADDING + 10, BTN_SIZE - 20, BTN_SIZE - 20);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

#pragma mark - ...

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result {
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedString(@"收到网络回调", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",result]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"确定", nil)
                             otherButtonTitles:nil];
    //根据请求的tag来区分
//    if ([request.tag isEqualToString:@"singlePic"]) {
//        [self sendSinglePicSuccess];
//    }
    [alert show];
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error; {
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedString(@"请求异常", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",error]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
    //[alert release];
}

- (BOOL)isExistWB {
    if ((self.provinceWB && ![self.provinceWB isEqualToString:@""]) || (self.cityWB && ![self.cityWB isEqualToString:@""])) {
        return YES;
    }
    return NO;
}

#pragma mark - 初始化

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SKY_BLUE;
    self.isSelectPic = NO;
    self.isCamera = NO;
    [self googleAD];
    [self buttonInit];
    [self avosLogin];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendWBMsgSuccess:) name:@"SendWBMsgSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendWBMsgFail:) name:@"SendWBMsgFail" object:nil];
    
    NSString *province = [[NSUserDefaults standardUserDefaults] objectForKey:@"Province"];
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:@"City"];
    
    
    self.provinceWB = [[ResourceManager sharedInstance] getProvinceWB:province];
    self.cityWB = [[ResourceManager sharedInstance] getCityWB:city ofProvince:province];
    //未定位
    if (!province) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showWarning:self title:@"未定位当前位置" subTitle:@"无法根据您的位置自动@当地的环保机构官方微博,将为您@微言环保。" closeButtonTitle:@"确定" duration:0.0f];
    } else if (![self isExistWB]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showWarning:self title:@"未开通微博" subTitle:@"您所在区域的环保机构尚未开通官方微博,将为您@微言环保。" closeButtonTitle:@"确定" duration:0.0f];
    }
}

- (void)googleAD {
    // 在屏幕顶部创建标准尺寸的视图。
    // 在GADAdSize.h中对可用的AdSize常量进行说明。
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    // 指定广告单元ID。ca-app-pub-9981528462779788/2026810556
    bannerView.adUnitID = GOOGLE_AD_ID;//@"ca-app-pub-9981528462779788/6387264958";
    // 告知运行时文件，在将用户转至广告的展示位置之后恢复哪个UIViewController
    // 并将其添加至视图层级结构。
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];
    
    // 启动一般性请求并在其中加载广告。
    [bannerView loadRequest:[GADRequest request]];
}

- (void)avosLogin {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBUsername"];
    if (![AVUser currentUser]) {
        AVUser *user = [AVUser user];
        user.username = username;
        user.password = @"123456";
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"%@", error.localizedDescription);
            //The request timed out.
            if (succeeded && !error) {
                //[self performSegueWithIdentifier:@"ToWeibo" sender:self];
            } else if ([error.localizedDescription isEqualToString:@"Username has already been taken"]) {
                [AVUser logInWithUsernameInBackground:user.username password:user.password block:^(AVUser *user, NSError *error) {
                    if (succeeded && !error) {
                        //[self performSegueWithIdentifier:@"ToWeibo" sender:self];
                    }
                }];
            }
        }];
    }
}

- (void)buttonInit {
    self.weibiBtn = [[ImgButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - BTN_SIZE * 2) / 3, SCREEN_HEIGHT - BTN_SIZE - MAIN_PADDING, BTN_SIZE, BTN_SIZE) withImgName:@"send"];
    [self.weibiBtn addTarget:self action:@selector(sendWeiboPic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.weibiBtn];
    
    self.addBtn = [[ImgButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - BTN_SIZE / 2, (SCREEN_HEIGHT - self.weibiBtn.frame.origin.x) / 2 - BTN_SIZE / 2, BTN_SIZE, BTN_SIZE) withImgName:@"picture"];
    [self.addBtn addTarget:self action:@selector(addPicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addBtn];
    
    self.listBtn = [[ImgButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - BTN_SIZE * 2) * 2 / 3 + BTN_SIZE, SCREEN_HEIGHT - BTN_SIZE - MAIN_PADDING, BTN_SIZE, BTN_SIZE) withImgName:@"list"];
    [self.listBtn addTarget:self action:@selector(checkAllWB:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.listBtn];

    self.addLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.addBtn.frame.origin.y + BTN_SIZE + 10, SCREEN_WIDTH, 100)];
    self.addLabel.text = @"点击选取图片\n(目前仅支持添加单张图片,\n多张图片请在点击发送按钮后,\n跳转至微博页面添加)";
    self.addLabel.textAlignment = NSTextAlignmentCenter;
    self.addLabel.backgroundColor = [UIColor clearColor];
    self.addLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    //设置换行
    self.addLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.addLabel.numberOfLines = 0;
    self.addLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.addLabel];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
