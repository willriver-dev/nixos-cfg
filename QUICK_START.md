# 🚀 Quick Start Guide - NixOS VM Setup

## TÓM TẮT NHANH

Config này đã được migrate từ mitchellh sang **thangha**.

### ✅ Đã hoàn thành:
- ✅ Username: mitchellh → thangha
- ✅ Cachix: Đã restore (sẽ build nhanh hơn!)
- ✅ Flake configs: Đã cập nhật
- ✅ Makefile: Đã cập nhật

### ⚠️ CẦN LÀM TRƯỚC KHI SETUP:
1. Cập nhật Git info trong `users/thangha/home-manager.nix`
2. Cập nhật user info trong `users/thangha/jujutsu.toml`
3. (Tùy chọn) Thêm SSH keys vào `users/thangha/nixos.nix`

---

## 📦 SETUP VM - 5 BƯỚC

### 1️⃣ Download NixOS ISO
- Apple Silicon (M1/M2/M3): https://nixos.org/download → **aarch64**
- Intel Mac: https://nixos.org/download → **x86_64**

### 2️⃣ Tạo VM trong VMware Fusion
```
- OS: Linux → Other Linux 5.x 64-bit
- Firmware: UEFI ⚠️
- Disk: 150GB NVMe (khuyến nghị)
- CPU: 4-6 cores
- RAM: 8-16 GB
- Network: Shared with Mac
```

### 3️⃣ Boot VM và chuẩn bị
```bash
# Trong VM
sudo su
passwd
# Nhập: root (2 lần)

# Lấy IP
ip addr show
# Ghi lại IP, ví dụ: 192.168.57.128
```

### 4️⃣ Bootstrap từ Mac
```bash
# Mở Terminal trên Mac
cd /Users/river/workspace/nixos-cfg

# Set environment variables
# Nếu Apple Silicon:
export NIXNAME=vm-aarch64
# Nếu Intel:
export NIXNAME=vm-intel

export NIXADDR=192.168.57.128  # IP của VM
export NIXUSER=thangha

# Chạy bootstrap giai đoạn 1
make vm/bootstrap0
# ⏱️ 10-20 phút, VM sẽ reboot

# Sau khi VM reboot, chạy giai đoạn 2
make vm/bootstrap
# ⏱️ 30-60 phút (nhờ Cachix)
```

### 5️⃣ Login và đổi password
```bash
# Login vào VM
# Username: thangha
# Password: (hash cũ của mitchellh)

# ĐỔI PASSWORD NGAY!
passwd
```

---

## 📚 TÀI LIỆU CHI TIẾT

- **VMWARE_SETUP_GUIDE.md** - Hướng dẫn đầy đủ từng bước
- **MIGRATION_NOTES.md** - Chi tiết các thay đổi đã thực hiện
- **README.md** - Thông tin về config gốc

---

## 🆘 GẶP VẤN ĐỀ?

### Lỗi SSH
```bash
# Test SSH thủ công
ssh -o PubkeyAuthentication=no root@192.168.57.128
# Password: root
```

### Lỗi disk không phải /dev/nvme0n1
- Bạn đã chọn SATA disk
- Tạo lại VM với NVMe disk (khuyến nghị)
- Hoặc xem VMWARE_SETUP_GUIDE.md Phụ lục G để sửa Makefile cho SATA

### Build quá lâu
- Kiểm tra internet
- Đợi thêm - lần đầu có thể lâu
- Cachix đã được restore nên sẽ nhanh hơn nhiều

---

## 🎯 SAU KHI SETUP XONG

```bash
# Trong VM
cd ~/nixos-cfg

# Sửa config
nvim users/thangha/home-manager.nix

# Test
sudo make test

# Apply
sudo make switch
```

---

## 📊 NETWORK INFO (từ ifconfig của bạn)

VMware networks đang chạy:
- **bridge100**: `192.168.57.1/24` ← VM sẽ dùng network này
- **bridge101**: `172.16.46.1/24`
- Mac IP: `192.168.1.7`

VM sẽ nhận IP trong dải `192.168.57.x`

---

**Chúc bạn setup thành công! 🎉**

Nếu cần hỗ trợ, cung cấp log lỗi cụ thể.

