# Create PostgreSQL Cluster

## Index
- [Evaluation Environment](#evaluation-environment)
- [Create Base Cluster](#create-base-cluster)
- [Install WSL2 on Both Servers](#install-wsl2-on-both-servers)
- [Install Docker on Both Ubuntu Servers](#install-docker-on-ubuntu-on-both-servers)
- [Create PostgreSQL Cluster](#create-postgresql-cluster)
- [Add Script Resource](#add-script-resource)

## Evaluation Environment
```
+--------------------------------------------------------------------------+
| Azure                                                                    |
| +---------------------------------+  +---------------------------------+ |
| | ws2022-01                       |  | ws2022-02                       | |
| | - Windows Server 2022           |  | - Windows Server 2022           | |
| | - CLUSTERPRO X 5.0              |  | - CLUSTERPRO X 5.0              | |
| | +-----------------------------+ |  | +-----------------------------+ | |
| | | WSL2                        | |  | | WSL2                        | | |
| | | +-------------------------+ | |  | | +-------------------------+ | | |
| | | | Ubuntu 22.04            | | |  | | | Ubuntu 22.04            | | | |
| | | | +---------------------+ | | |  | | | +---------------------+ | | | |
| | | | | Docker              | | | |  | | | | Docker              | | | | |
| | | | | +-----------------+ | | | |  | | | | +-----------------+ | | | | |
| | | | | | PostgreSQL 15.1 | | | | |  | | | | | PostgreSQL 15.1 | | | | | |
| | | | | +--------+--------+ | | | |  | | | | +--------+--------+ | | | | |
| | | | +----------|----------+ | | |  | | | +----------|----------+ | | | |
| | | +------------|------------+ | |  | | +------------|------------+ | | |
| | +--------------|--------------+ |  | +--------------|--------------+ | |
| +----------------|----------------+  +----------------|----------------+ |
|                  |                                    |                  |
|         +--------+--------+                  +--------+--------+         |
|         |   Mirror Disk   |--- Mirroring --->|   Mirror Disk   |         |
|         +-----------------+                  +-----------------+         |
+--------------------------------------------------------------------------+
```
- Azure: Standard D2s v5 (2 vcpus, 8 GiB memory)
- Windows Server 2022 Datacenter Azure Edition (Version 10.0.20348.1249)
- WSL2
- Ubuntu 20.04 (5.10.16.3-microsoft-standard-WSL2)
- Docker (Docker version 20.10.21, build baeda1f)
- PostgreSQL 15.1
- EXPRESSCLUSTER X 5.0 for Windows (13.02)

## Create Base Cluster
1. Create a cluster has on Mirror Disk Resource following [Installation and Configuration Guide]().
   - Data Partition Drive Letter: M
   - Cluster Partition Drive Letter: L

## Install WSL2 on Both Servers
1. Install WSL2.
   ```bat
   wsl --install
   ```
1. Restart OS and set user name and password for Ubuntu.

## Install Docker on Ubuntu on Both Servers
1. Start Ubuntu.
   ```bat
   wsl
   ```
1. Allow the user to do sudo without the password.
   ```sh
   sudo visudo
   ```
   ```
   # Allow members of group sudo to execute any command
   %sudo ALL=(ALL:ALL) ALL
   foo ALL=NOPASSWD: ALL
   ```
1. Install Docker following web site.
   - https://dev.to/felipecrs/simply-run-docker-on-wsl2-3o8
1. Stop Ubuntu.
   ```bat
   wsl --shutdown
   ```

## Create PostgreSQL Container
### Primary Server
1. Start Disk Management (diskmgmt.msc) and create a virtual hard disk on the data partition (e.g., M:) of the Mirror Disk Resource.
   1. [Action]
   1. [Create VHD]
      ```
      M:\postgres.vhdx
      ```
      - HELP ME: I cannot find out how to create VHDX file. If I install Hyper-V, I can do it. But, I don't want to install Hyper-V to just create VHDX file.
1. Attach the VHDX file.
   ```ps
   Mount-DiskImage M:\postgres.vhdx
   ```
1. Get the information of the VHDX file.
   ```ps
   $ret = Get-DiskImage M:\postgres.vhdx
   ```
1. Attach the VHDX file to Ubuntu.
   ```ps
   wsl --mount $ret.DevicePath --bare
   ```
1. Start Ubuntu.
   ```bat
   wsl
   ```
1. Create a partition (e.g., /dev/sdb2) with fdisk command.
1. Make ext4 file system.
   ```sh
   sudo mkfs -t ext4 /dev/sdb2
   ```
1. Create a mount point.
   ```sh
   sudo mkdir -p /mnt/postgres
   ```
1. Start Docker service.
   ```sh
   sudo service docker start
   ```
1. Pull PostgreSQL container image.
   ```sh
   sudo docker pull postgres:15.1
   ```
1. Create PostgreSQL container.
   ```sh
   sudo docker create \
   --name postgres \
   -e POSTGRES_PASSWORD=password \
   -e POSTGRES_DB=watch \
   -v /mnt/postgres:/var/lib/postgresql/data \
   -p 5432:5432 \
   postgres:15.1
   ```
1. Start PostgreSQL container.
   ```sh
   sudo docker start postgres
   ```
1. Run bash on PostgreSQL container.
   ```sh
   sudo docker exec -it postgres bash
   ```
1. Login to PostgreSQL server.
   ```
   psql -U postgres
   ```
1. Stop Ubuntu.
   ```bat
   wsl --shutdown
   ```
1. Dismount the VHDX file.
   ```ps
   Dismount-DiskImage M:\postgres.vhdx
   ```
1. Move the failover group to the secondary server.
   ```bat
   clpgrp -m <failover group name>
   ```

### Secondary Server
1. Attach the VHDX file.
   ```ps
   Mount-DiskImage M:\postgres.vhdx
   ```
1. Get the information of the VHDX file.
   ```ps
   $ret = Get-DiskImage M:\postgres.vhdx
   ```
1. Attach the VHDX file to Ubuntu.
   ```ps
   wsl --mount $ret.DevicePath --bare
   ```
1. Start Ubuntu.
   ```bat
   wsl
   ```
1. Create a mount point.
   ```sh
   sudo mkdir -p /mnt/postgres
   ```
1. Start Docker service.
   ```sh
   sudo service docker start
   ```
1. Pull PostgreSQL container image.
   ```sh
   sudo docker pull postgres:15.1
   ```
1. Create PostgreSQL container.
   ```sh
   sudo docker create \
   --name postgres \
   -e POSTGRES_PASSWORD=password \
   -e POSTGRES_DB=watch \
   -v /mnt/postgres:/var/lib/postgresql/data \
   -p 5432:5432 \
   postgres:15.1
   ```
1. Start PostgreSQL container.
   ```sh
   sudo docker start postgres
   ```
1. Run bash on PostgreSQL container.
   ```sh
   sudo docker exec -it postgres bash
   ```
1. Login to PostgreSQL server.
   ```
   psql -U postgres
   ```
1. Stop Ubuntu.
   ```bat
   wsl --shutdown
   ```
1. Dismount the VHDX file.
   ```ps
   Dismount-DiskImage M:\postgres.vhdx
   ```

## Add Script Resource
1. Start Cluster WebUI.
1. Add the user account of Windows Server.
   1. [Cluster Properties]
   1. [Account] tab
      - Add the user account.
1. Add Script Resource.
   1. [Detail] tab
      1. Replace start.bat and stop.bat with the following files.
        - [start.bat](../script/PostgreSQL/start.bat)
        - [stop.bat](../script/PostgreSQL/stop.bat)
      1. Add the following files.
        - [Start-PostgreSQL.ps1](../script/PostgreSQL/Start-PostgreSQL.ps1)
        - [Stop-PostgreSQL.ps1](../script/PostgreSQL/Stop-PostgreSQL.ps1)
      1. Click [Tuning].
      1. Set the user account to [Exec User].
1. Apply the configuration file.
1. Start the failover group.
1. Check the cluster status.
   ```bat
   clpstat --long
   ```
   ```
    ========================  CLUSTER STATUS  ===========================
     Cluster : cluster
     <server>
      *ws2022-01 ........................: Online
         lankhb1                         : Normal           LAN Heartbeat
       ws2022-02 ........................: Online
         lankhb1                         : Normal           LAN Heartbeat
     <group>
       failover .........................: Online
         current                         : ws2022-01
         md                              : Online
         script-postgres                 : Online
     <monitor>
       mdw1                              : Normal
       userw                             : Normal
    =====================================================================
   ```
<!--
## Add Database Monitor
1. Download PostgreSQL installer for Windows.
   - https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
1. Install Command Line Tools on both servres.
1. Start Cluster WebUI.
-->