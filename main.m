function [ ] = main()
    clf
    clear all

    stopbutton
    readybutton
    hazardbutton
    UR10_modified;
    EV10;
    
    global stopflag q1 q1_target q2 q2_target q2_base q2_base_target velocitylimit angularlimit obj_target handoffready passover held q2Height hazardready;
                 %x    y    z
    workspace = [-3 4.5 -2 2 -0 3];
    axis normal
    view(3)
    scale = 0.2;
    stopflag = 0;
                                                                            %Using this many global variables is 100% bad practice but don't have a better solution
    robot1 = EV10();%robot1.workspace = workspace
    q1 = zeros(1,6);%q1(4) = [pi/2]
    q1_target = zeros(1,6);
    
    robot2 = UR10_modified();
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
    hazardready
    
    robot1.workspace = workspace;robot2.workspace = workspace;

    robot1.model.base = robot1.model.base * transl(-1,0.2,0.84);
    %robot1.model.plot(q1,'workspace',workspace,'scale',scale,'delay',0);
    robot1.PlotAndColourRobot();
    hold on
    view(3)
    %pause(1)
    robot2.model.base = robot2.model.base * transl([0,0,q2Height]);
    robot2.PlotAndColourRobot();
    %robot2.plot(q2,'workspace',workspace,'scale',scale);
    
    
    objs = GroceryObject(2,workspace);
    
    target = objs.object{obj_target}.base;
    
    lightcurtain = transl([3.95 -0.1 1]);
    lightcurtain(:,:,2) = lightcurtain*transl([0 -1.8 0]);
    v = [lightcurtain(1:3,4,1),lightcurtain(1:3,4,2)]';
    
    plot3(v(:,1),v(:,2),v(:,3),'y')
    
    hazard = HazardObject()
    checkLightCurtain(hazard,lightcurtain);
    
    drawEnvironment();
    
    %q1 = deg2rad([-90 20 -115 90 0 0]);
    %q2 = deg2rad([-90 -135 45 0 0 0]);
    aq2_target = findQ(objs.object{obj_target}.base,robot2.model);
    q2_base_target = findBasePos(objs.object{obj_target}.base);
    
    view(3)
    
    
    %robot2.model.teach()
    
    while(true)
        pause(0.001);
        if not(stopflag)
            %global velocitylimit q1 q1_target q2 q2_target obj_target handoffready
            [q1,q1_target] = EV10Flowchart(q1,q1_target,objs,robot1.model);
            robot1.model.animate(q1);
            [q2,q2_target] = UR10Flowchart(q2,q2_target,robot2.model.base,objs,robot2.model);
            robot2.model.base = q2_base;
            robot2.model.animate(q2);
            if held(1)>0
                    objs.object{held(1)}.base = robot1.model.fkine(q1);
            end
            if held(2)>0
                    objs.object{held(2)}.base = robot2.model.fkine(q2);
            end
            objs.animate()
            %drawnow
        end
        if isempty(hazard) == 0
            if hazardready == true
                hazard.move(transl([-0.2 0 0]));
            end
            if checkLightCurtain(hazard,lightcurtain)
                stopflag = 1;
            end
        end
    end
end

function result = checkLightCurtain(hazard,curtain)
% Get the transform of every joint (i.e. start and end of every link)
    %tr = GetLinkPoses(qMatrix(qIndex,:), robot);
    result = false;
    % Go through each link and also each triangle face
    for faceIndex = 1:size(hazard.faces,1)
        vertOnPlane = hazard.vertex(hazard.faces(faceIndex,1)',:);
        [intersectP,check] = LinePlaneIntersection(hazard.normals(faceIndex,:),vertOnPlane,curtain(1:3,4,1)',curtain(1:3,4,2)'); 
        if check == 1 && IsIntersectionPointInsideTriangle(intersectP,hazard.vertex(hazard.faces(faceIndex,:)',:))
            %plot3(intersectP(1),intersectP(2),intersectP(3),'g*');
            display('Hazard Detected');
            result = true;
            return
        end
    end    
end

function result = IsIntersectionPointInsideTriangle(intersectP,triangleVerts)

u = triangleVerts(2,:) - triangleVerts(1,:);
v = triangleVerts(3,:) - triangleVerts(1,:);

uu = dot(u,u);
uv = dot(u,v);
vv = dot(v,v);

w = intersectP - triangleVerts(1,:);
wu = dot(w,u);
wv = dot(w,v);

D = uv * uv - uu * vv;

% Get and test parametric coords (s and t)
s = (uv * wv - vv * wu) / D;
if (s < 0.0 || s > 1.0)        % intersectP is outside Triangle
    result = 0;
    return;
end

t = (uv * wu - uu * wv) / D;
if (t < 0.0 || (s + t) > 1.0)  % intersectP is outside Triangle
    result = 0;
    return;
end

result = 1;                      % intersectP is in Triangle
end

function newq = velocityMatrixSanitise(robot,qMatrix,qdot)
    for j = 1:6                                                             % Loop through joints 1 to 6
        if qMatrix(j)+qdot(j) < robot.qlim(j,1)                 % If next joint angle is lower than joint limit...
            qdot(j) = 0; % Stop the motor
        elseif qMatrix(j)+qdot(j) > robot.qlim(j,2)             % If next joint angle is greater than joint limit 
            qdot(j) = 0; % Stop the motor
        end
    end
    newq = qMatrix+qdot;
end

function lambda = getManipulability(J,epsilon)
    m = sqrt(det(J*J'));
    if m < epsilon  % If manipulability is less than given threshold
        lambda = (1 - m/epsilon)*5E-2;
    else
        lambda = 0;
    end
end

function newq = calculateJacobian(robot,q,targetq)
    global velocitylimit angularlimit;
    %newq = q+maxMove(targetq-q,velocitylimit);
    state1 = robot.fkine(q);
    state2 = robot.fkine(targetq);
    a = transl(state1);b=transl(state2);
    ra = state1(1:3,1:3);
    rb = state2(1:3,1:3);
    d = Distance(a,b);
    linearvelocity = velocityvector(a,b,velocitylimit);
    rdot = velocityvector(ra,rb,angularlimit);
    S = rdot*ra';
    xdot = [linearvelocity;S(3,2);S(1,3);S(2,1)];
    
    J = robot.jacob0(q);
    
    lambda = getManipulability(J,0.1);
    invJ = inv(J'*J + lambda *eye(6))*J';
    qdot = (invJ*xdot)';
    newq = velocityMatrixSanitise(robot,q,qdot);
end

function newq = getNextPos(robot,q, targetq)
    newq = calculateJacobian(robot,q,targetq);
end

function newq = getNextPosOld(q,targetq)
    global velocitylimit
    newq = q+maxMove(targetq-q,velocitylimit);
end
    
function newm = getNextMatrix(m, targetm)
    newm = transl(getNextPosOld((transl(m)'),(transl(targetm)')));
end

function [nextQ,nextTargetQ] = UR10Flowchart(q, targetq, base, groceries, ur10)
    global handoffready obj_target held q2_base q2_base_target q2Height passover
    %rotate between [pi/2 0 pi/2 0 0 0] and 0
    handoff_q = deg2rad([0 -120 95 -57 180 -80]); %handoff
    state3 = deg2rad([-90 -135 45 0 0 0]);
    
    tolerance = 0.05;
    nextTargetQ = targetq;
    if (targetq == handoff_q)
        if(atPosition(ur10,q,handoff_q,tolerance) && atQ(base,q2_base_target,tolerance) && handoffready==1)
            obj_target = selectNewTarget()
            nextTargetQ = findQ(groceries.object{obj_target}.base,ur10);
            q2_base_target = findBasePos(groceries.object{obj_target}.base)
            handoffready = 0;
            held = [held(2), 0];
            passover(2) = 0;
        end
    else% (targetq == objgrab_q)
        if atPosition(ur10,q,targetq,tolerance) && atQ(base,q2_base_target,tolerance)
            nextTargetQ = handoff_q;
            held(2) = obj_target;
            q2_base_target = transl([0 0 0]);
            passover(2) = 0;
        end
    %else
        %nextTargetQ = objgrab_q;
    end
    
    if atPosition(ur10,q,state3,tolerance)
       passover(2) = 1;
    end
    if passover(2) == 1;
        nextQ = getNextPos(ur10,q,nextTargetQ);
        q2_base = getNextMatrix(q2_base,q2_base_target);
    else
        nextQ = getNextPos(ur10,q,state3);
    end
end

function [nextQ,nextTargetQ] = EV10Flowchart(q,targetq,groceries,ev10)
    global handoffready held passover
    state1 = deg2rad([-30 45 -135 90 -120 -20]); %ready to handoff
    state2 = deg2rad([-90 -20 -80 90 -90 -20]);    %deposit
    state3 = deg2rad([-90 20 -115 90 0 0]);     %collision avoidance
    tolerance = 0.1;
    
    
    nextTargetQ = targetq;
    nextQ = q;
    
    if (handoffready==0)    
        if (targetq == state1)
            if atPosition(ev10,q,state1,tolerance)
                nextTargetQ = state2;
                handoffready = 1;
                passover(1) = 0;
            end
        elseif (targetq == state2)
            if atPosition(ev10,q,state2,tolerance)
                nextTargetQ = state1;
                placeInCart(groceries,held(1))
                held(1) = 0;
                passover(1) = 0;
            end
        else
            nextTargetQ = state1;
        end
        if atPosition(ev10,q,state3,tolerance)
            passover(1) = 1;
        end
        
        if passover(1) == 1
            nextQ = getNextPos(ev10,q,nextTargetQ);
        else
            nextQ = getNextPos(ev10,q,state3);
        end
    end
end

function matrix = cartCoords(x,y)
    matrix = transl([(-1.5 +(x*0.2)),(-0.6 + (y*0.2)),(0.5)])
end

function placeInCart(groceries,num)
    positions = [1 1 2 2 3 3 4 4;repmat([0 1], 1, 4);]'
    if num <= 8
        groceries.object{num}.base = cartCoords(positions(num,1),positions(num,2))
    end
end

% function closest = findClosestObject(groceries)
%     closest = 1
%     for test = 1:length(groceries.object)
%         groceries.object{test}.base
%     end
% end


function dist = Distance(matrix1, matrix2)
    dist = norm(matrix1-matrix2);
end


function vec = velocityvector(a, b, limit)
    d = Distance(a,b);
    if d<limit
        vec = b-a;
    else
        q = (b-a)/(d/limit);
        vec = q;
    end
end

function target = selectNewTarget()
    global obj_target
    target = obj_target
    if (obj_target<8)
        target = obj_target+1
    end
end

function resultq = findQ(object,robot)
    %robot.base
    %object
    %a = object * transl([robot.base(1,4)-object(1,4) 0 0])
    object
    robot.base
    ur_offset = [0.1157 0 -0.3]
    
    trans = transl([robot.base(1,4),object(2,4),object(3,4)]+ur_offset)
    %trans = (object * transl([robot.base(1,4)-object(1,4) -0.2 0.1]))
    d = Distance(trans,robot.base)
    qGuess = deg2rad([-90 -110 90 -70 0 0])
    resultq = robot.ikine(trans)
    if abs(max(resultq))>10
        %error()
        resultq = deg2rad([-90 -90 0 0 90 0]);
    end
    %
end

function base = findBasePos(objectpos)  %using the base of an object on shelf, find where to send robot
    global q2Height
    base = transl(objectpos);
    base = transl([base(1), 0 q2Height])
end


function result = maxMove(dif, limit)
    result = zeros(1,length(dif));
    for i=1:length(dif)
        if (dif(i)>=0)
            result(i) = min(dif(i), limit);
        else
            result(i) = max(dif(i), -limit);
        end
    end
end

function flag = atQ(q1,q2,tolerance)
    if (max(abs(q1-q2))<tolerance)
        flag = 1;
    else
        flag = 0;
    end
end

function flag = atPosition(robot,q1,q2,tolerance)
    flag = atQ(transl(robot.fkine(q1)),transl(robot.fkine(q2)),tolerance);
end

function newVerts = transform(verts,pose)
    UpdatedPoints = [pose * [verts,ones(size(verts,1),1)]']';
    newVerts = UpdatedPoints(:,1:3);
end

function drawObject(name,pose)
    [f,v,data] = plyread(name, 'tri');
    vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue]/256;
    mesh_h = trisurf(f,v(:,1),v(:,2),v(:,3) ...
        , 'FaceVertexCData', vertexColours, 'EdgeColor','interp','EdgeLighting','Flat');
    mesh_h.Vertices = transform(mesh_h.Vertices,pose);
end

function drawEnvironment()
    surf([-3,-3;5,5],[-2,2;-2,2],[0.01,0.01;0.01,0.01],'CData',imread('floor wide.png'),'FaceColor','texturemap');


    drawObject('shelf fix.ply',(transl([1 0.55 0])*trotz(90,'deg')));
    drawObject('shelf fix.ply',(transl([3 0.55 0])*trotz(90,'deg')));
    drawObject('table.ply',(transl([-1.7 0.5 0.42])));
    drawObject('monitor.ply',(transl([-2.4 0.6 0.84])));
    drawObject('shopping_cart.ply',(transl([-1 -0.5 0])*trotz(180,'deg')));
    drawObject('HUMAN BODY.ply',(transl([-2.5 -0.4 0])*trotz(60,'deg')));
    drawObject('barrier.ply',(transl([-2 -1 0])*trotz(90,'deg')));
    drawObject('barrier.ply',(transl([4 -1 0])*trotz(90,'deg')));
    drawObject('rail.ply',(transl([2 0 0])*trotz(90,'deg')));
    drawObject('estop.ply',(transl([-2.2 0.2 0.84])));
    drawObject('lightcurtain.ply',(transl([3.95 -0.1 0])*trotz(0,'deg')));
    drawObject('lightcurtain.ply',(transl([3.95 -1.9 0])*trotz(180,'deg')));
    drawObject('lightcurtain.ply',(transl([-1.95 -0.1 0])*trotz(0,'deg')));
    drawObject('lightcurtain.ply',(transl([-1.95 -1.9 0])*trotz(180,'deg')));
    plot3([-1.95 -1.95],[-0.1 -1.9],[1 1],'y');

end


function stopbutton
    button = uicontrol
    button.String = 'Stop'
    button.Position = [25 25 80 80]
    button.Callback = @Stop
end

function readybutton
    button = uicontrol
    button.String = 'Restart'
    button.Position = [110 25 60 30]
    button.Callback = @Ready
end

function hazardbutton
    button = uicontrol
    button.String = 'Hazard'
    button.Position = [175 25 60 30]
    button.Callback = @SummonHazard
end
    
function Stop(btn,event)
    global stopflag
    if stopflag > 0
        fprintf('Stop Button Released\n');
        stopflag = 2;
    else
        fprintf('Stop Button Engaged\n');
        stopflag = 1;
    end
end

function Ready(btn,event)
global stopflag
    if stopflag==2
        stopflag = 0;
    end
end

function SummonHazard(btn,event)
    global hazardready
    hazardready = true
end
    
