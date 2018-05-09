//Taken from an ImageJ forumn post by Kees Straatman, University of Leicester, 10 May 2014 

//This code monitors for mouse clicks and will delete the selected ROIs when its name
//label is clicked on.

 if (nImages==0) exit("There is no image open"); 
 if (!isOpen("ROI Manager")) exit("There in no ROI manager open"); 
 if (roiManager("count")==0) exit("There are no ROIs loaded in the ROI manager"); 
 roiManager("Associate", "true"); 
 roiManager("Centered", "false"); 
 roiManager("UseNames", "true"); 
 setTool("rectangle"); 
 roiManager("Show All with labels"); 
 roiManager("Show All"); 
 roiManager("Deselect"); 
 leftButton=16; 
 x2=-1; y2=-1; z2=-1; flags2=-1; 
 logOpened = false; 
 print("Close this window when finished"); 
 while (!logOpened || isOpen("Log")) { 
  getCursorLoc(x, y, z, flags); 
  if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {  // Only when mouse moves new locatation is logged 
  wait(20);      // Might have to be increased with large number of ROIs 
               if (flags&leftButton!=0) { 
    if (roiManager("index")!=-1){  // Check that a ROI is selected 
     
    if( roiManager("index") >=4) {
     roiManager("Delete"); 
    }
    
    }
               } 
               logOpened = true; 
    } 
           x2=x; y2=y; z2=z; flags2=flags;    // Only when mouse moves new location is logged 
           wait(10); 
      // Takes care that one mouse click is recorded as one mouse click 
      } 


