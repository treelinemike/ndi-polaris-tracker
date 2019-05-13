function writeToolDefROMFile(romFileName,romOptions)

% initialize output string
writeStr = repmat(uint8(0),1,752);

% construct binary string for output
writeStr(1:3)     = 'NDI';
writeStr(9)       = uint8(1);          % not sure what this field is...
writeStr(13)      = uint8(romOptions.subType);
writeStr(16)      = uint8(romOptions.toolType);
writeStr(17:18)   = typecast(uint16(romOptions.toolRev),'uint8'); % TODO: requires little endian system
writeStr(21)      = romOptions.seqNumByte;
writeStr(22:24)   = getfield(typecast(uint32(romOptions.dateBytes),'uint8'),{1:3}); % TODO: requires little endian system
writeStr(25)      = uint8(romOptions.maxAngle);
writeStr(29)      = uint8(romOptions.numMarkers);
writeStr(33)      = uint8(romOptions.minMarkers);
writeStr(37:40)   = typecast(single(romOptions.max3DError),'uint8'); % TODO: requires little endian system
writeStr(41:44)   = typecast(single(romOptions.minSpread1),'uint8'); % TODO: requires little endian system
writeStr(45:48)   = typecast(single(romOptions.minSpread2),'uint8'); % TODO: requires little endian system
writeStr(49:52)   = typecast(single(romOptions.minSpread3),'uint8'); % TODO: requires little endian system
writeStr(67)      = uint8(hex2dec('20')); % not sure what this field is...
writeStr(68)      = uint8(hex2dec('41')); % not sure what this field is...

writeStr(573)      = uint8(romOptions.trackLED);
writeStr(574)      = uint8(romOptions.led1);
writeStr(575)      = uint8(romOptions.led2);
writeStr(576)      = uint8(romOptions.led3);
writeStr(577)      = uint8(romOptions.gpio1);
writeStr(578)      = uint8(romOptions.gpio2);
writeStr(579)      = uint8(romOptions.gpio3);
writeStr(580)      = uint8(romOptions.gpio4);
writeStr(613)      = uint8(romOptions.faceGrpByte);
writeStr(654)      = uint8(romOptions.enhAlgFlags);
writeStr(656)      = uint8(romOptions.MrkrType);

% manufacturer
if(length(romOptions.mfgr) > 12)
    romOptions.mfgr = romOptions.mfgr(1:12);
else
    romOptions.mfgr = [romOptions.mfgr zeros(1,12-length(romOptions.mfgr))];
end
writeStr(580+(1:12)) = romOptions.mfgr;

% part number
if(length(romOptions.partNum) > 20)
    romOptions.partNum = romOptions.partNum(1:20);
else
    romOptions.partNum = [romOptions.partNum zeros(1,20-length(romOptions.partNum))];
end
writeStr(592+(1:20)) = romOptions.partNum;

% marker locations
for markerIdx = 1:size(romOptions.markerLocs,1)
   baseByteIdx = 73+12*(markerIdx-1);
   writeStr(baseByteIdx + 0 + [0:3]) = typecast(single(romOptions.markerLocs(markerIdx,1)),'uint8'); % x location
   writeStr(baseByteIdx + 4 + [0:3]) = typecast(single(romOptions.markerLocs(markerIdx,2)),'uint8'); % y location
   writeStr(baseByteIdx + 8 + [0:3]) = typecast(single(romOptions.markerLocs(markerIdx,3)),'uint8'); % z location
end

% marker normals
for markerIdx = 1:size(romOptions.markerNormals,1)
   baseByteIdx = 313+12*(markerIdx-1);
   writeStr(baseByteIdx + 0 + [0:3]) = typecast(single(romOptions.markerNormals(markerIdx,1)),'uint8'); % x location
   writeStr(baseByteIdx + 4 + [0:3]) = typecast(single(romOptions.markerNormals(markerIdx,2)),'uint8'); % y location
   writeStr(baseByteIdx + 8 + [0:3]) = typecast(single(romOptions.markerNormals(markerIdx,3)),'uint8'); % z location
end

% face normals
for faceIdx = 1:size(romOptions.faceNormals,1)
   baseByteIdx = 657+12*(faceIdx-1);
   writeStr(baseByteIdx + 0 + [0:3]) = typecast(single(romOptions.faceNormals(faceIdx,1)),'uint8'); % x location
   writeStr(baseByteIdx + 4 + [0:3]) = typecast(single(romOptions.faceNormals(faceIdx,2)),'uint8'); % y location
   writeStr(baseByteIdx + 8 + [0:3]) = typecast(single(romOptions.faceNormals(faceIdx,3)),'uint8'); % z location
end

% firing sequence, face and group assignments
for markerIdx = 1:romOptions.numMarkers
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

end


% decode a floating point number from ROM file
% swapbytes(typecast( uint32( hex2dec( 'CEAAAFBF' ) ), 'single'))