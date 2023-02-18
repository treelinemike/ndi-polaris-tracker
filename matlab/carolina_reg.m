% restart
close all; clear all; clc;

% options
num_points = 4;
polaris_filename = '20220530_carolina_reg_001.csv';

% define registration points in output frame
reg_pts_output_frame = [ 133.98 0 0; 0 -133.98 0; -133.98 0 0; 0 133.98 0]';

% load registration points from polaris
reg_pts_polaris_frame = nan(size(reg_pts_output_frame));
tab = readtable(polaris_filename,'Delimiter',',');
for point_idx = 1:num_points
    point_mask = (tab.capture_note == point_idx);
    if(nnz(point_mask) ~= 1)
        error('Cannot find a unique capture note for point #%d',point_idx);
    end
    this_row = tab(point_mask,:);
    reg_pts_polaris_frame(:,point_idx) = [this_row.tx_tip this_row.ty_tip this_row.tz_tip]';
end

% compute transform, report RMSE, and save transforme for future use
[~,TF_polaris_to_robot,RMSE] = rigid_align_svd(reg_pts_polaris_frame,reg_pts_output_frame);
fprintf('Fit RMSE = %0.2fmm\n',RMSE);
save("TF_polaris_to_robot.mat","TF_polaris_to_robot");