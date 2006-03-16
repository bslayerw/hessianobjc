//
//  BBSHessianMapDecoder.h
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
/** Because a Hessian Map is translated into an NSDictionary which can
  * only old objects this decoder is required to decode NSNumbers / NSValues
  * to their instrinstic types. This class is usually not used directly, but is
  * used by the BBSHessianDecoder.
  */

@interface BBSHessianMapDecoder: NSCoder {
    @private
    NSDictionary * hessianMap;
}

/** Initialize with a NSDictionary that was decoded from a Hessian Map type. 
  * @param aHessianMap is an NSDictionary thas was decoded and returned from either
  * BBSHessianDecoder + (id) decodedObjectWithData:(NSData *) someData;
  * BBSHessianDecoder - (id) decodedObject;
  * Note that either of these methods will only return a NSDictionary if a map was decoded
  * and no class mapping was found. 
  */
- (id) initForReadingWithDictionary:(NSDictionary *) aHessianMap;

@end
