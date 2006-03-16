//
//  AppController.h
//  SimpleAppTest
//
//  Created by Byron Wright on 3/13/06.
//  Copyright 2006 Blue Bear Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
    IBOutlet NSTextView * outputField;
    IBOutlet NSTextField * subA;
    IBOutlet NSTextField * subB;
}

- (void) setOutput:(id) output;
- (IBAction) sayHello:(id) sender;
- (IBAction) subtractAB:(id) sender;
@end
