/**
 * extract informations & parametters  of a list of files
 * editor - DESGREZ DAUTET H.
 */

function launch(){
	
	startTime = getTime();
	
	setBatchMode(false);
	tif_dir = getDirectory("Select the directory where .tif files are stored ...");
		
	//outputPath=File.openDialog("Select output file ..."); //test
	outputPathCSV = File.openDialog("Select output CSV file ...");
	File.append("name;unit;pixelW;pixelH;pixelZ;width;height;channels;slices;min;max;moy", outputPathCSV);

	setBatchMode(false);
	forAllTiff(tif_dir);

	endTime = getTime();
	
	totalTime = endTime - startTime;
	totalSeconds = totalTime / 1000;
	hours = totalSeconds / 3600;
	minutes = (totalSeconds % 3600) / 60;
	seconds = totalSeconds % 60;
	print("Fin du programme en : " + round(hours) + " h " + round(minutes) + " min " + round(seconds) + " s ");
}

function forAllTiff(tif_dir) {
	file_list = getFileList(tif_dir);
	
	for (i=0; i < file_list.length; i++) {
		
		if (endsWith(file_list[i], ".tif")){
			file_path_curr = tif_dir + file_list[i];
			
			if (i < file_list.length-1){
				file_path_next = tif_dir + file_list[i+1];
				ouverture(file_path_curr,file_path_next,file_list[i]);
			}
			else ouverture(file_path_curr,file_path_curr,file_list[i]);
			
			close("*");
			run("Collect Garbage");
		}
	}
}

function ouverture(file_path_curr, file_path_next,fichier){
	//run("Preloader","current="+file_path_curr+" next="+file_path_next);
	open(file_path_curr);
	print("TEST");
	name = File.getName(fichier);
	selectWindow(name);
	run("Duplicate...", "title=red duplicate channels=1");
	selectWindow("red");
	run("8-bit");
	moy = 255;
	for (i = 1; i <= nSlices; i++) {
    	setSlice(i);
    	getStatistics(a, mean, min, max);
    	if (moy>mean) moy = mean;
	}
	getPixelSize(unit, pixelW, pixelH, pixelZ);
	getDimensions(width, height, channels, slices, frames);
	
	
	ret_csv = newArray(name,unit,pixelW,pixelH,pixelZ,width,height,channels,slices,min,max,moy);
	csvString = "";
	
	for (i = 0; i < ret_csv.length-1; i++) csvString = csvString + ret_csv[i] + ";" ;
	csvString = csvString + ret_csv[ret_csv.length-1];
	
	File.append(csvString, outputPathCSV);
}

launch();