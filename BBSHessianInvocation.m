//
//  BBSHessianInvocation.m
//  HessianObjC
//
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
#import <HessianObjC/BBSHessianInvocation.h>
#import <HessianObjC/BBSHessianCall.h>
#import <HessianObjC/BBSHessianResult.h>

@implementation BBSHessianInvocation

- (id) initWithCall:(BBSHessianCall *) aCall
     callbackTarget:(id) aTarget
   callbackSelector:(SEL) aSelector {
    if((self = [super init]) != nil) {     
        call = [aCall retain];
        callbackTarget = [aTarget retain];
        callbackSelector = aSelector;
    }
    return self;
}

- (NSString *) methodName {
    return [call methodName];
}

- (NSData *) callData {
    return [call data];
}

- (id) callbackTarget {
    return callbackTarget;
}

- (SEL) callbackSelector {
    return callbackSelector;
}

- (void)connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) response {
    #pragma unused(connection,response)
    if(!asynchResponseData) {
        asynchResponseData = [[NSMutableData data] retain];
    }
    else {
        [asynchResponseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *) data {
    #pragma unused(connection)
    [asynchResponseData appendData:data];
}

- (void)connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
    [connection release];
    [asynchResponseData release];
    if(callbackTarget) {
        if([callbackTarget respondsToSelector:callbackSelector]) {
            [callbackTarget performSelector:callbackSelector withObject:error];
        }
        else {
            NSAssert1(NO,@"callbackTarget does not response to selector %@",NSStringFromSelector(callbackSelector));
        }
    }
    else {
        NSLog(@"error occured but not callback target is specified");
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *) connection {
    [connection release];
    BBSHessianResult * response = [[[BBSHessianResult alloc] initForReadingWithData:asynchResponseData] autorelease];
    id decodedObject = [response resultValue];
    if(callbackTarget) {
        if([callbackTarget respondsToSelector:callbackSelector]) {
            [callbackTarget performSelector:callbackSelector withObject:decodedObject];
        }
        else {
            NSAssert1(NO,@"callbackTarget does not response to selector %@",NSStringFromSelector(callbackSelector));
        }
    }
    else {
        NSLog(@"completed request but not callback target is specified");
        
    }
    [asynchResponseData release];
}

-(NSURLRequest *)connection:(NSURLConnection *) connection 
            willSendRequest:(NSURLRequest *) request
           redirectResponse:(NSURLResponse *) redirectResponse {
    #pragma unused(connection)
    NSURLRequest *newRequest=request;
    if (redirectResponse) {
        newRequest=nil;
    }
    return newRequest;
}


- (void) dealloc {
    [call release];
    call = nil;
    [callbackTarget release];
    callbackTarget = nil;
    [super dealloc];
}

@end
