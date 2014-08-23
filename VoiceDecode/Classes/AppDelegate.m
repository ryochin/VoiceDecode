//

#import "AppDelegate.h"
#import "UICKeyChainStore.h"

@implementation AppDelegate

+ (NSUserDefaults *) getUserDefaults {
	// get defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	defaultValues[@"saveDirectory"] = [[self class] defaultDir];
	defaultValues[@"savePassPhraseToKeyChain"] = @(YES);

	// register
	[defaults registerDefaults: defaultValues];

	return defaults;
}

+ (NSString *) defaultDir {
	return [NSString stringWithFormat: @"%@/Desktop", NSHomeDirectory()];
}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
	// prepare user defaults
	self.defaults = [AppDelegate getUserDefaults];

	// check
	[self checkSaveDirectory];

	// Window
	[self.window setFrameAutosaveName: @"default"];

	// Drag View
	self.dragView = [[DragView alloc] initWithFrame: NSMakeRect( 20, 20, 80, 80 )];
	[self.dragView setWantsLayer: YES];

	[self.window.contentView addSubview: self.dragView];

	// Label
	self.passPhraseTextLabel = [[NSTextField alloc] initWithFrame: NSMakeRect( 116, 76 - 2, 80, 24 )];
	[self.passPhraseTextLabel setBordered: NO];
	[self.passPhraseTextLabel setEditable: NO];
	[self.passPhraseTextLabel setBackgroundColor: [NSColor clearColor]];

	[self.passPhraseTextLabel setStringValue: LS(@"Passphrase: ")];

	[self.window.contentView addSubview: self.passPhraseTextLabel];

	// Passphrase
	self.passPhraseTextView = [[NSSecureTextField alloc] initWithFrame: NSMakeRect( 194, 76, 280, 24 )];
	self.passPhraseTextView.delegate = self;
	[[self.passPhraseTextView cell] setWraps: NO];
	[[self.passPhraseTextView cell] setUsesSingleLineMode: YES];

	[self.window.contentView addSubview: self.passPhraseTextView];

	// checkbox
	self.savePassPhraseCheckButton = [[NSButton alloc] initWithFrame: NSMakeRect( 192, 44, 120, 32 )];
	[self.savePassPhraseCheckButton setButtonType: NSSwitchButton];
	[self.savePassPhraseCheckButton setTitle: LS(@"save to KeyChain")];
	[self.savePassPhraseCheckButton setState: [[self.defaults objectForKey: @"savePassPhraseToKeyChain"] boolValue]];
	[self.savePassPhraseCheckButton setTarget: self];
	[self.savePassPhraseCheckButton setAction: @selector(savePassPhraseCheckButtonDidChange:)];

	[self.window.contentView addSubview: self.savePassPhraseCheckButton];

	// Label
	self.saveDirTextLabel = [[NSTextField alloc] initWithFrame: NSMakeRect( 116, 18 - 2, 80, 24 )];
	[self.saveDirTextLabel setBordered: NO];
	[self.saveDirTextLabel setEditable: NO];
	[self.saveDirTextLabel setBackgroundColor: [NSColor clearColor]];

	[self.saveDirTextLabel setStringValue: LS(@"Save To: ")];

	[self.window.contentView addSubview: self.saveDirTextLabel];

	// Save Directory
	self.saveDirTextView = [[NSTextField alloc] initWithFrame: NSMakeRect( 194, 18 - 2, 204, 24 )];
	[self.saveDirTextView setBordered: NO];
	[self.saveDirTextView setEditable: NO];
	[self.saveDirTextView setBackgroundColor: [NSColor clearColor]];
	[[self.saveDirTextView cell] setWraps: NO];
	[[self.saveDirTextView cell] setLineBreakMode: NSLineBreakByTruncatingHead];
	[[self.saveDirTextView cell] setUsesSingleLineMode: YES];

	[self updateSaveDirDisplay];

	[self.window.contentView addSubview: self.saveDirTextView];

	// Open Button
	self.openButton = NSButton.new;
	self.openButton.frame = NSMakeRect( 402, 18, 72, 24 );
	self.openButton.bezelStyle = NSThickerSquareBezelStyle;
	self.openButton.title = LS(@"Change");
	self.openButton.action = @selector(openSaveDirDialog);

	[self.window.contentView addSubview: self.openButton];

	// run
	[self performSelector: @selector(setPassphraseFromKeyChain) withObject: nil afterDelay: 0.50f];
}

- (void) applicationWillTerminate: (NSNotification *) notification {
	[self.window saveFrameUsingName: @"default"];
}

- (void) checkSaveDirectory {
	void (^setDefaultDir)() = ^void(){
		// fall back to default
		[self.defaults setObject: [[self class] defaultDir] forKey: @"saveDirectory"];
		[self.defaults synchronize];
	};

	BOOL isDirectory;
	if( [[NSFileManager defaultManager] fileExistsAtPath: [self.defaults objectForKey: @"saveDirectory"] isDirectory: &isDirectory] == YES ){
		if( isDirectory == NO ){
			setDefaultDir();
		}
	}
	else{
		setDefaultDir();
	}
}

- (void) controlTextDidChange: (NSNotification *) aNotification {
	[self savePassphraseToKeyChain];
}

- (void) controlTextDidEndEditing: (NSNotification *) aNotification {
	[self savePassphraseToKeyChain];
}

- (void) setPassphraseFromKeyChain {
	NSString *passPhrase = [UICKeyChainStore stringForKey: PASSPHRASE_KEY];
	if( passPhrase == nil ) return;
	if( [passPhrase isEqualToString: @""] ) return;

	[self.passPhraseTextView setStringValue: [UICKeyChainStore stringForKey: PASSPHRASE_KEY]];
}

- (void) updateSaveDirDisplay {
	[self.saveDirTextView setStringValue: [self.defaults objectForKey: @"saveDirectory"]];
}

- (void) savePassphraseToKeyChain {
	NSString *passPhrase = [self.passPhraseTextView stringValue];
	if( passPhrase == nil ) return;

	if( [self.savePassPhraseCheckButton state] == NSOnState ){
		[UICKeyChainStore setString: passPhrase forKey: PASSPHRASE_KEY];
	}
	else if( [[UICKeyChainStore stringForKey: PASSPHRASE_KEY] length] > 0 ){
		[UICKeyChainStore setString: @"" forKey: PASSPHRASE_KEY];
	}
}

- (void) openSaveDirDialog {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories: YES];
	[openPanel setCanChooseFiles: NO];
	[openPanel setAllowsMultipleSelection: NO];

	NSInteger pressedButton = [openPanel runModal];
	if( pressedButton == NSOKButton ){
		[self.defaults setObject: [[openPanel URL] path] forKey: @"saveDirectory"];
		[self.defaults synchronize];
		[self checkSaveDirectory];
		[self updateSaveDirDisplay];
	}
	else if( pressedButton == NSCancelButton ){
		;
	}
	else{
		TRACE("something is wrong");
	}
}

- (void) savePassPhraseCheckButtonDidChange: (id) sender {
	[self.defaults setObject: @( [self.savePassPhraseCheckButton state] == NSOnState ) forKey: @"savePassPhraseToKeyChain"];
	[self.defaults synchronize];

	[self savePassphraseToKeyChain];
}

@end
