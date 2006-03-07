//
//  BBSHessianOBJDefines.h
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

#ifndef BBS_HESSIAN_OBJC_DEFINES 
#define BBS_HESSIAN_OBJC_DEFINES

#if defined(__cplusplus)
    #define BBS_HESSIAN_OBJC_EXTERN extern "C"
#else
    #define BBS_HESSIAN_OBJC_EXTERN extern
#endif

BBS_HESSIAN_OBJC_EXTERN NSString * BBSHessianClassNameKey;
BBS_HESSIAN_OBJC_EXTERN NSString * BBSHessianObjCError;


enum {
    BBSHessianProtocolError                   = 666,   // generic protocol
    BBSHessianProtocolBadReplyError           = 676    // generic protocol
}   ;
#endif