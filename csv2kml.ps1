$arg_option = @{
    file = $null;
    show_key = $null;
    col_num = 3;
    lon = $null;
    lat = $null;
    alt = $null;
    output = $null;
    debug = $false
}

function args_help {
    "usage: $($args) [-h]"
    "  -h, --help  show this help message and exit"
    "  -debug,     debug"
    ""
    "  -f,         input csv file"
    "  -s,         show csv header columns"
    "  -o,         output kml file"
    "  -ncol,      show columns number"
    ""
    "  -lon,       Longitude of csv column's name"
    "  -lat,       Latitude of csv column's name"
    "  -alt,       Altitude of csv column's name"
}

if ($args.Count -ne 0) {
    for ($i = 0; $i -lt $args.Count; $i++) {
        if ($args[$i] -eq "-f") {
            $arg_option["file"] = $args[$i + 1]
        } elseif ($args[$i] -eq "-s") {
            $arg_option["show_key"] = $true
        } elseif ($args[$i] -eq "-lon") {
            $arg_option["lon"] = $args[$i + 1]
        } elseif ($args[$i] -eq "-lat") {
            $arg_option["lat"] = $args[$i + 1]
        } elseif ($args[$i] -eq "-alt") {
            $arg_option["alt"] = $args[$i + 1]
        } elseif ($args[$i] -eq "-o") {
            $arg_option["output"] = $args[$i + 1]
        } elseif ($args[$i] -eq "-ncol") {
            $arg_option["col_num"] = $args[$i + 1]
        } elseif ($args[$i] -eq "-debug") {
            $arg_option["debug"] = $true
        } elseif ($args[$i] -eq "-h" -or $args[$i] -eq "--help") {
            args_help $($MyInvocation.MyCommand.Name)
        }
    }
} else {
    args_help $($MyInvocation.MyCommand.Name)
}

if ($arg_option["debug"]) {
    "Arguments Options:"
    $arg_option | Format-Table
}

if ($arg_option["file"] -ne $null) {
    $data = Import-Csv $arg_option["file"]
    if ($arg_option["show_key"] -eq $true) {
        $cols = (
            $data | Get-member -MemberType "NoteProperty" |
            Select-Object -ExpandProperty "Name"
        )
        $ncol = $arg_option["col_num"]
        $header_col  = ""
        $header_col += "-" * 100
        $header_col += "`n"
        $header_col += " CSV header columns: `n"
        for ($i = 0; $i -lt $cols.Count; $i++) {
            if ( $i % $ncol -eq ($ncol -1)  ) {
                $header_col += "{0,20},`n" -f $cols[$i]
            } else {
                $header_col += "{0,20}, " -f $cols[$i]
            }
        }
        $header_col += "`n"
        $header_col += "-" * 100
        echo $header_col

    }
    if (
        $arg_option["lon"] -eq $null -or
        $arg_option["lat"] -eq $null -or
        $arg_option["alt"] -eq $null
    ) {
        continue
    } else {
        $lla = @()
        for ($i = 0; $i -lt $data.Count; $i++) {
            Write-Host ("`r Progress = {0:N} % " -f $($i / $data.Count * 100)) -NoNewline
            $lla += "{0},{1},{2}" -f (
                $data[$i].("{0}" -f $arg_option["lon"]),
                $data[$i].("{0}" -f $arg_option["lat"]),
                $data[$i].("{0}" -f $arg_option["alt"])
            )
        }
        $kml =
@"
<?xml version="1.0" encoding="utf-8" ?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document id="root_doc">
<Folder>
    <name>
    $([System.IO.Path]::GetFileNameWithoutExtension($arg_option["file"]))
    </name>
    <Placemark>
    <name>trajectory</name>
    <description>record trajectory path</description>
    <Style><LineStyle>
        <color>ff0000ff</color></LineStyle><PolyStyle><fill>0</fill>
    </PolyStyle></Style>
        <LineString>
        <coordinates>
        $($lla)
        </coordinates>
        </LineString>
    </Placemark>
    <Placemark>
    <name>start</name>
    <description>start record</description>
        <Point>
        <coordinates>
        $($lla[0])
        </coordinates>
        </Point>
    </Placemark>
    <Placemark>
    <name>end</name>
    <description>end record</description>
        <Point>
        <coordinates>
        $($lla[$lla.Count - 1])
        </coordinates>
        </Point>
    </Placemark>
</Folder>
</Document></kml>
"@
        if ($arg_option['output'] -ne $null) {
            $kml | Out-File ("{0}" -f $arg_option["output"]) -Encoding UTF8
        } else {
            $kml | Out-File output.kml -Encoding UTF8
        }
    }
} else { continue }
