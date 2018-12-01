clc;
clear
fnm = 'AirQualityUCI3.xlsx';
rh = 'D:D';
RH = xlsread(fnm,rh);
%testing the kalman algo on 100 data points. Univariate
mea = RH(1:250); %Measured value / per hour
R_mea = 0.01*mea;%rand(length(mea),1).*mea/100;
est_rh = 1.0;  % A random initial estimate
est_error = 0.01; % 2
prediction = zeros(length(mea),1);
%ismalicious = zeros(length(mea),1);
KG = 1;
%error_th = 0.2; % 20 percent error threshold arbitrarily chosen
%curr_error = 0;

for k=1:250
    if (k~=1)
        est_rh=0.83*prediction(k-1);
    elseif (k==8 || k==18)
            est_rh=1.2*prediction(k-1);
    end
    KG = est_error/(est_error + R_mea(k));
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

    
