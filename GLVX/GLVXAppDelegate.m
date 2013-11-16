#import "GLVXAppDelegate.h"
#import "GLVXWindowController.h"
#import "TestViews.h"

@implementation GLVXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _widgets = [[GLVXWindowController alloc] initWithGLV:GetWidgetsTestView()];
    [_widgets showWindow:nil];

    _text = [[GLVXWindowController alloc] initWithGLV:GetTextTestView()];
    [_text showWindow:nil];
}

@end
