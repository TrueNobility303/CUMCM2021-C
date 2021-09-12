import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 
from sklearn.cluster import KMeans
from sklearn.mixture import GaussianMixture as GMM

#读取数据并输出

sExcelFile_1 = 'data\data1.xlsx'
sExcelFile_2 = 'data\data2.xlsx'
df_order = pd.read_excel(sExcelFile_1,sheet_name=0,engine='openpyxl')
df_supply = pd.read_excel(sExcelFile_1,sheet_name=1,engine='openpyxl')
df_transport = pd.read_excel(sExcelFile_2,sheet_name=0,engine='openpyxl')

# 出现两行NAN值，预先去除
array_order = np.array(df_order)[:-2,:]
array_supply = np.array(df_supply)
array_transport = np.array(df_transport)

#根据种类进行归一化

def scale_by_type(array):
    for i in range(0,402):
        ty = array[i,1]
        if ty == 'A':
            array[i,2:] = array[i,2:] / 0.6
        elif ty == 'B':
            array[i,2:] = array[i,2:] / 0.66
        elif ty == 'C':
            array[i,2:] = array[i,2:] / 0.72
    return array

#进行等效化
array_order = scale_by_type(array_order)
array_supply = scale_by_type(array_supply)

def min_max_scale(a):
    a = (a - np.min(a)) / (np.max(a) - np.min(a))
    return a 

def GMM_cluter():
    features = get_features()
    gmm = GMM(n_components=4).fit(features)
    probs = gmm.predict_proba(features)
    # 返回[402,4]的矩阵表示GMM的先验概率
    #print(probs)

    pred_class = np.argmax(probs,1)
    #print(pred_class.shape)
    #print(pred_class)

    para = gmm.get_params()
    print(para)

#scale过后就不需要考虑type信息,先将type信息记录在相应的数组中
array_type = array_supply[:,1]
#print('type',array_type)
array_order = array_order[:,2:]
array_supply = array_supply[:,2:]

def greedy_search(sort_max_supply,max_valid_supply):
    i = 401
    s = 0
    selected_company = []
    while s < 28200:
        index = sort_max_supply[i]
        s += max_valid_supply[index]
        i -=1 
        selected_company.append(index+1)

    #print(selected_company)
    return selected_company

def greedy_method():
    # 数据稀疏性分析

    #print(np.sum(array_supply[:,2:]>=0))
    #print(np.sum(array_supply[:,2:]>0))

    #96480条数据，但只有25784个非零元素，仅有占比为27%

    mean_valid_supply = np.zeros(402)
    for i in range(0,402):
        s = 0 
        cnt = 0
        for j in range(0,240):
            if array_supply[i,j]>0:
                s += array_supply[i,j]
                cnt += 1
        #print(cnt)
        mean_valid_supply[i] = s / cnt 

    # 尝试使用贪心算法求解，使用有效的均值和最大值分别衡量

    #print(mean_valid_supply.shape)

    #print(max_supply.shape)

    #print(np.sort(mean_valid_supply))
    #print(np.sort(max_supply))

    max_valid_supply = np.max(array_supply,1)
    maxA = 6000 / 0.6
    maxB = 6000 / 0.66
    maxC = 6000 / 0.72 

    #最大供应量需要受到限制
    for i in range(402):
        ty = array_type[i]
        if ty == 'A':
            if max_valid_supply[i] > maxA:
                max_valid_supply[i] = maxA
        elif ty == 'B':
            if max_valid_supply[i] > maxB:
                max_valid_supply[i] = maxB
        elif ty == 'C':
            if max_valid_supply[i] > maxC:
                max_valid_supply[i] = maxC
    #print(max_valid_supply)
    
    sort_mean_supply = np.argsort(mean_valid_supply)
    sort_max_supply = np.argsort(max_valid_supply)

    # 贪心算法对于max_supply求解
    selected_company = greedy_search(sort_max_supply,max_valid_supply)
    print(selected_company)

    # 按照最大的求解： [201, 307, 395]
    # 但没有考虑订购量和供应量的关系

    selected_company = greedy_search(sort_mean_supply,mean_valid_supply)
    print(selected_company)

    #采用均值，需要更多的公司，[201, 229, 140, 361, 395, 108, 282, 151, 275, 329, 340, 139, 131, 308, 330, 348, 307, 356, 268, 306, 126]

if __name__ == '__main__':
    
    print(array_supply.shape) 
    gmm = GMM(n_components=4).fit(features)
    probs = gmm.predict_proba(features)
    # 返回[402,4]的矩阵表示GMM的先验概率
    #print(probs)

    pred_class = np.argmax(probs,1)
    #print(pred_class.shape)
    #print(pred_class)

    para = gmm.get_params()