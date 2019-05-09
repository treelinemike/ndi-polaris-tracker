
% compose a date... don't foget to update checksum!!
datevar = bitshift((datenum('9/9/2019')-datenum('1/1/2019')),2);
datevar = bitor(datevar,bitshift((9-1),11));
datevar = bitor(bitshift(hex2dec('3B80'),8),datevar);

addpath('C:\Users\f002r5k\GitHub\ndi-polaris-tracker\matlab');

swapbytes(typecast( uint32( hex2dec( 'CEAAAFBF' ) ), 'single'))

binFile = fopen('medtronic_fromdata_1.rom');
[readBytes, numBytes] = fread(binFile)
fclose(binFile);
readStr = char(readBytes)';
% get actual checksum from file
realCSum = reshape(dec2hex(double(readStr(5:6)))',1,[])
% csum = 0;
% for byteNum = 7:numBytes
csum = polarisCRC16(0,readStr([16:end]))
% end
