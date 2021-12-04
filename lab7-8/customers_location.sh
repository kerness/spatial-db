#!/bin/bash

# Created on 02.12.2021 by Maciej Bąk 400666
# This script can be used to download new customers data, compare with existing data and insert new data to database.
# It finds the best customers based on distance parameter
# Also, it sends the best customers report to provided email address


# # VARIABLES 

# Directories
WORKSPACE=`pwd`
REFERENCE_DATA=$WORKSPACE/reference_data/Customers_old.csv
DOWNLOAD=$WORKSPACE/download
TMP=$WORKSPACE/tmp
PROCESSED=$WORKSPACE/processed
OUTPUT=${WORKSPACE}/output

# cleaning
rm -r $PROCESSED

#mkdir -p $REFERENCE_DATA
mkdir -p $DOWNLOAD
mkdir -p $TMP
mkdir -p $PROCESSED
mkdir -p $OUTPUT

# SQL
SQL_HOSTNAME=localhost
SQL_DATABASE=customers_location
SQL_PORT="25432"
SQL_USERID=geo
SQL_PASSWORD=geo
SQL_JDBC_STRING="postgresql://${SQL_USERID}:${SQL_PASSWORD}@${SQL_HOSTNAME}:${SQL_PORT}/${SQL_DATABASE}"

# Others
TIMESTAMP=`date +'%m-%d-%Y'`
TIMESTAMP_HMS=`date +'%m-%d-%Y %H:%M:%S'`
LOG_FILE=$PROCESSED/etl_${TIMESTAMP}.log
FILE_URL=https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip
FILE_NAME=$(echo $FILE_URL | awk -F  "/" '{print $5}' | cut -f1 -d".")
FILE_NAME_FULL=${FILE_NAME}.csv
FILE_PATH=$WORKSPACE/$FILE_NAME/$FILE_NAME_FULL
ZIP_PASSWORD=agh
INDEX_NUMBER=400666


# DOWNLOAD AND UNZIP DATA
wget -nv $FILE_URL -P $DOWNLOAD
unzip -qq -o -P "agh" $DOWNLOAD/Customers_Nov2021.zip -d $WORKSPACE/$FILE_NAME
if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: Data was succesfully downloaded" >> $LOG_FILE
fi


# # VALIDATION

# merge data to one file
cat $REFERENCE_DATA $FILE_PATH | tr -d "'" > $TMP/merged.csv
# remove empty lines
awk 'NF' $TMP/merged.csv > $TMP/merged_noempty.csv
# find duplicated lines - NOT TO INSERT
awk 'dup[$0]++ == 1' $TMP/merged_noempty.csv > "$PROCESSED/$FILE_NAME.bad_$TIMESTAMP_HMS"
# remove empty lines, remove header, remove duplicated lines form the data - as result we have THE CORRECT DATA TO INSERT
awk 'NF' $FILE_PATH | tail -n +2 | grep -Fvxf "$PROCESSED/$FILE_NAME.bad_$TIMESTAMP_HMS" $TMP/merged_noempty.csv > to_insert.csv
if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: Validation completed succesfully" >> $LOG_FILE
fi
NUM_OF_LINES_NEW_FILE=`wc -l < $FILE_PATH`

# # PREPARE DATABASE

psql --quiet $SQL_JDBC_STRING -c "\connect ${SQL_DATABASE}"
psql $SQL_JDBC_STRING -c "create extension if not exists postgis;"
psql $SQL_JDBC_STRING -c "create table if not exists CUSTOMERS_${INDEX_NUMBER} (first_name varchar(30), last_name varchar(30), email varchar(30), geog GEOGRAPHY(Point) );"
if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: Database prepared succesfully" >> $LOG_FILE
fi

# # READ CSV LINE BY LINE AND CREATE SQL SCRIPT

while read line
do
   echo $line | awk -v INDEX_NUMBER=$INDEX_NUMBER -F "," ' {
            begining="insert into CUSTOMERS_"INDEX_NUMBER" values ("; 
            first_name="\x27"$1"\x27,"
            last_name="\x27"$2"\x27,"
            email="\x27"$3"\x27,"
            lat=$4
            long=$5
            point="\x27POINT("lat" "long")\x27"
            end=");"            

            print begining first_name last_name email point end
        }
    
    ' >> customers_${INDEX_NUMBER}_inserts.sql
done < "${WORKSPACE}/to_insert.csv"
# connect to db and insert data
psql --quiet $SQL_JDBC_STRING -c "\connect ${SQL_DATABASE}" -f customers_${INDEX_NUMBER}_inserts.sql

if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: Data was succesfully inserted to database" >> $LOG_FILE
fi

# move the file to PROCESSED
mv $WORKSPACE/Customers_Nov2021 "${PROCESSED}/${TIMESTAMP}_Customers_Nov2021"

# # SEND FIRST THE EMAIL

# count number of inserted records
NUM_OF_LINES_TO_INSERT=`wc -l < to_insert.csv`

EMAIL="
    Count of rows in new file: $NUM_OF_LINES_NEW_FILE
    Count of correct rows: `wc -l < to_insert.csv`
    Count of duplicates: `wc -l < "$PROCESSED/$FILE_NAME.bad_$TIMESTAMP_HMS"`
    Number of inserted records: `awk -v n=$NUM_OF_LINES_TO_INSERT "BEGIN {print n*5}"`
"
echo $EMAIL | mailx -s "[$TIMESTAMP] CUSTOMERS LOAD" testowy.test39@gmail.com   
if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: Info email was sent" >> $LOG_FILE
fi

# SQL QUERY TO FIND THE BEST CUSTOMERS

SQL_QUERY="
SELECT first_name, last_name INTO best_customers_${INDEX_NUMBER} FROM customers_${INDEX_NUMBER}
WHERE ST_DISTANCESpheroid(
	geog::geometry,
	'SRID=4326;POINT( 41.39988501005976 -75.67329768604034)'::geometry,
	'SPHEROID["\""WGS 84"\"",6378137,298.257223563]'
)/1000 < 50;
"

psql $SQL_JDBC_STRING -c "\connect ${SQL_DATABASE}"
psql $SQL_JDBC_STRING -c " ${SQL_QUERY}"

if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: Best customers detected and inserted ino best_customers_${INDEX_NUMBER}" >> $LOG_FILE
fi

# EXPORT TO CSV

SQL_TO_CSV="COPY best_customers_${INDEX_NUMBER} TO STDOUT WITH (FORMAT CSV, HEADER);"
psql $SQL_JDBC_STRING -c "\connect ${SQL_DATABASE}"
psql $SQL_JDBC_STRING -c " $SQL_TO_CSV" > $OUTPUT/best_customers_${INDEX_NUMBER}.csv # copy to stdout and to local filesystem cause database is on docker
zip ${WORKSPACE}/best_customers_${INDEX_NUMBER}.zip $OUTPUT/best_customers_${INDEX_NUMBER}.csv 

if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: best_customers_${INDEX_NUMBER} export was succesfully prepared" >> $LOG_FILE
fi
# SEND THE SECOND EMAIL

EMAIL="
    Creation date: ${TIMESTAMP} 
    Number of rows: `wc -l < output/best_customers_${INDEX_NUMBER}.csv`
"

echo $EMAIL | mailx -a best_customers_${INDEX_NUMBER}.zip -s "[$TIMESTAMP] BEST CUSTOMERS EXPORT" testowy.test39@gmail.com   
if [ "$?" -eq "0" ]
then
    echo "[${TIMESTAMP_HMS}]: Info email was sent" >> $LOG_FILE
fi

# CLEANING

rm -r $WORKSPACE/to_insert.csv $WORKSPACE/customers_${INDEX_NUMBER}_inserts.sql $WORKSPACE/tmp $WORKSPACE/best_customers_${INDEX_NUMBER}.zip $DOWNLOAD $OUTPUT