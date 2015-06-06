//
// mandelbrot.pde
// author: Zack Fleischman
//
// This dumps the mandelbrot set visualization to the window.
//

/////////////////////
// Parameters

// Number of images to write
int maxImages = 5000;

// Iterations to escape
int currentMaxIter = 30;
int maxIter = 50;

// Which window we are currently using.
MandelbrotWindow window = getCanonicalMandelbrotWindow();

// Zooming Params
double zoomSpeed = 0.1;
double currentZoom = 1.0;
double zoomFactor = 1.03;
// Interesting points to zoom in on
double[][] zoomPoints = new double[][]{
    {-0.9895494202241311, 0.27757489483067976},
    { -0.75, 0.1 }, // Seahorse Valley
    { 0.275, 0.0 } // Elephant Valley
};

// Which point index we are zooming in on
int currentZoomPointIdx = 0;
double xCenterOffset = 0.0;
double yCenterOffset = 0.0;
double offsetChangeSpeed = 0.05;

// 
// Program starts here.
//
void setup() {
    // Set the size of the canvas to the image size
    //size(1080, 720);
    size(640, 480);

    // Setup the initial window
    updateWindow();

    // Only draw once.
   // noLoop();
}

//
// Called after setup() finishes.
//
int frameNum = 1;
void draw() {
    long dt = getTimeDelta();
    if (frameNum % 20 == 0) {
        System.out.println("FPS: " + (1.0 / nanoToSeconds(dt)));
    }

    background(color(0));

    // Draw pixels
    loadPixels();
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            color c = getMandelbrotColorForWindow((double)x/width, (double)y/height, window);
            setPixel(x, y, c);
        }
    }
    updatePixels(); 

    // Update parameter states
    updateParameters();

    // Write image
    String fileName = "frames/mandelbrot_" + frameNum + ".jpg";
    System.out.println(fileName);
    save(fileName);
    frameNum++;
    if (frameNum > maxImages) {
        noLoop();
    }
}


void keyPressed() {
    updateCenterOffset();

    if (key == ' ') {
        currentZoom += zoomSpeed;
        zoomSpeed *= zoomFactor;
        redraw();
    }
    
    if (key == 'b') {
        zoomSpeed /= zoomFactor;
        currentZoom -= zoomSpeed;
        redraw();
    }
} 

///////////////// Classes /////////////////////
public class MandelbrotWindow {
    public double minX, maxX;
    public double minY, maxY;
    public MandelbrotWindow() {
        minX = -2.5;
        maxX = 1.0;
        minY = -1.0;
        maxY = 1.0;
    }
    public MandelbrotWindow(double minX, double maxX, double minY, double maxY) {
        this.minX = minX;
        this.maxX = maxX;
        this.minY = minY;
        this.maxY = maxY;
    }
}

/////////////////// Helpers ///////////////////

// Conversion to seconds from nano
double nanoToSeconds(long nano) {
    return nano / 1000000000.0;
}

// Get the time elapsed since the last time this was called
long lastTime = 0L;
long getTimeDelta() {
    long currentTime = System.nanoTime();
    long dt = currentTime - lastTime;
    if (lastTime == 0L) {
        dt = 0L;
    }
    lastTime = currentTime;
    return dt;
}

// Adjust the offset of the center.
void updateCenterOffset() {
    switch (key) {
        case 'j':
            yCenterOffset += offsetChangeSpeed;
            redraw();
            dumpCenter();
            break;
        case 'k':
            yCenterOffset -= offsetChangeSpeed;
            redraw();
            dumpCenter();
            break;
        case 'h':
            xCenterOffset -= offsetChangeSpeed;
            redraw();
            dumpCenter();
            break;
        case 'l':
            xCenterOffset += offsetChangeSpeed;
            redraw();
            dumpCenter();
            break;
        case '0':
            offsetChangeSpeed *= 1.5;
            System.out.println("Offset Change Speed: " + offsetChangeSpeed);
            break;
        case '9':
            offsetChangeSpeed /= 1.5;
            System.out.println("Offset Change Speed: " + offsetChangeSpeed);
            break;
    }
}

// Print the current center point to the screen
void dumpCenter() {
    double cX = zoomPoints[currentZoomPointIdx][0];
    double cY = zoomPoints[currentZoomPointIdx][1];
    System.out.println("Center Point: (" + (cX + xCenterOffset) + ", " + (cY + yCenterOffset) + ")");
}

// Set Pixel Color
void setPixel(int x, int y, color c) {
    // Use the formula to find the 1D location
    int loc = x + y * width;
    pixels[loc] = c;
}

// Update the program parameters.
void updateParameters() {
    // Window
    updateWindow();

    // Iterations
    //currentMaxIter++;
    //currentMaxIter %= maxIter;
    currentMaxIter+=5;
    currentMaxIter = 1000;

    // Zooming
    currentZoom += zoomSpeed;
    zoomSpeed *= zoomFactor;
    //if (currentZoom > maxZoom) {
    //     currentZoom = 1.0;
    //}
}

// Update the window to account for zoom and positioning
void updateWindow() {
    double cX = zoomPoints[currentZoomPointIdx][0];
    double cY = zoomPoints[currentZoomPointIdx][1];
    cX += xCenterOffset;
    cY += yCenterOffset;
    window = getMandelbrotWindow(cX, cY, currentZoom);
}

// Get canonical Mandelbrot Set Window
MandelbrotWindow getCanonicalMandelbrotWindow() {
    return getMandelbrotWindow(-2.5 + (3.5/2.0), 0.0, 1.0);
}

// Get a mandelbrot set window from a center point and a zoom value
MandelbrotWindow getMandelbrotWindow(double cX, double cY, double zoom) {
    final double defaultWidth = 3.5;
    final double defaultHeight = 2.0;

    double windowWidth = defaultWidth / zoom;
    double windowHeight = defaultHeight / zoom;

    double minX = cX - (windowWidth/2.0);
    double maxX = cX + (windowWidth/2.0);
    double minY = cY - (windowHeight/2.0);
    double maxY = cY + (windowHeight/2.0);

    return new MandelbrotWindow(minX, maxX, minY, maxY);
}

// Get Mandelbrot color for image window
color getMandelbrotColorForWindow(double x, double y, MandelbrotWindow w) {
    double x0 = w.minX + (x * (w.maxX - w.minX));
    double y0 = w.minY + (y * (w.maxY - w.minY));
    return getMandelbrotColor(x0, y0);
}

// Get Mandelbrot color for C(x0, y0)
color getMandelbrotColor(double x0, double y0) {
    double x = 0.0;
    double y = 0.0;
    int iteration = 0;
    double xTemp = 0.0;
    while (x*x + y*y < 4 && iteration < currentMaxIter)
    {
        xTemp = x*x - y*y + x0;
        y = 2*x*y + y0;
        x = xTemp;
        iteration++;
    }
    return getColor(iteration);
}

// Return a color for the iteration.
color getColor(int iteration) {
    color c = color(0);
    if (iteration < currentMaxIter) {
        c = color(255);
    }
    return c;
}
