#==============================
# Set parameters
#------------------------------
$vhdx = "M:\postgres.vhdx"
#==============================

Mount-DiskImage $vhdx
$ret = Get-DiskImage $vhdx
wsl --mount $ret.DevicePath --bare
wsl -e sudo mount /dev/sdb2 /mnt/postgres
wsl -e sudo service docker start
# FIXME: Need to check docker status
sleep 10
wsl -e sudo docker start postgres

exit 0