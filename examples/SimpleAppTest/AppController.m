//
//  AppController.m
//  SimpleAppTest
//
//  Created by Byron Wright on 3/13/06.
//  Copyright 2006 Blue Bear Studio. All rights reserved.
//  At the time of this writing the url to the test service at Caucho.com was unreachable.
// "http://www.caucho.com/hessian/test/basic.
// If it's still unreachable please point to your dev environment if you have one :)
#import <HessianObjC/BBSHessianObjC.h>
#import "AppController.h"


@implementation AppController

- (void) setOutput:(id) output {
    [outputField insertText:[NSString stringWithFormat:@"%@: %@\n",[NSDate date],output]];
}

- (IBAction) sayHello:(id) sender {
    NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    id result = [proxy callSynchronous:@"hello" withParameters:nil];
    [self setOutput:result];
}
- (IBAction) subtractAB:(id) sender {
    int a = [subA intValue];
    int b = [subB intValue];
    NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
    BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
    NSArray * paramters = [NSArray arrayWithObjects:[NSNumber numberWithInt:a],[NSNumber numberWithInt:b],nil];
    id result = [proxy callSynchronous:@"subtract" withParameters:paramters];
    [self setOutput:result];
    
}
@end
