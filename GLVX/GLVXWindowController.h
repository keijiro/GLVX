#import <Cocoa/Cocoa.h>
#import "GLVX.h"

@interface GLVXWindowController : NSWindowController <NSWindowDelegate>
{
    GLVREF _glv;
}

- (id)initWithGLV:(GLVREF)glv size:(CGSize)size title:(NSString *)title;

@end
