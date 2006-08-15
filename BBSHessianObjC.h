//
//  HessianObjC.h
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
#import <HessianObjC/BBSHessianObjCDefines.h>
#import <HessianObjC/BBSHessianDecoder.h>
#import <HessianObjC/BBSHessianEncoder.h>
#import <HessianObjC/BBSHessianCall.h>
#import <HessianObjC/BBSHessianResult.h>
#import <HessianObjC/BBSHessianMapDecoder.h>
#import <HessianObjC/BBSHessianProxy.h>


/** \mainpage
<h2>Quick Start</h2>

<p>Installation</p>
<p>Either get the latest source  <code>svn co https://svn.sourceforge.net/svnroot/hessianobjc/trunk hessianobj</code> or get the latest framework binary from <a href="http://sourceforge.net/project/showfiles.php?group_id=161665">SourceForge.net</a>.</p>

<p>Place the framework in /Library/Frameworks/ or ~/Library/Frameworks/. Placing the framework in /Library/Frameworks/ is recommended unless of your you don't have permissions.</p>
<p>I'm going to assume you know how to include a framework in XCode (this is a Quickstart guide after all). The two main classes for encoding and decoding Hessian objects are <code>BBSHessianEncoder</code> and <code>BBSHessianDecoder</code>. When working with a remote Hessian web service you'll use the <code>BBSHessianProxy</code> class.</p>
<p>Here is the sample code to call the subtract method provided by the BasicAPI service at caucho.com synchronously. From their javadoc, their remote method signature : <code>public int subtract(int a,int b)</code></p>

<p><code> NSURL * url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];<br />
BBSHessianProxy * proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];<br />
NSNumber * a = [NSNumber numberWithInt:1130];<br />
NSNumber * b = [NSNumber numberWithInt:551];<br />
id result = [proxy callSynchronous:@"subtract" withParameters:[NSArray arrayWithObjects:a,b,nil]];<br />
NSLog(@"testSubtract result = %@",result);</code></p>
<p>Noticed that all parameters are objects and all return values are object also. All ints, double longs and booleans will be converted to NSNumbers.
</p>


*/


