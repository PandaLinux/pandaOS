#!/bin/sh

shopt -s -o pipefail

function clean() {
    rm -rf /tmp/*
    rm -rf /tools
}

clean;
