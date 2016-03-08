//
//  ServiceHandler.m
//  CurrencyConvertor
//
//  Created by Anusha Patil on 28/02/16.
//  Copyright © 2016 Anusha Patil. All rights reserved.
//

#import "ServiceHandler.h"
#import "Constants.h"

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

#pragma mark REST Service methods

- (void)hitRESTServerWithRequest:(NSMutableURLRequest *)request
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error == nil)
        {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"Data = %@",jsonDict);
            [self.delegate handlerResponseDictForRest:jsonDict];
            
        }
    }];
    [sessionDataTask resume];
}

//Rest Get Method

- (void)formGETRequestWithFromCurrency:(NSString *)fromCurrency ToCurrency:(NSString *)toCurrency
{
    __unused NSString *urlString = [NSString stringWithFormat:@"%@/CurrencyConvertor.asmx/ConversionRate?FromCurrency=%@&ToCurrency=%@",HOST_NAME,fromCurrency,toCurrency];
    NSURL *url = [NSURL  URLWithString:[NSString stringWithFormat:@"http://api.fixer.io/latest?base=%@&symbols=%@",fromCurrency,toCurrency]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:HTTP_GET];

    [self hitRESTServerWithRequest:request];
}

//Rest Post Method
- (void)formPOSTRequestWithFromCurrency:(NSString *)fromCurrency ToCurrency:(NSString *)toCurrency
{
   __unused NSString *urlString = [NSString stringWithFormat:@"%@/CurrencyConvertor.asmx/ConversionRate",HOST_NAME];
    NSURL *url = [NSURL  URLWithString:@"http://api.fixer.io/latest"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"base='%@'&symbols='%@'",fromCurrency,toCurrency];
    
    [request setHTTPMethod:HTTP_POST];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self hitRESTServerWithRequest:request];
}

#pragma mark SOAP Service methods

- (void)hitSOAPServerWithRequest:(NSMutableURLRequest *)request
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error == nil)
        {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Data = %@",dataString);
            [self.delegate handlerResponseXmlForSoap:dataString];
            
        }
    }];
    [sessionDataTask resume];
}

- (void)workingWithSOAPServicesFromCurrency:(NSString *)fromCurrency toCurrency:(NSString *)toCurrency
{
    NSMutableURLRequest *request = nil;
    
     //SOAP 1.1
//    request = [self createSoapRequestFromCurrency:fromCurrency toCurrency:toCurrency];
    
    //SOAP 1.2
    request = [self createNewSoapRequestFromCurrency:fromCurrency toCurrency:toCurrency];

    [self hitSOAPServerWithRequest:request];
}

//SOAP 1.1

- (NSMutableURLRequest *)createSoapRequestFromCurrency:(NSString *)fromCurrency toCurrency:(NSString *)toCurrency
{
    //Create SOAP Message
    
    NSString *soapMeassage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                              "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                              "<soap:Body>"
                              "<ConversionRate xmlns=\"http://www.webserviceX.NET/\">"
                              "<FromCurrency>%@</FromCurrency>"
                              "<ToCurrency>%@</ToCurrency>"
                              "</ConversionRate>"
                              "</soap:Body>""</soap:Envelope>",fromCurrency,toCurrency];
    
    //Create request to the URL of web services
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/CurrencyConvertor.asmx",HOST_NAME]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *soapMsgLength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMeassage length]];
    
    [request addValue:[NSString stringWithFormat:@"%@",HOST_NAME] forHTTPHeaderField:@"HOST"];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:soapMsgLength forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"http://www.webserviceX.NET/ConversionRate" forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPMethod:HTTP_POST];
    [request setHTTPBody:[soapMeassage dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

//SOAP 1.2

- (NSMutableURLRequest *)createNewSoapRequestFromCurrency:(NSString *)fromCurrency toCurrency:(NSString *)toCurrency
{
    //Create SOAP Message
    
    NSString *soapMeassage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                              "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
                              "<soap12:Body>"
                              "<ConversionRate xmlns=\"http://www.webserviceX.NET/\">"
                              "<FromCurrency>%@</FromCurrency>"
                              "<ToCurrency>%@</ToCurrency>"
                              "</ConversionRate>"
                              "</soap12:Body>"
                              "</soap12:Envelope>",fromCurrency,toCurrency];
    
    //Create request to the URL of web services
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/CurrencyConvertor.asmx",HOST_NAME]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *soapMsgLength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMeassage length]];
    
    [request addValue:[NSString stringWithFormat:@"%@",HOST_NAME] forHTTPHeaderField:@"HOST"];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:soapMsgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:HTTP_POST];
    [request setHTTPBody:[soapMeassage dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}


@end
