clear;
%%%%%%%%%%%%%%%%%%%%%%Given
W=[2;1;0.5;0.5;1];%weight for %scopus article weight%non scopus article weight%book chapter weight%Conference Proceeding%creative work weight
C=["COBA","CCIT","CFAD","CEDU","CLAW","CMMC","CSGS"];
Data=[42,6,12,21,21,9,6; %Faculty members
    2,3,2,2,1,1,2; %adminstrative assisstant
    1873,456,496,39,1037,1171,362; %Enrolled Student
    0.7852,0.6154,0.7838,0.75,0.5965,0.7297,0.4615;%Retention rate
    1,2,4,1,1,2,1; %nu. undergraduate
    2,2,0,0,4,0,3; %nu. postgraduate
    137,21,38,0,56,82,3;
    %1292,161,154,0,660,363,9; %Bachelor degree
    32,0,0,0,35,0,37;
    %441,21,0,0,102,222,14; %master degree
    [22,22,19,20,0]*W,[12,4,0,8,1]*W,[0,0,0,2,5]*W,[0,6,0,3,2]*W,[0,19,2,6,2]*W,[0,4,5,1,0]*W,[0,1,1,5,0]*W; %papers
    138+46,9+14,35,17,15+17,24+20,2+3];%Guest Speakers and Field visits


%Chosen inputs and outputs
InputD=Data(1:2:3,:);
Output=[Data(7,:)+Data(8,:);Data(9:10,:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ID=fopen('result.doc','a');%the results will be written in this file
n=size(Output,2);%number of DMUs
r=size(Output,1);% number of outputs
m_D=size(InputD,1);%number of deterministic inputs
Eff=zeros(n,3);

A=[InputD,zeros(m_D,1)];
A(m_D+1:m_D+r,:)=[-Output,zeros(r,1)];
for VRS=0:1
    if(VRS==0)
        fprintf(ID,'CRS\n');
        Aeq=[];
        Beq=[];
    elseif(VRS==1)
        fprintf(ID,'VRS\n');
        %Sum of lambdas equal one
        Aeq=[ones(1,n),0];
        Beq=1;
    end
    
    for O=0:1
        if(O==0)
            fprintf(ID,'Input Oriented Model\n');
            lb=zeros(n+1,1);
            ub=[Inf(n,1);1];
        elseif(O==1)
            fprintf(ID,'Output Oriented Model\n');
            lb=[zeros(n,1);1];%theta\geq 1
            ub=Inf(n+1,1);
        end
        for p=1:n
            A(:,n+1)=zeros(m_D+r,1);
            if(O==0)
                A(:,n+1)=[-InputD(:,p);zeros(r,1)];
                B(:,1)=[zeros(m_D,1);-Output(:,p)];
            elseif(O==1)
                A(:,n+1)=[zeros(m_D,1);Output(:,p)];
                B(:,1)=[InputD(:,p);zeros(r,1)];
            end
            f=[zeros(n,1);(-1)^O];%(-1)^O=1 for input oriented and (-1)^O=-1 for output oriented
            [X,fval] = linprog(f,A,B,Aeq,Beq,lb,ub);% X(n+1)=theta and X(i)=lambda_i
            %disp(transpose(X));
            if(O==0)
                Eff(p,:)=[p,X(n+1),X(p)];
            elseif(O==1)
                Eff(p,:)=[p,1/X(n+1),X(p)];
            end
        end
        for p=1:n
            fprintf(ID,'%s,p=%i, theta =%1.3f,lambda=%1.3f\n',C(p),Eff(p,:));
            fprintf(ID,'\n');
        end
    end
end
fclose(ID);