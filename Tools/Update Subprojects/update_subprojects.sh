#!/bin/sh

#S12CForth
git pull -s subtree S12CForth master
git tag -d `git tag | grep S12CForth`
