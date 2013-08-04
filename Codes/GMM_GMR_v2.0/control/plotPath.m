function plotPath
load('data/raw_1.mat');

tmp = raw_1';
hand_record = tmp(12:14, :);
ball_record = tmp(1:3, :);
max(ball_record')
min(ball_record')
plot3(ball_record(1,:), ball_record(2,:), ball_record(3,:), 'r-'); 
hold on;
plot3(hand_record(1,:), hand_record(2,:), hand_record(3,:), 'b-');
hold on;


x = ball_record;
x(1,:) = x(1, :)-0.2;
y = GMR(x);

hand_regress = y(9:11, :);

plot3(x(1,:), x(2,:), x(3,:), 'ro-'); 
hold on;
plot3(hand_regress(1,:), hand_regress(2,:), hand_regress(3,:), 'g-'); 
grid on;

xlabel('x','fontsize',16); ylabel('y','fontsize',16); zlabel('z', 'fontsize',16);
