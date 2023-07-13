# %%
import pandas as pd
import json
import os
import scipy.io as sio
import csv
import numpy as np


# %%
# input data
datapath='STROOPrawdata/'
datafiles=os.listdir(datapath) 
exportfolder='STROOPcleandata'
try:
    os.mkdir(exportfolder)
except:
    print('folder exists already')

# initialize variables
bigtrain=pd.DataFrame()
bigmain=pd.DataFrame()
interference=[]

# simple parameter for STROOP analysis
prematureRT_cutoff=200 # must 0 or above (misses are coded as -1 in the rt column)
na_rep='' # representation of missing data in the output csvs

# loop over files
for datafile in datafiles:

    subject = int(datafile[2:5])
    visit = int(datafile[13:14])

    # preprocess the files
    if datafile[len(datafile)-3:len(datafile)]=='csv':
        df = pd.read_csv(datapath+datafile)
    else:
        df = pd.read_json(datapath+datafile)

    fdf = df.filter(items=['trial_tag', 'trial_index', 'tnum', 'fixdur', 'string', 'color', 'congruent', 'rt', 'correct'])
    fdf['subject'] = subject
    fdf['visit'] = visit

    # slice
    train=fdf[fdf['trial_tag']=='STROOPtrain']
    main=fdf[fdf['trial_tag']=='STROOPmain']
    main=main.drop('trial_tag', axis=1)
    train=train.drop('trial_tag', axis=1)

    # concatenate in big matrices for subsequent analyses
    bigmain=pd.concat([bigmain,main],axis=0)
    bigtrain=pd.concat([bigtrain,train],axis=0)

    # basic interference RT
    meanRT = main[main["rt"]>prematureRT_cutoff].groupby('congruent', as_index=False).rt.mean()
    try:
        rawInterference=meanRT.values[0][1]-meanRT.values[1][1]
        normInterference=(meanRT.values[0][1]-meanRT.values[1][1])/meanRT.values[1][1]
    except:
        rawInterference=float('nan')
        normInterference=float('nan')
    
    # interference RT in correct trials only
    meanRT = main[(main["rt"]>prematureRT_cutoff) & (main["correct"]==1)].groupby('congruent', as_index=False).rt.mean()
    try:
        correctrawInterference=meanRT.values[0][1]-meanRT.values[1][1]
        correctnormInterference=(meanRT.values[0][1]-meanRT.values[1][1])/meanRT.values[1][1]
    except:
        correctrawInterference=float('nan')
        correctnormInterference=float('nan')

    # interference RT in correct trials only
    meanACC = main[(main["correct"]>-1)].groupby('congruent', as_index=False).correct.mean()
    try:
        accInterference=meanACC.values[0][1]-meanACC.values[1][1]
        accnormInterference=(meanACC.values[0][1]-meanACC.values[1][1])/meanACC.values[1][1]
    except:
        accrawInterference=float('nan')
        accnormInterference=float('nan')

    meanRT=main[main["rt"]>0].rt.mean()
    meanACC=float(pd.DataFrame(main["correct"]==1).mean())
    meanMISSES=float(pd.DataFrame(main["correct"]==-1).mean())

    interference.append([subject,visit, rawInterference, normInterference, correctrawInterference, correctnormInterference,accInterference, accnormInterference, meanACC, meanRT, meanMISSES])


outmat={}
outmat['main']=bigmain.to_numpy()
outmat['train']=bigtrain.to_numpy()

# save big matrices to csv and matlab format
sio.savemat(exportfolder+'/STROOPdata.mat',outmat)
bigmain.to_csv(exportfolder+'/STROOPdata_main.csv', index=False, header=True, na_rep=na_rep)
bigmain.to_csv(exportfolder+'/STROOPdata_train.csv', index=False, header=True, na_rep=na_rep)



# %%
# field names
fields = ['subject', 'visit', 'rawIntRT', 'normIntRT', 'rawIntRTcor', 'normIntRTcor', 'rawIntACC', 'normIntACC', 'ACC', 'RT', 'Misses']
 
df = pd.DataFrame(interference)
df.to_csv(exportfolder+'/STROOPsummarystatistics.csv', header=fields, index=False, na_rep=na_rep)


#np.savetxt('STROOPsummarystatistics.csv',interference, delimiter=',')


