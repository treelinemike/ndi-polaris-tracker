% restart
close all; clear all; clc;

% options
doShowAllPlots = 0;

% load data
allData = load('medtronic_data_1_identify.csv');
allRelDist = [];
allRelXYZ = [];

for rowIdx = 1:size(allData,1)
    absLocs = reshape(allData(rowIdx,:),3,[]);
    meanLoc = mean(absLocs,2);
    relLocs = absLocs - meanLoc;
    relDists = vecnorm(relLocs,2,1);  % 2-Norm along columns
    [sortRelDist,relDistSortIdx] = sort(relDists);
    allRelDist(end+1,:) = sortRelDist;
    sortedLocs = absLocs(:,relDistSortIdx);
    
    [vec val] = eig(relLocs*relLocs');
    
    % rearrange eigenvectors in order of decreasing eigenvalues
    % so x axis has the largest variation, and z axis has the least
    [valSort, valSortIdx] = sort(diag(val),'descend');
    vecSort = vec(:,valSortIdx);
    
    % make sure that eigenvectors are pointing in generally the right
    % directions
    % assumptions:
    %   - array on pointer device is taller than it is wide
    %   - x axis along the eigenvector with the largest eigenvalue, positive generally aligned with the tracker NEGATIVE x axis (points away from tip)
    %   - z axis along the eigenvector with the smallest eigenvalue, positive pointing generally toward tracker head
    if(vecSort(1,1) > 0)
        vecSort = vecSort*diag([-1 1 1]);
    end
    if(vecSort(3,3) < 0)
        vecSort = vecSort*diag([1 1 -1]);
    end
    
    % make sure y axis is consistent (right-handed CS)
    vecSort(:,2) = cross(vecSort(:,3),vecSort(:,1));
    
    % transform data into local CS
    localPts = (vecSort')*relLocs(:,relDistSortIdx);
    
    % store local data
    allRelXYZ(end+1,:) = reshape(localPts,1,[]);
    
    % show each frame if desired
    if(doShowAllPlots)
        hold off;
        for i = 1:3:size(allRelXYZ,2)
            plot3(allRelXYZ(:,i),allRelXYZ(:,i+1),allRelXYZ(:,i+2),'k.','MarkerSize',10);
            hold on;
        end

        for locIdx = 1:size(sortedLocs,2) % in a loop for colors...
            plot3(localPts(1,locIdx),localPts(2,locIdx),localPts(3,locIdx),'.','MarkerSize',25);
        end
        
        grid on;
        
        view([270,90]);
        axis equal;
        xlabel('x');
        ylabel('y');
        zlabel('z');
        xlim([-200,200]);
        ylim([-200,200]);
        zlim([-200,200]);
        
        drawnow;
%         pause(0.1);
    end
end


% show all data overlaid in local CS
figure;
hold on; grid on;
for i = 1:3:size(allRelXYZ,2)
    plot3(allRelXYZ(:,i),allRelXYZ(:,i+1),allRelXYZ(:,i+2),'.','MarkerSize',15);
end
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');
view([130,34]);
xlim([-200,200]);
ylim([-200,200]);
zlim([-200,200]);

% compute estimated marker locations relative to centroid
% in local coordinate system
% for now we just average the marker locations over all available data
% but in the future an optimization routine might be more accurate
estimate = reshape(mean(allRelXYZ),3,[])'

% ground truth, relative to centroid
groundTruth = [160,0,0;230,0,0;305,0,0;263.67,-43.49,0;256,42.71,0];  % from Xiaoyao
groundTruth = groundTruth-repmat(mean(groundTruth),size(groundTruth,1),1);

% align estimate with ground truth to see how close we came (measured by RMSE)
[tform,movingReg,rmse] = pcregistericp(pointCloud(estimate),pointCloud(groundTruth));%,'InitialTransform',affine3d([-1 0 0 0; 0 -1 0 0; 0 0 1 0; 0 0 0 1]));
rmse

% plot results
plot3(movingReg.Location(:,1),movingReg.Location(:,2),movingReg.Location(:,3),'r+','MarkerSize',5);
plot3(groundTruth(:,1),groundTruth(:,2),groundTruth(:,3),'bo','MarkerSize',5);
% [~,sidx] = sort(estimate(:,1));
% est2 = estimate(sidx,:)
% est2 = est2 - repmat([est2(1,1) 0 0],5,1)
% [~,sidx] = sort(groundTruth(:,1));
% gt2 = groundTruth(sidx,:);
% gt2 = gt2 - repmat([gt2(1,1) 0 0],5,1)
