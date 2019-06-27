% restart
close all; clear all; clc;

% options
romFileName = 'CalPlateB.rom';
mfgrString = 'Thayer';
partNumString = 'Calibration Plate';

% marker locations from CAD file
mkrz = (0.345-0.025-0.002-0.008)*25.4; % (post bottom to center) - (cbore depth) - (467MP adhesive thickness) - (paper thickness)
marker_cad_locs = [16.5 16.5 mkrz; -21 16.5 mkrz; -58.5 16.5 mkrz; 25 -76.5 mkrz; -42 -76.5 mkrz];
marker_nom_locs = marker_cad_locs*[0 -1 0; 1 0 0; 0 0 1]*[-1 0 0; 0 1 0; 0 0 -1] - [6 6 0]; % could do this in one homogeneous transformation but this seems pretty clear

plot3(marker_cad_locs(:,1),marker_cad_locs(:,2),marker_cad_locs(:,3),'r.','MarkerSize',20); grid on; hold on; axis equal;
plot3(marker_nom_locs(:,1),marker_nom_locs(:,2),marker_nom_locs(:,3),'b.','MarkerSize',20); grid on; hold on; axis equal;
xlabel('\bfx');
ylabel('\bfy');
view([0,90]);
%%
% compile information for tool definition ROM file
% tool definition file contents
romOptions.subType  = hex2dec('01');    % Subtype: 0x00 = Removable tip; 0x01= Fixed Tip; 0x02 = Undefined
romOptions.toolType = hex2dec('02');    % Tool type: 0x01 = Ref; 0x02 = Probe; 0x03 = Switch; 0x0C = GPIO, etc…
romOptions.toolRev  = 0;              % 0 - 999
romOptions.seqNum   = 0;   % 0 - 1023
romOptions.maxAngle = 90;    % [deg] (integer)
romOptions.numMarkers = size(marker_nom_locs,1);
romOptions.minMarkers = 3;
romOptions.max3DError = 0.500;  % [mm]
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
romOptions.markerLocs(1:size(marker_nom_locs,1),1:size(marker_nom_locs,2)) = marker_nom_locs;

% default normal to the face (and all markers on it)
% TODO: make this work with more than one face...
defaultNormal = [0 0 -1];
defaultNormal = defaultNormal/norm(defaultNormal);
romOptions.markerNormals = zeros(20,3);
romOptions.markerNormals(1,:) = defaultNormal;
romOptions.markerNormals(2,:) = defaultNormal;
romOptions.markerNormals(3,:) = defaultNormal;
romOptions.markerNormals(4,:) = defaultNormal;
romOptions.markerNormals(5,:) = defaultNormal;
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
writeToolDefROMFile(romFileName,romOptions);