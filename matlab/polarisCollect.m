function polarisCollect

% options
SERIAL_TERMINATOR = hex2dec('0D');   % 0x0D = 0d13 = CR
SERIAL_TIMEOUT    = 0.05;            % [s]
SERIAL_COM_PORT   = 'COM4';

% tool definition files: each row is filename, toolCode
% tool code: 'D' = dynamic tool; 'S' = static tool; 'B' = button box
toolDefFiles = {
    'C:\Users\f002r5k\Dropbox\projects\surg_nav\NDI\Polaris\Tool Definition Files\Medtronic_960_556_V3.rom', 'D';
    'C:\Users\f002r5k\Dropbox\projects\surg_nav\NDI\Polaris\Tool Definition Files\PassiveProbe3PTS.rom', 'D'
    };
numTools = size(toolDefFiles,1);

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

% send tool definition files to Polaris
% tool files can be generated with NDI 6D Architect software
for fileIdx = 1:numTools
    thisToolFile = toolDefFiles{fileIdx,1};
    toolFileID = fopen(thisToolFile);
    if( isempty(toolFileID) )
        fclose(fid1);
        error('Invalid tool file and/or path.');
    end
    disp(['INITIALIZING PORT ' char(64+fileIdx) ' WITH TOOL FILE: ' thisToolFile(max(strfind(thisToolFile,'\'))+1:end)]);
    
    % read 64-byte clumps from binary file
    [readBytes, numBytes] = fread(toolFileID,64);
    bytePos = 0;
    while (numBytes == 64)
        str = ['PVWR:' char(64+fileIdx) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[])];
        polarisSendCommand(fid1,str);
        disp(['< ' polarisGetResponse(fid1)]);
        [readBytes, numBytes] = fread(toolFileID,64);
        bytePos = bytePos + 64;
    end
    
    % read any remaining bytes, padding with FF
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
    
    % enable tracking for the tool
    polarisSendCommand(fid1, ['PENA:' char(64+fileIdx) toolDefFiles{fileIdx,2}]);
    disp(['< ' polarisGetResponse(fid1)]);
end

% confirm tool configuration
polarisSendCommand(fid1, 'PSTAT:801f');
disp(['< ' polarisGetResponse(fid1)]);

% enter tracking mode
polarisSendCommand(fid1, 'TSTART:');
disp(['< ' polarisGetResponse(fid1)]);

% run tracking
for i = 1:50
    
    % query tool positions
    polarisSendCommand(fid1, 'GX:800B');
    thisResp = polarisGetResponse(fid1);
    unixtimestamp = posixtime(datetime('now')); % recover with datetime(unixtimestamp,'ConvertFrom','posixtime')
    
    % thisResp =[
    %     'DISABLED' char(10) ...
    %     'DISABLED' char(10) ...
    %     'DISABLED' char(10) ...
    %     '00000000000000000000000000000000000000000000' char(10) ...
    %     '000000000000000000000000' char(10) ...
    %     '+00367+00613-00731-09947+043218+001124-175562+02835' char(10) ...
    %     '+05270-05290+03621-05578+011421-004663-179021+00631' char(10) ...
    %     'DISABLED' char(10) ...
    %     '003131000000000000000000000003FF00000000003F' char(10) ...
    %     '000000000000013900000139'];
    % disp(['< ' thisResp]);
    
    % extract quaternion, position, timestamp, and estimated error for each tool
    respParts = strsplit(thisResp,char(10));
    thisStatusStr = respParts{end};
    for toolIdx = 1:numTools
        thisTransformStr = respParts{ 5 + toolIdx };
        assert( length(thisTransformStr) == 51, 'Unexpected transform string length');
        q = zeros(4,1);
        t = zeros(3,1);
        
        % extract rotational component (quaternion)
        for qIdx = 1:4
            startIdx = (qIdx-1)*6 + 1;
            q(qIdx) = str2num(thisTransformStr(startIdx:startIdx+5))/10000;
        end
        
        % extract translational component
        for tIdx = 1:3
            startIdx = (tIdx-1)*7 + 25;
            t(tIdx) = str2num(thisTransformStr(startIdx:startIdx+6))/100;
        end
        
        % extract error
        err = str2num(thisTransformStr(46:end))/10000;
        
        % extract timestamp
        startIdx = (toolIdx-1)*8+1;
        timestamp = hex2dec(thisStatusStr(startIdx:startIdx+7))/60;
        
        % display tool tracking information
        fprintf('%0.4f,%0.2f,%s,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.2f,%+0.2f,%+0.2f,%+0.4f\n', timestamp, unixtimestamp, char(64+toolIdx), q(1), q(2), q(3), q(4), t(1), t(2), t(3), err);
    end
end

% end tracking
polarisSendCommand(fid1, 'TSTOP:');
disp(['< ' polarisGetResponse(fid1)]);

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