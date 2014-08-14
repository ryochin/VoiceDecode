//

#import "AppDelegate.h"
#import "NSData+Encryption.h"
#import "UICKeyChainStore.h"
#import "DragView.h"

@implementation DragView

- (id) initWithFrame: (NSRect) frame {
	self = [super initWithFrame: frame];
	if( self ){
		self.highlightColor = [NSColor colorWithHue: 0.0f saturation: 0.0f brightness: 0.88f alpha: 1.0f];

		[self registerForDraggedTypes: @[NSFilenamesPboardType]];
	}
	return self;
}

- (void) drawRect: (NSRect) rect {
	NSString *path = [[NSBundle mainBundle] pathForResource: @"Drop" ofType: @"png"];
	NSImage *image = [[NSImage alloc] initWithContentsOfFile: path];

	NSPoint point = NSMakePoint( ( 80 - 60 ) / 2, ( 80 - 60 ) / 2 );

	[image drawAtPoint: point fromRect: rect operation: NSCompositeCopy fraction: 1.0f];
}

- (void) decrypt: (NSArray *) files {
	// check passphrase
	NSString *passPhrase = [UICKeyChainStore stringForKey: PASSPHRASE_KEY];
	if( [passPhrase isEqualToString: @""] ){
		[self showMessage: LS(@"Please set your passphrase which was used to encrypt on Voice Droplet App.") withArgs: nil];
		return;
	}

	// decrypt
	for( __strong NSString *file in files ){
		if( [self decryptFile: file] == YES ){
			;
		}
		else{
			// cancel remainings
			return;
		}

		[NSThread sleepForTimeInterval: 0.20f];
	}
}

- (BOOL) decryptFile: (NSString *) file {
	NSString *decryptedFile = [self getRawFilePath: file];

	TRACE("%@ -> %@", file, decryptedFile);

	NSData *content = [[[NSFileManager defaultManager] contentsAtPath: file] AES256DecryptWithKey: [UICKeyChainStore stringForKey: PASSPHRASE_KEY]];

	if( [[NSFileManager defaultManager] createFileAtPath: decryptedFile contents: content attributes: nil] == YES ){
		;
	}
	else{
		[self showMessage: LS(@"Failed to save file: %@") withArgs: @[decryptedFile]];
		return NO;
	}

	return YES;
}

- (NSString *) getRawFilePath: (NSString *) file {
	NSString *fileName = [[file stringByDeletingPathExtension] lastPathComponent];
	NSString *decryptedFile = [NSString stringWithFormat: @"%@/%@", [app.defaults objectForKey: @"saveDirectory"], fileName];

	if( [[NSFileManager defaultManager] fileExistsAtPath: decryptedFile] == YES ){
		NSString *suffix = [fileName pathExtension];
		NSString *fileBodyName = [fileName stringByDeletingPathExtension];

		return [NSString stringWithFormat: @"%@/%@.%@.%@", [app.defaults objectForKey: @"saveDirectory"], fileBodyName, [self uniqueFileSuffix], suffix];
	}
	else{
		return decryptedFile;
	}
}

#pragma mark - NSDraggingDestination

- (NSDragOperation) draggingEntered: (id <NSDraggingInfo>) sender {
	self.layer.backgroundColor = [self.highlightColor CGColor];

	return NSDragOperationGeneric;
}

- (void) draggingEnded: (id <NSDraggingInfo>) sender {
	self.layer.backgroundColor = [[NSColor clearColor] CGColor];
}

- (void) draggingExited: (id <NSDraggingInfo>) sender {
	self.layer.backgroundColor = [[NSColor clearColor] CGColor];
}

#pragma mark Drops

- (BOOL) prepareForDragOperation: (id <NSDraggingInfo>) sender {
	// check suffix
	for( __strong NSString *path in [self filelistInDraggingInfo: sender] ){
		NSURL *url = [NSURL fileURLWithPath: path];
		NSString *suffix = [url pathExtension];
		if( ! [suffix isEqualToString: ENCRYPTION_SUFFIX] ){
			return NO;
		}
	}

	return YES;
}

- (BOOL) performDragOperation: (id <NSDraggingInfo>) sender {
	[self decrypt: [self filelistInDraggingInfo: sender]];

	return YES;
}

- (void) concludeDragOperation: (id <NSDraggingInfo>) sender {
	;
}

- (NSArray *) filelistInDraggingInfo: (id <NSDraggingInfo>) info {
	NSPasteboard *board = [info draggingPasteboard];
	return [board propertyListForType:NSFilenamesPboardType];
}

#pragma mark - Utils

- (void) showMessage: (NSString *) message withArgs: (NSArray *) args {
	NSAlert *alert = [ NSAlert alertWithMessageText: @""
									  defaultButton: LS(@"OK")
									alternateButton: nil
										otherButton: nil
						  informativeTextWithFormat: message, args];

	[alert beginSheetModalForWindow: self.window
					  modalDelegate: self
					 didEndSelector: nil
						contextInfo: nil];
}

- (NSString *) uniqueFileSuffix {
	NSString *str = [NSString stringWithFormat: @"%lu", (unsigned long)([[NSDate date] timeIntervalSinceReferenceDate] * 100.0f)];
	return [str substringFromIndex: 3];
}

@end
