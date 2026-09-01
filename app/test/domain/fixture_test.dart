import 'dart:convert';
import 'dart:io';

import 'package:court_piece/domain/fixture.dart';
import 'package:court_piece/domain/seat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = [
    (1, Seat.south, 'seed_1_south.json'),
    (2, Seat.west, 'seed_2_west.json'),
    (7, Seat.north, 'seed_7_north.json'),
  ];

  for (final (seed, dealer, name) in cases) {
    test('fixture $name matches the engine', () {
      final golden = jsonDecode(_file(name).readAsStringSync());
      expect(buildDealFixture(seed: seed, dealer: dealer), golden);
    });
  }
}

File _file(String name) {
  final cwd = Directory.current;
  final paths = [
    File('${cwd.path}/fixtures/$name'),
    File('${cwd.path}/../fixtures/$name'),
  ];
  return paths.firstWhere((file) => file.existsSync());
}
