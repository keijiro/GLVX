#import "GLVXAppDelegate.h"
#import "GLVXWindowController.h"
#import "TestViews.h"

@implementation GLVXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _widgets = [[GLVXWindowController alloc] initWithGLV:GetWidgetsTestView() size:CGSizeMake(800, 600) title:@"GLV Widgets"];
    [_widgets showWindow:nil];

    _text = [[GLVXWindowController alloc] initWithGLV:GetTextTestView() size:CGSizeMake(600, 300) title:@"Example: draw::text"];
    [_text showWindow:nil];
}

@end
