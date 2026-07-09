import 'package:eh/views/mainapp/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eh/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'furniture_model.dart';
import 'theme_display_widget.dart';
import 'theme_edit_widget.dart';

class ThemeAppPage extends StatefulWidget {
  const ThemeAppPage({super.key});

  @override
  State<ThemeAppPage> createState() => _ThemeAppPageState();
}

class _ThemeAppPageState extends State<ThemeAppPage> {
  bool _isEditMode = false;
  FurnitureItem? _selectedInventoryItem;

  @override
  Widget build(BuildContext context) {
    final myUserId = context.read<UserProvider>().userId;
    final myNickname = context.read<UserProvider>().nickname;

    // 💡 2, 3번 요구사항: 최상위 컬렉션 두 곳에서 내 가구 정보 실시간 복합 구독 구현 (Nested Streams)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_items')
          .where('user_id', isEqualTo: myUserId)
          .snapshots(),
      builder: (context, inventorySnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('theme_placements')
              .where('user_id', isEqualTo: myUserId)
              .snapshots(),
          builder: (context, placementsSnapshot) {

            // 데이터 로딩 상태 예외 처리
            if (inventorySnapshot.connectionState == ConnectionState.waiting ||
                placementsSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF0D0A1E),
                body: Center(child: CircularProgressIndicator(color: Color(0xFF8E51FF))),
              );
            }

            // 1. 인벤토리 목록 파싱 (user_items 컬렉션 파싱)
            List<FurnitureItem> ownedInventory = [];
            if (inventorySnapshot.hasData) {
              for (var doc in inventorySnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final int fId = data['furniture_id'] ?? 0;
                ownedInventory.add(FurnitureMaster.findById(fId));
              }
            }

            // 2. 방에 배치된 가구 리스트 파싱 (theme_placements 컬렉션 파싱)
            List<PlacedItem> placedItems = [];
            if (placementsSnapshot.hasData) {
              for (var doc in placementsSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final int fId = data['furniture_id'] ?? 0;
                placedItems.add(
                  PlacedItem(
                    docId: doc.id, // 문서 ID 저장하여 나중에 제어
                    item: FurnitureMaster.findById(fId),
                    x: data['position_x'] ?? 0,
                    y: data['position_y'] ?? 0,
                    rotation: data['rotation'] ?? 0,
                  ),
                );
              }
            }

            return Scaffold(
                resizeToAvoidBottomInset: true,
                endDrawer: const MainEndDrawer(),
                floatingActionButton: Container(
                  width: 56.0, height: 56.0,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🏡', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 2),
                        Text('메인', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                body: Container(
                  width: double.infinity, height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, -0.8), end: Alignment(0.0, 1.0),
                      colors: [Color(0xFF12083A), Color(0xFF0D0A1E), Color(0xFF081228)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                _buildHeader(myNickname),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isEditMode ? '🛠️ 원하는 위치를 터치하여 배치하세요' : '🏠 내 미니룸',
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditMode = !_isEditMode;
                                          _selectedInventoryItem = null;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _isEditMode ? Colors.cyan : const Color(0xFF8E51FF),
                                        side: BorderSide(color: _isEditMode ? Colors.cyan : const Color(0xFF8E51FF)),
                                      ),
                                      child: Text(_isEditMode ? '저장 완료' : '배치 편집'),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // --- 1. 가구 월드 뷰 (전시 / 편집 상호 스위칭) ---
                                // --- 1. 가구 월드 뷰 (전시 / 편집 상호 스위칭) ---
                                _isEditMode
                                    ? ThemeEditWidget(
                                  placedItems: placedItems,
                                  selectedInventoryItem: _selectedInventoryItem,
                                  onItemMoved: (item, newX, newY) async {
                                    await FirebaseFirestore.instance
                                        .collection('theme_placements')
                                        .doc(item.docId)
                                        .update({'position_x': newX, 'position_y': newY});
                                  },
                                  onItemRotated: (item) async {
                                    int nextRotation = (item.rotation + 1) % 4; // 0 -> 1 -> 2 -> 3 -> 0 순환
                                    await FirebaseFirestore.instance
                                        .collection('theme_placements')
                                        .doc(item.docId)
                                        .update({'rotation': nextRotation});
                                  },
                                  onItemDeleted: (item) async {
                                    await FirebaseFirestore.instance
                                        .collection('theme_placements')
                                        .doc(item.docId)
                                        .delete();
                                  },
                                  onNewItemPlaced: (x, y) async {
                                    if (_selectedInventoryItem != null) {
                                      await FirebaseFirestore.instance
                                          .collection('theme_placements')
                                          .add({
                                        'user_id': myUserId,
                                        'furniture_id': _selectedInventoryItem!.id,
                                        'position_x': x,
                                        'position_y': y,
                                        'rotation': 0,
                                      });
                                      setState(() => _selectedInventoryItem = null);
                                    }
                                  },
                                )
                                    : ThemeDisplayWidget(placedItems: placedItems),
                                const SizedBox(height: 28),

                                // --- 2. 하단 보관함 UI 컴포넌트 출력 ---
                                _buildInventory(ownedInventory ,placedItems),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(String nickname) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('안녕하세요, $nickname님 💫', style: const TextStyle(color: Color(0xFFF0EAFF), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Noto Sans KR')),
            const SizedBox(height: 4),
            const Text('보유 중인 아이템으로 나만의 방을 꾸며보세요.', style: TextStyle(color: Color(0xFF7C6FA0), fontSize: 12, fontFamily: 'Noto Sans KR')),
          ],
        ),
      ],
    );
  }

  Widget _buildInventory(List<FurnitureItem> ownedInventory, List<PlacedItem> placedItems) {
    // 1. 유저가 보유한 가구 종류별 총 개수 카운트
    Map<int, int> ownedCounts = {};
    for (var item in ownedInventory) {
      ownedCounts[item.id] = (ownedCounts[item.id] ?? 0) + 1;
    }
    // 2. 현재 방에 배치된 가구 종류별 개수 카운트
    Map<int, int> placedCounts = {};
    for (var p in placedItems) {
      placedCounts[p.item.id] = (placedCounts[p.item.id] ?? 0) + 1;
    }

    // 중복 아이콘 방지를 위해 종류별로 1개씩 묶기
    List<FurnitureItem> uniqueItems = [];
    Set<int> seenIds = {};
    for (var item in ownedInventory) {
      if (!seenIds.contains(item.id)) {
        uniqueItems.add(item);
        seenIds.add(item.id);
      }
    }

    // 💡 [수정 사항 1] 보관함 아이템 이름순(가나다/ABC) 정렬 적용
    uniqueItems.sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📦 가구 보관함 (보유 중)', style: TextStyle(color: Color(0xFFF0EAFF), fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12), // 💡 고정 높이(height: 96)를 없애고 패딩으로 교체하여 아래로 확장되게 유도
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: uniqueItems.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('가구가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 12))),
          )
              : GridView.builder(
            // 💡 [수정 사항 2] 좌우 스크롤 대신 아래로 자동 확장되는 GridView 배치
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // 최상위 SingleChildScrollView와 스크롤 연동
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,       // 한 줄에 가구 4개씩 균등 배치
              crossAxisSpacing: 10,    // 아이템 가로 간격
              mainAxisSpacing: 10,     // 아이템 세로 간격
              childAspectRatio: 0.82,  // 셀 가로/세로 비율 (글자 누락 방지용 여유 공간 확보)
            ),
            itemCount: uniqueItems.length,
            itemBuilder: (context, index) {
              final item = uniqueItems[index];
              bool isPicked = _selectedInventoryItem?.id == item.id;

              int availableCount = (ownedCounts[item.id] ?? 0) - (placedCounts[item.id] ?? 0);
              bool isExhausted = availableCount <= 0;

              return GestureDetector(
                onTap: () {
                  if (!_isEditMode) return;

                  if (isExhausted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('해당 가구를 이미 전부 배치했습니다!'), duration: Duration(seconds: 1)),
                    );
                    return;
                  }

                  setState(() {
                    _selectedInventoryItem = isPicked ? null : item;
                  });
                },
                child: Opacity(
                  opacity: isExhausted ? 0.3 : 1.0,
                  child: Container(
                    // 💡 고정 width와 margin을 지우고 Grid 구조가 제어하도록 위임
                    decoration: BoxDecoration(
                      color: isPicked ? const Color(0x4D8E51FF) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isPicked ? const Color(0xFF8E51FF) : Colors.transparent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chair, color: Colors.white, size: 24),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            item.name,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // 혹시 이름이 길어지면 말줄임표 처리
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('$availableCount개 남음', style: const TextStyle(color: Colors.cyanAccent, fontSize: 8)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}