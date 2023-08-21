//
//  IRHCLog.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Log Enable Config
 */
#define IRHCLogEnable(target, console_log_enable, record_log_enable)               \
static BOOL const IRHCLog_##target##_ConsoleLogEnable = console_log_enable;        \
static BOOL const IRHCLog_##target##_RecordLogEnable = record_log_enable;

#define IRHCLogEnableValueConsoleLog(target)       IRHCLog_##target##_ConsoleLogEnable
#define IRHCLogEnableValueRecordLog(target)        IRHCLog_##target##_RecordLogEnable

/**
 *  Common
 */
IRHCLogEnable(Common,            YES, YES)

/**
 *  HTTP Server
 */
IRHCLogEnable(HTTPServer,        YES, YES)
IRHCLogEnable(HTTPConnection,    YES, YES)
IRHCLogEnable(HTTPResponse,      YES, YES)

/**
 *  Data Storage
 */
IRHCLogEnable(DataStorage,       YES, YES)
IRHCLogEnable(DataRequest,       YES, YES)
IRHCLogEnable(DataResponse,      YES, YES)
IRHCLogEnable(DataReader,        YES, YES)
IRHCLogEnable(DataLoader,        YES, YES)

IRHCLogEnable(DataUnit,          YES, YES)
IRHCLogEnable(DataUnitItem,      YES, YES)
IRHCLogEnable(DataUnitPool,      YES, YES)
IRHCLogEnable(DataUnitQueue,     YES, YES)

IRHCLogEnable(DataSourceManager, YES, YES)
IRHCLogEnable(DataFileSource,    YES, YES)
IRHCLogEnable(DataNetworkSource, YES, YES)

/**
 *  Download
 */
IRHCLogEnable(Download,          YES, YES)

/**
 *  Alloc & Dealloc
 */
IRHCLogEnable(Alloc,             YES, YES)
IRHCLogEnable(Dealloc,           YES, YES)

/**
 *  Log
 */
#define IRHCLogging(target, console_log_enable, record_log_enable, ...)            \
if (([IRHCLog log].consoleLogEnable && console_log_enable) || ([IRHCLog log].recordLogEnable && record_log_enable))       \
{                                                                                   \
    NSString *va_args = [NSString stringWithFormat:__VA_ARGS__];                    \
    NSString *log = [NSString stringWithFormat:@"%@  :   %@", target, va_args];     \
    if ([IRHCLog log].recordLogEnable && record_log_enable) {                      \
        [[IRHCLog log] addRecordLog:log];                                          \
    }                                                                               \
    if ([IRHCLog log].consoleLogEnable && console_log_enable) {                    \
        NSLog(@"%@", log);                                                          \
    }                                                                               \
}


/**
 *  Common
 */
#define IRHCLogCommon(...)                 IRHCLogging(@"IRHCMacro           ", IRHCLogEnableValueConsoleLog(Common),            IRHCLogEnableValueRecordLog(Common),            ##__VA_ARGS__)

/**
 *  HTTP Server
 */
#define IRHCLogHTTPServer(...)             IRHCLogging(@"IRHCHTTPServer       ", IRHCLogEnableValueConsoleLog(HTTPServer),        IRHCLogEnableValueRecordLog(HTTPServer),        ##__VA_ARGS__)
#define IRHCLogHTTPConnection(...)         IRHCLogging(@"IRHCHTTPConnection   ", IRHCLogEnableValueConsoleLog(HTTPConnection),    IRHCLogEnableValueRecordLog(HTTPConnection),    ##__VA_ARGS__)
#define IRHCLogHTTPResponse(...)           IRHCLogging(@"IRHCHTTPResponse     ", IRHCLogEnableValueConsoleLog(HTTPResponse),      IRHCLogEnableValueRecordLog(HTTPResponse),      ##__VA_ARGS__)

/**
 *  Data Storage
 */
#define IRHCLogDataStorage(...)            IRHCLogging(@"IRHCDataStorage      ", IRHCLogEnableValueConsoleLog(DataStorage),       IRHCLogEnableValueRecordLog(DataStorage),       ##__VA_ARGS__)
#define IRHCLogDataRequest(...)            IRHCLogging(@"IRHCDataRequest      ", IRHCLogEnableValueConsoleLog(DataRequest),       IRHCLogEnableValueRecordLog(DataRequest),       ##__VA_ARGS__)
#define IRHCLogDataResponse(...)           IRHCLogging(@"IRHCDataResponse     ", IRHCLogEnableValueConsoleLog(DataResponse),      IRHCLogEnableValueRecordLog(DataResponse),      ##__VA_ARGS__)
#define IRHCLogDataReader(...)             IRHCLogging(@"IRHCDataReader       ", IRHCLogEnableValueConsoleLog(DataReader),        IRHCLogEnableValueRecordLog(DataReader),        ##__VA_ARGS__)
#define IRHCLogDataLoader(...)             IRHCLogging(@"IRHCDataLoader       ", IRHCLogEnableValueConsoleLog(DataLoader),        IRHCLogEnableValueRecordLog(DataLoader),        ##__VA_ARGS__)

#define IRHCLogDataUnit(...)               IRHCLogging(@"IRHCDataUnit         ", IRHCLogEnableValueConsoleLog(DataUnit),          IRHCLogEnableValueRecordLog(DataUnit),          ##__VA_ARGS__)
#define IRHCLogDataUnitItem(...)           IRHCLogging(@"IRHCDataUnitItem     ", IRHCLogEnableValueConsoleLog(DataUnitItem),      IRHCLogEnableValueRecordLog(DataUnitItem),      ##__VA_ARGS__)
#define IRHCLogDataUnitPool(...)           IRHCLogging(@"IRHCDataUnitPool     ", IRHCLogEnableValueConsoleLog(DataUnitPool),      IRHCLogEnableValueRecordLog(DataUnitPool),      ##__VA_ARGS__)
#define IRHCLogDataUnitQueue(...)          IRHCLogging(@"IRHCDataUnitQueue    ", IRHCLogEnableValueConsoleLog(DataUnitQueue),     IRHCLogEnableValueRecordLog(DataUnitQueue),     ##__VA_ARGS__)

#define IRHCLogDataSourceManager(...)      IRHCLogging(@"IRHCDataSourceManager", IRHCLogEnableValueConsoleLog(DataSourceManager), IRHCLogEnableValueRecordLog(DataSourceManager), ##__VA_ARGS__)
#define IRHCLogDataFileSource(...)         IRHCLogging(@"IRHCDataFileSource   ", IRHCLogEnableValueConsoleLog(DataFileSource),    IRHCLogEnableValueRecordLog(DataFileSource),    ##__VA_ARGS__)
#define IRHCLogDataNetworkSource(...)      IRHCLogging(@"IRHCDataNetworkSource", IRHCLogEnableValueConsoleLog(DataNetworkSource), IRHCLogEnableValueRecordLog(DataNetworkSource), ##__VA_ARGS__)

/**
 *  Download
 */
#define IRHCLogDownload(...)               IRHCLogging(@"IRHCDownload         ", IRHCLogEnableValueConsoleLog(Download),          IRHCLogEnableValueRecordLog(Download),          ##__VA_ARGS__)

/**
 *  Alloc & Dealloc
 */
#define IRHCLogAlloc(obj)                  IRHCLogging(obj, IRHCLogEnableValueConsoleLog(Alloc),   IRHCLogEnableValueRecordLog(Alloc),   @"alloc")
#define IRHCLogDealloc(obj)                IRHCLogging(obj, IRHCLogEnableValueConsoleLog(Dealloc), IRHCLogEnableValueRecordLog(Dealloc), @"dealloc")

@interface IRHCLog : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)log;

/**
 *  DEBUG   : default is NO.
 *  RELEASE : default is NO.
 */
@property (nonatomic) BOOL consoleLogEnable;

/**
 *  DEBUG   : default is NO.
 *  RELEASE : default is NO.
 */
@property (nonatomic) BOOL recordLogEnable;

- (void)addRecordLog:(NSString *)log;

- (NSURL *)recordLogFileURL;
- (void)deleteRecordLogFile;

/**
 *  Error
 */
- (void)addError:(NSError *)error forURL:(NSURL *)URL;
- (NSDictionary<NSURL *, NSError *> *)errors;
- (NSError *)errorForURL:(NSURL *)URL;
- (void)cleanErrorForURL:(NSURL *)URL;

@end


NS_ASSUME_NONNULL_END
