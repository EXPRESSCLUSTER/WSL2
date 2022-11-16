#==============================
# Set parameters
#------------------------------
$vhdx = "M:\vhdx\postgresql.vhdx"
#==============================

wsl --shutdown
Dismount-DiskImage $vhdx

exit 0