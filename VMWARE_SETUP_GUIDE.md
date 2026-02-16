# Hướng dẫn Setup NixOS trên VMware Fusion

## 📋 PHẦN 1: CHUẨN BỊ

### 1.1 Download NixOS ISO
Tải NixOS ISO từ: https://nixos.org/download.html#nixos-iso

**Chọn phiên bản:**
- Nếu dùng Mac Apple Silicon (M1/M2/M3): **NixOS 25.05 aarch64**
- Nếu dùng Mac Intel: **NixOS 25.05 x86_64**

### 1.2 Kiểm tra VMware Fusion
Bạn đã có VMware Fusion (tôi thấy vmenet interfaces trong ifconfig).

**Network hiện tại của bạn:**
- `bridge100` (vmenet0): `192.168.57.1/24` - Shared networking
- `bridge101` (vmenet1/2): `172.16.46.1/24` - Private networking
- `bridge102` (vmenet3): Bridged với en0

---

## 🖥️ PHẦN 2: TẠO VM TRONG VMWARE FUSION

### 2.1 Cấu hình VM

**Tạo VM mới:**
1. Mở VMware Fusion
2. File → New → Create Custom Virtual Machine
3. Chọn:
   - **Operating System**: Linux → Other Linux 5.x kernel 64-bit
   - **Firmware**: UEFI (quan trọng!)

**Cấu hình phần cứng:**

| Thành phần | Cấu hình khuyến nghị | Tối thiểu |
|------------|---------------------|-----------|
| **CPU** | 4-6 cores | 2 cores |
| **RAM** | 8-16 GB | 4 GB |
| **Disk** | 150 GB NVMe | 80 GB |
| **Graphics** | Full acceleration, max RAM | Default |
| **Network** | Shared with Mac | Shared |

**⚠️ QUAN TRỌNG - Disk Type:**
- Chọn **NVMe** (khuyến nghị - nhanh hơn)
- Makefile đã được cấu hình để dùng `/dev/nvme0n1`
- Nếu muốn dùng SATA thay vì NVMe, xem Phụ lục G bên dưới

**Xóa các thiết bị không cần:**
- ❌ Sound card
- ❌ Camera
- ❌ Printer
- ✅ Giữ: CD/DVD (để boot ISO)

### 2.2 Cấu hình Network
- **Network Adapter**: Shared with my Mac
- VM sẽ nhận IP trong dải `192.168.57.x` hoặc `172.16.x.x`

### 2.3 Disable VMware Keybindings
Settings → Keyboard & Mouse → Disable hầu hết keybindings để tránh conflict

---

## 🚀 PHẦN 3: BOOT VÀ CHUẨN BỊ

### 3.1 Mount ISO và Boot
1. VM Settings → CD/DVD → Choose NixOS ISO file
2. Start VM
3. Boot vào NixOS Live environment

### 3.2 Trong VM - Chuẩn bị cho Bootstrap

**Đổi password root thành "root":**
```bash
sudo su
passwd
# Nhập: root
# Nhập lại: root
```

**Kiểm tra disk device:**
```bash
ls -la /dev/nvme*
# Phải thấy: /dev/nvme0n1, /dev/nvme0n1p1, /dev/nvme0n1p2, etc.
```

**⚠️ Nếu thấy `/dev/sda` thay vì `/dev/nvme0n1`:**
- Bạn đã chọn SATA disk
- Cần sửa Makefile hoặc tạo lại VM với NVMe (xem Phụ lục G)

**Lấy IP address của VM:**
```bash
ip addr show
# Hoặc
ifconfig
```

Tìm interface có IP (thường là `ens160` hoặc `ens33`):
- Ví dụ: `192.168.57.128`
- **GHI LẠI IP NÀY!**

### 3.3 Tạo Snapshot (khuyến nghị)
Trong VMware Fusion:
- Virtual Machine → Snapshots → Take Snapshot
- Đặt tên: "prebootstrap0"
- Nếu có lỗi, có thể restore lại snapshot này

---

## 💻 PHẦN 4: BOOTSTRAP TỪ MAC HOST

### 4.1 Mở Terminal trên Mac

**Di chuyển vào thư mục config:**
```bash
cd /Users/river/workspace/nixos-cfg
```

### 4.2 Set Environment Variables

**Xác định kiến trúc CPU:**
```bash
# Kiểm tra Mac của bạn
uname -m
```

**Nếu Apple Silicon (arm64):**
```bash
export NIXNAME=vm-aarch64
export NIXADDR=192.168.57.128  # Thay bằng IP VM của bạn
export NIXPORT=22
export NIXUSER=thangha
```

**Nếu Intel (x86_64):**
```bash
export NIXNAME=vm-intel
export NIXADDR=192.168.57.128  # Thay bằng IP VM của bạn
export NIXPORT=22
export NIXUSER=thangha
```

**Kiểm tra:**
```bash
echo "NIXNAME: $NIXNAME"
echo "NIXADDR: $NIXADDR"
echo "NIXUSER: $NIXUSER"
```

### 4.3 Chạy Bootstrap Giai đoạn 0

**Lệnh:**
```bash
make vm/bootstrap0
```

**Quá trình này sẽ:**
1. SSH vào VM (password: root)
2. Phân vùng disk `/dev/sda`
3. Format các partitions
4. Mount filesystems
5. Generate NixOS config
6. Cài đặt NixOS cơ bản
7. Reboot VM

**⏱️ Thời gian:** 10-20 phút

**Nếu gặp lỗi SSH:**
```bash
# Thử SSH thủ công để test
ssh -o PubkeyAuthentication=no -o StrictHostKeyChecking=no root@$NIXADDR
# Password: root
```

### 4.4 Sau khi VM Reboot

**Trong VM, đổi password root:**
```bash
sudo su
passwd
# Đặt password mới (hoặc giữ "root")
```

### 4.5 Chạy Bootstrap Giai đoạn Cuối

**Từ Mac terminal:**
```bash
make vm/bootstrap
```

**Quá trình này sẽ:**
1. Copy toàn bộ config vào VM
2. Chạy `nixos-rebuild switch` với config đầy đủ
3. Copy SSH keys và GPG keys (nếu có)
4. Reboot VM

**⏱️ Thời gian:** 30-60 phút (lần đầu, nhờ có Cachix)

---

## ✅ PHẦN 5: SAU KHI BOOTSTRAP XONG

### 5.1 Login vào VM

**Username:** `thangha`
**Password:** (password hash cũ của mitchellh - cần đổi!)

### 5.2 Đổi Password ngay

```bash
passwd
# Nhập password mới
```

### 5.3 Clone repo trong VM

```bash
cd ~
git clone https://github.com/your-username/nixos-cfg.git
cd nixos-cfg
```

### 5.4 Từ giờ làm việc trong VM

**Để thay đổi config:**
```bash
# Sửa file config
nvim users/thangha/home-manager.nix

# Test config
sudo make test

# Apply config
sudo make switch
```

---

## 🔧 PHẦN 6: TROUBLESHOOTING

### Lỗi: "Connection refused" khi SSH
```bash
# Trong VM, kiểm tra SSH service
sudo systemctl status sshd

# Start SSH nếu chưa chạy
sudo systemctl start sshd
```

### Lỗi: "No route to host"
- Kiểm tra VM network adapter đang ở chế độ "Shared"
- Restart VM networking

### Lỗi: Disk không phải /dev/sda
- Xem phần "NVMe Disk Setup" bên dưới

---

## 📝 GHI CHÚ QUAN TRỌNG

1. **Password hiện tại**: Vẫn dùng hash cũ của mitchellh, ĐỔI NGAY!
2. **SSH Keys**: Đã comment, thêm keys của bạn vào `users/thangha/nixos.nix`
3. **Git config**: Cập nhật tên/email trong `users/thangha/home-manager.nix`
4. **Cachix**: Đã restore, sẽ tăng tốc build đáng kể

---

## 💾 PHỤ LỤC A: THÔNG TIN VỀ DISK TYPES

### NVMe vs SATA

**NVMe (Mặc định - Khuyến nghị):**
- ✅ Nhanh hơn SATA
- ✅ Makefile đã được cấu hình sẵn
- Device: `/dev/nvme0n1`
- Partitions: `/dev/nvme0n1p1`, `/dev/nvme0n1p2`, `/dev/nvme0n1p3`

**SATA (Cũ hơn):**
- Chậm hơn NVMe
- Device: `/dev/sda`
- Partitions: `/dev/sda1`, `/dev/sda2`, `/dev/sda3`

**Lưu ý về naming convention:**
- SATA: Partition number được gắn trực tiếp (`sda1`, `sda2`)
- NVMe: Có chữ `p` (partition) ở giữa (`nvme0n1p1`, `nvme0n1p2`)

---

## 📊 PHỤ LỤC B: NETWORK INFORMATION

**Từ ifconfig của bạn, tôi thấy:**

### VMware Networks hiện có:
1. **bridge100** (`192.168.57.1/24`) - Shared networking
   - VM sẽ nhận IP: `192.168.57.x`
   - Có thể truy cập internet
   - Mac có thể SSH vào VM

2. **bridge101** (`172.16.46.1/24`) - Private networking
   - VM sẽ nhận IP: `172.16.46.x`
   - Chỉ Mac và VM giao tiếp với nhau

3. **bridge102** - Bridged với en0
   - VM sẽ nhận IP từ router (cùng dải với Mac)
   - Mac IP: `192.168.1.7`

**Khuyến nghị:** Dùng Shared networking (bridge100) - đơn giản nhất

---

## 🎯 PHỤ LỤC C: CHECKLIST TRƯỚC KHI BẮT ĐẦU

- [ ] Đã download NixOS ISO (đúng kiến trúc: aarch64 hoặc x86_64)
- [ ] Đã tạo VM với cấu hình đúng (UEFI, SATA disk, Shared network)
- [ ] Đã boot VM từ ISO
- [ ] Đã đổi password root thành "root" trong VM
- [ ] Đã lấy IP address của VM
- [ ] Đã set environment variables trên Mac (NIXADDR, NIXNAME, NIXUSER)
- [ ] Đã test SSH từ Mac vào VM: `ssh root@$NIXADDR`
- [ ] Đã tạo snapshot "prebootstrap0"
- [ ] Đã cập nhật thông tin cá nhân trong config files:
  - [ ] `users/thangha/home-manager.nix` (Git name, email, GitHub username)
  - [ ] `users/thangha/jujutsu.toml` (name, email)
  - [ ] `users/thangha/nixos.nix` (SSH keys - nếu có)

---

## 🚨 PHỤ LỤC D: CÁC LỖI THƯỜNG GẶP

### Lỗi 1: "Permission denied (publickey)"
**Nguyên nhân:** SSH đang dùng key authentication
**Giải pháp:** Makefile đã có `-o PubkeyAuthentication=no`, nên không gặp lỗi này

### Lỗi 2: "Device /dev/sda not found"
**Nguyên nhân:** VM dùng NVMe disk
**Giải pháp:** Xem Phụ lục A hoặc tạo lại VM với SATA disk

### Lỗi 3: Build quá lâu (>2 giờ)
**Nguyên nhân:** Cachix không hoạt động hoặc internet chậm
**Giải pháp:**
- Kiểm tra internet connection
- Kiểm tra Cachix settings đã được restore chưa
- Chờ đợi - lần đầu có thể lâu

### Lỗi 4: "No space left on device"
**Nguyên nhân:** Disk quá nhỏ
**Giải pháp:** Tạo lại VM với disk ≥ 100GB

### Lỗi 5: VM không nhận IP
**Nguyên nhân:** Network adapter chưa đúng
**Giải pháp:**
```bash
# Trong VM
sudo systemctl restart NetworkManager
# Hoặc
sudo dhclient
```

---

## 📞 PHỤ LỤC E: LIÊN HỆ VÀ TÀI LIỆU

### Tài liệu tham khảo:
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Home Manager: https://nix-community.github.io/home-manager/
- Cachix: https://docs.cachix.org/

### Nếu cần hỗ trợ:
- NixOS Discourse: https://discourse.nixos.org/
- NixOS Reddit: https://reddit.com/r/NixOS
- Original repo: https://github.com/mitchellh/nixos-config

---

## ✨ PHỤ LỤC F: SAU KHI SETUP XONG

### Các bước tiếp theo:
1. **Customize config** theo nhu cầu của bạn
2. **Cài đặt thêm packages** trong `home-manager.nix`
3. **Setup development environment** (Go, Rust, Node.js, etc.)
4. **Configure editor** (Neovim đã có sẵn trong config)
5. **Setup Git credentials** và GPG signing (nếu cần)
6. **Tạo backup** của secrets: `make secrets/backup`

### Workflow hàng ngày:
```bash
# Trong VM
cd ~/nixos-cfg

# Sửa config
nvim users/thangha/home-manager.nix

# Test (không apply)
sudo make test

# Apply changes
sudo make switch

# Nếu có lỗi, rollback
sudo nixos-rebuild switch --rollback
```

### Tips:
- **Snapshot VM thường xuyên** trước khi thay đổi lớn
- **Commit config changes** vào Git
- **Backup secrets** định kỳ
- **Update nixpkgs** thỉnh thoảng: sửa `flake.nix` và `nix flake update`

---

---

## 💿 PHỤ LỤC G: SETUP VỚI SATA DISK (Thay vì NVMe)

Nếu bạn muốn dùng SATA disk thay vì NVMe (mặc định):

### G.1 Tạo VM với SATA Disk
- Trong VMware Fusion, chọn disk type: **SATA** (không phải NVMe)
- VM sẽ có device `/dev/sda` thay vì `/dev/nvme0n1`

### G.2 Sửa Makefile

**Cần thay đổi trong task `vm/bootstrap0` (dòng 76-103):**

```makefile
# Thay TẤT CẢ /dev/nvme0n1 → /dev/sda
# Thay TẤT CẢ /dev/nvme0n1p1 → /dev/sda1
# Thay TẤT CẢ /dev/nvme0n1p2 → /dev/sda2
# Thay TẤT CẢ /dev/nvme0n1p3 → /dev/sda3
```

**Chi tiết các dòng cần sửa:**
```makefile
vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/sda -- mklabel gpt; \
		parted /dev/sda -- mkpart primary 512MB -8GB; \
		parted /dev/sda -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/sda -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/sda -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/sda1; \
		mkswap -L swap /dev/sda2; \
		mkfs.fat -F 32 -n boot /dev/sda3; \
		...
```

**Lưu ý:** SATA không dùng chữ `p` giữa device name và partition number.

---

**Chúc bạn setup thành công! 🎉**

Nếu gặp vấn đề gì, hãy cho tôi biết log lỗi cụ thể.


