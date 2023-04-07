//06/07/2022
//ver 2.6
//measurement of ROS
//ver 2.5
//mitochondria are counted too
//ver 2.4
//run time is counted and some optimisation has been brought
//ver 2.3
//the nucleis count is now ajust by a centroid proximity function to suppress two time's counted nucleis 
//ver 2.2 
//the nucleis count is now applied on the whole data set and results are redirected to a chosen CSV file 

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



/**LANCEMENT
 * 
 */
requires("1.53d");
launch();

/** INITIALISATION
 * > choix du mode de lancement
 * > lancement des procedures en fonction des choix :
 * -> si conversion lif tif, recuperation des répertoires d'entrée et de sortie des fichiers
 * -> si comptage, 	recuperation du repertoire d'entrée
 * 					appel à GUI()
 * 					recuperation des paramètres
 * 					appel à forAllTiff
 * > message de terminaison
 */
function launch(){
	
	Dialog.create("Launch style");
	Dialog.addCheckbox("lif to tif", false);
	Dialog.addCheckbox("tif to count", false);
	Dialog.show();
	lifToTiff = Dialog.getCheckbox();
	tifToCount = Dialog.getCheckbox();
	
	startTime = getTime();
	
	if(lifToTiff){
		lif_dir = getDirectory("Select the directory where .lif files are stored ");
		tif_dir = getDirectory("Select the directory where will be stored .tif files ...");
		
		setBatchMode(false);
		forAllLif(lif_dir,tif_dir);
	}
	if(tifToCount){
		if(!lifToTiff) 
			tif_dir = getDirectory("Select the directory where .tif files are stored ...");
		
		//outputPath=File.openDialog("Select output file ..."); //test
		outputPathCSV = File.openDialog("Select output CSV file ...");
		File.append("name;unit;pixelW;pixelH;pixelZ;width;height;channels;frames;slices;nucleus_area;diameter;marge;totalThick;nucleusSlices;totalPlainNucleus;slicesLeft;totalNucNotCorr;totalMitoNotCorr;corrTotaleNuc", outputPathCSV);
		
		ret_arr = GUI();
		nucleus_area = ret_arr[0];
		mito_area = ret_arr[1];
		diameter = ret_arr[2];
		setBatchMode(false);
		forAllTiff(tif_dir);
	}

	endTime = getTime();
	
	totalTime = endTime - startTime;
	totalSeconds = totalTime / 1000;
	hours = totalSeconds / 3600;
	minutes = (totalSeconds % 3600) / 60;
	seconds = totalSeconds % 60;
	temps = "Fin du programme en : " + round(hours) + " h " + round(minutes) + " min " + round(seconds) + " s ";
	print(temps);
	File.append("", outputPathCSV);
	File.append(temps, outputPathCSV);
}


/** CONVERTION LIF > TIFF 
 * > récuperation de la liste des fichiers du répertoire des .lif
 * > boucle sur la liste, si le fichier est un .lif -> appel à gestionFichier()
 */
function forAllLif(lif_dir, tif_dir) {
	
	LIF_file_list = getFileList(lif_dir);
	for (i=0; i<LIF_file_list.length; i++) { 
		if (endsWith(LIF_file_list[i], ".lif")){
			gestionFichiers(lif_dir, LIF_file_list[i], tif_dir);
			close("*");
		}
	}
}

/** CONVERSION des LIFF en TIFF
 * > récupération de l'adresse du fichier
 * > préparation
 * > boucle pour récupérer tous les .tif
 */
function gestionFichiers(lif_dir, LIF_file_name, outPath) {
	
	filePath = lif_dir + LIF_file_name;
	
	run("Bio-Formats Macro Extensions");
	Ext.setId(filePath);
	Ext.getCurrentFile(file);
	Ext.getSeriesCount(serieCount);
	tif_names = newArray(serieCount);

	for (s=0; s<serieCount; s++) {
		Ext.setSeries(s);
		tif_names[s] = "";
		Ext.getSeriesName(tif_names[s]);
		file_name2 = tif_names[s] + ".tif";
	
		// Bio-Formats Importer uses an argument that can be built by concatenate a set of strings
		run("Bio-Formats Importer", "open=&filePath autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+ (s+1));
		LIF_file_name = replace(LIF_file_name,".lif"," - ");
		file_name2 = replace(file_name2, "/", "_");
		saveAs("Tiff",outPath + LIF_file_name + file_name2);
		//close();
	}
}


/** PARAMETRAGE
 * > choix des paramètres : nucleus_area minimale de prise en compte, taille du noyau attendue
 * (propre au projet) taille du noyau par défaut à trois pour être sensiblement en deça des tailles observées
 */
function GUI() { 
	Dialog.create("Parameters ajusting");
	Dialog.addNumber("Nucleis's Area above (pixels) will be counted :", 1100);
	Dialog.addNumber("Mitochondria's Area under (pixels) will be counted :", 200);
	Dialog.addNumber("Size of nucleis (µm)", 3); 
	Dialog.show();
	
	nucleus_area = Dialog.getNumber();
	mito_area = Dialog.getNumber();
	diameter = Dialog.getNumber();

	return newArray(nucleus_area, mito_area, diameter);	
}


/** GENERALISATION DU TRAITEMENT
 * récuperation de la liste des fichiers du répertoire des .tif
 * boucle sur la liste, si le fichier est un .Tif -> appel à ouverture()
 */
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
	}
} // --> launch

/** OUVETURE du FICHIER
 * relica d'une autre architecture à conserver pour la lisibilité sinon incorporer à splitProjections()
 */
function ouverture(filepath){
	open(file_path);
	dir = File.getParent(fichier);
	name = File.getName(fichier);
	
	splitProjections(name); // --> splitProjections
	
	selectWindow("ROI Manager"); run("Close");
} // --> forAllTiff

/** PREPARATION des PROJECTIONS
 * > récupération des détails du fichier
 * > calculs des paramètres de la découpe en projection
 * > traitement du stack avant découpe
 * > initialisation de la table des positions
 * > boucle pour la création des projections et pour l'appel à measurement()
 * > préparation puis lancement de l'appel à correction()
 */
function splitProjections(name){
	selectWindow(name);
	getPixelSize(unit, pixelW, pixelH, pixelZ);
	getDimensions(width, height, channels, slices, frames);
	
	if((unit=="pixels")||(unit=="pixel"))	exit("pixel size is not scaled !");
	
	run("Duplicate...", "title=nucleis duplicate channels=2");
	run("Gaussian Blur 3D...", "x=3 y=3 z=1"); // Christian préferait une valeur de 3,3,3
	
	// TODO insérer ici la duplication du rouge
	 
	selectWindow(name); close();
	
	totalThick = slices*pixelZ; //en µm
	nucleusSlices = floor(diameter/pixelZ); //(nombre de tranches par projection)
	if(nucleusSlices%2==1){ // on cherche à ce que le nb de tranche par projection soit pair
		nucleusSlices+=1;
	}
	totalPlainNucleus = floor(slices/nucleusSlices); //nombre de projection(s)
	slicesLeft = slices%nucleusSlices;
	mitoSlices = nucleusSlices/2;
	
	//print("totalPlainNuleus="+totalPlainNucleus+" , nucleusSlices=" + nucleusSlices + " , slicesLeft="+slicesLeft);
	
	Table.create("tabXY");
	arrSize = newArray(totalPlainNucleus);	// tableau de taille *nombe de projection* pour le nombre de noyau par projection
	totalNotCorr = 0;						// nombre total avant correction
	
	//toutes les projections sont traitées avant correction
	for (i = 0; i < totalPlainNucleus; i++) {
		selectWindow("nucleis");
		run("Z Project...","start=" + (i*nucleusSlices)+1 + " stop=" + (i+1)*nucleusSlices + " projection=[Max Intensity]");
		rename("p"+i);
		
		measureRes = measurement(i);			// --> measurement
		
		arrSize[i] = measureRes[0];
		totalNucNotCorr+=measureRes[1];
		totalMitoNotCorr+=measureRes[2];
		
		selectWindow("p"+i); close();			// fermeture projection bleu
	}
	
	selectWindow("nucleis"); close();
	
	corrTotaleNuc = 0; 							// variable de correction
	
	marge = floor((diameter/pixelZ)/10); 		// traitement de la marge sujet à modification pour ajuster la precision de la correction
	
	if(totalPlainNucleus>1){
		// TODO ajouter le control des mitochondries
		for (i = 0; i < totalPlainNucleus-1; i++) {
			c = correction(i,i+1,marge);
			corrTotaleNuc += c;
		}
	}
	
	selectWindow("tabXY"); run("Close");
	
	csvArray = newArray(name,unit,pixelW,pixelH,pixelZ,width,height,channels,frames,slices,nucleus_area,diameter,marge,totalThick,nucleusSlices,totalPlainNucleus,slicesLeft,totalNucNotCorr,totalMitoNotCorr,corrTotaleNuc);
	csvString = "";
	
	for (i = 0; i < csvArray.length-1; i++) csvString = csvString + csvArray[i] + ";" ;
	csvString = csvString + csvArray[csvArray.length-1];
	//print(csvString);
	//print(outputPathCSV);
	File.append(csvString, outputPathCSV);
} // --> ouverture

/** PREPARATION de l'IMAGE et LANCEMENT du COMPTAGE et de la CORRECTION
 * > préparation des mesures
 * > netoyage de l'écran et ajustement de l'image
 * > duplication puis éxecution de stardist
 * > appel à CountNucleisAreaLessThan()
 * > appel à CountNucleis_control()
 */
function measurement(k) { 
	run("Set Measurements...", "area centroid limit redirect=None decimal=3");
	//clean
	if(isOpen("Results")){
		selectWindow("Results"); run("Close");
	}
	if(isOpen("ROI Manager")){
		selectWindow("ROI Manager"); run("Close");
	}
	
	selectWindow("p"+k);
	run("8-bit");
	run("Set Scale...", "distance=0 known=0 unit=pixel");

	total_nuc=0; //variable de compte des objets
	total_mito=0;
	run("Duplicate...", "title=imgDup");
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'imgDup', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'72.7', 'percentileTop':'98.4', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'modelFile':'C:\\\\Users\\\\crouvier\\\\Downloads\\\\3d-unet---arabidopsis---zerocostdl4mic_tensorflow_saved_model_bundle\\\\TF_SavedModel.zip', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'true', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	rename("labels");
	
	numbers = CountNucleisAreaLessThan("labels");			// --> CountNucleisAreaLessThan
	total_nuc = total_nuc+numbers[0];
	total_mito = total_mito+numbers[1];
	
	selectWindow("labels"); close();
	
	arrEnd = CountNucleis_control("p"+k,k,nucleus_area);	// --> CountNucleis_control
	
	if(isOpen("Results")){
		selectWindow("Results"); run("Close");
	}
	selectWindow("imgDup"); close();
	
	return newArray(arrEnd,total_nuc,total_mito); 			// --> splitProjections
}

/** COMPTAGE par TAILLE
 * 
 */
function CountNucleisAreaLessThan(image){
//run stardist  "versatile" 
//scan segmented particles and count those above area : "obj_area" 
//draw on averlay a white dot for control
//return the number of object counted
	selectWindow(image);
	//get "Label Image" image
	getMinAndMax(min, max);
	nuc_number=0;
	mito_number=0;
	for (i = min; i <= max; i++) {
		selectWindow(image);
		setThreshold(i, i);
		run("Measure");
	    obj_area=getResult("Area",i-1);	    
	    if(obj_area>=nucleus_area)	nuc_number++;
	    else { if(obj_area>=100 && obj_area<=mito_area)	mito_number++; }
	    //Table.deleteRows(nResults-1,nResults-1);
		//updateResults();
	}
	return newArray(nuc_number,mito_number);
}

/** RECUPERATION des POSITIONS
 * 
 */
function CountNucleis_control(image,k,a){
//need a stack and a Results tab
//a is min area , image is image where cross are drawed in overlay
	selectWindow(image);
	
	if(!isOpen("Results")) 	exit("Results tab is need !");
	if(nSlices<1)			exit("Stack is needed !" + fichier);
	
	n=nResults;
	selectWindow("Results");
	Table.sort("Area");
	
	//suppression des objets trop petits
	areaStart=0;
	for (i = 0; i < n && areaStart==0; i++) {
    	if((getResult("Area", i)>=nucleus_area)) areaStart=i;
	}
	Table.deleteRows(0, areaStart-1);
	n=nResults;
	ptX = newArray(n);
	ptY = newArray(n);
	for (i = 0; i < n; i++) {
	    x = floor(getResult('X', i));
		y = floor(getResult("Y", i));
		ptX[i]=x;
		ptY[i]=y;
	}
	arrEnd = creationTable(ptX,ptY,k,n);	// --> creationTable
	
	return arrEnd;						// --> measurement
}

/** CREATION de la TABLE des POSITIONS
 * > récupère les positions des différentes projections pour les ranger dans la meme table
 */
function creationTable(ptX,ptY,k,n) {
	arrEnd = n;
	// partie récupération des coordonnées pour les trier
	Table.create("tabXY"+k);
	Table.setColumn("X",ptX);
	Table.setColumn("Y",ptY);
	Table.sort("Y");
	Table.sort("X");
	
	arrX = Table.getColumn("X");
	arrY = Table.getColumn("Y");
	
	selectWindow("tabXY"+k); run("Close"); 
	selectWindow("tabXY");
	
	Table.setColumn("X"+k, arrX);
	Table.setColumn("Y"+k, arrY);
	
	return arrEnd;					// --> CountNucleis_control
}

/** ELIMINATION des REDONDANCES
 * > boucle sur le tableau des positions en fonction de Xi 
 * > vérifie les proximités des points des différentes projections, appel à dist() 
 * 
 */
function correction(first,second,marge) {
	
	selectWindow("tabXY");
	cor = 0; bot = 0;
	end = arrSize[second];
	
	for (i = 0; i < arrSize[first]; i++) {
		x1 = Table.get("X"+first, i);
		y1 = Table.get("Y"+first, i);
		top = true;
		for(j = bot; j < end && top; j++){
			x2 = Table.get("X"+second, j);
			y2 = Table.get("Y"+second, j);
			d = sqrt(pow(x1-x2,2)+pow(y1-y2,2));
			if(d<=marge) cor++;
		}
	}
	
	return cor;								// --> splitProjection
}
