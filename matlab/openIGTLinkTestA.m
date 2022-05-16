% restart
close all; clear; clc;

openIGTLinkClient = tcpclient('127.0.0.1',18944);

while(1)
    data = read(openIGTLinkClient);
    if(~isempty(data))
        data
    end
end
clear openIGTLinkClient;