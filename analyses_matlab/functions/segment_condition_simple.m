function [seg] = segment_condition(y,ind,twindow, fs)

%SEGMENT_CONDITION
%
twindow=round(twindow*fs);

seg=nan(length(ind),twindow(2)-twindow(1));
tcenter=abs(twindow(1));

for i=1:length(ind)
    
    %%% fill blindly
    %
    tback=-1;
    while tback>twindow(1) && ind(i)+tback>1
        seg(i,tcenter+tback)=y(ind(i)+tback);
        tback=tback-1;
    end
    %
    tfront=0;
    while tfront<=twindow(2) && ind(i)+tfront<length(y)
        seg(i,tcenter+tfront)=y(ind(i)+tfront);
        tfront=tfront+1;
    end
    
end
    