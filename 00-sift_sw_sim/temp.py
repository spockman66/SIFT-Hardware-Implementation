from PIL import Image
import numpy as np
from matplotlib import pyplot as plt
import math
import cv2
import warnings

############### SIFT特征点生成函数 ###############
#输入：图片地址
#输出：特征向量列表，特征点行号列表，特征点列号列表
def SIFT_feature(path):
    img = Image.open(path, "r")
    img_L = img.convert('L')
    pixels = img_L.load()
    height,width = img.height, img.width
    all_pixels = []
    for row in range(height):
        for col in range(width):
            cpixel = pixels[col, row]
            all_pixels.append(cpixel)   
    img = np.array(all_pixels).reshape((height,width))
            
    #生成高斯模板的函数
    #输入：sigmma为参数，size为模板的边长
    #输出：np.array类型矩阵
    def create_gaussian_kernal(sigmma, size):
        Gaussian_kernal = [[float(0) for i in range(size)] for j in range(size)]
        sum_my = float(0)    
        for row in range(size):
            for col in range(size):
                Gaussian_kernal[row][col] = math.exp(-((row-(size-1)/2)**2+(col-(size-1)/2)**2)/(2.0*sigmma**2))
                sum_my = sum_my + Gaussian_kernal[row][col]           
        for row in range(size):
            for col in range(size):
                Gaussian_kernal[row][col] = Gaussian_kernal[row][col] / sum_my
        return np.array(Gaussian_kernal, dtype="float32")
    
    
    # # 生成高斯金字塔
    src = cv2.imread(path,cv2.IMREAD_GRAYSCALE)
    sigmma0 = 1.6
    S = 4
    size = 15
    img_gaussian_list = [img.copy() for i in range(S)]
    for i in range(4):
        sigmma = sigmma0 * 2**(i/(S-1))
        gaussian_kernal = create_gaussian_kernal(sigmma, size)
        dst = cv2.filter2D(src, ddepth = -1, kernel = gaussian_kernal)
        img_gaussian_list[i] = np.array(dst)
    
    
    # # 生成差分金字塔
    img_gaussian_deta_list = [img.copy() for i in range(S)]
    for i in range(3):
        img_gaussian_deta_list[i] = img_gaussian_list[i] - img_gaussian_list[i+1]
    
    # # 寻找关键点
    feature_row = []
    feature_col = []
    for row in np.arange(7,504):
        for col in np.arange(7,504):
            center = img_gaussian_deta_list[1][row][col]
            flag = 1
            for z in [0,1,2]:
                for x in [-1,0,1]:
                    for y in [-1,0,1]:
                        if z==1 and x==0 and y==0:
                            continue
                        elif center >= img_gaussian_deta_list[z][row+x][col+y]:
                            flag = 0
            if flag==1:
                feature_row.append(row)
                feature_col.append(col)
                
    # # 生成描述向量
    # ## 计算一阶差分矩阵Dx，Dy
    warnings.filterwarnings("ignore")
    Dx, Dy = np.zeros((height, width)), np.zeros((height, width))
    img_temp = img_gaussian_list[1]
    Dx_kernel, Dy_kernel = np.array([-1,0,1]).reshape((1,3)), np.array([1,0,-1]).reshape((3,1))
    Dx = (cv2.filter2D(img_temp, ddepth = -1, kernel = Dx_kernel))
    Dy = (cv2.filter2D(img_temp, ddepth = -1, kernel = Dy_kernel))
    
    # ## 计算幅值矩阵和角度矩阵
    mag, theta = np.zeros((height, width)), np.zeros((height, width))
    for row in range(height):
        for col in range(width):
            dx = Dx[row][col]
            dy = Dy[row][col]
            #计算梯度
            mag[row][col] = abs(dx) + abs(dy)
            #计算象限
            if dx>0 and dy>=0:
                XiangXian = 1
            elif dx<=0 and dy>0:
                XiangXian = 2
            elif dx<0 and dy<=0:
                XiangXian = 3
            else:
                XiangXian = 4
            #计算绝对值的角度    
            dx, dy = abs(dx), abs(dy)
            if dx>dy*5:
                temp=0
            elif dx*2>dy*3:
                temp=1
            elif dx*3>dy*2:
                temp=2
            elif dx*5>dy:
                temp=3
            else:
                temp=4
            #根据象限计算角度
            if XiangXian == 1:
                temp=temp
            elif XiangXian == 2:
                temp = 8-temp
            elif XiangXian == 3:
                temp = 8+temp
            elif XiangXian == 4:
                temp = 16-temp
            if temp==16:
                temp=0
            theta[row][col] = temp
            
    # ## 关键点特征向量生成函数
    def feature_point_descripitor(center_row, center_col, sigmma0):    
        # 生成子区域的高斯模板
        sigmma = sigmma0*1.5
        size = 5
        kernel_temp = create_gaussian_kernal(sigmma, size)   
        # 依次生成17个子区域的中心坐标
        sub_center_row = [0,-3,-5,-5,-5,-5,-5,-3,0,3,5,5,5,5,5,3,0]
        sub_center_col = [5,5,5,3,0,-3,-5,-5,-5,-5,-5,-3,0,3,5,5,0]    
        # 子区域和关键点的特征向量
        sub_dspt = [0 for i in range(16)]
        dspt = []   
        # 对每个子区域进行遍历
        for i in range(17):
            #子区域描述向量清0
            sub_dspt = [0 for i in range(16)]
            #子区域中心坐标
            sub_row, sub_col = center_row+sub_center_row[i], center_col+sub_center_col[i]
            #对5*5的子区域进行遍历
            for deta_row in [-2,-1,0,1,2]:
                for deta_col in [-2,-1,0,1,2]:
                    temp_row = sub_row+deta_row
                    temp_col = sub_col+deta_col
                    sub_dspt[int(theta[temp_row][temp_col])] = sub_dspt[int(theta[temp_row][temp_col])] + mag[temp_row][temp_col]*kernel_temp[deta_row+2][deta_col+2]     
            dspt.extend(sub_dspt)
        return dspt
    
    # ## 关键点特征向量生成
    feature_point_dispt = []
    for i in range(len(feature_row)):
        feature_point_dispt.append(feature_point_descripitor(feature_row[i],feature_col[i], sigmma0))
    
    # ## 关键点主方向计算
    # 生成区域的高斯模板
    sigmma = sigmma0
    size = 15
    kernel_temp = create_gaussian_kernal(sigmma, size)
    main_ori = []
    main_ori_bin = [0 for i in range(16)]
    for i in range(len(feature_row)):
        main_ori_bin = [0 for i in range(16)]
        point_row = feature_row[i]
        point_col = feature_col[i]
        for deta_row in np.arange(-7,8):
            for deta_col in np.arange(-7,8):
                temp_row = point_row + deta_row
                temp_col = point_col + deta_col
                main_ori_bin[int(theta[temp_row][temp_col])] = main_ori_bin[int(theta[temp_row][temp_col])] + mag[temp_row][temp_col]*kernel_temp[deta_row+7][deta_col+7]
        main_ori.append(main_ori_bin.index(max(main_ori_bin)))
    
    # ## 描述向量旋转函数
    def dspt_reorder(dspt, ori):
        #创建子区域的顺序
        order = [i+ori for i in range(16)]
        for i in range(16):
            if order[i] >= 16:
                order[i] = order[i] - 16
        order = order + [17]
        #按顺序遍历子区域
        new_dspt = []
        for i in order:
            sub_dspt_tmp = dspt[int(i*16):int(i*16+16)]
            temp1 = sub_dspt_tmp[ori:16]
            temp2 = sub_dspt_tmp[0:ori]
            temp = temp1 + temp2
            new_dspt.extend(temp)
        return new_dspt
    
    # ## 旋转所有描述向量
    for i in range(len(feature_point_dispt)):
        feature_point_dispt[i] = dspt_reorder(feature_point_dispt[i], main_ori[i])
    return feature_point_dispt, feature_row, feature_col


######################### 主函数 #########################   

path1 = 'D:/CreateIC/sw_sim/5.jpg'
des1, feature_row1, feature_col1 = SIFT_feature(path1) 
print("image1 complete!")  

path2 = 'D:/CreateIC/sw_sim/6.jpg'
des2, feature_row2, feature_col2 = SIFT_feature(path2) 
print("image2 complete!")  
