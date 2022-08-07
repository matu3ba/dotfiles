#!/bin/bash

executables="test.xml"
for executable in "${executables}"; do
 if [ "${executable: -4}" != ".xml" ]   \
 && [ "${executable: -4}" != ".txt" ]   \
 && [ "${executable: -4}" != ".csv" ]; then
  echo "file is no csv, txt or xml"
 fi
done

## based on https://www.baeldung.com/linux/csv-parsing
csv_file="file.csv"
echo 'SNo,Quantity,Price,Value
1,2,20,40
2,5,10,50' > csv_file

# 1. print lines
while read line
do
   echo "Line content: $line"
#done < file.csv
# 2. without first line
done < <(tail -n +2 file.csv)

# 3. parse line with read -r
while IFS="," read -r col1 col2 col3 col3
do
  echo "col1: ${col1}"
  echo "col2: ${col2}"
  echo "col3: ${col3}"
  echo "col4: ${col4}"
  echo ""
done < <(tail -n +2 file.csv)
