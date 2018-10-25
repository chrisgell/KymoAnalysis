

/*
 * Chris Gell
 * 9th May 2018
 * 
 * Semi-automated analysis of kymographs.
 * 
 * Load a red-green kymoe, select it in the drop down, enter the pizel size and time interval in code. When prompted mark ROIS for bg,
mark ROI for non-ends, mark roi for ends. The software will then thresholds and analyze particles using the max background pixel value as the threshold
Then correct the event ROIs, you can delete ROIs by following the prompts and clicking on them.
If you wish to see a threshoded image use the B tool. Not sensible to try to edit existing ones. But you can then add new one (make sure to hit 't' to
add them to the ROI manager.




TO DO NEXT!!!!!!!!!!
Revisit the structure where all of the data is saved and make sure summary, latice and end events go into seperate folders
these should be grouped otgether for analysis as appropriate - i.e. all of the streams for the same experiment on a given
day etc...



TO DO Write an igor routine that filters out unwanted events (i.e. only one wide).




DONE Need to make sure all ori are saved
DONE Need the MT length
DONE Need total number sof each event
DONE Best to put these in a log window and save all into a folder with same name as the kymo 
DONE- Make a shortcut to delete currently selected ROI in the manager.
DONE Need to a way for user to change the pixel size and time spacing. Perhaps other parameters too.
Half DONE Have ROI's in an ROI deleted? - now able to click a ROI to delete it. Not sure can do much else in a macro.
DONE Undo ROI delete? - Made it less likely to cause a problem.
DONE Click 1 pixel event





*/

//print (getDirectory("plugins"));

//Load any toolbar buttons needed.
run("Install...", "install=["+getDirectory("plugins")+"Scripts\\SLIM\\Friel\\Friel Dependencies\\Auto_Kymo_Add1px_ToolBar.ijm]");


//Need to make sure that a bounding rectangle is fit for the measurements
run("Set Measurements...", "bounding redirect=None decimal=3");

//waitForUser( "Pause","Set options");

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//EDIT THIS************************************************
//Time and spacing
frameInt=0.1; //Time lapse in seconds
pxSize=0.1;	//pixel size in microns
title = "Set parameters";
width=1024; height=1024;
Dialog.create("Set parameters");
Dialog.addNumber("Time interval (s)", frameInt);
Dialog.addNumber("Pixel size (um)", pxSize);
Dialog.show();
frameInt = Dialog.getNumber();
pxSize = Dialog.getNumber();
//print (frameInt);
//print (pxSize);
//*******************************************************
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

//clear the ROI manager
if (roiManager("count") !=0)  {
roiManager("deselect");
roiManager("delete");
}


//set up the ROI manager in a good way.
 roiManager("Show All with labels"); 
 roiManager("UseNames", "true"); 
 



 //create an array with a list of open window names
 n = nImages; 
    list = newArray(n); 
    //setBatchMode(true); 
    for (i=1; i<=n; i++) { 
        selectImage(i); 
        list[i-1] = getTitle; 
    } 
// create a dialog to get the user to give us the kymo to be analysed
title = "Choose Kymo";
width=1024; height=1024;
Dialog.create("Choose Kymo");
Dialog.addChoice("Type:", list);
Dialog.show();
kymoImageName = Dialog.getChoice();
selectWindow(kymoImageName);
kymoID=getImageID();


screenH = screenHeight;
screenW = screenWidth;
setLocation(200,0,500,screenH-50);



//going to have the user choose the 4 ROI
selectWindow(kymoImageName);
run("Select None");
imgHeight=getHeight();
imgWidth=getWidth();
setTool("rectangle");


//wait for the user
makeRectangle(5, imgHeight/4, 6, imgHeight/3);
waitForUser( "Pause","Draw a BACKGROUND ROI then click OK.");
roiManager("add");
roiManager("select", 0)
roiManager("rename", "BG");
roiManager("Set Color", "white");
roiManager("Set Line Width", 0.1);

selectWindow(kymoImageName);
run("Select None");
//wait for the user
makeRectangle(10, 0, 6, imgHeight);
waitForUser( "Pause","Draw the LEFT END ROI then click OK.");
roiManager("add");
roiManager("select", 1)
roiManager("rename", "LeftEnd");
roiManager("Set Color", "red");
roiManager("Set Line Width", 0.1);
Roi.getBounds(leROIx, leROIy, leROIwidth, leROIheight);

selectWindow(kymoImageName);
run("Select None");
//wait for the user
makeRectangle(imgWidth-20, 0, 6, imgHeight);
waitForUser( "Pause","Draw the RIGHT END ROI then click OK.");
roiManager("add");
roiManager("select", 2)
roiManager("rename", "RightEnd");
roiManager("Set Color", "red");
roiManager("Set Line Width", 0.1);
Roi.getBounds(reROIx, reROIy, reROIwidth, reROIheight);

selectWindow(kymoImageName);
run("Select None");
//wait for the user
imgCent=round(imgWidth/2);
makeRectangle(leROIx+leROIwidth, 0, reROIx-leROIx-leROIwidth, imgHeight);
waitForUser( "Pause","Edit the LATTICE ROI if necessary then click OK.");
roiManager("add");
roiManager("select", 3)
roiManager("rename", "Lattice");
roiManager("Set Color", "blue");
roiManager("Set Line Width", 0.1);
roiManager("show none");
run("Select None");



//Hide the tube image, makes it easier to see the events and have the ROIS now.
selectWindow(kymoImageName);
Stack.setActiveChannels("10");

//create a dir to store everything
dir = getDirectory("Choose a Directory where the ROI and results will be saved.");
//File.makeDirectory(dir); 
newDir=dir;

/*make sure these are recorded
roiManager("deselect");
roiManager("save", newDir +kymoImageName+"areas.zip");
selectWindow(kymoImageName);
roiManager("show none");
*/


//could use the ROI to calculate the MT length.
//Would put that here.

setBatchMode(false);

//copy out the GFP data
selectImage(kymoID);
//selectWindow(kymoImageName);
run("Duplicate...", "title=gfpOnly duplicate channels=1");
gfpOnlyID=getImageID();



//get bg value
roiManager("select", 0);

getStatistics(area, mean, min, max);
backGround=max;
print("Background  is "+backGround);

setBatchMode(true);

//run("Threshold...");
selectImage(gfpOnlyID);
setThreshold(max, 3.4e38);
setOption("BlackBackground", false);
run("Convert to Mask");

//this simulate the joning conditions - this is the really hard bit to do quickly though.
run("Dilate");
run("Erode");

setBatchMode(false);



//measure each of the 3 areas
//*****************************************************************************************************************
//Lattice events
//*****************************************************************************************************************
selectImage(gfpOnlyID);
roiManager("select", 3)
run("Analyze Particles...", "size=2-Infinity add");
//Rename the ROIs

n=roiManager("count");
startRenameFrom=4;
tempEventName=1;

    for (p=startRenameFrom; p<n; p++) { 
		roiManager("select", p);
		roiManager("rename", "C"+tempEventName);
		tempEventName++;    
    } 




selectWindow(kymoImageName);
roiManager("show all");
waitForUser( "Pause","Press Ok to enter delete mode to remove unwanted lattice events, \n (click on ROI label to remove them). \nClose the log window when you are done to continue.");
run("Auto Kymo Keys"); //Activate the Event Deletion tool
waitForUser( "Pause","Now add any missing LATTICE events as necessary (draw then 't'), then click OK.\n Use the + toolbar to add 1px (in time) events.");



//make sure these are recorded
roiManager("deselect");
roiManager("save", newDir +kymoImageName+"areas_lattice.zip");
selectWindow(kymoImageName);
roiManager("show all");

//Run the measurement
numRois=roiManager("count");
roiManager("deselect");
roiManager("Measure");

setBatchMode(true);

//Read out the data you need and put it in a new table
	count=4;
	n = numRois; 
    eventHeightLat = newArray(n-4);
    eventLabelLat = newArray(n-4);

 

    eventCount=1;
    for (k=0; k<n-4; k++) { 
        eventHeightLat[k] = frameInt*getResult("Height", count);
        eventLabelLat[k] = eventCount;
        eventCount++;
        count++; 
    } 
    
//close the results of the calc
   if (isOpen("Results")) { 
       selectWindow("Results"); 
      run("Close"); 
   } 

 	//Generate a results window with the selected values
   Array.show("ResultsTest", eventLabelLat, eventHeightLat);
   selectWindow("ResultsTest"); 
   saveAs("ResultsTest", dir+"Results"+"_Lattice_"+kymoImageName+"_.txt");

   //close the changed results
   if (isOpen("Results"+"_Lattice_"+kymoImageName+"_.txt")) { 
       selectWindow("Results"+"_Lattice_"+kymoImageName+"_.txt"); 
       run("Close"); 
   }


   //need to clear the ROIs (except the first 4).
       numRois=roiManager("count");
       n = numRois; 
       for (p=n-1; p>3; p--) { 
        roiManager("select", p);
        roiManager("delete");
    } 
    
numLatticeEvents=0;
numLatticeEvents=numRois-4;
   
//*****************************************************************************************************************    
//End of lattice results data collection
//*****************************************************************************************************************







//*****************************************************************************************************************
//Left End events
//*****************************************************************************************************************
selectImage(gfpOnlyID);
roiManager("select", 1)
run("Analyze Particles...", "size=2-Infinity add");
selectWindow(kymoImageName);
roiManager("show all");
n=roiManager("count");
startRenameFrom=4;
tempEventName=1;

    for (p=startRenameFrom; p<n; p++) { 
		roiManager("select", p);
		roiManager("rename", "L"+tempEventName);
		tempEventName++;    
    } 
waitForUser( "Pause","Please edit the LEFT END events as necessary then click OK.");

//make sure these are recorded
roiManager("deselect");
roiManager("save", newDir +kymoImageName+"areas_left_end.zip");
selectWindow(kymoImageName);
roiManager("show all");

//Run the measurement
numRois=roiManager("count");
roiManager("deselect");
roiManager("Measure");







//Read out the data you need and put it in a new table
	count=4;
	n = numRois; 
    eventHeightLE = newArray(n-4);
    eventLabelLE = newArray(n-4);
 

    eventCount=1;
    for (k=0; k<n-4; k++) { 
        eventHeightLE[k] = frameInt*getResult("Height", count);
        eventLabelLE[k] = eventCount;
        eventCount++;
        count++; 
    } 
    
//close the results of the calc
   if (isOpen("Results")) { 
       selectWindow("Results"); 
      run("Close"); 
   } 

 	//Generate a results window with the selected values
   Array.show("ResultsTest", eventLabelLE, eventHeightLE);
   selectWindow("ResultsTest"); 
   saveAs("ResultsTest", dir+"Results"+"_Left_End_"+kymoImageName+"_.txt");

   //close the changed results
   if (isOpen("Results"+"_Left_End_"+kymoImageName+"_.txt")) { 
       selectWindow("Results"+"_Left_End_"+kymoImageName+"_.txt"); 
       run("Close"); 
   }

   //need to clear the ROIs (except the first 4).
       numRois=roiManager("count");
       n = numRois; 
       for (p=n-1; p>3; p--) { 
        roiManager("select", p);
        roiManager("delete");
    }    

numEndBindings=0;
numEndBindings=numRois-4;
    
//*****************************************************************************************************************    
//End of left-end results data collection
//*****************************************************************************************************************


//*****************************************************************************************************************
//Right End events
//*****************************************************************************************************************
selectImage(gfpOnlyID);
roiManager("select", 2)
run("Analyze Particles...", "size=2-Infinity add");
selectWindow(kymoImageName);
roiManager("show all");
n=roiManager("count");
startRenameFrom=4;
tempEventName=1;

    for (p=startRenameFrom; p<n; p++) { 
		roiManager("select", p);
		roiManager("rename", "R"+tempEventName);
		tempEventName++;    
    } 
waitForUser( "Pause","Please edit the RIGHT END events as necessary then click OK.");

//make sure these are recorded
roiManager("deselect");
roiManager("save", newDir +kymoImageName+"areas_right_end.zip");
selectWindow(kymoImageName);
roiManager("show all");

//Run the measurement
numRois=roiManager("count");
roiManager("deselect");
roiManager("Measure");

//Read out the data you need and put it in a new table
	count=4;
	n = numRois; 
    eventHeightRE = newArray(n-4);
    eventLabelRE = newArray(n-4);
 

    eventCount=1;
    for (k=0; k<n-4; k++) { 
        eventHeightRE[k] = frameInt*getResult("Height", count);
        eventLabelRE[k] = eventCount;
        eventCount++;
        count++; 
    } 
    
//close the results of the calc
   if (isOpen("Results")) { 
       selectWindow("Results"); 
      run("Close"); 
   } 

 	//Generate a results window with the selected values
   Array.show("ResultsTest", eventLabelRE, eventHeightRE);
   selectWindow("ResultsTest"); 
   saveAs("ResultsTest", dir+"Results"+"_Right_End_"+kymoImageName+"_.txt");

   //close the changed results
   if (isOpen("Results"+"_Right_End_"+kymoImageName+"_.txt")) { 
       selectWindow("Results"+"_Right_End_"+kymoImageName+"_.txt"); 
       run("Close"); 
   }

   //need to clear the ROIs (except the first 4).
       numRois=roiManager("count");
       n = numRois; 
       for (p=n-1; p>3; p--) { 
        roiManager("select", p);
        roiManager("delete");
    }

numEndBindings=numEndBindings+numRois-4;        
//*****************************************************************************************************************    
//End of right-end results data collection
//*****************************************************************************************************************

//Write some summary information to a file.

/*

Threshold used (in backGround)
MT length
Num End bindings
Mean End binding time
Num lattice events
Mean lattice time

*/
//*************************************************************************
//Measure MT length
roiManager("deselect");
roiManager("select", 1);
 Roi.getBounds(x,y,w,h);
 left=x;
 roiManager("select", 2);
 Roi.getBounds(x,y,w,h);
 right=x+w;
 mtLength=right-left;
 mtLength=mtLength*pxSize;


 // backGround

// numLatticeEvents 
 
 // numEndBindings


 	backGroundRes = newArray(1);
    numLatticeEventsRes = newArray(1);
    numEndBindingsRes = newArray(1);
    mtLengthRes = newArray(1);

    backGroundRes[0] = backGround;
    numLatticeEventsRes[0] = numLatticeEvents;
    numEndBindingsRes[0] = numEndBindings;
    mtLengthRes[0] = mtLength;
   
    
	//Generate a results window with the selected values
   Array.show("ResultsSummary", backGroundRes, numLatticeEventsRes, numEndBindingsRes, mtLengthRes);
   selectWindow("ResultsSummary"); 
   saveAs("ResultsSummary", dir+"Results"+"_Summary_"+kymoImageName+"_.txt");




//Very end of the experiment

//Tidy up a few windows no longer needed, should really run this in batch mode.
   //close the changed results
   if (isOpen("gfpOnly")) { 
       selectWindow("gfpOnly"); 
       run("Close"); 
   }
      if (isOpen("Drawing of gfpOnly")) { 
       selectWindow("Drawing of gfpOnly"); 
       run("Close"); 
   }

//clear the ROI manager
if (roiManager("count") !=0)  {
roiManager("deselect");
roiManager("delete");
}





