//
//  ServiceHandler.m
//  CurrencyConvertor
//
//  Created by Anusha Patil on 28/02/16.
//  Copyright © 2016 Anusha Patil. All rights reserved.
//

#import "ServiceHandler.h"
#define HOST_NAME @"http://www.webservicex.net"

@implementation ServiceHandler


+ (id)sharedManager
{
    static ServiceHandler *serviceHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceHandler = [[self alloc] init];
    });
    return serviceHandler;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)formGETRequestWithFromCurrency:(NSString *)fromCurrency ToCurrency:(NSString *)toCurrency
{
    __unused NSString *urlString = [NSString stringWithFormat:@"%@/CurrencyConvertor.asmx/ConversionRate?FromCurrency=%@&ToCurrency=%@",HOST_NAME,fromCurrency,toCurrency];
    NSURL *url = [NSURL  URLWithString:[NSString stringWithFormat:@"http://api.fixer.io/latest?base=%@&symbols=%@",fromCurrency,toCurrency]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error == nil)
        {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"Data = %@",jsonDict);
            [self.delegate responseHandlerResponseDict:jsonDict];
            
        }
    }];
    [sessionDataTask resume];
}

- (void)formPOSTRequestWithFromCurrency:(NSString *)fromCurrency ToCurrency:(NSString *)toCurrency
{
   __unused NSString *urlString = [NSString stringWithFormat:@"%@/CurrencyConvertor.asmx/ConversionRate",HOST_NAME];
    NSURL *url = [NSURL  URLWithString:@"http://api.fixer.io/latest"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"base='%@'&symbols='%@'",fromCurrency,toCurrency];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error == nil)
        {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"Data = %@",jsonDict);
            
            [self.delegate responseHandlerResponseDict:jsonDict];
        }
    }];
    [sessionDataTask resume];
}

@end
