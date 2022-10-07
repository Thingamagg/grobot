imshow('Lab1_CircularRaceTrack.jpg');
axis on
hold on
car1Tr = se2(300, 550, 0)
%T1_h = trplot2(car1Tr, 'frame', '1', 'color', 'b','length',50);

forLoopIncrements = 360;

car1MoveTr = se2((pi * 484)/forLoopIncrements, 0, 0);
car1TurnTr = se2(0, 0, -2*pi/forLoopIncrements);

car2MoveTr = se2((pi * 375)/forLoopIncrements, 0, 0);
car2TurnTr = se2(0, 0, 2*pi/forLoopIncrements);

car2Tr = se2(300, 125, 0)
%T2_h = trplot2(car2Tr, 'frame', '1', 'color', 'r','length',50);

subplot(1,2,2);
xlabel('Timestep');
ylabel('Sensor reading - distance between cars');
hold on;     

for i = 1:forLoopIncrements
    subplot(1,2,1);
    car1Tr = car1Tr * car1MoveTr * car1TurnTr;
    car2Tr = car2Tr * car2MoveTr * car2TurnTr;
    try delete(car1Tr_h);end
    try delete(text_h);end;
    try delete(car2Tr_h);end
    car1Tr_h = trplot2(car1Tr, 'frame', '1', 'color', 'b','length',50);
    car2Tr_h = trplot2(car2Tr, 'frame', '1', 'color', 'r','length',50);
    message = sprintf([num2str(round(car1Tr(1,:),2,'significant')),'\n' ...
                      ,num2str(round(car1Tr(2,:),2,'significant')),'\n' ...
                      ,num2str(round(car1Tr(3,:),2,'significant'))]);
    text_h = text(10, 50, message, 'FontSize', 10, 'Color', [.6 .2 .6]);
    subplot(1,2,2);

    drawnow();
    
end
