# Funtion to check and create save path directory
check_and_create_dir() {
  # $1 is the directory to check
  if [ ! -d "$1" ]; then
    # Directory does not exist, so create it
    mkdir "$1"
  fi
}

# Function to generate grid_deployment blocks
generate_grid_deployment_blocks() {
  # Initialize empty arrays to store disk and vm blocks
  VMS_BLOCKS=()
  
  # Request input for number of VMs to create
  read -p "Enter the number of VMs you want to create[1]: " NUM_VMS
  if [[ -z $NUM_VMS ]]; then
  NUM_VMS="1"
  fi
  # Loop through and request input for VMNAME, VMDESC, FLIST, PUB4, PUB6, MEMORY, and YGG
  echo "Enter values for each VM:"
  for i in $(seq 1 $NUM_VMS)
  do
	read -p "Choose node for vm $i [1]: " VMNODE
	if [[ -z $VMNODE ]]; then
    VMNODE="1"
	fi
	read -p "Choose a Name for VM $i [VM$i]: " VMNAME
	if [[ -z $VMNAME ]]; then
		VMNAME=VM$i
	fi
    read -p "Choose a Description for VM $i[MyVm$i]: " VMDESC
	if [[ -z $VMDESC ]]; then
		VMDESC=MyVm$i
	fi
    read -p "FLlist URL From Hub.Grid.TF [https://hub.grid.tf/tf-official-vms/ubuntu-20.04-lts.flist]: " FLIST
	if [[ -z $FLIST ]]; then
    FLIST="https://hub.grid.tf/tf-official-vms/ubuntu-20.04-lts.flist"
	fi
	read -p "Enter Number of Cores for VM $i [4]: " NUM_CPU
	if [[ -z $NUM_CPU ]]; then
    NUM_CPU="4"
	fi
	read -p "Enter  [4096]: " NUM_MEMORY
	if [[ -z $NUM_MEMORY ]]; then
    NUM_MEMORY="4096"
	fi
    read -p "Should VM $i have a public IPV4 address? (y/n) [Y] " PUB4
	if [[ -z $PUB4 ]]; then
		PUB4=y
	fi
	if [[ $PUB4 == "y" ]]; then
		PUB4=true
	else
		PUB4=false
	fi
    read -p "Should VM $i have a public IPV6 address? (y/n) [Y] " PUB6
	if [[ -z $PUB6 ]]; then
		PUB6=y
	fi
	if [[ $PUB6 == "y" ]]; then
		PUB6=true
	else
		PUB6=false
	fi
    read -p "Should VM $i have a Planetary Network Address? (y/n) [Y] " YGG
	if [[ -z $YGG ]]; then
		YGG=y
	fi
	if [[ $YGG == "y" ]]; then
		YGG=true
	else
		YGG=false
	fi
    
	# Initialize empty arrays to store disk blocks
	DISK_BLOCKS=()
	# Initialize MOUNT_BLOCKS array
    MOUNT_BLOCKS=()
	
	# Request input for number of disks blocks to add
	read -p "Enter the number of disk blocks you want to add[1]: " NUM_DISKS
	if [[ -z $NUM_DISKS ]]; then
		NUM_DISKS="1"
	fi

	# Loop through and request input for DISKNAME and DISKSIZE for each disk
	# for i in $(seq 1 $NUM_DISKS)
	for ((j=1;j<=NUM_DISKS;j++)); do
	# do
    read -p "Enter disk name for DISK $j[Disk$j]: " DISKNAME
	if [[ -z $DISKNAME ]]; then
		DISKNAME=Disk$j
	fi
    read -p "Enter the size in GB for $DISKNAME[25]: " DISKSIZE
	if [[ -z $DISKSIZE ]]; then
		DISKSIZE="25"
	fi
	 # Request input for mount point
    read -p "Enter mount point for disk $DISKNAME [/data$j]: " MOUNT_POINT
	if [[ -z $MOUNT_POINT ]]; then
		MOUNT_POINT="/data$j"
	fi

    # Create disks block string with input values and add to array 
	DISK_BLOCK="disks { \n	 name = \"$DISKNAME\" \n	 size = \"$DISKSIZE\" \n  } \n  "
	
	# Join DISK_BLOCKS array with newline separator
	DISK_BLOCKS+=$(IFS=$'\n'; echo "${DISK_BLOCK[*]}")
	
	# Create mount block string with input values 
	MOUNT_BLOCK="mounts { \n	 disk_name = \"$DISKNAME\" \n	 mount_point = \"$MOUNT_POINT\" \n	}\n	"
    
	# Join MOUNT_BLOCKS array with newline separator
	MOUNT_BLOCKS+=$(IFS=$'\n'; echo "${MOUNT_BLOCK[*]}")
  done	
    
	# Create vm block string with input values
	VMS_BLOCK="resource \"grid_deployment\" \"D$i\" { \n  node = [$VMNODE] \n  network_name = \"$GRID_NETNAME\" \n  ${DISK_BLOCKS[*]}  vms { \n    name = \"$VMNAME\" \n    description = \"$VMDESC\" \n    flist = \"$FLIST\" \n    cpu = \"$NUM_CPU\" \n    publicip = \"$PUB4\" \n    publicip6 = \"$PUB6\" \n    memory = \"$NUM_MEMORY\" \n    ${MOUNT_BLOCKS[*]}planetary = \"$YGG\" \n    env_vars = { \n      SSH_KEY = \"$SSH_KEY\" \n    } \n  } \n} \n"

    
	# Add vm block string to array
	VMS_BLOCKS+=$(IFS=$'\n'; echo "${VMS_BLOCK[*]}")
	
	
  done
}

# Function to generate main.tf
generate_main_tf() {
  # Concatenate DISK_BLOCKS and VMS_BLOCKS arrays and create main.tf
  printf "${VMS_BLOCKS[*]}" > $SAVE_PATH/main.tf

  echo "main.tf successfully created at $SAVE_PATH/main.tf"
}

# Request path to save main.tf
echo "Enter the path where you want to save main.tf (e.g. /home/user/):"
read "SAVE_PATH"

# Call generate_grid_deployment_blocks function
generate_grid_deployment_blocks

# Call generate_main_tf function
generate_main_tf

echo "main.tf successfully created at $SAVE_PATH/main.tf"
