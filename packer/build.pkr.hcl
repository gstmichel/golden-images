build {
  name = "vm"

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

build {
  name = "provision"

  sources = ["source.virtualbox-ovf.ovf"]
  
  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
    # inventory_file_template = "{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_password=${ build.Password }\n"
    user = "root"
    ansible_ssh_extra_args = [
      "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa",
    ]
    extra_arguments = [
      "--scp-extra-args", 
      "'-O'" ,
      # "-vvvv",
    ]
  }
}
