% This program computes the random coefficeints discrete choice model described 

global invA ns x1 x2 s_jt IV vfull dfull theta1 theti thetj cdid cdindex

% load data. see description in readme.txt
load ps2
load iv
IV = [iv(:,2:21) x1(:,2:25)];
clear iv

ns = 20;       % number of simulated "indviduals" per market %
nmkt = 94;     % number of markets = (# of cities)*(# of quarters)  %
nbrn = 24;     % number of brands per market. if the numebr differs by market% 
               % this requires some "accounting" vector %
% this vector relates each observation to the market it is in %
cdid = kron([1:nmkt]',ones(nbrn,1));    
% this vector provides for each index the of the last observation %
% in the data used here all brands appear in all markets. if this %
% is not the case the two vectors, cdid and cdindex, have to be   % 
% created in a different fashion but the rest of the program works fine.%
cdindex = [nbrn:nbrn:nbrn*nmkt]';       


% starting values. zero elements in the following matrix correspond to %
% coeff that will not be max over,i.e are fixed at zero. % 
%theta2w=    [0.3302   5.4819         0    0.2037         0;
%             2.4526  15.8935    -1.2000        0    2.6342;
%             0.0163  -0.2506         0    0.0511         0;
%             0.2441   1.2650         0   -0.8091         0];
         
theta2w=    [0.3772    3.0888         0    1.1859         0;
             1.8480   16.5980    -.6590         0   11.6245;
            -0.0035   -0.1925         0    0.0296         0;
             0.0810    1.4684         0   -1.5143         0];
    
% create a vector of the non-zero elements in the above matrix, and the %
% corresponding row and column indices. this facilitates passing values % 
% to the functions below. %
[theti, thetj, theta2]=find(theta2w);
          
horz=['    mean       sigma      income   income^2    age    child'];
vert=['constant  ';
      'price     ';
          'sugar     ';
          'mushy     '];

% create weight matrix
invA = inv([IV'*IV]);

% Logit results and save the mean utility as initial values for the search below

% compute the outside good market share by market
temp = cumsum(s_jt);
sum1 = temp(cdindex,:);
sum1(2:size(sum1,1),:) = diff(sum1);
outshr = 1.0 - sum1(cdid,:);

y = log(s_jt) - log(outshr);
mid = x1'*IV*invA*IV';
t = inv(mid*x1)*mid*y; % IV of log shares on X1 using IV as instruments
mvalold = x1*t;        % Fitted log shares
oldt2 = zeros(size(theta2)); % Zero out old theta2
mvalold = exp(mvalold);  % Compute shares

save mvalold mvalold oldt2
clear mid y outshr t oldt2 mvalold temp sum1

vfull = v(cdid,:);
dfull = demogr(cdid,:);

options = optimset('GradObj','on','TolFun',0.1,'TolX',0.01)

tic % Start stopwatch

% the following line computes the estimates using a Quasi-Newton method % 
% with an *analytic* gradient %
%[theta2, options] = fminu('gmmobjg',theta2,options,'gradobj')
[theta2,fval,exitflag,output] = fminunc('gmmobjg',theta2,options)

% the following line computes the estimates using a simplex search method
%theta2 = fmins('gmmobjg',theta2)

comp_t = toc/60;  % Stop stopwatch and record time

% computing the s.e.
vcov = var_cov(theta2);
se = sqrt(diag(vcov));

theta2w = full(sparse(theti,thetj,theta2));
t = size(se,1) - size(theta2,1);
se2w = full(sparse(theti,thetj,se(t+1:size(se,1))));

% the MD estimates
omega = inv(vcov(2:25,2:25));
xmd = [x2(1:24,1) x2(1:24,3:4)];
ymd = theta1(2:25);

beta = inv(xmd'*omega*xmd)*xmd'*omega*ymd;
resmd = ymd - xmd*beta;
semd = sqrt(diag(inv(xmd'*omega*xmd)));
mcoef = [beta(1); theta1(1); beta(2:3)];
semcoef = [semd(1); se(1); semd];

Rsq = 1-((resmd-mean(resmd))'*(resmd-mean(resmd)))/((ymd-mean(ymd))'*(ymd-mean(ymd)));
Rsq_G = 1-(resmd'*omega*resmd)/((ymd-mean(ymd))'*omega*(ymd-mean(ymd)));
Chisq = size(id,1)*resmd'*omega*resmd;

diary results
disp(horz)
disp('  ')
for i=1:size(theta2w,1)
     disp(vert(i,:))
     disp([mcoef(i) theta2w(i,:)])
     disp([semcoef(i) se2w(i,:)])
end

disp(output)
disp(['GMM objective:  ' num2str(fval)])
disp(['MD R-squared:  ' num2str(Rsq)])
disp(['MD weighted R-squared:  ' num2str(Rsq_G)])
disp(['run time (minutes):  ' num2str(comp_t)])
diary off
