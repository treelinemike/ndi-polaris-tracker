% polarisCollect.m
%
% Collect data from original (old!) NDI Polaris system for PASSIVE TOOLS
% only. Up to 9 passive tools supported. Tool definition files (*.rom) must
% be supplied and may be created using NDI 6D Architect software (available
% from the NDI website, once logged in).
%
% Author: mkokko
% Revised: 12-MAR-2019 (*)
%

% function polarisCollect

% handle to function that will execute when tracking is interrupted with
% CTRL-C
cleanupHandle = onCleanup(@endTracking);

% options
doTransformPolarisOutput = true;
doUseArduino = false;
TF_polaris_to_robot_filename = 'TF_polaris_to_robot.mat';
POLARIS_COM_PORT   = 'COM5';
ARDUINO_COM_PORT   = 'COM7';
SERIAL_TERMINATOR = hex2dec('0D');   % 0x0D = 0d13 = CR
SERIAL_TIMEOUT    = 0.05;            % [s]
BASE_TOOL_CHAR = 64;



NUM_MARKERS = 1;    % number of markers in array, used only when learning an array

% load TF_polaris_to_robot if requested
if(doTransformPolarisOutput)
    load(TF_polaris_to_robot_filename);
end

% gx transform mapping (tool # -> line index in GX response)
gx_transform_map = [6 7 8 10 11 12 14 15 16];

% output file descriptor, will be given extensions .csv and .log (TODO)
trialID = 'trial';
outputFilePath = 'C:\Users\f002r5k\GitHub\ndi-polaris-tracker\matlab';

% need a dummy tool def. file for tracking a single point
% doesn't matter what the tool def file is actually for...
% tool definition files: each row is filename, toolCode
% tool code: 'D' = dynamic tool; 'S' = static tool; 'B' = button box
% note: it seems like passive (non-wired) tools start at "D"?
toolDefFiles = {
    'C:\Users\f002r5k\GitHub\ndi-polaris-tracker\tool-defs\medtronic_chicken_foot_960_556.rom', 'D';
    '', '';
    '', '';
    '', '';
    '', '';
    '', '';
    '', '';
    '', '';
    '', '' };

% make sure tool definition file cell array is the correct size
% (must be 9x2)
if (min(size(toolDefFiles) == [9,2]) == 0)
    error('Incorrect tool file definition cell array size.')
end

% make sure there is a tool definition file for the first tool
toolsUsedMask = ~cellfun(@isempty,toolDefFiles(:,1));
toolsUsed = find(toolsUsedMask);
if(~toolsUsedMask(1))
    error('Need a dummy tool definition file in the first row!\n');
end

% format GX() calls for spurious capture (i.e. of a single marker)
gx_cmd_str = 'GX:9000';
pstat_cmd_str = 'PSTAT:801f';

% reset MATLAB instrument handles just to be safe
instrreset();

% open COM port using default settings (9600 baud)
fid_polaris = serial(POLARIS_COM_PORT,'BaudRate',9600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
warning off MATLAB:serial:fread:unsuccessfulRead;
fopen(fid_polaris);

% open connection to arduino
if(doUseArduino)
    fid_arduino = serial(POLARIS_COM_PORT,'BaudRate',57600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
    fopen(fid_arduino);
end

% send a serial break to reset Polaris
% use instrreset() and instrfind() to deal with ghost MATLAB port handles
serialbreak(fid_polaris, 10);
pause(1);
disp(['< ' polarisGetResponse(fid_polaris)]);
pause(1);

% produce audible beep as confirmation
polarisSendCommand(fid_polaris, 'BEEP:1',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% change communication to 57,600 baud
polarisSendCommand(fid_polaris, 'COMM:40000',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% swich MATLAB COM port settings to 57,600 baud
fclose(fid_polaris);
disp('SWITCHING PC TO 57,000 BAUD');
pause(0.5);
fid_polaris = serial(POLARIS_COM_PORT,'BaudRate',57600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
warning off MATLAB:serial:fread:unsuccessfulRead;
fopen(fid_polaris);

% produce audible beeps as confimation
polarisSendCommand(fid_polaris, 'BEEP:2',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% initialize system
polarisSendCommand(fid_polaris, 'INIT:',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% select volume (doing this blindly without querying volumes first)
polarisSendCommand(fid_polaris, 'VSEL:1',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% set illuminator rate to 20Hz
polarisSendCommand(fid_polaris, 'IRATE:0',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% send tool definition files to Polaris
% tool files can be generated with NDI 6D Architect software
for toolIdx = 1:length(toolsUsed)
    toolNum = toolsUsed(toolIdx);
    thisToolFile = toolDefFiles{toolNum,1};
    toolFileID = fopen(thisToolFile);
    if( isempty(toolFileID) )
        fclose(fid_polaris);
        error('Invalid tool file and/or path.');
    end
    disp(['INITIALIZING PORT ' char(BASE_TOOL_CHAR+toolNum) ' WITH TOOL FILE: ' thisToolFile(max(strfind(thisToolFile,'\'))+1:end)]);

    % read 64-byte clumps from binary file
    [readBytes, numBytes] = fread(toolFileID,64);
    bytePos = 0;
    while (numBytes == 64)
        str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[])];
        polarisSendCommand(fid_polaris,str,1);
        disp(['< ' polarisGetResponse(fid_polaris)]);
        [readBytes, numBytes] = fread(toolFileID,64);
        bytePos = bytePos + 64;
    end

    % read any remaining bytes, padding with FF
    if(numBytes > 0)
        str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[]) repmat('FF',1,64-numBytes)];
        polarisSendCommand(fid_polaris,str,1);
        disp(['< ' polarisGetResponse(fid_polaris)]);
    end

    % close binary tool file
    fclose(toolFileID);

    % initialize port handle for the tool
    polarisSendCommand(fid_polaris, ['PINIT:' char(BASE_TOOL_CHAR+toolNum)],1);
    disp(['< ' polarisGetResponse(fid_polaris)]);

    % enable tracking for the tool
    polarisSendCommand(fid_polaris, ['PENA:' char(BASE_TOOL_CHAR+toolNum) toolDefFiles{toolNum,2}],1);
    disp(['< ' polarisGetResponse(fid_polaris)]);
end

% confirm tool configuration
polarisSendCommand(fid_polaris, pstat_cmd_str,1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% enter tracking mode
polarisSendCommand(fid_polaris, 'TSTART:',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% get output file ready to go
counter = 1;
outputFileName = [outputFilePath '\' trialID sprintf('%03d',counter) '.csv'];
while( isfile(outputFileName))
    counter = counter + 1;
    outputFileName = [outputFileName(1:end-7) sprintf('%03d',counter) '.csv'];
end
fidDataOut = fopen(outputFileName,'w');

% run tracking, escape with CTRL-C
format long
while(1)

    % query polaris for spurios returns
    polarisSendCommand(fid_polaris, gx_cmd_str);
    thisResp = polarisGetResponse(fid_polaris);
    disp(['< ' thisResp]);

    [match,tok] = regexp(thisResp,'([+-]+[0-9]+)','match','tokens');

    if(length(tok) == (3*NUM_MARKERS+1) )
        tokMat = cellfun(@str2num,[tok{2:end}])/100;
%         outFormatStr = repmat('%+0.4f,',1,length(tokMat));
%         outFormatStr = [outFormatStr(1:end-1) '\n'];
% %         fprintf(fidDataOut,outFormatStr,tokMat);

        if(doTransformPolarisOutput)
            output_point = hTF(tokMat',TF_polaris_to_robot,0);
        else
            output_point = tokMat';
        end

        % for arduino
        outFormatStr = repmat('%d,',1,length(output_point));
        outFormatStr = [outFormatStr(1:end-1) '\n'];
        fprintf(outFormatStr,output_point);
        fprintf(fidDataOut,outFormatStr,output_point);
        if(doUseArduino)
        end
    end

    pause;
end



function endTracking()
% close output file
fclose(fidDataOut);

% end tracking
polarisSendCommand(fid_polaris, 'TSTOP:',1);
disp(['< ' polarisGetResponse(fid_polaris)]);

% close communication
fclose(fid_polaris);
end

% end

function polarisSendCommand(comPortHandle, cmdStr, varargin)

realStr = [cmdStr polarisCRC16(0,cmdStr)];
fprintf(comPortHandle,realStr); % note: terminator added automatically (default fprintf format is %s\n
% disp(realStr);

if(nargin > 2 && varargin{1} == 1)
    disp(['> ' strtrim(cmdStr)]);
end

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
% disp('<<POLARIS RESPONSE HERE>>');
% respStr = '';


end