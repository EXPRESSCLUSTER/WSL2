#==============================
# Set parameters
#------------------------------
$vhdx = "M:\postgres.vhdx"
#==============================

wsl --shutdown
Dismount-DiskImage $vhdx

exit 0