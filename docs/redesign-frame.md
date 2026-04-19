
Đây là kế hoạch chi tiết để đưa các màn hình chi tiết (Vocabulary, Grammar, Conversation, Character) về cùng một cấu trúc khung (Frame) thống nhất, giúp ứng dụng chuyên nghiệp và dễ bảo trì hơn.

### 1. Kiến trúc: "Hanzify Detail Frame"
Chúng ta sẽ tạo một Widget trung tâm đóng vai trò là "bộ khung" chuẩn. Widget này sẽ xử lý các thành phần lặp đi lặp lại như:
*   **HanzifyAppBar**: Nút quay lại, tiêu đề chuẩn, và các nút chức năng bên phải (như Bookmark).
*   **Watermark Background**: Một chữ Hán lớn mờ ở nền (như đang có ở Vocab Detail) để tạo nhận diện thương hiệu.
*   **Hero Section**: Khu vực nổi bật phía trên cùng (Chữ Hán lớn, Cấu trúc ngữ pháp, hoặc Icon hội thoại).
*   **Main Content**: Danh sách các Section nội dung được phân tách bằng khoảng cách chuẩn.

### 2. Các bước thực hiện chi tiết

#### Bước 1: Tạo Widget `HanzifyDetailFrame`
Tôi sẽ tạo tệp `lib/core/widgets/hanzify_detail_frame.dart`. Widget này sẽ nhận các tham số:
*   `title`: Tiêu đề màn hình.
*   `appBarTrailing`: Widget chức năng bên phải (tùy chọn).
*   `heroContent`: Nội dung chính của phần Hero (phần gradient phía trên).
*   `slivers`: Danh sách các phần nội dung bên dưới (dùng Slivers để tối ưu hiệu năng cuộn).
*   `watermark`: Chữ Hán hiển thị mờ ở nền (tùy chọn).

#### Bước 2: Thống nhất các Component con
Đảm bảo tất cả các màn hình sử dụng chung bộ UI Kit:
*   **Section Header**: Luôn dùng `HanzifySectionHeader` với icon và tiêu đề phụ.
*   **Content Cards**: Tất cả nội dung nằm trong `HanzifyCard.glass()` để tạo hiệu ứng xuyên thấu đồng bộ.
*   **Spacing**: Sử dụng các hằng số `AppSpacing.xl` (32dp) cho lề trái/phải và `AppSpacing.lg` cho khoảng cách giữa các khối.

#### Bước 3: Tái cấu trúc (Refactor) các màn hình hiện có

1.  **VocabDetailScreen**:
    *   Chuyển phần Chữ Hán & Pinyin vào `heroContent`.
    *   Giữ lại hiệu ứng Watermark đặc trưng.
    *   Sắp xếp lại các Section: Viết chữ, Nghĩa, Ví dụ.

2.  **GrammarDetailScreen**:
    *   Thay thế phần thẻ Gradient hiện tại bằng `heroContent` của Frame.
    *   Đưa các phần: Công thức, Cách dùng, Ví dụ về các Section chuẩn.
    *   Bỏ các cấu trúc Scaffold thủ công để dùng Frame.

3.  **ConversationDetailScreen**:
    *   Đưa phần thông tin tổng quan hội thoại (Icon, HSK, Tiêu đề) vào `heroContent`.
    *   Thống nhất phần "Hội thoại", "Từ vựng" và "Ngữ pháp liên quan" theo định dạng Section mới.

4.  **CharacterDetailScreen**:
    *   Đồng bộ hóa Header (hiện tại đang dùng một Header riêng khác biệt).
    *   Đưa phần Animation nét chữ và thông tin chi tiết vào Frame chung.

### 3. Kết quả mong đợi
*   **Tính nhất quán (Consistency)**: Người dùng cảm thấy quen thuộc dù đang học từ vựng hay ngữ pháp.
*   **Hiệu ứng cao cấp**: Tất cả đều có hiệu ứng mờ (Glassmorphism) và chuyển động cuộn mượt mà giống nhau.
*   **Dễ phát triển**: Khi muốn thay đổi giao diện chung (ví dụ đổi màu nền), chỉ cần sửa tại 1 nơi là `HanzifyDetailFrame`.
