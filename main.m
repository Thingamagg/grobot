clf
clear all

mdl_puma560
mdl_ev10

robot1 = p560
q1 = zeros(1,6)
q1_target = zeros(1,6)
robot2 = ev10
q2 = zeros(1,6)
q2_target = zeros(1,6)
speedlimit = 0.1
handoffready = 0

workspace = [-4 4 -4 4 -4 4];
scale = 0.2
robot1.base = robot1.base * transl(2,0,0)
robot1.plot(q1,'workspace',workspace,'scale',scale)
hold on
robot2.plot(q2,'workspace',workspace,'scale',scale)

for i = 1:100
    global speedlimit q1 q1_target q2 q2_target handoffready
    fprintf('New update!')
    [q1,q1_target] = P560Flowchart(q1,q1_target)
    robot1.animate(q1)
    [q2,q2_target] = EV10Flowchart(q2,q2_target)
    robot2.animate(q2)
    drawnow()
    hold on
    robot2.plot(q2,'workspace',workspace,'scale',scale)
end

function newq = getNextPos(q, targetq)
    global speedlimit
    fprintf('doin math')
    q
    targetq
    targetq-q
    newq = q+maxMove(targetq-q,speedlimit)
end

function [nextQ,nextTargetQ] = EV10Flowchart(q, targetq)
    global handoffready
    %rotate between [pi/2 0 pi/2 0 0 0] and 0
    state1 = deg2rad([0 90 -80 0 0 -100]) %handoff
    state2 = deg2rad([90 0 0 0 0 0])     %deposit
    tolerance = 0.05
    
    nextTargetQ = targetq
    if (targetq == state1)
        if(atQ(q,state1,tolerance) && handoffready==1)
            nextTargetQ = state2
            handoffready = 0
        end
    elseif (targetq == state2)
        if atQ(q,state2,tolerance)
            nextTargetQ = state1
        end
    else
        nextTargetQ = state1
    end
    nextQ = getNextPos(q,nextTargetQ)
end

function [nextQ,nextTargetQ] = P560Flowchart(q,targetq)
    global handoffready
    state1 = deg2rad([160 90 -80 0 0 0]) %ready to handoff
    state2 = deg2rad([0 0 -90 0 0 0])    %deposit
    tolerance = 0.05
    
    nextTargetQ = targetq
    nextQ = q
    
    if (handoffready==0)    
        if (targetq == state1)
            if atQ(q,state1,tolerance)
                nextTargetQ = state2
                handoffready = 1
            end
        elseif (targetq == state2)
            if atQ(q,state2,tolerance)
                nextTargetQ = state1
            end
        else
            nextTargetQ = state1
        end
        nextQ = getNextPos(q,nextTargetQ)
    end
end



function result = maxMove(dif, limit)
    result = zeros(1,length(dif))
    for i=1:length(dif)
        if (dif(i)>=0)
            result(i) = min(dif(i), limit)
        else
            result(i) = max(dif(i), -limit)
        end
    end
end

function flag = atQ(q1,q2,tolerance)
    
    if (max(abs(q1-q2))<tolerance)
        flag = 1
    else
        flag = 0
    end
end
