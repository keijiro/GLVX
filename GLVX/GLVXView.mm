#import "GLVXView.h"
#import "glv.h"

@implementation GLVXView

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
	[self drawView];
	return kCVReturnSuccess;
}

static CVReturn DisplayLinkOutputCallback(CVDisplayLinkRef displayLink,
                                          const CVTimeStamp *now,
                                          const CVTimeStamp *outputTime,
                                          CVOptionFlags flagsIn,
                                          CVOptionFlags *flagsOut,
                                          void *displayLinkContext)
{
    GLVXView *glView = (__bridge GLVXView *)displayLinkContext;
    CVReturn result = [glView getFrameForTime:outputTime];
    return result;
}

- (void)awakeFromNib
{
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

- (void)dealloc
{
    CVDisplayLinkStop(_displayLink);
    CVDisplayLinkRelease(_displayLink);
}

- (void)prepareOpenGL
{
    [super prepareOpenGL];
    
    [self initGL];
    
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkOutputCallback, (__bridge void *)(self));
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, (CGLContextObj)(self.openGLContext.CGLContextObj), (CGLPixelFormatObj)(self.pixelFormat.CGLPixelFormatObj));
    CVDisplayLinkStart(_displayLink);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:self.window];
}

- (void)windowWillClose:(NSNotification *)notification
{
    CVDisplayLinkStop(_displayLink);
}

- (void)initGL
{
    [self.openGLContext makeCurrentContext];
    
    GLint interval = 1;
    [self.openGLContext setValues:&interval forParameter:NSOpenGLCPSwapInterval];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawView];
}

- (void)drawView
{
    CGLLockContext((CGLContextObj)self.openGLContext.CGLContextObj);
    
    [self.openGLContext makeCurrentContext];

    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    if (_glv)
    {
        glv::Dereference(_glv).drawGLV(self.frame.size.width, self.frame.size.height, 1.0 / 60);
    }

    CGLFlushDrawable((CGLContextObj)self.openGLContext.CGLContextObj);
    CGLUnlockContext((CGLContextObj)self.openGLContext.CGLContextObj);
}

@end
