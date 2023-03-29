//macro pour Marlene. C.Rouviere CBI Image Processing
//4/10/2021
//ver 2.1
//Image is chosen by user(blobs)
//Aim: an hyperstack,image with 2 channels and z section is open.
//localisation of mitosox signal is done on channel 1 with local maxima detection method
//nucleis are counted on channel 2
//size of nucleis is enter by user to perform an adequate grouped z-project  
//output: a result tab with the number of cell and mitosox signal occurences for the opened image
//save in the same directory
//changes : add function control
//			add 3D blurred on all stack and remove gaussian blurred on single image for max detection
//Ver 2.0	add function for "stardist" nucleis 2D extraction
//			remove scale for counting in pixels
//			add 2 new functions


//QPath
//3D suite
//3D stardist

requires("1.53d");

//close
if(isOpen("Results")){
	selectWindow("Results");
	run("Close");
	}
if(isOpen("Log")){
	selectWindow("Log");
	run("Close");
	}
run("Remove Overlay");
run("Select None");

//tableau des informations : récolte les informations du fichier traité pour les ajouter au tableau des résultats en fin de boucle
info_table = newArray(1);

///////

launch();

///////

//all the processing is grouped
function launch(){
	
	lif_dir = getDirectory("Choose the directory where .lif files are stored ");
	tif_dir = getDirectory("Select the directory where will be stored .tif files ...");
	
	//outputPath=File.openDialog("Select output file ...");
	//outputPathCSV=File.openDialog("Select output CSV file ...");
	
	startTime = getTime();

	//ret_arr = GUI();
    //p = ret_arr[0];
    //aire = ret_arr[1];
    //rayon = ret_arr[2];
	
	setBatchMode(true);
	forAllLif(lif_dir,tif_dir);
	
	setBatchMode(false);
	//forAllTiff(tif_dir);
	
	endTime = getTime();
	
	totalTime = endTime - startTime;
	totalSeconds = totalTime / 1000;
	hours = totalSeconds / 3600;
	minutes = (totalSeconds % 3600) / 60;
	seconds = totalSeconds % 60;
	print("Fin du programme en : " + round(hours) + " h " + round(minutes) + " min " + round(seconds) + " s ");
}

//GUI
function GUI() { 
	Dialog.create("Parameters ajusting");
	Dialog.addMessage("Choose Prominances");
	Dialog.addSlider("for channel 1 (mitosox): ", 1, 255, 60);
	Dialog.addNumber("Nucleis's Area above (pixels) will be counted :", 1100);
	Dialog.addNumber("Size of nucleis (µm)", 4);  
	Dialog.show();
	
	p=Dialog.getNumber();//prominence channel 1
	aire=Dialog.getNumber();
	rayon = Dialog.getNumber();

	return newArray(p, aire, rayon);	
}

function forAllLif(lif_dir, tif_dir) {
	
	LIF_file_list = getFileList(lif_dir); 							// récupère les fichiers du dossier lif_dir
	for (i=0; i<LIF_file_list.length; i++) { 
		if (endsWith(LIF_file_list[i], ".lif")){ 					// filtre les fichiers LIF
			gestionFichiers(lif_dir, LIF_file_list[i], tif_dir);	// appel de la fonction gestionFichiers dessus
			close("*");
		}
	}
}

function gestionFichiers(lif_dir, LIF_file_name, outPath) {
	
	filePath = lif_dir + LIF_file_name; 					// construction du chemin du fichier
	
	run("Bio-Formats Macro Extensions");				// lance le plugin Bio-Format (nécessaire pour les fontions suivantes)
	Ext.setId(filePath);								// donne le chemin du fichier à l'objet qui contrôle le plugin
	Ext.getCurrentFile(file);							// place dans l'objet le fichier adress
	Ext.getSeriesCount(serieCount);						// récupère le nombre d'image dans le set (ici fichier LIF)
	tif_names = newArray(serieCount);					// initialise le tableau des noms des fichiers

	for (s=0; s<serieCount; s++) {
		Ext.setSeries(s);								// place le curseur sur le fichier TIFF
		tif_names[s] = "";
		Ext.getSeriesName(tif_names[s]);				// récupère le nom du fichier
		file_name2 = tif_names[s]+".tif";				// ajout de l'extension
		
		// Bio-Formats Importer uses an argument that can be built by concatenate a set of strings
		run("Bio-Formats Importer", "open=&filePath autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+ (s+1));
		LIF_file_name = replace(LIF_file_name,".lif"," - ");	// pour rendre le fichier lisible
		file_name2 = replace(file_name2, "/", "_");		// idem
		saveAs("Tiff",outPath+LIF_file_name+file_name2);	// enregistre le fichier
		//Ext.setId(filePath);
		//close();
	}
}


function forAllTiff(tif_dir) {
	file_list = getFileList(tif_dir);
	for (i=0; i < file_list.length; i++) {
		if (endsWith(file_list[i], ".tif")){
			fichier = file_list[i];
			info_table = newArray(fichier,p,aire,rayon);				//initialisation du tableau au nom du .tif
			file_path = tif_dir + fichier;
			launch_2(file_path);
			close("*");
		}
	}
}


function launch_2(filepath){
	open(file_path);
	dir = File.getParent(fichier);
	name = File.getName(fichier);
	selectWindow(name);
	
	getPixelSize(unit, pixelw, pixelh,pixelz);
	print("pixelz = " + pixelz);
	if((unit=="pixels")||(unit=="pixel"))
		exit("pixel size is not scaled !");
	getDimensions(width, height, channels, slices, frames);
	thick=slices*pixelz;
	thick1nuclus=floor(thick/rayon);
	SlicesFor1Nucleus=floor(slices/thick1nuclus);
	premier=slices%SlicesFor1Nucleus+1;
	
	selectWindow(name);
	
	//reduce number of slice to be able to do group Z project for each channels
	run("Duplicate...", "title=mitosox duplicate channels=1 slices="+premier+"-"+slices);
	run("Gaussian Blur 3D...", "x=3 y=3 z=3");
	run("Grouped Z Project...", "projection=[Max Intensity] group="+SlicesFor1Nucleus);
	selectWindow("mitosox");
	close();
	selectWindow(name);
	run("Duplicate...", "title=nucleis duplicate channels=2 slices="+premier+"-"+slices);
	run("Gaussian Blur 3D...", "x=3 y=3 z=3");
	run("Grouped Z Project...", "projection=[Max Intensity] group="+SlicesFor1Nucleus);
	selectWindow("nucleis");
	close();
	
	selectWindow(name);
	
	close();
	//now we get only 2 stacks :MAX_mitoxox and MAX_nucleis
	
	//--------------------------------------- Nucleis calculation
	run("Set Measurements...", "area centroid limit redirect=None decimal=3");
	//clean
		if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}
		if(isOpen("ROI Manager")){
			selectWindow("ROI Manager");
			run("Close");
		}
	
	selectWindow("MAX_nucleis");
	run("8-bit");
	run("Set Scale...", "distance=0 known=0 unit=pixel");
	ns=nSlices;
	
	//process
	total=0;
	print("-------------------- nSlices = " + ns + " ------------------");
	for(j=1;j<=ns;j++){
		selectWindow("MAX_nucleis");
		setSlice(j);
		run("Duplicate...", "title=imgDup");
		run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'imgDup', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'72.7', 'percentileTop':'98.4', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'modelFile':'C:\\\\Users\\\\crouvier\\\\Downloads\\\\3d-unet---arabidopsis---zerocostdl4mic_tensorflow_saved_model_bundle\\\\TF_SavedModel.zip', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'true', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
		rename("labels");
		s=CountNucleisAreaLessThan("labels",aire);
		
		total=total+s;
		
		selectWindow("labels");
		close();
		
		CountNucleisAreaLessThan_control("MAX_nucleis",j,aire);
		//IJ.renameResults("Results"+"_"+j);  //for test
		if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}
		selectWindow("imgDup");
		close();
	}

	outputRes = name + " : Nucleis total number = "+total;
	
	tab_buff = newArray(unit,pixelw,pixelh,pixelz,width,height,channels,slices,frames,thick,ns,total);
	
	//affichage dans une fenêtre log
	print(outputRes);
	//enregistrement dans un fichier
	end_buff = "";
	for (i = 0; i < info_table.length; i++) {
		end_buff = end_buff + info_table[i] + ",";
	}
	for (i = 0; i < tab_buff.length - 1; i++) {
		end_buff = end_buff + tab_buff[i] + ",";
	}
	end_buff = end_buff + tab_buff[tab_buff.length -1];
	
	

	File.append(end_buff, outputPathCSV);
	File.append(outputRes, outputPath);
	

	////mitosoxCalculation();
}

//----------------------------------------- mitosox calculation
function mitosoxCalculation() {
	selectWindow("MAX_mitosox");
	run("8-bit");
	run("Set Scale...", "distance=0 known=0 unit=pixel");
	//run("Set Scale...", "distance=0 known=0 unit=pixel");
	//run("Median...", "radius=3 stack");
	s=findMaxiOnStack(p);
	print("Mitosox signals number="+s);
	rename("mitosox-stack");
	findMaxiOnStack_VisualControl("mitosox-stack",p);
	run("Tile");
}

//---------------------------------------------Functions
function CountNucleisAreaLessThan(image,a){
//run stardist  "versatile" 
//scan segmented particles and count those above area : "a" 
//draw on averlay a white dot for control
	selectWindow(image);
	//get "Label Image" image
	getMinAndMax(min, max);
	
	n=0;
	
	for (i = 1; i <= max; i++) {
		selectWindow(image);
		setThreshold(i, i);
		run("Measure");
	    area=getResult("Area",i-1);	    
	    if(area>=a)
	    	n++;
	    //Table.deleteRows(nResults-1,nResults-1);
		//updateResults();
	    	
		}
	return n;
	}

//----------------------------------------------------------
function CountNucleisAreaLessThan_control(image,k,a){
//need a stack and a Results tab
//k is slice number, a is min area , image is image where cross are drawed in overlay
	selectWindow(image);
	
	if(!isOpen("Results"))
		exit("Results tab is need !");
		
	if(nSlices<1)
		exit("Stack is needed !"); // <= ou < simple
			    
	setSlice(k);
	n=nResults;
	p=0;
	for (i = 0; i < n; i++) {
    	if( (getResult("Area", i)>=a) ){
    		    x = floor(getResult('X', i));
    			y = floor(getResult("Y", i));
    			makePoint(x,y,"small white add");//draw
    			p++;
    		}
	}
	
}

//---------------------------------------------------------
function findMaxiOnStack(p){
//find Maxima on in focus stack
//return the sum for all images in stack
//p=prominence
run("Options...", "iterations=5 count=1 black");
n=nSlices;
s=0;
for(i=1;i<=n;i++){
	setSlice(i);
	run("Find Maxima...", "prominence="+p+" output=Count");
	s=s+getResult("Count");	
	}
if(isOpen("Results")){
	selectWindow("Results");
	run("Close");
	}
return s;
}

//---------------------------------------------------------------------------------
function findMaxiOnStack_VisualControl(image,p){
//make a visual result of max count on original stack :"image"
	run("Options...", "iterations=5 count=1 black");
	selectWindow(image);
	n=nSlices;

	for(i=1;i<=n;i++){
		setSlice(i);
		run("Find Maxima...", "prominence="+p+" output=[Single Points]");
		run("Options...", "iterations=5 count=1 black do=Dilate");
		rename("output");
		selectWindow(image);
		
		run("Add Image...", "image=output x=0 y=0 opacity=100 zero");
		selectWindow("output");
		close();
	}
}

