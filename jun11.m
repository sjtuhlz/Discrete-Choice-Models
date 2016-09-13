% June 11, 2013 Empirical IO homework
% use zone*week as market 

clear
A = importdata('finaldata_zone_IV.txt');

% A is a structure file


global p s x mkt IV prod
p = A.data(:,1);  %price
%rescale to help nonlinear optimization
p = 10*p;
s = A.data(:,2);  %share
x = A.data(:,3:6); %product characteristics
mkt = A.data(:,8);  % market id
IV = A.data(:,9:12);
prod = A.data(:,7); %product id

%simulate individuals
N = 2;
global yita 
%yita = normrnd(0,1,1,N);


% Different draws of consumers across markets
%Although consumer taste changes more across geographic stores/zones than
%across time
T = length(unique(mkt));
yita = zeros(T,N);
for t = 1:T
    yita(t,:) = normrnd(0,1,1,N);

end




%R = 10;
%result = zeros(R,6);
%for r = 1:R
options = optimset('GradObj','on');
theta0 = [1,1,1,1,-1,0.5]';
%theta1 = fminunc(@myfun,theta0,options);

lb = [-Inf -Inf -Inf -Inf -Inf 0]';
ub = [Inf Inf Inf Inf Inf Inf]';
%Aeq = [];
%Beq = [];
%A = zeros(1,6);
%A(6) = -1;
%b = 0;
%theta1 = fmincon(@myfun,theta0,A,b,[],[],[],[],[],options);
theta1= fmincon(@myfun,theta0,[],[],[],[],lb,ub,[],options);
%result(r,:) = theta;
%end







%Stage 2
ksi = fun_ksi(theta1);
z = [x IV];
global omg
omg = z'* ksi * ksi' *z;

options = optimset('GradObj','on');
lb = [-Inf -Inf -Inf -Inf -Inf 0]';
ub = [Inf Inf Inf Inf Inf Inf]';
theta0 = [1,1,1,1,-1,1]';
theta2= fmincon(@myfun2,theta0,[],[],[],[],lb,ub,[],options);
%theta2 = fminunc(@myfun2,theta0,options);












