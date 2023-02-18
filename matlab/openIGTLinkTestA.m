% test catching TCP packets from PLUS server
% plots STL files for chicken foot and butterfly tools in quasi real time
%
% author: m. kokko
% updated: 17-may-2022

% restart
close all; clear; clc;

% options
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
view([30 30]); % TODO: MATLAB plot manipulation tools not great, may not be able to achieve desired angle, instead transform everything to a nicer frame?

% open socket to PLUS server
openIGTLinkClient = tcpclient('127.0.0.1',18944);

% impementing a really hackish FIFO queue
% TODO: make this more robust, don't rely on changing size of data structure
data_queue = [];

% loop through all data
keep_running_flag = true;
while(keep_running_flag)

    % read any/all data available from buffer
    data = read(openIGTLinkClient);
    if(length(data) ~= 0 && ~mod(length(data),106))
        for i = 0:106:(length(data)-1)
            data_queue(end+1,:) = data(i+(1:106)); % yuck!
        end
    end

    % process packet
    new_transform_flag = false;
    if(~isempty(data_queue))

        % pop the next packet off the FIFO queue
        this_packet_data = data_queue(1,:);
        data_queue(1,:) = []; % yuck!

        % get packet version
        igtlinkver = swapbytes(typecast(uint8(this_packet_data(1,1:2)),'uint16')) + 1; % zero indexed, so add one to get actual version number
        if(igtlinkver ~= 2)
            fprintf('Received header version #%d\n',igtlinkver);
        end

        % extract header and transform information
        switch(igtlinkver)

            % process packet if version 2
            % ref: http://openigtlink.org/protocols/v2_header.html
            case 2
                type = char(this_packet_data(1,3:14));
                device_name = char(this_packet_data(1,15:34));
                if(nnz(device_name) > 0) % sometimes we get packets with invalid device names
                    timestamp_unix = swapbytes(typecast(uint8(this_packet_data(1,35:38)),'uint32'));
                    timestamp_matlab = datetime(timestamp_unix,'ConvertFrom','posixtime','TimeZone','UTC');
                    timestamp_frac = swapbytes(typecast(uint8(this_packet_data(1,39:42)),'uint32')); % is this actually a float32?
                    body_size = swapbytes(typecast(uint8(this_packet_data(1,43:50)),'uint64'));
                    crc64 = swapbytes(typecast(uint8(this_packet_data(1,51:58)),'uint64'));

                    % grab transform
                    tf_vector = nan(12,1);
                    tf_idx = 1;
                    for offset = 58:4:102%0:1:(size(data_matrix,2)-4)
                        bytes = this_packet_data(1,offset + [1:4]);
                        val = swapbytes(typecast(uint8(bytes),'single'));
                        tf_vector(tf_idx,1) = val;
                        tf_idx = tf_idx + 1;
                        %     fprintf('%d: %f\n',offset,val);
                    end
                    TF = [reshape(tf_vector,[3,4]); zeros(1,3) 1];
                    new_transform_flag = true;
                end % end process only valid-named devices
                
            otherwise
                % no other packet version supported yet...
                fprintf('IGT Link Header Version %d not supported yet!\n',igtlinkver);
        end

        % update display
        if(new_transform_flag)
            switch(device_name)
                case 'ChickenFootProbeToTr'
                    ph_chxft.Vertices = hTF(stl_chxft.Points',TF,0)';
                    %fprintf('chx/%d\n',body_size);
                case '9730605ProbeToTracke'
                    ph_btfly.Vertices = hTF(stl_btfly.Points',TF,0)';
                    %fprintf('but/%d\n',body_size);
                case 'NeedleToTracker'
                    fprintf('Aurora coil\n');
                otherwise
                    fprintf('Unknown tool: %s\n',device_name);
                    TF
            end
            drawnow;
        end % end update display
    end % end process non-empty data packet
end % end looping through all data packets

% have to run this manually if while(1) above...
clear openIGTLinkClient;



