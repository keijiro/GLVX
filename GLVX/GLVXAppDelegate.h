#import <Cocoa/Cocoa.h>

@class GLVXWindowController;

@interface GLVXAppDelegate : NSObject <NSApplicationDelegate>
{
    GLVXWindowController *_widgets;
    GLVXWindowController *_text;
}

@end
