import re
from underthesea import word_tokenize
import firebase_admin
from firebase_admin import credentials, firestore
import uuid

# Define common Vietnamese profanity words
PROFANITY_WORDS = [
    "đmm", "dm", "đm", "cc", "cặc", "lồn", "cl", "địt", "đéo", "mày", "tao", "loz", "vú", "dú", "cu", "cứt",
    "óc chó", "ngu", "chết tiệt", "khốn nạn", "súc vật", "thằng chó", 'con chó',
    "đĩ", "phò", "động vật", "vô học", "rác rưởi", "bẩn thỉu", "mất dạy",
    "chó đẻ", "đồ khốn", "đồ ngu", "đồ điên", "đồ mất dạy", "đồ vô giáo dục", "đồ khốn nạn",
    "đồ súc vật", "đồ đĩ", "đụ mẹ", "đụ má", "đụ mày", "đụ con mẹ mày", "đụ con đĩ",
    "con khùng", "con điên", "đồ điên khùng", "đồ ngu si", "đồ ngu ngốc",
    "đồ ngu dốt", "vãi cức", "vãi lồn", "vãi đái", "vãi cả lồn",
    "cc mày", "cc tao", "cc nó", "cc chúng mày", "cc tụi mày", "con mẹ mày",
    "cac", "lon", "cc", "đmm", "đmm tao", "đmm nó", "đmm chúng mày", "đmm tụi mày",
    "địt mẹ", "địt mẹ mày", "vcl", "vc", "vcc", "vl",
]

def is_profane(comment, profanity_words=PROFANITY_WORDS):
    """Checks if a comment contains any forbidden words using underthesea.word_tokenize."""
    # Simple preprocessing for profanity check: lowercase and remove some common punctuation
    temp_comment = comment.lower()
    temp_comment = re.sub(r'[^\w\s]', ' ', temp_comment) # Keep words and spaces
    temp_comment = re.sub(r'\s+', ' ', temp_comment).strip()

    print(f"Original comment: '{comment}'")
    print(f"Processed comment: '{temp_comment}'")

    # Tokenize the comment to get individual words
    # Using format="text" and then splitting to ensure compatibility with `in` operator
    words_in_comment = word_tokenize(temp_comment, format="text").split()
    
    print(f"Tokenized words: {words_in_comment}")

    for word in profanity_words:
        if word in words_in_comment:
            print(f"Found profanity word: '{word}'")
            return True
        # Check for multi-word profanity
        if word in temp_comment:
            print(f"Found multi-word profanity: '{word}'")
            return True
    
    print("No profanity found")
    return False

# Test cases
test_comments = [
    "con chó",
    "đmm",
    "cc",
    "thằng chó",
    "con mẹ mày",
    "hello world",
    "địt mẹ",
    "vcl"
]

print("=== TESTING PROFANITY DETECTION ===")
for comment in test_comments:
    print(f"\n--- Testing: '{comment}' ---")
    result = is_profane(comment)
    print(f"Result: {result}")
    print("-" * 50)

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