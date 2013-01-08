#!/bin/sh

#HSW12
git pull -s subtree HSW12 master
git tag -d `git tag | grep HSW12`
