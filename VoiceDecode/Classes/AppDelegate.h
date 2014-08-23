//

#import <Cocoa/Cocoa.h>
#import "DragView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>

@property (strong, atomic) NSUserDefaults *defaults;

@property (assign) IBOutlet   NSWindow          *window;
@property (strong, nonatomic) DragView          *dragView;
@property (strong, nonatomic) NSTextField       *passPhraseTextLabel;
@property (strong, nonatomic) NSSecureTextField *passPhraseTextView;
@property (strong, nonatomic) NSTextField       *saveDirTextLabel;
@property (strong, nonatomic) NSTextField       *saveDirTextView;
@property (strong, nonatomic) NSButton          *openButton;
@property (strong, nonatomic) NSButton          *savePassPhraseCheckButton;

+ (NSUserDefaults *) getUserDefaults;

@end
