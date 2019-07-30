/* CS7029 Assignment 3 - Program 
   by Woon Him WONG, Lindy      
*/

// Libraries for defining a custom comparison operation
// to sort our PixelImages by their brightness.
import java.util.Comparator;
import java.util.Collections;

// PixelImage class:
// Storing information about each of the images
class PixelImage {
  float bLevel; // image's brightness level
  String path;
  PImage cache;
  boolean cached = false;
  
  PixelImage(float b, String p)
  {
    bLevel = b;
    path = p;
  }
  
  // Caching image function
  PImage image(){
    if (!cached) {
      cache = loadImage(path);
      
      //float proportion = 1;
      if (cache.width > cache.height) {
        cache.resize(0, cellHeight*outputScale);
      } else {
        cache.resize(cellWidth*outputScale, 0);
      }
      cached = true;
    }
    return cache;
  }
}

PImage sourceImage;
String sourceImageFilename = "mainIMAGE.jpg"; // main reference image
int numCellsPerSide = 100; // define the number of cells per side on the mosaiced image
int outputScale = 1; // the outputScale of the mosaiced images
int cellWidth, cellHeight; // the width and height of each mosaiced image
ArrayList<PixelImage> pixelImages; // the arrayList for storing the pixel images used in mosaiced image
PImage cap;
// buttons
int topBtnX, topBtnY;
int topBtnSize = 90;
color topBtnColor;
color topBtnHighlight;
color currentColor;
boolean[] buttonOver = {false, false, false,false,false,false,false,false};
boolean pressed = false;
//filter
int filterMode = -1;
//Store filter image of mosaiced image
PImage filterM;
boolean redraw = false;

// Customize comparison operation
// 
class PixelImageComparator implements Comparator<PixelImage> {
  public int compare(PixelImage img1, PixelImage img2)
  {
    return (int)(img1.bLevel - img2.bLevel);
    // 1,0 or -1 --> greater, equal or less than
  }
}

void setup()
{
  size(920,650);
  //  UI buttons 
  topBtnColor = color(255);
  topBtnHighlight = color(255,140,0);
  
  init();
} // end of setup()

void init()
{
  clear();
  background(75); // clear screen
  // Load the sourceimage
  sourceImage = loadImage(sourceImageFilename);
  sourceImage.resize(790,552);
  //selectInput("Select your source image to stylize: ", "file selected");
  // Scale the canvas based on the proportions of the source img, but somehow bigger
  // calculate the size of each cell based on the size of the sourImage
  cellWidth = 790/numCellsPerSide;
  cellHeight = 552/numCellsPerSide;
    //=== Process all tile images and create PixelImage objects 
  // 1. Get a list of all the names from image files
  java.io.File folder = new java.io.File(sketchPath("sources"));
  String[] tileImageFilenames = folder.list();
  
  // 2. Initialize ArrayList of pixelImages
  pixelImages = new ArrayList<PixelImage>();
  
  // 3. Loading images
  PImage img;
  // loop through all of the filenames that we found in the directory
  for (int i=0; i < tileImageFilenames.length; i++)
  {
    // progress indicator
    println(i + "/" + tileImageFilenames.length);
    if (tileImageFilenames[i].endsWith("jpg")) {
      img = loadImage(sketchPath("sources/" + tileImageFilenames[i]));
      // Resize it smaller!
      img.resize(50,50);
      // Caculate the average brightness of the image
      float imgBrightness = aveBrightness(img);
      // Create an new PixelImage object with bLevel and the path of the image.
      PixelImage pixelImage = new PixelImage(imgBrightness, sketchPath("sources/" + tileImageFilenames[i]));
      pixelImages.add(pixelImage);// add it to the ArrayList
    }
  }
  // Now use the custom comparison operator to sort pixelImages based on their bLevel (in ascending order)
  Collections.sort(pixelImages, new PixelImageComparator());
  // Draw the photo-mosaic
  drawPhotomosaic();
  // Draw original image (reference test)
  translate((numCellsPerSide-1) *cellWidth*outputScale+25, 0);
  // move slightly to the right
  scale(0.2);
  image(sourceImage,0,250);
}
void draw(){
  //clear();
  background(75); // clear screen
  update();
  drawBtns();
  if (pressed) {init(); pressed = false;} 
  switch(filterMode)
  {
      case -1: image(filterM,0,50,(numCellsPerSide-1) *cellWidth*outputScale, (numCellsPerSide-1) *cellHeight*outputScale);break;
      case 0: if (redraw==true) { drawPhotomosaic();}break; //image(,0,50,(numCellsPerSide-1) *cellWidth*outputScale, (numCellsPerSide-1) *cellHeight*outputScale); break;
      case 1: filterM.filter(GRAY); break;
      case 2: filterM.filter(ERODE); break;
      case 3: filterM.filter(DILATE);break;
      case 4: filterM.filter(BLUR,2);break;
      case 5: filterM.filter(BLUR,3);filterM.filter(POSTERIZE,4);break;
  }
  if (filterMode > 0)
  {
    image(filterM,0,50,(numCellsPerSide-1) *cellWidth*outputScale, (numCellsPerSide-1) *cellHeight*outputScale); // show the filtered image
    filterMode = -1;
  }
  // Draw original image (reference test)
  translate((numCellsPerSide-1) *cellWidth*outputScale+25, 0);
  // move slightly to the right
  scale(0.2);
  image(sourceImage,0,250);
  scale(8);
  if (mouseX > 0 && mouseX < (numCellsPerSide+1) *cellWidth*outputScale && mouseY> 50 && mouseY <(numCellsPerSide+1) *cellHeight*outputScale)
  {
    PImage magnifier = get(mouseX-5,mouseY-5,50,50);
    image(magnifier,(numCellsPerSide-100) *cellWidth*outputScale, 150,100,100);
  }
  else
  {
    stroke(75);
    fill(75);
    rect((numCellsPerSide-100) *cellWidth*outputScale, 150,100,100);
  }

}

void update()
{
  for (int i=0; i < buttonOver.length; i++)
  {
     switch(i) 
     {
        case 0: if (over(0,10,100,25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break;          // load button
        case 1: if (over(110,10,100,25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break;        // save as button
        case 2: if (over(0, height-30, 100, 25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break; // no filter button
        case 3: if (over(110, height-30, 100, 25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break;// filter 1 button
        case 4: if (over(220, height-30, 100, 25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break;// filter 2 button
        case 5: if (over(330, height-30, 100, 25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break;// filter 3 button
        case 6: if (over(440, height-30, 100, 25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break;// filter 4 button
        case 7: if (over(550,height-30,100,25)) { buttonOver[i] = true; } else { buttonOver[i] = false;} break;// filter 5 button
     } 
  }
}

void mousePressed()
{
  if (mouseButton == LEFT) 
  {
    for (int i=0; i < buttonOver.length; i++)
    {
      if (buttonOver[i] == true)
      {
        switch(i) {
          case 0: selectInput("Select a file to process:", "fileSelected"); break;
          case 1: captureAndSave(0,50,(numCellsPerSide-1) *cellWidth*outputScale, (numCellsPerSide-1) *cellHeight*outputScale); break;
          case 2: filterMode = 0; redraw = true;break;
          case 3:
          case 4:
          case 5:
          case 6:
          case 7: filterMode = i-2;break;
        }
        break;
      }
    }
  }
}

void addFilter(int num)
{
  switch(num) {
    case 0:  break; // no filter
    case 1:  break;
    case 2:  break;
    case 3:  break;
    case 4:  break;
    case 5:  break;
  }
}

// Draw the UI buttons on screen
void drawBtns()
{
  for (int i=0; i < buttonOver.length; i++)
  {
    if (buttonOver[i]) { fill(topBtnHighlight); } else { fill (topBtnColor);}
    stroke(155);
    switch (i)
    {
      case 0: rect(0,10, 100, 25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Load Image",15,28);
      break;
       case 1: rect(110,10,100,25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Save as...",130,28);
      break;
      case 2: rect(0, height-30, 100, 25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Reset Filter",20,height-30+18);
      break;
      case 3: rect(110, height-30, 100, 25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Gray Filter",15+113,height-30+18);
      break;
      case 4: rect(220, height-30, 100, 25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Erode Filter +",5+113*2,height-30+18);
      break;
      case 5: rect(330, height-30, 100, 25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Dilate Filter +",5+112*3,height-30+18); 
      break;
      case 6: rect(440, height-30, 100, 25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Blur Filter +",5+112*4,height-30+18);
      break;
      case 7: rect(550, height-30, 100, 25,5,5,5,5);
              textSize(12);
              fill(0);
              text("Special Filter +",5+111*5,height-30+18);
      break;
    }
  }
}

// Check the mouse hovers on which button
boolean over(int x, int y, int w, int h)
{
  if (mouseX >= x && mouseX <= x+w && mouseY >=y && mouseY <= y+h)
  {
    return true;
  } else {
    return false;
  }
}

// Caculate the average brightness of an image
float aveBrightness(PImage img) {
  float result = 0;
  for (int i = 0; i < img.pixels.length; i++) 
  {
    result += brightness(img.pixels[i]);
  }
  // average
  result /= img.pixels.length;
  return result;
}

// !!! function loops over the grid and draws the actual photomosaic
// 1) Calculate the average brightness of that area of the sourceimage
// 2) Pick one of the PixelImages based on their brightness
void drawPhotomosaic() {
  PImage workingImage = createImage(cellWidth, cellHeight, RGB);
  int i = 0;
  int total = numCellsPerSide*numCellsPerSide;
  
  for (int row = 0; row < numCellsPerSide; row++) 
  {
    for (int col = 0; col < numCellsPerSide; col++)
    {
      println("Loading..." + i+"/"+total);
      i++;
      // Copy the pixels from the sourceImage into working image
      workingImage.copy(sourceImage, col*cellWidth, row*cellHeight, cellWidth, cellHeight, 0, 0, cellWidth, cellHeight);
      // average brightness of this area of our sourceImage
      float b = aveBrightness(workingImage);
      // map from the range of potential brightnesses (i.e. 0 - 255) into the range
      // of indices of pixelImages ArrayList
      int imageIndex = (int)map(b, 0, 255, 0, pixelImages.size()-1);
      PImage cellImage = pixelImages.get(imageIndex).image();
      image(cellImage, col*cellWidth*outputScale, row*cellHeight*outputScale + 50); // display the image at the right position
  }
  }
  filterM = get(0,50,(numCellsPerSide-1) *cellWidth*outputScale, (numCellsPerSide-1) *cellHeight*outputScale);
  redraw=false; filterMode = -1;
}

// Load File Windows dialog pop up
void fileSelected(File selection)
{
  if (selection != null)
  {
    sourceImageFilename = (String)selection.getAbsolutePath();
    // Draw the photo-mosaic
    pressed = true;
  }
}
// Save File Windows dialog pop up
void saveSelected(File selection)
{
  if (selection != null)
  {
    cap.save(selection.getAbsolutePath()+".png");
  }
}
// Capture the mosaiced image from display and save it to target directory
void captureAndSave(int x, int y, int w, int h){
  cap = get(x, y, w, h);
  selectInput("Select a file to process:", "saveSelected");
  println("saved!");
}
