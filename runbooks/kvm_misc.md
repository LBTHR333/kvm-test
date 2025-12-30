## Migration setup
Open FW ports
```
# Allow the standard libvirt migration port range
firewall-cmd --permanent --add-port=49152-49215/tcp

# Also ensure the libvirt service itself is allowed
firewall-cmd --permanent --add-service=libvirt

# Reload to apply changes
firewall-cmd --reload
```

This lets ya do the above as not root
```
usermod -aG libvirt ADMUSR
```

### Live Migration



Move a vm permanantly to another target host (both hosts have to have same shared storage config)
```
sudo virsh migrate --live --persistent --undefinesource gemcli01 qemu+ssh://ADMUSR@TARGETHOST/system tcp:TARGETHOST --verbose
```

