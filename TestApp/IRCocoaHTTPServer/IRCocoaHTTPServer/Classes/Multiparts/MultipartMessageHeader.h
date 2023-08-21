//
//  MultipartMessageHeader.h
//  IRCocoaHTTPServer
//
//  Created by irons on 2021/3/26.
//
//  Created by Валерий Гаврилов on 29.03.12.
//  Copyright (c) 2012 LLC "Online Publishing Partners" (onlinepp.ru). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//-----------------------------------------------------------------
// interface MultipartMessageHeader
//-----------------------------------------------------------------
enum {
    contentTransferEncoding_unknown,
    contentTransferEncoding_7bit,
    contentTransferEncoding_8bit,
    contentTransferEncoding_binary,
    contentTransferEncoding_base64,
    contentTransferEncoding_quotedPrintable,
};

@interface MultipartMessageHeader : NSObject {
    NSMutableDictionary*                    fields;
    int                                     encoding;
    NSString*                               contentDispositionName;
}
@property (strong,readonly) NSDictionary* fields;
@property (readonly) int encoding;

- (id) initWithData:(NSData*) data formEncoding:(NSStringEncoding) encoding;
@end


NS_ASSUME_NONNULL_END
