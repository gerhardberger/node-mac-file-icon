#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)();
typedef void (^ErrorBlock)(id);

@interface FileIconFetcher : NSObject

@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) ErrorBlock errorBlock;

- (void)getFileIconAtPath:(NSString *)input
              withOutput: (NSString *)output
                  atSize:(int)size
              withSuccess: (void (^)())completionHandler
                withError:(void (^)(NSError *error))errorHandler;
- (NSImage *)resizedImage:(NSImage *)sourceImage toSize:(int)size;
- (void)saveImage:(NSImage *)sourceImage toPath:(NSString *)destination;

@end
