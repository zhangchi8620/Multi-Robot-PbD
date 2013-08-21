%Main function

function calModel()
    clc;
    clear;
    
    path = 'data/';
    numDemo = 3;
    numDim = 14;    % 3 ball position + 3 hand position + 8 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
 
%    delete('data/*.mat');
%    flagDTW = 1;
%    readAll(path, numDemo, numDim, flagDTW);
 
    load('data/raw_all.mat');
    tmp = raw_all';
    
    % cal distance
    tmp(1, :) = tmp(4, :) - tmp(1, :);
    tmp(2, :) = tmp(5, :) - tmp(2, :);
    tmp(3, :) = tmp(6, :) - tmp(3, :);

    onetime = [1:size(tmp,2)/3];
    timeDim = [onetime, onetime, onetime];
    Data =[timeDim; tmp];
    
    [nbVar, nbData] = size(Data);
    fprintf('size of Data: [%d, %d]\n',nbVar, nbData);

%     nbStates = BIC(Data, numDemo)

  
%     inputDist= Data(2:4, :);
%     inputHand = Data(5:7, :);
%     inputJoint = Data(8:end, :);
%     inputAll = Data(2:end, :);
%     
    % threshold for PCA
    threshold = 0.98;
  
    %[Data2, A] = PCA(inputAll, threshold);
    
%     % BIC
%     maxStates = 10;
%     nbStates = BIC(Data2, maxStates);
%     fprintf('nbStates %d\n', nbStates);
    
    %% Training of GMM by EM algorithm, initialized by k-means clustering.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [Priors, Mu, Sigma] = trainModelwithPCA([timeDim;Data], threshold);
    save('data/Priors.mat', 'Priors');
    save('data/Mu.mat', 'Mu');
    save('data/Sigma.mat', 'Sigma');
    
    %% Plotting    
    nbVarDist = 3;
    nbVarHand = 3;
    nbVarJoints = 8;
%     
%   
%     
%     %plot hand-ball distance
%     nbVar = nbVarDist;
%     for n=1: nbVar
%       subplot(nbVar, 1, n);
%       hold on;
%       plotGMM(Mu([1,n+1],:), Sigma([1,n+1],[1,n+1],:), [0 .8 0], 1);
%       axis([min(Data(1,:)) max(Data(1,:)) min(Data(n+1,:))-0.01 max(Data(n+1,:))+0.01]);
%       xlabel('t','fontsize',16); ylabel(['x_' num2str(n)],'fontsize',16);
%     end
%     
%     figure;
%     %plot hand
%     nbVar = nbVarHand;
%     for n=4: 3+nbVar
%       subplot(nbVar, 1, n-3);
%       hold on;
%       plotGMM(Mu([1,n+1],:), Sigma([1,n+1],[1,n+1],:), [0 .8 0], 1);
%       %lotGMM([query(1,:); y([n-2],:), Sigma_y([1,n-2],[1,n-2],:), [0 0.8 0], 3);
%       plot(Data(1,:), Data(n+1,:), 'x', 'markerSize', 4, 'color', [.3 .3 .3]);
%       axis([min(Data(1,:)) max(Data(1,:)) min(Data(n+1,:))-0.01 max(Data(n+1,:))+0.01]);
%       xlabel('t','fontsize',16); ylabel(['x_' num2str(n)],'fontsize',16);
%     end
%     
%     %plot joints
%     nbVar = nbVarJoints;
%     figure;
%     
%     for n=7: 6+nbVar
%       subplot(nbVar, 1, n-6);
%       hold on;
%       plotGMM(Mu([1,n+1],:), Sigma([1,n+1],[1,n+1],:), [0 .8 0], 1);
%       plot(Data(1,:), Data(n+1,:), 'x', 'markerSize', 4, 'color', [.3 .3 .3]);
%       axis([min(Data(1,:)) max(Data(1,:)) min(Data(n+1,:))-0.01 max(Data(n+1,:))+0.01]);
%       xlabel('t','fontsize',16); ylabel(['x_' num2str(n)],'fontsize',16);
%     end
%     
%     
%     
%      plotGMM(Mu([plotDim],:), Sigma([plotDim],[plotDim],:), [.8 0 0], 1);
% 
%     plot(Data(input_x,1:numPoints/numDemo), Data(input_y, 1:numPoints/numDemo), 'r');
%     plot(Data(input_x,numPoints/numDemo + 1: 2 * numPoints/numDemo), Data(input_y, numPoints/numDemo + 1: 2*numPoints/numDemo), 'b');
%     plot(Data(input_x,2 * numPoints/numDemo + 1:numPoints), Data(input_y, 2 * numPoints/numDemo + 1:numPoints), 'g');
% 
%    
%     plot(Data(1,numPoints/numDemo), Data(2, numPoints/numDemo), 'ro'); hold on;
%     plot(Data(1,numPoints/numDemo * 2), Data(2, numPoints/numDemo * 2), 'bo'); hold on;
%     plot(Data(1,numPoints/numDemo * 3), Data(2, numPoints/numDemo * 3), 'go'); hold on;
%     xlabel('x','fontsize',16); ylabel('y','fontsize',16);
    
pause;
close all;

end        
