clf
close all;

%Define EV10-1450 DH Parameters
L1 = Link('d',0.483,'a',0.18,   'alpha',pi/2,   'offset',0,     'qlim', [deg2rad(-170), deg2rad(170)]);
L2 = Link('d',0,    'a',0.615,  'alpha',0,      'offset',0,     'qlim', [deg2rad(-65), deg2rad(155)]);
L3 = Link('d',0,    'a',0.655,  'alpha',0,      'offset',0.02,  'qlim', [deg2rad(-160), deg2rad(150)]);
L4 = Link('d',0,    'a',0,      'alpha',pi/2,   'offset',0,     'qlim', [deg2rad(-30), deg2rad(210)]);
L5 = Link('d',0.105,'a',0,      'alpha',0,      'offset',0,     'qlim', [pi/2 pi/2]);
L6 = Link('d',0,    'a',0,      'alpha',0,      'offset',0                          );

ev10 = SerialLink([L1 L2 L3 L4 L5 L6],'name','EV10-1450');

% robot = ev10
% workspace = [-4 4 -4 4 -4 4];                                       % Define the boundaries of the workspace        
% scale = 0.5;                                                        % Scale the robot down        
% q = [0 pi/2 -pi/2 pi/2 0 0]
% robot.plot(q,'workspace',workspace,'scale',scale) 
% 
% robotscooch = transl([0.1 0 0])
% 
% for i = 1:100
%     q(1) = deg2rad(i)
%     robot.base = robot.base*robotscooch
%     robot.animate(q)
% end
