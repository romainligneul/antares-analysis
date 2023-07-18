# %%
import pandas as pd
import json
import os
import scipy.io as sio
import csv
import numpy as np
import re

# %%
# input data
datapath='rawdata/'
datafiles=os.listdir(datapath) 

# %%

exportfolder='cleandata'
try:
    os.mkdir(exportfolder)
except:
    print('folder exists already')

# loop over files
f=0
for datafile in datafiles:

    strIndices=[]
    for match in re.finditer('_', datafile):
        strIndices.append(match.start())
    
    #print(datapath+datafile)
    subject = int(datafile[2:strIndices[0]])

    #print((datafile[strIndices[1]+1:strIndices[1]+2]))
    visit =  int(datafile[strIndices[1]+1:strIndices[1]+2])

    experiment=datafile[strIndices[0]+1:strIndices[1]]
    if experiment!='EPHEX':
        continue

    print(datafile)

    # preprocess the files
    if (datafile[len(datafile)-3:len(datafile)]=='csv') | (datafile[len(datafile)-3:len(datafile)]=='txt'):
        print('skip')
        #df = pd.read_csv(datapath+datafile)
    else:
        with open(datapath+datafile, 'r') as file2open:
            data = json.load(file2open)
            maindata=data[0:len(data)-2]
            try:
                mouseraw=pd.read_json(data[len(data)-1])
                mousedata=[]
                for i, row in mouseraw.iterrows():
                    mousedata.append(row['mousedata'])
                mousedata=pd.DataFrame(mousedata)
                mousedata.columns=['time','x', 'y', 'circleIn', 'polyIn', 'limit']
            except:
                print(datafile + ': mouse data impossible to read')
            #df = pd.read_json(datapath+datafile)
            file2open.close()
    f=f+1
    if f>1000:
        break

# %%
datafile = 'pP015_EPHEX_2_1_maindata_Tue Apr 18 2023 11_21_36 GMT+0200 (heure dΓÇÖe╠üte╠ü dΓÇÖEurope centrale).json'
with open(datapath+datafile, 'r') as file2open:
        data = json.load(file2open)
        maindata=data[0:len(data)-2]
        try:
            mouseraw=pd.read_json(data[len(data)-1])
            mousedata=[]
            for i, row in mouseraw.iterrows():
                mousedata.append(row['mousedata'])
            mousedata=pd.DataFrame(mousedata)
            mousedata.columns=['time','x', 'y', 'circleIn', 'polyIn', 'limit']
        except:
            print(datafile + ': mouse data impossible to read')
        #df = pd.read_json(datapath+datafile)
        file2open.close()


