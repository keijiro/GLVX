#import <Cocoa/Cocoa.h>
#import "GLVX.h"

@interface GLVXView : NSOpenGLView
{
    CVDisplayLinkRef _displayLink;
}

@property (assign) GLVREF glv;

@end
