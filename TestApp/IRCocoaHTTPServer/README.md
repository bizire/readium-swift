![Build Status](https://img.shields.io/badge/build-%20passing%20-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-%20iOS%20-blue.svg)

# IRCocoaHTTPServer 

- IRCocoaHTTPServer is a copy project from [KTVCocoaHTTPServer](https://github.com/ChangbaDevs/KTVCocoaHTTPServer) and [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer).

- A usage case is using HTTPServer combine with the video player([IRPlayer](https://github.com/irons163/IRPlayer))  for cache.

## Features
- Built in support for bonjour broadcasting
- IPv4 and IPv6 support
- Asynchronous networking using GCD and standard sockets
- Password protection support
- SSL/TLS encryption support
- Extremely FAST and memory efficient
- Extremely scalable (built entirely upon GCD)
- Heavily commented code
- Very easily extensible
- WebDAV is supported too!

## Install
### Git
- Git clone this project.

## Usage

### Basic
- Set `HTTPServer` .
```obj-c
// Create server using our custom MyHTTPServer class
httpServer = [[HTTPServer alloc] init];

// Tell the server to broadcast its presence via Bonjour.
// This allows browsers such as Safari to automatically discover our service.
[httpServer setType:@"_http._tcp."];

// Normally there's no need to run our server on any specific port.
// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
// However, for easy testing you may want force a certain port so you can just hit the refresh button.
// [httpServer setPort:12345];

// Serve files from our embedded Web folder
NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
NSLog(@"Setting document root: %@", webPath);

[httpServer setDocumentRoot:webPath];
```

## Screenshots
| Demo1 |
|:---:|
| ![Demo1](./ScreenShots/demo1.png) |
