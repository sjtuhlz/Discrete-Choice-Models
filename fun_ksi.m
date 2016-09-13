function ksi = fun_ksi(theta)

global p x s mkt yita

beta = theta(1:4);
alpha = theta(5);
sigma = theta(6);


%Step 2: utilty matrix of individual i consuming product j in market t
%(size JT*N)
uf = x*beta + alpha*p;
uf = repmat(uf,1,length(yita));
u = uf + sigma*x(:,1)*yita;
%u = (x*beta + alpha*p)* ones(size(yita)) + sigma*x(:,1)*yita;
eu = exp(u);

%Step 3: market share predicted
T = length(unique(mkt));
denom = zeros(size(u));

for i = 1:length(yita)
    for t = 1:T
        IX = mkt == t;
        denom(IX,i) = sum(eu(IX,i))+1;
    end
end


spi = eu ./ denom; %predicted share of each individual
sp = mean(spi,2); % predicted share averaged across individuals

% step 4: first-stage error term
ksi = sp - s;




end