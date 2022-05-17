% restart
close all; clear; clc;

stl_chxft = stlread('medtronic_chicken_foot.STL');
stl_btfly = stlread('medtronic_9730605_equiv_a.STL');

figure;
hold on; grid on; axis equal;
patch('Faces',stl_chxft.ConnectivityList,'Vertices',stl_chxft.Points,'FaceColor',[0.8 0.2 0.2],'EdgeColor',[0 0 0],'LineWidth',0.5);


figure;
hold on; grid on; axis equal;
ph_chxft = patch('Faces',stl_chxft.ConnectivityList,'Vertices',nan(size(stl_chxft.Points)),'FaceColor',[0.8 0.2 0.2],'EdgeColor',[0 0 0],'LineWidth',0.5);
ph_btfly = patch('Faces',stl_btfly.ConnectivityList,'Vertices',nan(size(stl_btfly.Points)),'FaceColor',[0.8 0.2 0.2],'EdgeColor',[0 0 0],'LineWidth',0.5);
xlim([-500 500]);
ylim([-500 500]);
zlim([-2800 -1600]);
view([30 30]);

%%
openIGTLinkClient = tcpclient('127.0.0.1',18944);
data_matrix = [];
while(1)
    data = read(openIGTLinkClient);
    if(~isempty(data))
        data
        data_matrix(end+1,:) = data;
    end
end
clear openIGTLinkClient;
save('matlab_data.mat','data_matrix');

%% Open IGT Link v2.0 Message Framing
% ref: http://openigtlink.org/protocols/v2_header.html
load('matlab_data.mat');
row_idx = 2;

igtlinkver = swapbytes(typecast(uint8(data_matrix(row_idx,1:2)),'uint16')) + 1 % zero indexed, so add one to get actual version number
type = char(data_matrix(row_idx,3:14))
device_name = char(data_matrix(row_idx,15:34))
timestamp_unix = swapbytes(typecast(uint8(data_matrix(row_idx,35:38)),'uint32'));
timestamp_matlab = datetime(timestamp_unix,'ConvertFrom','posixtime','TimeZone','UTC')
timestamp_frac = swapbytes(typecast(uint8(data_matrix(row_idx,39:42)),'uint32'))
body_size = swapbytes(typecast(uint8(data_matrix(row_idx,43:50)),'uint64'));
crc64 = swapbytes(typecast(uint8(data_matrix(row_idx,51:58)),'uint64'));

tf_vector = nan(12,1);
tf_idx = 1;
for offset = 58:4:102%0:1:(size(data_matrix,2)-4)
    bytes = data_matrix(row_idx,offset + [1:4]);
    val = swapbytes(typecast(uint8(bytes),'single'));
    tf_vector(tf_idx,1) = val;
    tf_idx = tf_idx + 1;
%     fprintf('%d: %f\n',offset,val);
end
TF = [reshape(tf_vector,[3,4]); zeros(1,3) 1];
ph_chxft.Vertices = hTF(stl_chxft.Points',TF,0)';

