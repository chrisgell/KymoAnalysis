//#pragma TextEncoding = "Windows-1252"
//#pragma rtGlobals=3		// Use modern global access method and strict wave access.

 
Menu "LoadWaves"
	"Load One File...", LoadOneFile("", "")
	"Load And Concatenate All Files in Folder...", LoadEndBindings("")
End


 
static StrConstant kFileNameExtension = ".txt"
 
// LoadOneFile(pathName, fileName)
// Produces the following waves: DateTimeW, CH4_dry, CO2_dry
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
 
 
 
 
 
 
	LoadWave /J /D /W /B=columnInfoStr /A /K=1 /E=2 /P=$pathName fileName
	Variable numWavesLoaded = V_flag			// V_flag is set by LoadWave

 
	Wave DateTimeW,TimeW			// Create reference to waves created by LoadWave
	
 
	return 0							// Success
End



function  SetCommonDF(path)
	string path // input parameter, something like "root:df"
 
	NewDataFolder/O/S $path // ensure the data folder exists
	String/G root:path0 = path // remember which data folder fn1 will return
end














 
// LoadAndConcatenateAllFiles(pathName)
// Loads all files in specified folder with extension specified by kFileNameExtension.
// The output waves are: DateTimeW, CH4_dry, CO2_dry
// All loaded waves are concatenated, creating the output waves in the current data folder.
// If the output waves already exist in the current data folder, this routine appends to them.
Function LoadEndBindings(pathName)
	String pathName					// Name of symbolic path or "" to get dialog
	String fileName
	Variable index=0
 
	Wave/D/Z EndBindIndex, EndBindTime
	if (!WaveExists(EndBindIndex))						// Date/time wave does not exist?
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
 
		// Create wave references for the waves loaded into the temporary data folder
		Wave TimeStampNew = :TimeStamp
		Wave EventLengthNew = :EventLength
		
 
		SetDataFolder ::				// Back to parent data folder
 
		Wave EndBindIndex, EndBindTime
 
 
 //need to sort out why this does not concat here - it works by re-adds the same waves.... the first one. Need to make 
 //time stamp new concat the correct wave.
 
		Concatenate /NP {TimeStampNew}, EndBindIndex
		Concatenate /NP {EventLengthNew}, EndBindTime
		
 
		KillDataFolder $dfName
 
		Printf "Loaded file %d: \"%s\"\r", index, fileName
 
		index += 1
	while (1)
 
	if (Exists("temporaryPath"))		// Kill temp path if it exists
		KillPath temporaryPath
	endif
 
	Wave EndBindIndex, EndBindTime
	
 
	return 0						// Signifies success.
End
