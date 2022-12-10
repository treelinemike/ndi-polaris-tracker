% [x_tip,rmse] = pivot_cal_lsq(input_filename,std_dev_threshold,output_filename)
%                x_tip: estimated location of tip in local (marker) frame
%                rmse:  root mean square error of resulting fit
%                input_filename: name of Polaris CSV file
%                std_dev_threshold: (optional) outlier rejection threshold, defaults to 3.0
%                output_filename: (optional) name of file to write result into
%
% analytically pivot calibration with least squares
% following method used in SlicerIGT: 
% - https://github.com/IGSIO/IGSIO/blob/master/IGSIOCalibration/vtkIGSIOPivotCalibrationAlgo.cxx
% - https://github.com/IGSIO/IGSIO/blob/master/IGSIOCommon/igsioMath.cxx
%
% solves Ax = b for x in a least squares sense
% A = [R_marker_to_tracker, -eye(3)]
% x = [tip_vec_in_marker_frame; tip_vec_in_tracker_frame]
% b = [-t_marker_to_tracker]
%
% author: Mike Kokko
% updated: 09-Dec-2022

function [x_tip,rmse] = pivot_cal_lsq(input_filename,varargin)

% determine outlier rejection threshold
% on standard deviation (applied along each coordinate direction)
if( nargin == 1 )
    std_dev_threshold = 3.0;
elseif( nargin <= 3 )
    std_dev_threshold = varargin{1};
else
    error('Too many arguments!');
end

% load table
tab = readtable(input_filename,'Delimiter',',','FileType','text');

% make sure we've only used one tool
if(length(unique(tab.tool_id)) ~= 1)
    error('Input file must contain Polaris data for only one tool');
end

% assemble A matrix and b vector
A = [];
b = [];
for point_idx = 1:size(tab,1)
    tabrow = tab(point_idx,:);
    t = [tabrow.tx tabrow.ty tabrow.tz]';
    q = [tabrow.q0 tabrow.q1 tabrow.q2 tabrow.q3]';
    R = quat2matrix(q);
    A = [A; R -1*eye(3)];
    b = [b; -t];
end

% initial least squares attempt
x = A\b;
% tip_local_lsq_initial = x(1:3);
% tip_global_lsq_initial = x(4:6);
resids = reshape(A*x - b,3,[]);
% rmse_lsq_initial = sqrt(mean(sum(resids .^2,1)));

% now we'll discard any rows that exceed deviation threshold
resid_means = mean(resids,2);  % this should be pretty much zero
resid_stdevs = std(resids,0,2);
resid_devs = abs((resids - resid_means) ./ repmat(resid_stdevs,1,size(resids,2)));
resid_mask = resid_devs>std_dev_threshold;
resid_mask_union = repmat(sum(resid_mask,1) > 0,3,1);
rowmask = ~reshape(resid_mask_union,[],1);
A = A(rowmask,:);
b = b(rowmask);

% try least squares again
x = A\b;
resids = reshape(A*x - b,3,[]);
rmse_lsq_final = sqrt(mean(sum(resids .^2,1)));
tip_local_lsq_final = x(1:3);
% tip_global_lsq_final = x(4:6);

% set return variables
x_tip = tip_local_lsq_final;
rmse = rmse_lsq_final;

% write to file if requested
if( nargin == 3 )
    output_filename = varargin{2}; 
    if(isfile(output_filename))
        warning('File exists! Not overwriting it!');
    else
        fprintf('Writing %s\n',output_filename);
        fid = fopen(output_filename,'w');
        fprintf(fid,'%+0.4f,%+0.4f,%+0.4f',x_tip);
        fclose(fid);
    end
end

end