# axis_image_vip
This module is used as the test bench (TB) to supply stimulus for simulation, and recieves the result. The TB data emulates an image sensor, pixels are presented in a raster-scanned order.  
The video stream is packeged according to the Xilinx convention (see Xilinx user guide UG934).

## Dependencies

#### Software
  - opencv-python

#### EDA tools
  - ChipCMake (build system)

## Configuration
See `config.cmake` file for parameters listing

## Usage
Add this repository as a submodule
```sh
git submodule init # if not done yet
git submodule add $URL_TO_THIS_REPO test/ip/axis_image_vip
```

In the test module CMakeFileList.txt of the parent design, add this call:
```cmake
add_ip(axis_image_vip
  SOURCE_BYTES ${DATA_BYTES}
  SINK_BYTES ${DATA_BYTES}
  TIMEOUT_CYCLE ${TIMEOUT_CYCLES}
  )
```
And the following:
```cmake
find_package(PythonInterp REQUIRED)
add_custom_command(OUTPUT ${TEST_REC_FILE}
  COMMAND ${PYTHON_EXECUTABLE} -B ${axis_image_vip_DIR}/utils/img2axis.py ${TEST_IMAGE} ${TEST_REC_FILE}
  COMMENT "Generating test pattern record file"
  )
add_custom_target(test_rec DEPENDS ${TEST_REC_FILE})
```

| Variable | Type | Description |
| ------ | ------ | ------ |
| DATA_BYTES | Digits | input/output data bit-width |
| TIMEOUT_CYCLES | Digits | terminate simulation if no output generated for this long (liveness) |
| TEST_IMAGE | String | path to the image file (can be in any format supported by opencv) |
| TEST_REC_FILE | String | output path for the encoded image file |

Variables not listed are automatically set.
#### Block diagram
————————+　+——+　+————————  
axis_image_vip　|--> |DUT |-->|axis_image_vip  
————————+　+——+　+————————  


## Interface description

#### API
Currently not applicable.

#### Ports
Inbound ports: \<Name\>_i; outbound ports: \<Name\>_o.

| Name | Protocol | Description |
| ------ | ------ | ------ | 
| axis_s_data_i | AXI4-Stream | input pixel stream TDATA |
| axis_s_valid_i | AXI4-Stream | input pixel stream TVALID |
| axis_s_ready_o | AXI4-Stream | input pixel stream TREADY |
| axis_s_last_i | AXI4-Stream | input pixel stream TLAST |
| axis_s_user_i | AXI4-Stream | input pixel stream TUSER |
| axis_m_data_o | AXI4-Stream | integrated data TDATA |
| axis_m_valid_o | AXI4-Stream | integrated data TVALID |
| axis_m_ready_i | AXI4-Stream | integrated data TREADY |
| axis_m_last_o | AXI4-Stream | integrated data TLAST |
| axis_m_user_o | AXI4-Stream | integrated data TUSER |
| clk_i | CLOCK | the clock |
| rstn_i | RESET | reset (active low) |

## Test plan
Before simulation, this IP should be added to the simulation `IP_LIST` in `test/CMakeLists.txt`, for example:
```cmake
# depends on the usage, may not be exactly the same
add_testbench(presim ${test_sources}
  IP_LIST
    ANOTHER_IP_1
    ANOTHER_IP_2
    ANOTHER_IP_3
    axis_image_vip
  FLAGS ${SIM_FLAGS}
  )
```

A passthrough streaming unit is used as a dummy DUT. To run the simulation:
```sh
mkdir -p impl # could also be 'build' or else, the name is not relevant
cd impl/
cmake -C ../config.cmake .. # initialize ChipCMake like traditional cmake
make feedback
```
Note if ChipCMake is not install in the system path, the flag `-DCMAKE_MODULE_PATH=$CCMK_PATH` is required.

Every design simulate with `axis_image_vip` will generate `impl/test/result_pattern.txt` for stream data and `impl/test/novas.fsdb` for the waveform.

The testbench can be controlled by several parameters defined in `test/CMakeLists.txt`:

| Parameter | Type | Description |
| ------ | ------ | ------ | 
| RESET_DELAY | Digits | reset will be asserted after this time from the start of simulation |
| RESET_DURATION | Digits | reset will be asserted with this duration |
| CLOCK_PERIOD | Digits | the clock period |
| DUMP_FSDB_PATH | String | signal dump file (fsdb) name |

## Known issue
 - TODO: Verify the simulation result automatically
 - TODO: Add API to control simulation


