%Main function

function calModel()
    clc;
    clear;
    delete('data/*.mat');
    path = 'data/';
    numDemo = 3;
    numDim = 12;    % 3 ball position + 3 hand position + 6 joint angles (RSholderPitch, RShoulderRoll, RElbowYaw, RElbowRoll, RwristYaw, RHand, LHip, RHip)
    
    read(path, numDemo, numDim);   
    [Priors, Mu, Sigma] = model('data/raw_all.mat');
    save('data/Priors.mat', 'Priors');
    save('data/Mu.mat', 'Mu');
    save('data/Sigma.mat', 'Sigma');
end