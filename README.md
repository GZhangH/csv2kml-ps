# csv2kml-ps

Convert the csv file to the kml file with powershell script.

### Help
```
$./csv2kml.ps1 -h
usage: csv2kml.ps1 [-h]
  -h, --help  show this help message and exit
  -debug,     debug

  -f,         input csv file
  -s,         show csv header columns
  -o,         output kml file
  -ncol,      show columns number

  -lon,       Longitude of csv column's name
  -lat,       Latitude of csv column's name
  -alt,       Altitude of csv column's name
```

### Example
```
./csv2kml.ps1 -f {file.csv} -lon 'lon' -lat 'lat' -alt 'alt' -o {file.kml}
```

`lon`, `lat`, `alt` are the CSV header column name.