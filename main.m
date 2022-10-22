function [ ] = main()
    clf
    clear all

    UR10_modified;
    EV10;
    
    global q1 q1_target q2 q2_target q2_base q2_base_target speedlimit obj_target handoffready held;
                 %x    y    z
    workspace = [-3 4.5 -2 2 -0.5 3];
    axis normal
    view(3)
    scale = 0.2;

        
    robot1 = EV10();%robot1.workspace = workspace
    q1 = zeros(1,6);
    q1_target = zeros(1,6);
    
    robot2 = UR10_modified();
    q2 = zeros(1,6);
    q2_target = zeros(1,6);
    q2_base = transl([0 0 0]);
    q2_base_target = transl([2 0 0]);
    speedlimit = 0.2;
    obj_target = 1;
    handoffready = 0;
    held = [0 0];
    

    robot1.workspace = workspace;robot2.workspace = workspace

    robot1.model.base = robot1.model.base * transl(-1,0.2,0.42);
    %robot1.model.plot(q1,'workspace',workspace,'scale',scale,'delay',0);
    robot1.PlotAndColourRobot();
    hold on
    view(3)
    %pause(1)
    robot2.PlotAndColourRobot();
    %robot2.plot(q2,'workspace',workspace,'scale',scale);
    
    
    objs = GroceryObject(8,workspace);
    
    target = objs.object{obj_target}.base
    
    
    drawEnvironment()
    
    
    
    q2_target = findQ(objs.object{obj_target}.base,robot2.model);
    q2_base_target = findBasePos(objs.object{obj_target}.base);
    
    %objs.object{obj_target}.base * transl([robot2.base(1,4)-objs.object{obj_target}.base(1,4) 0 0])
    %a = findQ(objs.object{obj_target}.base,robot2)

    view(3)
    
    for k1 = 1:100
        %global speedlimit q1 q1_target q2 q2_target obj_target handoffready
        [q1,q1_target] = P560Flowchart(q1,q1_target);
        robot1.model.animate(q1);
        [q2,q2_target] = EV10Flowchart(q2,q2_target,robot2.model.base,objs,robot2.model);
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
end


function newq = getNextPos(q, targetq)
    global speedlimit
    newq = q+maxMove(targetq-q,speedlimit);
end

function newm = getNextMatrix(m, targetm)
    newm = transl(getNextPos((transl(m)'),(transl(targetm)')));
end

function [nextQ,nextTargetQ] = EV10Flowchart(q, targetq, base, groceries, ev10)
    global handoffready obj_target held q2_base q2_base_target
    %rotate between [pi/2 0 pi/2 0 0 0] and 0
    handoff_q = deg2rad([0 90 -80 0 0 -100]); %handoff
    %objgrab_q = deg2rad([90 0 0 0 0 0]);     %object
    
    tolerance = 0.05;
    nextTargetQ = targetq;
    if (targetq == handoff_q)
        if(atQ(q,handoff_q,tolerance) && atQ(base,q2_base_target,tolerance) && handoffready==1)
            obj_target = selectNewTarget()
            nextTargetQ = findQ(groceries.object{obj_target}.base,ev10);
            q2_base_target = findBasePos(groceries.object{obj_target}.base)
            handoffready = 0;
            held = [held(2), 0]
        end
    else% (targetq == objgrab_q)
        if atQ(q,targetq,tolerance) && atQ(base,q2_base_target,tolerance)
            nextTargetQ = handoff_q;
            held(2) = obj_target;
            q2_base_target = transl([0 0 0]);
        end
    %else
        %nextTargetQ = objgrab_q;
    end
    nextQ = getNextPos(q,nextTargetQ);
    q2_base = getNextMatrix(q2_base,q2_base_target);

end

function [nextQ,nextTargetQ] = P560Flowchart(q,targetq)
    global handoffready held
    state1 = deg2rad([160 90 -80 0 0 0]); %ready to handoff
    state2 = deg2rad([0 0 -90 0 0 0]);    %deposit
    tolerance = 0.05;
    
    nextTargetQ = targetq;
    nextQ = q;
    
    if (handoffready==0)    
        if (targetq == state1)
            if atQ(q,state1,tolerance)
                nextTargetQ = state2;
                handoffready = 1;
            end
        elseif (targetq == state2)
            if atQ(q,state2,tolerance)
                nextTargetQ = state1;
                held(1) = 0
            end
        else
            nextTargetQ = state1;
        end
        nextQ = getNextPos(q,nextTargetQ);
    end
end


% function closest = findClosestObject(groceries)
%     closest = 1
%     for test = 1:length(groceries.object)
%         groceries.object{test}.base
%     end
% end

function dist = Distance(matrix1, matrix2)
    dist = norm(matrix1-matrix2)
end

function target = selectNewTarget()
    global obj_target
    target = obj_target
    if (obj_target<10)
        target = obj_target+1
    end
end

function resultq = findQ(object,robot)
    %robot.base
    %object
    %a = object * transl([robot.base(1,4)-object(1,4) 0 0])
    %resultq = robot.ikine(object * transl([robot.base(1,4)-object(1,4) 0 0]))
    resultq = deg2rad([90 0 0 0 0 0]);
end

function base = findBasePos(objectpos)  %using the base of an object on shelf, find where to send robot
    base = transl(objectpos)
    base = transl([base(1), 0 0])
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

function newVerts = transform(verts,pose)
    pose
    size(pose)
    size([verts,ones(size(verts,1),1)])
    UpdatedPoints = [pose * [verts,ones(size(verts,1),1)]']'
    newVerts = UpdatedPoints(:,1:3)
end

function drawObject(name,pose)
    [f,v,data] = plyread(name, 'tri');
    vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue]/256;
    mesh_h = trisurf(f,v(:,1),v(:,2),v(:,3) ...
        , 'FaceVertexCData', vertexColours, 'EdgeColor','interp','EdgeLighting','Flat');
    mesh_h.Vertices = transform(mesh_h.Vertices,pose);
end


function drawEnvironment()
    drawObject('shelf fix.ply',(transl([1 0.6 0])*trotz(90,'deg')));
    drawObject('shelf fix.ply',(transl([3 0.6 0])*trotz(90,'deg')));
    drawObject('table.ply',(transl([-1.5 0.5 0])));
    drawObject('monitor.ply',(transl([-2.4 0.6 0.42])));
end
