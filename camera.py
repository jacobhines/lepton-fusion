#import numpy as np
import cv2
from time import time
#from pylepton import Lepton3
from picamera import PiCamera 
from subprocess import call
#from tkinter import *
from gpiozero import Button

#root = Tk()
#frame = Frame(root)
#frame.pack()
#b = Button(frame)
capture_flag = False
save_flag = False

def snap():
     global capture_flag
     capture_flag = True
#b.config(command=snap, width='20', height='10', text='Capture')
#frame.pack()
#b.pack()
b = Button(12)
b.when_pressed = snap
print("Initialized")
camera = PiCamera()
camera.resolution = (3280,2464)

while True:
     t = int(time()*1e9)
     call(["./raspberrypi_capture"])
     
     camera.capture("vis_temp.jpg")
     
     if capture_flag:
         camera.capture("out/vis" + str(t) + ".jpg")
         save_flag = True
         capture_flag = False
     
     im = cv2.imread("im_temp.pgm",0)
     cv2.imshow('im',im)
     cv2.waitKey(10)
     #root.update()
     #root.update_idletasks()
     
     if save_flag:
          cv2.imwrite("out/ir" + str(t) + ".jpg", im)
          print("Image saved!")
          im = cv2.imread("out/vis" + str(t) + ".jpg")
          im = cv2.resize(im, (320,200))
          cv2.imshow('im',im)
          cv2.waitKey(1000)
          save_flag=False