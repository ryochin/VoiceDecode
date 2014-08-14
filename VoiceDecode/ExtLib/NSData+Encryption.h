#import <Foundation/Foundation.h>

@interface NSData (Encryption)

- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
