# Function to generate grid_network blocks
generate_grid_network_blocks() {
  # Request Number of Grid_Network Deployements 
  # read -p "How many Grid Networks Are you Deploying[1]: " NUM_NetRD
  if [[ -z $NUM_NetRD ]]; then
  NUM_NetRD="1"
  fi
  # Initialize empty array to store grid_network blocks
  NET_BLOCKS=()

  # Loop through and request input for Grid_Network Node, Grid_Network Name, Grid_Network Descritption, IP_RANGE, Add Wire Gaurd Access
  echo "Enter values for each Grid_Network:"
  for i in $(seq 1 $NUM_NetRD)
  do
    read -p "Enter All of the Node IDs you will be Deploying on [1, 2]:" GRID_NODE
	if [[ -z $GRID_NODE ]]; then
    GRID_NODE="[1, 2]"
    fi
    read -p "Name Your Grid Network[Net1]:" NetName
	if [[ -z $NetName ]]; then 
	NetName="Net1"
	fi
    read -p "Describe Your Network[MyNetwork1]:" NetDesc
	if [[ -z $NetDesc ]]; then 
	NetDesc="MyNetwork1"
	fi
    read -p "Enter the Private Subnet Ip Range of your Network[10.0.0.0/16]" IP_RANGE
	if [[ -z $IP_RANGE ]]; then 
	IP_RANGE="10.0.0.0/16"
	fi
	read -p "Add WireGaurd Access True/False:  (y/n) [Y]" addwgaccess
	if [[ -z $addwgaccess ]]; then
		addwgaccess=y
	fi
	if [[ $addwgaccess == "y" ]]; then
		addwgaccess=true
	else
		addwgaccess=false
	fi
	

    # Create grid_network block string with input values
    NET_BLOCK="resource \"grid_network\" \"net1\" {
    nodes = $GRID_NODE
    ip_range = \"$IP_RANGE\"
    name = \"$NetName\"
    description = \"$NetDesc\"
    add_wg_access = \"$addwgaccess\"
}"

    # Add grid_network block string to array
    NET_BLOCKS+=("$NET_BLOCK")
  done
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
    read -p "Choose a Description for VM $i [MyVm$i]: " VMDESC
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
	read -p "Enter Amount of Memor in MB for Vm $i  [4096]: " NUM_MEMORY
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

    # Create disks block string with input values 
	DISK_BLOCK="disks { \n	 name = \"$DISKNAME\" \n	 size = \"$DISKSIZE\" \n  } \n  "
	
	# Join DISK_BLOCKS array with newline separator
	DISK_BLOCKS+=$(IFS=$'\n'; echo "${DISK_BLOCK[*]}")
	
	# Create mount block string with input values 
	MOUNT_BLOCK="mounts { \n	 disk_name = \"$DISKNAME\" \n	 mount_point = \"$MOUNT_POINT\" \n	}\n	"
    
	# Join MOUNT_BLOCKS array with newline separator
	MOUNT_BLOCKS+=$(IFS=$'\n'; echo "${MOUNT_BLOCK[*]}")
  done	
    
	# Create vm block string with input values
	VMS_BLOCK="resource \"grid_deployment\" \"D$i\" { \n  node = $VMNODE \n  network_name = grid_network.net1.name \n  ${DISK_BLOCKS[*]}  vms { \n    name = \"$VMNAME\" \n    description = \"$VMDESC\" \n    flist = \"$FLIST\" \n    cpu = \"$NUM_CPU\" \n    publicip = \"$PUB4\" \n    publicip6 = \"$PUB6\" \n    memory = \"$NUM_MEMORY\" \n    ${MOUNT_BLOCKS[*]}planetary = \"$YGG\" \n    env_vars = { \n      SSH_KEY = \"\${var.SSH_KEY}\" \n    } \n  } \n} \n"

    
	# Add vm block string to array
	VMS_BLOCKS+=$(IFS=$'\n'; echo "${VMS_BLOCK[*]}")
	
	#  Call Function To Generate Output_blocks 
	generate_vm_output_blocks
	
	
  done
}

# Function to Generate Output_Blocks 
generate_vm_output_blocks()  {
 # Print list of available output options
  echo "Available output variables:"
  echo "1. output wiregaurd gateway configuration"
  echo "2. output public IPV4 address of the VM "
  echo "3. output public IPV6 address of the VM "
  echo "4. output planetary network ip address of the VM"

 # Request input for number of outputs to create for VM
  read -p "Enter the number of output variables you want to create for VM $i[4]:" NUM_OUTPUTS
  if [[ -z $NUM_OUTPUTS ]]; then
		NUM_OUTPUTS="4"
	fi
  
  # Initialize empty arrays to store disk and vm blocks
  OUTPUT_BLOCKS=()
  
  # Loop through and request input for OUTPUT_NAME for each output
  for (( j=1; j<=$NUM_OUTPUTS; j++ )); do
    # Print list of available output options
    echo "Enter the number of the output variable you want to create for VM $i (e.g. 1):"
    read OUTPUT_NUM
    # Get OUTPUT_NAME from available options
    if [[ $OUTPUT_NUM -eq 1 ]]; then
      # Create output block string with input values 
	  OUTPUT_BLOCK+="output \"wg_config"$i"\" { \n  value = grid_network.net1.access_wg_config \n} \n"
		# Join OUTPUT_BLOCKS array with newline separator
	  OUTPUT_BLOCKS=$(IFS=$'\n'; echo "${OUTPUT_BLOCK[*]}")
    elif [[ $OUTPUT_NUM -eq 2 ]]; then
      # Create output block string with input values
	  OUTPUT_BLOCK+="output \"public_ip"$i"\" {\n value = grid_deployment.D$i.vms[0].computedip \n} \n"
	  # Join OUTPUT_BLOCKS array with newline separator
	  OUTPUT_BLOCKS=$(IFS=$'\n'; echo "${OUTPUT_BLOCK[*]}")
    elif [[ $OUTPUT_NUM -eq 3 ]]; then
      OUTPUT_BLOCK+="output \"public_ip6"$i"\" { \n  value = grid_deployment.D$i.vms[0].computedip6 \n} \n"
	  # Join OUTPUT_BLOCKS array with newline separator
	  OUTPUT_BLOCKS=$(IFS=$'\n'; echo "${OUTPUT_BLOCK[*]}")
    elif [[ $OUTPUT_NUM -eq 4 ]]; then
      OUTPUT_BLOCK+="output \"ygg_ip"$i"\" { \n   value = grid_deployment.D$i.vms[0].ygg_ip \n} \n"
	  # Join OUTPUT_BLOCKS array with newline separator
	  OUTPUT_BLOCKS=$(IFS=$'\n'; echo "${OUTPUT_BLOCK[*]}")
	fi
  done
}

 generate_main_tf() {
  # Print variables block
  printf "
variable \"MNEMONICS\" {
  type        = string
  description = \"The mnemonic phrase used to generate the seed for the node.\"
}

variable \"NETWORK\" {
  type        = string
  default     = \"main\"
  description = \"The network to connect the node to.\"
}

variable \"TF_PARALLELISM\" {
  type        = number
  default     = 1
  description = \"The level of parallelism to use when applying changes.\"
}

variable \"SSH_KEY\" {
  type = string
}


terraform {
  required_providers {
    grid = {
      source = \"threefoldtech/grid\"
    }
  }
}

provider \"grid\" {
    mnemonics = \"\${var.MNEMONICS}\"
    network   = \"\${var.NETWORK}\"  
}
${NET_BLOCKS[*]}
${VMS_BLOCKS[*]}
${OUTPUT_BLOCKS[*]}" > $SAVE_PATH/main.tf
}

# Request path to save main.tf
echo "Enter the path where you want to save main.tf (e.g. /home/user/):"
read SAVE_PATH

# Check and Create Directory 
# check_and_create_dir "$save_path"

# Prompt for identifier of grid_deployment resource
# echo "Enter grid deployment identifier:"
# read GRID_ID

# Request node IDs for the grid_deployment resource
#read -p "Enter the node IDs of all the nodes you would like to deploy on[1, 2]:" GRID_NODE
#if [[ -z $GRID_NODE ]]; then
#  GRID_NODE="1"
 # fi

# Request network name
#echo "Enter the name of the grid network:"
#read  GRID_NETNAME

# Call generate_grid_network_blocks
generate_grid_network_blocks

# Call generate_grid_deployment_blocks function
generate_grid_deployment_blocks

# Call generate_main_tf function
generate_main_tf

echo "main.tf successfully created at $SAVE_PATH/main.tf"


     
