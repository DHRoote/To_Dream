import 'package:flutter/material.dart';
import 'furniture_model.dart';

class ThemeDisplayWidget extends StatelessWidget {
  final List<PlacedItem> placedItems;
  final int gridSize = 6;

  const ThemeDisplayWidget({super.key, required this.placedItems});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerSize = constraints.maxWidth;

        // 💡 [여기 수정] 기존 0.61에서 0.82 정도로 비율을 키웁니다.
        final double boardSize = containerSize * 0.61;
        final double cellSize = boardSize / gridSize;

        // 💡 [여기 수정] 보드가 커진 만큼 상단 여백(y축 위치)도 알맞게 조정해야 합니다.
        // 기존 0.368에서 보드가 커진 만큼 위로 조금 올려주기 위해 0.25~0.28 정도로 조절해보세요.
        final double topOffset = containerSize * 0.38;
        final double leftOffset = (containerSize - boardSize) / 2;

        final sortedItems = List<PlacedItem>.from(placedItems)
          ..sort((a, b) => a.depthPriority.compareTo(b.depthPriority));

        return Container(
          width: containerSize,
          height: containerSize,
          color: const Color(0xFF1E1538),
          child: Stack(
            children: [
              // 배경 이미지 깔기
              Positioned.fill(
                child: Image.asset(
                  'assets/home.png',
                  fit: BoxFit.cover,
                ),
              ),
              // 가구 데이터 렌더링
              Positioned(
                left: leftOffset,
                top: topOffset,
                width: boardSize,
                height: boardSize,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(1.0, 0.47)
                    ..rotateZ(0.785398),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: sortedItems.map((placed) {
                      // 회전 방향에 따른 격자 사이즈 체인지 스왑
                      final bool isOriented = (placed.item.maxRotations > 1) && (placed.rotation % 2 == 1);
                      final double itemWidth = (isOriented ? placed.item.heightCells : placed.item.widthCells) * cellSize;
                      final double itemHeight = (isOriented ? placed.item.widthCells : placed.item.heightCells) * cellSize;

                      return Positioned(
                        left: placed.x * cellSize,
                        top: placed.y * cellSize,
                        width: itemWidth,
                        height: itemHeight,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateZ(-0.785398)
                            ..scale(1.0, 1.92),
                          child: Transform.scale(
                            scale: 1.3, // 👈 1.3은 30% 확대라는 뜻입니다. (1.5로 하면 50% 확대)
                            alignment: Alignment.bottomCenter, // 💡 바닥(기준점)을 고정한 채로 위로 커지게 설정
                            child: Image.asset(
                              placed.item.getRotatedAssetPath(placed.rotation),
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => Container(color: Colors.purple.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}