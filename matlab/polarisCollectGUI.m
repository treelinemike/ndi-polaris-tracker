function varargout = polarisCollectGUI(varargin)
% POLARISCOLLECTGUI MATLAB code for polarisCollectGUI.fig
%      POLARISCOLLECTGUI, by itself, creates a new POLARISCOLLECTGUI or raises the existing
%      singleton*.
%
%      H = POLARISCOLLECTGUI returns the handle to a new POLARISCOLLECTGUI or the handle to
%      the existing singleton*.
%
%      POLARISCOLLECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POLARISCOLLECTGUI.M with the given input arguments.
%
%      POLARISCOLLECTGUI('Property','Value',...) creates a new POLARISCOLLECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before polarisCollectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to polarisCollectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help polarisCollectGUI

% Last Modified by GUIDE v2.5 11-May-2021 21:07:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @polarisCollectGUI_OpeningFcn, ...
    'gui_OutputFcn',  @polarisCollectGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before polarisCollectGUI is made visible.
function polarisCollectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to polarisCollectGUI (see VARARGIN)

% Choose default command line output for polarisCollectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

handles.comport.String = [{'Auto'} cellstr(seriallist())];
set(handles.tooldeffile,'Enable','off')
set(handles.tipcalfile,'Enable','off')
toolDefFiles = repmat({'',''},9,1); 
tipCalFiles = repmat({''},9,1);
setappdata(handles.mainpanel,'toolDefFiles',toolDefFiles);
setappdata(handles.mainpanel,'tipCalFiles',tipCalFiles);
setappdata(handles.mainpanel,'tipCalData',zeros(9,3));
setappdata(handles.mainpanel,'doUseTipCal',0);
setappdata(handles.mainpanel,'outputFilePath','');
setappdata(handles.mainpanel,'fidDataOut',-1);
setappdata(handles.mainpanel,'fidSerial',-1);
setappdata(handles.mainpanel,'gx_cmd_str','');
setappdata(handles.mainpanel,'pstat_cmd_str','');
setappdata(handles.mainpanel,'BASE_TOOL_CHAR',64);
setappdata(handles.mainpanel,'toolsUsed',[]);
setappdata(handles.mainpanel,'gx_transform_map',[6 7 8 10 11 12 14 15 16]);
setappdata(handles.mainpanel,'endTrackingFlag',0);
setappdata(handles.mainpanel,'DEBUG_MODE',0);   % SET DEBUG MODE HERE, 0 surpresses display output for faster data rate %
setappdata(handles.mainpanel,'send_video_cmd',0);
setappdata(handles.mainpanel,'pointHandles',[]);
setappdata(handles.mainpanel,'validFrameCount',0);
setappdata(handles.mainpanel,'previewFlag',0);

% configure various UI components
updateOutputFilePath(hObject, eventdata, handles);
updateToolDefDisplay(hObject, eventdata, handles);
set(handles.disconnectbutton,'Enable','off');
set(handles.startcap,'Enable','off');
set(handles.startcapvid,'Enable','off');
set(handles.stopcap,'Enable','off');
set(handles.singlecap,'Enable','off');
set(handles.preview,'Enable','off');
set(handles.capturenote,'Enable','off');
set(handles.nummarkers,'Enable','off');
set(handles.tipbutton,'Enable','off');
set(handles.generateROM,'Enable','off');
resetToolStatusIndicators(hObject, eventdata, handles);

% initialize plots
% make sure GridColorMode is set to manual in GUIDE figure object!
axes(handles.axes_frontview);
hold on; grid on;
axis equal;
xlim([-750,750]);
ylim([-750, 750]);
r = 500;
theta = 0:0.01:2*pi;
plot(r*cos(theta),r*sin(theta),'k-','LineWidth',1.6);
plot([-750 750],[-650 -650],':','Color',0.7*ones(1,3),'LineWidth',6);

axes(handles.axes_topview);
hold on; grid on;
axis equal;
xlim([-100,2650]);
ylim([-750, 750]);
plot(0,0,'k.','MarkerSize',25);
plot([0 0],[-250 250],'k-','LineWidth',3);
theta = pi/2:0.01:3*pi/2;
plot(1900+r*cos(theta),r*sin(theta),'k-','LineWidth',1.6);
plot([1900 2400 2400 1900],[500 500 -500 -500],'k-','LineWidth',1.6);

axes(handles.axes_sideview);
hold on; grid on;
axis equal;
xlim([-100,2650]);
ylim([-750, 750]);
plot(0,0,'k.','MarkerSize',25);
plot([1900 2400 2400 1900],[500 500 -500 -500],'k-','LineWidth',1.6);
theta = pi/2:0.01:3*pi/2;
plot(1900+r*cos(theta),r*sin(theta),'k-','LineWidth',1.6);
plot([-100 2650],[-650 -650],':','Color',0.7*ones(1,3),'LineWidth',6);

pointHandles = getappdata(handles.mainpanel,'pointHandles');
for toolIdx = 1:9
    axes(handles.axes_frontview);
    pointHandles(toolIdx).front = text(nan,nan,char(64+toolIdx),'FontSize',18,'FontWeight','bold','HorizontalAlignment','Center');
    axes(handles.axes_sideview);
    pointHandles(toolIdx).side = text(nan,nan,char(64+toolIdx),'FontSize',18,'FontWeight','bold','HorizontalAlignment','Center');
    axes(handles.axes_topview);
    pointHandles(toolIdx).top = text(nan,nan,char(64+toolIdx),'FontSize',18,'FontWeight','bold','HorizontalAlignment','Center');
end
setappdata(handles.mainpanel,'pointHandles',pointHandles);

% important reminders
% warndlg('Turn off Bluetooth radio!','Reminder: Bluetooth','modal')
% warndlg('Press REM on Blackmagic recorders!','Reminder: Blackmagic','modal')

% UIWAIT makes polarisCollectGUI wait for user response (see UIRESUME)
% uiwait(handles.mainpanel);
% reset tool status "lights"
function resetToolStatusIndicators(hObject, eventdata, handles)
notLoadColor = get(handles.label_notload,'BackgroundColor');
set(handles.status_a,'BackgroundColor',notLoadColor);
set(handles.status_b,'BackgroundColor',notLoadColor);
set(handles.status_c,'BackgroundColor',notLoadColor);
set(handles.status_d,'BackgroundColor',notLoadColor);
set(handles.status_e,'BackgroundColor',notLoadColor);
set(handles.status_f,'BackgroundColor',notLoadColor);
set(handles.status_g,'BackgroundColor',notLoadColor);
set(handles.status_h,'BackgroundColor',notLoadColor);
set(handles.status_i,'BackgroundColor',notLoadColor);

% set tool status indicator
% status codes:
%  0 -> tracking, no errors
%  1 -> partially out of volume
%  2 -> out of volume
%  3 -> not enough markers
%  4 -> tool not loaded
function indicatorColor = setToolStatusIndicator(toolIdx,statusCode,handles)

% determine what color to set indicator
switch(statusCode)
    case 0
        indicatorColor = get(handles.label_track,'BackgroundColor');
    case 1
        indicatorColor = get(handles.label_poov,'BackgroundColor');
    case 2
        indicatorColor = get(handles.label_oov,'BackgroundColor');
    case 3
        indicatorColor = get(handles.label_toofew,'BackgroundColor');
    case 4
        indicatorColor = get(handles.label_notload,'BackgroundColor');
    otherwise
        error('Unrecognized status code!');
end

% set indicator to correct color
switch(toolIdx)
    case 1
        set(handles.status_a,'BackgroundColor',indicatorColor);
    case 2
        set(handles.status_b,'BackgroundColor',indicatorColor);
    case 3
        set(handles.status_c,'BackgroundColor',indicatorColor);
    case 4
        set(handles.status_d,'BackgroundColor',indicatorColor);
    case 5
        set(handles.status_e,'BackgroundColor',indicatorColor);
    case 6
        set(handles.status_f,'BackgroundColor',indicatorColor);
    case 7
        set(handles.status_g,'BackgroundColor',indicatorColor);
    case 8
        set(handles.status_h,'BackgroundColor',indicatorColor);
    case 9
        set(handles.status_i,'BackgroundColor',indicatorColor);
    otherwise
        error('Invalid tool index!');
end

% disable controls for changing output file
function disableOutputFileChange(hObject, eventdata, handles)
set(handles.outputfile,'Enable','off');
set(handles.outputfileselectbutton,'Enable','off');
set(handles.outputfileclearbutton,'Enable','off');

% enable controls for changing output file
function enableOutputFileChange(hObject, eventdata, handles)
set(handles.outputfile,'Enable','on');
set(handles.outputfileselectbutton,'Enable','on');
set(handles.outputfileclearbutton,'Enable','on');

% disable controls for changing tool definition table
function disableToolDefChange(hObject, eventdata, handles)
set(handles.rbstatic,'Enable','off');
set(handles.rbdynamic,'Enable','off');
set(handles.tooldefbutton,'Enable','off');
set(handles.tooldefclearbutton,'Enable','off');
set(handles.tipcalbutton,'Enable','off');
set(handles.tipcalclearbutton,'Enable','off');

% enable controls for changing tool definition table
function enableToolDefChange(hObject, eventdata, handles)
set(handles.rbstatic,'Enable','on');
set(handles.rbdynamic,'Enable','on');
set(handles.tooldefbutton,'Enable','on');
set(handles.tooldefclearbutton,'Enable','on');
set(handles.tipcalbutton,'Enable','on');
set(handles.tipcalclearbutton,'Enable','on');

function updateOutputFilePath(hObject, eventdata, handles)
outputFilePath = getappdata(handles.mainpanel,'outputFilePath');
if(isempty(outputFilePath))
    set(handles.outputfile,'String','trial001.csv');
else
    lastSlashIdx = find(outputFilePath == '\',1,'last');
    if(~isempty(lastSlashIdx))
        set(handles.outputfile,'String',outputFilePath(lastSlashIdx+1:end));
    else
        set(handles.outputfile,'String',outputFilePath);
    end
end

function updateToolDefDisplay(hObject, eventdata, handles)
toolDefFiles = getappdata(handles.mainpanel,'toolDefFiles');
tipCalFiles = getappdata(handles.mainpanel,'tipCalFiles');
toolIdx = get(handles.toolid,'Value');

% % for debugging, show tip calibration data
% tipCalData = getappdata(handles.mainpanel,'tipCalData');
% tipCalData

% put tool definition file into correct box
fullPathStr = toolDefFiles{toolIdx,1};
if(isempty(fullPathStr))
    set(handles.tooldeffile,'String','No tool definition file selected!');
else
    lastSlashIdx = find(fullPathStr == '\',1,'last');
    if(~isempty(lastSlashIdx))
        set(handles.tooldeffile,'String',fullPathStr(lastSlashIdx+1:end));
    else
        set(handles.tooldeffile,'String',fullPathStr);
    end
end

% set radio buttons appropriately
thisToolType = toolDefFiles{toolIdx,2};
switch(thisToolType)
    case 'D'
        set(handles.rbdynamic,'Value',1);
        set(handles.rbstatic,'Value',0);
    case 'S'
        set(handles.rbstatic,'Value',1);
        set(handles.rbdynamic,'Value',0);
    otherwise  % set radio buttons to dynamic by default
        set(handles.rbdynamic,'Value',1);
        set(handles.rbstatic,'Value',0);
end

% put tip calibration file into correct box
tipCalFullPathStr = tipCalFiles{toolIdx};
if(isempty(tipCalFullPathStr))
    set(handles.tipcalfile,'String','No tip calibration file selected!');
else
    lastSlashIdx = find(tipCalFullPathStr == '\',1,'last');
    if(~isempty(lastSlashIdx))
        set(handles.tipcalfile,'String',tipCalFullPathStr(lastSlashIdx+1:end));
    else
        set(handles.tipcalfile,'String',tipCalFullPathStr);
    end
end

% determine whether we're using tip calibration
doUseTipCal = 0;
for tcfIdx = 1:size(tipCalFiles)
    if( ~isempty(tipCalFiles{tcfIdx}) )
       doUseTipCal = 1; 
    end
end
setappdata(handles.mainpanel,'doUseTipCal',doUseTipCal);

% update GUI
drawnow;

% --- Outputs from this function are returned to the command line.
function varargout = polarisCollectGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connectbutton.
function connectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to connectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable connect button, as well as tool definition and output file
% controls
set(handles.comport,'Enable','off');
disableToolDefChange(hObject, eventdata, handles);
disableOutputFileChange(hObject, eventdata, handles);
set(handles.connectbutton,'Enable','off');
set(handles.rbtrack,'Enable','off');
set(handles.rbid,'Enable','off');
set(handles.nummarkers,'Enable','off');
set(handles.tipbutton,'Enable','off');

% flag for errors in connection
connectError = 0;

% load tool definition files
if(~connectError)
    % make sure tool definition file cell array is the correct size (must be 9x2)
    toolDefFiles = getappdata(handles.mainpanel,'toolDefFiles');
    if (min(size(toolDefFiles) == [9,2]) == 0)
        error('Incorrect tool file definition cell array size.')
    end
    
    % determine which tools are used and format GX() calls appropriately
    toolsUsedMask = ~cellfun(@isempty,toolDefFiles(:,1));
    toolsUsed = find(toolsUsedMask);
    setappdata(handles.mainpanel,'toolsUsed',toolsUsed);
    if(length(toolsUsed) == 0)
        waitfor(msgbox('No tool definition file(s) specified! Load a placeholder tool definition file for tool ID mode.'));
        connectError = 1;
    elseif( max(toolsUsed) < 4 ) % ports A,B,C only
        if( get(handles.rbtrack,'Value') && ~get(handles.rbid,'Value'))
            gx_cmd_str = 'GX:800B';
        elseif( ~get(handles.rbtrack,'Value') && get(handles.rbid,'Value'))
            gx_cmd_str = 'GX:9000';
        else
            error('Invalid collection mode.');
        end
        pstat_cmd_str = 'PSTAT:801f';
    else % ports A-I
        if( get(handles.rbtrack,'Value') && ~get(handles.rbid,'Value'))
            gx_cmd_str = 'GX:A00B';
            pstat_cmd_str = 'PSTAT:A01f';
        else
            waitfor(msgbox('Tool identification supported with tool definition files in ports A, B, and C only.'));
            connectError = 1;
        end
    end
end

% if tool definition files loaded successfully, put GX and PSTAT strings in
% storage
if(~connectError)
    setappdata(handles.mainpanel,'gx_cmd_str',gx_cmd_str);
    setappdata(handles.mainpanel,'pstat_cmd_str',pstat_cmd_str);
end

% attempt to automatically find the serial port if not manually specified
% note: this relies on the serial port descriptor reported by
% the Windows 'chgport' utility
if(~connectError)
    
    % reset MATLAB instrument handles just to be safe
    instrreset();
    
    % figure out which COM port to open
    comPortValues = get(handles.comport,'String');
    SERIAL_COM_PORT = comPortValues{get(handles.comport,'Value')};
    if(strcmp(SERIAL_COM_PORT,'Auto'))
        if(getappdata(handles.mainpanel,'DEBUG_MODE'))
            disp('Attempting to identify correct COM port...');
        end
        %         [~,res]=system('chgport'); % slow!
        [~,res] = system('reg query HKLM\HARDWARE\DEVICEMAP\SERIALCOMM');  % much faster than chgport, ref: https://superuser.com/a/1413756/1131751
        % for debug: res = ['HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM' char(10) '\Device\Serial0    REG_SZ    COM3' char(10) '         \Device\VCP0    REG_SZ    COM1' char(10) '         \Device\VCP1    REG_SZ    COM2']
        % [mat,tok] = regexp(res, '([A-Z0-9]+)[\s=]+([\\A-Za-z]+)[0-9]+','match','tokens');
        % [mat,tok] = regexp(res, '\\Device\\([A-ZA-z]+)[0-9]+\s+REG_SZ\s+([\\A-Za-z]+[0-9]+)','match','tokens');
        [mat,tok] = regexp(res, '\\Device\\VCP[0-9]+\s+REG_SZ\s+([\\A-Za-z]+[0-9]+)','match','tokens');
        comMatches = tok;
        switch length(comMatches)
            case 0
                waitfor(msgbox('COM port not recognized, set manually!'));
                connectError = 1;
            case 1
                if(getappdata(handles.mainpanel,'DEBUG_MODE'))
                    disp(['Detected correct adapter on ' comMatches{1}{1}]);
                end
                SERIAL_COM_PORT = comMatches{1}{1};
            otherwise
                waitfor(msgbox('Multiple devices found, set COM port manually!'));
                connectError = 1;
        end
    end
end
if(getappdata(handles.mainpanel,'DEBUG_MODE'))
    disp('Trying to open COM port');
end
% open COM port using default settings (9600 baud)
if(~connectError)
    SERIAL_TERMINATOR = hex2dec('0D');   % 0x0D = 0d13 = CR
    SERIAL_TIMEOUT    = 0.05;            % [s]
    fidSerial = serial(SERIAL_COM_PORT,'BaudRate',9600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
    warning off MATLAB:serial:fread:unsuccessfulRead;
    fopen(fidSerial)
    setappdata(handles.mainpanel,'fidSerial',fidSerial);
end
if(getappdata(handles.mainpanel,'DEBUG_MODE'))
    disp('Trying to connect to Polaris');
end
% reset Polaris and change baud rate
if(~connectError)
    
    % send a serial break to reset Polaris
    % use instrreset() and instrfind() to deal with ghost MATLAB port handles
    serialbreak(fidSerial, 10);
    pause(1);  % need this to be long(ish) otherwise miss response (1sec seems ok?)
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);  %TODO: Catch serial timeout errors that occurr if attempting to connect via wrong port
    else
        polarisGetResponse(fidSerial);
    end
    
    % produce audible beep as confirmation
    polarisSendCommand(handles,fidSerial, 'BEEP:1',1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
    
    % change communication to 57,600 baud
    polarisSendCommand(handles,fidSerial, 'COMM:40000',1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
    
    % swich MATLAB COM port settings to 57,600 baud
    fclose(fidSerial);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp('SWITCHING PC TO 57,000 BAUD');
    end
    pause(0.5);
    fidSerial = serial(SERIAL_COM_PORT,'BaudRate',57600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
    warning off MATLAB:serial:fread:unsuccessfulRead;
    fopen(fidSerial);
    setappdata(handles.mainpanel,'fidSerial',fidSerial);
    
    % produce audible beeps as confimation
    polarisSendCommand(handles,fidSerial, 'BEEP:2',1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
end

% general Polaris initialization
if(~connectError)
    % initialize system
    polarisSendCommand(handles,fidSerial, 'INIT:',1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
    
    % select volume (doing this blindly without querying volumes first)
    polarisSendCommand(handles,fidSerial, 'VSEL:1',1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
    
    % set illuminator rate to 20Hz
    polarisSendCommand(handles,fidSerial, 'IRATE:0',1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
end

% send tool definition files to Polaris
% tool files can be generated with NDI 6D Architect software
if(~connectError)
    BASE_TOOL_CHAR = getappdata(handles.mainpanel,'BASE_TOOL_CHAR');
    for toolIdx = 1:length(toolsUsed)
        toolNum = toolsUsed(toolIdx);
        thisToolFile = toolDefFiles{toolNum,1};
        toolFileID = fopen(thisToolFile);
        if( isempty(toolFileID) )
            fclose(fidSerial);
            error('Invalid tool file and/or path.');
        end
        
        if(getappdata(handles.mainpanel,'DEBUG_MODE'))
            disp(['INITIALIZING PORT ' char(BASE_TOOL_CHAR+toolNum) ' WITH TOOL FILE: ' thisToolFile(max(strfind(thisToolFile,'\'))+1:end)]);
        end
        
        % read 64-byte clumps from binary file
        [readBytes, numBytes] = fread(toolFileID,64);
        bytePos = 0;
        while (numBytes == 64)
            str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[])];
            polarisSendCommand(handles,fidSerial,str,1);
            if(getappdata(handles.mainpanel,'DEBUG_MODE'))
                disp(['< ' polarisGetResponse(fidSerial)]);
            else
                polarisGetResponse(fidSerial);
            end
            [readBytes, numBytes] = fread(toolFileID,64);
            bytePos = bytePos + 64;
        end
        
        % read any remaining bytes, padding with FF
        if(numBytes > 0)
            str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[]) repmat('FF',1,64-numBytes)];
            polarisSendCommand(handles,fidSerial,str,1);
            if(getappdata(handles.mainpanel,'DEBUG_MODE'))
                disp(['< ' polarisGetResponse(fidSerial)]);
            else
                polarisGetResponse(fidSerial);
            end
        end
        
        % close binary tool file
        fclose(toolFileID);
        
        % initialize port handle for the tool
        polarisSendCommand(handles,fidSerial, ['PINIT:' char(BASE_TOOL_CHAR+toolNum)],1);
        if(getappdata(handles.mainpanel,'DEBUG_MODE'))
            disp(['< ' polarisGetResponse(fidSerial)]);
        else
            polarisGetResponse(fidSerial);
        end
        
        % enable tracking for the tool
        polarisSendCommand(handles,fidSerial, ['PENA:' char(BASE_TOOL_CHAR+toolNum) toolDefFiles{toolNum,2}],1);
        if(getappdata(handles.mainpanel,'DEBUG_MODE'))
            disp(['< ' polarisGetResponse(fidSerial)]);
        else
            polarisGetResponse(fidSerial);
        end
    end
    
    % confirm tool configuration
    polarisSendCommand(handles,fidSerial, pstat_cmd_str,1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
end

% enter tracking mode
if(~connectError)
    polarisSendCommand(handles,fidSerial, 'TSTART:',1);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' polarisGetResponse(fidSerial)]);
    else
        polarisGetResponse(fidSerial);
    end
end

% load output file
if(~connectError)
    
    % get desired output file (full path and filename)
    outputFilePath = getappdata(handles.mainpanel,'outputFilePath');
    
    % if the desired output path is not specificed, default to trial001.csv
    % (or similar)
    if(isempty(outputFilePath))
        
        % try to find trialxxx.csv files in current directory
        [mat,tok] = regexp(string(ls()),'trial([0-9]+).csv','match','tokens');
        newFileIdx = max(arrayfun(@str2num,[tok{:}]))+1;
        if(isempty(newFileIdx))
            newFileIdx = 1;
        end
        
        % replace outputFilePath with correct default filename
        outputFilePath = sprintf('trial%03d.csv',newFileIdx);
        
    elseif(isfile(outputFilePath))
        % desired output file is specified and it already exists
        % if it exists already, we need to add a number
        [mat,tok] = regexp(outputFilePath,'(?:^|\\)([\w\-]+?)([0-9])*(\.\w+)?$','match','tokens');
        if(isempty(tok) || ~prod( size(tok{1}) == [1 3]) )
            tok{1}
            error('Selected filename could not be parsed.');
        end
        newFileIdx = str2num(tok{1}{2})+1;  % don't use str2double here b/c gives NaN rather than [] for null input...
        if(isempty(newFileIdx))
            newFileIdx =1 ;
        end
        pathIdx = find(outputFilePath == '\',1,'last');
        outputFilePath = [outputFilePath(1:pathIdx) tok{1}{1} sprintf('%03d',newFileIdx) tok{1}{3}];
    end
    
    % display the acutal file name being used
    setappdata(handles.mainpanel,'outputFilePath',outputFilePath);
    updateOutputFilePath(hObject, eventdata, handles)
    
    % open the output file
    fidDataOut = fopen(outputFilePath,'w');
    
    % set error flag if file couldn't be opened for writing
    % otherwise store fid for use (writing, closing) elsewhere
    if( fidDataOut == -1 )
        connectError = 1;
    else
        setappdata(handles.mainpanel,'fidDataOut',fidDataOut);
    end
end


% adjust UI to new mode (either error out or prepare to collect)
if(~connectError)
    set(handles.disconnectbutton,'Enable','on');
    set(handles.singlecap,'Enable','on');
    set(handles.startcap,'Enable','on');
    set(handles.startcapvid,'Enable','on');
    set(handles.preview,'Enable','on');
    if(get(handles.rbtrack,'Value') == 1)
        set(handles.capturenote,'Enable','on');
    end
else
    disconnectUIChange(hObject, eventdata, handles);
end

function disconnectUIChange(hObject, eventdata, handles)
set(handles.comport,'Enable','on');
enableToolDefChange(hObject, eventdata, handles);
enableOutputFileChange(hObject, eventdata, handles);
set(handles.connectbutton,'String','Connect');
set(handles.connectbutton,'Enable','on');
set(handles.disconnectbutton,'Enable','off');
set(handles.disconnectbutton,'Enable','off');
set(handles.singlecap,'Enable','off');
set(handles.startcap,'Enable','off');
set(handles.startcapvid,'Enable','off');
set(handles.preview,'Enable','off');
set(handles.capturenote,'Enable','off');
set(handles.rbtrack,'Enable','on');
set(handles.rbid,'Enable','on');

if( ~get(handles.rbtrack,'Value') && get(handles.rbid,'Value'))
    set(handles.nummarkers,'Enable','on');
    set(handles.generateROM,'Enable','on');
end

toolDefFiles = getappdata(handles.mainpanel,'toolDefFiles');
numToolsUsed = nnz(~cellfun(@isempty,toolDefFiles(:,1)));

if( get(handles.rbtrack,'Value') && ~get(handles.rbid,'Value') && numToolsUsed == 1)
    set(handles.tipbutton,'Enable','on');
end

resetToolStatusIndicators(hObject, eventdata, handles);

% --- Executes on button press in disconnectbutton.
function disconnectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to disconnectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fidSerial  = getappdata(handles.mainpanel,'fidSerial');
fidDataOut = getappdata(handles.mainpanel,'fidDataOut');

% fwrite(fidDataOut,'test!');

% close output file
fclose(fidDataOut);

% end tracking
polarisSendCommand(handles,fidSerial, 'TSTOP:',1);
if(getappdata(handles.mainpanel,'DEBUG_MODE'))
    disp(['< ' polarisGetResponse(fidSerial)]);
else
    polarisGetResponse(fidSerial);
end

% close communication
fclose(fidSerial);

% clear FIDs
setappdata(handles.mainpanel,'fidSerial',-1);
setappdata(handles.mainpanel,'fidDataOut',-1);

% update UI controls
set(handles.capturenote,'String','');
disconnectUIChange(hObject, eventdata, handles);


% --- Executes on selection change in toolid.
function toolid_Callback(hObject, eventdata, handles)
% hObject    handle to toolid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns toolid contents as cell array
%        contents{get(hObject,'Value')} returns selected item from toolid

% contents = cellstr(get(hObject,'String'));
% disp(contents{get(hObject,'Value')});

updateToolDefDisplay(hObject, eventdata, handles);





% --- Executes on button press in tooldefbutton.
function tooldefbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tooldefbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.rom','Select Tool Definition File');

if(ischar(file))
    toolDefFiles = getappdata(handles.mainpanel,'toolDefFiles');
    toolIdx = get(handles.toolid,'Value');
    
    toolDefFiles{toolIdx,1} = [path file];
    
    staticVal = get(handles.rbstatic,'Value');
    dynamicVal = get(handles.rbdynamic,'Value');
    
    if(staticVal && ~dynamicVal)
        toolDefFiles{toolIdx,2} = 'S';
    elseif(~staticVal && dynamicVal)
        toolDefFiles{toolIdx,2} = 'D';
    else
        warning('Invalid combination of radio button values!');
    end
    
    setappdata(handles.mainpanel,'toolDefFiles',toolDefFiles);
    
    updateToolDefDisplay(hObject, eventdata, handles);
    
end





% --- Executes on button press in tooldefclearbutton.
function tooldefclearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tooldefclearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

toolDefFiles = getappdata(handles.mainpanel,'toolDefFiles');
toolIdx = get(handles.toolid,'Value');
toolDefFiles{toolIdx,1} = '';
toolDefFiles{toolIdx,2} = '';
setappdata(handles.mainpanel,'toolDefFiles',toolDefFiles);
updateToolDefDisplay(hObject, eventdata, handles);



function tooldeffile_Callback(hObject, eventdata, handles)
% hObject    handle to tooldeffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tooldeffile as text
%        str2double(get(hObject,'String')) returns contents of tooldeffile as a double




% --- Executes on button press in tipcalbutton.
function tipcalbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tipcalbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tipCalFiles = getappdata(handles.mainpanel,'tipCalFiles');
tipCalData = getappdata(handles.mainpanel,'tipCalData');
toolIdx = get(handles.toolid,'Value');
[file,path] = uigetfile('*.tip','Select Tip Calibration File');

if(ischar(file))

    % try to load tipcal file
    tipCalFilename = [path file];    
    tipCalFid = fopen(tipCalFilename,'r');
    tipCalFileData = textscan(tipCalFid,'%f%f%f','delimiter',',');
    fclose(tipCalFid);
    tipCalFileData = [tipCalFileData{:}];
    
    % make sure we actually got reasonable tip cal data from the file
    if( isempty(tipCalFileData) || numel(tipCalFileData) ~= 3 )
        msgbox('Invalid tip cal file!','Error');
    else
        % store tip cal file name and tip cal data
        tipCalFiles{toolIdx,1} = tipCalFilename;
        tipCalData(toolIdx,:) = tipCalFileData;
        setappdata(handles.mainpanel,'tipCalFiles',tipCalFiles);
        setappdata(handles.mainpanel,'tipCalData',tipCalData);
        updateToolDefDisplay(hObject, eventdata, handles);
    end
end


% --- Executes on button press in tipcalclearbutton.
function tipcalclearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tipcalclearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tipCalFiles = getappdata(handles.mainpanel,'tipCalFiles');
tipCalData = getappdata(handles.mainpanel,'tipCalData');
toolIdx = get(handles.toolid,'Value');
tipCalFiles{toolIdx,1} = '';
tipCalData(toolIdx,:) = [0 0 0];
setappdata(handles.mainpanel,'tipCalFiles',tipCalFiles);
setappdata(handles.mainpanel,'tipCalData',tipCalData);
updateToolDefDisplay(hObject, eventdata, handles);




function tipcalfile_Callback(hObject, eventdata, handles)
% hObject    handle to tipcalfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tipcalfile as text
%        str2double(get(hObject,'String')) returns contents of tipcalfile as a double





% --- Executes on button press in singlecap.
function singlecap_Callback(hObject, eventdata, handles)
% hObject    handle to singlecap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.capturenote,'Enable','off');
set(handles.startcap,'Enable','off');
set(handles.startcapvid,'Enable','off');
set(handles.singlecap,'Enable','off');
set(handles.preview,'Enable','off');
set(handles.disconnectbutton,'Enable','off');

% capture a single datapoint
captureStatus = polarisCaptureData(hObject, eventdata, handles);
if(captureStatus)
    msgbox('Error: could not capture any data!');
end

% beep on success
% TODO: add control to disable beep on main GUI panel (for OR)
fidSerial = getappdata(handles.mainpanel,'fidSerial');
polarisSendCommand(handles,fidSerial, 'BEEP:1',1);
if(getappdata(handles.mainpanel,'DEBUG_MODE'))
    disp(['< ' polarisGetResponse(fidSerial)]);
else
    polarisGetResponse(fidSerial);
end

% reset GUI controls
if(get(handles.rbtrack,'Value') == 1)
    set(handles.capturenote,'Enable','on');
end
set(handles.startcap,'Enable','on');
set(handles.startcapvid,'Enable','on');
set(handles.singlecap,'Enable','on');
set(handles.preview,'Enable','on');
set(handles.disconnectbutton,'Enable','on');

% --- Executes on button press in startcap.
function startcap_Callback(hObject, eventdata, handles)
% hObject    handle to startcap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.capturenote,'Enable','off');
set(handles.startcap,'Enable','off');
set(handles.startcapvid,'Enable','off');
set(handles.singlecap,'Enable','off');
set(handles.stopcap,'Enable','on');
set(handles.preview,'Enable','off');
set(handles.disconnectbutton,'Enable','off');
drawnow;

% LOCAL flag to remember to close hyperdeck TCPIP
% probably doesn't need to be defined here
% but doing this anyway for clarity in variable scope
doCloseHyperDecks = 0;

% start
if(getappdata(handles.mainpanel,'send_video_cmd') == 1)
    
    % remember to close HyperDecks
    doCloseHyperDecks = 1;
    
    % reset flag to send video start commands
    setappdata(handles.mainpanel,'send_video_cmd',0);
    
    % set flag to allow tracking
    setappdata(handles.mainpanel,'endTrackingFlag',0);
    
    % Addresses for Left and Right Hyperdecks
    % TODO: this shouldn't be hard coded!!
    % Set PC to 192.168.10.10 (or something similar, netmask 255.255.255.0)
    hyperDeckLeftIP = '192.168.10.50';
    hyperDeckRightIP = '192.168.10.60';
    
    % Send network ping to Hyperdecks to make sure we'll be able to connect
    pingError = 0;
    if( isAlive(hyperDeckLeftIP,100) == 0 )
        warning('Cannot ping LEFT Hyperdeck!');
        pingError = 1;
    else
        disp('Left Hyperdeck ping successful.');
    end
    if( isAlive(hyperDeckRightIP,100) == 0 )
        warning('Cannot ping RIGHT Hyperdeck!');
        pingError = 1;
    else
        disp('Right Hyperdeck ping successful.');
    end
    
    % exit if we got a network ping error
    if(pingError)
        set(handles.capturenote,'Enable','on');
        set(handles.startcap,'Enable','on');
        set(handles.startcapvid,'Enable','on');
        set(handles.singlecap,'Enable','on');
        set(handles.stopcap,'Enable','off');
        set(handles.disconnectbutton,'Enable','on');
        drawnow;
        return;
    end
    
    % create TCPIP objects for each Hyper Deck
    hyperDeckLeft = tcpip(hyperDeckLeftIP,9993);
    hyperDeckRight = tcpip(hyperDeckRightIP,9993);
    
    % open both hyperdeck TCPIP channels
    fopen(hyperDeckLeft);
    fopen(hyperDeckRight);
    if(~strcmp(hyperDeckLeft.status,'open'))
        error('Error opening LEFT HyperDeck TCP/IP channel.');
    end
    if(~strcmp(hyperDeckRight.status,'open'))
        error('Error opening RIGHT HyperDeck TCP/IP channel.');
    end
    
    % flush input and output buffers
    flushinput(hyperDeckLeft);
    flushoutput(hyperDeckLeft);
    flushinput(hyperDeckRight);
    flushoutput(hyperDeckRight);
    
    % send software ping to each Hyperdeck
    fprintf(hyperDeckLeft,'ping\n');
    fprintf(hyperDeckRight,'ping\n');
    respL = fgets(hyperDeckLeft);
    respR = fgets(hyperDeckRight);
    errorVec = zeros(1,2);
    if(isempty(respL) || ~strcmp(respL(1:6),'200 ok'))
        errorVec(1) = 1;
    end
    if(isempty(respR) || ~strcmp(respR(1:6),'200 ok'))
        errorVec(2) = 1;
    end
    if(prod(errorVec))
        error('Software ping to Hyperdeck(s) failed!');
    else
        disp('Software ping to Hyperdecks successful.');
    end
    
    % make sure REMOTE is enabled on each Hyperdeck
    fprintf(hyperDeckLeft,'remote: enable: true\n');
    fprintf(hyperDeckRight,'remote: enable: true\n');
    respL = fgets(hyperDeckLeft);
    respR = fgets(hyperDeckRight);
    disp(['Remote enable LEFT: ' strtrim(char(respL))]);
    disp(['Remote enable RIGHT: ' strtrim(char(respR))]);
    
    fprintf(hyperDeckLeft,'slot select: slot id: 1\n');
    fprintf(hyperDeckRight,'slot select: slot id: 1\n');
    respL = fgets(hyperDeckLeft);
    respR = fgets(hyperDeckRight);
    disp(['Slot 1 select LEFT: ' strtrim(char(respL))]);
    disp(['Slot 1 select RIGHT: ' strtrim(char(respR))]);
    
    % start recording on both Hyper Decks
    % Note: \n seems to work in MATLAB on windows, need \r\n in python
    fprintf(hyperDeckLeft,'record\n');
    fprintf(hyperDeckRight,'record\n');
        
    % get Hyperdeck response to record command
    % TODO: This will add a small delay, find a workaround
    respL = fgets(hyperDeckLeft);
    respR = fgets(hyperDeckRight);
    disp(['Record LEFT: ' strtrim(char(respL))]);
    disp(['Record RIGHT: ' strtrim(char(respR))]);
    
end

% record tracking data until stop button is pressed
while(getappdata(handles.mainpanel,'endTrackingFlag') == 0)
    polarisCaptureData(hObject, eventdata, handles);
    drawnow; % this is key! needs to be here for interruption from stop button to work...
end
setappdata(handles.mainpanel,'endTrackingFlag',0);

% close TCPIP ports
if(doCloseHyperDecks)
    % close comms with hyperdecks
    fclose(hyperDeckLeft);
    fclose(hyperDeckRight);
end

% --- Executes on button press in stopcap.
function stopcap_Callback(hObject, eventdata, handles)
% hObject    handle to stopcap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.mainpanel,'endTrackingFlag',1);
setappdata(handles.mainpanel,'previewFlag',0);

while(getappdata(handles.mainpanel,'endTrackigFlag'))
    % wait until collection actually stops
end

% clear all tools that are displayed in the figures
pointHandles = getappdata(handles.mainpanel,'pointHandles');
for toolNum = 1:9
    pointHandles(toolNum).front.Position = [ NaN, NaN ];
    pointHandles(toolNum).side.Position  = [ NaN, NaN ];
    pointHandles(toolNum).top.Position   = [ NaN, NaN ];
end
setappdata(handles.mainpanel,'pointHandles',pointHandles);

% clear status displays
resetToolStatusIndicators(hObject, eventdata, handles);

% reset GUI
if(get(handles.rbtrack,'Value') == 1)
    set(handles.capturenote,'Enable','on');
end
set(handles.stopcap,'Enable','off');
set(handles.singlecap,'Enable','on');
set(handles.startcap,'Enable','on');
set(handles.startcapvid,'Enable','on');
set(handles.preview,'Enable','on');
set(handles.disconnectbutton,'Enable','on');

function capturenote_Callback(hObject, eventdata, handles)
% hObject    handle to capturenote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of capturenote as text
%        str2double(get(hObject,'String')) returns contents of capturenote as a double





% --- Executes on selection change in comport.
function comport_Callback(hObject, eventdata, handles)
% hObject    handle to comport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comport contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comport




% --- Executes on button press in outputfileselectbutton.
function outputfileselectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to outputfileselectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile('*.csv','Specify output file');
if(ischar(file))
    setappdata(handles.mainpanel,'outputFilePath',[path file]);
end
updateOutputFilePath(hObject, eventdata, handles);

% --- Executes on button press in outputfileclearbutton.
function outputfileclearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to outputfileclearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.mainpanel,'outputFilePath','');
updateOutputFilePath(hObject, eventdata, handles);


function outputfile_Callback(hObject, eventdata, handles)
% hObject    handle to outputfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputfile as text
%        str2double(get(hObject,'String')) returns contents of outputfile as a double

setappdata(handles.mainpanel,'outputFilePath',get(handles.outputfile,'String'));
updateOutputFilePath(hObject, eventdata, handles);



% --- Executes when selected object is changed in tooltyperbs.
function tooltyperbs_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in tooltyperbs
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

toolDefFiles = getappdata(handles.mainpanel,'toolDefFiles');
toolIdx = get(handles.toolid,'Value');

staticVal = get(handles.rbstatic,'Value');
dynamicVal = get(handles.rbdynamic,'Value');

if(staticVal && ~dynamicVal)
    toolDefFiles{toolIdx,2} = 'S';
elseif(~staticVal && dynamicVal)
    toolDefFiles{toolIdx,2} = 'D';
else
    warning('Invalid combination of radio button values!');
end

setappdata(handles.mainpanel,'toolDefFiles',toolDefFiles);

updateToolDefDisplay(hObject, eventdata, handles);

function statusbox_Callback(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of statusbox as text
%        str2double(get(hObject,'String')) returns contents of statusbox as a double



% --- Executes during object creation, after setting all properties.
function tooldeffile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tooldeffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function toolid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toolid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',num2cell(char(64+(1:9))));

% --- Executes during object creation, after setting all properties.
function nummarkers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nummarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',num2cell(3:16));

% --- Executes during object creation, after setting all properties.
function tipcalfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tipcalfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function capturenote_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capturenote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function comport_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function outputfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function statusbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in nummarkers.
function nummarkers_Callback(hObject, eventdata, handles)
% hObject    handle to nummarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nummarkers contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nummarkers





% --- Executes when selected object is changed in capmoderbs.
function capmoderbs_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in capmoderbs
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if( get(handles.rbtrack,'Value') && ~get(handles.rbid,'Value'))
    set(handles.nummarkers,'Enable','off');
elseif( ~get(handles.rbtrack,'Value') && get(handles.rbid,'Value'))
    set(handles.nummarkers,'Enable','on');
end

% send command to Polaris system
function polarisSendCommand(handles,comPortHandle, cmdStr, varargin)

realStr = [cmdStr polarisCRC16(0,cmdStr)];
fprintf(comPortHandle,realStr); % note: terminator added automatically (default fprintf format is %s\n

if(nargin > 3 && varargin{1} == 1)
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['> ' strtrim(cmdStr)]);
    end
end

% read response from Polaris system
function respStr = polarisGetResponse(comPortHandle)

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

function captureStatus = polarisCaptureData(hObject, eventdata, handles)
fidSerial        = getappdata(handles.mainpanel,'fidSerial');
fidDataOut       = getappdata(handles.mainpanel,'fidDataOut');
gx_cmd_str       = getappdata(handles.mainpanel,'gx_cmd_str');
gx_transform_map = getappdata(handles.mainpanel,'gx_transform_map');
toolsUsed        = getappdata(handles.mainpanel,'toolsUsed');
BASE_TOOL_CHAR   = getappdata(handles.mainpanel,'BASE_TOOL_CHAR');
pointHandles     = getappdata(handles.mainpanel,'pointHandles');
previewFlag      = getappdata(handles.mainpanel,'previewFlag');

% get tip cal info
doUseTipCal = getappdata(handles.mainpanel,'doUseTipCal');
tipCalFiles = getappdata(handles.mainpanel,'tipCalFiles');
tipCalData  = getappdata(handles.mainpanel,'tipCalData');

% keep track of whether data acquired, and repeat until it is or we hit a
% timeout
dataValidFlag = 0;
numRetries = 0;

while( ~dataValidFlag && numRetries < 10)
    numRetries = numRetries +1;
    
    % query tool positions
    polarisSendCommand(handles, fidSerial, gx_cmd_str);
    thisResp = polarisGetResponse(fidSerial);
    if(getappdata(handles.mainpanel,'DEBUG_MODE'))
        disp(['< ' thisResp]);
    end
    
    % handle tracking mode
    if( get(handles.rbtrack,'Value') && ~get(handles.rbid,'Value'))
        
        % get the capture note, and remove any commas
        captureNoteString = get(handles.capturenote,'String');
        captureNoteString(regexp(captureNoteString,','))=[];
        
        % get a unix timestamp for sanity check and future use (may want the actual DATE)
        unixtimestamp = posixtime(datetime('now')); % recover with datetime(unixtimestamp,'ConvertFrom','posixtime')
        
        % extract quaternion, position, timestamp, and estimated error for each tool
        respParts = strsplit(thisResp,char(10));
        thisFrameNumStr = respParts{end};
        
        for toolIdx = 1:length(toolsUsed)
            
            % get the tool index and tip offset
            toolNum = toolsUsed(toolIdx);
            x_tip_local = tipCalData(toolNum,:);
            
            % figure out which line the transform data is on
            dataLine = gx_transform_map(toolNum);
            
            % get the transform data
            thisTransformStr = respParts{ dataLine };
            if(length(thisTransformStr) == 51)
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
                
                % determine tip position
                x_tip_global =  t + quatrotate(q,x_tip_local');
                
                % extract error
                err = str2num(thisTransformStr(46:end))/10000;
                
                % extract timestamp
                startIdx = (toolNum-1)*8+1;
                timestamp = hex2dec(thisFrameNumStr(startIdx:startIdx+7))/60;
                
                % display tool tracking information
                if(getappdata(handles.mainpanel,'DEBUG_MODE'))
                    fprintf('%0.4f,%0.2f,%s,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%s\n', timestamp, unixtimestamp, char(BASE_TOOL_CHAR+toolNum), q(1), q(2), q(3), q(4), t(1), t(2), t(3), x_tip_global(1), x_tip_global(2), x_tip_global(3), err, captureNoteString);
                end
                
                % actually write data to file if not in preview mode
                if(~previewFlag)
                    fprintf(fidDataOut,'%0.4f,%0.2f,%s,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%s\n', timestamp, unixtimestamp, char(BASE_TOOL_CHAR+toolNum), q(1), q(2), q(3), q(4), t(1), t(2), t(3), x_tip_global(1), x_tip_global(2), x_tip_global(3), err, captureNoteString);
                end
                
                % plot tool position
                pointHandles(toolNum).front.Position = [ t(2),  -t(1) ];
                pointHandles(toolNum).side.Position  = [ -t(3), -t(1) ];
                pointHandles(toolNum).top.Position   = [ -t(3), -t(2) ];
                
                % flag this as valid data
                dataValidFlag = 1;
            else
                % plot tool position
                pointHandles(toolNum).front.Position = [ NaN, NaN ];
                pointHandles(toolNum).side.Position  = [ NaN, NaN ];
                pointHandles(toolNum).top.Position   = [ NaN, NaN ];
                
                % TODO: MAKE THIS MORE ROBUST, FAILS IF transform result is 'MISSING'
                %warning(['Tool ' char(BASE_TOOL_CHAR+toolNum) ' unexpected transform result: ' thisTransformStr]);
            end
            
            % get the volume status (in, partially out, out)
            volStatusLine = dataLine + (4-mod(dataLine-1,4));
            thisVolStatusStr = respParts{ volStatusLine };
            volStatusCode = thisVolStatusStr((9-2*((mod(toolNum-1,3)+1))));
            
            % set the status indicator on the GUI appropriately
            toolStatusColor = [0 0 0];
            if( strcmp(volStatusCode,'7') )
                % out of volume
                toolStatusColor = setToolStatusIndicator(toolNum,2,handles);
                pointHandles(toolNum).front.Color = toolStatusColor;
                pointHandles(toolNum).side.Color = toolStatusColor;
                pointHandles(toolNum).top.Color = toolStatusColor;
            elseif( strcmp(volStatusCode,'B') )
                % partially out of volume
                toolStatusColor = setToolStatusIndicator(toolNum,1,handles);
                pointHandles(toolNum).front.Color = toolStatusColor;
                pointHandles(toolNum).side.Color = toolStatusColor;
                pointHandles(toolNum).top.Color = toolStatusColor;
            elseif( strcmp(volStatusCode,'3') )
                % potentially in volume
                % need to make sure the "too few markers" flag isn't set
                thisMarkerStatusStr = respParts{ end-1 };
                thisMarkerStatusHexDigit = thisMarkerStatusStr(10+12*(toolNum-1));
                if(bitand(hex2dec(thisMarkerStatusHexDigit),bin2dec('0010')))
                    % too few markers
                    toolStatusColor = setToolStatusIndicator(toolNum,3,handles);
                else
                    % tracking OK, turn indicator green
                    toolStatusColor = setToolStatusIndicator(toolNum,0,handles);
                    pointHandles(toolNum).front.Color = toolStatusColor;
                    pointHandles(toolNum).side.Color = toolStatusColor;
                    pointHandles(toolNum).top.Color = toolStatusColor;
                end
            else
                warning(['Unsupported tool status code: ' volStatusCode]);
                %warning(thisVolStatusStr);
            end
            
        end
    elseif( ~get(handles.rbtrack,'Value') && get(handles.rbid,'Value'))
        % handle tool identification mode
        drawnow;
        [match,tok] = regexp(thisResp,'([+-]+[0-9]+)','match','tokens');
        
        % determine how many markers we should see
        numMarkersList = get(handles.nummarkers,'String');
        numMarkers = str2num(numMarkersList{get(handles.nummarkers,'Value')});
        
        if(length(tok) == (3*numMarkers+1) )
            tokMat = cellfun(@str2num,[tok{2:end}])/100;
            outFormatStr = repmat('%+0.4f,',1,length(tokMat));
            outFormatStr = [outFormatStr(1:end-1) '\n'];
            fprintf(fidDataOut,outFormatStr,tokMat);
            
            % increment frame counter
            validFrameCount = getappdata(handles.mainpanel,'validFrameCount') + 1;
            set(handles.frameCount,'String',num2str(validFrameCount));
            setappdata(handles.mainpanel,'validFrameCount',validFrameCount);
            
            % flag this as valid data
            dataValidFlag = 1;
        end
    end
end

if(~dataValidFlag)
    captureStatus = -1;
else
    captureStatus = 0;
end


% --- Executes on button press in status_a.
function status_a_Callback(hObject, eventdata, handles)
% hObject    handle to status_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_b.
function status_b_Callback(hObject, eventdata, handles)
% hObject    handle to status_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_c.
function status_c_Callback(hObject, eventdata, handles)
% hObject    handle to status_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_d.
function status_d_Callback(hObject, eventdata, handles)
% hObject    handle to status_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_e.
function status_e_Callback(hObject, eventdata, handles)
% hObject    handle to status_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_f.
function status_f_Callback(hObject, eventdata, handles)
% hObject    handle to status_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_g.
function status_g_Callback(hObject, eventdata, handles)
% hObject    handle to status_g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_h.
function status_h_Callback(hObject, eventdata, handles)
% hObject    handle to status_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in status_i.
function status_i_Callback(hObject, eventdata, handles)
% hObject    handle to status_i (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in label_track.
function label_track_Callback(hObject, eventdata, handles)
% hObject    handle to label_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in label_poov.
function label_poov_Callback(hObject, eventdata, handles)
% hObject    handle to label_poov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in label_oov.
function label_oov_Callback(hObject, eventdata, handles)
% hObject    handle to label_oov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in label_toofew.
function label_toofew_Callback(hObject, eventdata, handles)
% hObject    handle to label_toofew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in label_notload.
function label_notload_Callback(hObject, eventdata, handles)
% hObject    handle to label_notload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in startcapvid.
function startcapvid_Callback(hObject, eventdata, handles)
% hObject    handle to startcapvid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.mainpanel,'send_video_cmd',1);
startcap_Callback(hObject, eventdata, handles);



function frameCount_Callback(hObject, eventdata, handles)
% hObject    handle to frameCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameCount as text
%        str2double(get(hObject,'String')) returns contents of frameCount as a double


% --- Executes during object creation, after setting all properties.
function frameCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in generateROM.
function generateROM_Callback(hObject, eventdata, handles)
% hObject    handle to generateROM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    disp('Launching ROM generation script...');
    discoverCollarA(get(handles.outputfile,'String'));
catch ME
    msgbox('Error in ROM generation function!');
    rethrow(ME);
end

% perform quaternion rotation
% essentially using angle (theta) and axis (u, a unit vector) of rotation
% q =     q0     +     q123
% q = cos(theta) + sin(theta)*u
% note: MATLAB includes a similar function in the aerospace toolbox, but
% this is not part of the Dartmouth site license
function v_out = quatrotate(q_in,v_in)

% extract scalar and vector parts of quaternion
q0   = q_in(1);   % real (scalar) part of quaternion
q123 = q_in(2:4); % imaginary (vector) part of quaternion

% rotate v_in using point rotation: v_out = q * v_in * conj(q)
% q_out = quatmult(q_in,quatmult([0; v_in],quatconj(q_in)))
% v_out = q_out(2:4)
% Simplification from Kuipers2002: Quaternions and Rotation Sequences: A Primer with Applications to Orbits, Aerospace and Virtual Reality
v_out = (q0^2-norm(q123)^2)*v_in + 2*dot(q123,v_in)*q123 + 2*q0*cross(q123,v_in);

% function to test Hyperdeck connection
% passes timout (ms) to ping
function status = isAlive(ipAddr,timeout)
[~,sysOut] = system(['ping -n 1 -w ' num2str(timeout) ' ' ipAddr ' | grep ''% loss'' | sed ''s/.*(\(.*\)\% loss),/\1/''']);
if(str2num(sysOut) == 0)
    status = 1;
else
    status = 0;
end

% --- Executes on button press in tipbutton.
function tipbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tipbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
infile = get(handles.outputfile,'String');
[~,tok] = regexp(infile,'(\w+).csv','match','tokens');
if(length(tok) == 1)
    outfile = [tok{1}{1} '.tip'];
else
    outfile = [infile '.tip'];
end
ndi_optical_probe_tip_cal_numerical(infile,1,1,outfile);


% --- Executes on button press in preview.
function preview_Callback(hObject, eventdata, handles)
% hObject    handle to preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.mainpanel,'previewFlag',1);
startcap_Callback(hObject, eventdata, handles);
