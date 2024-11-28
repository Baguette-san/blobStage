/**
 * Script for the images redimension
 */

function launch(){
	
	startTime = getTime();
	
	setBatchMode(false);
	tif_dir = getDirectory("Select the directory where .tif files are stored ...");
	crop_output_dir = getDirectory("Select the directory where will be stored resized files ...");
	
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
		}
	}
	run("Collect Garbage");
}

function ouverture(file_path_curr, file_path_next,fichier) { 
	open(file_path_curr);
	name = File.getName(fichier);
	selectWindow(name);
	resize();
}

function resize() {
	getDimensions(width, height, channels, slices, frames);
	if (width!=1576) {
		run("Size...", "width=1576 height=1576 depth="+slices+" constrain average interpolation=Bilinear");
		saveAs("Tiff", crop_output_dir+"resize_"+name);
	}
}

launch();
