//Some code modified from code taken from forum post by Kees Straatman, University of Leicester, 10 May 2014 
    
    
    macro "Add 1px time Tool - C0a0L18f8L818f" {



 leftButton=16; 
 x2=-1; y2=-1; z2=-1; flags2=-1; 



  getCursorLoc(x, y, z, flags); 
  if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {  // Only when mouse moves new locatation is logged 
  wait(20);      // Might have to be increased with large number of ROIs 
               if (flags&leftButton!=0) { 

                              makeRectangle(x, y, 3, 1); 
                                 roiManager("Add"); 
                                


    } 
         
   
           x2=x; y2=y; z2=z; flags2=flags;    // Only when mouse moves new location is logged 
           wait(10); 
      // Takes care that one mouse click is recorded as one mouse click 
      } 
} 



macro "Set BC to Bg Tool- T0912B" {
//get bg value
roiManager("select", 0);
getStatistics(area, mean, min, max);
backGround=max;
run("Brightness/Contrast...");
setMinAndMax(backGround, backGround+1);

}

