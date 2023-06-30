/**
 * Duplicate TIFF files with a selected start and end of the stacks following a pre-writen CSV file
 * give the possibility to check for artefact
 * editor - DESGREZ DAUTET H.
 */

launch();

function launch(){
	
	tif_input_dir = getDirectory("Select the directory where are stored .tif files ...");
	csv_input = File.openDialog("Select input CSV file ...");
	
	startTime = getTime();
	
	setBatchMode(false);
	
	open(csv_input);
	IJ.renameResults("Results");
	Table.setLocationAndSize(1100, 300, 700, 700);
	
	forAllTiff(tif_input_dir);
	
	endTime = getTime();
	
	totalTime = endTime - startTime;
	totalSeconds = totalTime / 1000;
	hours = totalSeconds / 3600;
	minutes = (totalSeconds % 3600) / 60;
	seconds = totalSeconds % 60;
	temps = "Fin du programme en : " + round(hours) + " h " + round(minutes) + " min " + round(seconds) + " s ";
	print(temps);
}


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
		treatment(i);
		close("*");
		
		if(i%10==0) run("Collect Garbage");
	}
}

function treatment(indice) {
	setLocation(10,10,1000,1000);
	run("Enhance Contrast...","saturated=0.35");
	
	Dialog.create("To keep or not to keep ?");
	Dialog.addRadioButtonGroup("", newArray("YES","NO"), 2, 1, "YES");
	Dialog.setLocation(1200,200);
	Dialog.show();
	
	option = Dialog.getRadioButton();
	if(option=="NO") setResult("correction", indice, "X");
}
