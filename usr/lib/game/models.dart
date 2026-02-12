import 'dart:math';
import 'package:flutter/material.dart';

// Represents a single block shape
class BlockShape {
  final List<List<int>> matrix; // 1 for filled, 0 for empty
  final Color color;
  final int id; // Unique ID for keying

  BlockShape({
    required this.matrix,
    required this.color,
    required this.id,
  });

  int get width => matrix[0].length;
  int get height => matrix.length;
}

class GameConstants {
  static const int gridSize = 8;
  
  // Colors
  static const Color gridBackground = Color(0xFF16213E);
  static const Color cellEmpty = Color(0xFF0F3460);
  
  static const List<Color> blockColors = [
    Color(0xFFE94560), // Red
    Color(0xFF533483), // Purple
    Color(0xFF0F3460), // Dark Blue
    Color(0xFFF2A365), // Orange
    Color(0xFF22A6B3), // Teal
    Color(0xFF6AB04C), // Green
    Color(0xFFF9CA24), // Yellow
  ];

  static List<List<List<int>>> shapeTemplates = [
    // 1x1
    [[1]],
    // 2x1
    [[1, 1]],
    [[1], [1]],
    // 3x1
    [[1, 1, 1]],
    [[1], [1], [1]],
    // 4x1
    [[1, 1, 1, 1]],
    [[1], [1], [1], [1]],
    // 2x2 Square
    [[1, 1], [1, 1]],
    // 3x3 Square
    [[1, 1, 1], [1, 1, 1], [1, 1, 1]],
    // L shapes
    [[1, 0], [1, 0], [1, 1]],
    [[0, 1], [0, 1], [1, 1]],
    [[1, 1, 1], [1, 0, 0]],
    [[1, 1, 1], [0, 0, 1]],
    // T shapes
    [[1, 1, 1], [0, 1, 0]],
    [[0, 1, 0], [1, 1, 1]],
    [[1, 0], [1, 1], [1, 0]],
    [[0, 1], [1, 1], [0, 1]],
    // Diagonal (rare but fun)
    [[1, 0], [0, 1]],
    [[0, 1], [1, 0]],
  ];

  static BlockShape generateRandomShape() {
    final random = Random();
    final matrix = shapeTemplates[random.nextInt(shapeTemplates.length)];
    final color = blockColors[random.nextInt(blockColors.length)];
    return BlockShape(
      matrix: matrix,
      color: color,
      id: random.nextInt(1000000),
    );
  }
}
