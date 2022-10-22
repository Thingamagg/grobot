classdef LinearEV10 < handle
    properties
        %> Robot model
        model;
        
        %>
        workspace = [-2 2 -2 2 -0.3 2]; 
        
        %> Flag to indicate if gripper is used
        useGripper = false;        
    end
    
    methods%% Class for EV10 robot simulation
function self = LinearEV10(useGripper,robotpos)%构造函数
    self.useGripper = useGripper;
    
%> Define the boundaries of the workspace
 
    self.GetEV10Robot(robotpos);
    self.PlotAndColourRobot();%robot,workspace;
end

%% GetEV10Robot
% Given a name (optional), create and return a EV10 robot model
function GetEV10Robot(self,robotpos)
%     if nargin < 1
        % Create a unique name (ms timestamp after 1ms pause)
        pause(0.001);%延时1ms创建机器人，目的是使机器人的名字不同
        name = ['LinearEV10_',datestr(now,'yyyymmddTHHMMSSFFF')];%将机器人的名字与当前时间结合
%     end


%     L(1) = Link([pi     0           0       pi/2   1]);
%     L(2) = Link([0      0.1599  0       pi/2   0]);
%     L(3) = Link([0      0  -0.24365       0    0]);
%     L(4) = Link([0      0  -0.21325       0    0]);
%     L(5) = Link([0      0.11235   0    pi/2   0]);
%     L(6) = Link([0      0.08535   0   -pi/2	 0]);
%     L(7) = Link([0      0.0819     0        0   0]);
%     
%     % Incorporate joint limits限位
%     L(1).qlim = [-0.8 0];
%     L(2).qlim = [-360 360]*pi/180;
%     L(3).qlim = [-180 0]*pi/180;
%     L(4).qlim = [-360 360]*pi/180;
%     L(5).qlim = [-360 360]*pi/180;
%     L(6).qlim = [-360 360]*pi/180;
%     L(7).qlim = [-360 360]*pi/180;
    
    % Create the EV10 model 
    L1 = Link('d',0.483,'a',0.18,   'alpha',pi/2,   'offset',0,     'qlim', [deg2rad(-170), deg2rad(170)]);
    L2 = Link('d',0,    'a',0.615,  'alpha',0,      'offset',0,     'qlim', [deg2rad(-65), deg2rad(155)]);
    L3 = Link('d',0,    'a',0.655,  'alpha',0,      'offset',0,  'qlim', [deg2rad(-160), deg2rad(150)]);
    L4 = Link('d',0,    'a',0,      'alpha',pi/2,   'offset',0,     'qlim', [deg2rad(-30), deg2rad(210)]);
    L5 = Link('d',0.105,'a',0,      'alpha',0,      'offset',0,     'qlim', [pi/2 pi/2]);
    L6 = Link('d',0,    'a',0,      'alpha',0,      'offset',0                          );

    self.model = SerialLink([L1 L2 L3 L4 L5 L6],'name',name);
    
    % Rotate robot to the correct orientation将机器人旋转到正确的姿态
%     self.model.base = self.model.base * trotx(pi/2) * troty(pi/2) * transl(robotpos(1),robotpos(2),robotpos(3));
    
end
%% PlotAndColourRobot
% Given a robot index, add the glyphs (vertices and faces) and
% colour them in if data is available 
function PlotAndColourRobot(self)%robot,workspace)
    for linkIndex = 0:self.model.n
        if self.useGripper && linkIndex == self.model.n
            [ faceData, vertexData, plyData{linkIndex+1} ] = plyread(['EV10_Link',num2str(linkIndex),'Gripper.ply'],'tri'); %#ok<AGROW>
        else
            [ faceData, vertexData, plyData{linkIndex+1} ] = plyread(['EV10_Link',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>EV10_link0
        end
        self.model.faces{linkIndex+1} = faceData;
        self.model.points{linkIndex+1} = vertexData;
    end

    % Display robot
    self.model.plot3d(zeros(1,self.model.n),'noarrow','workspace',self.workspace);
    if isempty(findobj(get(gca,'Children'),'Type','Light'))
        camlight
    end  
    self.model.delay = 0;

    % Try to correctly colour the arm (if colours are in ply file data)
%     for linkIndex = 0:self.model.n
%         handles = findobj('Tag', self.model.name);
%         h = get(handles,'UserData');
%         try 
%             h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ...
%                                                           , plyData{linkIndex+1}.vertex.green ...
%                                                           , plyData{linkIndex+1}.vertex.blue]/255;
%             h.link(linkIndex+1).Children.FaceColor = 'interp';
%         catch ME_1
%             disp(ME_1);
%             continue;
%         end
%     end
end        
    end
end