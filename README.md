# Flora Mart Manager 🌿

![Flora Mart Manager Banner](assets/flora-mart-manager-banner.png)

**Flora Mart Manager** là ứng dụng quản lý dành cho người bán và quản trị viên trong hệ thống **Flora Mart**, một nền tảng mua bán cây cảnh trực tuyến. Ứng dụng được phát triển bằng **Flutter**, cho phép quản lý sản phẩm, đơn hàng, và theo dõi thống kê doanh thu một cách hiệu quả. Dự án là một phần của đề tài “Xây dựng ứng dụng mua bán cây cảnh trực tuyến” do **Nguyễn Hà Quỳnh Giao** và **Hoàng Công Mạnh** thực hiện trong học kỳ II, năm học 2024-2025, thuộc môn Lập trình Di động Nâng cao, Trường Đại học Sư phạm Kỹ thuật TP.HCM.

## Mục lục
- [Giới thiệu](#giới-thiệu)
- [Tính năng](#tính-năng)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Hướng dẫn cài đặt](#hướng-dẫn-cài-đặt)
- [Cách sử dụng](#cách-sử-dụng)
- [Đóng góp](#đóng-góp)
- [Giấy phép](#giấy-phép)
- [Liên hệ](#liên-hệ)
- [Tài liệu tham khảo](#tài-liệu-tham-khảo)

## Giới thiệu
**Flora Mart Manager** được thiết kế để hỗ trợ người bán và quản trị viên trong việc quản lý hoạt động kinh doanh cây cảnh trên nền tảng Flora Mart. Ứng dụng cung cấp giao diện trực quan, dễ sử dụng, giúp tối ưu hóa quy trình quản lý sản phẩm, xử lý đơn hàng, và phân tích hiệu suất bán hàng. Ứng dụng tích hợp với backend **Spring Boot** để đảm bảo dữ liệu được đồng bộ và an toàn, góp phần vào mục tiêu thúc đẩy lối sống xanh và bền vững.

Dự án này là một phần của hệ thống Flora Mart, bao gồm:
- **Flora Mart Client** (React Native): Ứng dụng dành cho khách hàng.
- **Flora Mart Backend** (Spring Boot): Hệ thống API REST và cơ sở dữ liệu.

## Tính năng
- **Quản lý sản phẩm** (YC13): Thêm, sửa, xóa thông tin cây cảnh (tên, giá, mô tả, hướng dẫn chăm sóc).
- **Quản lý đơn hàng** (YC12): Xem, xác nhận, cập nhật trạng thái đơn hàng (mới, đang giao, hoàn thành).
- **Thống kê doanh thu** (YC14): Hiển thị biểu đồ và số liệu về doanh thu, số đơn hàng, sản phẩm bán chạy.
- **Đăng nhập an toàn** (YC01): Xác thực tài khoản người bán/quản trị viên với JWT.
- **Giao diện trực quan**: Thiết kế thân thiện, hỗ trợ đa ngôn ngữ (Tiếng Việt, Tiếng Anh).

## Công nghệ sử dụng
- **Frontend**: Flutter (Dart).
- **Backend tích hợp**: Spring Boot (qua API REST).
- **Cơ sở dữ liệu**: MySQL (truy cập thông qua backend).
- **Công cụ**:
  - Visual Studio Code, Android Studio, Xcode.
  - Git, GitHub.
- **Thư viện Flutter**:
  - `http`: Gọi API.
  - `provider`: Quản lý trạng thái.
  - `flutter_secure_storage`: Lưu trữ token an toàn.

## Yêu cầu hệ thống
- **Hệ điều hành phát triển**: Windows 11, macOS Ventura.
- **Thiết bị thử nghiệm**: iOS 14.0 trở lên, Android 9.0 trở lên.
- **Phần mềm cần thiết**:
  - Flutter SDK (3.x+), Dart.
  - Backend Spring Boot chạy trên `http://localhost:8080` (hoặc URL tùy chỉnh).
  - Android Studio (cho Android Emulator), Xcode (cho iOS Simulator).

## Hướng dẫn cài đặt
1. **Cài đặt môi trường Flutter**:
   - Tải Flutter SDK từ [flutter.dev](https://flutter.dev).
   - Thêm Flutter vào biến môi trường PATH:
     ```bash
     export PATH="$PATH:/path/to/flutter/bin"
     ```
   - Kiểm tra cài đặt:
     ```bash
     flutter doctor
     ```

2. **Tải dự án**:
   ```bash
   git clone https://github.com/ZaoQuynh/flora-mart-manager.git
   cd flora-mart-manager
   ```

3. **Cài đặt phụ thuộc**:
   - Chỉnh sửa `pubspec.yaml` để đảm bảo các thư viện:
     ```yaml
     dependencies:
       flutter:
         sdk: flutter
       http: ^0.13.5
       provider: ^6.0.5
       flutter_secure_storage: ^8.0.0
     ```
   - Cài phụ thuộc:
     ```bash
     flutter pub get
     ```

4. **Cấu hình kết nối backend**:
   - Cập nhật URL API trong `lib/constants/api.dart`:
     ```dart
     const String baseUrl = 'http://localhost:8080/api';
     ```
   - Đảm bảo backend Spring Boot đang chạy (xem [Flora Mart Backend](https://github.com/ZaoQuynh/flora-mart-backend)).

5. **Chạy ứng dụng**:
   ```bash
   flutter run
   ```

**Lưu ý**:
- Kết nối thiết bị thực hoặc emulator trước khi chạy.
- Đảm bảo backend đã khởi động để API hoạt động.

## Cách sử dụng
1. **Khởi động backend**:
   - Chạy backend Spring Boot tại `http://localhost:8080` (hoặc URL tùy chỉnh).

2. **Đăng nhập**:
   - Mở ứng dụng, đăng nhập bằng tài khoản người bán/quản trị (vai trò `SELLER` hoặc `MANAGER`).
   - Ví dụ tài khoản thử nghiệm: `seller@example.com` / `password123`.

3. **Quản lý**:
   - **Sản phẩm**: Thêm/sửa/xóa cây cảnh trong mục “Quản lý sản phẩm”.
   - **Đơn hàng**: Xem và cập nhật trạng thái đơn hàng trong mục “Quản lý đơn hàng”.
   - **Thống kê**: Xem biểu đồ doanh thu và số liệu trong mục “Thống kê”.

4. **Kiểm tra API**:
   - Sử dụng Postman để kiểm tra các endpoint như `/api/products`, `/api/orders`.

## Đóng góp
Chúng tôi hoan nghênh mọi đóng góp để cải thiện **Flora Mart Manager**! Để đóng góp:
1. Fork repository này.
2. Tạo nhánh mới:
   ```bash
   git checkout -b feature/ten-chuc-nang
   ```
3. Commit thay đổi:
   ```bash
   git commit -m "Mô tả thay đổi"
   ```
4. Push lên nhánh:
   ```bash
   git push origin feature/ten-chuc-nang
   ```
5. Tạo Pull Request trên GitHub.

Vui lòng đọc [CONTRIBUTING.md](docs/CONTRIBUTING.md) để biết thêm chi tiết.

## Giấy phép
Dự án được cấp phép theo [MIT License](LICENSE.md). Xem tệp `LICENSE.md` để biết thêm thông tin.

## Liên hệ
- **Nguyễn Hà Quỳnh Giao**: [GitHub](https://github.com/ZaoQuynh) | Email: nguyenhauquynhgiao9569@gmail.com
- **Hoàng Công Mạnh**: [GitHub](https://github.com/congmanhhoang) | Email: hoangmanh6889@gmail.com

## Tài liệu tham khảo
1. Tutorials Point. (n.d.). *Flutter introduction*. Tutorials Point. https://www.tutorialspoint.com/flutter/flutter_introduction.htm
2. Pivotal Software, Inc. (2023). *Getting started: Building a Spring Boot application*. Spring. https://spring.io/guides/gs/spring-boot
3. W3Schools. (n.d.). *MySQL introduction*. W3Schools. https://www.w3schools.com/mysql/mysql_intro.asp
