function [y,std] = get_avg2(beg,pred,mea)
    dim = size(mea);
    jmp = 24;
    num = 0;
    sum = 0;
    sqsum=0;
        for row=beg:jmp:dim(1)
            sum = sum + mea(row,:);
            num = num + 1;
        end
        avg = sum/num;
        sum = 0;
        num = 0;
        for row=beg:jmp:dim(1)
            sum = sum + mea(row,:)./pred(row,:);
            sqsum = sqsum + ((mea(row,:)-avg).^2);
            num = num + 1;
        end

        y = sum/num;
        std = sqrt(sqsum/num);
end