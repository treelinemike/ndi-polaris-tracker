% restart
close all; clear all; clc;

colors = {'b','g','b'};

% specify data file and tip calibration file (just x,y,z locations of tip
% in local coordinate system)
dataFiles = {'20200716_initial_test_002.csv'};
% dataFiles = {'cam001.csv','cam002.csv','cam003.csv'};
tipCalFile = [];
% tipCalFile = 'C:\Users\f002r5k\GitHub\ndi-polaris-tracker\tool-defs\medtronic_fromdata_2.tip';

% get x,y,z location of probe tip in local coordinate system
if(isempty(tipCalFile))
    xTip = [0 0 0]';
else
    fidTipCal = fopen(tipCalFile,'r');
    xTip = cell2mat(textscan(fidTipCal,'%f,%f,%f'))';
    fclose(fidTipCal);
end

% data storage
allPoints = [];

% get tracking data from Polaris
for dataFileIdx = 1:length(dataFiles)
    
    % read data from file
    thisDataFile = dataFiles{dataFileIdx};
    fidData = fopen(thisDataFile,'r');
    rawCellData = textscan(fidData,'%f %*f %c %f %f %f %f %f %f %f %*f %*s','Delimiter',',','CollectOutput',1);
    fclose(fidData);
    
    % extract data into arrays
    allData = rawCellData{3};
    toolData = rawCellData{2};
    timeData = rawCellData{1};
    
    % determine which tools were used (alphabetic, 1-char tool IDs)
    toolList = unique(toolData);
    
    % convert 7D tracking data (quaternition & position) into 3D tip points
    measData = zeros(length(allData),3);
    for pointIdx = 1:size(allData,1)
        q = allData(pointIdx,1:4)';
        x = allData(pointIdx,5:7)';
        measData(pointIdx,:) = (x+quatrotate(q,xTip))';
    end
    measPtCloud = pointCloud(measData);
    allPoints = [allPoints; measData];
%     plot3(measData(:,1),measData(:,2),measData(:,3),'.','MarkerSize',5,'color',colors{dataFileIdx})
    figure;
    set(gcf,'Position',[1.626000e+02 8.820000e+01 7.728000e+02 6.744000e+02]);
    hold on; grid on; axis equal;
    for toolIdx = 1:length(toolList)
        thisToolID = toolList(toolIdx);
        toolDataMask = (toolData == thisToolID);
        toolPoints = measData(toolDataMask,:);
        plot3(toolPoints(:,1),toolPoints(:,2),toolPoints(:,3),'.-','LineWidth',0.6,'MarkerSize',5);
    end
    legend(toolList);
    view([-35 15]);
end



% meanPt = mean(allPoints);
% A = allPoints - repmat(meanPt,size(allPoints,1),1);
% [vec,val] = eig(A'*A);
% K=20;
% for i = 1:3
%     plot3(meanPt(1)+[0 K*vec(1,i)], meanPt(2)+[0 K*vec(2,i)], meanPt(3)+[0 K*vec(3,i)],'-','LineWidth',1.6);
% end
% 
% 
% figure;
% AA = (vec'*A')';
% plot3(AA(:,1),AA(:,2),AA(:,3),'.');
% 
% % finailize plot
% axis equal;
% xlabel('\bfx [mm]');
% ylabel('\bfy [mm]');
% zlabel('\bfz [mm]');
% 
% csvwrite('pointCloudData.csv',allPoints);

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


