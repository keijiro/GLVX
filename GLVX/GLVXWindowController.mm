#import "GLVXWindowController.h"
#import "GLVXView.h"
#import "glv.h"

@interface GLVXWindowController ()

@end

@implementation GLVXWindowController

- (id)initWithGLV:(GLVREF)glv
{
    self = [super initWithWindowNibName:@"GLVXWindow"];
    if (self)
    {
        _glv = glv;
    }
    return self;
}

- (void)windowDidResize:(NSNotification *)notification
{
    glv::GLV& glv = glv::Dereference(_glv);

    CGSize size = _glvxView.frame.size;
    glv.extent(size.width, size.height);

    glv.broadcastEvent(glv::Event::WindowResize);
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    _glvxView.glv = _glv;

    glv::GLV& glv = glv::Dereference(_glv);

    CGSize size = _glvxView.frame.size;
    glv.extent(size.width, size.height);
    
    glv.broadcastEvent(glv::Event::WindowCreate);
}

@end
