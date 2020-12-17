import sys

#target = "406x620+38+68"
#w_src = float("700")
#h_src = float("800")
#dpi_h = float("96")
#dpi_w = float("28")

# 1747x1278+0+1 1747 2480 300 300
target, w_src, h_src, dpi_w, dpi_h = sys.argv[1:]

def convert_to_pt(x, dpi):
    return (x / dpi) * 72.0 

wh, x, y = target.split("+")
w, h = wh.split("x")
x = float(x)
y = float(y)
w = float(w)
h = float(h)
w_src = float(w_src)
h_src = float(h_src)
dpi_h = float(dpi_h)
dpi_w = float(dpi_w)


w_scale = convert_to_pt(w_src, dpi_w)
h_scale = convert_to_pt(h_src, dpi_h)

# For CropBox: (left bottom right top)
clips = [convert_to_pt(x, dpi_w),
         convert_to_pt(h_src-y-h, dpi_h),
         convert_to_pt((x+w),dpi_w),
         convert_to_pt((h_src-y),dpi_h)
         ]# distance from left, top, right and bottom
print ( " ".join( [ '%d' % round(x) for x in clips ]  ))

# # For PDF crop: (distance from left, top, right and bottom)
# clips = [-convert_to_pt(x, dpi_w),
#          -convert_to_pt(y, dpi_h),
#          -convert_to_pt((w_src-w-x),dpi_w),
#          -convert_to_pt((h_src-h-y),dpi_h)
#          ]# distance from left, top, right and bottom
# print ( " ".join( [ '%d' % round(x) for x in clips ]  ))