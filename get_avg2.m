function y = get_avg2(beg,pred,mea)
    dim = size(mea);
    jmp = 24;
    num = 0;
    sum = 0;
        for row=beg:jmp:dim(1)
            sum = sum + mea(row,:)./pred(row,:);
            num = num + 1;
        end

        y = sum/num;
end