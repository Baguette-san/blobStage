/**
 * Duplicate TIFF files with a selected start and end of the stacks following a pre-writen CSV file
 * editor - DESGREZ DAUTET H.
 */


launch();


function launch(){
	
	tif_input_dir = getDirectory("Select the directory where are stored .tif files ...");
	crop_output_dir = getDirectory("Select the directory where will be stored crop files ...");
	
	startTime = getTime();
	
	setBatchMode(true);
	
	IJ.renameResults("Results");
	
	forAllTiff(tif_input_dir);
	
	endTime = getTime();
	
	totalTime = endTime - startTime;
	totalSeconds = totalTime / 1000;
	hours = totalSeconds / 3600;
	minutes = (totalSeconds % 3600) / 60;
	seconds = totalSeconds % 60;
	temps = "Fin du programme en : " + round(hours) + " h " + round(minutes) + " min " + round(seconds) + " s ";
	print(temps);


function forAllTiff(tif_dir) {
	
	file_list = getFileList(tif_dir);
	
	for (i=0; i < file_list.length; i++) {
		
		if (endsWith(file_list[i], ".tif")){
			
			fichier = file_list[i];
			info_table = newArray(fichier,nucleus_area,diameter);
			file_path = tif_dir + fichier;
			
			ouverture(file_path); // --> ouverture
			//close("*");
		}
		if( (i%10)==0) run("Collect Garbage");
	}
}

function forAllTiff(tif_dir) {
	file_list = getFileList(tif_input_dir);
		
	for (i=0; i < file_list.length; i++) {
		if (endsWith(file_list[i], ".tif")){
			
			fichier = file_list[i];
			file_path = tif_dir + fichier;
			open(file_path);
			name = File.getName(fichier);
			dup();
			close("*");
		}
		if(i%10==0) run("Collect Garbage");
	}
}

function dup(){
	selectWindow(name);
	first = 1;
	slices = nSlices/2;
	if(slices>30) last=30;
	else last = slices;
		
	run("Make Substack...", "channels=1-2 slices="+first+"-"+last);
	saveAs("Tiff", crop_output_dir+"crop10µ_"+name);
}
