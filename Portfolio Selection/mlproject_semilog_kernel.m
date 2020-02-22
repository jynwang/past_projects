train_initial = train1;
test = test1;


n = size(train_initial,1); % number of training days
d = size(train_initial,2); % number of stocks in the basket
delta = 0.01; % learning rate

K = zeros(252,1);

G = zeros(5,10);
test_1y = prod(test);

for k = 50:50:250
    k
    for l = 1:1:10
        l 
        r_2 = 0.0008*d*k*(1+l/10);
        r = sqrt(r_2);

        % new series
        D = zeros(1,n-k-1);
        for i=1:n-k-1
        D(i) = norm(train_initial(k+i-k:1:k+i-1,:)-train_initial(n-k:1:n-1,:));
        end
        index_new = find(D<=r) + k;
        train = train_initial(index_new,:);
        size(train)
        
        b_k_1 = ones(d,1)*(1/d); % initial portfolio weight size: dx1
        z = train*b_k_1;
        W = mean(z-1-((z-1).^2)/2); % initial value of objective function
        V_k_1 = W; % V(k-1)

        flag = 1; % check when to stop training

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
        K = K + test1*b_k_1;
        G(k/50,l)=test_1y * b_k_1;
    end
end
G'
mean2(G)
plot(K/50)


