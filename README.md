# Z80Pack

Docker image for Z80 emulation of CP/M 1, CP/M 2, CP/M 3 and MP/M II using Z80Pack

The Docker updates the system on restart to apply security and Linux updates.

To run Z80Pack on unRAID:

docker run -d --name="Z80Pack" \
--net="bridge" \
-p 4200:4200 \
-e PUID="99" \
-e PGID="100" \
-e TZ="America/New_York" \
-v "/mnt/user/appdata/Z80Pack":"/config":rw \
z80pack

To access the shell in a box gui: https://IP:4200
  User: vintage
  Password: computer.

You will be taken directly to the /root/z80pack/cpmsim directory.

Use the command 'sudo ./cpm' to run the simulator with root privileges.

Changes:

2017-07-17
- Add shell in a box for gui access to the Docker.

2017-07-16
- Add the cpm13 and cpm14 scripts to /config folder.

2017-07-12
- Initial release.
