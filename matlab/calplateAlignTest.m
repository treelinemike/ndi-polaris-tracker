% restart
close all; clear; clc;

% define some points
marker_nom_locs = [16.5 16.5 0; -21 16.5 0; -58.5 16.5 0; 25 -76.5 0; -42 -76.5 0];

% compute minimum PE
centroid = mean(marker_nom_locs);
rel_locs = marker_nom_locs - centroid

plot(rel_locs(:,1),rel_locs(:,2),'r.','MarkerSize',20); grid on; hold on; axis equal;