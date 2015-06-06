//
// mandelbrot.pde
// author: Zack Fleischman
//
// This dumps the mandelbrot set visualization to the window.
//

// Parameters
int currentMaxIter = 1;
int maxIter = 50;
MandelbrotWindow window = getMandelbrotWindow();

// 
// Program starts here.
//
void setup() {
    // Set the size of the canvas to the image size
    size(1080, 720);

    // Only draw once.
    //noLoop();
}

//
// Called after setup() finishes.
//
void draw() {  
    long dt = getTimeDelta();
    System.out.println("FPS: " + (1.0 / nanoToSeconds(dt)));

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

// Set Pixel Color
void setPixel(int x, int y, color c) {
    // Use the formula to find the 1D location
    int loc = x + y * width;
    pixels[loc] = c;
}

// Update the program parameters.
void updateParameters() {
    currentMaxIter++;
    currentMaxIter %= maxIter;
}

// Get current window for the animation.
MandelbrotWindow getMandelbrotWindow() {
    return new MandelbrotWindow();
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
