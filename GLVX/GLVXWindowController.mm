#import "GLVXWindowController.h"
#import "GLVXView.h"
#import "glv.h"

#pragma mark Private members

@interface GLVXWindowController ()
- (void)processMouseEvent:(NSEvent *)theEvent;
@end

#pragma mark
#pragma mark Class implementation

@implementation GLVXWindowController

#pragma mark Initialization

- (id)initWithGLV:(GLVREF)glv
{
    self = [super initWithWindowNibName:@"GLVXWindow"];
    if (self)
    {
        _glv = glv;
    }
    return self;
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

#pragma mark Window handling events

- (void)windowDidResize:(NSNotification *)notification
{
    glv::GLV& glv = glv::Dereference(_glv);
    
    CGSize size = _glvxView.frame.size;
    glv.extent(size.width, size.height);
    
    glv.broadcastEvent(glv::Event::WindowResize);
}

#pragma mark Mouse events

- (void)mouseDown:(NSEvent *)theEvent
{
    [self processMouseEvent:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self processMouseEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self processMouseEvent:theEvent];
}

- (void)processMouseEvent:(NSEvent *)theEvent
{
    glv::GLV& target = glv::Dereference(_glv);
    
    NSPoint point = theEvent.locationInWindow;
    point.y = _glvxView.frame.size.height - point.y;
    glv::space_t relx = point.x;
    glv::space_t rely = point.y;
    
    if (theEvent.type == NSLeftMouseDown)
    {
        target.setMouseDown(relx, rely, glv::Mouse::Left, 0);
    }
    else if (theEvent.type == NSLeftMouseDragged)
    {
        target.setMouseMotion(relx, rely, glv::Event::MouseDrag);
    }
    else if (theEvent.type == NSLeftMouseUp)
    {
        target.setMouseUp(relx, rely, glv::Mouse::Left, 0);
    }
    
    target.setMousePos(point.x, point.y, relx, rely);
    target.propagateEvent();
}

@end
