# 06 — Demo Risk

Toàn bộ rủi ro nhận diện được, dựa trên code + dữ liệu thật hiện tại (xem `01_DEMO_DATA.md`). Mỗi rủi ro có nguyên nhân, cách phòng tránh trước, và phương án xử lý ngay tại chỗ nếu vẫn xảy ra.

## Mục lục

1. [GPS / vị trí](#1-gps--vị-trí)
2. [Mạng / Internet](#2-mạng--internet)
3. [Firebase / Firestore Rules](#3-firebase--firestore-rules)
4. [Rotation / Business Date](#4-rotation--business-date)
5. [Tài khoản demo](#5-tài-khoản-demo)
6. [Trùng lặp thao tác Check In/Out](#6-trùng-lặp-thao-tác-check-inout)
7. [Hiệu năng & thiết bị](#7-hiệu-năng--thiết-bị)
8. [Dữ liệu trống](#8-dữ-liệu-trống)

---

## 1. GPS / vị trí

**Nguyên nhân:** `company_settings.radius` hiện đang đặt cực lớn (9999999999m — xem `01_DEMO_DATA.md` mục 7), nên rủi ro "đứng ngoài bán kính" gần như không còn — nhưng vẫn còn 2 rủi ro khác: (a) GPS bị tắt hoàn toàn trên thiết bị, (b) app phát hiện vị trí giả (`position.isMocked`) nếu demo bằng máy ảo/giả lập thay vì máy thật, hoặc nếu vô tình còn bật app giả lập vị trí từ trước.
**Cách phòng tránh:** Bật GPS trước khi demo, kiểm tra không có app mock-location nào đang chạy nền, ưu tiên demo trên **máy thật** (không phải emulator).
**Xử lý tại chỗ:** Nếu báo "vị trí giả", tắt hẳn app mock-location, khởi động lại app, thử lại. Nếu GPS không bắt được tín hiệu (trong nhà kín), di chuyển gần cửa sổ hoặc ra ngoài trong chốc lát.

## 2. Mạng / Internet

**Nguyên nhân:** Cả Check In/Out lẫn mọi màn admin đều gọi Firestore qua Internet — mất mạng là mất toàn bộ chức năng demo.
**Cách phòng tránh:** Chuẩn bị sẵn hotspot 4G làm phương án dự phòng, thử chuyển mạng 1 lần trước giờ báo cáo để chắc chắn hoạt động.
**Xử lý tại chỗ:** Nếu Wi-Fi nơi báo cáo không ổn định, chuyển ngay sang hotspot 4G đã chuẩn bị sẵn, không cố gắng debug mạng giữa buổi.

## 3. Firebase / Firestore Rules

**Nguyên nhân:** Nếu tài khoản admin dùng để demo bị thiếu `role: 'admin'` hoặc `isActive: false`, mọi thao tác admin sẽ bị từ chối quyền (`permission-denied`). Ngoài ra, cần xác nhận `firestore.rules` **đang deploy đúng bản gốc đã commit** — không phải bản `firestore.rules.import-mode` (bản tạm, nới quyền, được chuẩn bị cho công cụ import nhưng chưa từng dùng tới).
**Cách phòng tránh:** Trước demo, chạy `git status -- firestore.rules` (phải sạch, không có gì thay đổi) để xác nhận rules đang deploy đúng bản chính thức. Kiểm tra hồ sơ tài khoản admin demo có đúng `role`/`isActive`.
**Xử lý tại chỗ:** Nếu gặp `permission-denied` bất ngờ, kiểm tra nhanh Firestore Console xem tài khoản đang đăng nhập có đúng `role: 'admin'`, `isActive: true` không — sửa trực tiếp nếu cần, không cần khởi động lại app.

## 4. Rotation / Business Date

**Nguyên nhân:** Nếu vô tình sửa `rotationStartDate`/`rotationDays` trong lúc thử nghiệm trước đó mà quên đổi lại, ca hiển thị trên Home có thể không khớp với những gì đã trình bày trong slide/script.
**Cách phòng tránh:** Kiểm tra lại `company_settings` đúng giá trị đã ghi trong `01_DEMO_DATA.md` mục 7 (`rotationStartDate: 2026-06-01`, `rotationDays: 14`) trước khi demo.
**Xử lý tại chỗ:** Nếu ca hiển thị khác dự kiến, không cần hoảng — giải thích ngắn gọn theo đúng logic rotation thật đang áp dụng, không cần khớp chính xác với ví dụ đã nói trước.

## 5. Tài khoản demo

**Nguyên nhân:** Dùng nhầm tài khoản không có `shiftGroup` như dự kiến, hoặc dùng tài khoản admin có `departmentId` không hợp lệ (`dep001` — xem `01_DEMO_DATA.md` mục 2) gây hiển thị lỗi nhẹ khi mở hồ sơ.
**Cách phòng tránh:** Ghi rõ trước UID/employeeCode của từng tài khoản sẽ dùng (EMP001 nhóm A, EMP002/EMP003 nhóm B), sửa lại `departmentId` của admin trước demo.
**Xử lý tại chỗ:** Nếu lỡ đăng nhập nhầm tài khoản, đăng xuất và đăng nhập lại đúng tài khoản — không ảnh hưởng dữ liệu.

## 6. Trùng lặp thao tác Check In/Out

**Nguyên nhân:** Nếu đã test Check In thật cho cùng 1 tài khoản trong cùng "ngày làm việc" trước đó (kể cả lúc chuẩn bị), hệ thống sẽ từ chối với thông báo "Bạn đã Check In hôm nay rồi" khi demo thật. Tương tự, Check Out có khung ân hạn 2 giờ sau giờ tan ca — quá thời gian này sẽ bị từ chối.
**Cách phòng tránh:** Nếu đã test trước, dùng **tài khoản khác** cho buổi demo chính thức (hệ thống có ít nhất 4 tài khoản nhân viên), hoặc test vào ngày làm việc khác với ngày sẽ demo thật.
**Xử lý tại chỗ:** Nếu bị từ chối do đã Check In, chuyển ngay sang dùng tài khoản nhân viên khác để demo — không cần giải thích dài dòng, chỉ cần nói "em dùng tài khoản khác để demo tiếp".

## 7. Hiệu năng & thiết bị

**Nguyên nhân:** Dashboard admin tải 7 truy vấn tuần tự cho biểu đồ tuần, có thể mất vài giây; thiết bị hết pin giữa chừng.
**Cách phòng tránh:** Sạc đầy pin điện thoại + laptop trước giờ báo cáo; mở thử Dashboard 1 lần trước để dữ liệu được cache một phần (nếu có).
**Xử lý tại chỗ:** Nếu Dashboard tải chậm, tiếp tục nói trong lúc chờ ("hệ thống đang tổng hợp số liệu tuần") thay vì im lặng chờ — biến độ trễ thành khoảnh khắc giải thích thay vì khoảng lặng khó xử.

## 8. Dữ liệu trống

**Nguyên nhân:** Nếu quên seed 3 đơn nghỉ phép mẫu (mục 5, `01_DEMO_DATA.md`), màn "Duyệt Nghỉ Phép" sẽ trống hoàn toàn khi demo.
**Cách phòng tránh:** Thực hiện đúng checklist ở `05_DEMO_CHECKLIST.md` mục 1 trước 1 ngày, xác nhận lại mục 2 ngay trước giờ báo cáo.
**Xử lý tại chỗ:** Nếu phát hiện trống ngay trước giờ demo, có thể thêm nhanh 1 document qua Firestore Console (thao tác dưới 1 phút, xem schema ở `01_DEMO_DATA.md` mục 5) trước khi bắt đầu.
