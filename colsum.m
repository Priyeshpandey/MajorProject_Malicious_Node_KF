%colsum
function y = colsum(A)
    n = size(A);
    y = zeros(n(1),1);
    for i=1:n(1)
        y(i) = sum(A(i,:));
    end
        
end