#!/bin/bash

docker run -d --name="Z80Pack" \
--net="bridge" \
-p 4200:4200 \
-e PUID="99" \
-e PGID="100" \
-e TZ="America/Chicago" \
-v "/mnt/user/appdata/Z80Pack":"/config":rw \
dlandon/z80pack
