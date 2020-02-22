train = train1;
test = test1;

test_1y = prod(test);

n = size(train,1); % number of training days
d = size(train,2); % number of stocks in the basket

b_k_1 = ones(d,1)*(1/d); % initial portfolio weight size: dx1
delta = 0.001; % learning rate
z = train*b_k_1;
W = mean(z-1-((z-1).^2)/2); % initial value of objective function
V_k_1 = W; % V(k-1)

flag = 1; % check when to stop training

tic
while flag==1 
    B_k_1 = kron(b_k_1,ones(1,d)); % duplicate the vector d times
    B = B_k_1 + delta * diag(ones(1,d));
    % projecting to delta_d 
    P = sum(B,1);
    for i=1:1:d
        B(:,i) = B(:,i)/P(i);
    end
    Z = train*B;
    W_d = mean(Z-1-(Z-1).^2/2,1);
    V_k = max(W_d); % find the largest within 10 different portfolio

    if V_k_1 < V_k % continue training 
        j = find(W_d == V_k); % find the first corresponding porfolio
        b_k_1 = B(:,j); % using this largest one as the new porfolio vector
        V_k_1 = V_k;
    else
        flag = 0;
        break;
    end
end
toc
g = test_1y * b_k_1

