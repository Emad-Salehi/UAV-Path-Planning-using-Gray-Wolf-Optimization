function fxy = Rosenbrock(X)
x = X(1);
y = X(2);
fxy=((1-x).^2)+(100*((y-(x.^2)).^2));
return;
end