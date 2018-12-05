%%Main File for Kalman Filtering and training of seasonal factors

clc;
clear
filename = 'AirQualityUCI3.xlsx';   %Air quality Data
exelrange = 'E9:M176'; % 1 week data 9 sensors selected
%Testing the kalman algo on 9 sensors data simultaneously. Multivariate
measurement = xlsread(filename,exelrange); %Measured value / per hour for one week 168 hours.
%% Data Filtering
%Count all the missing and negative values and replace it with global average
missing_measurement = isnan(measurement);
negative_measurement = (measurement < 0);
count_missing = sum(missing_measurement + negative_measurement);    %Count number of all invalid data
temp_measure = measurement.*(~negative_measurement);                %Removing negatives from data
dimension = size(measurement);                                      %Data Dimension
% avg = zeros(24,dimension(2));                                       %Calculating seasonal average
% 
% sum = 0;
% for col=1:dimension(2)
%    for s=1:24
%        num = 0;
%        sum = 0;
%        for row=s:24:dimension(1)
%            if missing_measurement(row,col) == 1 || negative_measurement(row,col) == 1
%                num = num+1;
%            else
%                sum = sum + measurement(row,col);
%            end
%        end
%        avg(s,col) = sum/(7-num);
%    end
%     
% end

avg = sum(temp_measure,'omitnan')./(length(measurement) - count_missing);
%Global average
for col=1:dimension(2)        %Replace missing values with global average
    for row=1:dimension(1)
        if missing_measurement(row,col) == 1 || negative_measurement(row,col) == 1
            measurement(row,col) = avg(col);
        end
    end
end
%% Missing values and negative values are replaced with seasonal average.
sensor_error = 0.01*ones(1,dimension(2)); %Sensor error (measurement error) for each sensor is assumed to be 1% (constant)
estimation = ones(1,dimension(2));  %Initial estimate for all sensors is arbitrarily taken as 1 (constant)
estimat_error = 0.1*ones(1,dimension(2)); %Error in estimation initially taken  10%
estimation_error = zeros(dimension);      %Recording error
KG = zeros(dimension);                    %Recording Kalman gain
prediction = zeros(dimension);            %Recording Predictions 
ratio_avg = zeros(24,dimension(2));       %Seasonality factors
%ismalicious = zeros(length(mea),1);
kg = ones(1,dimension(2));                %Initial Kalman gain

%% Running Kalman filter
    for row=1:dimension(1)
        if (row>3)
            estimation = (0.4*prediction(row-3,:) + 0.6*prediction(row-2,:) + 0.8*prediction(row-1,:))/1.8;
            estimat_error = ((0.4^2)*estimation_error(row-3,:) + (0.6^2)*estimation_error(row-2,:) + (0.8^2)*estimation_error(row-1,:))/(0.4^2+0.6^2+0.8^2);
        end
        kg = estimat_error./(estimat_error + sensor_error);
        KG(row,:) = kg;
        estimation = estimation + kg.*(measurement(row,:) - estimation);
        prediction(row,:) = estimation;
        estimat_error = (1-kg).*estimat_error;
        estimation_error(row,:) = estimat_error;
        %curr_error = (mea(k) - est_rh)/mea(k);
        %ismalicious(k) = curr_error > error_th;
    end
%% Calculating threshold for error
error_threshold = zeros(24,dimension(2));

for row=1:24
    [ratio_avg(row,:),error_threshold(row,:)] = get_avg2(row,prediction,measurement);
end

%% Correcting KF for seasonal Variation
for row=0:dimension(1)-1
    prediction(row+1,:) = ratio_avg(mod(row,24)+1,:).*prediction(row+1,:);
end

%% Malicious Node Detection
error_calculated = 0;
malnode = zeros(dimension);
%malnode = malnode + missing_measurement + negative_measurement; %Counting missing and negative measurements as malicious.
for row=0:dimension(1)-1    %Counting measurements which are erroneous
    error_calculated = abs(measurement(row+1,:) - prediction(row+1,:));
    malnode(row+1,:) = malnode(row+1,:) + (error_calculated > 2*error_threshold(mod(row,24)+1,:));
end
