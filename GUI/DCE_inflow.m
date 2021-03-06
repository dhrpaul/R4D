function varargout = DCE_inflow(varargin)
% DCE_INFLOW MATLAB code for DCE_inflow.fig
%      DCE_INFLOW, by itself, creates a new DCE_INFLOW or raises the existing
%      singleton*.
%
%      H = DCE_INFLOW returns the handle to a new DCE_INFLOW or the handle to
%      the existing singleton*.
%
%      DCE_INFLOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DCE_INFLOW.M with the given input arguments.
%
%      DCE_INFLOW('Property','Value',...) creates a new DCE_INFLOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DCE_inflow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DCE_inflow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DCE_inflow

% Last Modified by GUIDE v2.5 30-Sep-2016 15:13:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DCE_inflow_OpeningFcn, ...
                   'gui_OutputFcn',  @DCE_inflow_OutputFcn, ...
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

% --- Executes just before DCE_inflow is made visible.
function DCE_inflow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DCE_inflow (see VARARGIN)

% Choose default command line output for DCE_inflow
handles.output = hObject;
handles.ValSl1=0;
handles.ValSl2=0;

axes(handles.axes1);cla;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DCE_inflow wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = DCE_inflow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,folder] = uigetfile('*.raw*','Choose raw file');
MRC=GoldenAngle_Recon([folder,file]) %center of kspace
% MRC.Parameter.Parameter2Read.kz=0   %only center stack
MRC.Parameter.Parameter2Read.chan=MRC.Parameter.Parameter2Read.chan(1);
MRC.Perform1;


[center_signal,t]=filterGA(MRC)
handles.t=t;
handles.plotrange=[min(center_signal),max(center_signal)];
handles.DC=center_signal;

handles.P.file=file;
handles.P.folder=folder;

axes(handles.axes1);cla;
plot(handles.t,handles.DC,'k'); xlabel('t(s)');
guidata(hObject,handles)

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
t=handles.t;
set(hObject,'Min',0)
set(hObject,'Max',t(end))
handles.ValSl1=get(hObject,'Value');
axes(handles.axes1); cla;
hold on 
plot(handles.t,handles.DC,'k'); xlabel('t(s)');
plot([handles.ValSl1,handles.ValSl1],handles.plotrange,'r')
plot([handles.ValSl2,handles.ValSl2],handles.plotrange,'r')
hold off
set(handles.text2,'String',num2str(handles.ValSl1))

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

t=handles.t;
set(hObject,'Min',0);
set(hObject,'Max',t(end));
handles.ValSl2=get(hObject,'Value');
axes(handles.axes1);cla;
hold on 
plot(handles.t,handles.DC,'k'); xlabel('t(s)');
plot([handles.ValSl1,handles.ValSl1],handles.plotrange,'r')
plot([handles.ValSl2,handles.ValSl2],handles.plotrange,'b')
hold off


% set(handles.text3,'String',num2str(handles.ValSl2))
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function varargout=pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

P=handles.P;
spoke1=find(handles.t-handles.ValSl1>0,1,'first')-1
spoke2=find(handles.t-handles.ValSl2>0,1,'first')-1
P.spokestoread=[spoke1:spoke2].';
P.sensitivitymaps = true;

[MR,P]=GoldenAngle(P)


% FILTERS GOLDEN ANGLE FREQUENCY FROM SIGNAL
function [center_signal_filtered,t]=filterGA(MRC)

goldenangle=MRC.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
[nx,ny,nz,nc]=size(MRC.Data);
cksp=floor(nx/2)+1;
cnz=floor(nz/2)+1;
Ts=MRC.Parameter.Scan.TR.*MRC.Parameter.Scan.Samples(3).*1e-3;
t=[1:length(MRC.Data)].*Ts;
Fs=1./Ts;
goldenanglefreq=(goldenangle*Fs)/(360)

if license('checkout','signal_processing')==1; %if i dont have the signal processing license :( 
    
    f=designfilt('lowpassiir','FilterOrder',5,...
        'PassbandFrequency',goldenanglefreq*0.7,...
        'PassbandRipple',1,...
        'SampleRate',Fs);
    center_signal=abs(mean(MRC.Data(cksp,:,cnz,1),4));
    center_signal_filtered=filtfilt(f,double(center_signal));
else
    center_signal=abs(mean(MRC.Data(cksp,:,cnz,1),4));
%     center_signal=abs(mean(MRC.Data(cksp,:,:,:),3));
    center_signal_filtered=smooth(double(center_signal),15);
end
    
    
