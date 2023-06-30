/**
 * make projection of a set of tiff files
 * editor - DESGREZ DAUTET H.
 */

launch();

function launch(){
	
	tif_input_dir = getDirectory("Select the directory where are stored .tif files ...");
	tif_output_dir_red = getDirectory("Select the directory where will be stored projections ...");
	tif_output_dir_blue = getDirectory("Select the directory where will be stored projections ...");
	
	startTime = getTime();
	
	setBatchMode(true);
	forAllTiff(tif_input_dir);
	
	endTime = getTime();
	
	totalTime = endTime - startTime;
	totalSeconds = totalTime / 1000;
	hours = totalSeconds / 3600;
	minutes = (totalSeconds % 3600) / 60;
	seconds = totalSeconds % 60;
	print("Fin du programme en : " + round(hours) + " h " + round(minutes) + " min " + round(seconds) + " s ");
}

function forAllTiff(tif_dir) {
	j=0;
	file_list = getFileList(tif_input_dir);
	for (i=0; i < file_list.length; i++) {
		//print(file_list[i]);
		if (endsWith(file_list[i], ".tif")){
			fichier = file_list[i];
			file_path = tif_input_dir + fichier;
			dup(file_path);
			j++;
			close("*");
		}
	}
}

function dup(file_path){
	open(file_path);
	name = File.getName(fichier);
	slices = nSlices;
	if(slices<15){
		start=1;
		stop=slices;
	}
	else{
		start=floor((slices/2)-5);
		stop=Math.ceil((slices/2)+5);
	}
	
	/**
	run("Duplicate...", "title=red duplicate channels=1");
	run("Z Project...", "start="+start+" stop="+stop+" projection=[Max Intensity]");
	saveAs("Tiff", tif_output_dir_red+"red-projection-"+name);
	*/
	
	selectWindow(name);
	run("Duplicate...", "title=blue duplicate channels=2");
	run("Gaussian Blur...", "sigma=2 stack");
	run("Z Project...", "start="+start+" stop="+stop+" projection=[Max Intensity]");
	run("Cyan");
	run("Enhance Contrast", "saturated=0.35");
	saveAs("Tiff", tif_output_dir_blue+"blue-projection-"+name);
}

