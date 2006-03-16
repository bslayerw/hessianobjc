//
//  HessianProxy.h
//  HessianObjC

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

@class BBSHessianInvocation;

/** BBSHessianProxy acts as a facade to the underlying transport and encoder / decoder framework.
  * This proxy class is responsible to encode remote method calls, making the call and then decoding
  * remote method returns. 
  */
@interface BBSHessianProxy : NSObject {
    @private
    NSURL * serviceUrl;
    NSURLConnection * remoteConnection;
}
/** Initialize with Hessian web service end point.
  */
- (id) initWithUrl:(NSURL * ) aServiceUrl;

/** @return the Url service end point */
- (NSURL *) serviceUrl;
- (void) setServiceUrl: (NSURL *) aServiceUrl;

/** Call the remote method with the specified parameters synchronously.
  * This method will return the result value when complete. 
  * @param methodName is an NSString of the remote method to call at the serviceUrl
  * @param parameters is an NSArray containing the parameters that will be encoded and passed to the remote method
  */
- (id) callSynchronous:(NSString *) methodName
        withParameters:(NSArray *) parameters;

/** Asynchronously call the remote service Url with a BBSHessianInvocation
  * @see BBSHessianInvocation
  */
- (void) callWithInvocation:(BBSHessianInvocation *) anInvocation;

/** The class mapping dictionary is used to map remote to local and local to remote class types.
  * As an example, passing a NSDictionary as follows: 
  * [NSDictionary dictionaryWithObject:@"TestObject" forKey:@"com.bluebearstudio.test.TestObject"]
  * will allow the encoder to send a Objective-C TestObject:NSObject as a Java com.bluebearstudio.test.TestObject.
  * This will also allow the decoder to decode a Java Java com.bluebearstudio.test.TestObject and instantiate
  * a local TestObject:NSObject. 
  */
+ (void) setClassMapping:(NSDictionary *) classMapping;

+ (void) setEncoderClassMapping:(NSDictionary *) encoderMapping;
+ (void) setDecoderClassMapping:(NSDictionary *) decoderMapping;
@end
