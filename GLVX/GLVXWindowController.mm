#import "GLVXWindowController.h"

@interface GLVXWindowController ()

@end

@implementation GLVXWindowController

- (id)initWithGLV:(glv::GLV *)glv
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
    CGSize size = _glvxView.frame.size;
    _glv->extent(size.width, size.height);
    _glv->broadcastEvent(glv::Event::WindowResize);
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    _glvxView.glv = _glv;
    CGSize size = _glvxView.frame.size;
    _glv->extent(size.width, size.height);
    _glv->broadcastEvent(glv::Event::WindowCreate);
}

@end
