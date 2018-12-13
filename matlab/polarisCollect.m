function polarisCollect

% options
SERIAL_TERMINATOR = hex2dec('0D');   % 0x0D = 0d13 = CR
SERIAL_TIMEOUT    = 0.05;            % [s]
SERIAL_COM_PORT   = 'COM4';

global frameNums;
frameNums = [];

% reset MATLAB instrument handles just to be safe
instrreset();

% open COM port using default settings (9600 baud)

fid1 = serial(SERIAL_COM_PORT,'BaudRate',9600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
warning off MATLAB:serial:fread:unsuccessfulRead;
fopen(fid1);

% send a serial break to reset Polaris
% use instrreset() and instrfind() to deal with ghost MATLAB port handles
serialbreak(fid1, 10);
pause(1);
disp(['< ' polarisGetResponse(fid1)]);
pause(1);

% produce audible beep as confirmation
polarisSendCommand(fid1, 'BEEP:1');
disp(['< ' polarisGetResponse(fid1)]);

% change communication to 57,600 baud
polarisSendCommand(fid1, 'COMM:40000');
disp(['< ' polarisGetResponse(fid1)]);

% swich MATLAB COM port settings to 57,600 baud
fclose(fid1);
disp('SWITCHING PC TO 57,000 BAUD');
pause(0.5);
fid1 = serial(SERIAL_COM_PORT,'BaudRate',57600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
warning off MATLAB:serial:fread:unsuccessfulRead;
fopen(fid1);

% produce audible beeps as confimation
polarisSendCommand(fid1, 'BEEP:2');
disp(['< ' polarisGetResponse(fid1)]);

% initialize system
polarisSendCommand(fid1, 'INIT:');
disp(['< ' polarisGetResponse(fid1)]);

% select volume (doing this blindly without querying volumes first)
polarisSendCommand(fid1, 'VSEL:1');
disp(['< ' polarisGetResponse(fid1)]);

% set illuminator rate to 20Hz
polarisSendCommand(fid1, 'IRATE:0');
disp(['< ' polarisGetResponse(fid1)]);


%
toolDefFiles = {
    'C:\Users\f002r5k\Dropbox\projects\surg_nav\NDI\Polaris\Tool Definition Files\Medtronic_960_556_V3.rom';
    'C:\Users\f002r5k\Dropbox\projects\surg_nav\NDI\Polaris\Tool Definition Files\PassiveProbe3PTS.rom'
    };
for fileIdx = 1:size(toolDefFiles,1)
    thisToolFile = toolDefFiles{fileIdx};
    toolFileID = fopen(thisToolFile);
    if( isempty(toolFileID) )
        fclose(fid1);
        error('Invalid tool file and/or path.');
    end
    disp(['INITIALIZING PORT ' char(64+fileIdx) ' WITH TOOL FILE: ' thisToolFile(max(strfind(thisToolFile,'\'))+1:end)]);
    
    [readBytes, numBytes] = fread(toolFileID,64);
    bytePos = 0;
    while (numBytes == 64)
        str = ['PVWR:' char(64+fileIdx) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[])];
        polarisSendCommand(fid1,str);
        disp(['< ' polarisGetResponse(fid1)]);
        [readBytes, numBytes] = fread(toolFileID,64);
        bytePos = bytePos + 64;
    end
    if(numBytes > 0)
        str = ['PVWR:' char(64+fileIdx) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[]) repmat('FF',1,64-numBytes)];
        polarisSendCommand(fid1,str);
        disp(['< ' polarisGetResponse(fid1)]);
    end
    
    % close binary tool file
    fclose(toolFileID);
    
    % initialize port handle for the tool
    polarisSendCommand(fid1, ['PINIT:' char(64+fileIdx)]);
    disp(['< ' polarisGetResponse(fid1)]);
    
    % enable tracking for the tool ... ASSUMING DYNAMIC TOOL 'D' (may want to
    % change this to allow for static tools or button boxes)
    polarisSendCommand(fid1, ['PENA:' char(64+fileIdx) 'D']);
    disp(['< ' polarisGetResponse(fid1)]);
end

% confirm tool configuration
polarisSendCommand(fid1, 'PSTAT:801f');
disp(['< ' polarisGetResponse(fid1)]);

% enter tracking mode
polarisSendCommand(fid1, 'TSTART:');
disp(['< ' polarisGetResponse(fid1)]);

% query position of tools
for i = 1:50
    
    polarisSendCommand(fid1, 'GX:800B');
    
    thisResp = polarisGetResponse(fid1);
    disp(['< ' thisResp]);
    
    frameNums(end+1) = hex2dec(thisResp(end-15:end-8));

    pause(1);
    
end



% end tracking
polarisSendCommand(fid1, 'TSTOP:');
disp(['< ' polarisGetResponse(fid1)]);

% % change communication back to 9600 baud
% polarisSendCommand(fid1, 'COMM:00000');
% disp(['< ' polarisGetResponse(fid1)]);

% % send a serial break to reset Polaris
% serialbreak(fid1, 1000);

% close communication
fclose(fid1);


end

function polarisSendCommand(comPortHandle, cmdStr)

realStr = [cmdStr polarisCRC16(0,cmdStr)];
fprintf(comPortHandle,realStr); % note: terminator added automatically (default fprintf format is %s\n
disp(['> ' strtrim(cmdStr)]);

end

function respStr = polarisGetResponse(comPortHandle)

% read response
resp = strtrim(reshape(char(fgetl(comPortHandle)),1,[]));
if(length(resp) < 5)
    fclose(comPortHandle);
    error('Invalid (or no) response from Polaris.');
end

% split off CRC
respCRC = strtrim(resp(end-3:end));
respStr = strtrim(resp(1:end-4));

% check CRC
if(~strcmp(respCRC,polarisCRC16(0,respStr)))
    fclose(comPortHandle);
    error('CRC Mismatch');
end

end