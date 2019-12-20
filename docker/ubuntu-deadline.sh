#!/bin/sh

apt-get update

apt-get install ssl-dev

ulimit -n 64000

# Install Deadline
/deadline/DeadlineRepository-*-linux-x64-installer.run

# Run DeadlineRCS
/opt/Thinkbox/Deadline10/bin/deadlinercs