//
//  BBSHessianCall.m
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

#import <HessianObjC/BBSHessianEncoder.h>
#import <HessianObjC/BBSHessianCall.h>

@interface BBSHessianCall (PrivateMethods) 

- (void) startCall;

- (void) endCall;

@end

@implementation BBSHessianCall

- (id) initWithRemoteMethodName:(NSString *) aMethodName {
    if((self = [super init]) != nil) {        
        //[self setServiceUrl:aServiceUrl];
        //WARN: this should never happen but because
        //we are converting a 32 bit value -> 16 bit
        //the method name cannot be extremely long            
        methodName = [aMethodName retain];              
    }
    return self;
}

- (void) setParameters: (NSArray *) someParameters {
    [someParameters retain];
    [parameters release];
    parameters = someParameters;
}


- (NSData *) data {
    //lazy create the data
    if(!callData) {   
        callData = [[NSMutableData data] retain];    
        [self startCall];
        NSEnumerator * e = [parameters objectEnumerator];
        id current ;
        while(current = [e nextObject]) {
            [callData appendData:[BBSHessianEncoder dataWithRootObject:current]];
        }
        [self endCall];
    }    
    return callData;    
}

- (NSString *) methodName {
    return methodName;
}

- (void) dealloc {
    [callData release];
    callData = nil;  
    [super dealloc];
}
@end

@implementation BBSHessianCall (PrivateMethods) 
- (void) startCall {
    char call = 'c';
    char char1 = 0x01;
    char char0 = 0x00;
    char m = 'm';
    
    [callData appendBytes:&call length:1];    
    [callData appendBytes:&char1 length:1];
    [callData appendBytes:&char0 length:1];
    [callData appendBytes:&m length:1];
    
    unsigned short len = [methodName length];
    UInt16 biLen = EndianU16_NtoB(len);
    [callData appendBytes:&biLen length:sizeof(biLen)];
    [callData appendBytes:[methodName UTF8String] length:len];  
}



- (void) endCall {
    char z = 'z';
    [callData appendBytes:&z length:1];
}
@end
