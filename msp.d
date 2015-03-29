//
// TODO:
// Exit when ESCAPE key is pressed

import std.stdio;
import std.array;
import std.string;
import std.datetime;
import core.thread;
import std.file : read;
import std.uni : toLower;
import std.conv : to;
import std.json;

import glib.Timeout;

import gtk.Box;
import gtk.Button;
import gtk.Entry;
import gtk.EntryBuffer;
import gtk.Frame;
import gtk.Label;
import gtk.Image;
import gtk.Main;
import gtk.MainWindow;
import gtk.Stack;
import gtk.Viewport;
import gtk.Widget;
import gtk.Window;
import gtk.DrawingArea;

import gdk.Threads;
import gdk.Color;
import gdk.Pixbuf;
import gdk.Screen;

import cairo.Context;
import cairo.ImageSurface;

//shared Image backImage;
//shared Image forwardImage;
//shared Image refreshImage;
//shared Label newTabLabel;

__gshared Image[] images;

shared Color white;
shared Color lightBlue;

struct PageInfo
{
  string address;
  Widget tab;
  Widget content;
}

struct GtkBrowserWindow
{
  Widget gtkGui;

  Box tabsGtkBox;
  auto tabs = appender!(Widget[])();

  size_t currentTabIndex = size_t.max;
  //Widget currentTab;
  //Widget currentTabContents;

  Entry addressEntry;

  Frame contentFrame;
  auto tabContents = appender!(Widget[])();

  void error(string message)
  {
    writeln(message);
    stdout.flush();
  }

  // Callbacks
  void newTabClicked(Button newTabButton)
  {
    addNewTab(true);
  }
  void tabClicked(Button tabButton)
  {
    foreach(i, tab; tabs.data) {
      if(tab == tabButton) {
	showTab(i);
	return;
      }
    }
    error("got tabClicked callback from unknown tabButton");
  }
/+
  void onWindowActivateFocus(Window window)
  {
    writeln("onWindowActivateFocus");
    stdout.flush();
  }
  void onWindowSetFocus(Window window)
  {
    writeln("onWindowSetFocus");
    stdout.flush();
  }
+/
  void addNewTab(bool showContents)
  {
    auto newTab = new Button("New Tab");
    newTab.addOnClicked(&tabClicked);
    newTab.modifyBg(GtkStateType.NORMAL, cast(Color)lightBlue);

    tabs.put(newTab);
    tabsGtkBox.packStart(newTab, false, false, 0);
    newTab.show();

    auto newTabContent = new Label(format("New Tab (index=%s)", tabs.data.length - 1));
    newTabContent.modifyBg(GtkStateType.NORMAL, cast(Color)white);
    tabContents.put(newTabContent);

    if(showContents) {
      showTab(tabs.data.length - 1);
    }
  }
  void showTab(size_t newTabIndex)
  {
    if(newTabIndex == currentTabIndex) return;

    if(currentTabIndex != size_t.max) {
      Widget oldTab = tabs.data[currentTabIndex];
      oldTab.modifyBg(GtkStateType.NORMAL, cast(Color)lightBlue);
    }
    Widget newTab = tabs.data[newTabIndex];
    newTab.modifyBg(GtkStateType.NORMAL, cast(Color)white);

    Widget tabContents = tabContents.data[newTabIndex];
    contentFrame.removeAll();
    contentFrame.add(tabContents);
    tabContents.show();

    currentTabIndex = newTabIndex;
  }
}

__gshared MainWindow window;
//__gshared CairoFadeImage cairoFade;
//__gshared ImageSurface image1, image2;

Image load(string filename)
{
  writefln("Loading '%s'", filename);
  stdout.flush();
  auto imagePixBuf = new Pixbuf(filename);

  // Save Png
  if(!filename.endsWith(".png")) {
    imagePixBuf.savev(filename ~ ".png", "png", null, null);
  }
  
  writefln("Scaling...");
  stdout.flush();
  imagePixBuf = imagePixBuf.scaleSimple(2560, 1600, GdkInterpType.HYPER);

  return new Image(imagePixBuf);
}

void main(string[] args)
{
  Main.init(args);

  //
  // Setup Global Data
  //
  /+
  //newTabLabel  = cast(shared Label)new Label("New Tab");
  white        = cast(shared Color)new Color(255, 255, 255);
  lightBlue    = cast(shared Color)new Color(  0, 120, 255);
  +/
  window = new MainWindow("GtkNet");
  window.setDefaultSize(300, 300);
  window.setPosition(GtkWindowPosition.POS_CENTER);

  window.setDecorated(false);
  //window.fullscreen();


  //auto cairoFadeImages = loadConfig("config.json");
  //return;

  
  //
  // Setup Icon
  //
  //auto icon = new Pixbuf("img/icon32.png");
  //window.setIcon(icon);

  //
  // Setup blank page
  //
  //auto windowContent = createWindowContent();
  //window.add(windowContent.gtkGui);
  //window.setFocus(windowContent.addressEntry);
  //window.addOnActivateFocus(&windowContent.onWindowActivateFocus);
  //window.addOnSetFocus(&windowContent.onWindowSetFocus);


  //images ~= new Image(`C:\temp\msp\TV1-1.jpg`);

  //load(`C:\temp\msp\TV1-1.jpg`);
  //load(`C:\temp\msp\TV1-2.jpg`);

  //firstImage = load(
  //secondImage = load(`C:\temp\msp\image2.png`);


  //image1 = ImageSurface.createFromPng(`C:\temp\msp\image1.png`);
  //image2 = ImageSurface.createFromPng(`C:\temp\msp\image2.png`);
  //image1 = ImageSurface.createFromPng(`C:\temp\msp\TV1-1.png`);
  //image2 = ImageSurface.createFromPng(`C:\temp\msp\TV1-2.png`);
  //cairoFade = new CairoFadeImage(image1, 500);
  
  //window.add(cairoFade.drawingArea);

  

  var lambImage = ImageSurface.createFromPng(`C:\temp\msp\lamb.png`);
  var kittiesImage = ImageSurface.createFromPng(`C:\temp\msp\kitties.png`);

/+
  extern(C) int startTransitionThread(void* data)
{
  TransitionThread transitionThread = new TransitionThread
    ([
      WaitAction( 4000, &delegates.switchToImage2),
      WaitAction( 4000, &delegates.switchToImage1)
      ]);
  transitionThread.start();
  return 0;
}
+/  
  
  

  //new Timeout(25, &delegates.fortyPerSecond);

  window.showAll();
  gdk.Threads.threadsAddIdle(&startTransitionThread, null);
  Main.run();

  //timeout.stop();
  //auto defaultScreen = Screen.getDefault();
  //defaultScreen.printInfo("defaultScreen");
}







struct CiaroImageRoll
{
  CairoTransitionImage transitionImage;
  ImageSurface[] imageRoll;
  size_t currentImageIndex;
  
  this(CairoTransitionImage transitionImage, ImageSurface[] imageRoll)
  {
    this.transitionImage = transitionImage;
    this.imageRoll = imageRoll;
  }
  void next()
  {
    currentImageIndex++;
    if(currentImageIndex >= imageRoll.length) {
      currentImageIndex = 0;
    }
    this.transitionImage.transitionTo(imageRoll[currentImageIndex]);
  }
}



interface CairoTransitionImage
{
  void transitionTo(ImageSurface image);
}


class CairoFadeImage : CairoTransitionImage
{
  DrawingArea drawingArea;
  ImageSurface currentImage;

  uint fadeMsecs;

  ImageSurface fadeImage;
  long fadeStartTime;

  this(ImageSurface image, uint fadeMsecs) {
    this.drawingArea = new DrawingArea();
    this.drawingArea.addOnDraw(&onDraw);
    this.drawingArea.addOnDestroy(&onDestroy);
    this.currentImage = image;
    this.fadeMsecs = fadeMsecs;
  }
  void transitionTo(ImageSurface image)
  {
    this.fadeImage = image;
    this.fadeStartTime = Clock.currStdTime();
    //writefln("--> fadeTo(&this=%s) startTime = %s", &this, this.fadeStartTime);
    new Timeout(1, &timeoutCallback);
  }
  bool timeoutCallback()
  {
    if(fadeImage is null)
      return false;

    drawingArea.queueDraw();
    //window.queueDraw();
    return true;
  }
  void onDestroy(Widget widget)
  {
    //writefln("TODO: implement onDestroy");
    //stdout.flush();
  }
  bool onDraw(Context c, Widget widget)
  {
    stdout.flush();
    if(fadeImage is null) {
      c.setSourceSurface(currentImage, 0, 0);
      c.paint();
    } else {
      auto diffMsecs = convert!("hnsecs", "msecs")(Clock.currStdTime() - fadeStartTime);
      if(diffMsecs >= fadeMsecs) {
	this.currentImage = this.fadeImage;
	this.fadeImage = null;
	c.setSourceSurface(currentImage, 0, 0);
	c.paint();
      } else {
	c.setSourceSurface(currentImage, 0, 0);
	c.paint();
	c.setSourceSurface(fadeImage, 0, 0);
	c.paintWithAlpha(cast(double)diffMsecs / cast(double)fadeMsecs);
      }
    }
    return true;
  }
}

extern(C) int uiCallback(void* data)
{
  writefln("uiCallback: data = 0x%x", data);stdout.flush();

  WaitAction* waitAction = cast(WaitAction*)data;
  waitAction.action();

  return 0;
}
extern(C) int startTransitionThread(void* data)
{
  TransitionThread transitionThread = new TransitionThread
    ([
      WaitAction( 4000, &delegates.switchToImage2),
      WaitAction( 4000, &delegates.switchToImage1)
      ]);
  transitionThread.start();
  return 0;
}

struct WaitAction
{
  uint msecs;
  void delegate() action;
}

class TransitionThread : Thread
{
  WaitAction[] waitActions;
  size_t nextWaitAction;
  //uint loopMsecs;
  this(WaitAction[] waitActions)
  {
    super(&run);
    this.waitActions = waitActions;
  }
  private void run()
  {
    writefln("[TransitionThread] start");stdout.flush();
    while(true) {
      writefln("[TransitionThread] wait %s msecs", waitActions[nextWaitAction].msecs);stdout.flush();
      Thread.sleep(dur!("msecs")(waitActions[nextWaitAction].msecs));

      gdk.Threads.threadsAddIdle(&uiCallback, &(waitActions[nextWaitAction]));

      nextWaitAction++;
      if(nextWaitAction >= waitActions.length) {
	nextWaitAction = 0;
      }
    }
    writefln("[TransitionThread] exit");stdout.flush();
  }
}

struct MyDelegates
{
  void switchToImage2()
  {
    writefln("--> switchToImage2");stdout.flush();
    // !!!!!!!!!!!!!!!!!!!!!!!!!!
    // TODO: do this using invoke
    cairoFade.transitionTo(image2);
  }
  void switchToImage1()
  {
    writefln("--> switchToImage1");stdout.flush();
    //window.removeAll();
    //window.add(firstImage);
    //window.showAll();
    cairoFade.transitionTo(image1);
  }
/+
  bool fortyPerSecond()
  {
    foreach(fadeImage; fadingImages) {
      if(fadeImage.fadeIteration < fadeImage.fadeCount) {
	window.queueDraw();
      }
    }
    return true;
  }
+/
}
MyDelegates delegates;    

/+
extern (C) fadeOut(void* ptr)
{
  
}
+/

/+
struct IntSize
{
  int width, height;
}
IntSize scale(int x, int y, int ontoX, int ontoY)
{
  auto diffX = (x >= ontoX) ? x - ontoX : ontoX - x;
  auto diffY = (y >= ontoY) ? y - ontoY : ontoY - y;

  if(diffX > diffY) {
    if(x >= ontoX) {
      
    } else {
    }
  } else {
  }
  
}
+/


void printInfo(Screen screen, string identifier)
{
  writefln("%s.getNumber() = %s", identifier, screen.getNumber());
  writefln("%s.getWidth() = %s", identifier, screen.getWidth());
  writefln("%s.getHeight() = %s", identifier, screen.getHeight());
  writefln("%s.makeDisplayName() = %s", identifier, screen.makeDisplayName());
  writefln("%s.getPrimaryMonitor() = %s", identifier, screen.getPrimaryMonitor());
  auto monitorCount = screen.getNMonitors();
  writefln("%s.getNMonitors() = %s", identifier, monitorCount);
  foreach(i; 0..monitorCount) {
    Rectangle rect;
    writefln("%s.getMonitorPlugName(%s) = %s", identifier, i, screen.getMonitorPlugName(i));
    screen.getMonitorGeometry(i, rect);
    writefln("%s.getMonitorGeometry(%s) = %s", identifier, i, rect);
    screen.getMonitorWorkarea(i, rect);
    writefln("%s.getMonitorWorkarea(%s) = %s", identifier, i, rect);
  }
  //writefln("%s.() = %s", identifier, screen.());
  stdout.flush();
}






//
// JSON Parse Logic
//
string namePrefix(JSON_TYPE type)
{
  if (type == JSON_TYPE.ARRAY || type == JSON_TYPE.OBJECT || type == JSON_TYPE.INTEGER) {
    return "an";
  } else {
    return "a";
  }
}
template namePrefix(string type)
{
  static if(type == "array" || type == "object" || type == "integer") {
    enum namePrefix = "an";
  } else static assert(0, "no namePrefix for type "~type);
}
auto as(string type)(JSONValue v, lazy string context)
{
  try {
    mixin("return v."~type~";");
  } catch(JSONException e) {
    throw new JSONException(context~format(" expected %s %s but got %s %s", namePrefix!type, type,
					   namePrefix(v.type), to!string(v.type).toLower));
  }
}
auto getProp(string type)(JSONValue[string] object, string property, lazy string objectIdentifier)
{
  if(property !in object)
    throw new JSONException(format("%s is missing property '%s'", objectIdentifier, property));
  try {
    mixin("return object[property]."~type~";");
  } catch(Exception e) {
    throw e;
  }
}
CairoFadeImage[] loadConfig(string filename)
{
  auto jsonText = cast(char[])read(filename);
  auto jsonRoot = parseJSON(jsonText);
  
  auto cairoFadeImages = appender!(CairoFadeImage[])();

  foreach(i, imageConfigArray; jsonRoot.as!"array"("While parsing start of config file")) {

    JSONValue[string] imageConfig = imageConfigArray.as!"object"(format("While parsing start of element at root index %s", i));

    string objectId = format("Graphic config object at index %s", i);
    auto type = imageConfig.getProp!"str"("Type", objectId);
    if(type == "Slideshow") {

      auto top = imageConfig.getProp!"integer"("Top", objectId);
      auto left = imageConfig.getProp!"integer"("Left", objectId);

      auto images = imageConfig.getProp!"array"("Images", objectId);
      
      
    } else {
      throw new JSONException(format("Unknown graphic Type '%s'", type));
    }
    
  }

  return null;
}




