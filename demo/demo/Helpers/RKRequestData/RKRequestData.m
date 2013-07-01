//
//  RKRequestData.m
//  idbox
//
//  Created by MacMini on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RKRequestData.h"
#import "Constants.h"
#import "NSString+URLEncoding.h"
#import "AppDelegate.h"

@implementation RKRequestData

@synthesize parsingType;
@synthesize requestType;
@synthesize request;
@synthesize type;
@synthesize url;
@synthesize requestValues;
@synthesize delegate;
@synthesize aSynchronous;
@synthesize serverURL;
@synthesize script;
@synthesize requestid;

- (void) dealloc
{
    [requestid release];
    [serverURL release];
    [script release];
    [parsingType release];
    [requestType release];
    [url release];
    [requestValues release];
    [super dealloc];
}

- (void) requestStart
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    if (!requestValues)
    {
        requestValues = [[NSMutableDictionary alloc] init];
    }
    // Add standard key values to requests to own server
    
    if (serverURL.length > 0 && script.length > 0)
    {        
        [requestValues setValue:[CLIENT lowercaseString] forKey:@"client"];
        [requestValues setValue:[PARSING_XML lowercaseString] forKey:@"format"];

        [requestValues setValue:[[defaults valueForKey:IOS_VERSION] lowercaseString] forKey:@"os"];
        [requestValues setValue:[[defaults valueForKey:LANGUAGE] lowercaseString] forKey:@"language"];
        [requestValues setValue:[[defaults valueForKey:PHONELANGUAGE] lowercaseString] forKey:@"phonelanguage"];
        [requestValues setValue:[[defaults valueForKey:PHONEID] lowercaseString] forKey:@"phoneid"];
        [requestValues setValue:[[defaults valueForKey:APP_VERSION] lowercaseString] forKey:@"appvs"];
        [requestValues setValue:[[defaults valueForKey:SANDBOX] lowercaseString] forKey:@"sandbox"];
        [requestValues setValue:[NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]] forKey:@"systemtime"];
        
        /*
        if ([User defaultUser].userID.length > 0) {            
            [requestValues setValue:[User defaultUser].userID forKey:@"userid"];
        }
         */
        
        url = [NSString stringWithFormat:@"%@/%@%@", serverURL, script, url];
    }
    
    if ([requestType isEqualToString:REQUEST_GET]) 
    {
//        NSLog(@"GET Request");
        NSArray *postValuesKeys = [requestValues allKeys];
        for (int i = 0; i < [requestValues count]; i++) 
        {
            NSString *key = [postValuesKeys objectAtIndex:i];
            NSString *value = [requestValues objectForKey:key];

            url = [url stringByAppendingFormat:@"&%@=%@", [key urlEncodeUsingEncoding:NSUTF8StringEncoding], [value urlEncodeUsingEncoding:NSUTF8StringEncoding]];
        }
        DLog(@"url-get: %@", url);
        
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    }
    else if ([requestType isEqualToString:REQUEST_POST])
    {
        request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        NSArray *postValuesKeys = [requestValues allKeys];
        for (int i = 0; i < postValuesKeys.count ; i++)
        {
            NSString *key = [postValuesKeys objectAtIndex:i];
            NSString *value = [requestValues objectForKey:key];
//            NSLog(@"key %@ - value %@", key, value);
            [request setPostValue:value forKey:key];
        }
        DLog(@"url-post: %@", url);
        
    }
//    [requestValues release];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    
    if (aSynchronous)
    {
        [request startAsynchronous];
    }
    else
    {
        [request startSynchronous];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)Request
{
    if ([self.parsingType isEqualToString:PARSING_JSON]) 
    {
        // Use when fetching text data for JSON parsing
        if ([requestType isEqualToString:REQUEST_GET]) 
        {
            if ([[Request responseString] length] > 0) 
            {
                [self parseJSON:[Request responseString]];
            }
            
        } else if ([requestType isEqualToString:REQUEST_POST])
        {
            if ([[Request responseString] length] > 0) 
            {
                [self parseJSON:[Request responseString]];
            }
        }
    }   
    
    else if ([self.parsingType isEqualToString:PARSING_XML]) 
    {
        // Use when fetching binary data for XML parsing
        NSData *responseData = [Request responseData];
        [self parseXML:responseData];
    }
    
}


- (void) parseJSON:(NSString *)responseString
{
    if ([responseString length] > 0)
    {
        [Networking parseResponseJSON:responseString forRequest:self];
    }
}

- (void) parseXML:(NSData *)responseData
{
    if (responseData)
    {
        [Networking parseResponseXML:responseData forRequest:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)Request
{
    // Remove request from Networking object
    [[Networking sharedManager].requestsDictionary removeObjectForKey:requestid];
    
    NSError *error = [Request error];
    DLog(@"Error: %i, %@", error.code, error.description);
    
    switch (error.code)
    {            
        case 1:
        {
            // network failure
            if(delegate && [self.delegate respondsToSelector:@selector(handleError:fromRequest:)])
            {
                //send the delegate function with the amount entered by the user
                [delegate handleError:error fromRequest:self];
            }
            break;
        }
        case 2:
        {
            // request timed out
            if(delegate && [self.delegate respondsToSelector:@selector(handleError:fromRequest:)])
            {
                //send the delegate function with the amount entered by the user
                [delegate handleError:error fromRequest:self];
            }
            break;
        }
        case 4:
        {
            // canceled
            if(delegate && [self.delegate respondsToSelector:@selector(handleError:fromRequest:)])
            {
                //send the delegate function with the amount entered by the user
                [delegate handleError:error fromRequest:self];
            }
            break;
        }
        case 5:
        {
            // bad request
            if(delegate && [self.delegate respondsToSelector:@selector(handleError:fromRequest:)])
            {
                //send the delegate function with the amount entered by the user
                [delegate handleError:error fromRequest:self];
            }
            break;
        }
        default:
            break;
    }   
}

@end
