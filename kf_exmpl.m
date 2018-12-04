clc;
clear
fnm = 'AirQualityUCI3.xlsx';
rh = 'G:G';
RH = xlsread(fnm,rh);
%testing the kalman algo on 100 data points. Univariate
mea = RH(8:247); %Measured value / per hour
mea = mea.*(mea>0) + 0.0001;
R_mea = 0.01;%rand(length(mea),1).*mea/100;
est_rh = 11.0;  % A random initial estimate
est_error = 0.1; % 2
estr = zeros(length(mea),1);
kgV = zeros(length(mea),1);
prediction = zeros(length(mea),1);
ratio_avg = zeros(24,1);
%ismalicious = zeros(length(mea),1);
KG = 1;
%error_th = 0.2; % 20 percent error threshold arbitrarily chosen
%curr_error = 0;

for k=1:240
    if (k>3)
        est_rh = (0.4*prediction(k-3) + 0.6*prediction(k-2) + 0.8*prediction(k-1))/1.8;
        est_error = ((0.4^2)*estr(k-3) + (0.6^2)*estr(k-2) + (0.8^2)*estr(k-1))/(0.4^2+0.6^2+0.8^2);
    end
    KG = est_error/(est_error + R_mea);
    kgV(k) = KG;
    est_rh = est_rh + KG*(mea(k) - est_rh);
    prediction(k) = est_rh;
    est_error = (1-KG)*est_error;
    estr(k) = est_error;
    %curr_error = (mea(k) - est_rh)/mea(k);
    %ismalicious(k) = curr_error > error_th;
end

for k=1:24
    ratio_avg(k) = get_avg(k,prediction,mea);
end

for k=0:239
    prediction(k+1) = ratio_avg(mod(k,24)+1)*prediction(k+1);
end

plot(mea);
hold on
plot(prediction);
%stairs(ismalicious);
%ylim([-1 2]);

    
