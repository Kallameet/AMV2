vunit vSimpleBus(SimpleBus(Bhv)) {
  default clock is ( clk'event and clk = '1');
  
  property req is always (request -> next_e[1:5](grant or abort_));
  assert req;

  property gr is always (grant -> next_a[8](data_valid));
  assert gr;
}