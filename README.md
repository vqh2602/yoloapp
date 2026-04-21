Các type chính:

detect: phát hiện vật thể. Kết quả là nhãn + độ tin cậy + bounding box.
segment: phân đoạn đối tượng. Ngoài box còn có mask vùng pixel của từng đối tượng.
classify: phân loại ảnh. Thường trả về lớp chính của ảnh thay vì nhiều box.
pose: phát hiện keypoints/tư thế. Hay dùng cho người, khớp tay chân, skeleton.
obb: oriented bounding box. Giống detect nhưng box có góc xoay, hợp với vật thể nghiêng/xoay.