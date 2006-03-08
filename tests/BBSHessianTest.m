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

#import "BBSHessianTest.h"
#import "BBSHessianCall.h"
#import "BBSHessianDecoder.h"
#import "BBSHessianEncoder.h"
#import "TestObject.h"

#import "BBSHessianProxy.h"

@implementation BBSHessianTest


+ (void) initialize {
    [BBSHessianEncoder setClassName:@"com.sbs.colledia.hessian.test.TestObject" forClass:[TestObject class]];
    [BBSHessianDecoder setClass:[TestObject class] forClassName:@"com.sbs.colledia.hessian.test.TestObject"];
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

    NSLog(@"decodedObj = %@",decodedObj);
    NSLog(@"fname = %@",[decodedObj fname]);
    NSLog(@"lname = %@",[decodedObj lname]);
    NSMutableData * encodedObject = [BBSHessianEncoder dataWithRootObject:obj];
    STAssertNotNil(encodedObject,@"failed to encode data with root object");
    //STAssertTrue(([encodedObject length] > 0),@"empty data returned from encoding");
    id anotherDecodedObject = [BBSHessianDecoder decodedObjectWithData:encodedObject];
    NSLog(@"anotherDecodedObject = %@",anotherDecodedObject);
    STAssertNotNil(anotherDecodedObject,@"failed to decode object");
}

- (void) testCallNull {    
    NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"nullCall" withParameters:nil];
    NSLog(@"testCallNull result = %@",result);
    STAssertNil(result,@"call null returned a non null value");
}

- (void) testHello {
    NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"hello" withParameters:nil];
    STAssertNotNil(result,@"test hello did not return a valid value");
    //STAssertTrue([result length] > 0,@"excepted a non-empty string");
    NSLog(@"testHello = %@",result);
}

- (void) testSubtract {
    NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    NSNumber * a = [NSNumber numberWithInt:1130];
    NSNumber * b = [NSNumber numberWithInt:551];
    id result = [proxy callSynchronous:@"subtract" withParameters:[NSArray arrayWithObjects:a,b,nil]];
    NSLog(@"testSubtract result = %@",result);
}

- (void) testEcho {
    NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    
    NSMutableDictionary * encodeMapping = [NSMutableDictionary dictionary];
    NSMutableData * mappingData = [NSMutableData data];
    NSKeyedArchiver * archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:mappingData] autorelease];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:encodeMapping];
    [archiver finishEncoding];
    //[mappingData writeToFile:@"/Users/byronwright/testmapping.xml" atomically:YES];
    //[BBSHessianEncoder setClassNameMapping:encodeMapping];
    NSNumber * anInt = [NSNumber numberWithInt:551];
    NSNumber * aDouble = [NSNumber numberWithDouble:123123.5132];
    NSNumber * aLong = [NSNumber numberWithLongLong:2112312313];
    NSDate * now = [NSDate date];
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
    [aDict setObject:aBool forKey:@"testBool"];
    [aDict setObject:@"test string for TestObject" forKey:@"testValue"];
    [aDict setObject:anInt forKey:@"testInt"];
    [aDict setObject:aLong forKey:@"testLong"];
    TestObject * obj = [[[TestObject alloc] init] autorelease];
    [obj setFname:@"Byron"];
    [obj setLname:@"Wright"];
    [aDict setObject:obj forKey:@"me"];
    id result = [proxy callSynchronous:@"echo" withParameters:[NSArray arrayWithObjects:aDict,nil]];
    STAssertNotNil(result,@"echo failed to return object");
    STAssertNotNil([result objectForKey:@"testArray"],@"test array was not echoed");
    STAssertNotNil([result objectForKey:@"testDouble"],@"test double was not echoed");
    STAssertNotNil([result objectForKey:@"testDate"],@"test date was not echoed");
    STAssertNotNil([result objectForKey:@"testBool"],@"test bool was not echoed");
    STAssertNotNil([result objectForKey:@"testValue"],@"test testValue was not echoed");
    STAssertNotNil([result objectForKey:@"testInt"],@"test testInt was not echoed");
    STAssertNotNil([result objectForKey:@"testLong"],@"test testLong was not echoed");
    STAssertNotNil([result objectForKey:@"me"],@"test me was not echoed");
}


- (void) testFault {

    NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"fault" withParameters:nil];
    STAssertNotNil(result,@"fault test return nil value");
    STAssertTrue([result isKindOfClass:[NSError class]],@"fault test returned did not return an error");
    NSLog(@"test fault return value = %@",result);
}

@end
