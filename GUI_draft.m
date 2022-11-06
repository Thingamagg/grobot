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

% Last Modified by GUIDE v2.5 28-Oct-2022 13:31:16

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
hold on;
robot1 = EV10();
    robot2 = UR10_modified();

    workspace = [-3 4.5 -2 2 -0 3];
    axis normal
    view(3)
    scale = 0.2;
    stopflag = 0;
%                                                                             %Using this many global variables is 100% bad practice but don't have a better solution
robot1.workspace = workspace;
    q1 = zeros(1,6);%q1(4) = [pi/2]
    q1_target = zeros(1,6);
%     
%     robot2 = UR10_modified();
    q2 = zeros(1,6);
    q2_target = zeros(1,6);
    q2_base = transl([0 0 0]);
    q2_base_target = transl([2 0 0.2]);
    q2Height = 0.25;
    velocitylimit = 0.2;
    angularlimit = 0.3;
    obj_target = 1;
    handoffready = 0;
    passover = [0 0];
    held = [0 0];
    
    robot1.workspace = workspace;
    robot2.workspace = workspace;
    robot1.model.base = robot1.model.base * transl(-1,0.2,0.84);
    %robot1.model.plot(q1,'workspace',workspace,'scale',scale,'delay',0);
    robot1.PlotAndColourRobot();
    hold on
    view(3)
    %pause(1)
    robot2.model.base = robot2.model.base * transl([0,0,q2Height]);
    robot2.PlotAndColourRobot();
    %robot2.plot(q2,'workspace',workspace,'scale',scale);
    
    
    objs = GroceryObject(8,workspace);
    
    target = objs.object{obj_target}.base;
    
    
    drawEnvironment();
    

    
    %q1 = deg2rad([-90 20 -115 90 0 0]);
    %q2 = deg2rad([-90 -135 45 0 0 0]);

    
    view(3)
    

% main();


data = guidata(hObject); 
data.robot1 = robot1; 
data.robot2 = robot2;
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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 
tr(1,4) = tr(1,4) + 0.05; 
newQ = handles.robot1.model.ikcon(tr,q); 
handles.robot1.model.animate(newQ); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 
tr(1,4) = tr(1,4) - 0.05; 
newQ = handles.robot1.model.ikcon(tr,q); 
q = handles.robot1.model.getpos; 
handles.robot1.model.animate(newQ); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 
tr(2,4) = tr(2,4) + 0.05; 
newQ = handles.robot1.model.ikcon(tr,q); 
q = handles.robot1.model.getpos; 
handles.robot1.model.animate(newQ); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 
tr(2,4) = tr(2,4) - 0.05; 
newQ = handles.robot1.model.ikcon(tr,q); 
q = handles.robot1.model.getpos; 
handles.robot1.model.animate(newQ); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 
tr(3,4) = tr(3,4) + 0.05; 
newQ = handles.robot1.model.ikcon(tr,q); 
q = handles.robot1.model.getpos; 
handles.robot1.model.animate(newQ); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 
tr(3,4) = tr(3,4) - 0.05; 
newQ = handles.robot1.model.ikcon(tr,q); 
q = handles.robot1.model.getpos; 
handles.robot1.model.animate(newQ); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 

q(1) = data;
 
handles.robot1.model.animate(q);



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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 

q(2) = data;
 
handles.robot1.model.animate(q); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 

q(3) = data;
 
handles.robot1.model.animate(q); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 

q(4) = data;
 
handles.robot1.model.animate(q); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 

q(5) = data;
 
handles.robot1.model.animate(q); 

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
q = handles.robot1.model.getpos; 
tr = handles.robot1.model.fkine(q); 

q(6) = data;
handles.robot1.model.animate(q);

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
q = handles.robot1.model.getpos; 


q(1) = data;
 
handles.robot1.model.animate(q); 
set(handles.q1,'Value',data);
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
q = handles.robot1.model.getpos; 


q(2) = data;
 
handles.robot1.model.animate(q); 
set(handles.q2,'Value',data);
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
q = handles.robot1.model.getpos; 


q(3) = data;
 
handles.robot1.model.animate(q); 
set(handles.q3,'Value',data);
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
q = handles.robot1.model.getpos; 


q(4) = data;
 
handles.robot1.model.animate(q); 
set(handles.q4,'Value',data);
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
q = handles.robot1.model.getpos; 


q(5) = data;
 
handles.robot1.model.animate(q); 
set(handles.q5,'Value',data);
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
q = handles.robot1.model.getpos; 


q(6) = data;
 
handles.robot1.model.animate(q); 
set(handles.q6,'Value',data);
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
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 

q(1) = data;
 
handles.robot2.model.animate(q);
string = sprintf('%.2f', data);

set(handles.q1_2val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

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








function q1_2val_Callback(hObject, eventdata, handles)
% hObject    handle to q1_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q1_2val as text
%        str2double(get(hObject,'String')) returns contents of q1_2val as a double
data = str2double(get(handles.q1_2val,'String'));
q = handles.robot2.model.getpos; 


q(1) = data;
 
handles.robot2.model.animate(q); 
set(handles.q1_2,'Value',data);

% --- Executes during object creation, after setting all properties.
function q1_2val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q1_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function q2_2_Callback(hObject, eventdata, handles)
% hObject    handle to q2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = get(handles.q2_2,'Value');
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 

q(2) = data;
 
handles.robot2.model.animate(q);
string = sprintf('%.2f', data);

set(handles.q2_2val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

% --- Executes during object creation, after setting all properties.
function q2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q3_2_Callback(hObject, eventdata, handles)
% hObject    handle to q3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = get(handles.q3_2,'Value');
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 

q(3) = data;
 
handles.robot2.model.animate(q);
string = sprintf('%.2f', data);

set(handles.q3_2val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);
% --- Executes during object creation, after setting all properties.
function q3_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q4_2_Callback(hObject, eventdata, handles)
% hObject    handle to q4_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = get(handles.q4_2,'Value');
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 

q(4) = data;
 
handles.robot2.model.animate(q);
string = sprintf('%.2f', data);

set(handles.q4_2val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);
% --- Executes during object creation, after setting all properties.
function q4_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q4_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q5_2_Callback(hObject, eventdata, handles)
% hObject    handle to q5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = get(handles.q5_2,'Value');
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 

q(5) = data;
 
handles.robot2.model.animate(q);
string = sprintf('%.2f', data);

set(handles.q5_2val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);
% --- Executes during object creation, after setting all properties.
function q5_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function q6_2_Callback(hObject, eventdata, handles)
% hObject    handle to q6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = get(handles.q6_2,'Value');
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 

q(6) = data;
 
handles.robot2.model.animate(q);
string = sprintf('%.2f', data);

set(handles.q6_2val,'String', string);

stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);
% --- Executes during object creation, after setting all properties.
function q6_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function q2_2val_Callback(hObject, eventdata, handles)
% hObject    handle to q2_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q2_2val as text
%        str2double(get(hObject,'String')) returns contents of q2_2val as a double
data = str2double(get(handles.q2_2val,'String'));
q = handles.robot2.model.getpos; 


q(2) = data;
 
handles.robot2.model.animate(q); 
set(handles.q2_2,'Value',data);


% --- Executes during object creation, after setting all properties.
function q2_2val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q2_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q3_2val_Callback(hObject, eventdata, handles)
% hObject    handle to q3_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q3_2val as text
%        str2double(get(hObject,'String')) returns contents of q3_2val as a double
data = str2double(get(handles.q3_2val,'String'));
q = handles.robot2.model.getpos; 


q(2) = data;
 
handles.robot2.model.animate(q); 
set(handles.q3_2,'Value',data);

% --- Executes during object creation, after setting all properties.
function q3_2val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q3_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q4_2val_Callback(hObject, eventdata, handles)
% hObject    handle to q4_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q4_2val as text
%        str2double(get(hObject,'String')) returns contents of q4_2val as a double

data = str2double(get(handles.q4_2val,'String'));
q = handles.robot2.model.getpos; 


q(2) = data;
 
handles.robot2.model.animate(q); 
set(handles.q4_2,'Value',data);

% --- Executes during object creation, after setting all properties.
function q4_2val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q4_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q5_2val_Callback(hObject, eventdata, handles)
% hObject    handle to q5_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q5_2val as text
%        str2double(get(hObject,'String')) returns contents of q5_2val as a double
data = str2double(get(handles.q5_2val,'String'));
q = handles.robot2.model.getpos; 


q(2) = data;
 
handles.robot2.model.animate(q); 
set(handles.q5_2,'Value',data);

% --- Executes during object creation, after setting all properties.
function q5_2val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q5_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q6_2val_Callback(hObject, eventdata, handles)
% hObject    handle to q6_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q6_2val as text
%        str2double(get(hObject,'String')) returns contents of q6_2val as a double
data = str2double(get(handles.q6_2val,'String'));
q = handles.robot2.model.getpos; 


q(2) = data;
 
handles.robot2.model.animate(q); 
set(handles.q6_2,'Value',data);

% --- Executes during object creation, after setting all properties.
function q6_2val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q6_2val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plusx2.
function plusx2_Callback(hObject, eventdata, handles)
% hObject    handle to plusx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 
tr(1,4) = tr(1,4) + 0.05; 
newQ = handles.robot2.model.ikcon(tr,q); 
handles.robot2.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1_2val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2_2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3_2val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4_2val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5_2val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6_2val,'String', string_q6);


% --- Executes on button press in minusx2.
function minusx2_Callback(hObject, eventdata, handles)
% hObject    handle to minusx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 
tr(1,4) = tr(1,4) - 0.05; 
newQ = handles.robot2.model.ikcon(tr,q); 
handles.robot2.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1_2val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2_2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3_2val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4_2val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5_2val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6_2val,'String', string_q6);

% --- Executes on button press in plusy2.
function plusy2_Callback(hObject, eventdata, handles)
% hObject    handle to plusy2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 
tr(2,4) = tr(2,4) + 0.05; 
newQ = handles.robot2.model.ikcon(tr,q); 
handles.robot2.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1_2val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2_2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3_2val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4_2val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5_2val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6_2val,'String', string_q6);

% --- Executes on button press in minusy2.
function minusy2_Callback(hObject, eventdata, handles)
% hObject    handle to minusy2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 
tr(2,4) = tr(2,4) - 0.05; 
newQ = handles.robot2.model.ikcon(tr,q); 
handles.robot2.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1_2val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2_2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3_2val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4_2val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5_2val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6_2val,'String', string_q6);

% --- Executes on button press in plusz2.
function plusz2_Callback(hObject, eventdata, handles)
% hObject    handle to plusz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 
tr(3,4) = tr(3,4) + 0.05; 
newQ = handles.robot2.model.ikcon(tr,q); 
handles.robot2.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1_2val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2_2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3_2val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4_2val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5_2val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6_2val,'String', string_q6);

% --- Executes on button press in minusz2.
function minusz2_Callback(hObject, eventdata, handles)
% hObject    handle to minusz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
q = handles.robot2.model.getpos; 
tr = handles.robot2.model.fkine(q); 
tr(3,4) = tr(3,4) - 0.05; 
newQ = handles.robot2.model.ikcon(tr,q); 
handles.robot2.model.animate(newQ); 

%print to end effector coordinates
stringX = sprintf('%.2f', tr(1,4));
set(handles.Xval2,'String', stringX);

stringY = sprintf('%.2f', tr(2,4));
set(handles.Yval2,'String', stringY)

stringZ = sprintf('%.2f', tr(3,4));
set(handles.Zval2,'String', stringZ);

%print to q values
string_q1 = sprintf('%.2f', q(1));              
set(handles.q1_2val,'String', string_q1);

string_q2 = sprintf('%.2f', q(2));              
set(handles.q2_2val,'String', string_q2);

string_q3 = sprintf('%.2f', q(3));              
set(handles.q3_2val,'String', string_q3);

string_q4 = sprintf('%.2f', q(4));              
set(handles.q4_2val,'String', string_q4);

string_q5 = sprintf('%.2f', q(5));              
set(handles.q5_2val,'String', string_q5);

string_q6 = sprintf('%.2f', q(6));              
set(handles.q6_2val,'String', string_q6);


function Xval2_Callback(hObject, eventdata, handles)
% hObject    handle to Xval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xval2 as text
%        str2double(get(hObject,'String')) returns contents of Xval2 as a double


% --- Executes during object creation, after setting all properties.
function Xval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Yval2_Callback(hObject, eventdata, handles)
% hObject    handle to Yval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Yval2 as text
%        str2double(get(hObject,'String')) returns contents of Yval2 as a double


% --- Executes during object creation, after setting all properties.
function Yval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zval2_Callback(hObject, eventdata, handles)
% hObject    handle to Zval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zval2 as text
%        str2double(get(hObject,'String')) returns contents of Zval2 as a double


% --- Executes during object creation, after setting all properties.
function Zval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function drawObject(name,pose)
    [f,v,data] = plyread(name, 'tri');
    vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue]/256;
    mesh_h = trisurf(f,v(:,1),v(:,2),v(:,3) ...
        , 'FaceVertexCData', vertexColours, 'EdgeColor','interp','EdgeLighting','Flat');



    function drawEnvironment()
    surf([-3,-3;5,5],[-2,2;-2,2],[0.01,0.01;0.01,0.01],'CData',imread('floor wide.png'),'FaceColor','texturemap');



    h = PlaceObject('shelf fix.ply',[-0.55,1,0]);
verts = [get(h,'Vertices'), ones(size(get(h,'Vertices'),1),1)] * trotz(pi/2);
set(h,'Vertices',verts(:,1:3))
    h = PlaceObject('shelf fix.ply',[-0.55,3,0]);
verts = [get(h,'Vertices'), ones(size(get(h,'Vertices'),1),1)] * trotz(pi/2);
set(h,'Vertices',verts(:,1:3))
PlaceObject('table.ply',[-1.7 0.5 0.42]);
PlaceObject('monitor.ply',[-2.4 0.6 0.84]);
    h = PlaceObject('shopping_cart.ply',[1,0.5,0]);
verts = [get(h,'Vertices'), ones(size(get(h,'Vertices'),1),1)] * trotz(pi);
set(h,'Vertices',verts(:,1:3))

    h = PlaceObject('HUMAN BODY.ply',[2 0.5 0]);
verts = [get(h,'Vertices'), ones(size(get(h,'Vertices'),1),1)] * trotz(pi);
set(h,'Vertices',verts(:,1:3))
    h = PlaceObject('barrier.ply',[-1,-5,0]);
verts = [get(h,'Vertices'), ones(size(get(h,'Vertices'),1),1)] * trotz(-pi/2);
set(h,'Vertices',verts(:,1:3))
    h = PlaceObject('barrier.ply',[-1,0,0]);
verts = [get(h,'Vertices'), ones(size(get(h,'Vertices'),1),1)] * trotz(-pi/2);
set(h,'Vertices',verts(:,1:3))
    h = PlaceObject('rail.ply',[0,2,0]);
verts = [get(h,'Vertices'), ones(size(get(h,'Vertices'),1),1)] * trotz(pi/2);
set(h,'Vertices',verts(:,1:3))
    h = PlaceObject('estop.ply',[-2.2 0.2 0.84]);

