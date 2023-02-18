% function discoverCamProbeA(rawDataFile)
close all; clear; clc;
rawDataFile = 'linear_001_tooldef.csv';
% generate rom file name
[mat,tok] = regexp(rawDataFile,'([\w\-]+)\.\w+','match','tokens');
if(isempty(tok))
    error('Improperly formatted data file name!');
end
romFileName = [tok{1}{1} '.rom'];

% general settings
mfgrString = 'Thayer';
partNumString = 'Linear Array';
numICPAngs = 4; % rotate to this many initial positions (for each: as observed, flipped)
minRMSEThreshold = 1.00; % [mm]
romMaxAngle = 90;    % [deg] (integer)
romMinMarkers = 3;
romMax3DError = 0.500;  % [mm]

% generate prior marker arrangement
% marker_nom_locs = [     0.00      0.00   0.00; 
%                          -1.80     -2.40   0.00;
%                           3.20     -2.40   0.00]*25.4;

marker_nom_locs = [   0.0   0.0  0.570;
                        2.00  0.0  0.570;    
                        3.60  0.0  0.570] * 25.4;
marker_nom_pc = pointCloud(marker_nom_locs);

% display nominal marker arrangement
figure(1);
set(gcf,'Position',[0488 5.746000e+02 0225 1.874000e+02]);
hold on; grid on;
plot3(marker_nom_locs(:,1),marker_nom_locs(:,2),marker_nom_locs(:,3),'b.','MarkerSize',20);
axis equal;

% load data
allData = load(rawDataFile);

% data storage
% allRelDist = [];
allRegPts = zeros(size(marker_nom_locs,1),3,size(allData,1));
regPtIdx = 1;

% look at each row (individual observation) separately
for rowIdx = 1:size(allData,1)
    
    % data comes in as (xpos,ypos,zpos) for each marker in a single row
    % (x1,y1,z1,x2,y2,z2,...,xn,yn,zn
    % reshape the current row to be a 3xn matrix
    absLocs = reshape(allData(rowIdx,:),3,[]);

    % subtract off the mean point location
    meanLoc = mean(absLocs,2);
    relLocs = absLocs - meanLoc;
    
    % compute eigenvalues and eigenvectors of the centered covariance matrix
    [vec, val] = eig(relLocs*relLocs');
    
    % rearrange eigenvectors in order of decreasing eigenvalues
    % so x axis has the largest variation, and z axis has the least
    [valSort, valSortIdx] = sort(diag(val),'descend');
    vecSort = vec(:,valSortIdx);
    
    % make sure that eigenvectors are pointing in generally the right
    % directions
    % assumptions:
    %   - array on pointer device is taller than it is wide
    %   - x axis along the eigenvector with the largest eigenvalue, positive generally aligned with the tracker NEGATIVE x axis (points away from tip)
    %   - z axis along the eigenvector with the smallest eigenvalue, positive pointing generally toward tracker head
    if(vecSort(1,1) > 0)
        vecSort = vecSort*diag([-1 1 1]);
    end
    if(vecSort(3,3) < 0)
        vecSort = vecSort*diag([1 1 -1]);
    end
    
    % make sure y axis is consistent (right-handed CS)
    vecSort(:,2) = cross(vecSort(:,3),vecSort(:,1));
    
    % transform data into local CS
    localPts = (vecSort')*relLocs;%(:,relDistSortIdx);
    
    % try ICP from various initial positions
    allICP = {};
    data_pc = pointCloud(localPts');
    allAngs = linspace(0,2*pi,numICPAngs+1);
    allAngs = allAngs(1:numICPAngs);
    for flipState = 0:1
        for angIdx = 1:length(allAngs)
            thisAngle = allAngs(angIdx);
            initialTransform = eye(4);
            if(flipState)
                initialTransform = diag([1 -1 -1 1]);
            end
            initialTransform = [cos(thisAngle) sin(thisAngle) 0 0; -sin(thisAngle) cos(thisAngle) 0 0; 0 0 1 0; 0 0 0 1]*initialTransform; 
            [tform,movingreg,rmse] = pcregistericp(data_pc,marker_nom_pc,'InitialTransform',affine3d(initialTransform));
            allICP{end+1,1} = rmse;
            allICP{end,2} = movingreg;
        end
    end
    [rmse,minIdx] = min([allICP{:,1}]);
    movingreg = allICP{minIdx,2};
    
    % store data if the minimum RMSE is below threshold
    if(rmse < minRMSEThreshold)
        
        % label points consistently
        regPts = allICP{minIdx,2}.Location;
        [az,~,~] = cart2sph(regPts(:,1),regPts(:,2),regPts(:,3));
        [~,sortIdx] = sort(az);
        regPts = regPts(sortIdx,:);
        regPtsIdx = knnsearch(marker_nom_locs,regPts);
        regPts = regPts(regPtsIdx,:);
        
        % store data and increment counter
        allRegPts(:,:,regPtIdx) = regPts;
        regPtIdx = regPtIdx + 1;
    end
end

% remove unused layers from storage array
allRegPts(:,:,regPtIdx:end) = [];

% show all data overlaid in local CS
figure;
hold on; grid on;
for frameIdx = 1:size(allRegPts,3)
    for pointIdx = 1:size(allRegPts,1)
        colors = [1 0 0; 0 1 0; 1 1 0];
        thisColor = colors(pointIdx,:);
        plot3(allRegPts(pointIdx,1,frameIdx),allRegPts(pointIdx,2,frameIdx),allRegPts(pointIdx,3,frameIdx),'.','MarkerSize',15,'Color',thisColor);
    end
end
% compute estimated marker locations relative to centroid
% in local coordinate system
% for now we just average the marker locations over all available data
% but in the future an optimization routine might be more accurate
estimate = mean(allRegPts,3);
plot3(estimate(:,1),estimate(:,2),estimate(:,3),'m.','MarkerSize',30);
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');

figure(1);
plot3(estimate(:,1),estimate(:,2),estimate(:,3),'mx','MarkerSize',10,'LineWidth',2);
legend('Nominal','Estimate');

% compile information for tool definition ROM file
% tool definition file contents
romOptions.subType  = hex2dec('01');    % Subtype: 0x00 = Removable tip; 0x01= Fixed Tip; 0x02 = Undefined
romOptions.toolType = hex2dec('02');    % Tool type: 0x01 = Ref; 0x02 = Probe; 0x03 = Switch; 0x0C = GPIO, etc…
romOptions.toolRev  = 0;              % 0 - 999
romOptions.seqNum   = 0;   % 0 - 1023
romOptions.maxAngle = romMaxAngle;    % [deg] (integer)
romOptions.numMarkers = size(estimate,1);
romOptions.minMarkers = romMinMarkers;
romOptions.max3DError = romMax3DError;  % [mm]
romOptions.minSpread1 = 0;
romOptions.minSpread2 = 0;
romOptions.minSpread3 = 0;
romOptions.numFaces = 1;   % TODO: allow more than one face
romOptions.numGroups = 1;  % TODO: allow more than one group
romOptions.trackLED = 31;  % LEDs: 0x1F = None; 0x00 = A; 0x13 = T; 0x1E = Set in GPIO 
romOptions.led1 = 31;            % 0x1F = 0d31
romOptions.led2 = 31;
romOptions.led3 = 31;
romOptions.gpio1 = 9;  % GPIOs: 0x09 = Input, 0x10 = Output; 0x30 = Always High; 0x11 = Output w/ Feedback; 0x00 = None
romOptions.gpio2 = 0;
romOptions.gpio3 = 0;
romOptions.gpio4 = 0;
romOptions.mfgr = mfgrString;
romOptions.partNum = partNumString;
romOptions.enhAlgFlags = 128;
romOptions.MrkrType = 41; % Marker Type: 0x11 = 880 Active Ceramic; 0x12 = 930; 0x10 = NDI Legacy; 0x29 = Passive Marker, Sphere; 0x31 = Passive Marker, Disk 
               % 0x29 = 0d43
               
% marker locations... TODO: roll into a function where this is provided as input
romOptions.markerLocs = zeros(20,3);
romOptions.markerLocs(1:size(estimate,1),1:size(estimate,2)) = estimate;

% default normal to the face (and all markers on it)
% TODO: make this work with more than one face...
defaultNormal = [0 0 1];
defaultNormal = defaultNormal/norm(defaultNormal);
romOptions.markerNormals = zeros(20,3);
for markerNormalIdx = 1:size(marker_nom_locs,1)
    romOptions.markerNormals(markerNormalIdx,:) = defaultNormal;
end
romOptions.faceNormals = zeros(8,3);
romOptions.faceNormals(1,:) = defaultNormal;

% sequence number byte
romOptions.seqNumByte = bitand(uint16(romOptions.seqNum),hex2dec('FF'));
seqNumPartialByte = double(bitand(swapbytes(uint16(romOptions.seqNum)),hex2dec('FF')));

% encode the date
thisDateVec = datevec(date);
datevar = bitshift((datenum(thisDateVec)-datenum(datetime(thisDateVec(1),1,1))),2);  % day of year
datevar = bitor(datevar,seqNumPartialByte);                    % add two bits of sequence number
datevar = bitor(datevar,bitshift((thisDateVec(2)-1),11));      % month
datevar = bitor(bitshift((thisDateVec(1) - 1900),15),datevar); % year
romOptions.dateBytes = datevar;

% faces and groups
romOptions.faceGrpByte = bitor(uint8(bitshift(romOptions.numFaces,3)),uint8(bitand(romOptions.numGroups,hex2dec('07'))));

% write ROM file
disp(['Writing ' romFileName]);
writeToolDefROMFile(romFileName,romOptions);