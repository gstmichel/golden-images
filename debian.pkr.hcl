source "virtualbox-iso" "vm" {
  vboxmanage = [
    # ["modifyvm", "{{.Name}}", "--memory", "8192"],
    # ["modifyvm", "{{.Name}}", "--cpus", "2"],
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
  ]

  iso_url = "download/debian-11.7.0-amd64-netinst.iso"
  iso_checksum = "md5:b33775a9ab6eae784b6da9f31be48be3"

  #iso_url = "download/debian-10.6.0-amd64-netinst.iso"
  #iso_checksum = "md5:42c43392d108ed8957083843392c794b"

  cpus = 2
  memory = 8192

  http_directory = "http"
  guest_os_type = "Debian_64"
  disk_size = "204800"
  gfx_controller = "vmsvga"

  headless = true
  vrdp_port_min = 5900
  vrdp_port_max = 5900
  rtc_time_base = "UTC"

  shutdown_command = "shutdown -h now"
  
  boot_command = [
        "<esc><wait>",
        "install",
        " auto",
        " url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed}",
        " debian-installer/locale=en_CA.UTF-8",
        " keyboard-configuration/xkb-keymap=us",
        " netcfg/get_hostname=unassigned",
        " netcfg/get_domain=unassigned",
        "<enter>",
      ]

  ssh_username = "root"
  ssh_password = "insecure"
  ssh_timeout = "30m"

  virtualbox_version_file = ""
  guest_additions_mode = "disable"
  # guest_additions_interface = "disable"
  vm_name = "debian-step1"
}

# source "virtualbox-ovf" "ovf" {
#   shutdown_command = "shutdown -h now"
#   source_path = "output-vm/debian-step1.ovf"
#   ssh_username = "root"
#   ssh_password = "insecure"
#   ssh_port = 22
#   vm_name = "virtualbox-ovf"

#   headless = true

#   vrdp_port_min = 5900
#   vrdp_port_max = 5900
# }

build {
  sources = ["source.virtualbox-iso.vm"]

  # post-processor "manifest" {
  #   output = "stage-1-manifest.json"
  # }

  provisioner "ansible" {
    playbook_file = "../ansible/5min-playbook.yml"
    # inventory_file_template = "{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_password=${ build.Password }\n"
    user = "root"
    ansible_ssh_extra_args = [
      "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa",
    ]
    extra_arguments = [
      "--scp-extra-args", 
      "'-O'" ,
    ]
  }
}

# build {
#   name = "provision"

#   sources = ["source.virtualbox-ovf.ovf"]
  
#   provisioner "ansible" {
#     playbook_file = "../ansible/playbook.yml"
#     # inventory_file_template = "{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_password=${ build.Password }\n"
#     user = "root"
#     ansible_ssh_extra_args = [
#       "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa",
#     ]
#     extra_arguments = [
#       "--scp-extra-args", 
#       "'-O'" ,
#       # "-vvvv",
#     ]
#   }
# }

variable "preseed" {
    type = string
    default = "preseed-noswap.cfg"
}