# KVM Hypervisor Configuration for CentOS 10

This project contains a set of Ansible playbooks and shell scripts designed to fully configure a KVM hypervisor on a fresh CentOS 10 installation. The scripts automate the setup of virtualization, networking, and storage.

## Network Diagram

```mermaid
graph TD
    subgraph "Physical Hardware"
        direction LR
        subgraph "Storage NICs"
            PNIC1[enp1s0f0]
            PNIC2[enp1s0f1]
        end
        subgraph "VM Switch NICs"
            PNIC3[enp2s0f0]
            PNIC4[enp2s0f1]
        end
    end

    subgraph "LACP Bonds (Mode 802.3ad)"
        direction LR
        BOND_STOR("STOR-Bond0")
        BOND_VMSW("VMSW-Bond0 (Trunk)")
    end

    subgraph "Storage Bridge"
        BR_STOR("Bridge: STOR")
    end

    subgraph "VLAN Bridges (for VMs)"
        BR_VLAN10("Bridge: VLAN-10")
        BR_VLAN20("Bridge: VLAN-20")
        BR_VLAN_etc("...")
        BR_VLAN90("Bridge: VLAN-90")
    end

    subgraph "Tagged VLAN Interfaces"
        VLAN10_IF("vmsw.v10")
        VLAN20_IF("vmsw.v20")
        VLAN_etc_IF("...")
        VLAN90_IF("vmsw.v90")
    end

    %% --- Define Connections ---

    %% Physical NICs to Bonds
    PNIC1 --> BOND_STOR
    PNIC2 --> BOND_STOR
    PNIC3 --> BOND_VMSW
    PNIC4 --> BOND_VMSW

    %% Bond to Storage Bridge
    BOND_STOR --"Attached as port"--> BR_STOR

    %% VLAN trunking from VMSW Bond
    BOND_VMSW --"Creates tagged interface"--> VLAN10_IF
    BOND_VMSW --"Creates tagged interface"--> VLAN20_IF
    BOND_VMSW --"Creates tagged interface"--> VLAN_etc_IF
    BOND_VMSW --"Creates tagged interface"--> VLAN90_IF

    %% Tagged interfaces to their respective VM bridges
    VLAN10_IF --"Attached as port"--> BR_VLAN10
    VLAN20_IF --"Attached as port"--> BR_VLAN20
    VLAN_etc_IF --" "--> BR_VLAN_etc
    VLAN90_IF --"Attached as port"--> BR_VLAN90

    style BR_VLAN10 fill:#cde4ff,stroke:#6a9fdf
    style BR_VLAN20 fill:#cde4ff,stroke:#6a9fdf
    style BR_VLAN_etc fill:#cde4ff,stroke:#6a9fdf
    style BR_VLAN90 fill:#cde4ff,stroke:#6a9fdf
```

## Getting Started

To begin the configuration, execute the main build script as root:
```bash
sudo ./build.sh
```

## File Descriptions

- **`build.sh`**: The main entry point for the configuration. This script installs Ansible and its required collections, then executes the core Ansible playbooks (`add_virtualization.yml`, `add_network.yml`, `add_storage.yml`) in the correct order.

- **`add_virtualization.yml`**: An Ansible playbook that installs the KVM virtualization packages, Cockpit for web-based management, and other virtualization tools. It also ensures the `libvirtd` service is running.

- **`add_network.yml`**: An Ansible playbook responsible for configuring the host's networking. It creates network bridges and LACP bonds for virtual machine traffic and storage. It dynamically creates VLAN-based bridges based on the definitions in `vlans.csv`.

- **`vlans.csv`**: A data file containing a list of VLAN IDs and names that are used by `add_network.yml` to create the corresponding network bridges.

- **`add_storage.yml`**: An Ansible playbook that sets up a shared NFS storage pool for `libvirt`. This allows virtual machine disks to be stored on a network-attached storage device.

- **`add_vmtmplt.yml`**: An optional Ansible playbook (not run by `build.sh`) to create a Debian 13 VM template. It automates the creation of a base OS image that can be quickly cloned to new VMs.

- **`preseed.cfg`**: A Debian preseed configuration file used by `add_vmtmplt.yml` to automate the operating system installation for the VM template.
