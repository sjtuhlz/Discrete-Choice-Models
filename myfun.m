%this function returns the objective function and gradient function of GMM
%estimation in the first stage.
function [f, g] = myfun(theta)
global p x s mkt yita

beta = theta(1:4);
alpha = theta(5);
sigma = theta(6);

%Step 1: simulate individuals
%N = 10; %# of simulated individuals
%yita = normrnd(0,1,1,N);

%Step 2: utilty matrix of individual i consuming product j in market t
%(size JT*N)
%u = (x*beta + alpha*p)* ones(size(yita)) + sigma*x(:,1)*yita; //WRONG!!!
uf = x*beta + alpha*p;
uf = repmat(uf,1,length(yita));
u = uf + sigma*x(:,1)*yita;
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

% step 4: GMM objective function 
ksi = sp - s;
f = 0.5 .* ksi' * ksi;

% step 5: Gradient


%%get the four beta parameters done one by one, plus sigma 
dedb = zeros(length(p),length(theta));
%B = zeros(size(u));
for m = 1:(length(beta))
    ex = eu .* repmat(x(:,m),1,length(yita));
    nom = zeros(size(u)); %nom changes for each m iteration

    for i = 1:length(yita)
        for t = 1:T
            IX = mkt == t;
            nom(IX,i) = sum(ex(IX,i));
        end        
    end
    B = spi.* repmat(x(:,m),1,length(yita)) - spi.* nom./denom;
    dedb(:,m) = mean(B,2);
    if m == 1
        B = repmat(yita,length(p),1) .* B;
        dedb(:,length(theta)) = mean(B,2);
    end
end


%%get the alpha parameter done
ex = eu .* repmat(p,1,length(yita));
nom = zeros(size(u));
for i = 1:length(yita)
    for t = 1:T
        IX = mkt == t;
        nom(IX,i) = sum(ex(IX,i));
    end
end
B = spi.* repmat(p,1,length(yita)) - spi.* nom./denom;    
dedb(:,length(beta)+1) = mean(B,2);


% at last ....

g = dedb' * ksi;

end 

