//
//  BBSHessianEncoder.m
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

@interface BBSHessianEncoder (PrivateMethods) 

- (void) encodeNSObject:(NSObject *) anObject;
- (void) encodeNSObject:(NSObject *) anObject forKey:(NSString *) key;
- (void) encodeObject:(id) anyObject;
- (void) encodeNumber:(NSNumber *) aNumber;
- (void) encodeString:(NSString *) aString;
- (void) encodeBool:(BOOL) aBool;
- (void) encodeDate:(NSDate *) aDate;
- (void) encodeDouble:(double) aDouble;
- (void) encodeInt:(int) anInt;
- (void) encodeArray:(NSArray *) anArray;
- (void) encodeDictionary:(NSDictionary *) aDictionary;
- (void) encodeLongLong:(long long) aLongLong;
- (void) encodeNil;
- (void) encodeXml:(NSString *) anXmlString;
- (void) encodeType:(NSString *) aClassName;
- (void) encodeData:(NSData *) someData;
- (void) encodeBytes:(const uint8_t *)bytesp length:(unsigned)lenv;
@end



@implementation BBSHessianEncoder

static NSMutableDictionary * gClassMapping;

+ (void) initialize {
    gClassMapping = [[NSMutableDictionary dictionary] retain];
}

- (id) init {
    if((self = [super init]) != nil) {
        callData = [[NSMutableData data] retain];
       classMapping = [[NSMutableDictionary dictionary] retain];
    }
    return self;
}

- (id) initForWritingWithMutableData:(NSMutableData *)data {
    if((self = [super init]) != nil) {
        callData = [data retain];
    }
    return self;
}

+ (NSMutableData *) dataWithRootObject:(id) anyObject {
    BBSHessianEncoder * encoder = [[[BBSHessianEncoder alloc] init] autorelease];
    [encoder encodeObject:anyObject];
    return [encoder data];
}


- (NSMutableData *) data {
    return callData;
}

/** NSCoding support */
- (void) encodeBool:(BOOL) boolv forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeBool:boolv];
}

- (void) encodeBytes:(const uint8_t *) bytesp length:(unsigned)lenv forKey:(NSString *) key {    
    [self encodeString:key];
    [self encodeBytes:bytesp length:lenv];
}

- (void)encodeDouble:(double) realv forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeDouble:realv];
}

- (void)encodeFloat:(float) realv forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeDouble:realv];
}
 
- (void)encodeInt32:(int32_t) intv forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeInt:intv];
}
 
- (void)encodeInt64:(int64_t) intv forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeLongLong:intv];
}

- (void)encodeInt:(int) intv forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeInt:intv];
}

- (void)encodeObject:(id) objv forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeObject:objv];
}

- (void)setClassName:(NSString *) codedName forClass:(Class) cls {
    [classMapping setObject:codedName forKey:NSStringFromClass(cls)];
}

+ (void) setClassName:(NSString *) codedName forClass:(Class) cls {
    [gClassMapping setObject:codedName forKey:NSStringFromClass(cls)];
}

- (NSString *)classNameForClass:(Class) cls {
    return [classMapping objectForKey:NSStringFromClass(cls)];
}

+ (NSString *)classNameForClass:(Class) cls {
    return [gClassMapping objectForKey:NSStringFromClass(cls)];
}

+ (void) setClassNameMapping:(NSDictionary *) aMappingDictionary {
    [gClassMapping release];
    gClassMapping = [aMappingDictionary mutableCopy];
}

- (BOOL)allowsKeyedCoding {
    return YES;
}

- (void) dealloc {
    [callData release];
    callData = nil;
    [classMapping release];
    classMapping = nil;
    [super dealloc];
}

@end

@implementation BBSHessianEncoder (PrivateMethods)

- (void) encodeNSObject:(NSObject *) anObject {
    //For now we don't care about the type
    if([anObject conformsToProtocol:@protocol(NSCoding)]) {
        char M = 'M';
        [callData appendBytes:&M length:1];
        //TODO: ideally we'd want to place the classname even if there was no
        //mapping because the format is supposed to be cross-language. So if you
        //wanted to serialize and deserialize only in Objective-C you could
        //keep the type mappings intact. TODO: research a way to make it transparent
        //
        //check the instance mapping first
        NSString * className = [self classNameForClass:[anObject class]];
        if(!className) {
            //check global mappings
            className = [BBSHessianEncoder classNameForClass:[anObject class]];
        }
        //put the type in if a mapping exists
        if(className) {
            char t = 't';
            [callData appendBytes:&t length:1];
            unsigned short len = [className length];
            uint16_t biLen = CFSwapInt16HostToBig(len);
            [callData appendBytes:&biLen length:sizeof(biLen)];
            [callData appendBytes:[className UTF8String] length:len];
        }
        [(id<NSCoding>)anObject encodeWithCoder:self];
        char z = 'z';
        [callData appendBytes:&z length:1];
    }
    else {
        NSLog(@"attempting to encode an object that does not conform to NSCoding. %@", [anObject class]);
    }
}

- (void) encodeNSObject:(NSObject *) anObject forKey:(NSString *) key {
    [self encodeString:key];
    [self encodeNSObject:anObject];
}

- (void) encodeObject:(id) anyObject {
    //figure out what anyObject is and delegate to appropriate encode method
    if(anyObject == nil) {
        [self encodeNil];
        return;
    }
    Class objClass = [anyObject class];
    
    NSString * classString = NSStringFromClass(objClass);
    //TODO: research the posibilities of a more robust way of introspect class clusters
    if([classString isEqualToString:[[NSConstantString class] description]] ||
        [objClass isKindOfClass:[NSString class]] || 
        [classString isEqualToString:@"NSCFString"]) {
        [self encodeString:(NSString*)anyObject];
    }
    else if([classString isEqualToString:@"NSCFBoolean"]) {
        [self encodeBool:[anyObject boolValue]];
    }    
    else if([anyObject isKindOfClass:[NSNumber class]]) {
        [self encodeNumber:anyObject];
    }
    else if([objClass isKindOfClass:[NSValue class]] || 
            [classString isEqualToString:@"NSConcreteValue"]) {
    }
    else if([classString isEqualToString:@"NSCFDictionary"]) {
        [self encodeDictionary:anyObject];
    }
    else if([classString isEqualToString:@"NSCFDate"] || 
            [anyObject isKindOfClass:[NSCalendarDate class]]) {
        [self encodeDate:anyObject];
    }
    else  if([classString isEqualToString:@"NSCFArray"]) {
        [self encodeArray:anyObject];
    }    
    else if([classString isEqualToString:@"NSConcreteData"]) {
        [self encodeData:anyObject];
    }
    else {
        //otherwise treat it like a map, the Object has to support NSCoding protocol
        [self encodeNSObject:anyObject];
    }
}


- (void) encodeString:(NSString *) aString {   
    unsigned currentLen =  [aString length];   
    unsigned currentPos = 0;  
    char s = 's';
    char S = 'S';    
    while(currentLen > 0x8000) { /* 32768 or 0x8000 is the 16 bit length limit for a binary chunk */
        [callData appendBytes:&s length:1];
        uint16_t sLen = CFSwapInt16HostToBig(0x800);
        [callData appendBytes:&sLen length:sizeof(sLen)];
        //now add chunk        
        NSString * stringChunk = [aString substringWithRange:NSMakeRange(currentPos,0x8000)];
        [callData appendBytes:[stringChunk UTF8String] length:[stringChunk length]]; 
        currentPos += 0x8000;
        currentLen -= 0x8000;
    }    
    [callData appendBytes:&S length:1];
    uint16_t sLen = CFSwapInt16HostToBig(currentLen);
    [callData appendBytes:&sLen length:sizeof(sLen)];
    NSString * stringChunk = [aString substringWithRange:NSMakeRange(currentPos,currentLen)];  
    [callData appendBytes:[stringChunk UTF8String] length:[stringChunk length]];    
}

- (void) encodeNumber:(NSNumber *) aNumber {
    //what type of number is it?
    if(strcmp("i",[aNumber objCType]) == 0) {
        //it's an int
        [self encodeInt:[aNumber intValue]];
    }
    else if(strcmp("f",[aNumber objCType]) == 0) {
        [self encodeDouble:[aNumber doubleValue]];
    }
    else if(strcmp("d",[aNumber objCType]) == 0) {
        [self encodeDouble:[aNumber doubleValue]];
    }
    else if(strcmp("q",[aNumber objCType]) == 0) {
        [self encodeLongLong:[aNumber longLongValue]];
    }
}

- (void) encodeBool:(BOOL) aBool {
    char boolChar = aBool ? 'T' : 'F';
    //char B = 'B';
    //[callData appendBytes:&B length:1];
    [callData appendBytes:&boolChar length:1];
}

- (void) encodeDate:(NSDate *) aDate {   
    char d = 'd';
    [callData appendBytes:&d length:1];
    long long aLong = [aDate timeIntervalSince1970] * 1000;
    uint64_t bigDate = CFSwapInt64HostToBig(aLong) ;
    [callData appendBytes:&bigDate length:sizeof(bigDate)];
}

- (void) encodeDouble:(double) aDouble {   
    char d = 'D';
    [callData appendBytes:&d length:1];
    CFSwappedFloat64 bigEndian = CFConvertFloat64HostToSwapped(aDouble);
    [callData appendBytes:&bigEndian length:sizeof(bigEndian)];
}

- (void) encodeInt:(int) anInt {
    uint32_t biInt = CFSwapInt32HostToBig(anInt);
    char I = 'I';
    [callData appendBytes:&I length:1];
    [callData appendBytes:&biInt length:sizeof(biInt)];
}

- (void) encodeArray:(NSArray *) anArray {
    char V = 'V';
    [callData appendBytes:&V length:1];

    char l = 'l';
    [callData appendBytes:&l length:1];    
    uint32_t length =CFSwapInt32HostToBig(-1);   
    [callData appendBytes:&length length:sizeof(length)];
    
    NSEnumerator * e = [anArray objectEnumerator];
    id current;
    
    while(current = [e nextObject]) {
        [self encodeObject:current];
    }
    char z = 'z';
    [callData appendBytes:&z length:1];
}


- (void) encodeDictionary:(NSDictionary *) aDictionary {   
    id currentKey; 
    char M = 'M';
    [callData appendBytes:&M length:1];     
    NSEnumerator * e = [aDictionary keyEnumerator];
    while(currentKey = [e nextObject]) {
        //encode the properties name        
        [self encodeString:currentKey];
        [self encodeObject:[aDictionary objectForKey:currentKey]];        
    }
    char z = 'z';
    [callData appendBytes:&z length:1];
}

- (void) encodeLongLong:(long long) aLongLong {
    char L = 'L';
    [callData appendBytes:&L length:1];
    uint64_t biLongLong = CFSwapInt64HostToBig(aLongLong);
    [callData appendBytes:&biLongLong length:sizeof(biLongLong)];
}

- (void) encodeNil {
    char nilChar = 'N';
    [callData appendBytes:&nilChar length:1];
}

- (void) encodeXml:(NSString *) anXmlString {
    unsigned currentLen =  [anXmlString length];   
    unsigned currentPos = 0;  
    char x = 'x';
    char X = 'X';    
    while(currentLen > 0x8000) { /* 32768 or 0x8000 is the 16 bit length limit for a binary chunk */
        [callData appendBytes:&x length:1];
        uint16_t xLen = CFSwapInt16HostToBig(0x800);
        [callData appendBytes:&xLen length:sizeof(xLen)];
        //now add chunk        
        NSString * stringChunk = [anXmlString substringWithRange:NSMakeRange(currentPos,0x8000)];
        [callData appendBytes:[stringChunk UTF8String] length:[stringChunk length]]; 
        
        currentPos += 0x8000;
        currentLen -= 0x8000;
    }    
    [callData appendBytes:&X length:1];
    uint16_t xLen = CFSwapInt16HostToBig(0x800);
    [callData appendBytes:&xLen length:sizeof(xLen)];
    NSString * stringChunk = [anXmlString substringWithRange:NSMakeRange(currentPos,currentLen)];
    [callData appendBytes:[stringChunk UTF8String] length:[stringChunk length]]; 
}

- (void) encodeType:(NSString *) aClassName {
    unsigned short len = [aClassName length];
    uint16_t biLen = CFSwapInt16HostToBig(len);   
    char S = 't';
    [callData appendBytes:&S length:1];
    [callData appendBytes:&biLen length:sizeof(biLen)];
    [callData appendBytes:[aClassName UTF8String] length:len]; 
}

- (void) encodeData:(NSData *) someData {
    unsigned currentLen = [someData length];   
    unsigned currentPos = 0;  
    char b = 'b';
    char B = 'B';
    
    while(currentLen > 0x8000) { /* 32768 or 0x8000 is the 16 bit length limit for a binary chunk */
        [callData appendBytes:&b length:1];
        uint16_t xLen = CFSwapInt16HostToBig(0x800);
        [callData appendBytes:&xLen length:sizeof(xLen)];
        //now add chunk        
        NSData * dataChunk = [someData subdataWithRange:NSMakeRange(currentPos,0x8000)];
        [callData appendBytes:[dataChunk bytes] length:[dataChunk length]];
        currentPos += 0x8000;
        currentLen -= 0x8000;
    }    
    [callData appendBytes:&B length:1];
    uint16_t biLen = CFSwapInt16HostToBig(currentLen);
    [callData appendBytes:&biLen length:sizeof(biLen)];
    NSData * dataChunk = [someData subdataWithRange:NSMakeRange(currentPos,currentLen)];
    [callData appendBytes:[dataChunk bytes] length:[dataChunk length]];
}

- (void) encodeBytes:(const uint8_t *) bytesp length:(unsigned)lenv {
    [self encodeData:[NSData dataWithBytes:bytesp length:lenv]];
}

@end
