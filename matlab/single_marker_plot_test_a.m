% restart
close all; clear; clc;

tab = readtable('trial019.csv','NumHeaderLines',0,'Delimiter',',');

figure;
hold on; grid on; axis equal;
plot3(tab.Var1,tab.Var2,tab.Var3,'-','LineWidth',1.6,'Color',[0 0 0.8]);

