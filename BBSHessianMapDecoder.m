//
//  BBSHessianMapDecoder.m
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

#import <HessianObjC/BBSHessianMapDecoder.h>

@implementation BBSHessianMapDecoder

- (id) initForReadingWithDictionary:(NSDictionary *) aHessianMap {
    if((self = [super init]) != nil) {
        [aHessianMap retain];
        [hessianMap release];
        hessianMap = aHessianMap;
    }
    return self;
}

- (BOOL) decodeBoolForKey:(NSString *) key {
    id obj = [hessianMap objectForKey:key];
    if([obj isKindOfClass:[NSNumber class]]) {
        return [obj boolValue];
    }
    else {
        NSLog(@"excepted an NSNumber");
    }
    return NO;
}
//TODO:implement
- (const uint8_t *) decodeBytesForKey:(NSString *) key returnedLength:(unsigned *) lengthp {
    NSLog(@"TODO:implement this method BBSHessianMapDecoder:- (const uint8_t *) decodeBytesForKey:(NSString *) key returnedLength:(unsigned *) lengthp");
    *lengthp = 0;
    return NULL;    
}

- (double) decodeDoubleForKey:(NSString *) key {
    id obj = [hessianMap objectForKey:key];
    if([obj isKindOfClass:[NSNumber class]]) {
        return [obj doubleValue];
    }
    else {
        NSLog(@"excepted an NSNumber");
    }
    return 0.0;
}

- (float) decodeFloatForKey:(NSString *) key {
    id obj = [hessianMap objectForKey:key];
    if([obj isKindOfClass:[NSNumber class]]) {
        return [obj floatValue];
    }
    else {
        NSLog(@"excepted an NSNumber");
    }
    return 0.0f;
}

- (int32_t) decodeInt32ForKey:(NSString *) key {
    id obj = [hessianMap objectForKey:key];
    if([obj isKindOfClass:[NSNumber class]]) {
        return [obj intValue];
    }
    else {
        NSLog(@"excepted an NSNumber");
    }
    return 0;
}

- (int64_t) decodeInt64ForKey:(NSString *) key {
    id obj = [hessianMap objectForKey:key];
    if([obj isKindOfClass:[NSNumber class]]) {
        return [obj longLongValue];
    }
    else {
        NSLog(@"excepted an NSNumber");
    }
    return 0;
}

- (int) decodeIntForKey:(NSString *) key {
    id obj = [hessianMap objectForKey:key];
    if([obj isKindOfClass:[NSNumber class]]) {
        return [obj intValue];
    }
    else {
        NSLog(@"excepted an NSNumber");
    }
    return 0;
}

- (id)decodeObjectForKey:(NSString *) key {
    return [hessianMap objectForKey:key];
}



- (void) dealloc {
    [hessianMap release];
    hessianMap = nil;
    [super dealloc];
}
@end
