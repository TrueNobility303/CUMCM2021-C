label='BACBACACBBCACAAAABBCAACBCAABBABCCCABCACBCAACBABBABAAABBABBCCCACAAACCBCAABCACBABCBAACCCABACABACBAABACAACABACBACBBCAAABBABAAABBCAACABACBCCBBBBBBAAABBACACABAAAAAACCCACABABBACBCBBBCABBACCAACABABBCBCAABABBABAAACCAACACCBBBACACABCBBAACABCBBCBCABCBCAACCCCBBAACCAABCBBBBCCBAACCACCBAAABCACBAAACABBAACAAACAACBAACABACCABABBACCBBAABCBBABCCBBABCABCBAABCBACCBCBCACACABACCCBCBCCABCBBCCABAACBBCBCCACCCBBBBBBCBBAAABCBBBB';
w=zeros(402,1);
w(label=='A')=0.6;
w(label=='B')=0.66;
w(label=='C')=0.72;
sigma=100*ones(402,1);

aindex=find(label=='A');
bindex=find(label=='B');
cindex=find(label=='C');


load 'upbound_new.txt'

upbound=upbound_new(:,1)*ones(1,24);
sigma=upbound_new(:,2);
sig=zeros(24,1);
for j=1:24
    sig(j)=j.*sum(sigma./w);
end
sig=sig+158.0332; % r.sd in R files 'C3_preprocess'
%%
bound=76400; % solved
%bound=76500; % infeasible
cvx_clear
cvx_begin
    variable x(402,24) 
    expressions mu(24,1) sig(24,1) z(24,1)
    sa=sum(x(aindex,:));sb=sum(x(bindex,:));sc=sum(x(cindex,:));
    minimize(1.2*sum(sa)+1.1*sum(sb)+sum(sc)+0.2*norm(sc,1)+0.1*norm(sb,1))
    %minimize(1.2*sum(sa)+1.1*sum(sb)+sum(sc))
    subject to
    x>=0;
    x<=upbound;
    sum(x)<=6000*8;
    for j=1:24
        for i=1:402
            z(j)=z(j)+x(i,j)/w(i);
        end
        if(j==1)
            mu(j)=z(j)-bound;
        else
            mu(j)=mu(j-1)+z(j)-bound;
        end
    end
    
    mu-1.6*sig>=0
    
cvx_end