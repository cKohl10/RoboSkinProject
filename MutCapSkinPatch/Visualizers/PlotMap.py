# Generic heat map for Robotic Skin
# Carson Kohlbrenner
# 7/20/2023

# Making the serial connection
import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation

###### Comment out incorrect serials #######
serialPort = 'COM4' #Windows
#serialPort = '/dev/ttyACM0' #Linux


# Main Parameters
ser = serial.Serial(serialPort, 115200) #Serial port /dev/ttyACM0, 9600 baud
num_RX = 3
num_TX = 10
numSensors = num_RX*num_TX
threshold = 9000 #Activation threshold
calibVals = [0 for i in range(numSensors)]
calRaw = [[] for i in range(numSensors)]
visLim = 200; #Number of data points to show
rejectionLevel = 0.8 #Percent range of rejection

######### Helper Functions ##########
def readSkin(s):
    sepData = s.split(',')
    value = []
    value = [0 for i in range(len(sepData))]
    for i in range(len(sepData)):
        if sepData[i] == '':
            return -1
        if len(sepData)==numSensors:
            value[i] = int(sepData[i])
        else:
            return -1
    return value

def reset():
    for i in range(20):
        s = ser.readline()

    for i in range(30):
        s = ser.readline().decode('utf-8').rstrip()
        vals = readSkin(s)
        while(vals == -1):
            s = ser.readline().decode('utf-8').rstrip()
            vals = readSkin(s)
        ser.flushInput()
        for j in range(numSensors):
            calRaw[j].append(vals[j])

    for i in range(numSensors):
        calibVals[i] = sum(calRaw[i])/len(calRaw[i])
    return calibVals

def isTouching(vals, threshold):
    isTouched = []
    isTouched = [0 for i in range(len(vals)-1)]
    for i in (range(len(vals)-1)):
        if vals[i] > threshold:
            isTouched[i] = 1
    return isTouched
            

# Function to animate the graph
def animate(i, xs, ys, threshold, calibVals, rejectionLevel):
    s = ser.readline().decode('utf-8').rstrip()
    vals = readSkin(s)
    while(vals == -1):
        s = ser.readline().decode('utf-8').rstrip()
        vals = readSkin(s)
    ser.flushInput()

    ax.clear()
    xs.append(len(xs))
    xs = xs[-visLim:]

    #Generating the plots
    for i in range(numSensors):
        ysRaw[i].append(vals[i])
        #meanRaw[i] = sum(ysRaw[i])/len(ysRaw[i])
        #ys[i].append((vals[i]-meanRaw[i])*(vals[i]-meanRaw[i]>-50))
        if vals[i] <= calibVals[i]*(1/rejectionLevel) and vals[i] >= calibVals[i]*rejectionLevel:
            ys[i].append(vals[i]-calibVals[i])
        else:
            ys[i].append(ys[i][len(ys[i])-2])
        # Limit x and y lists to 20 items
        labelName = "Sensor " + str(i+1)
        ys[i] = ys[i][-visLim:]
        ysRaw[i] = ysRaw[i][-visLim:]
        ax.plot(xs, ys[i], label = labelName)
        mean[i] = sum(ys[i])/len(ys[i])

    # Draw x and y lists
    threshold = min(mean)
    ax.plot([xs[0], xs[len(xs)-1]], [threshold, threshold], label = "Threshold", linestyle="--")
    #plt.ylim(0.8*min(mean), 1.2*max(mean))

    #Plot Labeling
    ax.set_ylabel('Clock Cycles')
    ax.set_xlabel('Time (s)')
    ax.set_title('Sensed Capacitance')
    #if ax.lines:
    #    plt.legend()

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
ani = animation.FuncAnimation(fig, animate, fargs=(xs, ys, threshold, calibVals, rejectionLevel), interval=10)
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


