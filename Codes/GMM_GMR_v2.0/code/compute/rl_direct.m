%function Mu = rl(Mu, DoFs)
function Mu = rl()
clc;
clear;
    path = '../data/';
    load([path, 'Mu.mat']);


    [hand_std, joint_std] = reproduce();
    wall = hand_std;
    wall(32:172, 3) = hand_std(32:172, 3) - 0.0235;

    plot(hand_std(:,3), 'r'); hold on;
    plot(wall(:,3));
	DoFs = 1;
 
    
    
    
    % define state and action
    action = 0; % 0, 1, -1
    state = [0, 0, 0]; % 0, 1, -1
    
    %nbRange = 5;
    %nbAct = 3;  % 3 actions: 1-stay, 2-increase, 3-decrease
    
    %params
	gamma = 0.8;
    lambda = 0.1;
    alpha = 0.6;
   

    % initilize Q, e
    Q = rand([power(nbRange, nbState), power(nbAct, nbState)]);		% 5^6 * 3^6
    e = zeros(size(Q));
   
    % training 5000 episode
	total_step = 0;
	accum_rwd = 0;
    for episode = 1 : 10000
        %initialize s, a
        s = randi(nbRange, [1, nbState]);		% s begins randomly 
        s_new = zeros(size(s));
		a = greedy(s, Q, total_step, nbRange, nbState, nbAct);			% select a greedy
        %a = randi(nbAct, [1, nbState]);        % select a randomly
		a_new = zeros(size(a));

        % repeat for each step in one episode
		follow_counter = 0;
		fail_counter = 0;
        hand = zeros(200, 6);
        train_length = 40;
        for step = 1 : train_length
            fprintf('episode %d\t total_step %d\t step %d\t', episode, total_step, step);      
			total_step = total_step + 1; 
			% take action from 1 ~ nbRange, observer new state
            s_new = takeAction(s,  a);
            % observe reward
            wall(step, 3)
            [rwd, h] = reward(step, Mu, DoFs, s_new, joint_mu_matrix, Jacobian, wall(step, 3));
            %fprintf('rwd %f\n', rwd);
			
            if rwd == 1 
                follow_counter = follow_counter + 1;
                hand(step, :) = h';
				%s_new
            else
                follow_counter = 0;
				fail_counter = fail_counter + 1;
            end

            % choose a_new, greedy
            a_new = greedy(s_new, Q, total_step, nbRange, nbState, nbAct);

            idx_s = index(s, nbRange);
            idx_s_new = index(s_new, nbRange);
            idx_a = index(a, nbAct);
            idx_a_new = index(a_new, nbAct);
            
            delta = rwd + gamma * Q(idx_s_new, idx_a_new) - Q(idx_s, idx_a);
            e(idx_s, idx_a) = e(idx_s, idx_a) + 1; 
            % update Q, e
            Q = Q + alpha * delta * e;
            e = gamma * lambda * e;
			
% 			if follow_counter >5
%                 plot(hand(1:step, 3)); grid on;
%    				s
%                 a
% 				s_new
% 				a_new
%                 h
% 				pause;
% 			end
            

			accum_rwd = accum_rwd + rwd;
			fprintf('accum_rwd %f\t', accum_rwd/total_step);
			
			% check termination	
			fprintf('follow_counter %d\n', follow_counter);
			if follow_counter > train_length -1
				disp('Success !!!');
                fprintf('episode %d, total_step %d\n', episode, total_step);
                s
                pause;
                compareHand(s);
                pause;
                close all;
				%save('../data/Mu_new.mat', 'Mu_new');
				return;
			end
			if fail_counter > 0
				break
            end
            
            s = s_new;
            a = a_new;
        end % 200 steps 
    end %each episode while(1)
    %save('data/Mu.mat', 'Mu');
end

function val = index(s, base)
    s = fliplr(s);
    val = 0;
    for i = size(s, 2) :-1: 1
        val = val + (s(i)-1) * power(base, i-1);
    end    
    val = val + 1;
end

function x = decode(a)
    base =3;
    nbState = 6;
    x = zeros(1, 6);
    a = a - 1;
    for i = nbState : -1 :1
        x(i) = mod(a, base) + 1;
        a = fix(a/base);
    end
end

function s_new = takeAction(s, a)    
	for i = 1 : size(s, 2)
		if s(i) == 1 && a(i) == 3		% min and decrease -> s(5)
			s_new(i) = 5;
		elseif s(i) == 5 && a(i) == 2  % max and increase -> s(1)
			s_new(i) = 1;
		else
			switch a(i)
				case 1
					s_new(i) = s(i);
				case 2
					s_new(i) = s(i) + 1;
				case 3
					s_new(i) = s(i) - 1;
				otherwise 
					disp('Wrong action in takeAction(), hit any key to exit');
					pause;
					return;
			end
		 end
	end
end

function best = greedy(s, Q, total_step, nbRange, nbState, nbAct)
    epsilon = 0.3;
	
	line = Q(index(s, nbRange), :);
    a = find(line==max(line));
	best = decode(a);
	if size(a, 2) ~= 1 
		fprintf('Multiple max in Q: a %d, size of a %d\n', a, size(a));
		pause;
	end

	temperature = 1 / total_step; 
	%if total_step > 100 && total_step < 500
	%	temperature = 1 / (total_step - 99) * 2;	
	%end
	%if total_step > 500
	%	temperature = 1/(total_step - 500);	
	%end

	if rand(1,1) > epsilon * temperature || (total_step == 0)
		return;
	else
		non_best = randi(nbAct, [1, nbState]);
		while all(non_best - best) == 0
			non_best = randi(nbAct, [1, nbState]);
		end
		best = non_best;
		return;
	end
end

function [r, hand] = reward(queryTime, Mu, DoFs, s, joint_mu_matrix, Jacobian, wall) 
   nbState = size(Mu, 2);
   Mu_new = Mu;
   for i = 1 : nbState
       Mu_new(1+DoFs, i) = joint_mu_matrix(s(i), i);
   end

   joint = GMRwithParam(queryTime, [1], [2:9], Mu_new);
	

   hand = testForwardKinect([joint]', Jacobian);
 
   fprintf('hand %f\t, wall %f\t, diff %f\n', hand(3), wall, hand(3)-wall);
    
    if queryTime < 32 || queryTime > 171
        if hand(3) < 0.33
            r = -1;
        else
            r = 1;
        end
    else
        if abs(hand(3) - wall) > 0.005
            r = -1;
        else
            r = 1;
            %r = 1 - abs(hand(3) - wall) * 100;
        end
    end
end
