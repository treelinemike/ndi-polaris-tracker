% restart
close all; clear all; clc;

% options
doShowPlots = 0;

% load data
allData = load('medtronic_test_a.csv');
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
    [valSort valSortIdx] = sort(diag(val),'descend')
    vecSort = vec(:,valSortIdx);
    
    localPts = (vecSort')*relLocs(:,relDistSortIdx);
    
    % flip x axis if not pointing toward the closest point along
    if (min(abs(localPts(1,(localPts(1,:)<0)))) > min(localPts(1,(localPts(1,:)>0))))
        vecSort = vecSort*diag([-1 1 1]);
    end
    
    % flip y axis if not pointing toward the closest point along
    if (min(abs(localPts(2,(localPts(2,:)<0)))) > min(localPts(2,(localPts(2,:)>0))))
        vecSort = vecSort*diag([1 -1 1]);
    end
    
    % make sure z axis is consistent (right-handed CS)
    vecSort(:,3) = cross(vecSort(:,1),vecSort(:,2));
    
    % recalculate local points with adjusted coordinate system
    localPts = (vecSort')*relLocs(:,relDistSortIdx);
    
    allRelXYZ(end+1,:) = reshape(localPts,1,[]);
    
    if(doShowPlots)
        hold off;
        %     plot3(sortedLocs(1,:),sortedLocs(2,:),sortedLocs(3,:),'.','MarkerSize',25);
        for locIdx = 1:size(sortedLocs,2)
            %         plot3(sortedLocs(1,locIdx),sortedLocs(2,locIdx),sortedLocs(3,locIdx),'.','MarkerSize',25);
            plot3(localPts(1,locIdx),localPts(2,locIdx),localPts(3,locIdx),'.','MarkerSize',25);
            
            hold on;
        end
        %     vec = vec*100;
        %     plot3(meanLoc(1),meanLoc(2),meanLoc(3),'k*','MarkerSize',10);
        %     plot3(meanLoc(1)+[0 vec(1,1)],meanLoc(2)+[0 vec(2,1)],meanLoc(3)+[0 vec(3,1)],'r-');
        %     plot3(meanLoc(1)+[0 vec(1,2)],meanLoc(2)+[0 vec(2,2)],meanLoc(3)+[0 vec(3,2)],'g-');
        %     plot3(meanLoc(1)+[0 vec(1,3)],meanLoc(2)+[0 vec(2,3)],meanLoc(3)+[0 vec(3,3)],'b-');
        
        
        grid on;
        %     view([100,50]);
        %         view([128,10]);
        view([90,0]);
        axis equal;
        xlabel('x');
        ylabel('y');
        zlabel('z');
        %     xlim([-400,0]);
        %     ylim([-200,200]);
        %     zlim([-2100,-1800]);
        
        xlim([-200,200]);
        ylim([-200,200]);
        zlim([-200,200]);
        
        pause(0.1);
    end
end


figure; hold on; grid on;
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
reshape(mean(allRelXYZ),3,[])'
