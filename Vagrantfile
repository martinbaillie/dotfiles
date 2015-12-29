# vim: set ft=ruby:fen:fmr={,}:fdl=0:fdm=marker:ff=unix

VM_IP='192.168.4.40'

PROXYCONF_PROXY = ENV['http_proxy'].nil? ? 'http://d99192910:31337' : ENV['http_proxy']

ANSIBLE_VERBOSE = ENV['ANSIBLE_VERBOSE'].nil? ? 'vvvv' : ENV['ANSIBLE_VERBOSE']
ANSIBLE_TAGS    = ENV['ANSIBLE_TAGS']

Vagrant.configure(2) do |config|
  config.vm.box = "terrywang/archlinux"
  config.vm.box_check_update = false
  config.vm.hostname = "archie"
  config.vm.network :private_network, ip: VM_IP

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = 2048
    vb.cpus = 4
    vb.name = "archie"
    vb.customize ["modifyvm", :id, "--vram", "64"]
  end

  config.vm.provision "ansible" do |ansible|
    #ansible.extra_vars = {
      #LLDB: LLDB,
      #PERF: PERF,
      #DEVEL: DEVEL,
      #DOTFILES: DOTFILES,
      #VIM: VIM
    #}
    ansible.playbook = "provisioning/ansible/site.yml"
    ansible.inventory_path = "provisioning/ansible/hosts"
    ansible.sudo = true
    ansible.verbose = ANSIBLE_VERBOSE
    ansible.limit = 'all'
    unless ANSIBLE_TAGS.nil?
      ansible.tags = ANSIBLE_TAGS
    end
  end

  if Vagrant.has_plugin?("vagrant-proxyconf")
    # TODO: change to use env variables
    # This is a CNTLM proxy on the host
    config.proxy.http     = PROXY
    config.proxy.https    = PROXY
    config.proxy.no_proxy = "localhost,127.0.0.1"
  end
end
