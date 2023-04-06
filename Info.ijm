
function launch(){
	
	startTime = getTime();
	
	setBatchMode(false);
	tif_dir = getDirectory("Select the directory where .tif files are stored ...");
		
	//outputPath=File.openDialog("Select output file ..."); //test
	outputPathCSV = File.openDialog("Select output CSV file ...");
	//File.append("name,unit,pixelW,pixelH,pixelZ,width,height,channels,frames,slices,min,max,mean", outputPathCSV);

	setBatchMode(true);
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
			fichier = file_list[i];
			file_path = tif_dir + fichier;
			ouverture(file_path);
			close("*");
		}
	}
}

function ouverture(filepath){
	open(file_path);
	dir = File.getParent(fichier);
	name = File.getName(fichier);
	
	selectWindow(name);
	getPixelSize(unit, pixelW, pixelH, pixelZ);
	getDimensions(width, height, channels, slices, frames);
	getStatistics(mean, min, max);
	
	
	ret_csv = newArray(name,unit,pixelW,pixelH,pixelZ,width,height,channels,frames,slices,min,max,mean);
	csvString = "";
	
	for (i = 0; i < ret_csv.length-1; i++) csvString = csvString + ret_csv[i] + "," ;
	csvString = csvString + ret_csv[ret_csv.length-1];
	
	File.append(csvString, outputPathCSV);
	
	
}

launch();
