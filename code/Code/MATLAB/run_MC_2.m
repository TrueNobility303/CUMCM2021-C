MC2_cost = []
MC2_store=[]
for i = 1:10000
    MonteCarlo2;
    MC2_cost=[MC2_cost,tot_cost];MC2_store=[MC2_store,store];
end

mean(MC2_cost)
std(MC2_cost)

MonteCarlo2_T;