function [Z] = dnemo_dist(W, P)
%% dist function, identical to native matlab operation
% 
%  INPUT:
%  . W -- S x R weight matrix
%  . P -- R x Q matrix of Q input (column) vectors
%
%  OUTPUT:
%  . Z -- S x Q matrix of vector distances
%

S = size(W, 1);
Q = size(P, 2);
Z = zeros(S, Q);

if Q < S
    P = P';
    dup = zeros(1, S);
    for qq=1:Q
        Z(:,qq) = sum((W - P(Q+dup, :)).^2, 2);
    end
else
    W = W';
    dup = zeros(1, Q);
    for ss=1:S
        Z(ss,:) = sum((W(:, ss+dup)-P).^2, 1);
    end
end
Z = sqrt(Z);


%
%%%
%%%%%
%%%
%