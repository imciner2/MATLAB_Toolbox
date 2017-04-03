function cir = circle()

x = [-1:1/100:1];
y = sqrt( 1.^2 - x(1,:).^2 );

cir(1,:) = [x, x];
cir(2,:) = [y, -y];

end