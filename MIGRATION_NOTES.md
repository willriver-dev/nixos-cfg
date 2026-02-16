# Ghi chú về việc chuyển đổi từ mitchellh sang thangha

## ✅ Các thay đổi đã thực hiện

### 1. Đổi tên thư mục user
- `users/mitchellh/` → `users/thangha/`

### 2. Cập nhật flake.nix
- Tất cả 6 system configurations đã được cập nhật: `user = "thangha"`
- Bao gồm: vm-aarch64, vm-aarch64-prl, vm-aarch64-utm, vm-intel, wsl, macbook-pro-m1

### 3. Cập nhật Makefile
- `NIXUSER ?= thangha`
- Đã comment/disable cachix push task
- Đã xóa cachix references trong bootstrap0

### 4. Cập nhật user configs
- `users/thangha/nixos.nix`: username, home path
- `users/thangha/darwin.nix`: username, home path, primaryUser
- `users/thangha/home-manager.nix`: Git config với placeholders
- `users/thangha/jujutsu.toml`: User info với placeholders

### 5. Cập nhật machine configs
- `machines/vm-shared.nix`: Đã comment cachix settings
- `machines/macbook-pro-m1.nix`: Đã comment cachix settings

## 📝 CẦN LÀM TIẾP

### 1. Cập nhật thông tin cá nhân trong `users/thangha/home-manager.nix`
```nix
user.name = "Tên của bạn";
user.email = "email@cua-ban.com";
github.user = "github-username-cua-ban";
```

### 2. Cập nhật thông tin trong `users/thangha/jujutsu.toml`
```toml
email = "email@cua-ban.com"
name = "Tên của bạn"
```

### 3. Cập nhật SSH key và password trong `users/thangha/nixos.nix`
Tạo password hash:
```bash
mkpasswd -m sha-512
```

Thêm SSH public key của bạn:
```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... your-key-here"
];
```

### 4. (Tùy chọn) Cấu hình GPG signing
Nếu bạn muốn sign commits với GPG:
- Uncomment phần `signing` trong `users/thangha/home-manager.nix`
- Thêm GPG key ID của bạn
- Uncomment phần `[signing]` trong `users/thangha/jujutsu.toml`

### 5. ✅ Cachix đã được restore
**Đã khôi phục lại Cachix của mitchellh** - đây là public binary cache, hoàn toàn an toàn và hợp pháp để sử dụng.

**Lợi ích:**
- Giảm thời gian build từ 30-60 phút xuống còn 5-10 phút
- Tiết kiệm bandwidth
- Không cần tạo cachix riêng trừ khi bạn có nhu cầu đặc biệt

**Nếu muốn tạo Cachix riêng (tùy chọn):**
1. Tạo tài khoản tại https://cachix.org
2. Tạo cache mới
3. Thêm cachix của bạn VÀO CÙNG với cachix của mitchellh trong:
   - `machines/vm-shared.nix`
   - `machines/macbook-pro-m1.nix`

## 🚀 Kiểm tra cấu hình

Chạy lệnh sau để kiểm tra cấu hình có hợp lệ không:
```bash
nix flake check
```

## 📦 Build WSL (nếu cần)

Từ máy Linux hoặc VM NixOS:
```bash
make wsl
```

Tarball sẽ được tạo tại `./result/tarball/nixos-wsl-installer.tar.gz`

Trên Windows:
```powershell
wsl --import nixos .\nixos .\nixos-wsl-installer.tar.gz
wsl -d nixos
```

## ⚠️ Lưu ý quan trọng

1. **Password mặc định**: Hiện tại vẫn đang dùng password hash cũ của mitchellh. Bạn NÊN đổi ngay!

2. **SSH Keys**: Đã comment SSH keys cũ. Thêm keys của bạn trước khi deploy.

3. **Cachix**: ✅ Đã RESTORE lại cachix của mitchellh - sẽ giúp build nhanh hơn rất nhiều!

4. **Git signing**: Đã disable GPG signing mặc định. Bật lại nếu bạn cần.

## 🔍 Các file đã thay đổi

- `flake.nix`
- `Makefile`
- `users/thangha/nixos.nix`
- `users/thangha/darwin.nix`
- `users/thangha/home-manager.nix`
- `users/thangha/jujutsu.toml`
- `machines/vm-shared.nix`
- `machines/macbook-pro-m1.nix`

Tất cả các file khác giữ nguyên.

