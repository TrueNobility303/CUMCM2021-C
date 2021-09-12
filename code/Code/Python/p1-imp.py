import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 
from sklearn.cluster import KMeans
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

array_order = scale_by_type(array_order)
array_supply = scale_by_type(array_supply)

def min_max_scale(a):
    a = (a - np.min(a)) / (np.max(a) - np.min(a))
    return a 

#方法1：根据总供应平均供应量确定企业重要性
def method_sum_supply():
    # 根据总供应量选择重要的企业
    sum_supply = np.mean(array_supply[:,2:],1)
    sum_supply = min_max_scale(sum_supply)
    sort_score = np.argsort(sum_supply)

    imp = sort_score[-50:] + 1

    return sum_supply, imp

    #绘制散点图
    #plt.scatter(np.zeros(sum_supply.shape),sum_supply)
    #plt.show()

    #根据总供应量排序
    #sort_supply = np.sort(sum_supply)
    #print(sort_supply)

    # 改变阈值查看筛选后剩下的企业数目
    # 1500 60
    # 14000 50

    #threshold_supply = 14000
    #num = np.sum(sum_supply>threshold_supply)
    #print(num)

    #important_companys = []
    #for i in range(1,403):
    #    if sum_supply[i-1] > threshold_supply:
    #        important_companys.append(i)
    #print(important_companys)

    # 参考的排序结果

    # [ 78 208 189 292 273  74 114  3 218 210 244  86 294  80 346  55 367 364 338  40 365  31 284 126 374  37 247 395 307 201 143 194 352 348 306 268 356 330 308 131 139 340 329 275 151 282 108 361 140 229]

def get_features():

    # 特征提取
    rate = array_supply[:,2:] / (array_order[:,2:] + 1e-12)
    rate[rate>1e8] = None
    
    mrate = np.mean(rate,1)
    # 用方差衡量稳定性
    var = 1 - np.var(rate,1)
    msupply = np.mean(array_supply[:,2:],1)

    print(msupply.shape)

    # 可以选择做聚类... 

    mrate = min_max_scale(mrate)
    var = min_max_scale(var)
    msupply = min_max_scale(msupply)

    #生成特征矩阵

    features = np.zeros((402,3))
    features[:,0] = msupply
    features[:,1] = mrate
    features[:,2] = var 

    return features

#基于熵确定权重
def method_end():
    # 特征提取

    features = get_features()

    #print(features)
    k=1/np.log(3)
    yij=features.sum(axis=0)
    pij=features/yij

    #计算pij
    test=pij*np.log(pij + 1e-5)
    test=np.nan_to_num(test)
    ej=-k*(test.sum(axis=0))
    #计算每种指标的信息熵
    wi=(1-ej)/np.sum(1-ej)
    #计算每种指标的权重

    print('w',wi)

    #wi = np.array([1,0,0])
    scores = np.sum(features * wi,1)

    #print(scores)

    sort_score = np.argsort(scores)
    imp = sort_score[-50:] + 1
    
    return scores, imp

    # [ 76 129 189 307 201  98   3  86 338 348 291 114 314 150   7 123  55 244 139 346  80 367  40 294 218 364 140 143 365  31 247 284 266 374 308 194 352 330 356 306 268 131 151 340 329 275 282 108 361 229]

def method_cluster():
    features = get_features()
    kmeans = KMeans(n_clusters=3)
    kmeans.fit(features)
    y_kmeans = kmeans.predict(features)

    index = np.argwhere(y_kmeans==y_kmeans[229-1])
    index = index.squeeze() + 1
    print(index)
    return index 

def intersect(a,b):
    ans = 0
    for aa in a:
        for bb in b:
            if aa == bb:
                ans += 1
                break
    return ans 

def dump_weight():
    s = "BACBACACBBCACAAAABBCAACBCAABBABCCCABCACBCAACBABBABAAABBABBCCCACAAACCBCAABCACBABCBAACCCABACABACBAABACAACABACBACBBCAAABBABAAABBCAACABACBCCBBBBBBAAABBACACABAAAAAACCCACABABBACBCBBBCABBACCAACABABBCBCAABABBABAAACCAACACCBBBACACABCBBAACABCBBCBCABCBCAACCCCBBAACCAABCBBBBCCBAACCACCBAAABCACBAAACABBAACAAACAACBAACABACCABABBACCBBAABCBBABCCBBABCABCBAABCBACCBCBCACACABACCCBCBCCABCBBCCABAACBBCBCCACCCBBBBBBCBBAAABCBBBB"
    w = []
    u = []
    for ss in s:
        if ss == 'A':
            w.append(1.2)
            u.append(0.6)
        elif ss == 'B':
            w.append(1.1)
            u.append(0.66)
        elif ss == 'C':
            w.append(1)
            u.append(0.72)
    return w,u 

if __name__ == '__main__':
    #w,u = dump_weight()
    #print(w)
    #print(u)
    sc1,imp1 = method_sum_supply()
    sc2,imp2 = method_end()

    sc = sc1 + sc2 
    imp = np.argsort(sc)[-50:] + 1
    print(imp)
    
    # 加权之后的结果
    # [126  98  37   3  86 291 395 338 314 307 201 114 150   7 123 244  80 266 218  55 294 346 367 364  40 348 365  31 284 374 247 143 194 352 306 356 268 139 308 330 131 340 329 151 275 282 108 140 361 229]
    #print(intersect(imp1,imp2))

    # 比较两种方法的的得分
    # 相等的共有41家企业

    #imp3 = method_cluster()
    #print(imp3)
    #print('number of imp3',len(imp3))
    #print(intersect(imp2,imp3))

