//
//  BBSHessianInvocation.h
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
#import <Foundation/Foundation.h>
@class BBSHessianCall;

/** Encapsulates a HessianCall and the context for callback when the invocation is complete.
  */
  
@interface BBSHessianInvocation : NSObject {
    @private
    id callbackTarget;
    SEL callbackSelector;
    BBSHessianCall * call;
    NSMutableData * asynchResponseData;
}

/** Initiate with a BBSHessianCall @see BBSHessianCall
  * @param aCall is a BBSHessianCall @see BBSHessianCall
  * @param aTarget is the target object that the callbackSelector will be called on when the invocation is complete
  * @param aSelector is the selector that will be called on the target object with the result value of the invocation.
  * The method signature should be like, - (void) myCallbackSelector:(id):resultValue. So call this with @selector(myCallbackSelector:).
  */
- (id) initWithCall:(BBSHessianCall *) aCall
     callbackTarget:(id) aTarget
   callbackSelector:(SEL) aSelector;
   
/** Return the remote method name for the invocation
  * @return an NSString of the remote method name.
  */
- (NSString *) methodName;

/** Return the Hessian encoded data of the encapsulated call @see BBSHessianCall data. 
  * @return Hessian encoded data of the encapsulated call @see BBSHessianCall data. 
 */
- (NSData *) callData;

/** Return the object that will be called with the callback selector when the invocation is complete.
  * @return the object that will be called with the callback selector when the invocation is complete.
  */
- (id) callbackTarget;
/** Return the selector that will be called on the callback target object when the invocation is complete.
  * @return the selector that will be called on the callback target object when the invocation is complete.
  * The selector should have a signature like :  - (void) myCallbackSelector:(id):resultValue. Which would have been created with @selector(myCallbackSelector:).
  */
- (SEL) callbackSelector;

@end
