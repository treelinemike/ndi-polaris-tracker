seqNum = 976;

% sequence number byte
seqNumByte = dec2hex(bitand(uint16(seqNum),hex2dec('FF')))
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
