import numpy as np
import cv2
import argparse


parser = argparse.ArgumentParser(description='Generate test sequence for HDL simulation.')
parser.add_argument('source', type=str, help='Path to input image')
parser.add_argument('destination', type=str, help='Path to output file')

args = parser.parse_args()

img = cv2.imread(args.source, cv2.IMREAD_GRAYSCALE)
if img is None:
    print('Cannot read image!')
    exit(1)

seq = img.flatten()
pt = np.zeros((len(seq), 2))
pt[:,0] = seq
pt[-1, 1] = 1
np.savetxt(args.destination, pt, fmt='%d', delimiter=',')
