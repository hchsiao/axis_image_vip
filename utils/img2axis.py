import numpy as np
import cv2
import sys

sources = sys.argv[1:-1]
destination = sys.argv[-1]

result = None
for src in sources:
    img = cv2.imread(src, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print('Cannot read image!')
        exit(1)

    frame_h = img.shape[0]
    frame_w = img.shape[1]
    seq = img.flatten()
    pt = np.zeros((len(seq), 3))
    # AXIS.TDATA
    pt[:,0] = seq
    # AXIS.TLAST
    for y in range(1, frame_h+1):
        pt[frame_w*y-1, 1] = 1
    # AXIS.TUSER
    pt[0, 2] = 1
    if result is None:
        result = pt
    else:
        result = np.concatenate((result, pt))

np.savetxt(destination, result, fmt='%d', delimiter=',')
