enum Team { northSouth, eastWest }

/// Table seat. [next] is counter-clockwise. Hakem is the dealer's [next].
enum Seat {
  north,
  east,
  south,
  west;

  Team get team => switch (this) {
    north || south => Team.northSouth,
    east || west => Team.eastWest,
  };

  Seat get next => switch (this) {
    south => east,
    east => north,
    north => west,
    west => south,
  };
}

/// Losing team deals so the winners keep the hakem seat.
Seat nextDealer(Seat previous, Team losers) {
  var seat = previous.next;
  while (seat.team != losers) {
    seat = seat.next;
  }
  return seat;
}
