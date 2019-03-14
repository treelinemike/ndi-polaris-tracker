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

% Last Modified by GUIDE v2.5 14-Mar-2019 10:02:40

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
setappdata(handles.connectbutton,'status',0);

% UIWAIT makes polarisCollectGUI wait for user response (see UIRESUME)
% uiwait(handles.mainpanel);

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


function updateToolDefDisplay(hObject, eventdata, handles)
toolDefFiles = getappdata(handles.mainpanel,'toolDefFiles');
toolIdx = get(handles.toolid,'Value');

% put tool definition file into correct box
fullPathStr = toolDefFiles{toolIdx,1};
lastSlashIdx = find(fullPathStr == '\',1,'last');
if(~isempty(lastSlashIdx))
    set(handles.tooldeffile,'String',fullPathStr(lastSlashIdx+1:end));
else
    set(handles.tooldeffile,'String',fullPathStr);
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
        disp(['Unexpected tool type in structure: ' thisToolType]);
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

if(getappdata(handles.connectbutton,'status') == 0)
    set(handles.comport,'Enable','off');
    disableToolDefChange(hObject, eventdata, handles);
    set(handles.connectbutton,'String','Disconnect');
    setappdata(handles.connectbutton,'status',1);
else
    set(handles.comport,'Enable','on');
    enableToolDefChange(hObject, eventdata, handles);
    set(handles.connectbutton,'String','Connect');
    setappdata(handles.connectbutton,'status',0);
end


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


% --- Executes on selection change in toolid.
function toolid_Callback(hObject, eventdata, handles)
% hObject    handle to toolid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns toolid contents as cell array
%        contents{get(hObject,'Value')} returns selected item from toolid

updateToolDefDisplay(hObject, eventdata, handles);

contents = cellstr(get(hObject,'String'));
disp(contents{get(hObject,'Value')});

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


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


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



function statusbox_Callback(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of statusbox as text
%        str2double(get(hObject,'String')) returns contents of statusbox as a double


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



function capturenote_Callback(hObject, eventdata, handles)
% hObject    handle to capturenote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of capturenote as text
%        str2double(get(hObject,'String')) returns contents of capturenote as a double


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


% --- Executes on selection change in comport.
function comport_Callback(hObject, eventdata, handles)
% hObject    handle to comport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comport contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comport


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


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function outputfile_Callback(hObject, eventdata, handles)
% hObject    handle to outputfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputfile as text
%        str2double(get(hObject,'String')) returns contents of outputfile as a double


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


