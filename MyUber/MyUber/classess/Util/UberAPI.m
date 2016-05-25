//
//  UberAPI.m
//  UberOAuth2
//
//  Created by coderyi on 16/1/19.
//  Copyright © 2016年 coderyi. All rights reserved.
//

#import "UberAPI.h"
#import "UberActivity.h"
#import "UberProduct.h"
#import "UberPrice.h"
#import "UberTime.h"
#import "UberPromotion.h"
#import "UberProfile.h"

NSString * const baseURL = @"https://api.uber.com/v1";


@implementation UberAPI

#pragma mark -根据code获取token
+ (void)requestAccessTokenWithAuthorationCode:(NSString *)code result:(RequestResult)requestResult{
    NSURL *url = [NSURL URLWithString:@"https://login.uber.com.cn/oauth/v2/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postBodyString=[NSString stringWithFormat:@"client_secret=%@&client_id=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",ClientSecret,ClientId,RedirectUrl,code];
    
    NSData *bodyData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"access_token"] forKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"scope"] forKey:@"scope"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (requestResult) {
            
            requestResult([responseObject objectForKey:@"access_token"],response,error);
        }
    }];
    [task resume];
}

#pragma mark - 获取用户信息
+ (void)requestUserProfileWithResult:(RequestResult)requestResult{
    NSURL *URL = [NSURL URLWithString:@"https://api.uber.com.cn/v1/me"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (requestResult) {
            UberProfile *profile = [[UberProfile alloc] initWithDictionary:responseObject];
            requestResult(profile,response,error);
        }
    }];
    [task resume];
}

#pragma mark - history
+ (void) getUserActivityWithCompletionHandler:(CompletionHandler)completion
{
    //GET /v1.2/history
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    NSString *url = [NSString stringWithFormat:@"https://api.uber.com/v1.2/history?access_token=%@", token];
    [UberAPI requestProductMessageWithURL:url completionHandler:^(NSDictionary *activity, NSURLResponse *response, NSError *error)
     {
         if(!error)
         {
             int offset = [[activity objectForKey:@"offset"] intValue];
             int limit = [[activity objectForKey:@"limit"] intValue];
             int count = [[activity objectForKey:@"count"] intValue];
             NSArray *history = [activity objectForKey:@"history"];
             NSMutableArray *availableActivity = [[NSMutableArray alloc] init];
             for(int i=0; i<history.count; i++)
             {
                 UberActivity *activity = [[UberActivity alloc] initWithDictionary:[history objectAtIndex:i]];
                 [activity setLimit:limit];
                 [activity setOffset:offset];
                 [activity setCount:count];
                 [availableActivity addObject:activity];
             }
             completion(availableActivity, response, error);
         }
         else
         {
             completion(nil, response, error);
         }
     }];
}

#pragma mark - products
+ (void) getProductsForLocation:(CLLocation *)location withCompletionHandler:(CompletionHandler)completion
{
    // GET/v1/products
    
    NSString *url = [NSString stringWithFormat:@"%@/products?server_token=%@&latitude=%f&longitude=%f", baseURL, ServerId, location.coordinate.latitude, location.coordinate.longitude];
    [UberAPI requestProductMessageWithURL:url completionHandler:^(NSDictionary *results, NSURLResponse *response, NSError *error)
     {
         if(!error)
         {
             NSArray *products = [results objectForKey:@"products"];
             NSMutableArray *availableProducts = [[NSMutableArray alloc] init];
             for(int i=0; i<products.count; i++)
             {
                 UberProduct *product = [[UberProduct alloc] initWithDictionary:[products objectAtIndex:i]];
                 [availableProducts addObject:product];
             }
             completion(availableProducts, response,  error);
         }
         else
         {
             NSLog(@"Error %@", error);
             completion(nil, response, error);
         }
     }];
}


+ (void) getPriceForTripWithStartLocation:(CLLocation *)startLocation endLocation:(CLLocation *)endLocation withCompletionHandler:(CompletionHandler)completion
{
    // GET /v1/estimates/price
    
    NSString *url = [NSString stringWithFormat:@"%@/estimates/price?server_token=%@&start_latitude=%f&start_longitude=%f&end_latitude=%f&end_longitude=%f", baseURL, ServerId, startLocation.coordinate.latitude, startLocation.coordinate.longitude, endLocation.coordinate.latitude, endLocation.coordinate.longitude];
    [self requestProductMessageWithURL:url completionHandler:^(NSDictionary *results, NSURLResponse *response, NSError *error)
     {
         if(!error)
         {
             NSArray *prices = [results objectForKey:@"prices"];
             NSMutableArray *availablePrices = [[NSMutableArray alloc] init];
             for(int i=0; i<prices.count; i++)
             {
                 UberPrice *price = [[UberPrice alloc] initWithDictionary:[prices objectAtIndex:i]];
                 if(price.lowEstimate > -1)
                 {
                     [availablePrices addObject:price];
                 }
             }
             completion(availablePrices, response, error);
         }
         else
         {
             NSLog(@"Error %@", error);
             completion(nil, response, error);
         }
     }];
}


+ (void) getTimeForProductArrivalWithLocation:(CLLocation *)location withCompletionHandler:(CompletionHandler)completion
{
    //GET /v1/estimates/time
    
    NSString *url = [NSString stringWithFormat:@"%@/estimates/time?server_token=%@&start_latitude=%f&start_longitude=%f", baseURL, ServerId, location.coordinate.latitude, location.coordinate.longitude];
    [UberAPI requestProductMessageWithURL:url completionHandler:^(NSDictionary *results, NSURLResponse *response, NSError *error)
     {
         if(!error)
         {
             NSArray *times = [results objectForKey:@"times"];
             NSMutableArray *availableTimes = [[NSMutableArray alloc] init];
             for(int i=0; i<times.count; i++)
             {
                 UberTime *time = [[UberTime alloc] initWithDictionary:[times objectAtIndex:i]];
                 [availableTimes addObject:time];
             }
             completion(availableTimes, response, error);
         }
         else
         {
             NSLog(@"Error %@", error);
             completion(nil, response, error);
         }
     }];
}

#pragma mark - 请求基类
+ (void) requestProductMessageWithURL:(NSString *)url completionHandler:(void (^)(NSDictionary *, NSURLResponse *, NSError *))completion
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            NSError *jsonError = nil;
            NSDictionary *serializedResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError == nil) {
                completion(serializedResults, response, jsonError);
            } else {
                NSHTTPURLResponse *convertedResponse = (NSHTTPURLResponse *)response;
                completion(nil, convertedResponse, jsonError);
            }
        }
        else
        {
            NSHTTPURLResponse *convertedResponse = (NSHTTPURLResponse *)response;
            completion(nil, convertedResponse, error);
        }
    }] resume];
}

@end
