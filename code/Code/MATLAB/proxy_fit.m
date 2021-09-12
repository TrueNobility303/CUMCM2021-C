clc;
load datas.mat
K = 4; %试验得可取出4家公司的数量最优解
Xx = [1:10:6000]'; 

for i = 1:402
    if S_Class(i) == 'B' % 据理论分析，应该选择A或C供应商以最优化
        s_max(i)=-1;p_max(i)=-1;continue
    end
    [s_max(i),I] = max(SB_proxy(i,[1:10:min([6000,S_max(i)])]'));
    p_max(i) = Xx(I);
    [~,sigma2(i)] = SB_proxy(i,p_max(i));
end

[s_max,I] = sort(s_max,'descend');
p_max=p_max(I);
s_max = s_max(1:K);
p_max = p_max(1:K);
sigma2 = sigma2(1:K);
I = I(1:K);

s_max
sigma2
s_max' .* density_vec(I)

for i = 1:K
    figure(i);
    scatter(Book_matrix(I(i),:), ...
            Supply_matrix(I(i),:));
    hold("on");
    plot(Xx,SB_proxy(I(i),Xx));
    scatter(p_max(i),s_max(i));
end