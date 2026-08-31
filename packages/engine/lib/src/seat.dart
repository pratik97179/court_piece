enum Seat {
  north,
  east,
  south,
  west;

  /// Next seat in counter-clockwise order.
  Seat get next => switch (this) {
    Seat.north => Seat.west,
    Seat.west => Seat.south,
    Seat.south => Seat.east,
    Seat.east => Seat.north,
  };

  Seat get partner => switch (this) {
    Seat.north => Seat.south,
    Seat.south => Seat.north,
    Seat.east => Seat.west,
    Seat.west => Seat.east,
  };

  Team get team => switch (this) {
    Seat.north || Seat.south => Team.northSouth,
    Seat.east || Seat.west => Team.eastWest,
  };
}

enum Team { northSouth, eastWest }

extension TeamX on Team {
  Team get opponent => switch (this) {
    Team.northSouth => Team.eastWest,
    Team.eastWest => Team.northSouth,
  };
}
