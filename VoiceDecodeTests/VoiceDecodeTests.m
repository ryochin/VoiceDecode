//

#import <XCTest/XCTest.h>
#import "DragView.h"

@interface VoiceDecodeTests : XCTestCase

@end

@implementation VoiceDecodeTests

- (void) setUp {
	[super setUp];
}

- (void) tearDown {
	[super tearDown];
}

- (void) testExample {
	DragView *dragView = DragView.new;

	XCTAssert( [[dragView uniqueFileSuffix] length] == 8, @"unique file suffix: length");
}

@end
