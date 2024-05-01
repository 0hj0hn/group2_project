#!/bin/bash

echo "Enter the number of parts you want to split the 'hospital_prices.csv' file into:"
read N

FILE="./archive/hospital_prices.csv"
DIRECTORY="splitted_parts"


total_lines=$(wc -l < "$FILE")
echo "Total lines in the file: $total_lines"


lines_per_file=$((total_lines / N))
echo "Each part will approximately have $lines_per_file lines."


mkdir -p $DIRECTORY


split -l $lines_per_file "$FILE" "${DIRECTORY}/part_"


a=0
for file in ${DIRECTORY}/part_*; do
  mv "$file" "${DIRECTORY}/part_${a}.csv"
  let a++
done

echo "Splitting complete. Files are saved in ${DIRECTORY}/"
