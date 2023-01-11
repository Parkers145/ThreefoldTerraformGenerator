# ThreefoldTerraformGenerator

The **root_menu** function is the main menu of the script. It displays a welcome message and a list of options to the user, then prompts the user to enter a selection. The user's input is validated to ensure it is a number between 1 and 4, and then the corresponding action is taken based on the selection. The available options are:

- Install Terraform
- Generate a main.tf
- Generate an env.tfvars
- Modify an existing example main.tf for deployment with env.tfvars file. 

The **install_terraform function** installs Terraform, if it is not already installed. The function checks if Terraform is installed by checking if the terraform command is available. If Terraform is already installed, a message is displayed to the user and the function exits. If Terraform is not installed, the function downloads and installs the latest version of Terraform.

The **generate_a_main_tf** function generates a main.tf file. This file is a configuration file for Terraform and contains the necessary information for deploying infrastructure with Terraform.

The **generate_a_env_tfvars** function generates an env.tfvars file. This file contains variables and their values that can be used in the main.tf file.

The **deploy_main_tf function** deploys the infrastructure described in the main.tf file using Terraform.

**FUNCTIONALITY STATUSES**

**New Functionality**
- Root Menu with 4 fucntions
	- install terraform
		- alpha feature, should work 
	- Generate a main.tf 
		- working with one known issue 
			- must restart script before generating a second main.tf or output blocks from previous main.tf's will print to new main.tf 
				-susupect handling of $OUTPUT_BLOCK
      - need to add output wiregaurd vm ip variable. 
	- Generate a env.tfvars
		- Working with minimal testing
	- Deploy a main.tf 
		- Untested, new start of feature

**Code Improvements**
- Input validation on most prompts
- Default Values on most prompts 

**Planned Features**
- Modify Exsisting Main.tf for use with env.tfvars
- Modify Exsisting Main.tf from outside provider for use with the grid. 
   - Reads Main.tf for deploying on outside provider and creates a replica grid deployment main.tf 
    - AWS Cloud Copy
    - Google Cloud Copy 
- Deploy a "***" functionality
  - Deploy a Forwarder, 
  - Deploy a Gateway 
  - Deploy Storage Devices



*Example Output of generate_a_main_tf*
This is unaltered output from the function with requested setup of 3 vms in a wiregaurd network with mutliple disks, and appropriate output variables for each vm 
- This can be immeadiately deployed using a env.tfvars file with 

```
terraform apply -parallelism=1 -auto-approve -var-file="/deployments/prod.tfvars"
``` 

```

variable "MNEMONICS" {
  type        = string
  description = "The mnemonic phrase used to generate the seed for the node."
}

variable "NETWORK" {
  type        = string
  default     = "main"
  description = "The network to connect the node to."
}

variable "SSH_KEY" {
  type = string
}


terraform {
  required_providers {
    grid = {
      source = "threefoldtech/grid"
    }
  }
}

provider "grid" {
    mnemonics = "${var.MNEMONICS}"
    network   = "${var.NETWORK}"  
}
resource "grid_network" "net1" {
    nodes = [1, 2]
    ip_range = "10.0.0.0/16"
    name = "Net1"
    description = "MyNetwork1"
    add_wg_access = "true"
}
resource "grid_deployment" "D1" { 
  node = 1 
  network_name = grid_network.net1.name 
  disks { 
	 name = "Disk1" 
	 size = "25" 
  } 
  disks { 
	 name = "Disk2" 
	 size = "25" 
  } 
  disks { 
	 name = "Disk3" 
	 size = "25" 
  } 
    vms { 
    name = "VM1" 
    description = "MyVm1" 
    flist = "https://hub.grid.tf/tf-official-vms/ubuntu-20.04-lts.flist" 
    cpu = "4" 
    publicip = "true" 
    publicip6 = "true" 
    memory = "4096" 
    mounts { 
	 disk_name = "Disk1" 
	 mount_point = "/data1" 
	}
	mounts { 
	 disk_name = "Disk2" 
	 mount_point = "/data2" 
	}
	mounts { 
	 disk_name = "Disk3" 
	 mount_point = "/data3" 
	}
	planetary = "true" 
    env_vars = { 
      SSH_KEY = "${var.SSH_KEY}" 
    } 
  } 
} 
resource "grid_deployment" "D2" { 
  node = 2 
  network_name = grid_network.net1.name 
  disks { 
	 name = "Disk1" 
	 size = "25" 
  } 
  disks { 
	 name = "Disk2" 
	 size = "25" 
  } 
    vms { 
    name = "VM2" 
    description = "MyVm2" 
    flist = "https://hub.grid.tf/tf-official-vms/ubuntu-20.04-lts.flist" 
    cpu = "4" 
    publicip = "true" 
    publicip6 = "true" 
    memory = "4096" 
    mounts { 
	 disk_name = "Disk1" 
	 mount_point = "/data1" 
	}
	mounts { 
	 disk_name = "Disk2" 
	 mount_point = "/data2" 
	}
	planetary = "true" 
    env_vars = { 
      SSH_KEY = "${var.SSH_KEY}" 
    } 
  } 
} 
resource "grid_deployment" "D3" { 
  node = 1 
  network_name = grid_network.net1.name 
  disks { 
	 name = "Disk1" 
	 size = "25" 
  } 
  disks { 
	 name = "Disk2" 
	 size = "25" 
  } 
  disks { 
	 name = "Disk3" 
	 size = "25" 
  } 
    vms { 
    name = "VM3" 
    description = "MyVm3" 
    flist = "https://hub.grid.tf/tf-official-vms/ubuntu-20.04-lts.flist" 
    cpu = "4" 
    publicip = "true" 
    publicip6 = "true" 
    memory = "4096" 
    mounts { 
	 disk_name = "Disk1" 
	 mount_point = "/data1" 
	}
	mounts { 
	 disk_name = "Disk2" 
	 mount_point = "/data2" 
	}
	mounts { 
	 disk_name = "Disk3" 
	 mount_point = "/data3" 
	}
	planetary = "true" 
    env_vars = { 
      SSH_KEY = "${var.SSH_KEY}" 
    } 
  } 
} 

output "wg_config1" { 
  value = grid_network.net1.access_wg_config 
} 
output "public_ip1" {
 value = grid_deployment.D1.vms[0].computedip 
} 
output "public_ip61" { 
  value = grid_deployment.D1.vms[0].computedip6 
} 
output "ygg_ip1" { 
   value = grid_deployment.D1.vms[0].ygg_ip 
} 
output "public_ip2" {
 value = grid_deployment.D2.vms[0].computedip 
} 
output "public_ip62" { 
  value = grid_deployment.D2.vms[0].computedip6 
} 
output "ygg_ip2" { 
   value = grid_deployment.D2.vms[0].ygg_ip 
} 
output "public_ip3" {
 value = grid_deployment.D3.vms[0].computedip 
} 
output "public_ip63" { 
  value = grid_deployment.D3.vms[0].computedip6 
} 
output "ygg_ip3" { 
   value = grid_deployment.D3.vms[0].ygg_ip 
} 

```
