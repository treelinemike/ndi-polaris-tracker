% Test catching TCP packets from PLUS server
% DOES NOT SEND ACK PACKETS!

% restart
close all; clear; clc;

% options
do_read_from_file = true;
data_file_name = 'openIGTLinkTestData.mat';
stl_chxft = stlread('../tool-defs/medtronic_chicken_foot.STL');
stl_btfly = stlread('../tool-defs/medtronic_9730605_equiv_a.STL');

% initialize plot
figure;
hold on; grid on; axis equal;
ph_chxft = patch('Faces',stl_chxft.ConnectivityList,'Vertices',nan(size(stl_chxft.Points)),'FaceColor',[0.8 0.2 0.2],'EdgeColor',[0 0 0],'LineWidth',0.5);
ph_btfly = patch('Faces',stl_btfly.ConnectivityList,'Vertices',nan(size(stl_btfly.Points)),'FaceColor',[0.8 0.2 0.2],'EdgeColor',[0 0 0],'LineWidth',0.5);
xlim([-500 500]);
ylim([-500 500]);
zlim([-2800 -1600]);
view([30 30]);

% preapare to either read from file or from TCP interface
if(do_read_from_file)
    load(data_file_name);
    file_data = data_matrix;
    file_row_idx = 1;
else
    openIGTLinkClient = tcpclient('127.0.0.1',18944);
end
data_matrix = [];

% loop through all data
keep_running_flag = true;
while(keep_running_flag)

    % get a packet
    if(do_read_from_file)
        data = file_data(file_row_idx,:);
        file_row_idx = file_row_idx + 1;
        if(file_row_idx >= size(file_data,1))
            keep_running_flag = false;
        end
    else
        data = read(openIGTLinkClient);
    end
    
    % process packet
    new_transform_flag = false;
    if(~isempty(data))
        data;
        data_matrix(end+1,:) = data;
        row_idx = size(data_matrix,1);

        % get version
        igtlinkver = swapbytes(typecast(uint8(data_matrix(row_idx,1:2)),'uint16')) + 1; % zero indexed, so add one to get actual version number

        % Extract header and transform information
        switch(igtlinkver)

            % process packet if version 2
            case 2
                % get v2 header information
                % ref: http://openigtlink.org/protocols/v2_header.html
                type = char(data_matrix(row_idx,3:14));
                device_name = char(data_matrix(row_idx,15:34));
                timestamp_unix = swapbytes(typecast(uint8(data_matrix(row_idx,35:38)),'uint32'));
                timestamp_matlab = datetime(timestamp_unix,'ConvertFrom','posixtime','TimeZone','UTC');
                timestamp_frac = swapbytes(typecast(uint8(data_matrix(row_idx,39:42)),'uint32')); % is this actually a float32?
                body_size = swapbytes(typecast(uint8(data_matrix(row_idx,43:50)),'uint64'));
                crc64 = swapbytes(typecast(uint8(data_matrix(row_idx,51:58)),'uint64'));

                % grab transform
                tf_vector = nan(12,1);
                tf_idx = 1;
                for offset = 58:4:102%0:1:(size(data_matrix,2)-4)
                    bytes = data_matrix(row_idx,offset + [1:4]);
                    val = swapbytes(typecast(uint8(bytes),'single'));
                    tf_vector(tf_idx,1) = val;
                    tf_idx = tf_idx + 1;
                    %     fprintf('%d: %f\n',offset,val);
                end
                TF = [reshape(tf_vector,[3,4]); zeros(1,3) 1]
                new_transform_flag = true;

            % no other packet version supported yet...
            otherwise
                fprintf('IGT Link Header Version %d not supported yet!\n',igtlinkver);
        end

        % update display
        if(new_transform_flag)
            switch(device_name)
                case 'ChickenFootProbeToTr'
                    ph_chxft.Vertices = hTF(stl_chxft.Points',TF,0)';
                case '9730605ProbeToTracke'
                    ph_btfly.Vertices = hTF(stl_btfly.Points',TF,0)';
                otherwise
                    fprintf('Unknown tool!');
            end
        end % end update display

    end % end process non-empty data packet
end % end looping through all data packets

% have to run this manually if while(1) above...
clear openIGTLinkClient;
save(data_file_name,'data_matrix');



