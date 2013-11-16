#import "GLVXAppDelegate.h"
#import "GLVXWindowController.h"
#import "GLVX.h"
#import "glv.h"
#import "glv_util.h"

namespace
{
    glv::GLV top;
    glv::Slider sl11(glv::Rect(100, 20));
    glv::Slider2D sl21(glv::Rect(100, 100), 0.5, 0.5);
    glv::Button btn1(glv::Rect(20, 20), true);
    glv::Button btn2(glv::Rect(20, 20), false);
    glv::Button btn3(glv::Rect(20, 20), false, glv::draw::check);
    glv::SliderGrid<3> sg31(glv::Rect(100)), sg32(glv::Rect(100)), sg33(glv::Rect(100));
    glv::SliderGrid<2> sg21(glv::Rect(100));
    
    struct MyView3D : public glv::View3D
    {
        MyView3D(): View3D()
        {
            stretch(1,1);
            disable(glv::DrawBorder);
        }
        
        virtual void onDraw3D(glv::GLV& g)
        {
            using namespace glv;
            using namespace glv::draw;
            
            Color c;
            c.setHSV(sg31.getValue(0), sg31.getValue(1), sg31.getValue(2)*sg31.getValue(2));
            color(c);
            
            translate(sg32.getValue(0)*2-1, sg32.getValue(1)*2-1, -sg32.getValue(2)*2 -2.42);
            rotate(sg33.getValue(0)*360, sg33.getValue(1)*360, sg33.getValue(2)*360);
            scale(sg21.getValue(0), sg21.getValue(1));
            
            rectangle(-1, -1, 1, 1);
        }
    }
    v3D;
    
    struct MyGLV : public glv::GLV
    {
        bool onEvent(glv::Event::t e, GLV& g)
        {
            if (e == glv::Event::KeyDown)
            {
                switch (g.keyboard().key())
                {
                    case '`': toggle(glv::Visible); return false;
                }
            }
            if (e == glv::Event::MouseDrag)
            {
                if (g.keyboard().ctrl()) printf("ctrl");
                if (g.keyboard().shift()) printf("shift");
            }
            return true;
        }
    };
    
    void Initialize()
    {
        using namespace glv;
        
        top.colors().set(glv::HSV(0.3,0.,0.6), 0.55);
        top << v3D;
        
        //---- Add labels
        sg31 << (new Label("Color"))->anchor(Place::CR).pos(Place::CL, 4,0);
        sg31 << (new Label("H"))->size(6).anchor(1/3., 3/3.).pos(Place::BR, -4, -4);
        sg31 << (new Label("S"))->size(6).anchor(2/3., 2/3.).pos(Place::BR, -4, -4);
        sg31 << (new Label("V"))->size(6).anchor(3/3., 1/3.).pos(Place::BR, -4, -4);
        sg32 << (new Label("Translate"))->anchor(Place::CR).pos(Place::CL, 4,0);
        sg32 << (new Label("x"))->size(6).anchor(1/3., 3/3.).pos(Place::BR, -4, -4);
        sg32 << (new Label("y"))->size(6).anchor(2/3., 2/3.).pos(Place::BR, -4, -4);
        sg32 << (new Label("z"))->size(6).anchor(3/3., 1/3.).pos(Place::BR, -4, -4);
        sg33 << (new Label("Rotate"))->anchor(Place::CR).pos(Place::CL, 4,0);
        sg33 << (new Label("x"))->size(6).anchor(1/3., 3/3.).pos(Place::BR, -4, -4);
        sg33 << (new Label("y"))->size(6).anchor(2/3., 2/3.).pos(Place::BR, -4, -4);
        sg33 << (new Label("z"))->size(6).anchor(3/3., 1/3.).pos(Place::BR, -4, -4);
        sg21 << (new Label("Scale"))->anchor(Place::CR).pos(Place::CL, 4,0);
        sg21 << (new Label("x"))->size(6).anchor(1/2., 2/2.).pos(Place::BR, -4, -4);
        sg21 << (new Label("y"))->size(6).anchor(2/2., 1/2.).pos(Place::BR, -4, -4);
        
        sl11 << (new Label("Slider"))->anchor(Place::CL).pos(Place::CR, -4,0);
        sl21 << (new Label("Slider2D"))->anchor(Place::CL).pos(Place::CR, -4,0);
        sl21 << (new Label("X Param"))->size(6).anchor(Place::BC).pos(Place::BC, 0, -4);
        sl21 << (new Label("Y Param", true))->size(6).anchor(Place::CL).pos(Place::CL, 4,0);
        
        btn1 << (new Label("Button"))->anchor(Place::CR).pos(Place::CL, 4,0);
        btn2 << (new Label("Toggle"))->anchor(Place::CR).pos(Place::CL, 4,0);
        btn3 << (new Label("Checkbox"))->anchor(Place::CR).pos(Place::CL, 4,0);
        
        sg31.setValueMid();
        sg32.setValueMid();
        sg21.setValueMax();
        
        
        // Define south-bound layout. Views added to top GLV view.
        //Layout layout(Direction::S, 10, 30, 4, top);
        Placer layout(v3D, Direction::S, Place::TL, 10, 30, 4);
        
        layout << sg31 << sg32 << sg33 << sg21;
        
        
        // Put buttons in the bottom-left corner
        layout.pos(10, -10).flow(Direction::N).align(Place::BL);
        
        btn1.anchor(Place::BL);
        btn2.anchor(Place::BL);
        btn3.anchor(Place::BL);
        
        layout << btn3 << btn2 << btn1;
        
        
        // Put sliders in top-right corner
        layout.pos(-10, 30).flow(Direction::S).align(Place::TR);
        
        sl11.anchor(Place::TR);
        sl21.anchor(Place::TR);
        
        layout << sl11 << sl21;
        
        
        //  Vertical slider bank
        Slider vsb[8];
        layout.flow(Direction::S, 2);
        
        for(int i=0; i<8; ++i){
            char c[] = {static_cast<char>('1' + i), 0};
            vsb[i].anchor(Place::TR).extent(100, 10);
            layout << (vsb[i] << (new Label(c))->anchor(Place::CL).pos(Place::CL, 4,0));
        }
        
        
        // Horizontal slider bank
        Slider hsb[8];
        layout.flow(Direction::W).posX(-10);
        
        for(int i=7; i>=0; --i){
            char c[] = {static_cast<char>('1' + i), 0};
            hsb[i].anchor(Place::TR).extent(10, 150);
            layout << (hsb[i] << (new Label(c,true))->anchor(Place::BC).pos(Place::BC, 0, -4));
        }
        
        
        // Tool Bar
        Button toolBar[8];
        layout.pos(0, 0).flow(Direction::E, 0).align(Place::TL);
        
        for(int i=0; i<8; ++i){
            char c[] = {static_cast<char>('A' + i), 0};
            toolBar[i].disable(DrawBack | FocusHighlight).extent(40, 20);
            layout << (toolBar[i] << (new Label(c))->anchor(Place::CC).pos(Place::CC));
        }
    }
}

@implementation GLVXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    Initialize();
    _controller = [[GLVXWindowController alloc] initWithGLV:glv::MakeReference(top)];
    [_controller showWindow:nil];
}

@end
