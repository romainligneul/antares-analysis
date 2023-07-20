clear all
close all
addpath(genpath('functions'))
datafolder='../cleandata_EP/';

filelist=dir([datafolder '*main.csv']);
filelist={filelist.name}'
filelist(strmatch('.', filelist))=[];

additionalanalyses=true;
trialwindow=[-30:30];
f=0;
Uturn=[1 -2];
antiUturn=[2 -1];

centers=[
    [960,224];...
    [1286,787];...
    [635,787]
    ];

for ff=1:length(filelist)
    
    sdata=readtable([datafolder filelist{ff}]);
    
    if str2num(filelist{ff}(5))<0 || size(sdata,1)<100
        continue
    else
        f=f+1;
    end
    
    %sdata(sdata.tnum<100,:)=[];
    
    subject(f,1)= str2num(filelist{ff}(1:3));
    visit(f,1)= str2num(filelist{ff}(5));
    
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
    
    % state analysis
    dist2state=[];
    for st=1:3
        dist2state(:,st)=hypot(sdata.stateX-centers(st,1),sdata.stateY-centers(st,2));
    end
    predstate=nan;
    turns=nan;
    turn=nan;
    stateAcc=nan;
    for t=2:size(sdata,1)
        predstate(t,1)=find(dist2state(t,:)==min(dist2state(t,:)))-1;
        turn(t,1)=predstate(t,1)-sdata.currentState(t,1);
        if sdata.current_rule(t)==0
            stateAcc(t,1)=double(ismember(turn(t,1),Uturn));
        else
            if sdata.finalAction(t)==0
                stateAcc(t,1)=double(ismember(turn(t,1),Uturn));
            else
                stateAcc(t,1)=double(ismember(turn(t,1),antiUturn));
            end
        end
    end
    
    
    % turns
    turns=double(ismember(predstate-sdata.currentState,Uturn));
    turns(1)=NaN;
    
    
    stateAccuracy(f,1)=mean(sdata.stateAccuracy);
    
    %
    gstats=grpstats(sdata.stateAccuracy,sdata.current_rule, {'mean'});
    stateAccuracy_bycontrol(f,:)=gstats;
    %
    gstats=grpstats(sdata.finalAction,sdata.current_rule, {'mean'});
    sideChoice_bycontrol(f,:)=gstats;
    %
    gstats=grpstats(turns,sdata.current_rule, {'mean'});
    turns_bycontrol(f,:)=gstats;    
    
    % reversal analyses
    % accuracy
    reversal_indices=[1; find([0;diff(sdata.current_rule)]~=0); size(sdata.current_rule,1)];
    [segmented,mean_revACC(f,:)]=reversal_analysis(stateAcc,reversal_indices, trialwindow);
    reversal_indices=reversal_indices(2:end-1);
    mean_revACC_UtoC(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==0,:));
    mean_revACC_CtoU(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==1,:));
    % reward
    reversal_indices=[1; find([0;diff(sdata.current_rule)]~=0); size(sdata.current_rule,1)];
    [segmented,mean_revREW(f,:)]=reversal_analysis(sdata.reward,reversal_indices, trialwindow);
    reversal_indices=reversal_indices(2:end-1);
    mean_revREW_UtoC(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==0,:));
    mean_revREW_CtoU(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==1,:));
    % choice side
    reversal_indices=[1; find([0;diff(sdata.current_rule)]~=0); size(sdata.current_rule,1)];
    [segmented,mean_revSIDE(f,:)]=reversal_analysis(sdata.finalAction,reversal_indices, trialwindow);
    reversal_indices=reversal_indices(2:end-1);
    mean_revSIDE_UtoC(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==0,:));
    mean_revSIDE_CtoU(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==1,:));
    
    % reward
    reversal_indices=[1; find([0;diff(sdata.current_rule)]~=0); size(sdata.current_rule,1)];
    [segmented,mean_revTURN(f,:)]=reversal_analysis(turns,reversal_indices, trialwindow);
    reversal_indices=reversal_indices(2:end-1);
    mean_revTURN_UtoC(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==0,:));
    mean_revTURN_CtoU(f,:)=nanmean(segmented(sdata.current_rule(reversal_indices-1)==1,:));
    
    %mean(sdata.stateAccuracy);
    
    
end

%% reversal figures
y=[mean_revACC mean_revACC_UtoC mean_revACC_CtoU];
x=repmat(trialwindow,size(y,1),3);
color=[repmat({'overall'},size(y,1),length(trialwindow)),repmat({'UtoC'},size(y,1),length(trialwindow)),repmat({'CtoU'},size(y,1),length(trialwindow))];
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem')
g.draw()

y=[mean_revREW mean_revREW_UtoC mean_revREW_CtoU];
x=repmat(trialwindow,size(y,1),3);
color=[repmat({'overall'},size(y,1),length(trialwindow)),repmat({'UtoC'},size(y,1),length(trialwindow)),repmat({'CtoU'},size(y,1),length(trialwindow))];
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem')
g.draw()

y=[mean_revSIDE mean_revSIDE_UtoC mean_revSIDE_CtoU];
x=repmat(trialwindow,size(y,1),3);
color=[repmat({'overall'},size(y,1),length(trialwindow)),repmat({'UtoC'},size(y,1),length(trialwindow)),repmat({'CtoU'},size(y,1),length(trialwindow))];
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem')
g.draw()

y=[mean_revTURN mean_revTURN_UtoC mean_revTURN_CtoU];
x=repmat(trialwindow,size(y,1),3);
color=[repmat({'overall'},size(y,1),length(trialwindow)),repmat({'UtoC'},size(y,1),length(trialwindow)),repmat({'CtoU'},size(y,1),length(trialwindow))];
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem')
g.draw()
%
% figure
% plot(sdata.stateX,1080-(sdata.stateY),'bo')
% xlim([0 1920])
% ylim([0 1080])

%% visit effect
y=[stateAccuracy_bycontrol];
x=repmat(visit,1,2);
color=repmat({'U','C'},size(y,1),1);
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem','geom','bar', 'dodge',0.7,'width',0.7)
g.stat_summary('setylim',true,'type','sem','geom','black_errorbar', 'dodge',0.7,'width',0.7)
g.set_limit_extra(0.2,0)
g.draw()

%% visit effect
y=[sideChoice_bycontrol];
x=repmat(visit,1,2);
color=repmat({'U','C'},size(y,1),1);
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem','geom','bar', 'dodge',0.7,'width',0.7)
g.stat_summary('setylim',true,'type','sem','geom','black_errorbar', 'dodge',0.7,'width',0.7)
g.set_limit_extra(0.2,0)
g.draw()


%% visit effect
y=[turns_bycontrol];
x=repmat(visit,1,2);
color=repmat({'U','C'},size(y,1),1);
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem','geom','bar', 'dodge',0.7,'width',0.7)
g.stat_summary('setylim',true,'type','sem','geom','black_errorbar', 'dodge',0.7,'width',0.7)
g.set_limit_extra(0.2,0)
g.draw()

if additionalanalyses
    y=[maxReward_bycontrol];
x=repmat(visit,1,2);
color=repmat({'U','C'},size(y,1),1);
figure
g=gramm('x',x(:),'y', y(:),'color',color(:))
g.stat_summary('setylim',true,'type','sem','geom','bar', 'dodge',0.7,'width',0.7)
g.stat_summary('setylim',true,'type','sem','geom','black_errorbar', 'dodge',0.7,'width',0.7)
g.set_limit_extra(0.2,0)
g.axe_property('ylim',[0.8 1])
g.draw()
end