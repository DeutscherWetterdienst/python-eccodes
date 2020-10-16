# Python and ecCodes in a Docker container
Python and [ECMWF ecCodes](https://github.com/ecmwf/eccodes) packaged in a Docker container to allow for easy processing of GRIB2 and BUFR files.

[![Python Version](https://img.shields.io/badge/python-3.7.9-informational)](https://hub.docker.com/_/python)
[![ecCodes Version](https://img.shields.io/badge/ecCodes-2.19.0-informational)](https://github.com/ecmwf/eccodes)
[![ecCodes-Python Version](https://img.shields.io/static/v1?label=eccodes-python&message=1.0.0&color=informational)](https://github.com/ecmwf/eccodes-python)
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

## Example 3: Extract data from grib file as CSV
This example shows how you can extract values from GRIB files and save them as CSV.

1. Create and switch to a working directory that will hold all input and output files
```
mkdir csv-example
cd csv-example/
```

2. Download Data
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/downloader downloader \
    --model icon \
    --single-level-fields t_2m,tot_prec \
    --max-time-step 5 \
    --directory /local
```

3. Regrid to geographical grid
```
docker run --rm \
    --volume $(pwd):/local \
    --env INPUT_FILE=/local \
    --env OUTPUT_FILE=/local \
    deutscherwetterdienst/regrid:icon \
    /convert.sh
```

4. (optional) Combine all regridded files into a single grib file
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/python-eccodes grib_copy regridded_*.grib2 combined.grib2
```

5. (optional) Peek inside
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/python-eccodes grib_ls combined.grib2
```

6. Extract GRIB data as CSV
Extract values from GRIB file and (this might take some time)
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/python-eccodes grib_get_data -p date,time,stepRange,shortName combined.grib2 >output.csv
```
The contents of ``output.csv`` should look something like this:
```
Latitude, Longitude, Value, date, time, stepRange, shortName
  -90.000 -180.000 2.1891917419e+02 20200807 600 120 T_2M
  -90.000 -179.875 2.1891917419e+02 20200807 600 120 T_2M
  -90.000 -179.750 2.1891917419e+02 20200807 600 120 T_2M
  -90.000 -179.625 2.1891917419e+02 20200807 600 120 T_2M
  ...
```
See also https://confluence.ecmwf.int/display/CKB/How+to+convert+GRIB+to+CSV for further information.

## Example 4: Extract data from grib file as JSON
This example shows how you can extract values from GRIB files and save them as JSON for further processing.

1. Create and switch to a working directory that will hold all input and output files
```
mkdir json-example
cd json-example/
```

2. Download Data
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/downloader downloader \
    --model icon-d2 \
    --single-level-fields rain_gsp \
    --max-time-step 5 \
    --directory /local
```

3. Regrid to geographical grid
```
docker run --rm \
    --volume $(pwd):/local \
    --env INPUT_FILE=/local \
    --env OUTPUT_FILE=/local \
    deutscherwetterdienst/regrid:icon-d2 \
    /convert.sh
```

4. (optional) Combine all regridded files into a single grib file
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/python-eccodes grib_copy regridded_*.grib2 combined.grib2
```

5. (optional) Peek inside
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/python-eccodes grib_ls combined.grib2
```
The output for ``rain_gsp`` will look something like this:
```
combined.grib2
edition      centre       date         dataType     gridType     typeOfLevel  level        stepRange    shortName    packingType  
2            edzw         20200810     fc           regular_ll   surface      0            0            RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-15         RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-30         RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-45         RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-60         RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-75         RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-90         RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-105        RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-120        RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-135        RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-150        RAIN_GSP     grid_simple 
2            edzw         20200810     fc           regular_ll   surface      0            0-165        RAIN_GSP     grid_simple 
12 of 12 messages in combined.grib2

12 of 12 total messages in 1 files
```

6. (optional) Split into single grib files
For grib files that contain multiple messages (e.g. for ``rain_gsp``) you need to split 
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/python-eccodes grib_copy combined.grib2 'split_[dateTime]_[level]_[stepRange]_[shortName].grib2'
```
This will produce a number of files, each containing a single message:
```
split_202008100000_0_0-105_RAIN_GSP.grib2
split_202008100000_0_0-120_RAIN_GSP.grib2
split_202008100000_0_0-135_RAIN_GSP.grib2
split_202008100000_0_0-150_RAIN_GSP.grib2
split_202008100000_0_0-15_RAIN_GSP.grib2
split_202008100000_0_0-165_RAIN_GSP.grib2
split_202008100000_0_0-30_RAIN_GSP.grib2
split_202008100000_0_0-45_RAIN_GSP.grib2
split_202008100000_0_0-60_RAIN_GSP.grib2
split_202008100000_0_0-75_RAIN_GSP.grib2
split_202008100000_0_0-90_RAIN_GSP.grib2
split_202008100000_0_0_RAIN_GSP.grib2
```

7. Convert GRIB data to JSON
Convert all ``split_*`` files to json (this might take some time):
```
docker run --rm --volume $(pwd):/local \
    deutscherwetterdienst/python-eccodes find -name 'split_*.grib2' -exec sh -c "grib_dump -j {} > {}.json" \;
```
This will create the corresponding json files:
```
split_202008100000_0_0-105_RAIN_GSP.grib2.json	split_202008100000_0_0-30_RAIN_GSP.grib2.json
split_202008100000_0_0-120_RAIN_GSP.grib2.json	split_202008100000_0_0-45_RAIN_GSP.grib2.json
split_202008100000_0_0-135_RAIN_GSP.grib2.json	split_202008100000_0_0-60_RAIN_GSP.grib2.json
split_202008100000_0_0-150_RAIN_GSP.grib2.json	split_202008100000_0_0-75_RAIN_GSP.grib2.json
split_202008100000_0_0-15_RAIN_GSP.grib2.json	split_202008100000_0_0-90_RAIN_GSP.grib2.json
split_202008100000_0_0-165_RAIN_GSP.grib2.json	split_202008100000_0_0_RAIN_GSP.grib2.json
```
The contents of each json file will look something like this:
```
{ "messages" : [
  [

    {
      "key" : "discipline",
      "value" : 0
    },
    {
      "key" : "editionNumber",
      "value" : 2
    },
    {
      "key" : "centre",
      "value" : 78
    },
    {
      "key" : "subCentre",
      "value" : 255
    },
    ...
```