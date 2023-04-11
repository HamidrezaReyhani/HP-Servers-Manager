# iLOREST_DISK_IDENTIFIER
# Determine Real Location of disk in baremetal os layer on the server G9 DL380:

ILOREST INSTALLATION:
Install the required keys from HP.
```
curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048.pub | apt-key add -
curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub | apt-key add -
curl https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub | apt-key add -
```
Add the HP APT-GET repository to your system.
```
add-apt-repository 'deb [arch=amd64,i386] http://downloads.linux.hpe.com/SDR/repo/ilorest bionic/current non-free'
apt-get update
```
On the HP DL380 server, Install the HP ilO RESTful Interface Tool using the following command.
```
apt-get install ilorest
```
Start the HP iLo rest command prompt using the following command.
```
ilorest
```
Determine how many disk allocated to os:
```
blkid /dev/sd[a-z]|wc -l
```

Determine ArrayControllers Redfish api path:
```
ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/ --url=$IP -u $USER -p $PASSWORD 2>/dev/null|grep -A2 Member|grep href|cut -d '"' -f4
```
Determine how many DiskDrives avilable on Server:
```
ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/3/DiskDrives/ --url=$IP -u $USER -p $PASSWORD 2>/dev/null|grep href|head -n -1|wc -l
```

Determine available DiskDrives Redfish api path:
```
ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/3/DiskDrives/ --url=$IP -u $USER -p $PASSWORD 2>/dev/null|grep -oE '(href).+'|head -n -1|cut -d '"' -f3
```
Determine Specified DiskDrive number 16 SerialNumber:
```
ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/3/DiskDrives/16/ --url=$IP -u $USER -p $PASSWORD 2>/dev/null|grep SerialNumber|cut -d '"' -f4
```
Determine how many LogicalDrives avilable on Server:
```
ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/3/LogicalDrives/ --url=$IP -u $USER -p $PASSWORD 2>/dev/null|grep href|head -n -1|wc -l
```
Determine available LogicalDrives Redfish api path:
```
ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/3/LogicalDrives/ --url=$IP -u $USER -p $PASSWORD 2>/dev/null|grep -oE '(href).+'|head -n -1|cut -d '"' -f3
```
Determine Specified LogicalDrive number 1 VolumeUniqueIdentifier:
```
ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/3/LogicalDrives/ --url=$IP -u $USER -p $PASSWORD 2>/dev/null|grep VolumeUniqueIdentifier|cut -d '"' -f4
```
as you know first logical drive will allocate as /dev/sda so another logical drives will allocate Respectively as /dev/sd*
we can grep "udevadm info --query=all --name=/dev/sda" command output to  `Determined Specified LogicalDrive number 1 VolumeUniqueIdentifier` for first disk like this:

```
udevadm info --query=all --name=/dev/sda|grep $(ilorest rawget /redfish/v1/Systems/1/SmartStorage/ArrayControllers/3/LogicalDrives/ --url=192.168.17.157 -u $USER -p $PASSWORD 2>/dev/null|grep VolumeUniqueIdentifier|cut -d '"' -f4)|grep ID_SERIAL_SHORT|cut -d '=' -f2 
```
if above command have output disk location is true.
