% Pen probe calibration routine for NDI Polaris Optical Tracking system
%
% xOpt = ndi_optical_probe_tip_cal_numerical( filename, printResults, showPlots, outFilename )
%        xOpt:         optimal location (3D position) of probe tip in local coordinate system
%        printResults: (optional) if nonzero, function will display text results in terminal
%        showPlots:    (optional) if nonzero, function will show calibration plot
%        outFilename:  (optional) file name to write data to
%
% Takes a series of 3D positions (x,y,z) and orientation quaternions (q0,q1,q2,q3)
% and finds the best (min SSE) choice of an invarient point in the local coordinate
% system.
%
% Optimization is performed numerically (rather than analyticalwebly) via
% fminsearch()
%
% Modified: 20210511
% Author:   Mike Kokko

function [xOpt,rmse,sse] = ndi_optical_probe_tip_cal_numerical(filename,varargin)

% parse optional display flag arguments
switch(length(varargin))
    case 0
        printResults = 0;
        showPlots = 0;
        outFilename = '';
    case 1
        printResults = varargin{1};
        showPlots = 0;
        outFilename = '';
    case 2
        printResults = varargin{1};
        showPlots = varargin{2};
        outFilename = '';
    case 3
        printResults = varargin{1};
        showPlots = varargin{2};
        outFilename = varargin{3};
    otherwise
        error('Too many arguments provided.');
end

% read tracker data from file
fileIn = fopen(filename,'r');

% discard one header line
readResult = fgetl(fileIn);

% extract lines from datafile, neglecting rows with missing data
allData = zeros(0,7);
readResult = fgetl(fileIn);
while ( readResult ~= -1)
    if(~contains(readResult,'MISSING'))
        allData(end+1,:) = cell2mat(textscan(readResult,'%*f %*f %*c %f %f %f %f %f %f %f %*f %*f %*f %*f','Delimiter',',','CollectOutput',1));
    end
    readResult = fgetl(fileIn);
end

% close file
fclose(fileIn);

% function to pass data to cost function
f = @(x_local)probeError(allData(:,5:7)',allData(:,1:4)',x_local);

% run optimization and display result, along with RMS error
% options = optimoptions('fminunc','MaxIterations',4000,'OptimalityTolerance',1e-12,'StepTolerance',1e-12);
% [xOpt, sse] = fminunc(f,[0 0 0]',options);
[xOpt, sse] = fminsearch(f,[0 0 0]');

rmse = sqrt(sse/size(allData,1));

if(printResults)
    fprintf('Probe Tip in Local CS: < %+8.3f, %+8.3f, %+8.3f >\n',xOpt);
    fprintf('RMSE (mm):  %8.3f\nSSE (mm^2): %8.3f\n',rmse,sse);
end

% show resulting rays
if(showPlots)
    figure;
    hold on; grid on;
    for pointIdx = 1:size(allData,1)
        x = allData(pointIdx,5:7);
        q = allData(pointIdx,1:4)';
        u = quatrotate(q,xOpt);
        plot3([x(1) x(1)+u(1)],[x(2) x(2)+u(2)],[x(3) x(3)+u(3)],'r-','LineWidth',1.6);
        plot3(x(1),x(2),x(3),'b.','MarkerSize',25);
    end
    title({sprintf('Optical Tracker Probe Tip Calibration (RMSE = %0.3fmm)',rmse);[filename]},'Interpreter','none');
    axis image;
end

if( ~isempty(outFilename) )
    if(isfile(outFilename))
        warning('File exists! Not overwriting it!');
    else
        fprintf('Writing %s\n',outFilename);
        fid = fopen(outFilename,'w');
        fprintf(fid,'%+0.4f,%+0.4f,%+0.4f',xOpt);
        fclose(fid);
    end
end
end

% emperical evaluation of cost function
% there may be a closed-form solution to this
% trying to find the value of x_local that minimizes J (RMSE)
function J = probeError(allX,allQ,x_local)

% first compute global endpoint positions under assumed
% local endpoint position x0
allPoints = zeros(size(allX));
for obsIdx = 1:size(allX,2)
    x = allX(:,obsIdx);  % extract position
    q = allQ(:,obsIdx);  % extract orientation quaternion
    allPoints(:,obsIdx) = x+quatrotate(q,x_local);
end

% compute sum of squared displacements from mean
p = allPoints - sum(allPoints,2)/size(allPoints,2);
J = trace(p*p');
end

% perform quaternion rotation
% essentially using angle (theta) and axis (u, a unit vector) of rotation
% q =     q0     +     q123
% q = cos(theta) + sin(theta)*u
% note: MATLAB includes a similar function in the aerospace toolbox, but
% this is not part of the Dartmouth site license
function v_out = quatrotate(q_in,v_in)

% make sure q_in and v_in are the correct length and shape
if (numel(q_in) == 4)
    q_in = reshape(q_in,4,1);
else
    error('Quaternion must have 4 elements.');
end
if (numel(v_in) == 3)
    v_in_size = size(v_in);
    v_in = reshape(v_in,3,1);
else
    error('Vector to rotate must have 3 elements.');
end

% normalize quaternion (it should be very close to a unit quaternion anyway...)
q_in = q_in/norm(q_in);

% extract scalar and vector parts of quaternion
q0   = q_in(1);   % real (scalar) part of quaternion
q123 = q_in(2:4); % imaginary (vector) part of quaternion

% rotate v_in using point rotation: v_out = q * v_in * conj(q)
% q_out = quatmult(q_in,quatmult([0; v_in],quatconj(q_in)))
% v_out = q_out(2:4)
% Simplification from Kuipers2002: Quaternions and Rotation Sequences: A Primer with Applications to Orbits, Aerospace and Virtual Reality
v_out = (q0^2-norm(q123)^2)*v_in + 2*dot(q123,v_in)*q123 + 2*q0*cross(q123,v_in);

end