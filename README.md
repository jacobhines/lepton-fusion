Image Capture (run on Raspberry Pi command line)
---------------------------------------

Build instructions (must be repeated after any changes to \thermal-camera\capture\visible\raspberrypi_capture):
1. Change directory to \thermal-camera\capture\visible\
2. Run 'make' command
3. Copy the compiled "raspberrypi_capture" executable file to the \thermal-camera\capture\thermal\ directory

Runtime instructions:
1. Run "camera_visiblePreview.py" with the command "sudo python3.5 camera_visiblePreview.py"
2. Physical button to capture, images are saved to the "out" folder
3. To exit the program: initiate the capture sequence, press alt+tab to switch to the command line, 
	press ctrl+c to exit the program
	

Image Fusion (Run on Matlab)
---------------------------------------
Build instructions:
1. Change to directory "\thermal-camera\processing\" in Matlab
2. Run setupDirectories.m

Sample script:
1. sampleScript.m shows image registration and GTF fusion as an example of the image processing pipeline.

Run instructions (examples):
1. Run registration/testRegistration.m
2. Images are stored in registration/registered_images directory
3. Run fusion/testYCbCrFusion.m
4. Run fusion/testQuantitativeFusion.m
5. Images are saved to fusion/figures 