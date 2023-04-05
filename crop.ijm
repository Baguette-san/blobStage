/**
 * Duplicate TIFF files with a selected start and end of the stacks following a pre-writen CSV file
 * editor - DESGREZ DAUTET H.
 */



launch();


function launch(){
	
	tif_input_dir = getDirectory("Select the directory where are stored .tif files ...");
	tif_output_dir = getDirectory("Select the directory where will be stored .tif files ...");
	csv_input = File.openDialog("Select input CSV file ...");
	
	open(csv_input);
	IJ.renameResults("Results");
	
	print("nResults="+nResults);
	tabName = newArray(nResults);
	tabFirst = newArray(nResults);
	tabLast = newArray(nResults);
	
	
	for (i = 0; i < nResults; i++) {
		tabName[i] = getResultString("Name", i);
		tabFirst[i] = getResult("First", i);
		tabLast[i] = getResult("Last", i);
		print(tabName[i]);
	}
	
	print("\n\n---\n\n");
	setBatchMode(false);
	forAllTiff(tif_input_dir);
	
	print("main success");
}

function forAllTiff(tif_dir) {
	j=0;
	file_list = getFileList(tif_input_dir);
	for (i=0; i < file_list.length; i++) {
		print(file_list[i]);
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
	if(tabName[j]==file_list[i]){
		open(file_path);
		name = File.getName(fichier);
		first = tabFirst[j];
		last = tabLast[j];
		
		run("Make Substack...", "channels=1-2 slices="+first+"-"+last);
		saveAs("Tiff", tif_output_dir+"reduced-"+name);
	}
	else{
		print("error index : " + j);
	}
	
}

