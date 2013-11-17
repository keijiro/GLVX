#import <Cocoa/Cocoa.h>
#import "GLVX.h"

@interface GLVXWindowController : NSWindowController <NSWindowDelegate>
{
    GLVREF _glv;
}

- (id)initWithGLV:(GLVREF)glv title:(NSString *)title;

@end
