function y = get_avg(beg,pred,mea)
    jmp = 24;
    num = 0;
    sum = 0;
    for k=beg:jmp:length(mea)
        sum = sum + mea(k)/pred(k);
        num = num + 1;
    end
    
    y = sum/num;
end