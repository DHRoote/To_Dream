import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:eh/providers/user_provider.dart';
import '../theme/furniture_model.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // 보유 중인 경험치(XP) - (추후 DB/Provider 연동 필요)
  int _myXp = 3420;

  // 모든 가구의 통일된 가격
  final int _fixedPrice = 150;

  // FurnitureMaster에서 가구 목록 불러오기
  final List<FurnitureItem> _allItems = FurnitureMaster.items;

  // 🛒 Firebase에 아이템 구매 내역 저장하는 함수
  Future<void> _purchaseItem(FurnitureItem item) async {
    // 1. Provider에서 현재 유저 ID 가져오기
    final myUserId = context.read<UserProvider>().userId;

    if (myUserId == null || myUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저 정보를 불러올 수 없습니다.')),
      );
      return;
    }

    // 2. XP가 충분한지 확인
    if (_myXp < _fixedPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('XP가 부족합니다!')),
      );
      return;
    }

    try {
      // 3. Firestore 'user_items' 컬렉션에 데이터 추가
      await FirebaseFirestore.instance.collection('user_items').add({
        'furniture_id': item.id,
        'user_id': myUserId,
      });

      // 4. 구매 성공 처리 (UI 업데이트 및 스낵바 띄우기)
      if (mounted) {
        setState(() {
          _myXp -= _fixedPrice; // XP 차감 로직 (현재 화면에서만 반영)
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} 구매 완료!'),
            backgroundColor: const Color(0xFFB062FF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매에 실패했습니다: $e')),
        );
      }
    }
  }

  // 구매 확인 다이얼로그 띄우기
  void _showPurchaseConfirmDialog(FurnitureItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1435),
          title: const Text('아이템 구매', style: TextStyle(color: Colors.white)),
          content: Text(
            '${item.name}을(를) $_fixedPrice XP로 구매하시겠습니까?',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소
              child: const Text('취소', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                _purchaseItem(item);    // 구매 로직 실행
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB800),
              ),
              child: const Text('구매하기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F071D), // 어두운 네이비 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '상점',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. 상단 내 경험치 및 상점 안내 헤더 ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1435),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '소품 상점',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '경험치로 나만의 공간을 꾸며보세요',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                      ),
                    ],
                  ),
                  // XP 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: Color(0xFFFFB800), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatNumber(_myXp)} XP',
                          style: const TextStyle(
                            color: Color(0xFFFFB800),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 2. 아이템 그리드 뷰 (이미지 포함) ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 40),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                // 💡 이미지가 들어갈 공간을 확보하기 위해 비율을 0.8로 수정
                childAspectRatio: 0.8,
              ),
              itemCount: _allItems.length,
              itemBuilder: (context, index) {
                final item = _allItems[index];
                return _buildItemCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 개별 아이템 카드 위젯
  Widget _buildItemCard(FurnitureItem item) {
    // 💡 getRotatedAssetPath(0)을 호출하면 '-1' 번호의 기본 이미지가 반환됩니다! (예: assets/bed1-1.png)
    final imagePath = item.getRotatedAssetPath(0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1435),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 위젯 간격 균등 배치
        children: [
          // 1. 가구 이미지 (assets 폴더에서 불러오기)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain, // 이미지가 카드 영역 안에 잘 맞게 들어가도록 설정
              ),
            ),
          ),

          // 2. 아이템명
          Text(
            item.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // 3. 가격 (XP) 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showPurchaseConfirmDialog(item),
              icon: const Icon(Icons.flash_on, color: Color(0xFFFFB800), size: 16),
              label: Text(
                '${_formatNumber(_fixedPrice)} XP',
                style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB800).withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: const Color(0xFFFFB800).withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 숫자 천 단위 콤마 포맷팅 함수
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}