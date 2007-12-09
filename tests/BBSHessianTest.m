//
//  BBSHessianTest.m
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
static NSString * testEndPoint = @"http://hessian.caucho.com/test/test";

#import "BBSHessianTest.h"
#import "TestObject.h"
#import "BBSHessianObjC.h"

@implementation BBSHessianTest


+ (void) initialize {
    NSDictionary * classMapping = [NSDictionary dictionaryWithObject:@"TestObject" forKey:@"com.bluebearstudio.hessianObjC.test.TestObject"];
    [BBSHessianProxy setClassMapping:classMapping];
    NSLog(@"main bundle = %@",[NSBundle mainBundle]);
}

- (void) testCoders {
    TestObject * obj = [[[TestObject alloc] init] autorelease];
    
    [obj setFname:@"Byron"];
    [obj setLname:@"Wright"];
    
    NSMutableData * hData = [NSMutableData data];
    BBSHessianEncoder * encoder = [[[BBSHessianEncoder alloc] initForWritingWithMutableData:hData] autorelease];
    [encoder encodeObject:obj];
    BBSHessianDecoder * decoder = [[[BBSHessianDecoder alloc] initForReadingWithData:hData] autorelease];
    id decodedObj = [decoder decodedObject];
    
    STAssertNotNil(decodedObj,@"failed to decode object");
    STAssertTrue([decodedObj isKindOfClass:[TestObject class]],@"decoded object is not an instance of TestObject");
    STAssertNotNil([decodedObj fname],@"did not decode fname property");
    STAssertNotNil([decodedObj lname],@"did not decode lname property");

    NSMutableData * encodedObject = [BBSHessianEncoder dataWithRootObject:obj];
    STAssertNotNil(encodedObject,@"failed to encode data with root object");
    id anotherDecodedObject = [BBSHessianDecoder decodedObjectWithData:encodedObject];
 
    STAssertNotNil(anotherDecodedObject,@"failed to decode object");
    
   /* NSData * imgIn = [NSData dataWithContentsOfFile:@"/Users/byronwright/Projects/hessianobjc/trunk/tests/P1040812.jpg"];
    NSMutableData * encodedImgData = [BBSHessianEncoder dataWithRootObject:imgIn];
    NSData * imgOut = [BBSHessianDecoder decodedObjectWithData:encodedImgData];
    [imgOut writeToFile:@"/Users/byronwright/Projects/hessianobjc/trunk/tests/P1040812.out.jpg" atomically:YES];*/
}

- (void) testCallNull {    
    NSURL * url = [NSURL URLWithString:testEndPoint];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"nullCall" withParameters:nil];
    NSLog(@"testCallNull result = %@",result);
    STAssertNil(result,@"call null returned a non null value");
}

- (void) testHello {
    NSURL * url = [NSURL URLWithString:testEndPoint];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"hello" withParameters:nil];
    STAssertNotNil(result,@"test hello did not return a valid value");
}

- (void) testSubtract {
    NSURL * url = [NSURL URLWithString:testEndPoint];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    NSNumber * a = [NSNumber numberWithInt:1130];
    NSNumber * b = [NSNumber numberWithInt:551];
    id result = [proxy callSynchronous:@"subtract" withParameters:[NSArray arrayWithObjects:a,b,nil]];
    STAssertEquals([result intValue],579,@"result of subtracting 551 from 1130 should be 579");
}

- (void) testEcho {
    NSURL * url = [NSURL URLWithString:testEndPoint];
    
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    NSMutableDictionary * encodeMapping = [NSMutableDictionary dictionary];
    NSMutableData * mappingData = [NSMutableData data];
    NSKeyedArchiver * archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:mappingData] autorelease];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:encodeMapping];
    [archiver finishEncoding];
   // [mappingData writeToFile:@"/Users/byronwright/testmapping.xml" atomically:YES];
    //[BBSHessianEncoder setClassNameMapping:encodeMapping];
    NSNumber * anInt = [NSNumber numberWithInt:551];
    NSNumber * aDouble = [NSNumber numberWithDouble:123123.5132];
    NSNumber * aLong = [NSNumber numberWithLongLong:2112312313];
    NSDate * now = [NSDate date];
    NSCalendarDate * cal = [NSCalendarDate calendarDate];
    NSNumber * aBool = [NSNumber numberWithBool:YES];
    NSMutableDictionary * aDict = [NSMutableDictionary dictionary];
    NSMutableArray * anArray = [NSMutableArray array];
    int i;
    for(i=0;i<10;i++) {
        [anArray addObject:[NSNumber numberWithInt:i]];
    }
    //[aDict setObject:someData forKey:@"testData"];
    [aDict setObject:anArray forKey:@"testArray"];
    [aDict setObject:aDouble forKey:@"testDouble"];
    [aDict setObject:now forKey:@"testDate"];
    [aDict setObject:cal forKey:@"cal"];
    [aDict setObject:aBool forKey:@"testBool"];
    [aDict setObject:@"test string for TestObject" forKey:@"testValue"];
    [aDict setObject:anInt forKey:@"testInt"];
    [aDict setObject:aLong forKey:@"testLong"];
    [aDict setObject:[NSNull null] forKey:@"testNull"];
    NSDecimalNumber * dec = [NSDecimalNumber decimalNumberWithString:@"23.00"];
    [aDict setObject:dec forKey:@"testDecimal"];
    //test encoding and decoding of NSData
    NSString * bigString = [NSString stringWithContentsOfFile:@"/Users/byronwright/Projects/hessianobjc/trunk/LICENSE"];

    [aDict setObject:bigString forKey:@"testBigString"];

    id result = [proxy callSynchronous:@"echo" withParameters:[NSArray arrayWithObjects:aDict,nil]];
    STAssertNotNil(result,@"echo failed to return object");
    STAssertNotNil([result objectForKey:@"testArray"],@"test array was not echoed");
    STAssertNotNil([result objectForKey:@"testDouble"],@"test double was not echoed");
    STAssertNotNil([result objectForKey:@"testDate"],@"test date was not echoed");
    STAssertNotNil([result objectForKey:@"testBool"],@"test bool was not echoed");
    STAssertNotNil([result objectForKey:@"testValue"],@"test testValue was not echoed");
    STAssertNotNil([result objectForKey:@"testInt"],@"test testInt was not echoed");
    STAssertNotNil([result objectForKey:@"testLong"],@"test testLong was not echoed");
    STAssertNotNil([result objectForKey:@"testDecimal"],@"failed to echo decimal number");
    STAssertTrue([[result objectForKey:@"testDecimal"] isEqualToNumber:[NSNumber numberWithDouble:23.00]],@"returned decimal value is not == 23");
    STAssertNotNil([result objectForKey:@"testBigString"],@"test testData was not echoed");

    TestObject * aTestObj = [[[TestObject alloc] init] autorelease];
    [aTestObj setFname:@"Byron"];
    [aTestObj setLname:@"Wright"];
    TestObject * child = [[[TestObject alloc] init] autorelease];
    [child setFname:@"Tyler"];
    [child setLname:@"Wright"];
    [aTestObj setChild:child];
    result = [proxy callSynchronous:@"echo" withParameters:[NSArray arrayWithObjects:aTestObj,nil]];
    STAssertNotNil(result,@"echo failed to return object");

    STAssertNotNil([result objectForKey:@"fname"],@"fname property was not echoed");
    STAssertNotNil([result objectForKey:@"lname"],@"lname property was not echoed");
    STAssertNotNil([result objectForKey:@"child"],@"child property was not echoed");
    STAssertNotNil([[result objectForKey:@"child"] objectForKey:@"fname"],@"child fname property was not echoed");
    STAssertNotNil([[result objectForKey:@"child"] objectForKey:@"lname"],@"child lname property was not echoed");
}


- (void) testFault {
    NSURL * url = [NSURL URLWithString:testEndPoint];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"fault" withParameters:nil];
    STAssertNotNil(result,@"fault test return nil value");
    STAssertTrue([result isKindOfClass:[NSError class]],@"fault test returned did not return an error");
    NSLog(@"test fault return value = %@",result);
    //get underlying error address
    NSLog(@"fault description = %@",[result localizedDescription]);
}

/*- (void) testRefs {
    NSURL * url = [NSURL URLWithString:@"http://localhost:8080/springapp/hello.service"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"refs" withParameters:nil];
    STAssertNotNil(result,@"refs test return nil value");
    STAssertTrue([result isKindOfClass:[NSError class]],@"refs test returned did not return an error");
    NSLog(@"test fault return value = %@",result);

}*/

/*- (void) testVariableLengthList {
    NSURL * url = [NSURL URLWithString:@"http://localhost:8080/springapp/hello.service"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"testList" withParameters:nil];
    STAssertNotNil(result,@"\"list\" test return nil value");
    STAssertFalse([result isKindOfClass:[NSError class]],@"\"list\" test returned did not return an error");
    NSLog(@"test testVariableLengthList return value = %@",result);
}*/
@end
