source "virtualbox-iso" "disk" {
  iso_url = "download/windows-10-enterprise-amd64.iso"
  iso_checksum = "md5:e469d0add9f698a1b48adce2520403ef"

  floppy_files = [
    "floppy/windows10/Autounattend.xml",
    "floppy/fixnetwork.ps1",
    "floppy/microsoft-updates.bat",
    "floppy/win-updates.ps1",
    "floppy/winrm-enable.ps1",
    "floppy/winrm-disable.ps1",
  ]

  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c Packer_Shutdown"
  post_shutdown_delay = "2m"
  communicator = "winrm"
  guest_additions_mode = "disable"
  guest_os_type = "Windows10_64"
  headless = true
  vboxmanage = [
    [ "setextradata", "{{.Name}}", "VBoxInternal/CPUM/IsaExts/CMPXCHG16B", "1" ],
    ["modifyvm", "{{.Name}}", "--vram", "48"],
  ]
  gfx_controller = "vboxsvga"
  cpus = var.cpus
  memory = var.memory
  #disk_size = "40960"
  hard_drive_interface = "sata"
  vm_name = "win10x64-enterprise"
  winrm_username = "automation"
  winrm_password = "insecure"
  winrm_timeout = "21600s"

  output_directory = "output"

  vrdp_bind_address = "0.0.0.0"
  vrdp_port_min = 5900
  vrdp_port_max = 5900
}

source "virtualbox-ovf" "vagrant" {
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c Packer_Shutdown"
  source_path = "output/win10x64-enterprise.ovf"
  winrm_username = "automation"
  winrm_password = "insecure"
  winrm_timeout = "10000s"
  vm_name = "virtualbox-ovf"
  headless = true
  communicator = "winrm"
  post_shutdown_delay = "2m"
  vrdp_bind_address = "0.0.0.0"
  vrdp_port_min = 5900
  vrdp_port_max = 5900

  host_port_min = 3333
  host_port_max = 3333
}

build {
  #name = "disk"
  sources = ["virtualbox-iso.disk"]
}

build {
  #name = "vagrant"

  sources = ["virtualbox-ovf.vagrant"]
  
  provisioner "ansible" {
    playbook_file = "./ansible/vagrant-playbook.windows.yml"
    inventory_file_template = "{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port=${ build.Port } ansible_password=${ build.Password } ansible_connection=winrm ansible_winrm_scheme=http \n"
    user = "automation"
    keep_inventory_file = true
    
    # extra_arguments = [
      # "-e", "ansible_user=automation",
      # "-e", "ansible_password=insecure",
      # "-e", "ansible_connection=winrm",
      # "-e", "ansible_winrm_scheme=http"
      # "-e", "ansible_winrm_server_cert_validation=ignore",
    # ]
  }

  post-processors {

    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "virtualbox"
    }  
  }
}

# packer build --only 'vagrantbox.*' --on-error=ask windows-10.pkr.hcl

variable "cpus" {
  type = number
  description = "Number of CPUs"
  default = 2
}

variable "memory" {
  type = number
  description = "RAM Size (in mb)"
  default = 8192
}