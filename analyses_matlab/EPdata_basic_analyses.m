clear all
close all

datafolder='../cleandata_EP/';

filelist=dir([datafolder '*main.csv']);
filelist={filelist.name}'
filelist(strmatch('.', filelist))=[];

additionalanalyses=false;

for f=1:length(filelist)

    sdata=readtable([datafolder filelist{f}]);

    if additionalanalyses
        maxreward=nan(size(sdata,1),1);
        for t=1:size(sdata,1)
            dum=eval(sdata.reward_values{t});
            if dum(1)~=dum(2)
                maxreward(t,1)=max(dum);
            end
        end
        maxReward_bycontrol(f,:)=grpstats(maxreward(~isnan(maxreward))==sdata.reward(~isnan(maxreward)),sdata.current_rule(~isnan(maxreward)), {'mean'});
    end

    stateAccuracy(f,1)=mean(sdata.stateAccuracy);

    gstats=grpstats(sdata.stateAccuracy,sdata.current_rule, {'mean'});

    stateAccuracy_bycontrol(f,:)=gstats;

    
    % reversal analysis
    
    %mean(sdata.stateAccuracy);


end