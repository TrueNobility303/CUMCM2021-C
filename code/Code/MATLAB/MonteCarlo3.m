load datas.mat
load MC.mat

K = 1;

u = zeros(402,1);
u(S_Class=='A') = 1/0.60;
u(S_Class=='B') = 1/0.66;
u(S_Class=='C') = 1/0.72;

w = zeros(402,1);
w(S_Class=='A') = 1.2;
w(S_Class=='B') = 1.1;
w(S_Class=='C') = 1.0;

C = zeros(402,3);
C(:,1) = S_Class=='A';
C(:,2) = S_Class=='B';
C(:,3) = S_Class=='C';

supply = P3_S; % 402x24 供应量
T = P3_T; % 402x24x8 转运关系
A = permute(MC2_T_sim,[1 3 2]); % （转置后）10000x24x8 带有蒙特卡罗模拟的损耗率

small_count = size(Low_ID,1);
small_std = 158.0332 ^ 0.5;

shift_ex = zeros(402,24);
shift_std_avr = shift_std;
shift_std_avr(Low_ID) = small_std/ small_count^0.5;
shift_std_ex = zeros(402,24);

for i = 1 : 24
    shift_ex(:,i) = shift(:);
    shift_std_ex(:,i) = shift_std_avr;
end

MC3_cost = [];
MC3_store = [];

MC3_err_count = 0;
for s = 1:10000
    As = A(s,:,:); % 1 24 8
    S_std = 100 .* ones(size(supply));
    
    supply_S = normrnd(supply-shift_ex,shift_std_ex);
    supply_S(supply_S<0) = 0;
    supply_S(supply_S>6000) = 6000;
    
    %supply_S = supply;
    
    R = sum((1- 0.01.*As).* T .* reshape(supply_S,[402 24 1]),3);
    R = reshape(R,[402 24]);
    if any(R<0)
        error("R<0")
    end
    In = R'*C; 
    
    % In (24 3) 每周 A,B,C 接受量
    tot_cost = sum(K.*(w .* supply_S)+supply_S,'all');
    store = [56400*0.6 0 0 ];
    %In %
    
    err_flag = 0;
    for week = 1:24
        
        tot_cost = tot_cost + sum(store);
        target = 28200;
        A_used = 0; B_used = 0; C_used = 0;
        if store(3)>0
            C_used = min(target, store(3)./0.72);
            target = target - C_used;
            store(3) = store(3) - C_used*0.72;
        end
        if target > 0 && store(2)>0
            B_used = min(target, store(2)./0.66);
            target = target - B_used;
            store(2) = store(2) - B_used*0.66;
        end
        if target > 0 && store(1)>0
            A_used = min(target, store(1)./0.60);
            target = target - A_used;
            store(1) = store(1) - A_used*0.60;
        end
        
        store = store + In(week,:);
        
        if store' * [1/0.6 1/0.66 1/0.72] < 56400
            disp("store < 56400");
            err_flag = 1;
            continue % 继续执行完当前生产过程
        end
    end
    
    MC3_cost = [MC3_cost tot_cost];
    MC3_store = [MC3_store; store];
    if err_flag == 1
        MC3_err_count = MC3_err_count + 1;
    end
end

disp("Finished")
