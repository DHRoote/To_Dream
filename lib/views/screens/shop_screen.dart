import 'package:flutter/material.dart';

// --- 1. 상점 아이템 데이터 모델 ---
class ShopItem {
  final String name;
  final int price;

  ShopItem({
    required this.name,
    required this.price,
  });
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // 보유 중인 경험치(XP)
  final int _myXp = 3420;

  // --- 2. 아이템 리스트 데이터 ---
  final List<ShopItem> _allItems = [
    ShopItem(name: '의자 1', price: 500),
    ShopItem(name: '의자 2', price: 800),
    ShopItem(name: '의자 3', price: 1000),
    ShopItem(name: '책상 1', price: 1000),
    ShopItem(name: '책상 2', price: 1200),
    ShopItem(name: '책상 3', price: 1500),
    ShopItem(name: '책상 4', price: 2000),
    ShopItem(name: '책상 5', price: 1800),
    ShopItem(name: '유리테이블 1', price: 1100),
    ShopItem(name: '유리테이블 2', price: 1300),
    ShopItem(name: '침대 1', price: 3000),
    ShopItem(name: '침대 2', price: 4500),
    ShopItem(name: '침대 3', price: 3500),
    ShopItem(name: '서랍 1', price: 900),
    ShopItem(name: '책장 1', price: 1200),
  ];

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
        // 💡 actions 속성(메뉴 버튼)을 삭제했습니다.
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

          // --- 2. 아이템 그리드 뷰 ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 40),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
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
  Widget _buildItemCard(ShopItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1435),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 아이템명
          Text(
            item.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // 2. 가격 (XP) 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                print('${item.name} 구매 시도');
              },
              icon: const Icon(Icons.flash_on, color: Color(0xFFFFB800), size: 16),
              label: Text(
                '${_formatNumber(item.price)} XP',
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