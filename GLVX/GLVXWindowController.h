#import <Cocoa/Cocoa.h>
#import "GLVXView.h"
#import "glv.h"

@interface GLVXWindowController : NSWindowController
{
    glv::GLV *_glv;
    IBOutlet GLVXView *_glvxView;
}

- (id)initWithGLV:(glv::GLV *)glv;

@end
