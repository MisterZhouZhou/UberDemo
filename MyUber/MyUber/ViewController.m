//
//  ViewController.m
//  MyUber
//
//  Created by rayootech on 16/5/20.
//  Copyright © 2016年 rayootech. All rights reserved.
//

#import "ViewController.h"
#import "UberLoginWebViewController.h"
#import "UberAPI.h"
#import "UberProfile.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *loginBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:loginBut];
    loginBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 100, 200, 50);
    loginBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [loginBut setTitle:@"Uber OAuth Login" forState:UIControlStateNormal];
    [loginBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBut addTarget:self action:@selector(loginButAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *requestUserProfileBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:requestUserProfileBut];
    requestUserProfileBut.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 200, 200, 50);
    requestUserProfileBut.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [requestUserProfileBut setTitle:@"Request User Profile" forState:UIControlStateNormal];
    [requestUserProfileBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestUserProfileBut addTarget:self action:@selector(requestUserProfileButAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *requestProduct=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:requestProduct];
    requestProduct.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 300, 200, 50);
    requestProduct.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [requestProduct setTitle:@"Request Product" forState:UIControlStateNormal];
    [requestProduct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestProduct addTarget:self action:@selector(pushProduct) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *rideBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:rideBtn];
    rideBtn.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 400, 200, 50);
    rideBtn.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [rideBtn setTitle:@"Ride" forState:UIControlStateNormal];
    [rideBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rideBtn addTarget:self action:@selector(rideBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *history=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:history];
    history.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 500, 200, 50);
    history.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [history setTitle:@"history" forState:UIControlStateNormal];
    [history setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [history addTarget:self action:@selector(historyClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *trip=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:trip];
    trip.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 600, 200, 50);
    trip.backgroundColor=[UIColor colorWithRed:0.04f green:0.03f blue:0.11f alpha:1.00f];
    [trip setTitle:@"trip" forState:UIControlStateNormal];
    [trip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [trip addTarget:self action:@selector(tripClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loginButAction{
    if (ClientId.length<1 || ClientSecret.length<1 || RedirectUrl.length<1 ) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"you need clientid & clientsecret & redirecturl \n" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alerView show];
        return;
        
    }
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    //    缓存  清除
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    UberLoginWebViewController *webViewController=[[UberLoginWebViewController alloc] init];
    NSString *url=[NSString stringWithFormat:@"https://login.uber.com.cn/oauth/v2/authorize?client_id=%@&redirect_url=%@&response_type=code&scope=profile history places history_lite ride_widgets",ClientId,RedirectUrl ];
    NSString *encodedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    webViewController.urlString=encodedUrlString;
    webViewController.resultCallBack=^(NSDictionary *jsonDict, NSURLResponse *response, NSError *error){
        NSLog(@"access token %@ ",jsonDict);
        
        if (error) {
            if ([error.domain isEqualToString:@"error2"]) {
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"login fail" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
                [alerView show];
            }
        }else{
            [self requestUserProfileButAction];
            
        }
        
    };
    
    [self presentViewController:webViewController animated:YES completion:nil];
}


- (void)requestUserProfileButAction{
    if (ClientId.length<1 || ClientSecret.length<1 || RedirectUrl.length<1 ) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"you need clientid & clientsecret & redirecturl \n" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alerView show];
        return;
        
    }
    
    NSString *accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (!accessToken || accessToken.length<1) {
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"" message:@"please login first" delegate:self cancelButtonTitle:@"sure" otherButtonTitles:@"cancel", nil];
        [alerView show];
    }else{
        [self userProfileRequest];
    }
}


#pragma mark - history
-(void)historyClick
{
   [UberAPI getUserActivityWithCompletionHandler:^(NSArray *resultsArray, NSURLResponse *response, NSError *error) {
      
       NSLog(@"%@",resultsArray);
   }];
}

#pragma mark - trip
-(void)tripClick{
    CLLocation *location1=[[CLLocation alloc] initWithLatitude:39.8458652156 longitude:116.4474123716];
    CLLocation *location2=[[CLLocation alloc] initWithLatitude:39.9613658535 longitude:116.4568376541];
  [UberAPI getPriceForTripWithStartLocation:location1 endLocation:location2 withCompletionHandler:^(NSArray *resultsArray, NSURLResponse *response, NSError *error) {
      NSLog(@"%@",resultsArray);
  }];
  
}

#pragma mark - 请求产品
-(void)pushProduct
{
    CLLocation *location=[[CLLocation alloc] initWithLatitude:37.7759792 longitude:-122.41823];
    [UberAPI getProductsForLocation:(CLLocation *)location withCompletionHandler:^(NSArray *resultsArray, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",resultsArray);
    }];
}

-(void)rideBtnClick{
    NSString *accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    NSString *scope=[[NSUserDefaults standardUserDefaults] objectForKey:@"scope"];
    NSString *url=[NSString stringWithFormat:@"https://components.uber.com.cn/rides/?access_token=%@&scope=%@",accessToken,scope];
    NSLog(@"--access_token:%@",url);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *webViewController=[[UIViewController alloc] init];
        NSString *encodedUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *baseURL = [NSURL URLWithString:encodedUrlString];
        
        UIWebView *webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame))];
        webView.scalesPageToFit = YES;
        
        NSURLRequest *request=[[NSURLRequest alloc]initWithURL:baseURL];
        [webView loadRequest:request];
        
        webView.backgroundColor=[UIColor whiteColor];
        [webViewController.view addSubview:webView];
        
        [self.navigationController pushViewController:webViewController animated:YES];
    });
}


#pragma mark - 使用者信息
- (void)userProfileRequest{
    
    [UberAPI requestUserProfileWithResult:^(UberProfile* profile, NSURLResponse *response, NSError *error){
        if (profile) {
            // 主线程执行：
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"User's 全名称 %@ %@", profile.last_name,profile.first_name);
            });
        }
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [self loginButAction];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
