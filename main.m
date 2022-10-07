clf
clear all

mdl_puma560
mdl_ev10

robot1 = p560
q1 = zeros(1,6)
%q1_target = [-pi/2 0 0 0 0 0]
robot2 = ev10
q2 = zeros(1,6)
%q2_target = [pi/2 0 0 0 0 0]

workspace = [-4 4 -4 4 -4 4];
scale = 0.2
robot1.base = robot1.base * transl(2,0,0)
robot1.plot(q1,'workspace',workspace,'scale',scale)
hold on
robot2.plot(q2,'workspace',workspace,'scale',scale)

for i = 1:180
    q1(1) = pi/360 * i
    robot1.animate(q1)
    q2(1) = -pi/360 * i
    robot2.animate(q2)
    drawnow()
    %hold on
    %robot2.plot(q2,'workspace',workspace,'scale',scale)
end
