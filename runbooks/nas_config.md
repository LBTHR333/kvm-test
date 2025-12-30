# Runbook: TrueNAS NFS Shares for KVM Hosts

This document outlines the configuration steps to provide persistent storage for KVM virtual machines using TrueNAS via NFS.

---

## 1. ID Mapping: CentOS to TrueNAS (Mapall)

This method ensures seamless permission handling by translating the local CentOS KVM user ID to a designated ID on the TrueNAS system. This avoids permission denied errors when the hypervisor attempts to manage disk images.

### Prerequisites

* **CentOS Host:** Identify the `qemu` user UID (default is usually `107`).
* **TrueNAS:** Administrative access to the web UI.

### Step 1: Create User and Group on TrueNAS

1. Navigate to **Accounts > Groups**.
2. Click **Add** and create a group with GID `3107` (e.g., `kvm_storage`).
3. Navigate to **Accounts > Users**.
4. Click **Add** and create a user with UID `3107` (e.g., `kvm_user`).
5. Assign the user to the `kvm_storage` group.

### Step 2: Configure the NFS Share

1. Go to **Shares > Unix (NFS) Shares**.
2. Locate the share intended for KVM storage and click **Edit**.
3. Click **Advanced Options**.
4. Locate the following fields:
* **Mapall User:** Select the user created in Step 1 (`kvm_user`).
* **Mapall Group:** Select the group created in Step 1 (`kvm_storage`).


5. Click **Save**.

### Outcome

When the CentOS host (UID `107`) writes a file to the share, TrueNAS automatically maps that operation to UID `3107`. This translation happens transparently, allowing the KVM host to read and write VM disk images without manual `chown` operations on the storage backend.

---
