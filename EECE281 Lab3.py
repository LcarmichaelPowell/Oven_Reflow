import time
import serial
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sys, time, math

from Tkinter import *
from ttk import *





#Create the window

#root = Tk()

#modify root window
#root.title("Labeler")
#root.geometry("200x50")

#app = Frame(root)
#app.grid()
#button1 = Button(app,text ="This is a Button!")


#Kick off event loop
#root.mainloop()

         

# configure the serial port
xsize=100
ser = serial.Serial(
    port='COM3',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_TWO,
    bytesize=serial.EIGHTBITS
)
ser.isOpen()
   
def data_gen():
    t = data_gen.t
    while True:
       strin = ser.readline()
       t+=1
       val=strin
       yield t, val

def run(data):
    # update the data
    t,y = data
    if t>-1: 
        xdata.append(t)
        ydata.append(y)
        line.set_data(xdata, ydata)

    return line,

def on_close_figure(event):
    sys.exit(0)

data_gen.t = -1
fig = plt.figure()
fig.canvas.mpl_connect('close_event', on_close_figure)
ax = fig.add_subplot(111)
line, = ax.plot([], [], lw=2)
ax.set_ylim(0, 250)
ax.set_xlim(0, 800)
ax.grid()
plt.title("Meghan's oven")
plt.xlabel("Time (Seconds)")
plt.ylabel("Temperature (Celsius)")
xdata, ydata = [], []

# Important: Although blit=True makes graphing faster, we need blit=False to prevent
# spurious lines to appear when resizing the stripchart.
ani = animation.FuncAnimation(fig, run, data_gen, blit=False, interval=100, repeat=False)
plt.show()
