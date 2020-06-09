# Python and ecCodes in a Docker container
Python and [ECMWF ecCodes](https://github.com/ecmwf/eccodes) packaged in a Docker container to allow for easy processing of GRIB2 and BUFR files.

# Usage
The image ``deutscherwetterdienst/python-eccodes`` is availble on [Dockerhub](https://hub.docker.com/orgs/deutscherwetterdienst/python-eccodes). 

You can download GRIB2 files from DWD's Open Data file server: https://opendata.dwd.de/weather/nwp/ .

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
docker run --rm --mount type=bind,source="$(pwd)"/some-file.grib2,target=/my.grib2 deutscherwetterdienst/python-eccodes grib_ls /my.grib2
```
Example output of ``grib_ls``:
```
edition      centre       date         dataType     gridType     stepRange    typeOfLevel  level        shortName    packingType  
2            edzw         20200608     fc           regular_ll   7            heightAboveGround  2            2t           grid_simple 
1 of 1 messages in some-file.grib2

1 of 1 total messages in 1 files
```