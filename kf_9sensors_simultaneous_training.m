clc;
clear
filename = 'AirQualityUCI3.xlsx';   %Air quality Data
exelrange = 'D9:L176'; % 1 week data 9 sensors selected
%Testing the kalman algo on 9 sensors data simultaneously. Multivariate
measurement = xlsread(filename,exelrange); %Measured value / per hour for one week 168 hours.
%% Data Filtering
%Count all the missing and negative values and replace it with global average
missing_measurement = isnan(measurement);
negative_measurement = (measurement < 0);
count_missing = sum(missing_measurement + negative_measurement);    %Count number of all invalid data
temp_measure = measurement.*(~negative_measurement);                %Removing negatives from data
avg = sum(temp_measure,'omitnan')./(length(measurement) - count_missing);
dimension = size(measurement);                                      %Data Dimension
for col=1:dimension(2)                                              %Replace missing values with global average
    for row=1:dimension(1)
        if missing_measurement(row,col) == 1 || negative_measurement(row,col) == 1
            measurement(row,col) = avg(col);
        end
    end
end
%% Missing values and negative values are replaced with global average.
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
%%
for row=1:24
    ratio_avg(row,:) = get_avg2(row,prediction,measurement);
end

for row=0:dimension(1)-1
    prediction(row+1,:) = ratio_avg(mod(row,24)+1,:).*prediction(row+1,:);
end


    
