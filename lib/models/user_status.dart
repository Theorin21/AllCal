class UserStatus {
  // 체력, 스트레스, 자본, 여유시간 (0.0 ~ 200.0)
  double health;
  double stress;
  double capital;
  double freeTime;

  UserStatus({
    this.health = 100.0,
    this.stress = 100.0,
    this.capital = 100.0,
    this.freeTime = 100.0,
  });
}