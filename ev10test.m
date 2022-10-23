clf
clear all

UR10;
ur = UR10()
%robot.PlotAndColourRobot()
robot = ur.model
q = [0 -pi/2 0 0 0 0]
x = transl(robot.fkine(q))
robot.animate(q)


object =    [1.0000         0         0    3.1500;
         0    1.0000         0    0.3000;
         0         0    1.0000    1.2000;
         0         0         0    1.0000];

 robot.base =     [1.0000         0         0         0;
         0    1.0000         0         0;
         0         0    1.0000    0.2000;
         0         0         0    1.0000];
     
trans = (transl([0.1157+object(1,4) 0 0]));
robot.base = robot.base*trans;
robot.ikine(object)

         