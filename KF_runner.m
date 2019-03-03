%Generate graph for all 9 sensors
[num,strobj,raw] = xlsread('AirQualityUCI3.xlsx','E1:M1');
for k=1:8
    figure
    plot(data(:,k));
    hold on
    plot(prediction(:,k));
    title(strcat('Data : ',strobj(k)))
    xlabel('Time(hr)')
    ylabel('Concentration')
    legend('Actual data','Kalman prediction')
    hold off
end
% Uncomment and run to generate scatter plotfor malicious node detection
%   x = (0:167)'*ones(1,dimension(2));
% figure
% hold on
% for k = 1:dimension(1)
%     scatter(x(k,:),malnode(k,:).*(1:dimension(2)),'o')
% end
% title('Malicious Node Detection')
% xlabel('Time(hr)')
% ylabel('Sensor')
% legend('Malicious')