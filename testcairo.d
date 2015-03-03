import std.stdio;

import gtk.MainWindow;
import gtk.DrawingArea;
import gtk.Main;
import gtk.Widget;

import glib.Timeout;

import cairo.Surface;
import cairo.ImageSurface;
import cairo.Context;

__gshared MainWindow window;

struct FadeImage {
  ImageSurface image;
  ImageSurface surface;

  bool fading;

  int width, height;
}
__gshared FadeImage fadeImage;

void main(string[] args)
{
  // Setup fade image
  fadeImage.image = ImageSurface.createFromPng(`C:\temp\msp\drive.png`);
  fadeImage.width = fadeImage.image.getWidth();
  fadeImage.height = fadeImage.image.getHeight();
  fadeImage.surface = ImageSurface.create(cairo_format_t.ARGB32, fadeImage.width, fadeImage.height);
  fadeImage.fading = true;

  Main.init(args);

  window = new MainWindow("GtkNet");
  window.setDefaultSize(300, 300);
  window.setPosition(GtkWindowPosition.POS_CENTER);

  auto drawingArea = new DrawingArea();
  window.add(drawingArea);

  drawingArea.addOnDraw(&delegates.onDraw);
  drawingArea.addOnDestroy(&delegates.onDestroy);
  

  //auto surface = new Surface();
  //auto cr = surface.create();
/+
  auto imageSurface = ImageSurface.create(cairo_format_t.ARGB32, 390, 60);
  auto cr = Context.create(imageSurface);

  cr.setSourceRgb(0, 0, 0);
  cr.selectFontFace("Sans", cairo_font_slant_t.NORMAL, cairo_font_weight_t.NORMAL);
  cr.setFontSize(40.0);

  cr.moveTo(10.0, 50.0);
  cr.showText("Disziplin ist Macht");

  imageSurface.writeToPng(`C:\temp\testcairo.png`);

  cr.destroy();
  imageSurface.destroy();
+/

  new Timeout(25, &delegates.timeoutCallback);
  
  window.showAll();
  Main.run();
}

struct MyDelegates
{
  bool timeoutCallback()
  {
    if(!fadeImage.fading)
      return false;

    window.queueDraw();
    return true;
  }

  enum fadeLineCount = 30;
  bool onDraw(Context c, Widget widget)
  {
    //writeln("onDraw");
    //stdout.flush();

    
    /+
    c.setSourceRgb(0, 0, 0);
    c.selectFontFace("Sans", cairo_font_slant_t.NORMAL, cairo_font_weight_t.NORMAL);
    c.setFontSize(40);

    c.moveTo(10, 50);
    c.showText("Hello, World!");
    +/
/+
    static int count = 0;

    auto newC = Context.create(fadeImage.surface);

    for(auto i = 0; i < fadeImage.height; i+=(fadeLineCount-1)) {
      for(auto j = 0; j < count; j++) {
	newC.moveTo(0, i+j);
	newC.lineTo(fadeImage.width, i+j);
      }
    }

    count++;
    if(count == fadeLineCount) {
      fadeImage.fading = false;
    }

    c.setSourceSurface(fadeImage.image, 0, 0);
    c.maskSurface(fadeImage.surface, 0, 0);
    newC.stroke();
    //newC.paint();
    newC.destroy();
    
    return true;
+/
    static int count = 0;

    count++;
    if(count == 10) {
      fadeImage.fading = false;
    }
    
    c.setSourceSurface(fadeImage.image, 0, 0);
    c.maskSurface(fadeImage.surface, 0, 0);
    c.paintWithAlpha(.1 * count);

    
    return true;

    
  }
  void onDestroy(Widget widget)
  {
    writeln("onDestroy");
    stdout.flush();
  }
}
MyDelegates delegates;
