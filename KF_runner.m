
for k=1:dimension(2)
    figure
    plot(measurement(:,k));
    hold on
    plot(prediction(:,k));
    title(k)
    hold off
end