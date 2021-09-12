w = [0.6
    0.6
    0.6 
    0.72 
    0.72];
sigma2 = [10000
          10000
          10000
          10000
          10000];
sigma = sqrt(sigma2);
%%
cvx_clear
cvx_begin quiet
    variable x(5,24) 
    expressions mu(24,1) sig(24,1) z(24,1)
    minimize(1.2.*sum(x(1,:)+x(2,:)+x(3,:))+sum(x(4,:)+x(5,:)))
    subject to
    x>=0;
    
    for j=1:24
        for i=1:5
            z(j)=z(j)+x(i,j)/w(i);
        end
        if(j==1)
            mu(j)=z(j)-28200;
        else
            mu(j)=mu(j-1)+z(j)-28200;
        end
    end
    sig=zeros(24,1);
    for j=1:24
        sig(j)=j.*sum(sigma./w);
    end
    mu-1.6*sig>=0
    
cvx_end