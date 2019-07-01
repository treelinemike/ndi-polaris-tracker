% checkerboard probe test
%
% Tool A: Calibration Plate (CalPlateB.rom)
% Tool B: Neuro Probe (medtronic_fromdata_2.rom)
%
% Collected tracker data with probe tip touching various "known" points on
% the checkerboard pattern. See if we can produce the correct point
% locations in calibration plate local coordinates.


% restart
close all; clear; clc;

% location of probe tip (from previous calibration
probeTipLoc = [-244.085630,-8.352223,1.026031];
% probeTipLoc = [-243.8105,-9.5671,0.8716];
% probeTipLoc = [-242.4136, -7.3947, 0.7560];
 probeTipLoc = [ -244.6652, -8.8286, 0.9601];

% load data from checkerboard_probe_test.csv
fid = fopen('./data/checkerboard_probe_test_002.csv');
allData = textscan(fid,'%*f %*u %c %f %f %f %f %f %f %f %*f %s','Delimiter',',');
fclose(fid);

toolID = allData{1};
Q = [allData{2:5}];
T = [allData{6:8}];
refLoc = allData{9};

allTipLocsGlobal = [];
allTipLocsLocal = [];

for pointIdx = 1:2:length(toolID)
    
   % determine probe tip locations in the GLOBAL tracker coordinate frame
   q_probe = Q(pointIdx+1,:);
   t_probe = T(pointIdx+1,:);
   quatrotate(q_probe,probeTipLoc);
   tip_loc = t_probe + quatrotate(q_probe,probeTipLoc);
   allTipLocsGlobal(end+1,:) = tip_loc;
   
   % locate origin of calibration plate
   t_plate = T(pointIdx,:);
   tip_loc_rel_global = tip_loc - t_plate;
   
   % rotate the relative tip location vector from global space to local
   % space, this requires the inverse calibration plate quaternion, which
   % can be found by switching the sign of the the imaginary (vector) components 
    q_plate = Q(pointIdx,:);
    tip_loc_rel_local = quatrotate(q_plate*diag([1 -1 -1 -1]),tip_loc_rel_global);
    allTipLocsLocal(end+1,:) = tip_loc_rel_local;
end

% %%
% A = allTipLocsGlobal - mean(allTipLocsGlobal)
% [vec,val] = eig(A'*A)
% % rearrange eigenvectors in order of decreasing eigenvalues
% % so x axis has the largest variation, and z axis has the least
% [valSort, valSortIdx] = sort(diag(val),'descend');
% vecSort = vec(:,valSortIdx);
% newData = A*vecSort
% newData = newData - newData(1,:)

% perform quaternion rotation
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

