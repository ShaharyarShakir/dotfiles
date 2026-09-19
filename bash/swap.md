
# blendOS — Swap Configuration

## Overview

Configured a **12 GiB swap file** on the blendOS host.

### System Memory

At the time of configuration:

```text
RAM: 7.3 GiB
Swap: 0 B
```

A 12 GiB disk-backed swap file was added to provide additional memory capacity when RAM becomes constrained.

---

## Configuration Implemented

### 1. Created a 12 GiB swap file

```bash
sudo fallocate -l 12G /swapfile
```

The resulting file was approximately:

```text
13G /swapfile
```

The difference is due to the display using decimal GB rather than GiB.

---

### 2. Secured the swap file

```bash
sudo chmod 600 /swapfile
```

This prevents regular users from reading or modifying the swap file.

Expected permissions:

```text
-rw------- root root /swapfile
```

---

### 3. Formatted the file as swap

```bash
sudo mkswap /swapfile
```

Swap UUID created:

```text
25522e1c-bcb3-4a19-af51-e35ee49b2d7f
```

---

### 4. Enabled the swap

```bash
sudo swapon /swapfile
```

---

### 5. Verified active swap

```bash
swapon --show
```

Current configuration:

```text
NAME      TYPE SIZE USED PRIO
/swapfile file  12G   0B   -1
```

---

### 6. Verified memory

```bash
free -h
```

Result after enabling swap:

```text
               total        used        free      shared  buff/cache   available
Mem:           7.3Gi       7.0Gi       160Mi       702Mi       1.1Gi       295Mi
Swap:           11Gi          0B        11Gi
```

The displayed `11Gi` is normal even though the swap file was created using `12G`. This is due to the difference between decimal GB and binary GiB units.

---

## Persistent Configuration

Added the following entry to:

```text
/etc/fstab
```

Entry:

```text
/swapfile none swap defaults 0 0
```

Command used:

```bash
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
```

Verified with:

```bash
grep '/swapfile' /etc/fstab
```

Output:

```text
/swapfile none swap defaults 0 0
```

The swap should therefore automatically activate after reboot.

---

# Final Configuration

| Setting        | Value       |
| -------------- | ----------- |
| Physical RAM   | ~8 GiB      |
| Swap type      | Swap file   |
| Swap file      | `/swapfile` |
| Allocated swap | 12 GB       |
| Displayed swap | ~11 GiB     |
| Swap priority  | `-1`        |
| Persistent     | Yes         |
| `/etc/fstab`   | Configured  |

---

# Useful Commands

## Check active swap

```bash
swapon --show
```

## Check RAM and swap

```bash
free -h
```

## Check swap file

```bash
ls -lh /swapfile
```

## Check permissions

```bash
ls -l /swapfile
```

## Check persistent configuration

```bash
grep '/swapfile' /etc/fstab
```

## Check all block devices

```bash
lsblk -f
```

---

# Disable Swap Temporarily

If needed:

```bash
sudo swapoff /swapfile
```

Verify:

```bash
swapon --show
```

---

# Re-enable Swap

```bash
sudo swapon /swapfile
```

---

# Remove Swap Configuration

**Do not do this unless the swap file is no longer needed.**

First disable it:

```bash
sudo swapoff /swapfile
```

Remove the `/etc/fstab` entry:

```bash
sudo sed -i '\|^/swapfile none swap|d' /etc/fstab
```

Then delete the file:

```bash
sudo rm /swapfile
```

Verify:

```bash
swapon --show
```

---

# Important Notes

* Swap was configured on the **blendOS host**, not inside a blendOS container.
* The swap file must remain owned by `root` and have restrictive permissions (`600`).
* Do not run `mkswap` on the file again unless intentionally recreating the swap.
* Do not recreate the swap file with `fallocate` unless intentionally replacing the existing configuration.
* `/etc/fstab` makes the swap persistent across reboots.
* Swap is slower than physical RAM and should be treated as additional memory capacity, not a replacement for RAM.

---

# Future Optimization

The current setup uses **disk-backed swap only**.

Potential future improvements:

### 1. Check memory consumers

```bash
ps aux --sort=-%mem | head -15
```

### 2. Check current swappiness

```bash
cat /proc/sys/vm/swappiness
```

### 3. Investigate zram

For a system with ~8 GiB RAM, a future configuration could use:

```text
RAM
 │
 ├── Applications
 │
 ├── Containers
 │
 └── Kernel
       │
       ▼
     zram
       │
       ▼
  /swapfile (12 GiB)
```

Before changing swappiness or adding zram, measure the system's actual memory behavior.

---

# Current Status

**Status: COMPLETE**

The blendOS system now has:

* ~8 GiB physical RAM
* 12 GB swap file
* Swap enabled
* Swap configured for automatic activation
* `/etc/fstab` updated
* Swap permissions secured

Last verified state:

```text
/swapfile file  12G   0B   -1
```
