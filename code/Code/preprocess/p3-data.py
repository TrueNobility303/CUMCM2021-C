import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 
#读取数据并输出

sExcelFile_1 = 'data\p3_supply_prob.xlsx'
df = pd.read_excel(sExcelFile_1,sheet_name=0,engine='openpyxl')

array_supply = np.array(df)
print(array_supply.shape)
s = np.sum(array_supply,1)
print(s.shape)

c = []
for i in range(0,401):
    if s[i] == 0:
        continue
    else:
        c.append(i+1)
print(c)

new_array = array_supply[c]
print(new_array)

#writer = pd.ExcelWriter('data\p3_nonzero_supply.xlsx')
#data = pd.DataFrame(new_array)
#data.to_excel(writer)
#writer.save()
#writer.close()