import cv2
import numpy as np
max_len = 500
border= 300
image = cv2.imread('current_page.png')


h_input,w_input, c = image.shape


if h_input < w_input:
    new_h = max_len
    scale = new_h / h_input
    new_w = int(round(w_input * scale))
else:
    new_w = max_len
    scale = new_w / w_input
    new_h = int(round(h_input * scale))

image = cv2.resize(image,(new_w, new_h))

image = cv2.copyMakeBorder(
                 image,
                 border,
                 border,
                 border,
                 border,
                 cv2.BORDER_CONSTANT,
                 #    dst=image,
                 value=[255, 255, 255]
              )



gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
kernel = np.ones((3,3),np.float32)/9
gray = cv2.filter2D(gray,-1,kernel)

ret, thresh =  cv2.threshold(gray,244,255,cv2.THRESH_OTSU|cv2.THRESH_BINARY_INV); #cv2.THRESH_OTSU|
thresh  = cv2.adaptiveThreshold(thresh,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,\
            cv2.THRESH_BINARY,45,17) # cv2.THRESH_BINARY_INV
thresh = 255-thresh
rect_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (77, 77))
thresh = cv2.dilate(thresh, rect_kernel, iterations = 3)
thresh = cv2.erode(thresh, rect_kernel, iterations=3)
contours, hierarchy = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

c = max(contours, key = cv2.contourArea)
x,y,w,h = cv2.boundingRect(c)

h_extended,w_extended, _ = image.shape
image = image[border:h_extended-border, border:w_extended-border,:]

h_orig,w_orig, _ = image.shape
w = min(w, (w_orig-x+border-1))
h = min(h, (h_orig-y+border-1))
x = max(0,x-border)
y = max(0,y-border)
print ( "%dx%d+%d+%d" %  (
    round(w/scale),
    round(h/scale),
    round(x/scale),
    round(y/scale)))

