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

% Last Modified by GUIDE v2.5 14-Mar-2019 13:16:29

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

% configure various UI components
updateOutputFilePath(hObject, eventdata, handles);
updateToolDefDisplay(hObject, eventdata, handles);
set(handles.disconnectbutton,'Enable','off');
set(handles.startcap,'Enable','off');
set(handles.stopcap,'Enable','off');
set(handles.singlecap,'Enable','off');
set(handles.capturenote,'Enable','off');

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

set(handles.comport,'Enable','off');
disableToolDefChange(hObject, eventdata, handles);
disableOutputFileChange(hObject, eventdata, handles);
set(handles.connectbutton,'Enable','off');

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

% now try to actually connect to device
if(~connectError)
    % nop
end

%TODO: implement this, chunk by chunk
% % % % % make sure tool definition file cell array is the correct size (must be
% % % % % 9x2)
% % % % if (min(size(toolDefFiles) == [9,2]) == 0)
% % % %     error('Incorrect tool file definition cell array size.')
% % % % end
% % % % 
% % % % % determine which tools are used and format GX() calls appropriately
% % % % toolsUsedMask = ~cellfun(@isempty,toolDefFiles(:,1));
% % % % toolsUsed = find(toolsUsedMask);
% % % % if( max(toolsUsed) < 4 )
% % % %     extended_flag = 0;
% % % %     switch(COLLECT_MODE)
% % % %         case 0
% % % %             gx_cmd_str = 'GX:800B';
% % % %         case 1
% % % %             gx_cmd_str = 'GX:9000';
% % % %     end
% % % %     pstat_cmd_str = 'PSTAT:801f';
% % % % else
% % % %     extended_flag = 1;
% % % %     gx_cmd_str = 'GX:A00B';
% % % %     pstat_cmd_str = 'PSTAT:A01f';
% % % % end
% % % % 
% % % % % reset MATLAB instrument handles just to be safe
% % % % instrreset();
% % % % 
% % % % % attempt to automatically find the serial port if not manually specified
% % % % % note: this relies on the serial port descriptor reported by
% % % % % the Windows 'chgport' utility
% % % % if(strcmp(SERIAL_COM_PORT,''))
% % % %     disp('Attempting to identify correct COM port...');
% % % %     [~,res]=system('chgport');
% % % %     [mat,tok] = regexp(res, '([A-Z0-9]+)[\s=]+([\\A-Za-z]+)[0-9]+','match','tokens');
% % % %     comMatches = {};
% % % %     for i = 1:length(tok)
% % % %         if( strcmp(tok{i}{2},'\Device\ProlificSerial') )
% % % %             comMatches{end+1} = tok{i}{1};
% % % %         end
% % % %     end
% % % %     switch length(comMatches)
% % % %         case 0
% % % %             error('COM port not found, set manually!');
% % % %         case 1
% % % %             disp(['Detected correct adapter on ' comMatches{1}]);
% % % %             SERIAL_COM_PORT = comMatches{1};
% % % %         otherwise
% % % %             error('Multiple ''ProlificSerial'' devices found, set COM port manually!');
% % % %     end
% % % % end
% % % % 
% % % % % open COM port using default settings (9600 baud)
% % % % fid1 = serial(SERIAL_COM_PORT,'BaudRate',9600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
% % % % warning off MATLAB:serial:fread:unsuccessfulRead;
% % % % fopen(fid1);
% % % % 
% % % % % send a serial break to reset Polaris
% % % % % use instrreset() and instrfind() to deal with ghost MATLAB port handles
% % % % serialbreak(fid1, 10);
% % % % pause(1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % pause(1);
% % % % 
% % % % % produce audible beep as confirmation
% % % % polarisSendCommand(fid1, 'BEEP:1',1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % 
% % % % % change communication to 57,600 baud
% % % % polarisSendCommand(fid1, 'COMM:40000',1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % 
% % % % % swich MATLAB COM port settings to 57,600 baud
% % % % fclose(fid1);
% % % % disp('SWITCHING PC TO 57,000 BAUD');
% % % % pause(0.5);
% % % % fid1 = serial(SERIAL_COM_PORT,'BaudRate',57600,'Timeout',SERIAL_TIMEOUT,'Terminator',SERIAL_TERMINATOR);
% % % % warning off MATLAB:serial:fread:unsuccessfulRead;
% % % % fopen(fid1);
% % % % 
% % % % % produce audible beeps as confimation
% % % % polarisSendCommand(fid1, 'BEEP:2',1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % 
% % % % % initialize system
% % % % polarisSendCommand(fid1, 'INIT:',1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % 
% % % % % select volume (doing this blindly without querying volumes first)
% % % % polarisSendCommand(fid1, 'VSEL:1',1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % 
% % % % % set illuminator rate to 20Hz
% % % % polarisSendCommand(fid1, 'IRATE:0',1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % 
% % % % % send tool definition files to Polaris
% % % % % tool files can be generated with NDI 6D Architect software
% % % % for toolIdx = 1:length(toolsUsed)
% % % %     toolNum = toolsUsed(toolIdx);
% % % %     thisToolFile = toolDefFiles{toolNum,1};
% % % %     toolFileID = fopen(thisToolFile);
% % % %     if( isempty(toolFileID) )
% % % %         fclose(fid1);
% % % %         error('Invalid tool file and/or path.');
% % % %     end
% % % %     disp(['INITIALIZING PORT ' char(BASE_TOOL_CHAR+toolNum) ' WITH TOOL FILE: ' thisToolFile(max(strfind(thisToolFile,'\'))+1:end)]);
% % % %     
% % % %     % read 64-byte clumps from binary file
% % % %     [readBytes, numBytes] = fread(toolFileID,64);
% % % %     bytePos = 0;
% % % %     while (numBytes == 64)
% % % %         str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[])];
% % % %         polarisSendCommand(fid1,str,1);
% % % %         disp(['< ' polarisGetResponse(fid1)]);
% % % %         [readBytes, numBytes] = fread(toolFileID,64);
% % % %         bytePos = bytePos + 64;
% % % %     end
% % % %     
% % % %     % read any remaining bytes, padding with FF
% % % %     if(numBytes > 0)
% % % %         str = ['PVWR:' char(BASE_TOOL_CHAR+toolNum) dec2hex(bytePos,4) reshape(dec2hex(readBytes,2)',1,[]) repmat('FF',1,64-numBytes)];
% % % %         polarisSendCommand(fid1,str,1);
% % % %         disp(['< ' polarisGetResponse(fid1)]);
% % % %     end
% % % %     
% % % %     % close binary tool file
% % % %     fclose(toolFileID);
% % % %     
% % % %     % initialize port handle for the tool
% % % %     polarisSendCommand(fid1, ['PINIT:' char(BASE_TOOL_CHAR+toolNum)],1);
% % % %     disp(['< ' polarisGetResponse(fid1)]);
% % % %     
% % % %     % enable tracking for the tool
% % % %     polarisSendCommand(fid1, ['PENA:' char(BASE_TOOL_CHAR+toolNum) toolDefFiles{toolNum,2}],1);
% % % %     disp(['< ' polarisGetResponse(fid1)]);
% % % % end
% % % % 
% % % % % confirm tool configuration
% % % % polarisSendCommand(fid1, pstat_cmd_str,1);
% % % % disp(['< ' polarisGetResponse(fid1)]);
% % % % 
% % % % % enter tracking mode
% % % % polarisSendCommand(fid1, 'TSTART:',1);
% % % % disp(['< ' polarisGetResponse(fid1)]);





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

% --- Executes on button press in disconnectbutton.
function disconnectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to disconnectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disconnectUIChange(hObject, eventdata, handles);
fidDataOut = getappdata(handles.mainpanel,'fidDataOut');
fwrite(fidDataOut,'test!');
fclose(fidDataOut);


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

% DO STUFF
pause(0.5);
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

