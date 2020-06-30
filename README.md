# Python and ecCodes in a Docker container
Python and [ECMWF ecCodes](https://github.com/ecmwf/eccodes) packaged in a Docker container to allow for easy processing of GRIB2 and BUFR files.

[![Python Version](https://img.shields.io/badge/python-3.7.7-informational)](https://hub.docker.com/_/python)
[![ecCodes Version](https://img.shields.io/badge/ecCodes-2.17.1-informational)](https://github.com/ecmwf/eccodes)
[![ecCodes-Python Version](https://img.shields.io/static/v1?label=eccodes-python&message=0.9.8&color=informational)](https://github.com/ecmwf/eccodes-python)
[![Docker Build Status](https://img.shields.io/docker/cloud/build/deutscherwetterdienst/python-eccodes.svg)](https://hub.docker.com/r/deutscherwetterdienst/python-eccodes)
[![Docker Pulls](https://img.shields.io/docker/pulls/deutscherwetterdienst/python-eccodes)](https://hub.docker.com/r/deutscherwetterdienst/python-eccodes)

# Usage
The [Docker](https://www.docker.com) image ``deutscherwetterdienst/python-eccodes`` is availble on [Dockerhub](https://hub.docker.com/r/deutscherwetterdienst/python-eccodes). 

## NWP forecast data
You can download [DWD](https://www.dwd.de)'s [NWP forecast data](https://www.dwd.de/EN/ourservices/nwp_forecast_data/nwp_forecast_data.html) in [GRIB2](https://www.wmo.int/pages/prog/www/WMOCodes/Guides/GRIB/GRIB2_062006.pdf) format from DWD's Open Data file server at: https://opendata.dwd.de/weather/nwp/ .

## Example 1: Extract meta data from sample grib file
To extract meta data from sample grib file ``icon_global.grib2`` included in the image run:
```
docker run --rm deutscherwetterdienst/python-eccodes grib_ls /samples/icon_global.grib2
```
This should produce the following output:
```
edition      centre       date         dataType     gridType     stepRange    typeOfLevel  level        shortName    packingType  
2            edzw         20200609     fc           unstructured_grid  0            heightAboveGround  2            2t           grid_simple 
1 of 1 messages in /samples/icon_global.grib2

1 of 1 total messages in 1 files
```

## Example 2: Extract meta data from grib file on local hard drive
If you have a local grib file ``some-file.grib2`` and you want to run ``grib_ls`` on this file:
```
docker run --rm --mount type=bind,source="$(pwd)"/,target=/local deutscherwetterdienst/python-eccodes grib_ls some-file.grib2
```
Example output of ``grib_ls``:
```
edition      centre       date         dataType     gridType     stepRange    typeOfLevel  level        shortName    packingType  
2            edzw         20200608     fc           regular_ll   7            heightAboveGround  2            2t           grid_simple 
1 of 1 messages in some-file.grib2

1 of 1 total messages in 1 files
```
