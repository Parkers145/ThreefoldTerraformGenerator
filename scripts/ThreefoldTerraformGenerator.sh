# Function to generate grid_network blocks
generate_grid_network_blocks() {
  # Initialize empty array to store grid_network blocks
  NET_BLOCKS=()

  # Loop through and request input for Grid_Network Node, Grid_Network Name, Grid_Network Descritption, IP_RANGE, Add Wire Gaurd Access
  echo "Enter values for each Grid_Network:"
  for i in $(seq 1 $NUM_NetRD)
  do
    read -p "Add Grid_Network Identifer: " NetId
    read -p "Enter Grid_Network Node: " NUM_NetNo
    # read -p "Enter Grid_Network Name: " NetName
    read -p "Enter Grid_Network Description: " NetDesc
    read -p "Enter Grid_Network IP_RANGE: " IP_RANGE
    read -p "Add WireGaurd Access True/False: " addwgaccess

    # Create grid_network block string with input values
    NET_BLOCK="
resource \"grid_network\" \"$NetId\" {
    nodes = [$NUM_NetNo]
    ip_range = \"$IP_RANGE\"
    name = \"$GRID_NETNAME\"
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
  DISK_BLOCKS=()
  VMS_BLOCKS=()

  # Request input for number of disks blocks to add
  read -p "Enter the number of disk blocks you want to add: " NUM_DISKS

  # Loop through and request input for DISKNAME and DISKSIZE for each disk
  echo "Enter values for each disk:"
  for i in $(seq 1 $NUM_DISKS)
  do
    read -p "Enter disk name: " DISKNAME
    read -p "Enter disk size: " DISKSIZE

    # Create disks block string with input values
    DISK_BLOCK="  disks {
    name = \"$DISKNAME\"
    size = \"$DISKSIZE\"
  }"

    # Add disks block string to array
    DISK_BLOCKS+=("$DISK_BLOCK")
  done

  # Request input for number of VMs to create
  read -p "Enter the number of VMs you want to create: " NUM_VMS

  # Loop through and request input for VMNAME, VMDESC, FLIST, PUB4, PUB6, MEMORY, and YGG
  echo "Enter values for each VM:"
  for i in $(seq 1 $NUM_VMS)
  do
    read -p "Enter vm name: " VMNAME
    read -p "Enter vm description: " VMDESC
    read -p "Enter vm flist: " FLIST
    read -p "Enter vm public ip4: " PUB4
    read -p "Enter vm public ip6: " PUB6
    read -p "Enter vm memory: " NUM_MEMORY
    read -p "Enter vm planetary node: " YGG
    read -p "Enter vm cpu: " NUM_CPU

    # Initialize MOUNT_BLOCKS array
    MOUNT_BLOCKS=()

    # Request input for number of mounts to create
    read -p "Enter the number of mounts you want to create for VM $i: " NUM_MOUNTS

    # Loop through and request input for DISKNAME and MOUNTPOINT for each mount
    for ((j=1;j<=NUM_MOUNTS;j++)); do
      # Print available disks
      printf "\nAvailable disks:\n"
      for k in "${!DISK_BLOCKS[@]}"; do
          printf "%s\n" "$k"
      done

            # Request input for disk to mount
      read -p "Enter name of disk to mount for mount $j: " DISK_NAME

      # Request input for mount point
      read -p "Enter mount point for disk $DISK_NAME: " MOUNT_POINT

      # Create mount block string with input values and add to array
      MOUNT_BLOCK="mounts {
        disk_name = \"$DISK_NAME\"
        mount_point = \"$MOUNT_POINT\"
      }"
      MOUNT_BLOCKS+=("$MOUNT_BLOCK")
    done

    # Create vm block string with input values
    VMS_BLOCK="  vms {
      name = \"$VMNAME\"
      description = \"$VMDESC\"
      flist = \"$FLIST\"
      cpu = \"$NUM_CPU\"
      publicip = \"$PUB4\"
      publicip6 = \"$PUB6\"
      memory = \"$NUM_MEMORY\"
      planetary = \"$YGG\"
      env_vars = {
        SSH_KEY = \"$SSH_KEY\"
      }
      ${MOUNT_BLOCKS[@]}
    }"

    # Add vm block string to array
    VMS_BLOCKS+=("$VMS_BLOCK")
  done
}

# Function to generate main.tf
generate_main_tf() {
  # Concatenate DISK_BLOCKS and VMS_BLOCKS arrays and create main.tf
  printf "resource \"grid_network\" \"$NET_ID\" {
  nodes = [$NET_NODES]
  ip_range = \"$IP_RANGE\"
  name = \"$NET_NAME\"
  description = \"$NET_DESC\"
  add_wg_access = \"$addwgaccess\"
}\n\nresource \"grid_deployment\" \"$GRID_ID\" {
  nodes = [$GRID_NODE]
  network = \"$GRID_NETNAME\"
  ${DISK_BLOCKS[@]}
  ${VMS_BLOCKS[@]}
}" > $SAVE_PATH/main.tf

  echo "main.tf successfully created at $SAVE_PATH/main.tf"
}

# Request path to save main.tf
echo "Enter the path where you want to save main.tf (e.g. /home/user/):"
read SAVE_PATH

# Prompt for identifier of grid_deployment resource
echo "Enter grid deployment identifier:"
read GRID_ID

# Request node IDs for the grid_deployment resource
echo "Enter the node IDs of the nodes you would like to deploy on:"
read GRID_NODE

# Request network name
echo "Enter the name of the grid network:"
read GRID_NETNAME

# Call generate_grid_network_blocks
generate_grid_network_blocks

# Call generate_grid_deployment_blocks function
generate_grid_deployment_blocks

# Call generate_main_tf function
generate_main_tf

echo "main.tf successfully created at $SAVE_PATH/main.tf"


     
