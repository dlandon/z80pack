#!/bin/bash

docker run -d --name="Z80Pack" \
--net="bridge" \
-e PUID="99" \
-e PGID="100" \
-e TZ="America/New_York" \
-v "/mnt/user/appdata/Z80Pack":"/config":rw \
z80pack
