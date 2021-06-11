# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)



variable "tenant_id" {
  default = "a2e466aa-4f86-4545-b5b8-97da7c8febf3"
}
variable "subscription_id" {
  default= "4398a24f-81d9-469d-8b59-2f51ac63df2d"
}

variable "resource_group" {
  description = "The name of your Azure Resource Group."
  default     = "Rachid2"
}

variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "rachid"
}

variable "hostname" {
  description = "Virtual machine hostname. Used for local hostname, DNS, and storage-related names."
  default     = "rachid"
}


variable "vm-name" {
  description = "Virtual machine name"
  default =   "Rachid"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "westeurope"
}

variable "virtual_network_name" {
  description = "The name for your virtual network."
  default     = "RachidVnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.8.0.0/14"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default = "10.9.0.0/24"
}

variable "storage_account_tier" {
  description = "Defines the storage tier. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the replication type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B1ls"
}

variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "username" {
  description = "Administrator user name"
  default     = "rachid"
}


variable "password" {
  description = "Administrator password"
  default     = "Leouf31071987."
}

variable "source_network" {
  description = "Allow access from this network prefix. Defaults to '*'."
  default     = "*"
}
variable "cosmos_db_account_name" {
  default = "rachidcosmos"
}
variable "failover_location" {
  default =  "eastus"
}

variable "Rachid_count" { 
 
  default = 3
}

variable "dns_name" {
description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."

default     = "rachid"
}


variable "lb_ip_dns_name" {
  description = "DNS for Load Balancer IP"
  default="rachid"
}

variable "tag" {
  description= "Tags in Azure"
  default="Devops"
}
variable "vmcount" {
  description= "number of vms"
  default=2
}
