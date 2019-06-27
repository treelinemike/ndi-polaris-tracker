% restart
close all; clear; clc;

% name of tool definition ROM file to write
romFileName = 'testToolDef.rom';

% tool definition file contents
subType  = hex2dec('01');    % Subtype: 0x00 = Removable tip; 0x01= Fixed Tip; 0x02 = Undefined
toolType = hex2dec('02');    % Tool type: 0x01 = Ref; 0x02 = Probe; 0x03 = Switch; 0x0C = GPIO, etc…
toolRev  = 0;              % 0 - 999
seqNum   = 0;   % 0 - 1023
maxAngle = 90;    % [deg] (integer)
numMarkers = 4;
minMarkers = 3;
max3DError = 2.000;  % [mm]
minSpread1 = 0;
minSpread2 = 0;
minSpread3 = 0;
numFaces = 1;
numGroups = 1;
trackLED = 31;  % LEDs: 0x1F = None; 0x00 = A; 0x13 = T; 0x1E = Set in GPIO 
led1 = 31;            % 0x1F = 0d31
led2 = 31;
led3 = 31;
gpio1 = 9;  % GPIOs: 0x09 = Input, 0x10 = Output; 0x30 = Always High; 0x11 = Output w/ Feedback; 0x00 = None
gpio2 = 0;
gpio3 = 0;
gpio4 = 0;
mfgr = 'Thayer';
partNum = 'Xi Collar 001';
enhAlgFlags = 128;
MrkrType = 41; % Marker Type: 0x11 = 880 Active Ceramic; 0x12 = 930; 0x10 = NDI Legacy; 0x29 = Passive Marker, Sphere; 0x31 = Passive Marker, Disk 
               % 0x29 = 0d41
               
% marker locations... TODO: roll into a function where this is provided as input
markerLocs = zeros(20,3);
markerLocs(1,:) = [13.02 -0.37 0.44];
markerLocs(2,:) = [-11.55 43.12 -0.03];
markerLocs(3,:) = [-22.63 -42.31 -0.03];
markerLocs(4,:) = [-62.08 2.88 -0.17];
markerLocs(5,:) = [83.24 -3.32 -0.21];

% default normal to the face (and all markers on it)
defaultNormal = [0.015600 -0.002000 -0.9999];
defaultNormal = defaultNormal/norm(defaultNormal);
markerNormals = zeros(20,3);
markerNormals(1,:) = defaultNormal;
markerNormals(2,:) = defaultNormal;
markerNormals(3,:) = defaultNormal;
markerNormals(4,:) = defaultNormal;
markerNormals(5,:) = defaultNormal;
faceNormals = zeros(8,3);
faceNormals(1,:) = defaultNormal;

% sequence number byte
seqNumByte = bitand(uint16(seqNum),hex2dec('FF'));
seqNumPartialByte = double(bitand(swapbytes(uint16(seqNum)),hex2dec('FF')));

% encode the date
 thisDateVec = datevec('27-FEB-2017');
%thisDateVec = datevec(date);
datevar = bitshift((datenum(thisDateVec)-datenum(datetime(thisDateVec(1),1,1))),2);  % day of year
datevar = bitor(datevar,seqNumPartialByte);                    % add two bits of sequence number
datevar = bitor(datevar,bitshift((thisDateVec(2)-1),11));      % month
datevar = bitor(bitshift((thisDateVec(1) - 1900),15),datevar); % year

% faces and groups
faceGrpByte = bitor(uint8(bitshift(numFaces,3)),uint8(bitand(numGroups,hex2dec('07'))));

% initialize output string
writeStr = repmat(uint8(0),1,752);

% construct binary string for output
writeStr(1:3)     = 'NDI';
writeStr(9)       = uint8(1);          % not sure what this field is...
writeStr(13)      = uint8(subType);
writeStr(16)      = uint8(toolType);
writeStr(17:18)   = typecast(uint16(toolRev),'uint8'); % TODO: requires little endian system
writeStr(21)      = seqNumByte;
writeStr(22:24)   = getfield(typecast(uint32(datevar),'uint8'),{1:3}); % TODO: requires little endian system
writeStr(25)      = uint8(maxAngle);
writeStr(29)      = uint8(numMarkers);
writeStr(33)      = uint8(minMarkers);
writeStr(37:40)   = typecast(single(max3DError),'uint8'); % TODO: requires little endian system
writeStr(41:44)   = typecast(single(minSpread1),'uint8'); % TODO: requires little endian system
writeStr(45:48)   = typecast(single(minSpread2),'uint8'); % TODO: requires little endian system
writeStr(49:52)   = typecast(single(minSpread3),'uint8'); % TODO: requires little endian system
writeStr(67)      = uint8(hex2dec('20')); % not sure what this field is...
writeStr(68)      = uint8(hex2dec('41')); % not sure what this field is...

writeStr(573)      = uint8(trackLED);
writeStr(574)      = uint8(led1);
writeStr(575)      = uint8(led2);
writeStr(576)      = uint8(led3);
writeStr(577)      = uint8(gpio1);
writeStr(578)      = uint8(gpio2);
writeStr(579)      = uint8(gpio3);
writeStr(580)      = uint8(gpio4);
writeStr(613)      = uint8(faceGrpByte);
writeStr(654)      = uint8(enhAlgFlags);
writeStr(656)      = uint8(MrkrType);

% manufacturer
if(length(mfgr) > 12)
    mfgr = mfgr(1:12);
else
    mfgr = [mfgr zeros(1,12-length(mfgr))];
end
writeStr(580+(1:12)) = mfgr;

% part number
if(length(partNum) > 20)
    partNum = partNum(1:20);
else
    partNum = [partNum zeros(1,20-length(partNum))];
end
writeStr(592+(1:20)) = partNum;

% marker locations
for markerIdx = 1:size(markerLocs,1)
   baseByteIdx = 73+12*(markerIdx-1);
   writeStr(baseByteIdx + 0 + [0:3]) = typecast(single(markerLocs(markerIdx,1)),'uint8'); % x location
   writeStr(baseByteIdx + 4 + [0:3]) = typecast(single(markerLocs(markerIdx,2)),'uint8'); % y location
   writeStr(baseByteIdx + 8 + [0:3]) = typecast(single(markerLocs(markerIdx,3)),'uint8'); % z location
end

% marker normals
for markerIdx = 1:size(markerNormals,1)
   baseByteIdx = 313+12*(markerIdx-1);
   writeStr(baseByteIdx + 0 + [0:3]) = typecast(single(markerNormals(markerIdx,1)),'uint8'); % x location
   writeStr(baseByteIdx + 4 + [0:3]) = typecast(single(markerNormals(markerIdx,2)),'uint8'); % y location
   writeStr(baseByteIdx + 8 + [0:3]) = typecast(single(markerNormals(markerIdx,3)),'uint8'); % z location
end

% face normals
for faceIdx = 1:size(faceNormals,1)
   baseByteIdx = 657+12*(faceIdx-1);
   writeStr(baseByteIdx + 0 + [0:3]) = typecast(single(faceNormals(faceIdx,1)),'uint8'); % x location
   writeStr(baseByteIdx + 4 + [0:3]) = typecast(single(faceNormals(faceIdx,2)),'uint8'); % y location
   writeStr(baseByteIdx + 8 + [0:3]) = typecast(single(faceNormals(faceIdx,3)),'uint8'); % z location
end

% firing sequence, face and group assignments
for markerIdx = 1:numMarkers
    % firing sequence
    writeStr(markerIdx + 552) = markerIdx-1;
    
    % assign all markers to first face
    writeStr(markerIdx + 613) = 1;
    
    % assign all markers to first group
    writeStr(markerIdx + 633) = 1;
end

% compute and add checksum
byteSum = uint16(0);
for byteNum = 7:length(writeStr)
    byteSum = byteSum + uint16(writeStr(byteNum));
end
writeStr(5:6) = typecast(uint16(byteSum),'uint8'); % TODO: requires little endian system

% write data to ROM file
fidOut = fopen(romFileName,'w');
fwrite(fidOut,writeStr);
fclose(fidOut);

% decode a floating point number from ROM file
% swapbytes(typecast( uint32( hex2dec( 'CEAAAFBF' ) ), 'single'))