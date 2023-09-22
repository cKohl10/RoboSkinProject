# Generic heat map for Robotic Skin
# Carson Kohlbrenner
# 7/20/2023

######### Arduino Code #########
#      Muca_Raw_Basic.ino


# Making the serial connection
import serial
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sounddevice as sd
from VarSkinViz import VarSkinViz

###### Comment out incorrect serials #######
# serialPort = 'COM4' #Windows
serialPort = '/dev/ttyACM0' #Linux


# Main Parameters
ser = serial.Serial(serialPort, 115200) #Serial port /dev/ttyACM0, 9600 baud
num_TX = 10
num_RX = 3
threshold = 200
numSensors = num_TX*num_RX
calibVals = [[0 for j in range(num_RX)] for i in range(num_TX)]
heatData = [[0 for j in range(num_RX)] for i in range(num_TX)]
calRaw = [[[] for j in range(num_RX)] for i in range(num_TX)]
rejectionLevel = 0.8 #Percent range of rejection

######### Helper Functions ##########
#This function takes in a string and converts it to data values
def readSkin(s):
    sepData = s.split(',')
    value = []
    value = [[0 for j in range(num_RX)] for i in range(num_TX)]
    count = 0
    if len(sepData)==numSensors:
        for r in range(num_TX):
            for t in range(num_RX):
                if sepData[count] == '':
                    return -1
                value[r][t] = int(sepData[count])
                count = count+1
    else:
        return -1
    return value

#This function is used to flush out bad input data and to calibrate the sensors to zero when not touching
def reset():
    print("Flushing bad data...")
    for i in range(20):
        s = ser.readline()
        #Calibration: number in range below is how many samples to calibrate with
    print("Calibrating...")
    for i in range(50):
        s = ser.readline().decode('utf-8').rstrip()
        vals = readSkin(s)
       
        #Incase a not properly formated line comes in, try again
        while(vals == -1):
            s = ser.readline().decode('utf-8').rstrip()
            vals = readSkin(s)
        ser.flushInput()

        #Form a data set to take the average of
        for r in range(num_TX):
            for t in range(num_RX):
                calRaw[r][t].append(vals[r][t])

    #Take the average and set as baseline
    for r in range(num_TX):
        for t in range(num_RX):
            calibVals[r][t] = sum(calRaw[r][t])/len(calRaw[r][t])
    return calibVals
            

def cv2_show_viz(var_skin_viz, calibVals):

    s = ser.readline().decode('utf-8').rstrip()
    vals = readSkin(s)
    while(vals == -1):
        s = ser.readline().decode('utf-8').rstrip()
        vals = readSkin(s)

    var_skin_viz.update_vals(vals, calibVals)
    var_skin_viz.show_image()


# Function to animate the graph
def animate(i, xs, calibVals, threshold):

    # bip(3000, 0.1)
    #Kills the program when the figure is closed
    nums = plt.get_fignums()
    if 1 not in nums:
        exit()

    s = ser.readline().decode('utf-8').rstrip()
    vals = readSkin(s)
    while(vals == -1):
        s = ser.readline().decode('utf-8').rstrip()
        vals = readSkin(s)
    ser.flushInput()
    ax.clear()
    #Cleaning up the data and calibrating
    # how to I linear index? 
    # 1. r num = num_TX
    # 2. t = num_RX
    
    max_idx = [0,0]
    max_val = 0
    for r in range(num_TX):
        for t in range(num_RX):
            heatData[r][num_RX-(t+1)] = vals[r][t] - calibVals[r][t]
            if heatData[r][num_RX-(t+1)] > max_val:
                max_val = heatData[r][num_RX-(t+1)]
                max_idx[0] = r
                max_idx[1] = t

    # print("Max Val", max_val)
    if max_val > 60.0:
        in_min = 0
        in_max = 29
        out_min = 400
        out_max = 1500
        idx = max_idx[0] * num_TX + max_idx[1] * num_RX
        # print(idx)
        hz = translate(idx, in_min, in_max, out_min, out_max)
        out_min = 0.01
        out_max = 0.05
        time = translate(idx, in_min, in_max, out_min, out_max)
        bip(hz, 0.1)
        # bip(hz+200, 0.1)


    #Generating the plots
    #vmin and vmax are the input max and mins for color
    plt.imshow(heatData, cmap='autumn', vmin=0, vmax = threshold)
    #ax = sns.heatmap(heatData, cmap='autumn')

    #Plot Labeling
    ax.set_title('Touch Sensor Array')

    #Connecting to ROS
    #isTouched = isTouching(vals, threshold)
    #touch_msg = Int8MultiArray()
    #touch_msg.data = isTouched
    #pub.publish(touch_msg)
    #rate.sleep()


# Ros Connection
#pub = rospy.Publisher('chatter', String, queue_size=10)
#pub = rospy.Publisher('/skin_touch', Int8MultiArray, queue_size=1)
#rospy.init_node('robot_skin', anonymous=True)
#rate = rospy.Rate(100)

########## MAIN LOOP ###########
def translate(value, leftMin, leftMax, rightMin, rightMax):
    # Figure out how 'wide' each range is
    leftSpan = leftMax - leftMin
    rightSpan = rightMax - rightMin

    # Convert the left range into a 0-1 range (float)
    valueScaled = float(value - leftMin) / float(leftSpan)

    # Convert the 0-1 range into a value in the right range.
    return rightMin + (valueScaled * rightSpan)

# example code from https://stackoverflow.com/questions/15863534/playing-note-with-pygame-midi
def bip(freq, dur, a=0, d=0, s=1, r=0):
    t=np.arange(0,dur,1/44100)
    env=np.interp(t, [0, a, (a+d), dur-r, dur], [0, 1, s, s, 0])
    sound=np.sin(2*np.pi*freq*t)*env
    sd.play(sound, samplerate=44100)


#Plotting 
# Create figure for plotting

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1)
xs = []
ysRaw = [[] for i in range(numSensors)]
ys = [[] for i in range(numSensors)]
mean = [0 for i in range(numSensors)]
meanRaw = [0 for i in range(numSensors)]
ax.set_ylabel('Clock Cycles')
ax.set_xlabel('Time (s)')
ax.set_title('Sensed Capacitance')

# Create the animation
calibVals = reset()

# Caleb visualize the blur in open cv
# var_skin_viz = VarSkinViz(num_RX, num_TX)
# cv2_show_viz(var_skin_viz, calibVals)
# exit()

ani = animation.FuncAnimation(fig, animate, fargs=(xs, calibVals, threshold), interval=10, cache_frame_data=False)
# Display the graph
plt.show()

#while ser.is_open:
    #s = ser.readline().decode('utf-8').rstrip()
    #vals = readSkin(s)
    #isTouched = isTouching(vals, threshold)
    #plt.show()
    #touch_msg = Int8MultiArray()
    #touch_msg.data = isTouched
    #pub.publish(touch_msg)
    #rate.sleep()


