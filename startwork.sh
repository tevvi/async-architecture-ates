#!/bin/bash

sudo cp /etc/docker/daemon_async.json /etc/docker/daemon.json
sudo systemctl restart docker