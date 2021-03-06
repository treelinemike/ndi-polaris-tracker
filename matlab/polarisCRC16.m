% polarisCRC16.m
% CRC16 implementation adapted from NDI Polaris API user guide
% Author: mkokko (but copied from API guide)
% Date:   30-NOV-2018
function crc = polarisCRC16(crc, addBytes, varargin)

if(nargin > 2)
    disp('using provided polynomial');
    crcPolynomial = str2num(char(dec2bin(varargin{1}))')';
    crcPolynomial = [ zeros(1,16-length(crcPolynomial)) crcPolynomial]
else
    crcPolynomial = [0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0]; % constant
end

crc = uint16(crc); % 16-bit unsigned int

% add to CRC for each byte of data in input string
for dataIdx = 1:length(addBytes)
    
    data = uint16(addBytes(dataIdx)); % 16-bit unsigned int
    data = bitand( (bitxor(data, bitand(crc, 255) ) ) , 255 );
    crc = bitshift(crc,-8);
        
    if( bitxor( crcPolynomial( bitand(data,15)+1), crcPolynomial(bitshift(data,-4)+1)) ) 
        crc = bitxor(crc,49153);
    end
    
    data = bitshift(data,6);
    crc = bitxor(crc,data);
    data = bitshift(data,1);
    crc = bitxor(crc,data);

end

    % return hex string
    crc = dec2hex(crc,4);%sprintf('%04X',crc);
end