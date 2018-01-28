import pydpi
INIT_SCALE = pydpi.get_params()['INIT_SCALE']
PX_BLANKING = pydpi.get_params()['PX_BLANKING']
IMG_PATH = pydpi.get_params()['IMG_PATH']

import numpy as np
import cv2

class source(pydpi.SvModule):
  io_spec = {
    'data': pydpi.OUTPUT_REG(8),
    'valid': pydpi.OUTPUT_REG(1),
    'ready': pydpi.INPUT(1),
    'last': pydpi.OUTPUT_REG(1),
    'reset': pydpi.INPUT(1),
    'clk': pydpi.INPUT_CLOCK(),
  }

  def _reset_img(self):
    src_img = cv2.imread(IMG_PATH, cv2.IMREAD_GRAYSCALE)
    r = 1.2**(self.__epoch)
    fw = int(src_img.shape[1]/r)
    fh = int(src_img.shape[0]/r)
    scaled_img = cv2.resize(src_img, (fw, fh))
    print('Effective size: W={}, H={}'.format(fw, fh))
    #self.__img = np.lib.pad(scaled_img, ((0, src_img.shape[0]-fh), (0, src_img.shape[1]-fw)), 'constant')
    self.__img = scaled_img
    self.__img_data = self.__img.flatten()
    self._last = 0
    self._blanking_dcnt = PX_BLANKING

  def _state_update(self, reset, ready):
    if reset == 1:
      self.__epoch = INIT_SCALE
      self.__die = False
      self.__img_ptr = 0
      self._data = 0
      self._last = 0
      self._blanking_dcnt = PX_BLANKING
    else:
      if self._blanking_dcnt > 0:
        self._blanking_dcnt -= 1
      if (self._blanking_dcnt == 0) and ready and not self.__die:
        if self.__img_ptr == 0:
          self._reset_img()

        data_len = len(self.__img_data)
        # emission
        if self.__img_ptr < data_len:
          self._data = self.__img_data[self.__img_ptr]
          self.__img_ptr += 1
          self._blanking_dcnt = PX_BLANKING
          if self.__img_ptr == data_len:
            self._last = 1
            if self.__epoch == 0:
              self.__epoch += 1
              self.__img_ptr = 0
        else:
          self.__die = True
          print('Stream ended')
          return

        w = self.__img.shape[1]
        if self.__img_ptr % w == 0 and self.__img_ptr != 0:
          print('#row = {}'.format(self.__img_ptr/w))

  def data(self, reset, ready):
    return self._data

  def valid(self, reset, ready):
    if reset == 1:
      return 0
    else:
      return 0 if self.__die else 1 if self._blanking_dcnt == PX_BLANKING else 0

  def last(self, reset, ready):
    return self._last
