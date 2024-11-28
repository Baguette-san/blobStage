/**
 * Duplicate TIFF files with a selected start and end of the stacks following a pre-writen CSV file
 * editor - DESGREZ DAUTET H.
 */



launch();


function launch(){
	
	tif_input_dir = getDirectory("Select the directory where are stored .tif files ...");
	crop_output_dir = getDirectory("Select the directory where will be stored crop files ...");
	//proj_output_dir = getDirectory("Select the directory where will be stored proj files ...");
	csv_input = File.openDialog("Select input CSV file ...");
	
	startTime = getTime();
	
	setBatchMode(true);
	
	open(csv_input);
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
	file_list = getFileList(tif_input_dir);
	
	if(nResults!=file_list.length){
		print("listes de tailles differentes");
		return 0;	
	}
	
	for (i=0; i < nResults; i++) {
		
		title = getResultString("title", i);
		file_path = tif_input_dir + title;
		
		open(file_path);
		dup();
		//proj();
		//proj2();
		close("*");
		
		if(i%10==0) run("Collect Garbage");
	}
}

function dup(){
	selectWindow(title);
	first = getResult("min", i);
	last = getResult("max", i);		
	run("Make Substack...", "channels=1-2 slices="+first+"-"+last);
	run("8-bit");
	saveAs("Tiff", crop_output_dir+"directed-crop_"+title);
}

function proj(){
	last = getResult("max", i);
	selectWindow(title);
	run("Duplicate...", "title=red duplicate channels=1");
	run("Z Project...","start="+(last-5)+" stop="+last+" projection=[Max Intensity]");
	saveAs("Tiff", proj_output_dir+"endProj_"+title);
}

function proj2(){
	last = getResult("max", i);
	selectWindow(title);
	run("Duplicate...", "title=red duplicate channels=1");
	run("Grouped Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", proj_output_dir2+"red_"+title);
	selectWindow(title);
	run("Duplicate...", "title=red duplicate channels=2");
	run("Gaussian Blur...", "sigma=2");
	run("Grouped Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", proj_output_dir2+"blue_"+title);
}

function runClose(windowName, type) { // 0 -> image / 1 -> other
	if(!isOpen(windowName)) return 0;
	if(type==0){ selectWindow(windowName); close(); }
	if(type==1){ selectWindow(windowName); run("Close"); }
}
