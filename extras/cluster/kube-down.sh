#!/bin/sh -xe
docker rm -f $(docker stop $(docker ps -a -q))