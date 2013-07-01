//
//  Networking.m
//  idbox
//
//  Created by Mona Mouteirek on 8/13/12.
//  Copyright (c) 2012 FOO_. All rights reserved.
//

#import "Networking.h"
#import "AppDelegate.h"
#import "Constants.h"

static Networking *sharedManager = nil;

@interface Networking () <RequestDataDelegate, UIAlertViewDelegate>
{
    AppDelegate *app;
}
@end

@implementation Networking

@synthesize requestsDictionary;

+ (Networking *) sharedManager
{
    //    NSLog(@"default user");
	if (sharedManager == nil)
    {
        //        NSLog(@"default user nil");
        sharedManager = [[Networking alloc] init];
        sharedManager.requestsDictionary = [[NSMutableDictionary alloc] init];
	}
	return sharedManager;
}

- (void) configureTimeout:(NSInteger)ttl ForScript:(NSString *)script
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    NSInteger future = ttl + now;
    [defaults setInteger:future forKey:script];
    [defaults synchronize];
}

- (NSString *) createIDForRequest:(RKRequestData *)request
{
    NSString *requestid = [[NSProcessInfo processInfo] globallyUniqueString];
    if (request.request)
    {
        [requestsDictionary setObject:request.request forKey:requestid];
    }
    return requestid;
}

- (void) cancelForRequestID:(NSString *)requestid
{
    if ([[self.requestsDictionary allKeys] containsObject:requestid])
    {
        ASIFormDataRequest *request = [self.requestsDictionary objectForKey:requestid];
        DLog(@"cancel: %@", requestid);
        [request cancel];
        [self.requestsDictionary removeObjectForKey:requestid];
    }
}


- (NSString *) sendNetworkRequestWithDelegate:(id<NetworkingDelegate>)delegate
{        
    NSString *url = [NSString stringWithFormat:@".php?"
                     
                     ];
    
	RKRequestData *requestData = [[RKRequestData alloc] init];
    requestData.url = url;
    requestData.serverURL = SERVER_URL;
    requestData.script = SAMPLE_SCRIPT;
    requestData.delegate = delegate;
    requestData.parsingType = PARSING_XML;
    requestData.requestType = REQUEST_GET;
    requestData.type = NetworkSampleRequest;
    requestData.aSynchronous = YES;
    requestData.requestid = [self createIDForRequest:requestData];
	[requestData requestStart];
    
    return requestData.requestid;
}

+ (void) configureTimeout:(NSInteger)ttl ForScript:(NSString *)script
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    NSInteger future = ttl + now;
    [defaults setInteger:future forKey:script];
    [defaults synchronize];
}

+ (void)parseResponseXML:(NSData *)responseData forRequest:(RKRequestData *)request
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SMXMLDocument *document = [[SMXMLDocument alloc] initWithData:responseData error:nil];
    
    SMXMLElement *rootElement = [document root];
    
    NSString *status = [[rootElement valueWithPath:@"status"] uppercaseString];
    BOOL success = [status isEqualToString:status];
    NSString *messagetitle = [rootElement valueWithPath:@"messagetitle"];
    NSString *message = [rootElement valueWithPath:@"message"];
    BOOL show = [[rootElement valueWithPath:@"show"] boolValue];  
    
    if (show)
    {
        [app displayAlertView:message WithTitle:messagetitle AndCancelTitle:NSLocalizedString(@"ok", nil) OtherButtonTitle:nil fromDelegate:nil];
    }
    
    if (request.delegate)
    {
        NSDictionary *responseDict = nil;
        switch (request.type)
        {
           case NetworkSampleRequest:
            {
                responseDict = [self parseNetworkSampleResponse:responseData];
                break;
            }
            default:
                break;
        }
        if ([request.delegate respondsToSelector:@selector(receivedResponseSuccess:responseDict:RequestType:)])
        {
            [request.delegate receivedResponseSuccess:success responseDict:responseDict RequestType:request.type];
        }

    }
    [[Networking sharedManager].requestsDictionary removeObjectForKey:request.requestid];
}

+ (void) parseResponseJSON:(NSString *)responseString forRequest:(RKRequestData *)request
{

//	NSLog(@"request.type:%d",request.type);
    switch (request.type)
    {
        default:
			break;
    }
    [[Networking sharedManager].requestsDictionary removeObjectForKey:request.requestid];
}


+ (NSDictionary *) parseNetworkSampleResponse:(NSData *)responseData
{    
    SMXMLDocument *document = [[SMXMLDocument alloc] initWithData:responseData error:nil];
    
    SMXMLElement *rootElement = [document root];
        
    // Parse response  
    
    [document release];
    return nil; // return dictoinary
}

@end