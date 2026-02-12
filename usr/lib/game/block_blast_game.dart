import 'package:flutter/material.dart';
import 'models.dart';

class BlockBlastGame extends StatefulWidget {
  const BlockBlastGame({super.key});

  @override
  State<BlockBlastGame> createState() => _BlockBlastGameState();
}

class _BlockBlastGameState extends State<BlockBlastGame> {
  // 8x8 Grid: null means empty, Color means filled
  late List<List<Color?>> grid;
  
  // The 3 shapes available to play
  late List<BlockShape?> availableShapes;
  
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      grid = List.generate(
        GameConstants.gridSize,
        (_) => List.generate(GameConstants.gridSize, (_) => null),
      );
      score = 0;
      isGameOver = false;
      _generateNewShapes();
    });
  }

  void _generateNewShapes() {
    availableShapes = List.generate(3, (_) => GameConstants.generateRandomShape());
    _checkGameOver();
  }

  // Check if any of the available shapes can fit anywhere on the grid
  void _checkGameOver() {
    // If all shapes are null (used), we don't check game over yet, we wait for refill
    if (availableShapes.every((s) => s == null)) return;

    bool canMove = false;
    
    for (var shape in availableShapes) {
      if (shape == null) continue;
      
      // Try every position
      for (int r = 0; r < GameConstants.gridSize; r++) {
        for (int c = 0; c < GameConstants.gridSize; c++) {
          if (_canPlaceShape(shape, r, c)) {
            canMove = true;
            break;
          }
        }
        if (canMove) break;
      }
      if (canMove) break;
    }

    if (!canMove) {
      setState(() {
        isGameOver = true;
      });
    }
  }

  bool _canPlaceShape(BlockShape shape, int row, int col) {
    // Check bounds and overlap
    for (int r = 0; r < shape.height; r++) {
      for (int c = 0; c < shape.width; c++) {
        if (shape.matrix[r][c] == 1) {
          int gridRow = row + r;
          int gridCol = col + c;

          // Out of bounds
          if (gridRow >= GameConstants.gridSize || gridCol >= GameConstants.gridSize) {
            return false;
          }

          // Already filled
          if (grid[gridRow][gridCol] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _placeShape(BlockShape shape, int row, int col) {
    setState(() {
      // 1. Place the block
      for (int r = 0; r < shape.height; r++) {
        for (int c = 0; c < shape.width; c++) {
          if (shape.matrix[r][c] == 1) {
            grid[row + r][col + c] = shape.color;
          }
        }
      }

      // 2. Remove from available shapes
      int index = availableShapes.indexOf(shape);
      if (index != -1) {
        availableShapes[index] = null;
      }

      // 3. Check for lines to clear
      _clearLines();

      // 4. Update score (simple logic: 10 points per block placed + bonus for lines)
      int blocksCount = 0;
      for(var row in shape.matrix) {
        for(var cell in row) {
          if(cell == 1) blocksCount++;
        }
      }
      score += blocksCount;

      // 5. Refill shapes if empty
      if (availableShapes.every((element) => element == null)) {
        _generateNewShapes();
      } else {
        // Check game over with remaining shapes
        _checkGameOver();
      }
    });
  }

  void _clearLines() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    // Check Rows
    for (int r = 0; r < GameConstants.gridSize; r++) {
      bool full = true;
      for (int c = 0; c < GameConstants.gridSize; c++) {
        if (grid[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) rowsToClear.add(r);
    }

    // Check Cols
    for (int c = 0; c < GameConstants.gridSize; c++) {
      bool full = true;
      for (int r = 0; r < GameConstants.gridSize; r++) {
        if (grid[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) colsToClear.add(c);
    }

    if (rowsToClear.isEmpty && colsToClear.isEmpty) return;

    // Clear and Score
    // Simple scoring: 100 per line, bonus for multi-line
    int linesCleared = rowsToClear.length + colsToClear.length;
    score += linesCleared * 100 * linesCleared; // Exponential bonus

    // Update grid
    // We need to be careful not to double-clear intersections incorrectly or crash
    // Actually, just setting them to null is fine.
    
    for (int r in rowsToClear) {
      for (int c = 0; c < GameConstants.gridSize; c++) {
        grid[r][c] = null;
      }
    }
    
    for (int c in colsToClear) {
      for (int r = 0; r < GameConstants.gridSize; r++) {
        grid[r][c] = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Block Blast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _startNewGame,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score Board
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Text(
                    'SCORE',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, letterSpacing: 2),
                  ),
                  Text(
                    '$score',
                    style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Game Grid
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: GameConstants.gridBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double cellSize = (constraints.maxWidth - 8) / GameConstants.gridSize;
                          return Stack(
                            children: [
                              // The visual grid
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: GameConstants.gridSize * GameConstants.gridSize,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: GameConstants.gridSize,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                ),
                                itemBuilder: (context, index) {
                                  int r = index ~/ GameConstants.gridSize;
                                  int c = index % GameConstants.gridSize;
                                  Color? cellColor = grid[r][c];
                                  
                                  return DragTarget<BlockShape>(
                                    onWillAcceptWithDetails: (details) {
                                      // We don't use this for the main logic because we need precise drop coordinates
                                      // relative to the shape's anchor.
                                      // However, we can use the "Global" drag target approach below.
                                      return false; 
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: cellColor ?? GameConstants.cellEmpty,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              
                              // Invisible DragTarget overlay for handling drops
                              // We use a single large DragTarget for the whole board to calculate relative position
                              Positioned.fill(
                                child: DragTarget<BlockShape>(
                                  onWillAcceptWithDetails: (details) {
                                    // Calculate which cell is under the drag
                                    // This is tricky because details.offset is global.
                                    // We need local coordinates.
                                    return true;
                                  },
                                  onAcceptWithDetails: (details) {
                                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                                    Offset localOffset = renderBox.globalToLocal(details.offset);
                                    
                                    // Adjust for the fact that the user drags the shape by its center (usually)
                                    // But the Draggable feedback is usually centered under finger.
                                    // Let's assume the drop point is the center of the shape.
                                    // We need to find the top-left cell of the shape.
                                    
                                    // NOTE: A simpler way is to pass the "touch offset within the shape" 
                                    // but Flutter's Draggable doesn't easily give that.
                                    // Instead, we can approximate.
                                    
                                    // Let's calculate the cell row/col based on localOffset
                                    // The grid has padding of 4.
                                    double effectiveX = localOffset.dx;
                                    double effectiveY = localOffset.dy;
                                    
                                    // We need to align the shape. 
                                    // Let's assume the user is dragging the "center" of the shape.
                                    // We need to shift to find the top-left (0,0) of the shape matrix.
                                    double blockWidth = details.data.width * cellSize;
                                    double blockHeight = details.data.height * cellSize;
                                    
                                    double topLeftX = effectiveX - (blockWidth / 2);
                                    double topLeftY = effectiveY - (blockHeight / 2);
                                    
                                    int c = (topLeftX / (cellSize + 2)).round();
                                    int r = (topLeftY / (cellSize + 2)).round();
                                    
                                    if (_canPlaceShape(details.data, r, c)) {
                                      _placeShape(details.data, r, c);
                                    }
                                  },
                                  builder: (context, candidates, rejected) {
                                    return Container(color: Colors.transparent);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Shapes Tray
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: availableShapes.map((shape) {
                  if (shape == null) {
                    return const SizedBox(width: 80, height: 80);
                  }
                  return Draggable<BlockShape>(
                    data: shape,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: 1.1,
                        child: ShapeWidget(shape: shape, cellSize: 30), // Slightly larger feedback
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: ShapeWidget(shape: shape, cellSize: 20),
                    ),
                    child: ShapeWidget(shape: shape, cellSize: 20),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapeWidget extends StatelessWidget {
  final BlockShape shape;
  final double cellSize;

  const ShapeWidget({
    super.key,
    required this.shape,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(shape.height, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(shape.width, (c) {
            return Container(
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: shape.matrix[r][c] == 1 ? shape.color : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      }),
    );
  }
}
