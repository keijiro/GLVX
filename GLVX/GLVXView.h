#import <Cocoa/Cocoa.h>
#import "GLVX.h"

@interface GLVXView : NSOpenGLView
{
    GLVREF _glv;
    CVDisplayLinkRef _displayLink;
}

- (id)initWithGLV:(GLVREF)glv frame:(NSRect)frameRect;

@end
