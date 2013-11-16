#import <Cocoa/Cocoa.h>
#import "GLVX.h"

@class GLVXView;

@interface GLVXWindowController : NSWindowController
{
    GLVREF _glv;
    IBOutlet GLVXView *_glvxView;
}

- (id)initWithGLV:(GLVREF)glv;

@end
