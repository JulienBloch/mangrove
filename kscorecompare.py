import csv
import glob, os
import numpy as np
import matplotlib.pyplot as plt
import itertools

os.chdir("/Users/julien/Desktop/E4E/auto/models")

ds = []
ws = []
# ks = []
ks = np.zeros([8, 8])

for file in glob.glob("*.csv"):
	# Kappa = (observed accuracy - expected accuracy)/(1 - expected accuracy)
		
	x = np.loadtxt(open(file, "rb"), delimiter=",", skiprows=2)
	print(x)
	OA = np.trace(x) / np.sum(x)
	sum_col = np.sum(x, axis=0)
	sum_row = np.sum(x, axis=1)
	EA = 0
	for i in range(len(sum_col)):
		EA += sum_col[i] * sum_row[i]
	EA /= (np.sum(x)**2)
	Kappa = (OA - EA) / (1 - EA)
	xx, w, d, yy = file.split("_")
	w = int(w[1:])
	d = int(d[1:])
	ws.append(w)
	ds.append(d)
	# ks.append(Kappa)
	print(w/50)
	print(d)
	ks[7-(w//50 - 1)][(d//2 - 1)] = Kappa

	print(OA)
	print(EA)
	print(Kappa)

ws=np.unique(ws)
ds=np.unique(ds)
X,Y = np.meshgrid(ds, ws)
ws=np.flip(ws, 0)

Z=np.asarray(ks).reshape(len(ws),len(ds))

plt.imshow(Z, interpolation='nearest')

#tick_marks = ["Not", "Black", "White", "Red", "Dead"]
#tick_marks = np.arange(num_classes)
plt.xticks(range(len(ds)), ds)
plt.yticks(range(len(ws)), ws)

#thresh = Z.max() / 2.
#for i, j in itertools.product(range(Z.shape[0]), range(Z.shape[1])):
#    plt.text(j, i, Z[i, j], size="x-small", horizontalalignment="center", color = ("white" if Z[i, j] > thresh else "black"))

#plt.pcolormesh(X,Y,Z)
plt.colorbar()
plt.xlabel("Tree Depth")
plt.ylabel("Tree Width")
plt.title("Kappa Coefficient of GBT")
plt.savefig("/Users/julien/Desktop/E4E/auto/oldkappa.png", dpi=1000)
plt.show()