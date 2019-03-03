%% Testing Data
clc;
clear
filename = 'AirQualityUCI3_original.xlsx';   %Air quality Data
exelr1 = 'E8:E175';
data1 = xlsread(filename,exelr1);
exelr2 = 'G8:H175';
data2 = xlsread(filename,exelr2);
exelr3 = 'J8:J175';
data3 = xlsread(filename,exelr3);
exelr4 = 'L8:M175';
data4 = xlsread(filename,exelr4);
exelr5 = 'O8:P175';
data5 = xlsread(filename,exelr5);
data_orig = horzcat(data1,data2,data3,data4,data5);
data = data_orig;
dim = size(data);
mis_data = isnan(data);
neg_data = (data<0);
invalid_data = sum(mis_data+neg_data);
%% Injecting 20% False values
visited = zeros(dim(1),dim(2));
myset = [6,5,8,10,4];

for i=1:dim(2)
    for k=1:int32(dim(1)*0.02)
        rr = randi(dim(1));
        if visited(rr,i) == 0
            data(rr,i) = data(rr,i)*myset(randi(length(myset)));
            visited(rr,i)=1;
        end
    end
end
injected_count = zeros(1,dim(2)); %sum(visited);
%% Data Filtering
% %Count all the missing and negative values and replace it with global average
% count_missing = sum(mis_data + neg_data);    %Count number of all invalid data
% temp_measure = data_orig.*(~neg_data);                %Removing negatives from data
% avg = sum(temp_measure,'omitnan')./(length(data_orig) - count_missing);
% %Global average
% for col=1:dim(2)        %Replace missing values with global average
%     for row=1:dim(1)
%         if mis_data(row,col) == 1 || neg_data(row,col) == 1
%             data(row,col) = avg(col);
%         end
%     end
% end
%% Missing values and negative values are replaced with seasonal average.
sensor_error = 0.01*ones(1,dim(2)); %Sensor error (data error) for each sensor is assumed to be 1% (constant)
estimation = ones(1,dim(2));  %Initial estimate for all sensors is arbitrarily taken as 1 (constant)
estimat_error = 0.1*ones(1,dim(2)); %Error in estimation initially taken  10%
estimation_error = zeros(dim);      %Recording error
KG = zeros(dim);                    %Recording Kalman gain
prediction = zeros(dim);            %Recording Predictions 
ratio_avg = zeros(24,dim(2));       %Seasonality factors
%ismalicious = zeros(length(mea),1);
kg = ones(1,dim(2));                %Initial Kalman gain
%% Running Kalman filter
    for row=1:dim(1)
        if (row>3)
            estimation = (0.4*prediction(row-3,:) + 0.6*prediction(row-2,:) + 0.8*prediction(row-1,:))/1.8;
            estimat_error = ((0.4^2)*estimation_error(row-3,:) + (0.6^2)*estimation_error(row-2,:) + (0.8^2)*estimation_error(row-1,:))/(0.4^2+0.6^2+0.8^2);
        end
        kg = estimat_error./(estimat_error + sensor_error);
        KG(row,:) = kg;
        estimation = estimation + kg.*(data(row,:) - estimation);
        prediction(row,:) = estimation;
        estimat_error = (1-kg).*estimat_error;
        estimation_error(row,:) = estimat_error;
        %curr_error = (mea(k) - est_rh)/mea(k);
        %ismalicious(k) = curr_error > error_th;
    end
    
%% Calculating threshold for error
error_threshold = zeros(24,dim(2));

for row=1:24
    [ratio_avg(row,:),error_threshold(row,:)] = get_avg2(row,prediction,data);
end
%% Correcting KF for seasonal Variation
for row=0:dim(1)-1
    prediction(row+1,:) = ratio_avg(mod(row,24)+1,:).*prediction(row+1,:);
end
%% Malicious Node Detection
error_calculated = 0;
malnode = zeros(dim);   %No of malicious found
%malnode = malnode + missing_data + negative_data; %Counting missing and negative datas as malicious.
for row=0:dim(1)-1    %Counting datas which are erroneous
    error_calculated = abs(data(row+1,:) - prediction(row+1,:));
    malnode(row+1,:) = (error_calculated > 2.2*error_threshold(mod(row,24)+1,:));
end

%% Performance measure
actual_malicious = visited;
detected = malnode;
correct_detection = (actual_malicious & detected);
actual_num = colsum(actual_malicious);
detect_num = colsum(detected);
correct_detect_num = colsum(correct_detection);
undetect_num = actual_num - correct_detect_num;
mis_detect_num = colsum(xor(actual_malicious,detected)) - undetect_num;