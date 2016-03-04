//
//  ServiceHandler.h
//  CurrencyConvertor
//
//  Created by Anusha Patil on 28/02/16.
//  Copyright © 2016 Anusha Patil. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServiceHandlerDelegate <NSObject>

- (void)handlerResponseDictForRest:(NSDictionary *)jsonDict;
- (void)handlerResponseXmlForSoap:(NSString *)xmlData;

@end

@interface ServiceHandler : NSObject

@property (nonatomic, assign)id<ServiceHandlerDelegate> delegate;

+ (id)sharedManager;

//REST services
- (void)formGETRequestWithFromCurrency:(NSString *)fromCurrency ToCurrency:(NSString *)toCurrency;
- (void)formPOSTRequestWithFromCurrency:(NSString *)fromCurrency ToCurrency:(NSString *)toCurrency;

//SOAP services
- (void)workingWithSOAPServicesFromCurrency:(NSString *)fromCurrency toCurrency:(NSString *)toCurrency;

@end
