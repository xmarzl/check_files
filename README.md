# check_files.pl
icinga2 check directory for new files

## Example output:
```
perl check_files.pl -s /opt/testing/ -rx "\.file" -v
verbose: Storage: "/opt/testing/"
verbose: regex: "\.file"
verbose: warning: "300"
verbose: critical: "600"
verbose: verbose: "1"
verbose: 
verbose: Script start
verbose: Opening directory: "/opt/testing/"
verbose: Directory successfully opened!
verbose: Found files (no RegEx): [test3.file,test4.file,test.bkp,test3.bkp,test2.bkp]
verbose: Found files (RegEx): [test3.file,test4.file]
Found 2 files.
Newest file: test4.file
Age: 2
verbose: End script - Everything fine!
```
```
perl check_files.pl -s /opt/testing/ -rx "\.txt" -v
verbose: Storage: "/opt/testing/"
verbose: regex: "\.txt"
verbose: warning: "300"
verbose: critical: "600"
verbose: verbose: "1"
verbose: 
verbose: Script start
verbose: Opening directory: "/opt/testing/"
verbose: Directory successfully opened!
verbose: Found files (no RegEx): [test3.file,test.bkp,test3.bkp,test2.bkp]
verbose: Found files (RegEx): []
Critical: Storage "/opt/testing/" does not contain a file matching the pattern "\.txt"
```


## Installation:
```sh
cd /usr/lib/nagios/plugins
wget https://raw.githubusercontent.com/xmarzl/check_files/main/check_files.pl
chmod 750 /usr/lib/nagios/plugins/check_files.pl
```
## 

| Parameter         | Description                 |
| ----------------- | --------------------------- |
| -s  \| --storage  | Path to storage             |
| -w  \| --warning  | File age warning (seconds)  |
| -c  \| --critical | File age critical (seconds) |
| -h  \| --help     | Shows help                  |
| -v  \| --verbose  | More information            |
| -rx \| --regex    | Filter files with regex     |
| usage | perl check_files.pl -s <storage> [-w <warning>] [-c <age_critical>] [-rx <regex_pattern>] [-v] |

Example:
```bash
./check_files.pl -s "/opt/example/backups" -rx "\\.bkp" -w 400 -c 1000 -v
```
