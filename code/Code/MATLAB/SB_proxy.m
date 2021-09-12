% 拟合第i供应商的订-供曲线
function [S,sigma2] = SB_proxy(i,B)
load datas.mat;
X = Book_matrix(i,:)';
[S,sigma2] = WMA(X,Supply_matrix(i,:)',B);
end
