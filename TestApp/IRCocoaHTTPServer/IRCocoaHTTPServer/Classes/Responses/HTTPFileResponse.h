//
//  HTTPFileResponse.h
//  IRCocoaHTTPServer
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "HTTPResponse.h"

@class HTTPConnection;

NS_ASSUME_NONNULL_BEGIN

@interface HTTPFileResponse : NSObject <HTTPResponse>
{
    HTTPConnection *connection;
    
    NSString *filePath;
    UInt64 fileLength;
    UInt64 fileOffset;
    
    BOOL aborted;
    
    int fileFD;
    void *buffer;
    NSUInteger bufferSize;
}

- (id)initWithFilePath:(NSString *)filePath forConnection:(HTTPConnection *)connection;
- (NSString *)filePath;

@end


NS_ASSUME_NONNULL_END
