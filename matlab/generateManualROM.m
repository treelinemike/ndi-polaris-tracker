% generate ROM file for a probe from 
close all; clear; clc;


% % Custom Linear Array 1
% % Machined 14-Jan-21
% romFileName = 'mak_linear_001.rom';
% mfgrString = 'Thayer';
% partNumString = 'Linear 001';
% known_marker_locs = [   0.0     0.0   13.64;
%                         0.0     1.20  13.64;    
%                         0.0     3.20  13.64 ] * 25.4;


% % MEDTRONIC SMALL PASSIVE CRANIAL FRAME 961-337
% romFileName = 'medtronic_961_337.rom';
% mfgrString = 'Medtronic';
% partNumString = 'Small Passive Cranial Frame';
% known_marker_locs = [   -63.50  -69.85  13.64;
%                          63.50  -67.44  13.64;    
%                         -63.5    38.15  13.64;
%                          56.5    30.15  13.64 ];
              
% % MEDTRONIC SMALL PASSIVE CRANIAL FRAME 961-572 SILVER
% romFileName = 'medtronic_961_572_silver.rom';
% mfgrString = 'Medtronic';
% partNumString = 'SureTrak2 Med Pas Fighter Silver';                     
% known_marker_locs = [     0.00    0.00   0.00;
%                          74.83   -5.15   0.00;
%                          35.64   51.34   0.00 ];

% % MEDTRONIC CHICKEN FOOT
% romFileName = 'medtronic_chicken_foot.rom';
% mfgrString = 'Medtronic';
% partNumString = 'Chicken Foot';                     
% known_marker_locs = [     160.00   0.00   0.00; 
%                           230.00   0.00   0.00;
%                           305.00   0.00   0.00;
%                           263.67 -43.49   0.00;
%                           256.00  42.71   0.00];
% known_marker_locs = known_marker_locs - known_marker_locs(3,:);                      

% MEDTRONIC SMALL REFERENCE FRAME
% PN9730605 / 120524
romFileName = 'medtronic_9730605_referece.rom';
mfgrString = 'Medtronic';
partNumString = 'Small Reference';                     
known_marker_locs = [     0.00     0.00    8.77; 
                          50.00    0.00    8.77;
                          77.00   65.00    8.77;
                         -39.00   65.00    8.77];

% general settings
romMaxAngle = 90;    % [deg] (integer)
romMinMarkers = 3;
romMax3DError = 0.5;  % [mm]

% compile information for tool definition ROM file
% tool definition file contents
romOptions.subType  = hex2dec('01');    % Subtype: 0x00 = Removable tip; 0x01= Fixed Tip; 0x02 = Undefined
romOptions.toolType = hex2dec('02');    % Tool type: 0x01 = Ref; 0x02 = Probe; 0x03 = Switch; 0x0C = GPIO, etc…
romOptions.toolRev  = 0;              % 0 - 999
romOptions.seqNum   = 0;   % 0 - 1023
romOptions.maxAngle = romMaxAngle;    % [deg] (integer)
romOptions.numMarkers = size(known_marker_locs,1);
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
romOptions.markerLocs(1:size(known_marker_locs,1),1:size(known_marker_locs,2)) = known_marker_locs;

% default normal to the face (and all markers on it)
% TODO: make this work with more than one face...
defaultNormal = [0 0 1];
defaultNormal = defaultNormal/norm(defaultNormal);
romOptions.markerNormals = zeros(20,3);
for markerNormalIdx = 1:size(known_marker_locs,1)
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