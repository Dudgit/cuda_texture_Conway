import pandas as  pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

handler = np.loadtxt('data/Conway.csv')

def save_anim(h,num):
    mD = np.array([h[i*100 : (i+1)*100]for i in range(int(len(h)/100)-1)])
    fig = plt.figure(figsize=(10,10))
    plt.title("Conway", fontsize = 20)
    im = plt.imshow(mD[0])
    plt.show()

    def animate(i):
        im.set_array(mD[i])
        return [im]

    anim = animation.FuncAnimation(fig,animate,frames = 10 ,interval = 10000 ) # in ms)
    anim.save("Cw_game_"+str(num)+ ".mp4")
    
    save_anim(handler,1)