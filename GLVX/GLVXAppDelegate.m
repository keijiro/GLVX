#import "GLVXAppDelegate.h"
#import "GLVXWindowController.h"
#import "TestViews.h"

@implementation GLVXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _widgets = [[GLVXWindowController alloc] initWithGLV:GetWidgetsTestView() title:@"GLV Widgets"];
    [_widgets showWindow:nil];

    _text = [[GLVXWindowController alloc] initWithGLV:GetTextTestView() title:@"Example: draw::text"];
    [_text showWindow:nil];
    
    _misc = [[GLVXWindowController alloc] initWithGLV:GetMiscTestView() title:@"GLV Test"];
    [_misc showWindow:nil];
}

@end
