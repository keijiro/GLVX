#import "GLVXView.h"
#import "glv.h"

#pragma mark Private members

@interface GLVXView ()
- (void)drawView;
@end

#pragma mark
#pragma mark DisplayLink Callbacks

static CVReturn DisplayLinkOutputCallback(CVDisplayLinkRef displayLink,
                                          const CVTimeStamp *now,
                                          const CVTimeStamp *outputTime,
                                          CVOptionFlags flagsIn,
                                          CVOptionFlags *flagsOut,
                                          void *displayLinkContext)
{
    GLVXView *view = (__bridge GLVXView *)displayLinkContext;
    [view drawView];
	return kCVReturnSuccess;
}

#pragma mark
#pragma mark Class implementation

@implementation GLVXView

#pragma mark Constructor and destructor

- (id)initWithGLV:(GLVREF)glv frame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _glv = glv;
        
        NSOpenGLPixelFormatAttribute attributes[] = {
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAPixelBuffer,
            NSOpenGLPFAColorSize, 32,
            NSOpenGLPFADepthSize, 24,
            0
        };
        
        self.pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
        self.openGLContext = [[NSOpenGLContext alloc] initWithFormat:self.pixelFormat shareContext:nil];
    }
    return self;
}

- (void)dealloc
{
    CVDisplayLinkStop(_displayLink);
    CVDisplayLinkRelease(_displayLink);
}

#pragma mark NSOpenGLView methods

- (void)prepareOpenGL
{
    [super prepareOpenGL];
    
//    [self.openGLContext makeCurrentContext];

    // Maximize framerate.
    GLint interval = 1;
    [self.openGLContext setValues:&interval forParameter:NSOpenGLCPSwapInterval];
    
    // Initialize DisplayLink.
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkOutputCallback, (__bridge void *)(self));

    CGLContextObj cglCtx = (CGLContextObj)(self.openGLContext.CGLContextObj);
    CGLPixelFormatObj cglPF = (CGLPixelFormatObj)(self.pixelFormat.CGLPixelFormatObj);
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglCtx, cglPF);
    
    CVDisplayLinkStart(_displayLink);
    
    // Add an observer for closing the window.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:self.window];
}

#pragma mark NSWindow methods

- (void)windowWillClose:(NSNotification *)notification
{
    // DisplayLink need to be stopped manually.
    CVDisplayLinkStop(_displayLink);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawView];
}

#pragma mark Private methods

- (void)drawView
{
    CGLContextObj cglCtx = (CGLContextObj)(self.openGLContext.CGLContextObj);

    // Lock DisplayLink.
    CGLLockContext(cglCtx);
    
    // Draw with GLV.
    CGSize size = self.frame.size;
    [self.openGLContext makeCurrentContext];
    glv::Dereference(_glv).drawGLV(size.width, size.height, 1.0 / 60);

    // Flush and unlock DisplayLink.
    CGLFlushDrawable(cglCtx);
    CGLUnlockContext(cglCtx);
}

@end
