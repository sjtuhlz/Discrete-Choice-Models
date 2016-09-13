% June 9, 2013 Empirical IO homework

clear
A = importdata('finaldata_IV.txt');

% A is a structure file


global p s x mkt IV prod
p = A.data(:,1);  %price
s = A.data(:,2);  %share
x = A.data(:,3:6); %product characteristics
mkt = A.data(:,7);  % market id
IV = A.data(:,8:11);
prod = A.data(:,12); %product id



options = optimset('GradObj','on');
theta0 = [1,1,1,1,-1,1]';
theta = fminunc(@myfun,theta0,options);







