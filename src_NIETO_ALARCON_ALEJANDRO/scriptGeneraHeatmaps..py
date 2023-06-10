import numpy as np
import matplotlib
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns

relative_path = ".\\src\\tracks\\singlePlayer\\evaluacion\\src_NIETO_ALARCON_ALEJANDRO\\"
#relative_path = "./src/tracks/singlePlayer/evaluacion/src_NIETO_ALARCON_ALEJANDRO/"

filenames = [relative_path +"HeuristicasLRTA.txt",
 relative_path + "HeuristicasRTA.txt",
 relative_path + "HeuristicasA.txt"]

for filename in filenames:
    name = filename[76:-4]

    fin = open(filename,'r')
    a=[]
    num_rows = 0
    for line in fin.readlines():
        a.append( [ float (x) for x in line.split(' ')[:-1] ] )
        num_rows = num_rows + 1

    data = np.array(a)

    b = []
    for row in a:
        row2 = []
        for num in row:
            if num >= 0.0:
                row2.append(False)
            else :
                row2.append(True)
        b.append(row2)
            
    mask = np.array(b)

    fig, ax = plt.subplots()
    ax = sns.heatmap(data, mask=mask, cmap="crest")
    ax.set_title("Camino optimo h(n) " + name)
    fig.tight_layout()
    plt.savefig(relative_path + name + "Heatmap.png")