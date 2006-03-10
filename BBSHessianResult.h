//
//  BBSHessianResponse.h
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

/** Responsible for decoding a result from a Hessian call */

@interface BBSHessianResult : NSObject {
    @private
    NSData * data;
    NSInputStream * dataInputStream;
    id resultValue;
    int majorVersion;
    int minorVersion;
}

/** Instantiate and initialize with data that will be decoded from Hessian format.
  * @param someData is NSData encoded in Hessian binary format 
  */
- (id) initForReadingWithData:(NSData *) someData;
/** Returns the result value that has been decoded from the remote call result. 
  * @return a decoded object from a remote call result @see BBSHessianDecoder decodeObject.
  */
- (id) resultValue;

@end
