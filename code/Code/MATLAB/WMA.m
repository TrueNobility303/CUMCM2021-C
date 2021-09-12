function [y,sigma2] = WMA(X,Y,x)
%WMA 已知X,Y，计算x的对于加权移动平均
% X (N,1), x(n,1), Y(N,1)
N = size(X,1);
n = size(x,1);
% W(n,N)
W = exp(-((X'-x)./500).^2); 
y = W*Y ./ sum(W,2);
sigma2 = sum(W.*((y-Y').^2),2) ./ sum(W,2); %用于试验的方差项；未使用
end
