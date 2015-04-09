//
//  AppDelegate.m
//  earth
//
//  Created by Feicun on 15/3/12.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "AppDelegate.h"

//102551001443
@interface AppDelegate () <WeiboSDKDelegate>

@end

@implementation AppDelegate

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        //NSString *title = NSLocalizedString(@"发送结果", nil);
        //NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
        WBSendMessageToWeiboResponse *sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString *accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken) {
            self.wbtoken = accessToken;
            [[NSUserDefaults standardUserDefaults] setObject:self.wbtoken forKey:@"WBToken"];
        }
        NSString *userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
            [[NSUserDefaults standardUserDefaults] setObject:self.wbCurrentUserID forKey:@"WBCurUserID"];
        }
        //响应成功 有问题  未发送(比如说回首页也返回0 -- 为什么会有时首页有时没首页)
        NSString *type = [response.requestUserInfo objectForKey:@"type"];
        NSDictionary *userInfoDic = [[NSDictionary alloc] initWithObjects:@[type] forKeys:@[@"type" ]];
        if ((int)response.statusCode == 0) {
            if ([type isEqualToString:@"text"] || [type isEqualToString:@"singlePic"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SendWBMsgSuccess" object:self userInfo:userInfoDic];
            }
        } else {
            if ([type isEqualToString:@"text"] || [type isEqualToString:@"singlePic"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SendWBMsgFail" object:self userInfo:userInfoDic];
            }
        }
        //[alert show];
        //[alert release];
    } else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        //NSString *title = NSLocalizedString(@"认证结果", nil);
        //NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, [(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
        
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        NSDate *date = [(WBAuthorizeResponse *)response expirationDate];
        //NSDate *nowDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *destDateString = [dateFormatter stringFromDate:date];
//        if ([date compare:nowDate] == NSOrderedAscending) {
//            //没过期
//        }
        [[NSUserDefaults standardUserDefaults] setObject:self.wbtoken forKey:@"WBToken"];
        [[NSUserDefaults standardUserDefaults] setObject:self.wbCurrentUserID forKey:@"WBCurUserID"];
        [[NSUserDefaults standardUserDefaults] setObject:destDateString forKey:@"WBExpirationDate"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetToken" object:nil];
        //[alert show];
        //[alert release];
    } else if ([response isKindOfClass:WBPaymentResponse.class]) {
//        NSString *title = NSLocalizedString(@"支付结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
//        [alert show];
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
   
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [AVOSCloud setApplicationId:AVOS_APP_ID clientKey:AVOS_APP_KEY];
    //setenv("LOG_CURL", "YES", 0);
    
    //[WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Province"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"City"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Address"];
}

@end
