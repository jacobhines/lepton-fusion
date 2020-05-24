import cv2
from datetime import datetime
from time import sleep
from picamera import PiCamera
from subprocess import call
from gpiozero import Button

capture_flag = False

def snap():
     global capture_flag
     capture_flag = True

b = Button(12)
b.when_pressed = snap

camera_vis = PiCamera()
camera_vis.resolution = (3280,2464)

print("Initialized")

while True:
    
    if capture_flag:
        capture_flag = False
        
        # get a timestamp and generate thermal and visible image filepaths
        now = datetime.now()
        timestamp = now.strftime("%Y%m%d_%H%M%S")
        fp_vis = "out/" + timestamp + "_vis.jpg"
        fp_thr = "out/" + timestamp + "_thr.jpg"
         
        # capture a thermal image
        call(["./raspberrypi_capture"])
        
        # capture a visible image
        camera_vis.capture(fp_vis)

        # display the thermal image
        im = cv2.imread("im_temp.pgm",0)
        im = cv2.resize(im, (800, 480))
        cv2.imshow('im',im)
        cv2.waitKey(1000)
        
        # save the thermal image
        cv2.imwrite(fp_thr, im)
        
        # load and display the visible image
        im = cv2.imread(fp_vis)
        im = cv2.resize(im, (800,480))
        cv2.imshow('im',im)
        cv2.waitKey(1000)
            
        capture_flag = False
            
    sleep(0.25)