# ThreefoldTerraformGenerator
This is a work in progress, Currently the script generates Grid_network And Grid Deployment blocks.I welcome anyones additions or changes. currently will fail when creating more then one of each block at a time.  Here is an example of what the script is currently able to output when using one of each block 

```
resource "grid_network" "" {
  nodes = []
  ip_range = "192.168.1.0/24"
  name = ""
  description = ""
  add_wg_access = "true"
}

resource "grid_deployment" "d1" {
  nodes = [1,2]
  network = "network1"
    disks {
    name = "disk1"
    size = "25"
  }
    vms {
      name = "vm1"
      description = "vmdesc"
      flist = "flist"
      cpu = "4"
      publicip = "ip4"
      publicip6 = "ip6"
      memory = "mem"
      planetary = "ygg"
      env_vars = {
        SSH_KEY = ""
      }
      mounts {
        disk_name = "disk1"
        mount_point = "/data"
      }
    }
}
```



The script contains two functions: generate_grid_network_blocks and generate_grid_deployment_blocks.

The generate_grid_network_blocks function is used to create one or more "grid_network" blocks for a Terraform configuration file. The function prompts the user to enter values for the following fields for each grid_network block:

NetId: the identifier for the grid_network resource
NUM_NetNo: the node for the grid_network
NetDesc: the description for the grid_network
IP_RANGE: the IP range for the grid_network
addwgaccess: a boolean value indicating whether to add WireGuard access for the grid_network
The function then creates a string representing a grid_network block using the input values, and adds the block to an array of grid_network blocks.

The generate_grid_deployment_blocks function is used to create one or more "disk" and "vm" blocks for a Terraform configuration file. The function first prompts the user to enter the number of disk blocks to create, and then prompts the user to enter values for the following fields for each disk:

DISKNAME: the name of the disk
DISKSIZE: the size of the disk
The function then creates a string representing a disk block using the input values, and adds the block to an array of disk blocks.

Next, the function prompts the user to enter the number of VM blocks to create, and then prompts the user to enter values for the following fields for each VM:

VMNAME: the name of the VM
VMDESC: the description of the VM
FLIST: the flist for the VM
PUB4: the public IP4 address for the VM
PUB6: the public IP6 address for the VM
NUM_MEMORY: the amount of memory for the VM
YGG: the planetary node for the VM
NUM_CPU: the number of CPUs for the VM
For each VM, the function also prompts the user to enter the number of mount blocks to create, and then prompts the user to enter values for the following fields for each mount:

DISK_NAME: the name of the disk to mount
MOUNT_POINT: the mount point for the disk
The function then creates a string representing a mount block using the input values, and adds the block to an array of mount blocks for the VM.

Finally, the function creates a string representing a VM block using the input values and the array of mount blocks, and adds the block to an array of VM blocks.

That's it! The script allows the user to create one or more grid_network, disk, and vm blocks for a Terraform configuration file by prompting the user to enter values for the various fields.
