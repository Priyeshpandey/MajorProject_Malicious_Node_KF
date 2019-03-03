% 100 * 100 m2 wireless sensor network deployment
% Density = 30 nodes: CH=1 and SN=29
% malicious nodes (mn) = 20% of 29 SN
% CH is genuine
function [] = deployment(mn,sn,detect) 
clc; 
%mn=1; % malicious node
%sn=8; % sensor node
x=randi([0,100],1,sn); % x coordinate of a sn
y=randi([0,100],1,sn); % y coordinate of a sn
%z=randi([0,sn],1,length(mn)); % malicious nodes index values (as per percentage 20%)
plot(x,y,'mo',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[.17 0.66 .83],...
    'MarkerSize',10)
legend('SN')
for i=1:length(detect)  %Detected malicious are colored red
      draw_circle1(x(detect(i)),y(detect(i)),6,'r') 
end

for i=1:length(mn)  %Actual malicious are colored black
      draw_circle1(x(mn(i)),y(mn(i)),4,'k') 
end
% for j=1:sn     
%     for k=1:mn
%     if z(k)==j
%     draw_circle1(x(j),y(j),5,'k')
%     end
%     end 
% end
grid on
figure(1) % Hold figure 1
hold on