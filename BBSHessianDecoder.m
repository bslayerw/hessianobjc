//
//  BBSHessianDecoder.m
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
#import <HessianObjC/BBSHessianObjCDefines.h>
#import <HessianObjC/BBSHessianDecoder.h>
#import <HessianObjC/BBSHessianMapDecoder.h>

@interface BBSHessianDecoder (PrivateMethods) 

- (id) decodeObject;
- (id) decodeObjectForCode:(uint8_t) code;
/** utility function to read the length of a string  */
- (int) decodeStringLength;
- (NSString *) decodeXml:(uint8_t) startCode;
- (NSString *) decodeString:(uint8_t) startCode;
- (NSString *) decodeStringChunk;
- (NSNumber *) decodeInt;
- (NSDictionary *) decodeMap;
- (NSArray * ) decodeList;
- (NSNumber *) decodeLong;
- (NSNumber *) decodeDouble;
- (NSDate *) decodeDate;
- (NSData *) decodeByteChunks;
- (NSData *) decodeBytes;
- (NSError *) decodeFault;
- (NSNumber *) decodeRef;

@end

@implementation BBSHessianDecoder

static NSMutableDictionary * gClassMapping;

+ (void) initialize {
    gClassMapping = [[NSMutableDictionary dictionary] retain];
}

- (id) init {
    if((self = [super init]) != nil) {
        classMapping = [[NSMutableDictionary dictionary] retain];
    }
    return self;
}

+ (id) decodedObjectWithData:(NSData *) someData {
    BBSHessianDecoder * decoder = [[[BBSHessianDecoder alloc] 
                                    initForReadingWithData:someData] autorelease];
    return [decoder decodedObject];
}


- (id) initForReadingWithData:(NSData *) someData {
    if((self = [self init]) != nil) {
        dataInputStream = [[NSInputStream inputStreamWithData:someData] retain];
        [dataInputStream open];
    }
    return self;
}

- (id) decodedObject {
    id obj = nil;
    obj = [self decodeObject];
    //if it's a map and has a mapping associated with it then try 
    //and instiate it's class. The class needs to be in the runtime
    if([obj isKindOfClass:[NSDictionary class]]) {
        Class objClass = NSClassFromString([obj objectForKey:BBSHessianClassNameKey]);
        if(objClass) { 
            BBSHessianMapDecoder * mapDecoder = [[[BBSHessianMapDecoder alloc] initForReadingWithDictionary:obj] autorelease];
            return [[[objClass alloc] initWithCoder:mapDecoder] autorelease];
        }
    }    
    return obj;
}

- (void) setClass:(Class) cls forClassName:(NSString *) codedName {
    [classMapping setObject:NSStringFromClass(cls) forKey:codedName];
}

+ (void) setClass:(Class) cls forClassName:(NSString *) codedName {
    [gClassMapping setObject:NSStringFromClass(cls) forKey:codedName];
}

- (Class) classForClassName:(NSString *) codedName {
    return NSClassFromString([classMapping objectForKey:codedName]);
}

+ (Class) classForClassName:(NSString *) codedName {
    return NSClassFromString([gClassMapping objectForKey:codedName]);
}

+ (void) setClassNameMapping:(NSDictionary *) aMappingDictionary {
    [gClassMapping release];
    gClassMapping = [aMappingDictionary mutableCopy];
}

- (void) dealloc {
    [classMapping release];    
    classMapping = nil;
    [dataInputStream release];
    dataInputStream = nil;
    [super dealloc];
}
@end

@implementation BBSHessianDecoder (PrivateMethods) 

- (id) decodeObject {
    uint8_t objectTag = 'e';
    id obj = nil;
    if([dataInputStream hasBytesAvailable]) {    
       [dataInputStream read:&objectTag maxLength:1];      
       return [self decodeObjectForCode:objectTag];
    }
    else {
        NSLog(@"no data available");
    }
    return obj;
}

- (id) decodeObjectForCode:(uint8_t) code {
    id obj = nil;

    switch(code) {
        case 'b': obj = [self decodeByteChunks];break;
        case 'B': obj = [self decodeBytes];break;
        case 'T': obj = [NSNumber numberWithBool:YES];break;
        case 'F': obj = [NSNumber numberWithBool:NO];break;
        case 'd': obj = [self decodeDate];break;
        case 'D': obj = [self decodeDouble];break;
        case 'f': obj = [self decodeFault] ; break;
        case 'I': obj = [self decodeInt]; break;
        case 'V': obj = [self decodeList]; break;
        case 'L': obj = [self decodeLong] ;break;
        case 'M': obj = [self decodeMap]; break;
        case 'N': obj = nil ;break;
        case 'R': obj = [self decodeRef];break;
        case 's': obj = [self decodeString:'s'];break;
        case 'S': obj = [self decodeString:'S'];break;
        case 'x': obj = [self decodeXml:'x'];break;
        case 'X': obj = [self decodeXml:'X'];break;
        default: NSLog(@"unknown data type returned from hessian service");
    }
    
    return obj;
}

- (NSString *) decodeXml:(uint8_t) startCode {
    NSMutableString * xmlString = [NSMutableString string];
    while(startCode == 'x') { //decode chunks
        [xmlString appendString:[self decodeStringChunk]];
        [dataInputStream read:&startCode maxLength:1]; 
    }
    if(startCode == 'X') {
        [xmlString appendString:[self decodeStringChunk]];
    }
    else {
        NSLog(@"expected 'X' for last xml chunk");        
    }
    return xmlString;
}

- (NSString *) decodeStringChunk {
    int len = [self decodeStringLength];
    if(len == 0) {
        return @"";
    }
    //alloc enough memory for the string +1 for null terminator
    uint8_t * readData = malloc((len+1) * sizeof(uint8_t));      
    if(readData == NULL) {
       NSLog(@"failed to alloc memory for string with len =%i",len);
       return @"";
    }  
    //set all to null.
    memset(readData,0,len+1);        
    [dataInputStream read:readData maxLength:len]; 
    NSString * retString = [NSString stringWithUTF8String:(const char *)readData] ;
    free(readData);
    return retString;
}

- (NSString *) decodeString:(uint8_t) startCode {
    
    NSMutableString * retString = [NSMutableString string];
    while(startCode == 's') { //decode chunks
        [retString appendString:[self decodeStringChunk]];
        [dataInputStream read:&startCode maxLength:1]; 
    }
    if(startCode == 'S') {
        [retString appendString:[self decodeStringChunk]];
    }
    else {
        NSLog(@"expected 'S' for last string chunk");        
    }
    return retString;
}

- (NSNumber *) decodeInt {
    SInt32 val = 0;
    if([dataInputStream hasBytesAvailable]) {    
       [dataInputStream read:(uint8_t *)&val maxLength:4];       
       val = EndianS32_BtoN(val);       
       return [NSNumber numberWithInt:val];
    }
    return nil;
}

- (NSDictionary *) decodeMap {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    uint8_t objectTag = 'e';
    if([dataInputStream hasBytesAvailable]) {    
        [dataInputStream read:&objectTag maxLength:1];  
        if(objectTag == 't') {
            //decode the type of map, maps with a type are objects of a particular class
            //if we have a class mapping for this then             
            NSString * type = [self decodeString:'S'];                 
            if(type != nil && [type length] > 0) {
                Class mappedClass = [self classForClassName:type];
                if(!mappedClass) { //try the global mapping
                    mappedClass = [BBSHessianDecoder classForClassName:type];
                }
                if(mappedClass) {
                    [dict setObject:NSStringFromClass(mappedClass) forKey:BBSHessianClassNameKey];
                }
                else {
                    [dict setObject:type forKey:BBSHessianClassNameKey];
                }
            }
        }         
        
        [dataInputStream read:&objectTag maxLength:1];
         while(objectTag != 'z' && [dataInputStream hasBytesAvailable]) {                       
            //read the type
            id key = [self decodeObjectForCode:objectTag];
            [dataInputStream read:&objectTag maxLength:1];
            id value = [self decodeObjectForCode:objectTag];
            if(key != nil) {
                if(value == nil) {
                    value = [NSNull null];
                }
                [dict setObject:value forKey:key];
            }
            [dataInputStream read:&objectTag maxLength:1];  
        }
        return dict;
    }
    else {
        NSLog(@"no data available");
    }
    return nil;
}

- (NSArray * ) decodeList {
    NSMutableArray * array = [NSMutableArray array];
    uint8_t objectTag = 'e';
    if([dataInputStream hasBytesAvailable]) {    
        [dataInputStream read:&objectTag maxLength:1]; 
        if(objectTag == 't') {
            //decode the type of list, we don't really care about this
            NSString * type = [self decodeString:'S'];  
            #pragma unused (type)            
        }  
        [dataInputStream read:&objectTag maxLength:1]; 
        if(objectTag == 'l') {
            //length of object in reply, we don't really care about this because we're creating an NSArray
            NSNumber * len = [self decodeInt];
            #pragma unused (len)
        }
        [dataInputStream read:&objectTag maxLength:1]; 
        
         while(objectTag != 'z' && [dataInputStream hasBytesAvailable]) {  
            id obj = [self decodeObjectForCode:objectTag];
            if(obj) { 
                [array addObject:obj];
            }
            [dataInputStream read:&objectTag maxLength:1];  
         }
         return array;
    }   
    return nil;
}


- (NSNumber *) decodeLong {
    SInt64 aLong = 0;
    if([dataInputStream hasBytesAvailable]) {    
        [dataInputStream read:(uint8_t *)&aLong maxLength:8]; 
    }
    aLong = EndianS64_BtoN(aLong);
    return [NSNumber numberWithLongLong:aLong];
}

- (NSNumber *) decodeDouble {
    SInt64 aLong = 0;
    if([dataInputStream hasBytesAvailable]) {    
        [dataInputStream read:(uint8_t *)&aLong maxLength:8]; 
    }
    aLong = EndianS64_BtoN(aLong);
    double* dval = (double*)&aLong;
    return [NSNumber numberWithDouble:*dval];
}

- (NSDate *) decodeDate {
    return [NSDate dateWithTimeIntervalSince1970:[[self decodeLong] longLongValue]/1000];
}

- (NSData * ) decodeByteChunks {
    NSMutableData * dataRet = [NSMutableData data];
    int len =0;
    uint8_t objectTag = 'b';
    while(objectTag == 'b') {
        len = [self decodeStringLength];          
        uint8_t * readData = NULL;
        readData = malloc(len * sizeof(readData));  
        if(readData == NULL) {
           NSLog(@"failed to alloc memory for binary data with len =%i",len);
           return nil;
        }  
        memset(readData,0,len);        
        [dataInputStream read:readData maxLength:len];
        [dataRet appendBytes:readData length:len];
        [dataInputStream read:&objectTag maxLength:1]; 
    }
    //last chunk
    if(objectTag == 'B') {
        uint8_t * readData = NULL;
        readData = malloc(len * sizeof(readData));            
        if(readData == NULL) {
           NSLog(@"failed to alloc memory for binary data with len =%i",len);
           return nil;
        }
        memset(readData,0,len);
        [dataInputStream read:readData maxLength:len];
        [dataRet appendBytes:readData length:len];
    }
    else {
        NSLog(@"ERROR: excepted 'B' tag for binary chunk sequence");
    }
    return dataRet;
}

- (NSData *) decodeBytes {
    int dataLength = [self decodeStringLength];
    uint8_t * readData = NULL;
    readData = malloc(dataLength * sizeof(readData));   
    if(readData == NULL) {
       NSLog(@"failed to alloc memory for binary data with len =%i",dataLength);
       return nil;
    } 
    memset(readData,0,dataLength);    
    [dataInputStream read:readData maxLength:dataLength];
    NSData * someData = [NSData dataWithBytes:readData length:dataLength];
    return someData;
}

- (NSError *) decodeFault {
    uint8_t objectTag = 'e';
    [dataInputStream read:&objectTag maxLength:1]; 
    //should be 'S'
    if(objectTag != 'S') {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"Malformed fault response from server" 
                                                              forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:BBSHessianObjCError
                                   code:BBSHessianProtocolError
                               userInfo:userInfo];
    }
    NSString * codeProp = [self decodeString:'S'];
    
    #pragma unused (codeProp)
    [dataInputStream read:&objectTag maxLength:1]; 
    //should be 'S'
    if(objectTag != 'S') {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"Malformed fault response from server" 
                                                              forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:BBSHessianObjCError
                                   code:BBSHessianProtocolError
                               userInfo:userInfo];
    }

    NSString * codeMessage = [self decodeString:'S'];
    [dataInputStream read:&objectTag maxLength:1]; 
    //should be 'S'
    if(objectTag != 'S') {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"Malformed fault response from server" 
                                                              forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:BBSHessianObjCError
                                   code:BBSHessianProtocolError
                               userInfo:userInfo];
    }

    NSString * messageProp = [self decodeString:'S'];
    #pragma unused (messageProp)
    [dataInputStream read:&objectTag maxLength:1]; 
    //should be 'S'
    if(objectTag != 'S') {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"Malformed fault response from server" 
                                                              forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:BBSHessianObjCError
                                   code:BBSHessianProtocolError
                               userInfo:userInfo];
    }

    NSString * message = [self decodeString:'S'];
    [dataInputStream read:&objectTag maxLength:1]; 
    //should be 'S'
    if(objectTag != 'S') {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"Malformed fault response from server" 
                                                              forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:BBSHessianObjCError
                                   code:BBSHessianProtocolError
                               userInfo:userInfo];
    }

    NSString * detailProp = [self decodeString:'S'];
    #pragma unused (detailProp)
    [dataInputStream read:&objectTag maxLength:1]; 
    //should be 'S'
    if(objectTag != 'M') {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"Malformed fault response from server" 
                                                              forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:BBSHessianObjCError
                                   code:BBSHessianProtocolError
                               userInfo:userInfo];
    }

    NSDictionary * details = [self decodeMap];   
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@:%@",codeMessage,message]
                                                              forKey:NSLocalizedDescriptionKey];
     
    [userInfo setObject:details forKey:NSUnderlyingErrorKey];
    return [NSError errorWithDomain:BBSHessianObjCError
                               code:BBSHessianProtocolError
                           userInfo:userInfo];

}

- (NSNumber *) decodeRef {
    return [self decodeInt];
}

- (int) decodeStringLength {
    UInt16 len = 0;    
    if([dataInputStream hasBytesAvailable]) {    
       [dataInputStream read:(uint8_t *)&len maxLength:2];
       len = EndianU16_BtoN(len);
    }    
    return len;
}


@end

