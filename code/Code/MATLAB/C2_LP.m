sid = [395,307,348 ,37,374];
label = ['A','A','A','C','C'];
a = [615.6117,-113.4732,-118.9772,499.6312,6.1530];
b = [0.4435,0.7758,0.5570,0.4257,0.9999];
sigma2 = [2.392131735926776e+06
          8.086703026848155e+06
          1.837298462059566e+07
          1.015018477538245e+06
          1.055334289371967e+01];
sigma = sqrt(sigma2);
%%
cvx_clear
cvx_begin quiet
    variable x(5,24) 
    expression p(24,1)
    minimize(1.2.*sum(x(1,:)+x(2,:)+x(3,:))+sum(x(4,:)+x(5,:)))
    subject to
    x>=0;
    x<=6000;
    for j=1:24
        for i=1:3
            p(j)=p(j)+(b(i)*x(i,j)+a(i))/0.6;
        end
        for i=4:5
            p(j)=p(j)+(b(i)*x(i,j)+a(i))/0.72;
        end
    end

    p>=28200;
    
cvx_end