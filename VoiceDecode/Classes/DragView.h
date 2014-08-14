//

#import <Cocoa/Cocoa.h>

@interface DragView : NSView <NSDraggingDestination>

@property (strong, nonatomic) NSColor *highlightColor;

- (NSString *) uniqueFileSuffix;

@end
