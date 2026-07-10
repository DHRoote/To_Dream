import 'package:flutter/material.dart';
import 'furniture_model.dart';

class ThemeEditWidget extends StatefulWidget {
  final List<PlacedItem> placedItems;
  final FurnitureItem? selectedInventoryItem;
  final Function(PlacedItem item, int newX, int newY) onItemMoved;
  final Function(PlacedItem item) onItemRotated; // 💡 상위 위젯에서 실행될 회전 이벤트 함수
  final Function(PlacedItem item) onItemDeleted;
  final Function(int x, int y) onNewItemPlaced;

  const ThemeEditWidget({
    super.key,
    required this.placedItems,
    required this.selectedInventoryItem,
    required this.onItemMoved,
    required this.onItemRotated,
    required this.onItemDeleted,
    required this.onNewItemPlaced,
  });

  @override
  State<ThemeEditWidget> createState() => _ThemeEditWidgetState();
}

class _ThemeEditWidgetState extends State<ThemeEditWidget> {
  final int gridSize = 6;
  String? _draggingDocId;
  int _dragX = 0;
  int _dragY = 0;
  double _accumulatedDx = 0;
  double _accumulatedDy = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerSize = constraints.maxWidth;

        // 💡 [여기 수정] 디스플레이 위젯과 완벽히 동일한 값으로 입력
        final double boardSize = containerSize * 0.61;
        final double cellSize = boardSize / gridSize;

        // 💡 [여기 수정] 디스플레이 위젯과 완벽히 동일한 값으로 입력
        final double topOffset = containerSize * 0.38;
        final double leftOffset = (containerSize - boardSize) / 2;

        final sortedItems = List<PlacedItem>.from(widget.placedItems)
          ..sort((a, b) => a.depthPriority.compareTo(b.depthPriority));

        return Container(
          width: containerSize,
          height: containerSize,
          color: const Color(0xFF1E1538),
          child: Stack(
            children: [
              // 1️⃣ 배경 이미지
              Positioned.fill(
                child: Image.asset(
                  'assets/home.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2️⃣ 격자 및 가구 레이어
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
                  child: GestureDetector(
                    onTapUp: (details) {
                      if (widget.selectedInventoryItem != null) {
                        int targetX = (details.localPosition.dx / cellSize).floor();
                        int targetY = (details.localPosition.dy / cellSize).floor();
                        if (targetX >= 0 && targetX < gridSize && targetY >= 0 && targetY < gridSize) {
                          widget.onNewItemPlaced(targetX, targetY);
                        }
                      }
                    },
                    child: Container(
                      width: boardSize,
                      height: boardSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 타일 가이드 선
                          Positioned.fill(
                            child: GridPaper(
                              color: Colors.white.withValues(alpha: 0.15),
                              divisions: 1,
                              subdivisions: 1,
                              interval: cellSize,
                            ),
                          ),

                          // 가구 배치 리스트
                          ...sortedItems.map((placed) {
                            bool isDragging = _draggingDocId == placed.docId;
                            int currentX = isDragging ? _dragX : placed.x;
                            int currentY = isDragging ? _dragY : placed.y;

                            // 💡 [핵심] 90도 혹은 270도 회전 시(즉, 홀수 변환) 격자 상 가로세로 점유 크기를 뒤바꿔줍니다.
                            // 단, 회전 가능한 가구(maxRotations > 1)일 때만 작동합니다.
                            final bool isOriented = (placed.item.maxRotations > 1) && (placed.rotation % 2 == 1);
                            final int currentWidthCells = isOriented ? placed.item.heightCells : placed.item.widthCells;
                            final int currentHeightCells = isOriented ? placed.item.widthCells : placed.item.heightCells;

                            return Positioned(
                              left: currentX * cellSize,
                              top: currentY * cellSize,
                              width: currentWidthCells * cellSize,
                              height: currentHeightCells * cellSize,
                              child: GestureDetector(
                                onTap: () => widget.onItemRotated(placed),
                                onDoubleTap: () => widget.onItemDeleted(placed),
                                onPanStart: (_) {
                                  _accumulatedDx = placed.x * cellSize;
                                  _accumulatedDy = placed.y * cellSize;
                                  setState(() {
                                    _draggingDocId = placed.docId;
                                    _dragX = placed.x;
                                    _dragY = placed.y;
                                  });
                                },
                                onPanUpdate: (details) {
                                  _accumulatedDx += details.delta.dx;
                                  _accumulatedDy += details.delta.dy;
                                  int newX = (_accumulatedDx / cellSize).round();
                                  int newY = (_accumulatedDy / cellSize).round();

                                  // 💡 회전되어 바뀐 실시간 크기를 기준으로 맵 밖으로 나가지 못하게 제어합니다.
                                  if (newX >= 0 && newX <= gridSize - currentWidthCells &&
                                      newY >= 0 && newY <= gridSize - currentHeightCells) {
                                    if (newX != _dragX || newY != _dragY) {
                                      setState(() {
                                        _dragX = newX;
                                        _dragY = newY;
                                      });
                                    }
                                  }
                                },
                                onPanEnd: (_) {
                                  if (_draggingDocId != null) {
                                    if (_dragX != placed.x || _dragY != placed.y) {
                                      widget.onItemMoved(placed, _dragX, _dragY);
                                    }
                                    setState(() => _draggingDocId = null);
                                  }
                                },
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
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
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