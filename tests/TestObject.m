//
//  TestObject.m
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

#import "TestObject.h"


@implementation TestObject

- (id) init {
    self = [super init];
    testArray = [[NSMutableArray alloc] init];
    return self;
}

- (NSString *) fname {
    return fname; 
}
- (void) setFname: (NSString *) aFname {
    [aFname retain];
    [fname release];
    fname = aFname;
}

- (NSString *) lname {
    return lname; 
}
- (void) setLname: (NSString *) aLname {
    [aLname retain];
    [lname release];
    lname = aLname;
}

- (void) addElementToTestArray:(NSString *) aStr {
    [testArray addObject:aStr];
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super init];
    [coder encodeObject: [self fname] forKey: @"fname"];
    [coder encodeObject: [self lname] forKey: @"lname"];
    [coder encodeObject:testArray forKey:@"testArray"];
}

- (id) initWithCoder: (NSCoder *) coder {    
    [self setFname: [coder decodeObjectForKey: @"fname"]];
    [self setLname: [coder decodeObjectForKey: @"lname"]];
    testArray = [[coder decodeObjectForKey: @"testArray"] retain];
   
    return self;
}

- (void) dealloc {
    [self setFname: nil];
    [self setLname: nil];
    [testArray release];
    testArray = nil;
    [super dealloc];
}


@end
