//
//  BBSHessianCall.h
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
/** Encapsulates a Hessian call. BBSHessianCall is responsible
  * for encoding a Hessian call and all it's parameters.
  */

@interface BBSHessianCall : NSObject {
    @private
    NSMutableData * callData;
    NSString * methodName;
    NSArray * parameters;
    /*NSMutableDictionary * headers;*/
}

/** initialize a Hessian call with a remote method name. 
  * eg. If the remote method has the following signature: public java.lang.Object echo(java.lang.Object value)
  * simple pass @"echo" has the remote method name.
  * @param aMethodName is an NSString with the name of the remote method for this call. 
  * eg. If the remote method has the following signature: public java.lang.Object echo(java.lang.Object value)
  * simple pass @"echo" has the remote method name.
  */
- (id) initWithRemoteMethodName:(NSString *) aMethodName;

/** Return the data encoded in Hessian binary format.
  * Call setParameters before calling data if the remote call will contain parameters.
  * @return NSData with call encoded in Hessian binary format. 
  * Call setParameters first if the call will contain parammeters.
  */
- (NSData *) data;

/** Parameters that will be passed to the remote method.
  * NSArray should contain the objects that will be passed. Ints, longs, doubles and bools
  * should be passed as NSNumbers. The encoder will handle passing them as their instrinsic types
  * to the remote service. eg [NSArray arrayWithObject:[NSNumber numberWithBool:NO]]; to pass a false bool.
  * @param someParameters should be an NSArray that contains parameters for remote method. Ints, longs, doubles and bools
  * should be passed as NSNumbers. The encoder will handle passing them as their instrinsic types
  * to the remote service.
  */
- (void) setParameters: (NSArray *) someParameters;

/*- (void) setHeader:(id) aHeader forName:(NSString*) theHeaderName;*/

/** Return the method name the call was instantiated with.
  * @return the method name the call was instantiated with.
  */ 
- (NSString*) methodName;

@end
