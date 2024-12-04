package Random
  import Modelica.Math;   // import might not be needed
  constant Real NV_MAGICCONST=4*exp(-0.5)/sqrt(2.0);
  type Seed = Real[3];
  connector EventPort
    Boolean signal;
  end EventPort;

  //Modelica.Math.Random.random
  //Uniform distribution random function
  //Distribution uniform between 0 and 1.

  function random "input random number generator with external storage of the seed"
  input Seed si "input random seed";
  output Real x "uniform random variate between 0 and 1";
  output Seed so "output random seed";
algorithm
  so[1] := abs(rem((171 * si[1]),30269));
  so[2] := abs(rem((172 * si[2]),30307));
  so[3] := abs(rem((170 * si[3]),30323));
// zero is a poor Seed, therfore substitute 1;
  if so[1] == 0 then
    so[1] := 1;
  end if;
  if so[2] == 0 then
    so[2] := 1;
  end if;
  if so[3] == 0 then
    so[3] := 1;
  end if;
  x := rem((so[1]/30269.0 +so[2]/30307.0 +
  so[3]/30323.0),1.0);
end random;

function exponential
  input Real lambda;
  input Seed si;
  output Real x;
  output Seed so;
protected
  Real prob;
algorithm
  (prob,so):=random(si);
  x:=-log(1-prob)/lambda;
  if x<1 then
    x:=1;
  end if;
end exponential;

  //Modelica.Math.Random.normalvariate
  // Normal distribution random function

  function normalvariate "normally distributed random variable"
  input Real mu "mean value";
  input Real sigma "standard deviation";
  input Seed si "input random seed";
  output Real x "gaussian random variate";
  output Seed so "output random seed";
  protected
    Seed s1, s2;
    Real z, zz, u1, u2;
    Boolean breakv=false;
  algorithm
  s1 := si;
  u2 := 1;
  while not breakv loop
    (u1,s2) := random(s1);
    (u2,s1) := random(s2);
    z := NV_MAGICCONST*(u1-0.5)/u2;
    zz := z*z/4.0;
    breakv := zz <= (- Math.log(u2));
  end while;
  x := mu + z*sigma;
  so := s1;
end normalvariate;

end Random;
