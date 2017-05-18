#!/bin/sh

#S12CBase
git pull -s subtree S12CBase master
git tag -d `git tag | grep S12CBase`
