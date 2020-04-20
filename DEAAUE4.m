clear;
pkg load io
W=[2;1;0.5;0.5;1];%weight for %scopus article weight%non scopus article weight%book chapter weight%Conference Proceeding%creative work weight
[num] = xlsread('AUE.xlsx','matlab');%Read data from Excel
Data=[num(1:4,:);W'*num(5:9,:);num(10,:)];

MEff=zeros(9,7,2,2); % 9 different scenarios with 7 DMUs
for i=1:3 %Chosen inputs and outputs to end up with 9 different scenarios
    for j=1:3
        if(i==1)
            CI=1; %first input
        elseif(i==2)
            CI=[1,2]; %first and second input
        elseif(i==3)
            CI=[1,3]; %first and third input
        end
        if(j==1)
            CO=[3+1,3+2]; %first and second output
        elseif(j==2)
            CO=[3+1,3+3]; %first and third output
        elseif(j==3)
            CO=[3+1,3+2,3+3]; %first, second and third output
        end
        InputD=Data(CI,:);
        Output=Data(CO,:);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        n=size(Output,2);%number of DMUs
        r=size(Output,1);% number of outputs
        m_D=size(InputD,1);%number of deterministic inputs
        Eff=zeros(n,3);
        
        A=[InputD,zeros(m_D,1)];
        A(m_D+1:m_D+r,:)=[-Output,zeros(r,1)];
        for VRS=0:1
            for O=0:1
                if(O==0)
                    lb=zeros(n+1,1);
                    ub=[Inf(n,1);1];
                elseif(O==1)
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
             ctype=repmat('U',[1,size(B,1)]);
             AA=A;
             BB=B;
            if(VRS==1)
                %Sum of lambdas equal one
                AA=[A;ones(1,n),0];
                BB=[B;1];
                ctype=strcat(ctype,'S');%adding inequality constrained
            end
                    f=[zeros(n,1);(-1)^O];%(-1)^O=1 for input oriented and (-1)^O=-1 for output oriented
                    [X,fval] = glpk(f,AA,BB,lb,ub,ctype);% X(n+1)=theta and X(i)=lambda_i
                    %disp(transpose(X));
                    clear AA BB
                    Eff(p,:)=[p,(1-O)*X(n+1)+O*1/X(n+1),X(p)];
                end
                
                MEff((1-O)*(3*(i-1)+j)+O*(3*(j-1)+i),:,VRS+1,O+1)=transpose(Eff(:,2));
                
            end
        end
        clearvars -except MEff Data i j
    end
end
%%%%%%% Write the results in Excel Sheet
C={"COBA","CCIT","CFAD","CEDU","CLAW","CMMC","CSGS"};
count=0;
ns=9; % 9 scenarios for each model 
for VRS=0:1 %% CRS and VRS model
    for O=0:1 %% Input and output orientation
        if(VRS==0)
            C(count+2,1)="CRS";
        elseif(VRS==1)
            C(count+2,1)="VRS";
        end
        if(O==0)
            C(count+2,2)="Input Oriented";
        elseif(O==1)
            C(count+2,2)="Output Oriented";
        end
        C(count+3:count+2+ns,:)=num2cell(MEff(:,:,VRS+1,O+1));
        count=count+3+ns;
    end
end
xlswrite('AUE.xlsx',C,'Reults','A1');
clearvars -except MEff Data
return