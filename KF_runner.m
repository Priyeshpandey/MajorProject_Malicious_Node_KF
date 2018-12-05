%%Generate graph for all 9 sensors
% for k=1:dimension(2)
%     figure
%     plot(measurement(:,k));
%     hold on
%     plot(prediction(:,k));
%     title(k)
%     hold off
% end
%Uncomment and run to generate scatter plotfor malicious node detection
  x = (0:167)'*ones(1,9);
figure
hold on
for k = 1:dimension(1)
    scatter(x(k,:),malnode(k,:).*(1:9))
end
