//
//  UberLoginWebViewController.h
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UberLoginWebViewController : UIViewController
@property(nonatomic,strong) NSString *urlString;//LoginWebViewController 's url
@property(nonatomic,copy) void (^resultCallBack) (NSDictionary *jsonDict, NSURLResponse *response, NSError *error);// login callback

@end
