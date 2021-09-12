%已得到转运损耗量波动模拟后，计算问题2第二部分的蒙特卡罗模拟

load MC.mat

for i = 1:10000
    for j = 1:4
        MC2_T_result(i,j,:) = Wdata(j,:) .* sum( reshape(P2_T(j,:,:),[8 24]) .* (1-0.01.*reshape(MC2_T_sim(i,:,:),[8 24])));
    end
end

MC2_T_res = MC2_T_result- reshape(Wdata,[1,4,24]);
