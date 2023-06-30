/**
 * permet d'extraire la distribution des intensités dans les stacks pour l'étude de la profondeur
 * editor - DESGREZ DAUTET H.
 */

function launch(){
	
	startTime = getTime();
	
	setBatchMode(false);
	tif_dir = getDirectory("Select the directory where .tif files are stored ...");
	outPutPathCSV_red = File.openDialog("Select red output file ...");
	outPutPathCSV_blue = File.openDialog("Select blue output file ...");
	head = "name;slices;min;max;";
	for (i = 0; i < 100; i++) head = head + "moy" + (i+1) + ";" ;
	File.append(head, outPutPathCSV_red);
	File.append(head, outPutPathCSV_blue);
	
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
	open(file_path_curr);
	name = File.getName(fichier);
	selectWindow(name);
	run("8-bit");
	red();
	blue();	
}

function red(){
	selectWindow(name);
	run("Duplicate...", "title=red duplicate channels=1");
	selectWindow("red");
	min = 255;
	max = 0;
	means = newArray(nSlices);
	for (i = 1; i <= nSlices; i++) {
    	setSlice(i);
    	getStatistics(area, mean, min, max);
    	if (min>mean) min = mean;
    	if (max<mean) max = mean;
    	means[i-1]=mean;
	}
	getPixelSize(unit, pixelW, pixelH, pixelZ);
	getDimensions(width, height, channels, slices, frames);
	selectWindow("red");close();	
	
	csvString = name+";"+slices+";"+min+";"+max+";";
	for (i = 0; i < means.length-1; i++) csvString = csvString + means[i] + ";" ;
	csvString = csvString + means[means.length-1];
	
	File.append(csvString, outPutPathCSV_red);
}

function blue(){
	selectWindow(name);
	run("Duplicate...", "title=blue duplicate channels=2");
	selectWindow("blue");
	min = 255;
	max = 0;
	means = newArray(nSlices);
	for (i = 1; i <= nSlices; i++) {
    	setSlice(i);
    	getStatistics(a, mean, min, max);
    	if (min>mean) min = mean;
    	if (max<mean) max = mean;
    	means[i-1]=mean;
	}
	getPixelSize(unit, pixelW, pixelH, pixelZ);
	getDimensions(width, height, channels, slices, frames);
	selectWindow("blue");close();
	
	csvString = name+";"+slices+";"+min+";"+max+";";
	for (i = 0; i < means.length-1; i++) csvString = csvString + means[i] + ";" ;
	csvString = csvString + means[means.length-1];
	
	File.append(csvString, outPutPathCSV_blue);
}

launch();