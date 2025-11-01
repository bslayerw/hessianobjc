# HessianObjC

HessianObjC is a pre-ARC Objective-C framework that speaks the Hessian 1.x
binary remote procedure call (RPC) protocol. Use it to encode Objective-C data
structures, post requests to Hessian services, and decode responses while
preserving legacy macOS compatibility.

## Hessian Protocol Snapshot

- 2001: Caucho Technology introduced the Hessian binary protocol to simplify
 service-to-service communication without SOAP’s XML overhead.
- Early 2000s: Java and PHP libraries shipped first, delivering language-agnostic
 RPC with compact binary framing and automatic typing.
- Mid 2000s: Objective-C and other community ports appeared, enabling native
 apps to talk to the growing ecosystem of Hessian services.

Today Hessian remains attractive for legacy integrations where compact
cross-language RPC is required without adopting gRPC or JSON-based stacks.

## Project Overview

- Targets macOS 10.4-era APIs: manual retain/release, `NSURLConnection`, and
 `NSCalendarDate` remain in active use.
- Encodes outbound payloads via `BBSHessianEncoder`, posts them with
 `BBSHessianProxy`, and decodes responses via `BBSHessianDecoder` and
 `BBSHessianResult`.
- Supports custom Objective-C ↔ Hessian class mappings so complex objects round
 trip cleanly using `NSCoding`.
- Ships with SenTestingKit-based integration tests that exercise the public
 API against Caucho’s public Hessian test endpoint.

## Key Components

- `BBSHessianEncoder`: Converts Foundation objects into Hessian byte streams.
 Handles chunked strings/data (0x8000-byte segments) and manual class-cluster
 inspection (`NSCFString`, `NSCFDictionary`, etc.).
- `BBSHessianDecoder`: Parses Hessian replies, manages reference tables, and
 rehydrates objects via `BBSHessianMapDecoder` when class mappings exist.
- `BBSHessianProxy`: Synchronous client that wraps `BBSHessianCall`, posts with
 `text/xml` headers, and returns decoded objects or `NSError` instances.
- `BBSHessianInvocation`: Asynchronous variant acting as an
 `NSURLConnection` delegate, calling back with decoded responses or errors.

## Building

```bash
xcodebuild -project HessianObjC.xcodeproj -alltargets
```

- The bundled `build.xml` mirrors these steps for Ant-based workflows:

```bash
ant dist
```

## Testing

Run the SenTestingKit suite (hits `http://hessian.caucho.com/test/test`):

```bash
xcodebuild \
 -project HessianObjC.xcodeproj \
 -target HessianObjTest \
 -configuration Debug \
 -sdk macosx
```

Network failures will surface as test errors; rerun when the external service
is reachable.

## Usage

### Synchronous Call

```objectivec
NSURL *url = [NSURL URLWithString:@"http://www.caucho.com/hessian/test/basic"];
BBSHessianProxy *proxy = [[[BBSHessianProxy alloc] initWithUrl:url] autorelease];
NSNumber *a = [NSNumber numberWithInt:1130];
NSNumber *b = [NSNumber numberWithInt:551];
id result = [proxy callSynchronous:@"subtract" withParameters:@[a, b]];
NSLog(@"subtract => %@", result);
```

### Custom Object Mapping

```objectivec
NSDictionary *mapping = [NSDictionary dictionaryWithObject:@"TestObject"
              forKey:@"com.example.TestObject"];
[BBSHessianProxy setClassMapping:mapping];

TestObject *obj = [[[TestObject alloc] init] autorelease];
[obj setFname:@"Byron"];
[obj setLname:@"Wright"];

NSMutableData *data = [BBSHessianEncoder dataWithRootObject:obj];
id decoded = [BBSHessianDecoder decodedObjectWithData:data];
```

### Notes

- All custom classes must implement `NSCoding` to encode/decode via Hessian
 maps. See `tests/TestObject.m` for a minimal example.
- `BBSHessianProxy callSynchronous:` returns either the decoded object or an
 `NSError`; callers should check the type before use.
- Be mindful of manual memory management; follow the retain/release patterns
 shown throughout the codebase.

## Examples & Samples

- `tests/BBSHessianTest.m`: Demonstrates encoder/decoder round trips, remote
 calls, and class mapping.
- `examples/SimpleAppTest/`: Simple Cocoa application project that consumes the
 framework.

## License

HessianObjC is licensed under the Apache License, Version 2.0. See `LICENSE`
for details.
