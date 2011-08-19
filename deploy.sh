#!/bin/sh

rsync -av . beta.sms.contextoptional.com:liker/ --checksum --exclude=.git --exclude=tmp --exclude=bundle --exclude=.sass-cache --exclude=.bundle $*
