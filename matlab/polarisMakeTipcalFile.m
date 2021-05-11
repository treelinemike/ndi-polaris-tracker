% restart
close all; clear all; clc;

fileIn  = './data/medtronic_data_1_tipcal_2.csv';
fileOut = 'medtronic_fromdata_2.tip_do_not_use';

[xOpt,rmse,sse] = ndi_optical_probe_tip_cal_numerical(fileIn,0,1);

fidOut = fopen(fileOut,'w');
fprintf(fidOut,'%f,%f,%f\n',xOpt);
fclose(fidOut);
