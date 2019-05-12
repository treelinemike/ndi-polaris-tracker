% restart
close all; clear all; clc;

romFileName = 'testToolDef.rom';

subType  = hex2dec('01');    % Subtype: 0x00 = Removable tip; 0x01= Fixed Tip; 0x02 = Undefined
toolType = hex2dec('02');    % Tool type: 0x01 = Ref; 0x02 = Probe; 0x03 = Switch; 0x0C = GPIO, etc…
toolRev  = 999;              % 0 - 999
seqNum   = 976;   % 0 - 1023
maxAngle = 90;    % [deg] (integer)
numMarkers = 5;
minMarkers = 3;
max3DError = 2.000;  % [mm]
minSpread1 = 0;
minSpread2 = 0;
minSpread3 = 0;

markerLocs = zeros(20,3);
markerLocs(1,:) = [13.02 -0.37 0.44];
markerLocs(2,:) = [-11.55 43.12 -0.03];
markerLocs(3,:) = [-22.63 -42.31 -0.03];
markerLocs(4,:) = [-62.08 2.88 -0.17];
markerLocs(5,:) = [83.24 -3.32 -0.21];

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
% dec2hex(seqNumByte)
seqNumPartialByte = double(bitand(swapbytes(uint16(seqNum)),hex2dec('FF')));

% compose a date... don't foget to update checksum afterward!
 thisDateVec = datevec('27-FEB-2017');
%thisDateVec = datevec(date);
datevar = bitshift((datenum(thisDateVec)-datenum(datetime(thisDateVec(1),1,1))),2);  % day of year

datevar = bitor(datevar,seqNumPartialByte);                    % add two bits of sequence number
datevar = bitor(datevar,bitshift((thisDateVec(2)-1),11));      % month
datevar = bitor(bitshift((thisDateVec(1) - 1900),15),datevar); % year
dec2hex(bitshift(swapbytes(uint32(datevar)),-8))               % date bytes for binary file




% try to compute checksum...
addpath('C:\Users\f002r5k\GitHub\ndi-polaris-tracker\matlab');
binFile = fopen('medtronic_fromdata_1_h.rom');
[readBytes, numBytes] = fread(binFile);
fclose(binFile);
readStr = char(readBytes)';
% get actual checksum from file
realCSum = reshape(dec2hex(double(readStr(5:6)))',1,[]);

byteSum = uint16(0);
for byteNum = 7:numBytes
    byteSum = byteSum + readBytes(byteNum);
end
csum = dec2hex(swapbytes(uint16(sum(readBytes(7:end)))))


% decode a floating point number from ROM file
% swapbytes(typecast( uint32( hex2dec( 'CEAAAFBF' ) ), 'single'))

% encode a floating point number from ROM file

%%
% initialize output string
writeStr = repmat(uint8(0),1,752);

% construct binary string for output
writeStr(1:3)     = 'NDI';
writeStr(9)       = uint8(1);          % not sure what this field is...
writeStr(13)      = uint8(subType);
writeStr(16)      = uint8(toolType);
writeStr(17:18)   = typecast(uint16(999),'uint8'); % TODO: requires little endian system
writeStr(21)      = seqNumByte;
writeStr(22:24)   = getfield(typecast(uint32(datevar),'uint8'),{1:3}); % TODO: requires little endian system
writeStr(25)      = uint8(maxAngle);
writeStr(29)      = uint8(numMarkers);
writeStr(33)      = uint8(minMarkers);
writeStr(37:40)   = typecast(single(max3DError),'uint8'); % TODO: requires little endian system
writeStr(41:44)   = typecast(single(minSpread1),'uint8'); % TODO: requires little endian system
writeStr(45:48)   = typecast(single(minSpread2),'uint8'); % TODO: requires little endian system
writeStr(49:52)   = typecast(single(minSpread3),'uint8'); % TODO: requires little endian system
writeStr(67)      = uint8(hex2dec('20'));
writeStr(68)      = uint8(hex2dec('41'));
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

fidOut = fopen(romFileName,'w');
fwrite(fidOut,writeStr);
fclose(fidOut);


