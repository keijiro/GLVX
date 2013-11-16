#import <Cocoa/Cocoa.h>
#import "glv.h"

@interface GLVXView : NSOpenGLView
{
    CVDisplayLinkRef _displayLink;
}

@property (assign) glv::GLV *glv;

@end
