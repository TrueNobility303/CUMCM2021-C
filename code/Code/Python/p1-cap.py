import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 

#读取数据并输出

sExcelFile_1 = 'data\data1.xlsx'
sExcelFile_2 = 'data\data2.xlsx'
df_order = pd.read_excel(sExcelFile_1,sheet_name=0,engine='openpyxl')
df_supply = pd.read_excel(sExcelFile_1,sheet_name=1,engine='openpyxl')
df_transport = pd.read_excel(sExcelFile_2,sheet_name=0,engine='openpyxl')

array_order = np.array(df_order)[:-2,:]
# 出现两行NAN值，预先去除
array_supply = np.array(df_supply)
array_transport = np.array(df_transport)

# ABC三类原材料
#print(array_supply[:,1])

print(array_supply.shape) #(402,242)

# 第一列：名称
# 第二列：类别

array_cap = np.zeros(240)

cap = 0
for j in range(2,242):
    for i in range(0,402):
        ty = array_supply[i,1]
        if ty == 'A':
            cap += array_supply[i,j] / 0.6
        elif ty == 'B':
            cap += array_supply[i,j] / 0.66
        elif ty == 'C':
            cap += array_supply[i,j] / 0.72
    cap -= 28200
    array_cap[j-2] = cap
print(array_cap)
plt.plot(array_cap)
plt.show()

cap = 0
for j in range(2,242):
    for i in range(0,402):
        ty = array_order[i,1]
        if ty == 'A':
            cap += array_order[i,j] / 0.6
        elif ty == 'B':
            cap += array_order[i,j] / 0.66
        elif ty == 'C':
            cap += array_order[i,j] / 0.72
    cap -= 28200
    array_cap[j-2] = cap
print(array_cap)
plt.plot(array_cap)
plt.show()





