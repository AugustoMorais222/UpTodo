import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 3) {
    hex = hex.split('').map((c) => c + c).join();
  } else if (hex.length == 5) {
    hex = '0' + hex;
  }
  return Color(int.parse('FF$hex', radix: 16));
}
