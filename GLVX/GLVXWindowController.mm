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

- (id)initWithGLV:(GLVREF)glv size:(CGSize)size title:(NSString *)title
{
    CGSize screenSize = [NSScreen mainScreen].frame.size;
    
    // Place the content at the center of the screen.
    NSRect contentRect;
    contentRect.origin.x = (screenSize.width - size.width) / 2;
    contentRect.origin.y = (screenSize.height - size.height) / 2;
    contentRect.size = size;
    
    // Create an empty window.
    NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:contentRect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
    if (!window) return self;
    
    // Create itself.
    self = [super initWithWindow:window];
    if (!self) return self;
    
    // Create a GLVXView instance and initialize the window.
    window.contentView = [[GLVXView alloc] initWithGLV:glv frame:contentRect];
    window.delegate = self;
    window.title = title;
    
    // Initialize the GLV instance.
    _glv = glv;
    glv::Dereference(_glv).extent(size.width, size.height);
    glv::Dereference(_glv).broadcastEvent(glv::Event::WindowCreate);
    
    return self;
}

#pragma mark Window handling events

- (void)windowDidResize:(NSNotification *)notification
{
    glv::GLV& target = glv::Dereference(_glv);
    CGSize size = [self.window.contentView frame].size;
    target.extent(size.width, size.height);
    target.broadcastEvent(glv::Event::WindowResize);
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
    
    // Flip vertically.
    NSPoint point = theEvent.locationInWindow;
    CGSize size = [self.window.contentView frame].size;
    point.y = size.height - point.y;
    
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
