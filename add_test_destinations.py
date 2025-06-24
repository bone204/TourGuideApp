import firebase_admin
from firebase_admin import credentials, firestore
import uuid

# Khởi tạo Firebase Admin SDK
cred = credentials.Certificate("path/to/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

# Thêm một số destination có tên chứa "vườn quốc gia" để test
test_destinations = [
    {
        "destinationId": "D00521",
        "destinationName": "Vườn Quốc Gia Cúc Phương",
        "latitude": 20.2500,
        "longitude": 105.7000,
        "province": "Ninh Bình",
        "specificAddress": "Vườn Quốc Gia Cúc Phương, Ninh Bình",
        "descriptionEng": "Cuc Phuong National Park is Vietnam's first national park",
        "descriptionViet": "Vườn Quốc Gia Cúc Phương là vườn quốc gia đầu tiên của Việt Nam",
        "photo": ["https://example.com/cucphuong1.jpg"],
        "video": [],
        "createdDate": "2024-01-01",
        "favouriteTimes": 0,
        "categories": ["Thiên nhiên"],
        "rating": 4.5,
        "userRatingsTotal": 1000
    },
    {
        "destinationId": "D01081",
        "destinationName": "Vườn Quốc Gia Ba Vì",
        "latitude": 21.0833,
        "longitude": 105.4167,
        "province": "Hà Nội",
        "specificAddress": "Vườn Quốc Gia Ba Vì, Hà Nội",
        "descriptionEng": "Ba Vi National Park is a beautiful mountain park",
        "descriptionViet": "Vườn Quốc Gia Ba Vì là một công viên núi đẹp",
        "photo": ["https://example.com/bavi1.jpg"],
        "video": [],
        "createdDate": "2024-01-01",
        "favouriteTimes": 0,
        "categories": ["Thiên nhiên"],
        "rating": 4.3,
        "userRatingsTotal": 800
    },
    {
        "destinationId": "D01082",
        "destinationName": "Vườn Quốc Gia Phong Nha - Kẻ Bàng",
        "latitude": 17.5333,
        "longitude": 106.1500,
        "province": "Quảng Bình",
        "specificAddress": "Vườn Quốc Gia Phong Nha - Kẻ Bàng, Quảng Bình",
        "descriptionEng": "Phong Nha - Ke Bang National Park is famous for its caves",
        "descriptionViet": "Vườn Quốc Gia Phong Nha - Kẻ Bàng nổi tiếng với các hang động",
        "photo": ["https://example.com/phongnha1.jpg"],
        "video": [],
        "createdDate": "2024-01-01",
        "favouriteTimes": 0,
        "categories": ["Thiên nhiên"],
        "rating": 4.7,
        "userRatingsTotal": 1200
    }
]

# Thêm các destination vào database
for dest in test_destinations:
    try:
        db.collection('DESTINATION').document(dest['destinationId']).set(dest)
        print(f"✅ Đã thêm: {dest['destinationName']}")
    except Exception as e:
        print(f"❌ Lỗi khi thêm {dest['destinationName']}: {e}")

print("🎉 Hoàn thành thêm test destinations!") 