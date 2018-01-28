import pydpi
SIM_TIME_LIMIT = pydpi.get_params()['SIM_TIME_LIMIT']
SIM_FRAMES = pydpi.get_params()['SIM_FRAMES']

class sink(pydpi.SvModule):
  io_spec = {
    'data': pydpi.INPUT(8),
    'valid': pydpi.INPUT(1),
    'ready': pydpi.OUTPUT_REG(1),
    'last': pydpi.INPUT(1),
    'reset': pydpi.INPUT(1),
    'clk': pydpi.INPUT_CLOCK(),
  }

  def __init__(self):
    self.__fin_flag = False
    self.__last_count = 0
    self.__timer = 0

  def _state_update(self, reset, data, valid, last):
    self.__timer += 1
    if self.__timer == SIM_TIME_LIMIT:
      self.__fin_flag = True

    import pydpi.dispatch
    if self.__fin_flag:
      pydpi.dispatch.finish()
      self.__log_file.close()
      return

    if last and valid:
      self.__last_count += 1
      if self.__last_count == SIM_FRAMES:
        self.__fin_flag = True

    if reset:
      self.__log_file = open('aos.log', 'w')
    else:
      if valid:
        self.__log_file.write('{} {}\n'.format(data, last))

  def ready(self, reset):
    return 1 if not reset else 0
