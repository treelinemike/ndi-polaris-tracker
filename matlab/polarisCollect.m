function polarisCollect

% open COM port using default settings (9600 baud)
COM_PORT = 'COM4';
BAUDRATE = 9600;
fid1 = serial(COM_PORT,'BaudRate',BAUDRATE,'Timeout',0.005);
warning off MATLAB:serial:fread:unsuccessfulRead;
fopen(fid1);

% produce audible beep as confirmation
polarisSendCommand(fid1, 'BEEP:1');
disp(['< ' polarisGetResponse(fid1)]);

% change communication to 57,600 baud
polarisSendCommand(fid1, 'COMM:40000');
disp(['< ' polarisGetResponse(fid1)]);

% swich MATLAB COM port settings to 57,600 baud
fclose(fid1);
pause(0.5);
BAUDRATE = 57600;
fid1 = serial(COM_PORT,'BaudRate',BAUDRATE,'Timeout',0.005);
warning off MATLAB:serial:fread:unsuccessfulRead;
fopen(fid1);

% produce audible beeps as confimation
polarisSendCommand(fid1, 'BEEP:2');
disp(['< ' polarisGetResponse(fid1)]);

% change communication back to 9600 baud
polarisSendCommand(fid1, 'COMM:00000');
disp(['< ' polarisGetResponse(fid1)]);

% close communication
fclose(fid1);


%%
% toolDefFiles = {
%     'C:\Users\f002r5k\Dropbox\projects\surg_nav\NDI\Polaris\Tool Definition Files\Medtronic_960_556_V3.rom',
%     'C:\Users\f002r5k\Dropbox\projects\surg_nav\NDI\Polaris\Tool Definition Files\Medtronic_960_556_V3.rom'
%     };
% for fileIdx = 1:size(toolDefFiles,2)
%     toolFileID = fopen(toolDefFiles{1});
%     [readBytes, numBytes] = fread(toolFileID,64);
%     bytePos = 0;
%     while (numBytes == 64)
%         str = ['PVWR:' char(64+fileIdx) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[])];
%         polarisSendCommand(fid1,str);
%         [readBytes, numBytes] = fread(toolFileID,64);
%         bytePos = bytePos + 64;
%     end
%     if(numBytes > 0)
%         str = ['PVWR:A' dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[]) repmat('FF',1,64-numBytes)];
%         polarisSendCommand(fid1,str);
%     end
%     
%     fclose(toolFileID);
% end
% 
% 

end

function polarisSendCommand(comPortHandle, cmdStr)

realStr = [cmdStr polarisCRC16(0,cmdStr) char(13)];
fprintf(comPortHandle,realStr);
disp(['> ' strtrim(cmdStr)]);

end

function respStr = polarisGetResponse(comPortHandle)

% read response
resp = strtrim(reshape(char(fread(comPortHandle)),1,[]));

% split off CRC
respCRC = strtrim(resp(end-3:end));
respStr = strtrim(resp(1:end-4));

% check CRC
if(~strcmp(respCRC,polarisCRC16(0,respStr)))
    error('CRC Mismatch');
end

end