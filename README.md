# Z80Pack

Docker image for Z80 emulation of CP/M 1, CP/M 2, CP/M 3 and MP/M II using Z80Pack

The Docker updates the system on restart to apply security and Linux updates.

To run Z80Pack on unRAID:

docker run -d --name="Z80Pack" \
--net="bridge" \
-e PUID="99" \
-e PGID="100" \
-e TZ="America/New_York" \
-v "/mnt/user/appdata/Z80Pack":"/config":rw \
z80pack

Changes:

2017-07-16
- Add the cpm13 and cpm14 scripts to /config folder.

2017-07-12
- Initial release.
