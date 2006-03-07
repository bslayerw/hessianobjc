//
//  HessianProxy.m
//  HessianObjC

// Copyright Byron Wright, Blue Bear Studio
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. 
// You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
//  
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <HessianObjC/BBSHessianProxy.h>
#import <HessianObjC/BBSHessianCall.h>
#import <HessianObjC/BBSHessianResult.h>
#import <HessianObjC/BBSHessianEncoder.h>
#import <HessianObjC/BBSHessianDecoder.h>
#import <HessianObjC/BBSHessianInvocation.h>

@implementation BBSHessianProxy

- (id) initWithUrl:(NSURL * ) aServiceUrl {
    if((self = [super init]) != nil) {
        [self setServiceUrl:aServiceUrl];
    }
    return self;
}

- (NSURL *) serviceUrl {
    return serviceUrl; 
}

- (void) setServiceUrl: (NSURL *) aServiceUrl {
    [aServiceUrl retain];
    [serviceUrl release];
    serviceUrl = aServiceUrl;
}

- (id) callSynchronous:(NSString *) methodName
        withParameters:(NSArray *) parameters {
    
    BBSHessianCall * hessianRequest = [[[BBSHessianCall alloc] initWithRemoteMethodName:methodName] autorelease];
    
    [hessianRequest setParameters:parameters];
    
    NSMutableURLRequest * request = [[[NSMutableURLRequest alloc] initWithURL:[self serviceUrl]
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                             timeoutInterval:60.0] autorelease];
    //add all the paramters to the data
    [request setHTTPMethod:@"POST"];
   
    [request setHTTPBody:[hessianRequest data]];
    //force this header field to be text/xml... Tomcat 4 blows up otherwise
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    NSHTTPURLResponse * returnResponse = nil; 
    
    NSError * requestError = nil;
    NSData * retData = [NSURLConnection sendSynchronousRequest:request 
                                             returningResponse:&returnResponse
                                                         error:&requestError];  
    
    if(requestError == nil) {
        if(returnResponse != nil) {
            if([returnResponse statusCode] == 200) { /* all went well */
                //deserialize the data
                BBSHessianResult * response = [[[BBSHessianResult alloc] initForReadingWithData:retData] autorelease];
                id decodedObject = [response resultValue];
                return decodedObject;
                
            }        
            else {
                //create an exception poo poo response from server here
                NSLog(@"request failed with code [%i] because [%@]",[returnResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[returnResponse statusCode]]);
            }
        }
        else {
            NSLog(@"return response is nil");
        }
    }
    else {
        NSLog(@"failed = %@",requestError);        
    }

    return nil;
}

- (void) callWithInvocation:(BBSHessianInvocation *) anInvocation {

    NSMutableURLRequest * request = [[[NSMutableURLRequest alloc] initWithURL:[self serviceUrl]
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                             timeoutInterval:60.0] autorelease];
    //add all the paramters to the data

    [request setHTTPMethod:@"POST"];
   
    [request setHTTPBody:[anInvocation callData]];
    //force this header field to be text/xml... Tomcat 4 blows up otherwise
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
       
    remoteConnection = [[NSURLConnection alloc] initWithRequest:request delegate:anInvocation];
    if(!remoteConnection) {    
        //call target and selector of invocation with an error
    }
}



+ (void) setClassMapping:(NSDictionary *) classMapping { 
    NSMutableDictionary * decoderMapping = [NSMutableDictionary dictionary];
    NSEnumerator * e = [classMapping keyEnumerator];
    id current;
    //this basiclly switches the key value pairs around for the decoder mapping
    while(current = [e nextObject]) {
        id value = [classMapping objectForKey:current];
        [decoderMapping setObject:current forKey:value];
    }
    [BBSHessianEncoder setClassNameMapping:classMapping];
    [BBSHessianDecoder setClassNameMapping:decoderMapping];
}

+ (void) setEncoderClassMapping:(NSDictionary *) encoderMapping {
    [BBSHessianEncoder setClassNameMapping:encoderMapping];

}
+ (void) setDecoderClassMapping:(NSDictionary *) decoderMapping {
    [BBSHessianDecoder setClassNameMapping:decoderMapping];
}



- (void) dealloc {
    [self setServiceUrl: nil];
    [super dealloc];
}


@end
