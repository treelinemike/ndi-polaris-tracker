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

% Last Modified by GUIDE v2.5 15-Mar-2019 11:07:22

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
% toolDefFiles{1,1} = 'test 1: should be static';
% toolDefFiles{1,2} = 'S';
% toolDefFiles{2,1} = 'test 2: should be dynamic';
% toolDefFiles{2,2} = 'D';
setappdata(handles.mainpanel,'toolDefFiles',toolDefFiles);
setappdata(handles.mainpanel,'outputFilePath','');
setappdata(handles.mainpanel,'fidDataOut',-1);
setappdata(handles.mainpanel,'fidSerial',-1);
setappdata(handles.mainpanel,'gx_cmd_str','');
setappdata(handles.mainpanel,'pstat_cmd_str','');
setappdata(handles.mainpanel,'BASE_TOOL_CHAR',64);
setappdata(handles.mainpanel,'toolsUsed',[]);
setappdata(handles.mainpanel,'gx_transform_map',[6 7 8 10 11 12 14 15 16]);

% configure various UI components
updateOutputFilePath(hObject, eventdata, handles);
updateToolDefDisplay(hObject, eventdata, handles);
set(handles.disconnectbutton,'Enable','off');
set(handles.startcap,'Enable','off');
set(handles.stopcap,'Enable','off');
set(handles.singlecap,'Enable','off');
set(handles.capturenote,'Enable','off');
set(handles.nummarkers,'Enable','off');

% tip calibration not implemented yet...
set(handles.tipcalbutton,'Enable','off');
set(handles.tipcalclearbutton,'Enable','off');

% UIWAIT makes polarisCollectGUI wait for user response (see UIRESUME)
% uiwait(handles.mainpanel);

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
%TODO: uncomment these lines when tip calibration is implemented
%set(handles.tipcalbutton,'Enable','on');
%set(handles.tipcalclearbutton,'Enable','on');

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
toolIdx = get(handles.toolid,'Value');

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

% flag for errors in connection
connectError = 0;

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
        [mat,tok] = regexp(outputFilePath,'(?:^|\\)(\w+?)([0-9])*(\.\w+)$','match','tokens');
        if(isempty(tok) || ~prod( size(tok{1}) == [1 3]) )
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
    if( max(toolsUsed) < 4 ) % ports A,B,C only
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
        else
            error('Load only one tool definiton file for tool identification.');
        end
        pstat_cmd_str = 'PSTAT:A01f';
    end
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
        disp('Attempting to identify correct COM port...');
        [~,res]=system('chgport');
        [mat,tok] = regexp(res, '([A-Z0-9]+)[\s=]+([\\A-Za-z]+)[0-9]+','match','tokens');
        comMatches = {};
        for i = 1:length(tok)
            if( strcmp(tok{i}{2},'\Device\ProlificSerial') )
                comMatches{end+1} = tok{i}{1};
            end
        end
        switch length(comMatches)
            case 0
                error('COM port not found, set manually!');
            case 1
                disp(['Detected correct adapter on ' comMatches{1}]);
                SERIAL_COM_PORT = comMatches{1};
            otherwise
                error('Multiple ''ProlificSerial'' devices found, set COM port manually!');
        end
    end
    
    
    % open COM port using default settings (9600 baud)
    SERIAL_TERMINATOR = hex2dec('0D');   % 0x0D = 0d13 = CR
    SERIAL_TIMEOUT    = 0.05;            % [s]
    fidSerial = serial(SERIAL_COM_PORT,'BaudRate',9600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
    warning off MATLAB:serial:fread:unsuccessfulRead;
    fopen(fidSerial)
    setappdata(handles.mainpanel,'fidSerial',fidSerial);
end

% reset Polaris and change baud rate
if(~connectError)
    
    % send a serial break to reset Polaris
    % use instrreset() and instrfind() to deal with ghost MATLAB port handles
    serialbreak(fidSerial, 10);
    pause(1);
    disp(['< ' polarisGetResponse(fidSerial)]);
    
    % produce audible beep as confirmation
    polarisSendCommand(fidSerial, 'BEEP:1',1);
    disp(['< ' polarisGetResponse(fidSerial)]);
    
    % change communication to 57,600 baud
    polarisSendCommand(fidSerial, 'COMM:40000',1);
    disp(['< ' polarisGetResponse(fidSerial)]);
    
    % swich MATLAB COM port settings to 57,600 baud
    fclose(fidSerial);
    disp('SWITCHING PC TO 57,000 BAUD');
    pause(0.5);
    fidSerial = serial(SERIAL_COM_PORT,'BaudRate',57600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
    warning off MATLAB:serial:fread:unsuccessfulRead;
    fopen(fidSerial);
    setappdata(handles.mainpanel,'fidSerial',fidSerial);
    
    % produce audible beeps as confimation
    polarisSendCommand(fidSerial, 'BEEP:2',1);
    disp(['< ' polarisGetResponse(fidSerial)]);
end

% general Polaris initialization
if(~connectError)
    % initialize system
    polarisSendCommand(fidSerial, 'INIT:',1);
    disp(['< ' polarisGetResponse(fidSerial)]);
    
    % select volume (doing this blindly without querying volumes first)
    polarisSendCommand(fidSerial, 'VSEL:1',1);
    disp(['< ' polarisGetResponse(fidSerial)]);
    
    % set illuminator rate to 20Hz
    polarisSendCommand(fidSerial, 'IRATE:0',1);
    disp(['< ' polarisGetResponse(fidSerial)]);
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
        disp(['INITIALIZING PORT ' char(BASE_TOOL_CHAR+toolNum) ' WITH TOOL FILE: ' thisToolFile(max(strfind(thisToolFile,'\'))+1:end)]);
        
        % read 64-byte clumps from binary file
        [readBytes, numBytes] = fread(toolFileID,64);
        bytePos = 0;
        while (numBytes == 64)
            str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[])];
            polarisSendCommand(fidSerial,str,1);
            disp(['< ' polarisGetResponse(fidSerial)]);
            [readBytes, numBytes] = fread(toolFileID,64);
            bytePos = bytePos + 64;
        end
        
        % read any remaining bytes, padding with FF
        if(numBytes > 0)
            str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[]) repmat('FF',1,64-numBytes)];
            polarisSendCommand(fidSerial,str,1);
            disp(['< ' polarisGetResponse(fidSerial)]);
        end
        
        % close binary tool file
        fclose(toolFileID);
        
        % initialize port handle for the tool
        polarisSendCommand(fidSerial, ['PINIT:' char(BASE_TOOL_CHAR+toolNum)],1);
        disp(['< ' polarisGetResponse(fidSerial)]);
        
        % enable tracking for the tool
        polarisSendCommand(fidSerial, ['PENA:' char(BASE_TOOL_CHAR+toolNum) toolDefFiles{toolNum,2}],1);
        disp(['< ' polarisGetResponse(fidSerial)]);
    end
    
    % confirm tool configuration
    polarisSendCommand(fidSerial, pstat_cmd_str,1);
    disp(['< ' polarisGetResponse(fidSerial)]);
end

% enter tracking mode
if(~connectError)
    polarisSendCommand(fidSerial, 'TSTART:',1);
    disp(['< ' polarisGetResponse(fidSerial)]);
end

% adjust UI to new mode (either error out or prepare to collect)
if(~connectError)
    set(handles.disconnectbutton,'Enable','on');
    set(handles.singlecap,'Enable','on');
    set(handles.startcap,'Enable','on');
    set(handles.capturenote,'Enable','on');
    
    % TEST CODE... THIS NEEDS TO BE REMOVED
    % msgbox(handles.comport.String{handles.comport.Value});
    % set(handles.connectbutton,'String','Disconnect');
    for i = 1:10
        
        handles.statusbox.String = [handles.statusbox.String;{num2str(i)}];
        %    handles.statusbox.Value = i;
        handles.statusbox.Value = length(handles.statusbox.String);
        
        %     if(isempty(handles.statusbox.String))
        %         handles.statusbox.String = {num2str(i)};
        %     else
        %         disp(['Trying: ' ]);
        %         [handles.statusbox.String; {num2str(i)}]
        %         handles.statusbox.String = [handles.statusbox.String; {num2str(i)}];
        %     end
        %     set(handles.statusbox,'String',[handles.statusbox.String char(10) num2str(i)]);
        drawnow;
        pause(0.1);
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
set(handles.capturenote,'Enable','off');
set(handles.rbtrack,'Enable','on');
set(handles.rbid,'Enable','on');

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
polarisSendCommand(fidSerial, 'TSTOP:',1);
disp(['< ' polarisGetResponse(fidSerial)]);

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
        disp('Invalid combination of radio button values!');
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


% --- Executes on button press in tipcalclearbutton.
function tipcalclearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to tipcalclearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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
set(handles.singlecap,'Enable','off');
set(handles.disconnectbutton,'Enable','off');

fidSerial        = getappdata(handles.mainpanel,'fidSerial');
fidDataOut       = getappdata(handles.mainpanel,'fidDataOut');
gx_cmd_str       = getappdata(handles.mainpanel,'gx_cmd_str');
gx_transform_map = getappdata(handles.mainpanel,'gx_transform_map');
toolsUsed        = getappdata(handles.mainpanel,'toolsUsed');
BASE_TOOL_CHAR   = getappdata(handles.mainpanel,'BASE_TOOL_CHAR')

% get the capture note, and remove any commas
captureNoteString = get(handles.capturenote,'String');
captureNoteString(regexp(captureNoteString,','))=[];

% query tool positions
polarisSendCommand(fidSerial, gx_cmd_str);
thisResp = polarisGetResponse(fidSerial);
disp(['< ' thisResp]);
        
% get a unix timestamp for sanity check and future use (may want the actual DATE)
unixtimestamp = posixtime(datetime('now')); % recover with datetime(unixtimestamp,'ConvertFrom','posixtime')
        
% extract quaternion, position, timestamp, and estimated error for each tool
respParts = strsplit(thisResp,char(10));
thisStatusStr = respParts{end};

for toolIdx = 1:length(toolsUsed)
    toolNum = toolsUsed(toolIdx);
    thisTransformStr = respParts{ gx_transform_map(toolNum) };
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
        
        % extract error
        err = str2num(thisTransformStr(46:end))/10000;
        
        % extract timestamp
        startIdx = (toolNum-1)*8+1;
        timestamp = hex2dec(thisStatusStr(startIdx:startIdx+7))/60;
        
        % display tool tracking information
        fprintf('%0.4f,%0.2f,%s,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.2f,%+0.2f,%+0.2f,%+0.4f,%s\n', timestamp, unixtimestamp, char(BASE_TOOL_CHAR+toolNum), q(1), q(2), q(3), q(4), t(1), t(2), t(3), err, captureNoteString);
        fprintf(fidDataOut,'%0.4f,%0.2f,%s,%+0.4f,%+0.4f,%+0.4f,%+0.4f,%+0.2f,%+0.2f,%+0.2f,%+0.4f,%s\n', timestamp, unixtimestamp, char(BASE_TOOL_CHAR+toolNum), q(1), q(2), q(3), q(4), t(1), t(2), t(3), err, captureNoteString);
    else
        disp(['Tool ' char(BASE_TOOL_CHAR+toolNum) ' unexpected transform result: ' thisTransformStr]);
    end
end

% reset GUI controls
set(handles.capturenote,'Enable','on');
set(handles.startcap,'Enable','on');
set(handles.singlecap,'Enable','on');
set(handles.disconnectbutton,'Enable','on');

% --- Executes on button press in startcap.
function startcap_Callback(hObject, eventdata, handles)
% hObject    handle to startcap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.capturenote,'Enable','off');
set(handles.startcap,'Enable','off');
set(handles.singlecap,'Enable','off');
set(handles.stopcap,'Enable','on');
set(handles.disconnectbutton,'Enable','off');




% --- Executes on button press in stopcap.
function stopcap_Callback(hObject, eventdata, handles)
% hObject    handle to stopcap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.capturenote,'Enable','on');
set(handles.stopcap,'Enable','off');
set(handles.singlecap,'Enable','on');
set(handles.startcap,'Enable','on');
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
    disp('Invalid combination of radio button values!');
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
function polarisSendCommand(comPortHandle, cmdStr, varargin)

realStr = [cmdStr polarisCRC16(0,cmdStr)];
fprintf(comPortHandle,realStr); % note: terminator added automatically (default fprintf format is %s\n

if(nargin > 2 && varargin{1} == 1)
    disp(['> ' strtrim(cmdStr)]);
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