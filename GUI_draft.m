function varargout = GUI_draft(varargin)
% GUI_DRAFT MATLAB code for GUI_draft.fig
%      GUI_DRAFT, by itself, creates a new GUI_DRAFT or raises the existing
%      singleton*.
%
%      H = GUI_DRAFT returns the handle to a new GUI_DRAFT or the handle to
%      the existing singleton*.
%
%      GUI_DRAFT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DRAFT.M with the given input arguments.
%
%      GUI_DRAFT('Property','Value',...) creates a new GUI_DRAFT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_draft_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_draft_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_draft

% Last Modified by GUIDE v2.5 24-Oct-2022 03:10:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_draft_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_draft_OutputFcn, ...
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

% --- Executes just before GUI_draft is made visible.
function GUI_draft_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_draft (see VARARGIN)

% Choose default command line output for GUI_draft
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GUI_draft.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes GUI_draft wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_draft_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

cla
axes(handles.axes1); 
L1 = Link('d',0.1807,'a',0,'alpha',pi/2,'offset',0,'qlim',[deg2rad(-360),deg2rad(360)]); 
L2 = Link('d',0,'a',-0.6127,'alpha',0,'offset',0,'qlim',[deg2rad(-90),deg2rad(90)]); 
L3 = Link('d',0,'a',-0.57155,'alpha',0,'offset',0,'qlim',[deg2rad(-170),deg2rad(170)]); 
L4 = Link('d',0.17415,'a',0,'alpha',pi/2,'offset',0,'qlim',[deg2rad(-360),deg2rad(360)]); 
L5 = Link('d',0.11985,'a',0,'alpha',-pi/2,'offset',0,'qlim',[deg2rad(-360),deg2rad(360)]); 
L6 = Link('d',0.11655,'a',0,'alpha',0,'offset',0,'qlim',[deg2rad(-360),deg2rad(360)]); 
model = SerialLink([L1 L2 L3 L4 L5 L6],'name','UR10'); 
for linkIndex = 0:model.n 
    [ faceData, vertexData, plyData{linkIndex+1} ] = plyread(['UR10Link',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>         
    model.faces{linkIndex+1} = faceData; 
    model.points{linkIndex+1} = vertexData; 
end 
% Display robot 
workspace = [-2 2 -2 2 -0.3 2];    
model.plot3d(zeros(1,model.n),'noarrow','workspace',workspace); 
if isempty(findobj(get(gca,'Children'),'Type','Light')) 
    camlight 
end   
model.delay = 0; 
% Try to correctly colour the arm (if colours are in ply file data) 
for linkIndex = 0:model.n 
    handles = findobj('Tag', model.name); 
    h = get(handles,'UserData'); 
    try  
        h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ... 
                                                      , plyData{linkIndex+1}.vertex.green ... 
                                                      , plyData{linkIndex+1}.vertex.blue]/255; 
        h.link(linkIndex+1).Children.FaceColor = 'interp'; 
    catch ME_1 
        disp(ME_1); 
        continue; 
    end 
end 
data = guidata(hObject); 
data.model = model; 
guidata(hObject,data); 
 

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in plusx.
function plusx_Callback(hObject, eventdata, handles)
q = handles.model.getpos; 
tr = handles.model.fkine(q); 
tr(1,4) = tr(1,4) + 0.01; 
newQ = handles.model.ikcon(tr,q); 
handles.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6val,'String', string_q6);


% hObject    handle to plusx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in minusX.
function minusX_Callback(hObject, eventdata, handles)
q = handles.model.getpos; 
tr = handles.model.fkine(q); 
tr(1,4) = tr(1,4) - 0.01; 
newQ = handles.model.ikcon(tr,q); 
handles.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6val,'String', string_q6);
% hObject    handle to minusX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plusy.
function plusy_Callback(hObject, eventdata, handles)
q = handles.model.getpos; 
tr = handles.model.fkine(q); 
tr(2,4) = tr(2,4) + 0.01; 
newQ = handles.model.ikcon(tr,q); 
handles.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6val,'String', string_q6);

% hObject    handle to plusy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in minusy.
function minusy_Callback(hObject, eventdata, handles)
q = handles.model.getpos; 
tr = handles.model.fkine(q); 
tr(2,4) = tr(2,4) - 0.01; 
newQ = handles.model.ikcon(tr,q); 
handles.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6val,'String', string_q6);
% hObject    handle to minusy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plusZ.
function plusZ_Callback(hObject, eventdata, handles)
q = handles.model.getpos; 
tr = handles.model.fkine(q); 
tr(3,4) = tr(3,4) + 0.01; 
newQ = handles.model.ikcon(tr,q); 
handles.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6val,'String', string_q6);
% hObject    handle to plusZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in minusZ.
function minusZ_Callback(hObject, eventdata, handles)
q = handles.model.getpos; 
tr = handles.model.fkine(q); 
tr(3,4) = tr(3,4) - 0.01; 
newQ = handles.model.ikcon(tr,q); 
handles.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6val,'String', string_q6);
% hObject    handle to minusZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function q1_Callback(hObject, eventdata, handles)
data = get(handles.q1,'Value');
q = handles.model.getpos; 
tr = handles.model.fkine(q); 

q(1) = data;
 
handles.model.animate(q);

string = sprintf('%.2f', data);

set(handles.q1val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);
% hObject    handle to q1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function q1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q2_Callback(hObject, eventdata, handles)
data = get(handles.q2,'Value');
q = handles.model.getpos; 
tr = handles.model.fkine(q); 

q(2) = data;
 
handles.model.animate(q); 

string = sprintf('%.2f', data);

set(handles.q2val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);
% hObject    handle to q2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function q2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q3_Callback(hObject, eventdata, handles)
data = get(handles.q3,'Value');
q = handles.model.getpos; 
tr = handles.model.fkine(q); 

q(3) = data;
 
handles.model.animate(q); 

string = sprintf('%.2f', data);

set(handles.q3val,'String', string);


stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);
% hObject    handle to q3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function q3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q4_Callback(hObject, eventdata, handles)
data = get(handles.q4,'Value');
q = handles.model.getpos; 
tr = handles.model.fkine(q); 

q(4) = data;
 
handles.model.animate(q); 

string = sprintf('%.2f', data);
set(handles.q4val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);
% hObject    handle to q4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function q4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q5_Callback(hObject, eventdata, handles)
data = get(handles.q5,'Value');
q = handles.model.getpos; 
tr = handles.model.fkine(q); 

q(5) = data;
 
handles.model.animate(q); 

string = sprintf('%.2f', data);
set(handles.q5val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);
% hObject    handle to q5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function q5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q6_Callback(hObject, eventdata, handles)
data = get(handles.q6,'Value');
q = handles.model.getpos; 
tr = handles.model.fkine(q); 

q(6) = data;
handles.model.animate(q);

string = sprintf('%.2f', data);
set(handles.q6val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval,'String', stringZ);
% hObject    handle to q6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function q6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function q1val_Callback(hObject, eventdata, handles)
data = str2double(get(handles.q1val,'String'));
q = handles.model.getpos; 


q(1) = data;
 
handles.model.animate(q); 
% hObject    handle to q1val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q1val as text
%        str2double(get(hObject,'String')) returns contents of q1val as a double


% --- Executes during object creation, after setting all properties.
function q1val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q1val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q2val_Callback(hObject, eventdata, handles)
data = str2double(get(handles.q2val,'String'));
q = handles.model.getpos; 


q(2) = data;
 
handles.model.animate(q); 
% hObject    handle to q2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q2val as text
%        str2double(get(hObject,'String')) returns contents of q2val as a double


% --- Executes during object creation, after setting all properties.
function q2val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q3val_Callback(hObject, eventdata, handles)
data = str2double(get(handles.q3val,'String'));
q = handles.model.getpos; 


q(3) = data;
 
handles.model.animate(q); 
% hObject    handle to q3val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q3val as text
%        str2double(get(hObject,'String')) returns contents of q3val as a double


% --- Executes during object creation, after setting all properties.
function q3val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q3val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q4val_Callback(hObject, eventdata, handles)
data = str2double(get(handles.q4val,'String'));
q = handles.model.getpos; 


q(4) = data;
 
handles.model.animate(q); 
% hObject    handle to q4val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q4val as text
%        str2double(get(hObject,'String')) returns contents of q4val as a double


% --- Executes during object creation, after setting all properties.
function q4val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q4val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q5val_Callback(hObject, eventdata, handles)
data = str2double(get(handles.q5val,'String'));
q = handles.model.getpos; 


q(5) = data;
 
handles.model.animate(q); 
% hObject    handle to q5val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q5val as text
%        str2double(get(hObject,'String')) returns contents of q5val as a double


% --- Executes during object creation, after setting all properties.
function q5val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q5val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q6val_Callback(hObject, eventdata, handles)
data = str2double(get(handles.q6val,'String'));
q = handles.model.getpos; 


q(6) = data;
 
handles.model.animate(q); 
% hObject    handle to q6val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q6val as text
%        str2double(get(hObject,'String')) returns contents of q6val as a double


% --- Executes during object creation, after setting all properties.
function q6val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q6val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xval_Callback(hObject, eventdata, handles)
% hObject    handle to Xval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xval as text
%        str2double(get(hObject,'String')) returns contents of Xval as a double


% --- Executes during object creation, after setting all properties.
function Xval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Yval_Callback(hObject, eventdata, handles)
% hObject    handle to Yval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Yval as text
%        str2double(get(hObject,'String')) returns contents of Yval as a double


% --- Executes during object creation, after setting all properties.
function Yval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zval_Callback(hObject, eventdata, handles)
% hObject    handle to Zval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zval as text
%        str2double(get(hObject,'String')) returns contents of Zval as a double


% --- Executes during object creation, after setting all properties.
function Zval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function q1_2_Callback(hObject, eventdata, handles)
data = get(handles.q1_2,'Value');
q = handles.model2.getpos; 
tr = handles.model2.fkine(q); 

q(1) = data;
 
handles.model2.animate(q);

% hObject    handle to q1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function q1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Estop.
function Estop_Callback(hObject, eventdata, handles)
% hObject    handle to Estop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
