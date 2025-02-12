/*
 * Description: Perform color deconvolution, detect cells with Cellpose and measure their intensity in blue channel
 * Developed for: Adèle, De Thé's team
 * Author: Héloïse Monnet @ ORION-CIRB 
 * Date: February 2025
 * Repository: https://github.com/orion-cirb/BGal_Senescence
 * Dependencies: PTBIOP Fiji plugin + Cellpose conda environment
*/


// PARAMETERS TO REVIEW BEFORE LAUNCHING MACRO //
cellposeEnvPath = "C:/Users/utilisateur/miniconda3/envs/CellPose/";
cellposeModelName = "cyto2";
cellposeDiameter = 140; // pix     20x: 80       40x: 140

cellMinArea = 2000; // pix         20x: 1000     40x: 2000
cellMaxArea = 50000; // pix        20x: 20000    40x: 50000
cellMinCircularity = 0.5;
cellMaxCircularity = 1;
////////////////////////////////////////////////


// Hide images during macro execution
setBatchMode(true);

// Ask for the images directory
inputDir = getDirectory("Please select a directory containing images to analyze");
print("Analysis started");

// Create results directory
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
resultDir = inputDir + "Results_" + year + "-" + (month+1) + "-" + dayOfMonth + "_" + hour + "-" + minute + "-" + second + File.separator();
if (!File.isDirectory(resultDir)) {
	File.makeDirectory(resultDir);
}

// Get all files in the input directory
inputFiles = getFileList(inputDir);

// Create global/branches_length/branches_diam results files and write headers in them
resultFileName = resultDir + "results.csv";
resultFile = File.open(resultFileName);
File.close(resultFile);
File.append("Image name,Methylene Blue background noise,Cell ID,Cell area (pix),Cell mean Methylene Blue intensity", resultFileName);

// Loop through all files with tif extension
for (i = 0; i < inputFiles.length; i++) {
    if (endsWith(inputFiles[i], ".tif")) {
    	print("Analyzing image " + inputFiles[i] + "...");
    	imgName = replace(inputFiles[i], ".tif", "");
		
		// Open cells channel
		open(inputDir + inputFiles[i]);
		rename("imgRgb");
		
		// Perform color deconvolution
		run("Colour Deconvolution", "vectors=Giemsa");
		if(i==0) {
			selectImage("Colour Deconvolution");
			saveAs("Tiff", resultDir + "colourDeconvolution");
		}
		selectImage("imgRgb-(Colour_1)");
		saveAs("Tiff", resultDir + imgName + "_methyleneBlue");
		rename("imgBlue");
		
		// Close useless images
		close("colourDeconvolution");
		close("imgRgb-(Colour_2)");
		close("imgRgb-(Colour_3)");
		
		// Detect cells on RGB image with Cellpose
		selectImage("imgRgb");
		run("8-bit");
		run("Invert");
		run("Cellpose ...", "env_path="+cellposeEnvPath+" env_type=conda model="+cellposeModelName+" model_path=path\\to\\own_cellpose_model diameter="+cellposeDiameter+" ch1=0 ch2=-1 additional_flags=--use_gpu");
		
		// Estimate background noise in blue channel
		selectImage("imgRgb-cellpose");
		setThreshold(0, 0);
		run("Set Measurements...", "median limit redirect=imgBlue decimal=2");
		run("Measure");
		bgBlue = getResult("Median", 0);
		close("Results");
		resetThreshold();
		
		// Filter out cells touching edges and with area or circularity out of specified ranges
		setBatchMode("exit and display");
		selectImage("imgRgb-cellpose");
		run("3D Exclude Edges", " ");
		run("Label image to ROIs", "ROI Manager");
		run("Set Measurements...", "area shape redirect=None decimal=2");
		roiManager("measure");
		setBackgroundColor(0, 0, 0);
		cellId = 1;
		for(c = 0; c < roiManager("count"); c++) {
			roiManager("select", c);
			if(getResult("Area", c) < cellMinArea || getResult("Area", c) > cellMaxArea || getResult("Circ.", c) < cellMinCircularity || getResult("Circ.", c) > cellMaxCircularity) {
				// Clear cell in mask
				run("Clear", "slice");
			} else {
				// Reset cell label in mask
				setColor(cellId);
				fill();
				cellId++;
			}
		}
		roiManager("reset");
		close("Results");
		run("Select None");
		setBatchMode(true);
		
		// Save cells ROIs
		selectImage("Objects_removed");
		run("Label image to ROIs", "");
		roiManager("Save", resultDir + imgName + "_cells.zip");
		
		// Save cells parameters
		run("Set Measurements...", "area mean redirect=imgBlue decimal=2");
		roiManager("measure");
		for (r = 0; r < nResults; r++) {
			File.append(imgName+","+bgBlue+","+(r+1)+","+getResult("Area", r)+","+getResult("Mean", r), resultFileName);
		}

		close("*");
		close("Results");
		roiManager("reset");
		close("ROI Manager");
    }
}

setBatchMode(false);

print("Analysis done!");