import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np
import time
import scipy.misc
import matplotlib.animation as animation
import numpy as np
from pylab import *

def parse(temp):
    #This for loop converts every line into an array of floats stored in a list row
    del temp[0]

    row =[] 
    for line in temp:
        if len(line) < 10:
            del line
        else:
            t = map(float, line.split())
            row.append(t)

    heatmap = []
    i = 0
    while i < len(row) - 3:
        heatmap.append(row[i] + row[i+1] + row[i+2] + row[i+3])
        i += 4

    return heatmap

def min_max(temps):
    mn = 10000
    mx = 0
    for l in temps:
        m = min(l)
        if (m<mn):
            mn = m
        m = max(l)
        if (m>mx):
            mx = m
    return mn,mx

def dto2d (l):
    if len(l) == 64:
        y = 4
        x = 16
    else:
        y = 8
        x = 32
    res = []
    for i in range(y):
        res.append(l[x*i:(i+1)*x])
    return res
def get_temp(pure, mn, mx, scale = "None"):
    temp = dto2d(pure)
    y = len(temp)
    x = len(temp[0])
    
    for i in range(y):
        for j in range(x):
            if temp[i][j] < mn:
                temp[i][j] = 0
            elif temp[i][j]>mx:
                temp[i][j] = 1
            else:
                temp[i][j] = round((temp[i][j]-mn)/(mx-mn),3)
    
    for i in range(y):
        for j in range(x):
            el = temp[i][j]
            if (el<0.33):
                r = el*3
                g = 0
                b = 0
            elif(el<0.66):
                r = 1
                g = (el-0.33)*3
                b = 0
            else:
                r = 1
                g = 1
                b = (el-0.66)*3
            if (scale == "None"):
                temp[i][j] = [r,g,b]
            else:
                g = temp[i][j]
                temp[i][j] = [g,g,g]
    return temp


###################### Start ###############################################


filename = raw_input("Enter filename: ")
opener = filename + ".txt"
temp = open(opener,'r').read().split('\n')

heat_map = parse(temp)

#Data for the histogram
all_data = []
for i in range(len(heat_map)):
    all_data += heat_map[i]

dpi = 400
temps = heat_map
mn,mx = min_max(heat_map)
print(mn, mx)
print "Length of heatmap: ", len(heat_map)


print "Creating Average temperature/frame plot"

plt.clf()
matplotlib.rc('xtick', labelsize=20) 
matplotlib.rc('ytick', labelsize=20)
avg_temp = []
for l in temps:
    s = 0
    for n in l:
        s+=n
    avg_temp.append(s/64.0)
t = np.arange(1,len(temps)+1,1)
print(len(avg_temp))
plt.plot(t, avg_temp, 'k', t, avg_temp, 'bo', markersize=10)
plt.title("Average temperature per frame")
saver1 = filename + "_mean" + ".jpg"
plt.savefig(saver1)

'''
print "Creating Histogram"

plt.clf()
n, bins, patches = plt.hist(all_data, bins=10, range=None, normed=False, weights=None, cumulative=False, bottom=None, histtype='bar', align='mid', orientation='vertical', rwidth=1)
print bins
print patches
#plt.xlabel('Smarts')
#plt.ylabel('Probability')
plt.title("Frequency of temperatures in heat array")
#plt.axis([40, 160, 0, 0.03])
plt.grid(True)
saver3 = filename + "_histo" + ".jpg"
plt.savefig(saver3)

plt.clf()
'''

saver = filename + "_video" + ".mp4"

i = 0

def ani_frame():
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)
    im = ax.imshow(get_temp(heat_map[0],22,30, scale = "grey"), interpolation = "nearest")

    def update_img(n):
        global i
        i = i+1
        if (i%50==0):
            print(i)
        im.set_data(get_temp(heat_map[i],22,30, scale = "grey"))
        return im

    ani = animation.FuncAnimation(fig,update_img,len(temps)-2,interval=30)
    mappable = plt.cm.ScalarMappable(cmap='gray')
    mappable.set_array([22,30])   
    cbar = fig.colorbar(mappable, shrink=0.5, spacing='proportional')
    cbar.ax.tick_params(labelsize=10) 
    writer = animation.writers['ffmpeg'](fps=5)
    ani.save(saver,writer=writer,dpi=dpi)
    return ani
ani_frame()

