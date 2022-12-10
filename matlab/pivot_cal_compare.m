% restart
close all; clear; clc;

% options
cal_data_filename = '20221208_chx_tipcal_001.csv';

% first, run numerical pivot calibration
tic;
[tip_local_numerical,rmse_numerical] = ndi_optical_probe_tip_cal_numerical(cal_data_filename);
dt_numerical = toc;

% now do it analytically with least squares, following method in SlicerIGT 
% https://github.com/IGSIO/IGSIO/blob/master/IGSIOCalibration/vtkIGSIOPivotCalibrationAlgo.cxx
% https://github.com/IGSIO/IGSIO/blob/master/IGSIOCommon/igsioMath.cxx
% Solve Ax = b
% A = [R_marker_to_tracker, -eye(3)]
% x = [tip_vec_in_marker_frame; tip_vec_in_tracker_frame]
% b = [-t_marker_to_tracker]
tic

% load table
tab = readtable(cal_data_filename,'Delimiter',',');

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
tip_local_lsq_initial = x(1:3);
tip_global_lsq_initial = x(4:6);
resids = reshape(A*x - b,3,[]);
rmse_lsq_initial = sqrt(mean(sum(resids .^2,1)));

% now we'll discard any rows that exceed deviation threshold
std_dev_threshold = 1;
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
tip_global_lsq_final = x(4:6);
dt_lsq = toc;

fprintf('Numerical: %0.3f sec, LSQ: %0.3f sec\n',dt_numerical,dt_lsq);
fprintf('Discarded %d points from least squares problem\n',nnz(~rowmask)/3);

tip_vecs = [tip_local_numerical tip_local_lsq_initial tip_local_lsq_final]
rmse = [rmse_numerical rmse_lsq_initial rmse_lsq_final]

[x_tip,rmse] = pivot_cal_lsq(cal_data_filename,20,'test.tip')