#!/bin/sh
docker-compose down
docker rmi antaresqaq/myhadoop:hdp
docker build --rm --tag antaresqaq/myhadoop:hdp .
docker-compose up -d