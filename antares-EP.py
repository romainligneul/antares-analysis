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

EPcolumns=[
    'time_elapsed',
    'current_rule',
    'currentState',
    'nextState',
    'nextHigh',
    'tnum',
    'stateAccuracy',
    'noisyTransition',
    'valueControl',
    'finalAction',
    'reward',
    'stateX',
    'stateY',
    'startTime',
    'stateTime',
    'endTime',
]

# loop over files
f=0
for datafile in datafiles:

    strIndices=[]
    for match in re.finditer('_', datafile):
        strIndices.append(match.start())
    
    #print(datapath+datafile)
    subject = datafile[2:strIndices[0]]

    #print((datafile[strIndices[1]+1:strIndices[1]+2]))
    visit =  datafile[strIndices[1]+1:strIndices[1]+2]

    experiment=datafile[strIndices[0]+1:strIndices[1]]
    if experiment!='EPHEX':
        continue

    print(datafile)

    # preprocess the files
    if (datafile[len(datafile)-3:len(datafile)]=='csv') | (datafile[len(datafile)-3:len(datafile)]=='txt'):
        if datafile[strIndices[3]+1:strIndices[4]]=='mousedata':
            mousedata = pd.read_csv(datapath+datafile)
            mousedata.to_csv(datapath+ subject + '_' + visit + '_EPmouse.csv')
            del mousedata
        else:
            #maindata = pd.read_csv(datapath+datafile)
            maindata = pd.read_csv(datapath+datafile) #, engine="pyarrow")
            maindata=maindata[EPcolumns]
            maindata.to_csv(datapath+ subject + '_' + visit + '_EPmain.csv')
            del maindata        
    else:
        with open(datapath+datafile, 'r') as file2open:
            data = json.load(file2open)
            maindata=pd.DataFrame(data[0:len(data)-2])
            try:
                mouseraw=pd.read_json(data[len(data)-1])
                mousedata=[]
                for i, row in mouseraw.iterrows():
                    mousedata.append(row['mousedata'])
                mousedata=pd.DataFrame(mousedata)
                mousedata.columns=['time','x', 'y', 'circleIn', 'polyIn', 'limit']
                mousedata.to_csv(datapath+ subject + '_' + visit + '_EPmouse.csv')
            except:
                print(datafile + ': mouse data impossible to read')
            #df = pd.read_json(datapath+datafile)
            file2open.close()
        maindata=maindata[EPcolumns]
        maindata.to_csv(datapath+ subject + '_' + visit + '_EPmain.csv')


