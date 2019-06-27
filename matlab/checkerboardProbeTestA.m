% checkerboard probe test
% Tool A: Calibration Plate (CalPlateB.rom)
% Tool B: Neuro Probe (medtronic_fromdata_2.rom)

% restart
close all; clear; clc;

% location of probe tip (from previous calibration
probeTipLoc = [-244.085630,-8.352223,1.026031];

% load data from checkerboard_probe_test.csv
fid = fopen('checkerboard_probe_test.csv');
allData = textscan(fid,'%*f %*u %c %f %f %f %f %f %f %f %*f %s','Delimiter',',');
fclose(fid);

toolID = allData{1};
Q = [allData{2:5}];
T = [allData{6:8}];
refLoc = allData{9};

allTipLocsGlobal = [];

for pointIdx = 1:2:length(toolID)
   q_probe = Q(pointIdx+1,:);
   t_probe = T(pointIdx+1,:);
   quatrotate(q_probe,probeTipLoc);
   tip_loc = t_probe + quatrotate(q_probe,probeTipLoc);
   allTipLocsGlobal(end+1,:) = tip_loc;
   
end

%%
A = allTipLocsGlobal - mean(allTipLocsGlobal)
[vec,val] = eig(A'*A)
% rearrange eigenvectors in order of decreasing eigenvalues
% so x axis has the largest variation, and z axis has the least
[valSort, valSortIdx] = sort(diag(val),'descend');
vecSort = vec(:,valSortIdx);
newData = A*vecSort
newData = newData - newData(1,:)

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

