// Sprite Converter
// Zane Cochran
// 24 DEC 2020
// Converts animated sprite sheets from Piskel to pixel arrays for the Adafruit GFX Library

String inFile = "";  // Global Variable to Store Filepath
PrintWriter pix;     // File to Hold Pixel Frame Info
PrintWriter mask;    // File to Hold Mask Frame Info 

void setup(){
  size(25, 25);
  selectInput("Piskel File", "fileSelected");
}

// Allow User to Select a Piskel File
void fileSelected(File selection) {
  if (selection == null) {exit();} 
  else {inFile = selection.getAbsolutePath(); convert();}
}


void convert(){
  // Get File and Set File Names
  String[] lines = loadStrings(inFile);
  
  String[] fPath = split(inFile, '/');
  String[] fRawName = split((fPath[fPath.length - 1]), '.');
  String fName = fRawName[0];
  String fPixName = fName + "_PIX.h";
  String fMaskName = fName + "_MASK.h";
  
  pix = createWriter(fPixName); 
  mask = createWriter(fMaskName); 

  // Get Frame Information
  int fCount = 0;
  int fWidth = 0;
  int fHeight = 0;
    
  String rawFrameCount = lines[2];
  String[] splitFrameCount = split(rawFrameCount, ' ');
  fCount = Integer.parseInt(splitFrameCount[2]);
  
  String rawFrameWidth = lines[3];
  String[] splitFrameWidth = split(rawFrameWidth, ' ');
  fWidth = Integer.parseInt(splitFrameWidth[2]);
  
  String rawFrameHeight = lines[4];
  String[] splitFrameHeight = split(rawFrameHeight, ' ');
  fHeight = Integer.parseInt(splitFrameHeight[2]);
  
  int framePix = fWidth * fHeight;
  int frameMask = ceil((fWidth * fHeight) / 8.0);
  
  // Write File Headers & DEFINE Variables
  pix.println("#define " + fName + "_COUNT " + fCount);  
  pix.println("#define " + fName + "_W " + fWidth);  
  pix.println("#define " + fName + "_H " + fHeight);  

  pix.println("const unsigned short " + fName + "_PIX[" + fCount + "][" + framePix + "] PROGMEM={");  
  mask.println("const uint8_t " + fName + "_MASK[" + fCount + "][" + frameMask + "] PROGMEM={");  

  // Recombine Split File Info into One Large String
  String rawFile = "";
  for (int i = 0 ; i < lines.length; i++){rawFile = rawFile + lines[i];}
  
  // Split File String into Individual Frames
  String[] fArrays = split(rawFile, '{');
  
  // Keep Track of Mask Bytes
  int maskByte = 0;
  int maskBitCounter = 0;
  
  // Loop through Each Frame
  for (int i = 2 ; i < fArrays.length; i++){
    String[] byteArray = split(fArrays[i], "0x");
    mask.print("{");
    pix.print("{");
    
    // Loop through each Byte of Frame
    for (int j = 0 ; j < byteArray.length; j++){
      String rawByte = byteArray[j];
      
      // Look for Valid Bytes
      if (rawByte.length() > 8){
        String byteMask = rawByte.substring(0, 2);
        String byteColorRev = rawByte.substring(2, 8);
        
        // Convert Mask Info to Binary and Write to Mask File
        maskByte = maskByte << 1;
        if(byteMask.equals("ff")){maskByte++;}
        maskBitCounter++;
        
        if(maskBitCounter > 7){
          mask.print(maskByte + ", ");
          maskByte = 0;
          maskBitCounter = 0;
        }
        
        // Convert Color Info to Binary and Write to Pix File
        pix.print(downgradeColor(byteColorRev) + ", ");
      }
    }
    
    // If there are fewer than 8 bits in last pixel array, fill last byte with 1's to complete
    if(maskBitCounter != 0){
      for (int k = 0; k < (8 - maskBitCounter); k++){maskByte = maskByte << 1; maskByte++;}
      mask.print(maskByte + ", ");
    }
    
    // Close Arrays
    mask.println("},");
    pix.println("},");
  }

 
  pix.println("};"); pix.flush(); pix.close();
  mask.println("};"); mask.flush(); mask.close();
  
  println("Done!");
  exit();
}


String downgradeColor(String c){
  String rawRC = c;
  String rawGC = c;
  String rawBC = c;
  
  String r = new StringBuilder(rawRC.substring(4, 6)).toString().toUpperCase();
  String g = new StringBuilder(rawGC.substring(2, 4)).toString().toUpperCase();
  String b = new StringBuilder(rawBC.substring(0, 2)).toString().toUpperCase();
    
  int rRaw = unhex(r);
  int newR = (int)map(rRaw, 0, 255, 0, 31);
  String rawR = binary(newR);
  String finalR = rawR.substring(27, 32);
  //println(finalR + ", " + binary(newR));
  
  int gRaw = unhex(g);
  int newG = (int)map(gRaw, 0, 255, 0, 63);
  String rawG = binary(newG);
  String finalG = rawG.substring(26, 32);
  //println(finalG + ", " + binary(newG));
  
  int bRaw = unhex(b);
  int newB = (int)map(bRaw, 0, 255, 0, 31);
  String rawB = binary(newB);
  String finalB = rawB.substring(27, 32);
  //println(finalB + ", " + binary(newB));
  
  String finalColorString = finalR + finalG + finalB;
  int finalColorInt = unbinary(finalColorString);
  String finalColorHex = hex(finalColorInt);
  
  String output = "0x" + finalColorHex.substring(4, 8);
  return(output);
}
