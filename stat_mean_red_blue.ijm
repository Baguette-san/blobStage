function launch(){
	
	startTime = getTime();
	
	setBatchMode(false);
	tif_dir = getDirectory("Select the directory where .tif files are stored ...");
		
	//outputPath=File.openDialog("Select output file ..."); //test
	outputPathCSV_red = File.openDialog("Select output RED CSV file ...");
	outputPathCSV_blue = File.openDialog("Select output BLUE CSV file ...");
	File.append("name;slices;moy", outputPathCSV_red);
	File.append("name;slices;moy", outputPathCSV_blue);

	setBatchMode(true);
	forAllTiff(tif_dir);

	endTime = getTime();
	
	totalTime = endTime - startTime;
	totalSeconds = totalTime / 1000;
	hours = totalSeconds / 3600;
	minutes = (totalSeconds % 3600) / 60;
	seconds = totalSeconds % 60;
	setBatchMode(false);
	print("Fin du programme en : " + round(hours) + " h " + round(minutes) + " min " + round(seconds) + " s ");
}

function forAllTiff(tif_dir) {
	file_list = getFileList(tif_dir);
	for (i=0; i < file_list.length; i++) {
		if (endsWith(file_list[i], ".tif")){
			file_path_curr = tif_dir + file_list[i];
			ouverture(file_path_curr, file_list[i]);
			close("*");
			run("Collect Garbage");
		}
	}
}

function ouverture(file_path_curr, fichier){
	open(file_path_curr);
	name = File.getName(fichier);
	
	run("Set Measurements...", "mean redirect=None decimal=0");
	
	selectWindow(name);
	run("Duplicate...", "title=red duplicate channels=1");
	selectWindow("red");
	for (i = 1; i <= nSlices; i++) {
    	setSlice(i);
    	run("Measure");
	}
	mean_tab_red = Table.getColumn("Mean");
	runClose("Results",1);
	runClose("red",0);
	
	
	selectWindow(name);
	run("Duplicate...", "title=blue duplicate channels=2");
	selectWindow("blue");
	slices = nSlices();
	for (i = 1; i <= nSlices; i++) {
    	setSlice(i);
    	run("Measure");
	}
	mean_tab_blue = Table.getColumn("Mean");
	runClose("Results",1);
	runClose("blue",0);
	
	ret_csv = "";
	ret_csv = name + ";" + slices + ";";
	for (i = 0; i < slices-1; i++) ret_csv = ret_csv + mean_tab_red[i] + ";";
	ret_csv + mean_tab_red[slices-1];
	File.append(ret_csv, outputPathCSV_red);
	
	ret_csv = "";
	ret_csv = name + ";" + slices + ";";
	for (i = 0; i < slices-1; i++) ret_csv = ret_csv + mean_tab_blue[i] + ";";
	ret_csv + mean_tab_blue[slices-1];
	File.append(ret_csv, outputPathCSV_blue);
}

function runClose(windowName, type) { // 0 -> image / 1 -> other
	if(!isOpen(windowName)) return 0;
	if(type==0){ selectWindow(windowName); close(); }
	if(type==1){ selectWindow(windowName); run("Close"); }
}

launch()