#include "glv.h"
#include "GLVX.h"
#include "TestViews.h"

namespace
{
    using namespace glv;
    
    struct CharView : public View{
        CharView(const Rect& r=Rect(80, 110))
        :	View(r), input(0), thickness(2)
        {
            addHandler(Event::MouseDrag, Behavior::mouseMove);
            addHandler(Event::MouseDrag, Behavior::mouseResize);
            disable(CropSelf);
        }
        
        int input;
        float thickness;
        
        virtual void onDraw(GLV& g){
            using namespace glv::draw;
            scale(w/8, h/11);	// scale characters to extent of view
            
            color(colors().fore, 0.2);
            lineWidth(1);
            grid(g.graphicsData(), 0,0,8,11,8,11);
            
            color(colors().fore, 0.5);
            shape(Lines,0,8,8,8);	// draw base line
            
            lineWidth(thickness);
            color(colors().fore);
            
            char str[2] = {static_cast<char>(input), '\0'};
            text(str);
        }
        
        virtual bool onEvent(Event::t e, GLV& glv){
            
            if(Event::KeyDown == e){
                int key = glv.keyboard().key();
                
                switch(key){
                    case Key::Up:   thickness += 0.5; break;
                    case Key::Down: thickness -= 0.5; if(thickness<1) thickness=1; break;
                    default: input = key;
                }
            }
            
            return false;
        }
    };
    
    
    struct ColorView : public View{
        
        ColorView(const Rect& r=Rect(40)): View(r){}
        
        virtual void onDraw(GLV& g){
            int divH = 32, divS = 16;
            float incH = 1./divH, incS = 1./divS;
            
            for(int i=0; i<divS; ++i){
                
                float sat = (float)i * incS;
                Color col;
                
                for(int j=0; j<divH; ++j){
                    float hue = (float)j * incH;
                    col.setHSV(hue, 1, sat*sat);
                    draw::color(col);
                    draw::rectangle(w * hue, h * sat, w * (hue + incH), h * (sat + incS));
                }
            }
        }
        
        virtual bool onEvent(Event::t e, GLV& glv){
            if(parent && glv.mouse().left()){
                float sat = glv.mouse().yRel()/h;
                parent->colors().back.setHSV(glv.mouse().xRel()/w, 1, sat*sat);
                return false;
            }
            return true;
        }
    };
    
    
    
    /// View that mimics another View
    class CopyCat : public View{
    public:
        
        /// @param[in]	src				The View to mimic
        /// @param[in]	controllable	Whether to respond to input events
        CopyCat(View& src, bool controllable=true)
        :	View(src), mSource(&src)
        {	if(!controllable) disable(Controllable); }
        
        View& source() const { return *mSource; }
        CopyCat& source(View& v){ if(&v != this) mSource=&v; return *this; }
        
        virtual void onDraw(GLV& g){
            space_t sw, sh; getDim(sw, sh); setDim(w, h);
            source().onDraw(g);
            setDim(sw, sh);
        }
        
        virtual bool onEvent(Event::t e, GLV& g){
            space_t sw, sh; getDim(sw, sh); setDim(w, h);
            bool r = source().onEvent(e, g);
            setDim(sw, sh);
            return r;
        }
        
    protected:
        View * mSource;
        void getDim(space_t& sw, space_t& sh){ sw = source().w; sh = source().h; }
        void setDim(space_t  sw, space_t  sh){ source().w = sw; source().h = sh; }
    };
    
    
    
    class RasterView : public View{
    public:
        RasterView(const Rect& r, int nx, int ny)
        :	View(r), mSizeX(nx), mSizeY(ny), mPrim(draw::LineStrip)
        {
            enable(DrawGrid);
            deselect();
        }
        
        virtual void onDraw(GLV& g){
            using namespace glv::draw;
            
            GraphicsData& gd = g.graphicsData();
            
            if(enabled(DrawGrid)){
                color(colors().fore, 0.25);
                grid(gd, 0,0,w,h,mSizeX,mSizeY, false);
            }
            
            color(colors().fore, 0.65);
            stroke(2);
            
            gd.reset();
            for(unsigned i=0; i<mPoints.size(); ++i){
                float x,y;
                indexToPoint(x,y, mPoints[i]);
                gd.addVertex(x,y);
            }
            paint(mPrim, gd);
            
            draw::enable(PointSmooth);
            stroke(6);
            
            gd.reset();
            for(int i=0; i<(int)mPoints.size(); ++i){
                float x,y;
                indexToPoint(x,y, mPoints[i]);
                if(isSelected() && mSelected == i){
                    gd.addColor(Color(1,0,0));
                }
                else{
                    gd.addColor(colors().fore);
                }
                gd.addVertex(x,y);
            }
            paint(Points, gd);
            
        }
        
        virtual bool onEvent(Event::t e, GLV& g){
            
            const Mouse& m = g.mouse();
            const Keyboard& k = g.keyboard();
            
            int idx; pointToIndex(idx, m.xRel(), m.yRel());
            
            switch(e){
                case Event::MouseDown:
				{
                    
                    if(k.shift()){		// append new point
                        mPoints.push_back(idx);
                    }
                    else if(k.ctrl()){	// insert new point
                        float dist = 1e7;
                        int inear = -1;
                        for(int i=mPoints.size()-1; i>0; --i){
                            int i1 = i-1;
                            int i2 = i;
                            float x1,y1, x2,y2, xn,yn;
                            indexToPoint(x1,y1, mPoints[i1]);
                            indexToPoint(x2,y2, mPoints[i2]);
                            indexToPoint(xn,yn, idx);
                            // measure distance to midpoint
                            float xm = (x1+x2)*0.5;
                            float ym = (y1+y2)*0.5;
                            float d = (xm-xn)*(xm-xn) + (ym-yn)*(ym-yn);
                            if(d < dist){ dist=d; inear=i2; }
                        }
                        if(inear >= 0){
                            mPoints.insert(mPoints.begin() + inear, idx);
                        }
                    }
                    
                    bool clickMatch=false;
                    for(int i=mPoints.size()-1; i>=0; --i){
                        if(mPoints[i] == idx){
                            mSelected = i;
                            clickMatch = true;
                            break;
                        }
                    }
                    
                    if(!clickMatch) deselect();
                    
                    
				}
                    return false;
                    
                case Event::MouseDrag:
                    if(isSelected()){
                        mPoints[mSelected] = idx;
                    }
                    return false;
                    
                case Event::KeyDown:
                    
                    switch(k.key()){
                        case 'c': mPoints.clear(); return false;
                        case 'p':
                            for(unsigned i=0; i<mPoints.size(); ++i){
                                printf("%c%d", i?',':'\0', mPoints[i]);
                            } printf("\n");
                            return false;
                        case '1': mPrim = draw::Lines; return false;
                        case '2': mPrim = draw::LineStrip; return false;
                        case '3': mPrim = draw::LineLoop; return false;
                        case '4': mPrim = draw::Triangles; return false;
                        case '5': mPrim = draw::TriangleStrip; return false;
                        case '6': mPrim = draw::TriangleFan; return false;
                        case 'g': toggle(DrawGrid); return false;
                        case Key::Delete:
                        case Key::Backspace:
                            if(isSelected()) mPoints.erase(mPoints.begin()+mSelected);
                            deselect();
                            return false;
                        default:;
                    }
                default:;
            }
            return true;
        }
        
    protected:
        int mSizeX, mSizeY;
        int mSelected;
        int mPrim;
        
        std::vector<int> mPoints;
        float subDivX() const { return w/mSizeX; }
        float subDivY() const { return h/mSizeY; }
        
        bool isSelected(){ return mSelected>=0; }
        void deselect(){ mSelected=-1; }
        
        void pointToIndex(int& idx, float x, float y) const {
            int ix = glv::clip<int>((x/w)*mSizeX, mSizeX-1);
            int iy = glv::clip<int>((y/h)*mSizeY, mSizeY-1);
            idx = iy*mSizeX + ix;	
        }
        
        void indexToPoint(float& x, float& y, int idx){
            int ix = idx % mSizeX;
            int iy = idx / mSizeX;
            x = ((ix+0.5)/mSizeX) * w;
            y = ((iy+0.5)/mSizeY) * h;
        }
        
    };
    
    struct MyGLV : public GLV
    {
        View hierView;
        View anchorView;
        RasterView rasterView;
        ColorView colorView;
        
        MyGLV()
        :   GLV(640, 640),
            rasterView(glv::Rect(200), 16, 16)
        {
            //---- Intialize GLV
            colors().set(StyleColor::WhiteOnBlack);
            colors().back.set(1,0.1);
            cloneStyle();
            colors().back.set(0);
            
            // Top view layout (2x2 grid)
            LayoutGrid layout(*this, 2, 2, 60);
            
            //---- Hierarchy View
            layout << hierView;
            hierView.addHandler(Event::MouseDrag, Behavior::mouseMove) << new Label("Hierarchy", 0, -10);
            
            LayoutGrid lg0(hierView, 2, 2, 14);
            for (int i = 0; i < 4; ++i)
            {
                View& v = (new View)->enable(CropChildren).addHandler(Event::MouseDrag, Behavior::mouseMove);
                lg0 << v;
                
                LayoutGrid lg(v, 2, 2, 14);
                for(int j=0; j<4; ++j)
                {
                    lg << (*(new View)).addHandler(Event::MouseDrag, Behavior::mouseMove);
                }
            }
            
            //---- Anchored children view
            layout << anchorView;
            anchorView.disable(DrawBack);
            anchorView.addHandler(Event::MouseDrag, Behavior::mouseResizeCorner);
            anchorView.addHandler(Event::MouseDrag, Behavior::mouseMove);
            anchorView << new Label("Anchored Children", 0, -10);
            
            LayoutGrid lg(anchorView, 3, 3, 14);
            for (int i = 0; i < 9; ++i)
            {
                lg << (new View)->anchor((i % 3) / 3., (i / 3) / 3.).stretch(1 / 3., 1 / 3.);
            }
            
            //---- Keyboard char view
            layout << rasterView;
            rasterView.style(&style());
            rasterView << new Label("Raster View", 0, -10);
            
            //---- Color view
            layout << colorView;
            colorView << new Label("Colorful View", 0, -10);
            colorView << (new Label("Hue"))->size(6).anchor(Place::BC).pos(Place::TC,0,4);
            colorView << (new Label("Value", true))->size(6).anchor(Place::CL).pos(Place::CR,-4,0);
        }
    };
    
    MyGLV top;
}

extern "C" GLVREF GetMiscTestView()
{
    return MakeReference(top);
}
