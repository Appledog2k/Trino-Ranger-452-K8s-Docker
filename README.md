# Trino + Ranger 452 trên Kubernetes & Docker

## Tóm tắt
- Mục tiêu: Cung cấp môi trường Trino v452 tích hợp Apache Ranger để quản lý phân quyền tập trung, chạy bằng Docker Compose để phát triển nhanh và Kubernetes cho môi trường tương tự production.
- Thành phần: Trino (coordinator + workers), Apache Ranger Admin, cơ sở dữ liệu cho Ranger (PostgreSQL/MySQL), Hive Metastore (nếu dùng connector hive), kho dữ liệu (S3/MinIO/HDFS), và (tuỳ chọn) Ranger KMS.
- Phân quyền:
  - Tùy chọn A (khuyến nghị, OSS thuần): Ranger plugin cho Hive Metastore để kiểm soát truy cập ở lớp metadata khi dùng `connector=hive`.
  - Tùy chọn B (tuỳ repo): Plugin Ranger cho Trino (cộng đồng). Chỉ bật nếu dự án đã tích hợp plugin tương thích Trino 452.

## Kiến trúc
- Trino: 1 Coordinator + N Workers; kết nối Hive Metastore (nếu dùng) và các kho dữ liệu như S3/MinIO/HDFS.
- Ranger Admin: Quản lý policy (row/column/table), đồng bộ tới plugin.
- Ranger DB: Lưu cấu hình policy, users, audit.
- Hive Metastore (HMS): Lưu metadata bảng; có thể cài plugin Ranger để uỷ quyền.
- Lưu trữ: S3/MinIO hoặc HDFS cho dữ liệu bảng.

## Yêu cầu tiên quyết
- Windows + PowerShell 5.1.
- Docker Desktop (bật Kubernetes nếu chạy k8s cục bộ).
- kubectl và kind hoặc minikube (nếu chạy k8s local).
- Helm 3 (nếu dùng chart).
- Tài nguyên khuyến nghị: ≥4 CPU, ≥8 GB RAM cho bản demo đầy đủ.

## Cấu trúc thư mục (gợi ý)
```
Trino-Ranger-452-K8s-Docker/
  docker/            # Dockerfile, docker-compose.yaml, .env
  k8s/               # Manifests/Helm values cho trino, ranger, hms, db, minio
  catalogs/          # Cấu hình catalogs Trino (hive.properties, iceberg.properties, ...)
  policies/          # Mẫu policy Ranger (export)
  scripts/           # Script khởi tạo, seed database/policies
  docs/              # Hướng dẫn bổ sung
```

## Biến môi trường (ví dụ)
- `TRINO_VERSION=452`
- `RANGER_VERSION=2.x` (điền bản bạn dùng)
- `RANGER_DB=postgres` (hoặc `mysql`)
- `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`
- `HMS_URI=thrift://hms:9083`
- `S3_ENDPOINT=http://minio:9000` (hoặc endpoint S3 thật)

## Khởi động nhanh bằng Docker Compose
Tạo/kiểm tra `docker-compose.yaml` có đủ services: `ranger-admin`, `ranger-db` (Postgres/MySQL), `hive-metastore`, `minio`, `trino-coordinator`, `trino-worker`. Mount `catalogs/` vào `/etc/trino/catalog/`.

Chạy:
```powershell
cd c:\workspace\Trino-Ranger-452-K8s-Docker
docker compose pull
docker compose up -d
docker compose ps
```

Truy cập:
- Trino Web UI: http://localhost:8080 (mặc định)
- Ranger Admin: http://localhost:6080 (mặc định) – đăng nhập `admin / admin` rồi đổi mật khẩu
- MinIO Console: http://localhost:9001

Kiểm tra Trino CLI (tuỳ chọn):
```powershell
docker compose exec trino-coordinator trino --execute "SHOW CATALOGS"
```

## Triển khai trên Kubernetes (kind/minikube)
Tạo cụm:
```powershell
# Kind
kind create cluster --name trino-ranger

# Hoặc Minikube
minikube start --cpus=4 --memory=8192
```
Cài charts/manifests:
```powershell
# MinIO (Helm)
helm repo add minio https://charts.min.io/
helm repo update
helm upgrade --install minio minio/minio `
  --namespace data --create-namespace `
  --set accessKey.password=$env:MINIO_ACCESS_KEY `
  --set secretKey.password=$env:MINIO_SECRET_KEY

# Hive Metastore
kubectl apply -n data -f k8s/hms/

# Ranger Admin + DB
kubectl apply -n security -f k8s/ranger/

# Trino
helm repo add trino https://trinodb.github.io/charts/
helm repo update
helm upgrade --install trino trino/trino `
  -n compute --create-namespace `
  -f k8s/trino/values.yaml
```
Expose để truy cập:
```powershell
kubectl -n compute port-forward svc/trino 8080:8080
kubectl -n security port-forward svc/ranger-admin 6080:6080
```

## Cấu hình Trino
Ví dụ `catalogs/hive.properties`:
```
connector.name=hive
hive.metastore.uri=thrift://hms:9083
hive.s3.path-style-access=true
hive.s3.endpoint=http://minio:9000
hive.s3.aws-access-key=MINIO_ACCESS_KEY
hive.s3.aws-secret-key=MINIO_SECRET_KEY
```

## Tích hợp Ranger: hai phương án
### A) Uỷ quyền qua Hive Metastore (khuyến nghị OSS)
- Cài plugin Apache Ranger cho Hive Metastore (HMS), trỏ `POLICY_MGR_URL` tới Ranger Admin.
- Tạo service `hive` trong Ranger, tạo policies theo DB/bảng/cột.
- Trino truy cập qua HMS; policy áp dụng ở lớp metadata.

### B) Plugin Ranger cho Trino (tuỳ repo có tích hợp)
- Nếu repo này đã đóng gói plugin Ranger dành cho Trino (cộng đồng), bật theo hướng dẫn kèm plugin.
- Lưu ý: Trino upstream không phát hành plugin Ranger chính thức; kiểm tra tương thích với Trino 452.

## Khởi tạo dữ liệu & demo
Tạo bucket và dữ liệu mẫu trong MinIO (dùng mc hoặc console). Sau đó tạo schema/bảng Hive:
```powershell
docker compose exec trino-coordinator trino --execute "CREATE SCHEMA hive.default WITH (location = 's3a://datalake/default/')"
docker compose exec trino-coordinator trino --execute "CREATE TABLE hive.default.nyc (id int, name varchar)"
```
Tạo policy trong Ranger cho service `hive` để cấp/thu hồi SELECT/UPDATE theo user/role.

## Bảo mật
- TLS: Bật TLS cho Trino và Ranger nếu triển khai thật; tạo secret k8s chứa cert/key, mount vào pods, cấu hình `config.properties` và `ranger-admin-site.xml`.
- Tài khoản quản trị: Đổi mật khẩu admin Ranger ngay sau lần đăng nhập đầu.
- Credentials S3/MinIO: Không hard-code; dùng Secret/ConfigMap trên k8s hoặc `.env` với Docker.

## Kiểm thử nhanh
```powershell
# Hiển thị catalogs
docker compose exec trino-coordinator trino --execute "SHOW CATALOGS"

# Truy vấn bảng mẫu
docker compose exec trino-coordinator trino --execute "SELECT * FROM hive.default.nyc LIMIT 5"
```

## Khắc phục sự cố
- Trino không thấy bảng: kiểm tra `hive.metastore.uri`, trạng thái HMS, policy Ranger.
- Lỗi kết nối S3/MinIO: kiểm tra endpoint, access/secret key, `path-style-access`.
- Ranger policy không áp dụng: xác nhận plugin đã cài (HMS/Trino) và kết nối tới Ranger Admin.
- Thiếu tài nguyên: tăng CPU/RAM; giảm số worker Trino.

## Tuỳ biến & Mở rộng
- Thêm catalogs: Iceberg/Hudi/Delta bằng cách thêm file `.properties` dưới `catalogs/`.
- Audit: Bật audit trong Ranger.
- Prod-like: Dùng external DB (RDS/Aurora) cho Ranger/HMS; cấu hình object store thật (Amazon S3).
