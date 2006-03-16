//
//  BBSHessianDecoder.h
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
/** BBSHessianDecoder is responsible to decoding Hessian binary protocol encoded objects.
  * If class mappings are specified those will also be used to instantiate to appropriate local class instance.
  */
@interface BBSHessianDecoder : NSObject {
    @private
    NSInputStream * dataInputStream;
    NSMutableDictionary * classMapping;
}

/** Static method that decodes an object encoded in Hessian binary protocol and returns the object value.
  * @param someData should be data encoded in Hessian binary format.
  */
+ (id) decodedObjectWithData:(NSData *) someData;

/** Instantiate and initialize the decoder for decoding with Hessian encoded data.
  * @param someData is NSData that's encoded in Hessian binary format.
  */
- (id) initForReadingWithData:(NSData *) someData;

/** Decodes and returns an object of the data that was encoded. 
  * @return a decoded object. If the encoded data was an int,long, double or Bool
  * then an NSNumber will be returned. Faults will be returned as an NSError. Object
  * will be returned as NSDictionaries unless a mapping was available, if so then an attempt
  * will be make to instantiate an instance of the local class.
  */
- (id) decodedObject;

- (void) setClass:(Class) cls forClassName:(NSString *) codedName;
+ (void) setClass:(Class) cls forClassName:(NSString *) codedName;
- (Class) classForClassName:(NSString *) codedName;
+ (Class) classForClassName:(NSString *) codedName;

+ (void) setClassNameMapping:(NSDictionary *) aMappingDictionary;
@end
