% display all tracker data from a file

% restart
close all; clear; clc;

% data file to load
% dataFile = '20210427_lucas_001.csv'
% dataFile = '20210427_lucas_scope.csv'
dataFile = '20210427_lucas_kidney_01.csv'
% dataFile = '20210427_lucas_kidney_02.csv'
% dataFile = '20210427_lucas_fpga.csv'

% tip calibration dictionary
tipLocs = {'A',[-304.6811,0.3919, 0.0873]};

% define colors
colors = [
    0.7 0.0 0.0; ...
    1.0 0.7 0.0; ...
    0.7 0.7 0.0; ...
    0.0 0.7 0.0; ...
    0.0 0.0 0.7; ...
    0.7 0.0 1.0 ];

% counters and data storage
trackIdx = 0;
legPlots = [];
legStrings = {};

% load data
fid = fopen(dataFile);
allData = textscan(fid,'%f %u %c %f %f %f %f %f %f %f %*f %s','Delimiter',',');
fclose(fid);time = allData{1};
toolID = allData{3};
Q = [allData{4:7}];
T = [allData{8:10}];
trackLabels = allData{11};

% create list of tracked tools
allTools = unique(toolID);
numTools = length(allTools);

% start figure;
figure;
hold on; grid on;

% iterate through all tools present
for toolIdx = 1:numTools
    thisTool = allTools(toolIdx);
    thisT = T(toolID == thisTool,:);
    thisQ = Q(toolID == thisTool,:);
    thisTime = time(toolID == thisTool,:);
    thisLabel = trackLabels(toolID == thisTool,:);
    
    % get tip position in local CS
    tipMatchIdx = find(arrayfun(@(x) strcmp(x,thisTool),[tipLocs{:,1}]));
    switch length(tipMatchIdx)
        case 0
            disp('No tip calibration applied.');
            tipPosLocal = [0 0 0]';
        case 1
            tipPosLocal = tipLocs{tipMatchIdx,2}';
        otherwise
            error('Too many matches!');
    end
    

    % subset further by label/comment
    allLabels = unique(thisLabel);
    numLabels = length(allLabels);    
    for labelIdx = 1:numLabels
        
        % extract tracking data for current path
        trackLabel = allLabels{labelIdx};
        trackMatchIdx = find(arrayfun(@(x) strcmp(x,trackLabel), thisLabel));
        trackT = thisT(trackMatchIdx,:);
        trackQ = thisQ(trackMatchIdx,:);
        trackTime = thisTime(trackMatchIdx,:);
        tipPoints = zeros(size(trackT));
        
        % iterate through all points for this marker / label combo
        for ptIdx = 1:size(trackT,1)
            
            % rotate tip position based on observed orientation, then
            % translate to observed marker origin
            tipPoints(ptIdx,:) = trackT(ptIdx,:) + quatrotate(trackQ(ptIdx,:),tipPosLocal');
        end
        
        % plot with correct color and store info for legend
        trackIdx = trackIdx + 1;
        thisColor = colors(mod(trackIdx-1,size(colors,1))+1,:);
        legPlots(end+1) = plot3(tipPoints(:,1),tipPoints(:,2),tipPoints(:,3),'.-','MarkerSize',10,'Color',thisColor);
        legStrings{end+1} = [thisTool ': ' trackLabel];
    end
end

% finalize plot
legend(legPlots,legStrings,'Location','eastoutside');
axis equal;
view([15,15]);

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

% see Kuipers pg 126 (ch. 5: Quaternion Algebra)
function R = quat2matrix(q)

R = [ 2*q(1)^2-1+2*q(2)^2,      2*q(2)*q(3)-2*q(1)*q(4),   2*q(2)*q(4)+2*q(1)*q(3);
    2*q(2)*q(3)+2*q(1)*q(4),  2*q(1)^2-1+2*q(3)^2,       2*q(3)*q(4)-2*q(1)*q(2);
    2*q(2)*q(4)-2*q(1)*q(3),  2*q(3)*q(4)+2*q(1)*q(2),   2*q(1)^2-1+2*q(4)^2       ];

end