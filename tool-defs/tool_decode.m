
% compose a date... don't foget to update checksum!!
datevar = bitshift((datenum('9/9/2019')-datenum('1/1/2019')),2);
datevar = bitor(datevar,bitshift((9-1),11));
datevar = bitor(bitshift(hex2dec('3B80'),8),datevar);


swapbytes(typecast( uint32( hex2dec( 'CEAAAFBF' ) ), 'single'))