# Generic Linux Init.d Initialization Script

## Description
This script is a starting point for those packages that don't come with initialization script that you want to run as a daemon.

## Prerequisites
1. CentOS/RHEL <= 6.x
    - Linux systems that use init.d and not ***systemd*** (CentOS/RHEL 7)

## Usage
1. Clone to system from Github.<br>
  ```git clone https://github.com/bonusbits/initd_script.git /path/to/clone/```
2. Copy script to init.d<br>
  ```sudo cp /path/to/clone/initd_script.sh /etc/init.d/myserviced```
3. Make script executable<br>
```sudo chmod +x /etc/init.d/myserviced```
4. Edit Custom Variables<br>
  ```sudo vim /etc/init.d/myserviced```<br>
  ```# region Edit These Variables```<br>
  servicename=**myserviced**<br>
  binary=**/bin/bash**<br>
  script=**/opt/application/runscript.sh**<br>
  logfile=**/var/log/myserviced/myserviced.log**<br>
  pidfile=**/var/run/myserviced/myserviced.pid**<br>
  user=**myservice**<br>
  ```# endregion Edit These Variables```
5. Add to Chkconfig<br>
  ```sudo chkconfig --add myserviced```
---