#!/usr/bin/env python2
"""
Lenovo Yoga 2 11 auto rotate script for Ubuntu 16.04

- Adjusted /sys/...accel filenames as I found them
- Added notify support
- Debugged accelerometer values

Initial version based on:
thinkpad-rotate.py

Rotates any detected screen, wacom digitizers, touchscreens,
touchpad/trackpoint based on orientation gathered from accelerometer. 

Tested with Lenovo Thinkpad Yoga S1

https://github.com/admiralakber/thinkpad-yoga-scripts

Acknowledgements:
Modified from source:
https://gist.githubusercontent.com/ei-grad/4d9d23b1463a99d24a8d/raw/rotate.py

"""

### BEGIN Configurables

rotate_pens = False # Set false if your DE rotates pen for you
disable_touchpads = False # Don't use in conjunction with tablet-mode
disable_touchpads = True  # Do use it

### END Configurables


from time import sleep
from os import path as op
import sys
from subprocess import check_call, check_output
from glob import glob
from os import environ, system
import notify2

def sendmessage(title, message):
    notify2.init("Test")
    notice = notify2.Notification(title, message)
    notice.show()
    return

def bdopen(fname):
    return open(op.join(basedir, fname))


def read(fname):
    return bdopen(fname).read()


#for basedir in glob('/sys/bus/iio/devices/iio:device*'):
for basedir in glob('/sys/devices/pci0000:00/0000:00:14.0/usb1/1-4/1-4:1.0/0003:048D:8386.0003/HID-SENSOR-200073.2.auto/iio:device*'):
    if 'accel' in read('name'):
        break
else:
    sys.stderr.write("Can't find an accellerator device!\n")
    sys.exit(1)


env = environ.copy()

devices = check_output(['xinput', '--list', '--name-only'],env=env).splitlines()

touchscreen_names = ['touchscreen', 'touch digitizer','maXTouch']
touchscreens = [i for i in devices if any(j in i.lower() for j in touchscreen_names)]

wacoms = [i for i in devices if any(j in i.lower() for j in ['wacom'])]

touchpad_names = ['touchpad', 'trackpoint']
touchpads = [i for i in devices if any(j in i.lower() for j in touchpad_names)]

scale = float(read('in_accel_scale'))

# Values on this laptop oscillate strangely between 0-1000 and 64000-65535,
#   kernel driver dependant?
thres = 500
thres2 = 65000

STATES = [
    {'rot': 'normal', 'pen': 'none', 'coord': '1 0 0 0 1 0 0 0 1', 'touchpad': 'enable',
     'check': lambda x, y: x < thres and y > thres},
    {'rot': 'inverted', 'pen': 'half', 'coord': '-1 0 1 0 -1 1 0 0 1', 'touchpad': 'disable',
     'check': lambda x, y: (x < thres or x > thres2) and y < 1000},
    {'rot': 'left', 'pen': 'ccw', 'coord': '0 -1 1 1 0 0 0 0 1', 'touchpad': 'disable',
     'check': lambda x, y: x < 1000 and (y < thres or y > thres2)},
    {'rot': 'right', 'pen': 'cw', 'coord': '0 1 0 -1 0 1 0 0 1', 'touchpad': 'disable',
     'check': lambda x, y: x > 64000 and (y < thres or y > thres2)},
]


def rotate(state):
    s = STATES[state]
    check_call(['xrandr', '-o', s['rot']],env=env)
    for dev in touchscreens if disable_touchpads else (touchscreens + touchpads):
        check_call([
            'xinput', 'set-prop', dev,
            'Coordinate Transformation Matrix',
        ] + s['coord'].split(),env=env)
    if rotate_pens:
        for dev in wacoms:
            check_call([
                'xsetwacom','set', dev,
                'rotate',s['pen']],env=env)
    if disable_touchpads:
        for dev in touchpads:
            check_call(['xinput', s['touchpad'], dev],env=env)

    if s['touchpad'] == 'disable':
        system('onboard &')
    else:
        check_call(['killall','onboard'],env=env)
    sleep(10)
    exit(0)

def read_accel(fp):
    fp.seek(0)
    return float(fp.read()) * scale


if __name__ == '__main__':


    current_state = None

    #while True:
    for ii in range(4):
        x = int(read('in_accel_x_raw')) 
        y = int(read('in_accel_y_raw'))
        z = int(read('in_accel_z_raw'))
        print 'x/y/z = ' + str(x) + ' ' + str(y) + ' ' + str(z)
        #print 'x/y = ' + str(x) + ' ' + str(y)
	
        for i in range(4):
            if i == current_state:
                continue
            if STATES[i]['check'](x, y):
	    	if z < thres2:
                    # Screen is too flat down so don't change orientation
                    print "Z axis prevented changing state to " + str(i)
		else:
		    sendmessage( "Auto rotate", "Changing to " +  STATES[i]['rot'])
                    current_state = i
                    #print "changing state to " + str(i)
                    rotate(i)
        sleep(1)
    sleep(10)
