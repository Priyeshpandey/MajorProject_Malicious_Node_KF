clc;
clear
fnm = 'AirQualityUCI3.xlsx';
rh = 'G:G';
RH = xlsread(fnm,rh);
%testing the kalman algo on 100 data points. Univariate
mea = RH(1:250); %Measured value / per hour
mea = mea.*(mea>0) + 0.0001;
R_mea = 0.01;%rand(length(mea),1).*mea/100;
est_rh = 1.0;  % A random initial estimate
est_error = 0.05; % 2
prediction = zeros(length(mea),1);
%ismalicious = zeros(length(mea),1);
KG = 1;
%error_th = 0.2; % 20 percent error threshold arbitrarily chosen
%curr_error = 0;

for k=1:250
    if (k>3)
        est_rh = (0.4*prediction(k-3) + 0.6*prediction(k-2) + 0.8*prediction(k-1))/1.8;
    end
    KG = est_error/(est_error + R_mea);
    est_rh = est_rh + KG*(mea(k) - est_rh);
    prediction(k) = est_rh;
    est_error = (1-KG)*est_error;
    %curr_error = (mea(k) - est_rh)/mea(k);
    %ismalicious(k) = curr_error > error_th;
end

plot(mea);
hold on
plot(prediction);
%stairs(ismalicious);
%ylim([-1 2]);

    
