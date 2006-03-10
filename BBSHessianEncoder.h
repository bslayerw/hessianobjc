//
//  BBSHessianEncoder.h
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
/** Encodes objects into Hessian binary protocol format */

@interface BBSHessianEncoder : NSCoder {
    @private
    NSMutableData * callData;
    NSMutableDictionary * classMapping;
}


/** Initialize with data that all encoded objects will be appened to.
  * This method usually isn't used directly. 
  * @param data is NSMutableData that all encoded objects will be appended to.
  */
- (id) initForWritingWithMutableData:(NSMutableData *)data;

/** Encode an object and return the data in Hessian binary format.
  * @param anObject is can be an NSObject that needs to be encoded in Hessian format.
  * If encoding of ints, double, longs and bool is required then pass them as NSNumbers 
  */
+ (NSMutableData *) dataWithRootObject:(id) anyObject;

/** Return the data with the encoded object(s) in Hessian format
  * @return the data with the encoded object(s) in Hessian format
  */
- (NSMutableData *) data;

- (void) setClassName:(NSString *)codedName forClass:(Class)cls;
+ (void) setClassName:(NSString *)codedName forClass:(Class)cls;
- (NSString *)classNameForClass:(Class)cls;
+ (NSString *)classNameForClass:(Class)cls;

+ (void) setClassNameMapping:(NSDictionary *) aMappingDictionary;
@end
