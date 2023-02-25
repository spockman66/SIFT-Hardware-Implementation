import cv2
from matplotlib import pyplot as plt

image1 = cv2.imread("5.jpg",cv2.IMREAD_GRAYSCALE)
image2 = cv2.imread("6.jpg",cv2.IMREAD_GRAYSCALE)
    
sift = cv2.SIFT_create()
kp1, des1 = sift.detectAndCompute(image1, None)
kp2, des2 = sift.detectAndCompute(image2, None)
kp_image1 = cv2.drawKeypoints(image1, kp1, None)
kp_image2 = cv2.drawKeypoints(image2, kp2, None)
    
plt.figure(dpi = 100)
plt.subplot(1,2,1)
plt.imshow(kp_image1)
plt.subplot(1,2,2)
plt.imshow(kp_image2)


ratio = 0.6

#  K近邻算法求取在空间中距离最近的K个数据点，并将这些数据点归为一类
matcher = cv2.BFMatcher()
raw_matches = matcher.knnMatch(des1, des2, k = 2)
good_matches = []
for m1, m2 in raw_matches:
    #  如果最接近和次接近的比值大于一个既定的值，那么我们保留这个最接近的值，认为它和其匹配的点为good_match
    if m1.distance < ratio * m2.distance:
        good_matches.append([m1])

matches = cv2.drawMatchesKnn(image1, kp1, image2, kp2, good_matches, None, flags = 2)
plt.figure(dpi = 80)
plt.imshow(matches)        




