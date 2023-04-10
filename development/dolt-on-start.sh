#!/bin/bash -x

cd "/var/lib/nautobot_dbs"
echo "date = $(date)"


createDb () {
    dbName=$1

    echo "creating an empty database $dbName"
    rm -rf $dbName
    dolt sql -q "CREATE DATABASE $dbName CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

    echo "done creating $dbName"
    echo "---"
}

echo "creating databases"
createDb nautobot
createDb test_nautobot

echo "come back to root"
cd /var/lib/nautobot_dbs

mkdir -p /var/lib/logs

echo "starting dolt..."
echo "dolt version = $(dolt version)" > /var/lib/logs/dolt-version.log 2>&1

# Start dolt server, no profiling, write all output to /var/log/nautobot/dolt.log
dolt --ignore-lock-file sql-server --config /var/lib/dolt-config.yaml 2>&1 | tee /var/lib/logs/dolt-sql.log

# Start dolt server, create profiling file, write all output to /var/log/nautobot/dolt.log
# dolt --ignore-lock-file --prof mem sql-server --config /var/lib/dolt-config.yaml > /var/lib/logs/dolt-sql.log 2>&1

# Start dolt server, start profiling server, write all output to /var/log/nautobot/dolt.log
# dolt --ignore-lock-file --pprof-server sql-server --config /var/lib/dolt-config.yaml > /var/lib/logs/dolt-sql.log 2>&1

# Start dolt server, start profiling server, logging to stdout
# dolt --ignore-lock-file --pprof-server sql-server --config /var/lib/dolt-config.yaml

# Start dolt server, no profiling, no logging
# dolt --ignore-lock-file sql-server --config /var/lib/dolt-config.yaml
