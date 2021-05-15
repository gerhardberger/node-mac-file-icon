#import "FileIconFetcher.h"

#import <AppKit/AppKit.h>


@interface FileIconFetcher ()
@end

@implementation FileIconFetcher

- (void)getFileIconAtPath:(NSString *)input
              withOutput: (NSString *)output
                  atSize:(int)size
              withSuccess: (void (^)())completionHandler
                withError:(void (^)(NSError *error))errorHandler {
  self.successBlock = completionHandler;
  self.errorBlock = errorHandler;

  NSURL *inputURL = [[NSWorkspace sharedWorkspace]
    URLForApplicationWithBundleIdentifier:input];

  if ([[NSFileManager defaultManager] fileExistsAtPath:input]) {
    NSImage *imageForInput = [[NSWorkspace sharedWorkspace] iconForFile:input];

    NSImage *resizedImage = [self resizedImage:imageForInput toSize:size];

    if (resizedImage) {
      [self saveImage:resizedImage toPath:output];
    } else {
      NSError *error = [NSError errorWithDomain:@"icon.file.mac.node"
                                           code:1000
                                       userInfo:@{@"Error reason":
                                         @"Image resize failed"}];
      errorHandler(error);
    }
  } else {
    NSLog(@"File does not exist!");
  }

  self.successBlock();
}

- (NSImage *)resizedImage:(NSImage *)sourceImage toSize:(int) size {
  if (!sourceImage.isValid) return nil;

  CGSize newSize = CGSizeMake(size, size);

  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:newSize.width
                          pixelsHigh:newSize.height
                        bitsPerSample:8
                      samplesPerPixel:4
                            hasAlpha:YES
                            isPlanar:NO
                      colorSpaceName:NSCalibratedRGBColorSpace
                          bytesPerRow:0
                        bitsPerPixel:0];
  rep.size = newSize;

  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext
    setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
  [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                 fromRect:NSZeroRect
                operation:NSCompositingOperationCopy
                 fraction:1.0];
  [NSGraphicsContext restoreGraphicsState];

  NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
  [newImage addRepresentation:rep];
  return newImage;
}

- (void)saveImage:(NSImage *)sourceImage toPath:(NSString *)destination {
  NSData *imageData = [sourceImage TIFFRepresentation];
  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
  NSDictionary *imageProps = [NSDictionary
    dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                  forKey:NSImageCompressionFactor];

  imageData = [imageRep representationUsingType:NSPNGFileType
                                      properties:imageProps];
  [imageData writeToFile:destination atomically:NO];
}

@end
