#!/bin/bash
# gen_client.sh — Tạo WireGuard client profile (.conf)
# Tham khảo trực tiếp từ: AIVPN/mod_wireguard/add-peer
# Đơn giản hóa: chạy độc lập, không cần Redis hay mod_manager
#
# CÁCH DÙNG:
#   chmod +x gen_client.sh
#   ./gen_client.sh peer1
#   ./gen_client.sh peer2
#
# Output: ./data/wireguard/peer<N>/peer<N>.conf  (tự động tạo bởi linuxserver/wireguard)
# HOẶC dùng QR code trong log: docker logs aivpn_wireguard

set -e

PEER_NAME=${1:-"peer1"}
CONTAINER="aivpn_wireguard"
WG_DATA="./data/wireguard"

echo "[*] Tạo WireGuard client: $PEER_NAME"
echo ""

# Cách 1 (ĐƠN GIẢN NHẤT): linuxserver/wireguard tự tạo peer khi PEERS=N
# Chỉ cần tăng số PEERS trong docker-compose.yml rồi restart:
echo "=== Cách 1: Tự động (khuyên dùng) ==="
echo "  1. Mở docker/docker-compose.yml"
echo "  2. Tăng PEERS=2 (hoặc 3...)"
echo "  3. docker compose -f docker/docker-compose.yml up -d wireguard"
echo "  4. Config file tự tạo ở: ./data/wireguard/peer1/peer1.conf"
echo "  5. QR code xem bằng: docker logs aivpn_wireguard | grep -A 20 'PEER 1'"
echo ""

# Cách 2: Thêm peer thủ công (tham khảo AIVPN/mod_wireguard/add-peer)
echo "=== Cách 2: Thêm peer thủ công ==="
echo "  Bước 1 — Tạo keypair cho client:"
echo "    wg genkey | tee $WG_DATA/$PEER_NAME/${PEER_NAME}_private | wg pubkey > $WG_DATA/$PEER_NAME/${PEER_NAME}_public"
echo ""
echo "  Bước 2 — Thêm [Peer] vào wg0.conf:"
echo "    # $PEER_NAME"
echo "    [Peer]"
echo "    PublicKey = <nội dung file ${PEER_NAME}_public>"
echo "    AllowedIPs = 10.13.13.X/32"
echo ""
echo "  Bước 3 — Tạo file .conf cho client:"
echo "    cat > $WG_DATA/$PEER_NAME/${PEER_NAME}.conf << EOF"
echo "    [Interface]"
echo "    PrivateKey = <nội dung file ${PEER_NAME}_private>"
echo "    Address = 10.13.13.X/32"
echo "    DNS = 8.8.8.8"
echo "    "
echo "    [Peer]"
echo "    PublicKey = <server public key>"
echo "    Endpoint = <SERVER_IP>:51820"
echo "    AllowedIPs = 0.0.0.0/0"
echo "    PersistentKeepalive = 25"
echo "    EOF"
echo ""
echo "  Bước 4 — Reload WireGuard (không cần restart container):"
echo "    docker exec aivpn_wireguard wg syncconf wg0 <(docker exec aivpn_wireguard wg-quick strip wg0)"
echo ""
echo "[*] Vị trí file config sau khi tạo:"
echo "    ./data/wireguard/peer1/peer1.conf  ← copy sang máy client"
echo ""
echo "[*] Xem tất cả peer đang kết nối:"
echo "    docker exec aivpn_wireguard wg show"