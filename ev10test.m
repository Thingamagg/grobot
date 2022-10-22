clf
clear all
EV10

robot1 = EV10()

%Define EV10-1450 DH Parameters %655 total
            L1 = Link('d',0.483,'a',0.18,   'alpha',pi/2,   'offset',0,     'qlim', [deg2rad(-170), deg2rad(170)]);
            L2 = Link('d',0,    'a',0.615,  'alpha',0,      'offset',0,     'qlim', [deg2rad(-65), deg2rad(155)]);
            L3 = Link('d',0,    'a',0.325,  'alpha',pi/2,      'offset',0.02,  'qlim', [deg2rad(-160), deg2rad(150)]);
            L4 = Link('d',0,    'a',0,      'alpha',pi/2,      'offset',0,  'qlim',[pi/2 pi/2]);
            L5 = Link('d',0.33,    'a',0,  'alpha',pi/2,   'offset',0,     'qlim', [-pi/2 pi/2])%[deg2rad(-30), deg2rad(210)]);
            L6 = Link('d',0,'a',0.105,      'alpha',0,      'offset',0,'qlim',[deg2rad(-30),deg2rad(210)])%'qlim', );

            robot2 = SerialLink([L1 L2 L3 L4 L5 L6],'name','EV10');
robot1.PlotAndColourRobot()
%hold on
q = zeros(1,6);q(4:5) = pi/2
%robot2.plot(q)
%robot2.teach()
robot1.model.animate(q)
robot1.model.teach()