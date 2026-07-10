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
  // 💡 기존의 로컬 상태 변수 _myXp는 삭제했습니다. (StreamBuilder에서 직접 관리)

  // 모든 가구의 통일된 가격
  final int _fixedPrice = 150;

  // FurnitureMaster에서 가구 목록 불러오기
  final List<FurnitureItem> _allItems = FurnitureMaster.items;

  // 🛒 Firebase에 아이템 구매 내역 저장 및 경험치 차감하는 함수
  Future<void> _purchaseItem(FurnitureItem item, int currentXp) async {
    // 1. Provider에서 현재 유저 ID 가져오기
    final myUserId = context.read<UserProvider>().userId;

    if (myUserId == null || myUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저 정보를 불러올 수 없습니다.')),
      );
      return;
    }

    // 2. 실시간 XP가 충분한지 확인
    if (currentXp < _fixedPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('XP가 부족합니다! 열심히 미션을 수행해보세요!')),
      );
      return;
    }

    try {
      // 💡 3. Firestore Batch를 사용하여 아이템 추가와 경험치 차감을 동시에 안전하게 처리
      final batch = FirebaseFirestore.instance.batch();

      // [1] user_items 컬렉션에 구매한 가구 데이터 추가
      final newItemRef = FirebaseFirestore.instance.collection('user_items').doc();
      batch.set(newItemRef, {
        'furniture_id': item.id,
        'user_id': myUserId,
      });

      // [2] users 컬렉션에서 내 current_xp 차감 (FieldValue.increment 사용)
      final userRef = FirebaseFirestore.instance.collection('users').doc(myUserId);
      batch.update(userRef, {
        'current_xp': FieldValue.increment(-_fixedPrice)
      });

      // 일괄 처리 실행
      await batch.commit();

      // 4. 구매 성공 처리 (스낵바 띄우기)
      // (로컬 변수 _myXp -= _fixedPrice 부분은 DB 연동으로 인해 삭제되었습니다)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} 구매 완료! 보관함을 확인해보세요.'),
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

  // 구매 확인 다이얼로그 띄우기 (현재 XP도 매개변수로 받아옵니다)
  void _showPurchaseConfirmDialog(FurnitureItem item, int currentXp) {
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
                _purchaseItem(item, currentXp);    // 구매 로직 실행
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
    // build 단계에서 Provider를 통해 내 UID를 가져옵니다.
    final myUserId = context.read<UserProvider>().userId;

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

      // 💡 StreamBuilder로 내 유저 정보 문서를 실시간 구독하여 current_xp를 가져옵니다.
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(myUserId).snapshots(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            }

            // DB에서 current_xp 파싱 (데이터가 없거나 필드가 없으면 0으로 초기화)
            int currentXp = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              // (혹시 필드명이 currentXp일 경우를 대비해 fallback 처리까지 넣었습니다)
              currentXp = (data['current_xp'] ?? data['currentXp'] ?? 0) as int;
            }

            return Column(
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
                        // XP 뱃지 (실시간 DB 값 적용)
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
                                '${_formatNumber(currentXp)} XP',
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
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _allItems.length,
                    itemBuilder: (context, index) {
                      final item = _allItems[index];
                      return _buildItemCard(item, currentXp); // 카드로 현재 보유 XP 전달
                    },
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  // 개별 아이템 카드 위젯
  Widget _buildItemCard(FurnitureItem item, int currentXp) {
    final imagePath = item.getRotatedAssetPath(0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1435),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. 가구 이미지
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
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
              onPressed: () => _showPurchaseConfirmDialog(item, currentXp), // 버튼 누를 때 XP 검사 로직으로 진입
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