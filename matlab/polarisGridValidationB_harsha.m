% restart
close all; clear all; clc;

% specify data file and tip calibration file (just x,y,z locations of tip
% in local coordinate system)
validationDataFile = 'C:\Users\f002r5k\GitHub\ndi-polaris-tracker\matlab\harsha_drill_calpattern_001.csv';
tipCalFile = 'C:\Users\f002r5k\GitHub\ndi-polaris-tracker\tool-defs\harsha_drill_003.tip';

% configure true/target grid
[x y z] = meshgrid(0:8,0:6,0);      % mesh grid in inches
truePts  = [x(:) y(:) z(:)]*25.4;   % grid points in mm
truePtCloud = pointCloud(truePts);  % convert to point cloud type

% get x,y,z location of probe tip in local coordinate system
fidTipCal = fopen(tipCalFile,'r');
xTip = cell2mat(textscan(fidTipCal,'%f,%f,%f'))';
fclose(fidTipCal);

% get tracking data from Polaris
fidData = fopen(validationDataFile,'r');
allData = cell2mat(textscan(fidTipCal,'%*f %*f %*c %f %f %f %f %f %f %f %*f %*s','Delimiter',',','CollectOutput',1));
fclose(fidData);

% convert 7D tracking data (quaternition & position) into 3D tip points
measData = zeros(length(allData),3);
for pointIdx = 1:size(allData,1)
   q = allData(pointIdx,1:4)';
   x = allData(pointIdx,5:7)';
   measData(pointIdx,:) = (x+quatrotate(q,xTip))';
end
measPtCloud = pointCloud(measData);

% use ICP to align point clouds, reporting RMSE
[tform,firstReg,rmse] = pcregistericp(measPtCloud,truePtCloud);%,'InitialTransform',affine3d([0 1 0 0; -1 0 0 0; 0 0 1 0; 0 0 0 1]));
% [tform,movingReg,rmse] = pcregistericp(measPtCloud,truePtCloud,'InitialTransform',affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; -measData(1,1) -measData(1,2) -measData(1,3) 1]));
[tform,secondReg,rmse] = pcregistericp(firstReg,truePtCloud,'InitialTransform',affine3d([0 -1 0 0; 1 0 0 0; 0 0 1 0; -firstReg.Location(1,1) -firstReg.Location(1,2) -firstReg.Location(1,3) 1]));
[tform,finalReg,rmse] = pcregistericp(secondReg,truePtCloud,'InitialTransform',affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; -secondReg.Location(1,1) -secondReg.Location(1,2) -secondReg.Location(1,3) 1]));
rmse





% plot results
figure;
hold on; grid on;
plot3(truePts(:,1),truePts(:,2),truePts(:,3),'b.','MarkerSize',25)
plot3(finalReg.Location(:,1),finalReg.Location(:,2),finalReg.Location(:,3),'r+','MarkerSize',10,'LineWidth',2);

axis equal;
xlabel('\bfx [mm]');
ylabel('\bfy [mm]');
zlabel('\bfz [mm]');
title(['\bf' sprintf('RMSE = %0.2f mm',rmse)]);

% function to perform quaternion rotation
% essentially using angle (theta) and axis (u, a unit vector) of rotation
% q =     q0     +     q123
% q = cos(theta) + sin(theta)*u
% note: MATLAB includes a similar function in the aerospace toolbox, but
% this is not part of the Dartmouth site license
function v_out = quatrotate(q_in,v_in)

% extract scalar and vector parts of quaternion
q0   = q_in(1);   % real (scalar) part of quaternion
q123 = q_in(2:4); % imaginary (vector) part of quaternion

% rotate v_in using point rotation: v_out = q * v_in * conj(q)
% q_out = quatmult(q_in,quatmult([0; v_in],quatconj(q_in)))
% v_out = q_out(2:4)
% Simplification from Kuipers2002: Quaternions and Rotation Sequences: A Primer with Applications to Orbits, Aerospace and Virtual Reality
v_out = (q0^2-norm(q123)^2)*v_in + 2*dot(q123,v_in)*q123 + 2*q0*cross(q123,v_in);

end