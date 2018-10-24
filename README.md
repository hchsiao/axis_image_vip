# axis_image_vip
Visual object detector for raster-scanned streaming (AXI4-Stream) images. The hardware streams out the coordinate of each window (which is implemented as a trivial 2D counter) and the score for each window (using Viola-Jones algorithm).

## Dependencies

#### Software
  - opencv-python

#### EDA tools
  - ChipCMake (build system)

## Architecture
The variance computation unit presents only when Haar-feature mode enabled.

## Configuration
See `config.cmake` file for parameters listing

## Usage
Add this repository as a submodule
```sh
git submodule init # if not done yet
git submodule add $URL_TO_THIS_REPO ip/axis_obj_detect
```

In the test module CMakeFileList.txt of the parent design, add this call:
```cmake
add_ip(axis_image_vip
  SOURCE_BYTES ${DATA_BYTES}
  SINK_BYTES ${DATA_BYTES}
  TIMEOUT_CYCLE ${TIMEOUT_CYCLES}
  )
```
And this one:
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
The `axis_image_vip` module is used as the test bench (TB) to supply stimulus for simulation, and recieves the result. The TB data emulates an image sensor, pixels are presented in a raster-scanned order.  
To run the simulation:
```sh
mkdir -p impl # could also be 'build' or else, the name is not relevant
cmake -C ../config.cmake .. # initialize ChipCMake like traditional cmake
make presim # make models are not required as dependencies are handled by cmake
```
Note if ChipCMake is not install in the system path, the flag `-DCMAKE_MODULE_PATH=$CCMK_PATH` is required.

#### Block diagram
-—+　+——————————-+　+——  
TB |-->|axis_obj_detect (DUT)　|-->|TB  
-—+　+——————————-+　+——

## Known issue
 - should not expose memory MUX parameter
 - TODO: Verify the simulation result automatically
 - Haar-feature is not working in the current branch. Trace back in the commit history for a working snapshot.


