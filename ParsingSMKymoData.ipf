//#pragma TextEncoding = "Windows-1252"
//#pragma rtGlobals=3		// Use modern global access method and strict wave access.

 
Menu "LoadKymoAnalysisResults"
	"Load End Bindings...", LoadEndBindings("")
	"Load Lattice Events...", LoadLatticeBindings("")
	"Load Summary Data...", LoadSummary("")
End


 
static StrConstant kFileNameExtension = ".txt"
 
// LoadOneFile(pathName, fileName)
// Produces the following waves
Function LoadOneFile(pathName, fileName)
	String pathName		// Name of an Igor symbolic path or "".
	String fileName			// Name of file or full path to file.
 
	// First get a valid reference to a file.
	if ((strlen(pathName)==0) || (strlen(fileName)==0))
		// Display dialog looking for file.
		Variable refNum
		Open/D/R/F=kFileNameExtension/P=$pathName refNum as fileName
		fileName = S_fileName			// S_fileName is set by Open/D
		if (strlen(fileName) == 0)		// User cancelled?
			return -1
		endif
	endif
	
	
	//Make sure this data is loaded into a unique DF for this KG
	Variable kymoNameStart = strsearch(filename, "Kymograph", 0)
	String thisPathForDF="root:df4"
	SetCommonDF(thisPathForDF)
 
 
 String columnInfoStr = " "
	columnInfoStr += "N='TimeStamp';"			// Load DATE column - will become date/time wave
	columnInfoStr += "N='EventLength';"			// Load TIME column
 
 
 
 
 
 
	LoadWave /J /D /W /B=columnInfoStr /A /K=1 /P=$pathName fileName
	Variable numWavesLoaded = V_flag			// V_flag is set by LoadWave

 
	Wave DateTimeW,TimeW			// Create reference to waves created by LoadWave
	
 
	return 0							// Success
End




//loads the summary file into waves backGroundRes	numLatticeEventsRes	numEndBindingsRes	mtLengthRes
Function LoadSummaryFile(pathName, fileName)
	String pathName		// Name of an Igor symbolic path or "".
	String fileName			// Name of file or full path to file.
 
	// First get a valid reference to a file.
	if ((strlen(pathName)==0) || (strlen(fileName)==0))
		// Display dialog looking for file.
		Variable refNum
		Open/D/R/F=kFileNameExtension/P=$pathName refNum as fileName
		fileName = S_fileName			// S_fileName is set by Open/D
		if (strlen(fileName) == 0)		// User cancelled?
			return -1
		endif
	endif
	
	
	//Make sure this data is loaded into a unique DF for this KG
	Variable kymoNameStart = strsearch(filename, "Kymograph", 0)
	String thisPathForDF="root:df4"
	SetCommonDF(thisPathForDF)
 
 
 String columnInfoStr = " "
	columnInfoStr += "N='backGroundRes';"			// Load DATE column - will become date/time wave
	columnInfoStr += "N='numLatticeEventsRes';"			// Load TIME column
 columnInfoStr += "N='numEndBindingsRes';"			// Load TIME column
 columnInfoStr += "N='mtLengthRes';"			// Load TIME column
 
 
 
 
	LoadWave /J /D /W /B=columnInfoStr /A /K=1 /P=$pathName fileName
	Variable numWavesLoaded = V_flag			// V_flag is set by LoadWave

 
	
	
 
	return 0							// Success
End




function  SetCommonDF(path)
	string path // input parameter, something like "root:df"
 
	NewDataFolder/O/S $path // ensure the data folder exists
	String/G root:path0 = path // remember which data folder fn1 will return
end














 
// LoadAndConcatenateAllFiles(pathName)
// Loads all files in specified folder with extension specified by kFileNameExtension.
// All loaded waves are concatenated, creating the output waves in the current data folder.
// If the output waves already exist in the current data folder, this routine appends to them.
Function LoadEndBindings(pathName)
	String pathName					// Name of symbolic path or "" to get dialog
	String fileName
	Variable index=0
 
	Wave/D/Z EndBindIndex, EndBindTime
	if (!WaveExists(EndBindIndex))						
		// Create the output waves because the code below concatenates	
		Make/O/N=0/D EndBindIndex, EndBindTime
	endif
 
	if (strlen(pathName)==0)			// If no path specified, create one
		NewPath/O temporaryPath		// This will put up a dialog
		if (V_flag != 0)
			return -1					// User cancelled
		endif
		pathName = "temporaryPath"
	endif
 
	Variable result
	do			// Loop through each file in folder
		fileName = IndexedFile($pathName, index, kFileNameExtension)
		if (strlen(fileName) == 0)			// No more files?
			break									// Break out of loop
		endif
 
		// Load the new data into a temporary data folder
		String dfName = "TempDataForLoadAndConcatenate"
		NewDataFolder/O/S $dfName
 
		result = LoadOneFile(pathName, fileName)
		if (result != 0)
			String message
			sprintf message, "An error occurred while loading the file \"%s\". Aborting the load.\r", fileName
			Print message
			DoAlert 0, message
			KillDataFolder $dfName
			break		
		endif
 
 if (index ==0)
 
		// Create wave references for the waves loaded into the temporary data folder, need to account for their naming
		Wave TimeStampNew = :TimeStamp
		Wave EventLengthNew = :EventLength
		
else 

		String LocTSName=":TimeStamp"+num2str(index)
		String LocEventLengthName=":EventLength"+num2str(index)
		



		Wave TimeStampNew = $LocTSName
		Wave EventLengthNew =$LocEventLengthName
		
endif		
		
 
		SetDataFolder ::				// Back to parent data folder
 
		Wave EndBindIndex, EndBindTime
 
 
 
		Concatenate /NP {TimeStampNew}, EndBindIndex
		Concatenate /NP {EventLengthNew}, EndBindTime
		
 
		KillDataFolder $dfName
 
		Printf "Loaded file %d: \"%s\"\r", index, fileName
 
		index += 1
	while (1)
 
	if (Exists("temporaryPath"))		// Kill temp path if it exists
		KillPath temporaryPath
	endif
	
	 	//remove zeros
	Wave EndBindIndex, EndBindTime
	EndBindIndex = EndBindIndex == 0 ? NaN : EndBindIndex
	WaveTransform zapNaNs EndBindIndex
	EndBindTime = EndBindTime == 0 ? NaN : EndBindTime
	WaveTransform zapNaNs EndBindTime
	
	
KillDataFolder df4
	
 
	return 0						// Signifies success.
End






// LoadAndConcatenateAllFiles(pathName)
// Loads all files in specified folder with extension specified by kFileNameExtension.
// All loaded waves are concatenated, creating the output waves in the current data folder.
// If the output waves already exist in the current data folder, this routine appends to them.
Function LoadLatticeBindings(pathName)
	String pathName					// Name of symbolic path or "" to get dialog
	String fileName
	Variable index=0
 
	Wave/D/Z LatBindIndex, LatBindTime
	if (!WaveExists(LatBindIndex))						
		// Create the output waves because the code below concatenates	
		Make/O/N=0/D LatBindIndex, LatBindTime
	endif
 
	if (strlen(pathName)==0)			// If no path specified, create one
		NewPath/O temporaryPath		// This will put up a dialog
		if (V_flag != 0)
			return -1					// User cancelled
		endif
		pathName = "temporaryPath"
	endif
 
	Variable result
	do			// Loop through each file in folder
		fileName = IndexedFile($pathName, index, kFileNameExtension)
		if (strlen(fileName) == 0)			// No more files?
			break									// Break out of loop
		endif
 
		// Load the new data into a temporary data folder
		String dfName = "TempDataForLoadAndConcatenate"
		NewDataFolder/O/S $dfName
 
		result = LoadOneFile(pathName, fileName)
		if (result != 0)
			String message
			sprintf message, "An error occurred while loading the file \"%s\". Aborting the load.\r", fileName
			Print message
			DoAlert 0, message
			KillDataFolder $dfName
			break		
		endif
 
 if (index ==0)
 
		// Create wave references for the waves loaded into the temporary data folder, need to account for their naming
		Wave TimeStampNew = :TimeStamp
		Wave EventLengthNew = :EventLength
		
else 

		String LocTSName=":TimeStamp"+num2str(index)
		String LocEventLengthName=":EventLength"+num2str(index)
		



		Wave TimeStampNew = $LocTSName
		Wave EventLengthNew =$LocEventLengthName
		
endif		
		
 
		SetDataFolder ::				// Back to parent data folder
 
		Wave LatBindIndex, LatBindTime
 
 
 
		Concatenate /NP {TimeStampNew}, LatBindIndex
		Concatenate /NP {EventLengthNew}, LatBindTime
		
 
		KillDataFolder $dfName
 
		Printf "Loaded file %d: \"%s\"\r", index, fileName
 
		index += 1
	while (1)
 
	if (Exists("temporaryPath"))		// Kill temp path if it exists
		KillPath temporaryPath
	endif
	
	 	//remove zeros
	Wave LatBindIndex, LatBindTime
	LatBindIndex = LatBindIndex == 0 ? NaN : LatBindIndex
	WaveTransform zapNaNs LatBindIndex
	LatBindTime = LatBindTime == 0 ? NaN : LatBindTime
	WaveTransform zapNaNs LatBindTime

	KillDataFolder df4
 
	return 0						// Signifies success.
End





Function RunAnalysis()

HistEndTimes()


End





Function HistEndTimes()
//make a nice hitrogram for the current results
Wave EndBindTime
Make/N=50/O EndBindTime_Hist;DelayUpdate
Histogram/C/B={0.1,0.1,50} EndBindTime,EndBindTime_Hist;DelayUpdate
Display EndBindTime_Hist
ModifyGraph mode=5
Label bottom "Time (s)"
Label left "Occurance"
End




//backGroundRes	numLatticeEventsRes	numEndBindingsRes	mtLengthRes
// Loads all files in specified folder with extension specified by kFileNameExtension.
// All loaded waves are concatenated, creating the output waves in the current data folder.
// If the output waves already exist in the current data folder, this routine appends to them.
Function LoadSummary(pathName)
	String pathName					// Name of symbolic path or "" to get dialog
	String fileName
	Variable index=0
 
	Wave/D/Z SummaryBG, SummaryLatEvents,SummaryEndEvents,SummaryLength 
	if (!WaveExists(SummaryBG))						
		// Create the output waves because the code below concatenates	
		Make/O/N=0/D SummaryBG, SummaryLatEvents,SummaryEndEvents,SummaryLength
	endif
 
	if (strlen(pathName)==0)			// If no path specified, create one
		NewPath/O temporaryPath		// This will put up a dialog
		if (V_flag != 0)
			return -1					// User cancelled
		endif
		pathName = "temporaryPath"
	endif
 
	Variable result
	do			// Loop through each file in folder
		fileName = IndexedFile($pathName, index, kFileNameExtension)
		if (strlen(fileName) == 0)			// No more files?
			break									// Break out of loop
		endif
 
		// Load the new data into a temporary data folder
		String dfName = "TempDataForLoadAndConcatenate"
		NewDataFolder/O/S $dfName
 
		result = LoadSummaryFile(pathName, fileName)
		if (result != 0)
			String message
			sprintf message, "An error occurred while loading the file \"%s\". Aborting the load.\r", fileName
			Print message
			DoAlert 0, message
			KillDataFolder $dfName
			break		
		endif
 
 if (index ==0)
 
 //backGroundRes	numLatticeEventsRes	numEndBindingsRes	mtLengthRes
 
		// Create wave references for the waves loaded into the temporary data folder, need to account for their naming
		Wave backGroundResNew = :backGroundRes
		Wave numLatticeEventsResNew = :numLatticeEventsRes
		Wave numEndBindingsResNew = :numEndBindingsRes
		Wave mtLengthResNew = :mtLengthRes
		
else 

		String LocBGName=":backGroundRes"+num2str(index)
		String LocLatNumName=":numLatticeEventsRes"+num2str(index)
		String LocEndNumName=":numEndBindingsRes"+num2str(index)
		String LocLengthName=":mtLengthRes"+num2str(index)
		



		Wave backGroundResNew = $LocBGName
		Wave numLatticeEventsResNew =$LocLatNumName
		Wave numEndBindingsResNew = $LocEndNumName
		Wave mtLengthResNew =$LocLengthName
		
endif		
		
 
		SetDataFolder ::				// Back to parent data folder
 
			Wave SummaryBG, SummaryLatEvents,SummaryEndEvents,SummaryLength 
 
 
 
		Concatenate /NP {backGroundResNew}, SummaryBG
		Concatenate /NP {numLatticeEventsResNew}, SummaryLatEvents
		Concatenate /NP {numEndBindingsResNew}, SummaryEndEvents
		Concatenate /NP {mtLengthResNew}, SummaryLength
		
 
		KillDataFolder $dfName
 
		Printf "Loaded file %d: \"%s\"\r", index, fileName
 
		index += 1
	while (1)
 
	if (Exists("temporaryPath"))		// Kill temp path if it exists
		KillPath temporaryPath
	endif
	
	 	//remove zeros
	//Wave SummaryBindIndex, SummaryBindTime
	//SummaryBindIndex = SummaryBindIndex == 0 ? NaN : SummaryBindIndex
	//WaveTransform zapNaNs SummaryBindIndex
	//SummaryBindTime = SummaryBindTime == 0 ? NaN : SummaryBindTime
	//WaveTransform zapNaNs SummaryBindTime

	KillDataFolder df4
 
	return 0						// Signifies success.
End