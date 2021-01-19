import pandas as  pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

handler = np.loadtxt('data/Conway.csv')
my_data = np.array([handler[i:i+100]for i in range(int(len(handler)/100)-1)])

fig = plt.figure(figsize=(10,10))
im = plt.imshow(my_data[0],cmap='cividis')
plt.show()

def animate(i):
    im.set_array(my_data[i])
    return [im]

anim = animation.FuncAnimation(fig,animate,frames = 1000 ,interval = 20) 
anim.save("t_anim.mp4")
