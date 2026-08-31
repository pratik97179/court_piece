/// Table seat. [next] is counter-clockwise. Hakem is the dealer's [next].
enum Seat {
  north,
  east,
  south,
  west;

  Seat get next => switch (this) {
    south => east,
    east => north,
    north => west,
    west => south,
  };
}
