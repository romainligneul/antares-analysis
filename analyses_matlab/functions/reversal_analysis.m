function [segmented,mean_segmented] = reversal_analysis(inputvec,reversal_indices, trialwindow)
%REVERSAL_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

    reversal_mat=nan(length(reversal_indices)-2,length(trialwindow));
    
    rr=0;
    for r=2:length(reversal_indices)-1
        rr=rr+1;
        rev_point = reversal_indices(r);
        rev_back = max(reversal_indices(r-1)-rev_point,trialwindow(1));
        rev_front = min(reversal_indices(r+1)-rev_point,trialwindow(end));
        fill_ind = find(trialwindow==rev_back):find(trialwindow==rev_front);
        reversal_mat(rr,fill_ind)=inputvec(rev_point+rev_back:rev_point+rev_front);
    end
    
    segmented=reversal_mat;
    mean_segmented=nanmean(reversal_mat);

end

