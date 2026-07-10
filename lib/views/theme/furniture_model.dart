class FurnitureItem {
  final int id;
  final String name;
  final String fileName; // 💡 파일명만 저장 (예: 'bed.png')
  final int widthCells;  // 가로 칸 수
  final int heightCells; // 세로 칸 수
  final int maxRotations; // 💡 추가: 가구별 최대 회전 가능 방향 수 (1, 2, 4)

  FurnitureItem({
    required this.id,
    required this.name,
    required this.fileName,
    this.widthCells = 1,
    this.heightCells = 1,
    this.maxRotations = 4, // 💡 기본값은 4방향으로 설정
  });

  // 💡 기존의 단순 경로 대신, 회전 상태와 maxRotations를 고려한 스마트 경로 반환 메서드
  String getRotatedAssetPath(int rotation) {
    int suffix = 1;
    if (maxRotations == 4) {
      suffix = (rotation % 4) + 1; // 1, 2, 3, 4 순환
    } else if (maxRotations == 2) {
      suffix = (rotation % 2) + 1; // 1, 2, 1, 2 대칭 순환
    } else {
      suffix = 1; // 완전 대칭(maxRotations = 1)은 무조건 -1 고정
    }

    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1) {
      final base = fileName.substring(0, dotIndex);
      final ext = fileName.substring(dotIndex);
      return 'assets/$base-$suffix$ext'; // 예: assets/chair-1.png
    }
    return 'assets/$fileName-$suffix';
  }

  // 백엔드 호환용 기본 assetPath 유지
  String get assetPath => 'assets/$fileName';
}

class PlacedItem {
  final String docId; // 💡 Firestore 문서 고유 ID (수정/삭제용)
  final FurnitureItem item;
  int x;
  int y;
  int rotation;

  PlacedItem({
    required this.docId,
    required this.item,
    required this.x,
    required this.y,
    this.rotation = 0,
  });

  // 2D 쿼터뷰/단면 겹침 정렬 기준 점수 (X + Y가 클수록 앞쪽에 그려짐)
  int get depthPriority => x + y;
}

// 💡 마스터 클래스 내 가구 정보에 maxRotations 속성 부여
class FurnitureMaster {
  static final List<FurnitureItem> items = [
    // --- 침대류 (4방향) ---
    FurnitureItem(id: 1, name: '침대 1', fileName: 'bed1.png', widthCells: 2, heightCells: 3, maxRotations: 4),
    FurnitureItem(id: 2, name: '침대 2', fileName: 'bed2.png', widthCells: 3, heightCells: 2, maxRotations: 4),
    FurnitureItem(id: 3, name: '침대 3', fileName: 'bed3.png', widthCells: 3, heightCells: 2, maxRotations: 4),

    // --- 의자류 (4방향) ---
    FurnitureItem(id: 4, name: '의자 1', fileName: 'chair1.png', widthCells: 1, heightCells: 1, maxRotations: 4),
    FurnitureItem(id: 5, name: '의자 2', fileName: 'chair2.png', widthCells: 1, heightCells: 1, maxRotations: 4),
    FurnitureItem(id: 6, name: '의자 3', fileName: 'chair3.png', widthCells: 1, heightCells: 1, maxRotations: 4),

    // --- 책상류 ---
    FurnitureItem(id: 7, name: '책상 1', fileName: 'desk1.png', widthCells: 3, heightCells: 2, maxRotations: 2), // 1, 2 파일만 존재
    FurnitureItem(id: 8, name: '책상 2', fileName: 'desk2.png', widthCells: 3, heightCells: 2, maxRotations: 2), // 1, 2 파일만 존재
    FurnitureItem(id: 9, name: '책상 3', fileName: 'desk3.png', widthCells: 2, heightCells: 2, maxRotations: 1), // 1 파일만 존재
    FurnitureItem(id: 10, name: '책상 4', fileName: 'desk4.png', widthCells: 2, heightCells: 3, maxRotations: 2), // 1, 2 파일만 존재
    FurnitureItem(id: 11, name: '책상 5', fileName: 'desk5.png', widthCells: 3, heightCells: 2, maxRotations: 4), // 1, 2, 3, 4 파일 존재

    // --- 서랍장 (4방향) ---
    FurnitureItem(id: 12, name: '서랍장', fileName: 'drawer.png', widthCells: 1, heightCells: 1, maxRotations: 4), // 1, 2, 3, 4 파일 존재

    // --- 유리 책상 ---
    FurnitureItem(id: 13, name: '유리 책상 1', fileName: 'glassdesk.png', widthCells: 1, heightCells: 1, maxRotations: 1), // 1 파일만 존재
    FurnitureItem(id: 14, name: '유리 책상 2', fileName: 'glassdesk2.png', widthCells: 2, heightCells: 2, maxRotations: 1), // 1 파일만 존재
  ];

  // ID값으로 가구 원본 정보를 찾아주는 헬퍼 함수
  static FurnitureItem findById(int id) {
    return items.firstWhere(
          (element) => element.id == id,
      orElse: () => FurnitureItem(id: 0, name: '알 수 없는 가구', fileName: 'unknown.png', maxRotations: 1),
    );
  }
}