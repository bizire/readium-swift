![Build Status](https://img.shields.io/badge/build-%20passing%20-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-%20iOS%20-blue.svg)

# IRHTTPCache 

- IRHTTPCache is a copy project from [KTVHTTPCache](https://github.com/ChangbaDevs/KTVHTTPCache).

- IRHTTPCache is a powerful media cache framework. It can cache HTTP request, and very suitable for media resources.

- A usage case is using IRHTTPCache combine with the video player([IRPlayer](https://github.com/irons163/IRPlayer))  for cache.

## Features

- Support Swift.
- Thread safety.
- Logging system, Support for console and file output.
- Accurate view caching information.
- Provide different levels of interface.
- Adjust the download configuration.
- Including demo
    - AVPlayer
    - ([IRPlayer](https://github.com/irons163/IRPlayer))

## Install
### Git
- Git clone this project.
- Copy this project into your own project.
- Add the .xcodeproj into you  project and link it as an embed framework.
- Also, link IRCocoaHTTPServer as an embed framework.
#### Options
- You can remove the `demo` and `ScreenShots` folder.

### Cocoapods
- Add `pod 'IRHTTPCache'`  in the `Podfile`
- `pod install`

## Usage

### Swift

```swift
let _: () = { () -> () in
    self.setupHTTPCache()
}()
        
...

func setupHTTPCache() {
    IRHTTPCache.logSetConsoleLogEnable(true)
    do {
        try IRHTTPCache.proxyStart()
        NSLog("Proxy Start Success");
    } catch {
        NSLog("Proxy Start Failure");
    }

    IRHTTPCache.encodeSetURLConverter { (URL) -> URL? in
        NSLog("URL Filter reviced URL")
        return URL
    }

    IRHTTPCache.downloadSetUnacceptableContentTypeDisposer { (URL, contentType) -> Bool in
        NSLog("Unsupport Content-Type Filter reviced URL")
        return false
    }
}
```

- Generated proxy URL.

```swift
IRHTTPCache.proxyURL(withOriginalURL: originalURL)
```

### ObjC

- Start proxy.

```objc
[IRHTTPCache proxyStart:&error];
```

- Generated proxy URL.

```objc
NSURL *proxyURL = [IRHTTPCache proxyURLWithOriginalURL:originalURL];
AVPlayer *player = [AVPlayer playerWithURL:proxyURL];
```

- Get the complete cache file URL if existed.

```objc
NSURL *completeCacheFileURL= [IRHTTPCache cacheCompleteFileURLWithURL:originalURL];
```

- Set the URL filter processing mapping relationship.

```objc
[IRHTTPCache encodeSetURLConverter:^NSURL *(NSURL *URL) {
    return URL;
}];
```

- Download Configuration

```objc
// Timeout interval.
[IRHTTPCache downloadSetTimeoutInterval:30];

// Accept Content-Type.
[IRHTTPCache downloadSetAcceptableContentTypes:contentTypes];

// Set unsupport Content-Type filter.
[IRHTTPCache downloadSetUnacceptableContentTypeDisposer:^BOOL(NSURL *URL, NSString *contentType) {
    return NO;
}];

// Additional headers.
[IRHTTPCache downloadSetAdditionalHeaders:headers];

// Whitelist headers.
[IRHTTPCache downloadSetWhitelistHeaderKeys:headers];
```

- Log.

```objc
// Console.
[IRHTTPCache logSetConsoleLogEnable:YES];

// File.
[IRHTTPCache logSetRecordLogEnable:YES];
NSString *logFilePath = [IRHTTPCache logRecordLogFilePath];
```

## Screenshots
| Demo Main Page | Demo1 |
|:---:|:---:|
|![Demo1](./ScreenShots/demo1.png)|![Demo2](./ScreenShots/demo2.png)| 

