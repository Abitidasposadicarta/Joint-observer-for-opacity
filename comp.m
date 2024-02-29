clear
clc

% G=[1,1,2;
%     1,3,4;
%     2,1,2;
%     2,2,1;
%     2,4,5;
%     3,1,1;
%     4,1,1;
%     4,2,3;
%     5,2,1]; % the automaton
% eint=[1,2]; % intruder observable events
% eope=[1,2,3]; % operator observable events
% s=[3,5]; % secret states
% eera=1; % eraseable ebents
% eins=1; % insertable events
% e=['a','b','c','d']; % events name

% G=[1,1,2;
%     1,2,3;
%     2,1,2;
%     2,2,1;
%     3,1,1]; % the automaton
% eint=[1,2]; % intruder observable events
% eope=[1,2]; % operator observable events
% s=[3]; % secret states
% eera=[1]; % eraseable events
% eins=[1]; % insertable events
% e=['a','b']; % events name
% sta=['q0';'q1';'q2'];

% G=[1,1,2;
%     1,3,4;
%     2,1,2;
%     2,2,1;
%     3,1,1;
%     4,2,3]; % the automaton
% eint=[1,2]; % intruder observable events
% eope=[1,2,3]; % operator observable events
% s=3; % secret states
% eera=1; % eraseable ebents
% eins=1; % insertable events
% e=['a','b','c']; % events name
% sta=['q0','q1','q2','q3']; % states name

% G=[1,1,2;
%     1,3,4;
%     2,1,3;
%     2,2,4;
%     3,1,3;
%     4,1,4];
% eint=[1,2,3];
% eope=[1,2,3];
% s=3;
% eera=[];
% eins=3;
% e=['a','b','c'];
% sta=['q0';'q1';'q2';'q3'];

G=[1,1,2;
    1,2,2;
    1,4,3;
    2,3,2;
    3,1,4;
    3,4,5;
    4,3,4;
    5,2,6;
    6,3,6];
eint=[1,2,3,4];
eope=[1,2,3,4];
s=2;
eera=[];
eins=4;
e=['a','b','c','e'];
sta=['q0';'q1';'q2';'q3';'q4';'q5'];

enum=max(G(:,2));
snum=max(max(G(:,1)),max(G(:,3)));
b=0;
Gcount=[];
for a=1:snum
    b=1;
    for i=1:size(G,1)
        if G(i,1)==a && b==1
            Gcount=[Gcount,i];
            b=0;
        elseif G(i,1)>a && b==1
            Gcount=[Gcount,i];
            b=0;
        elseif G(i,1)>a && b==0
            break
        end
    end
end
Gcount=[Gcount,size(G,1)+1];
Eint=zeros(1,enum);
for a=1:length(eint)
    Eint(eint(a))=1;
end
Eope=zeros(1,enum);
for a=1:length(eope)
    Eope(eope(a))=1;
end
Eera=zeros(1,enum);
for a=1:length(eera)
    Eera(eera(a))=1;
end
Eins=zeros(1,enum);
for a=1:length(eins)
    Eins(eins(a))=1;
end
S=zeros(1,snum);
for a=1:length(s)
    S(s(a))=1;
end
Gmat=-ones(snum,enum);
for a=1:size(G,1)
    Gmat(G(a,1),G(a,2))=G(a,3)-1;
end
len=4;
disp('the original plant is:')
for a=1:snum+1
    for i=1:enum+1
        if a==1 && i==1
            fprintf('s/e');
            for j=1:len-3
                fprintf(' ');
            end
        elseif a==1
            fprintf(e(i-1));
            for j=1:len-1
                fprintf(' ');
            end
        elseif i==1
            for j=1:size(sta,2)
                fprintf(sta(a-1,j));
            end
            for j=1:len-size(sta,2)
                fprintf(' ');
            end
        else
            p=num2str(Gmat(a-1,i-1));
            fprintf(p);
            for j=1:len-length(p)
                fprintf(' ');
            end
        end
    end
    disp(' ');
end
disp([' ']);

% operation model
ope=[1,zeros(1,snum-1)];
while 1
    for a=1:snum
        if ope(a)==1
            ope(a)=2;
            for i=Gcount(a):Gcount(a+1)-1
                if Eope(G(a,2))==0 && ope(G(a,3))==0
                    ope(G(a,3))=1;
                end
            end
        end
    end
    if ope~=1
        ope=ope/2;
        break
    end
end
Aope=[];
Ocount=1;
a=1;
while a<=size(ope,1)
    for i=1:enum
        if Eope(i)==0
            continue
        end
        cbuf=zeros(1,snum);
        for j=1:snum
            if ope(a,j)==1
                for k=Gcount(j):Gcount(j+1)-1
                    if G(k,2)==i
                        cbuf(G(k,3))=1;
                        break
                    end
                end
            end
        end
        if cbuf==0
            continue
        end
        while 1
            for j=1:snum
                if cbuf(j)==1
                    cbuf(j)=2;
                    for k=Gcount(j):Gcount(j+1)-1
                        if Eope(G(k,2))==0 && cbuf(G(k,3))==0
                            cbuf(G(k,3))=1;
                        end
                    end
                end
            end
            if cbuf~=1
                cbuf=cbuf/2;
                break
            end
        end
        for j=1:size(ope,1)
            if cbuf==ope(j,:)
                Aope=[Aope;a,i,j];
                b=1;
                break
            end
        end
        if b==1
            b=0;
        else
            ope=[ope;cbuf];
            Aope=[Aope;a,i,size(ope,1)];
        end
    end
    a=a+1;
    Ocount=[Ocount;size(Aope,1)+1];
end
Omat=-ones(size(ope,1),length(eope)+length(eera)+length(eins));
for a=1:size(Aope,1)
    Omat(Aope(a,1),Aope(a,2))=Aope(a,3)-1;
    if Eera(Aope(a,2))==1
        for i=1:length(eera)
            if eera(i)==Aope(a,2)
                Omat(Aope(a,1),length(eope)+i)=Aope(a,3)-1;
                break
            end
        end
    end
end
for a=1:size(ope,1)
    for i=1:length(eins)
        Omat(a,length(eope)+length(eera)+i)=a-1;
    end
end
disp('the opeator model is:')
for a=1:size(ope,1)+1
    for i=1:enum+length(eera)+length(eins)+1
        if a==1
            if i==1
                fprintf('s/e');
                for j=1:len-3
                    fprintf(' ');
                end
            elseif i>1 && i<=1+enum
                fprintf(e(i-1));
                for j=1:len-1
                    fprintf(' ');
                end
            elseif i>1+enum && i<=1+enum+length(eera)
                fprintf(e(eera(i-1-enum)));
                fprintf('-');
                for j=1:len-2
                    fprintf(' ');
                end
            elseif i>1+enum+length(eera) && i<=enum+length(eera)+length(eins)+1
                fprintf(e(eins(i-1-enum-length(eera))));
                fprintf('+');
                for j=1:len-2
                    fprintf(' ');
                end
            end
        else
            if i==1
                p=num2str(a-2);
                fprintf(p);
                for j=1:len-length(p)
                    fprintf(' ');
                end
            else
                p=num2str(Omat(a-1,i-1));
                fprintf(p);
                for j=1:len-length(p)
                    fprintf(' ');
                end
            end
        end
    end
    if a==1
        fprintf('estimation');
    else
        fprintf('{');
        for i=1:snum
            if ope(a-1,i)==1
                for j=1:size(sta,2)
                    fprintf(sta(i,j));
                end
                if i==snum
                    break
                elseif ope(a-1,i+1:snum)==0
                    break
                else
                    fprintf(',');
                end
            end
        end
        fprintf('}');
    end
    disp(' ');
end
disp([' ']);

% intruder model
int=[1,zeros(1,snum-1)];
while 1
    for a=1:snum
        if int(a)==1
            int(a)=2;
            for i=Gcount(a):Gcount(a+1)-1
                if Eint(G(i,2))==0 && int(G(i,3))==0
                    int(G(i,3))=1;
                end
            end
        end
    end
    if int~=1
        int=int/2;
        break
    end
end
Aint=[];
Icount=1;
a=1;
while a<=size(int,1)
    if int(a,:)==0
        Icount=[Icount,size(Aint,1)+1];
        a=a+1;
        continue
    end
    for i=1:enum
        if Eint(i)==0
            continue
        end
        cbuf=zeros(1,snum);
        for j=1:snum
            if int(a,j)==1
                for k=Gcount(j):Gcount(j+1)-1
                    if G(k,2)==i
                        cbuf(G(k,3))=1;
                        break
                    end
                end
            end
        end
        while 1
            for j=1:snum
                if cbuf(j)==1
                    cbuf(j)=2;
                    for k=Gcount(j):Gcount(j+1)-1
                        if Eint(G(k,2))==0 && cbuf(G(k,3))==0
                            cbuf(G(k,3))=1;
                        end
                    end
                end
            end
            if cbuf~=1
                cbuf=cbuf/2;
                break
            end
        end
        for j=1:size(int,1)
            if cbuf==int(j,:)
                Aint=[Aint;a,i,j];
                b=1;
                break
            end
        end
        if b==1
            b=0;
        else
            int=[int;cbuf];
            Aint=[Aint;a,i,size(int,1)];
        end
    end
    a=a+1;
    Icount=[Icount,size(Aint,1)+1];
end
Imat=-ones(size(int,1),length(eint)+length(eera)+length(eins));
for a=1:size(Aint,1)
    Imat(Aint(a,1),Aint(a,2))=Aint(a,3)-1;
    if Eins(Aint(a,2))==1
        for i=1:length(eins)
            if eins(i)==Aint(a,2)
                Imat(Aint(a,1),length(eint)+length(eera)+i)=Aint(a,3)-1;
            end
        end
    end
end
for a=1:size(int,1)
    if int(a,:)==0
        continue
    end
    for i=1:length(eera)
        Imat(a,i+length(eint))=a-1;
    end
end
disp('the intruder model is:')
for a=1:size(int,1)+1
    for i=1:1+enum+length(eera)+length(eins)
        if a==1
            if i==1
                fprintf('s/e');
                for j=1:len-3
                    fprintf(' ');
                end
            elseif i>1 && i<=1+enum
                fprintf(e(i-1));
                for j=1:len-1
                    fprintf(' ');
                end
            elseif i>1+enum && i<=1+enum+length(eera)
                fprintf(e(eera(i-1-enum)));
                fprintf('-');
                for j=1:len-2
                    fprintf(' ');
                end
            else
                fprintf(e(eins(i-1-enum-length(eera))));
                fprintf('+');
                for j=1:len-2
                    fprintf(' ');
                end
            end
        else
            if i==1
                p=num2str(a-2);
                fprintf(p);
                for j=1:len-length(p)
                    fprintf(' ');
                end
            else
                p=num2str(Imat(a-1,i-1));
                fprintf(p);
                for j=1:len-length(p)
                    fprintf(' ');
                end
            end
        end
    end
    if a==1
        fprintf('estimation');
    elseif int(a-1,:)==0
        fprintf('dump');
    else
        fprintf('{');
        for i=1:snum
            if int(a-1,i)==1
                for j=1:size(sta,2)
                    fprintf(sta(i,j));
                end
                if i==snum
                    break
                elseif int(a-1,i+1:snum)==0
                    break
                else
                    fprintf(',');
                end
            end
        end
        fprintf('}');
    end
    disp(' ');
end
disp([' ']);

% composive observer
co=[1,1];
Aco=[];
Ccount=1;
a=1;
while a<=size(co,1)
    if int(co(a,2),:)==0
        a=a+1;
        continue
    end
    for i=1:enum
        if Eope(i)==0
            continue
        end
        if Eint(i)==0
            cbuf=[0,co(a,2)];
            for j=Ocount(co(a,1)):Ocount(co(a,1)+1)-1
                if Aope(j,2)==i
                    cbuf(1)=Aope(j,3);
                    break
                end
            end
            if cbuf(1)==0
                continue
            end
            for j=1:size(co,1)
                if cbuf==co(j,:)
                    Aco=[Aco;a,i,j];
                    b=1;
                    break
                end
            end
            if b==1
                b=0;
            else
                co=[co;cbuf];
                Aco=[Aco;a,i,size(co,1)];
            end
        else
            cbuf=[0,0];
            for j=Ocount(co(a,1)):Ocount(co(a,1)+1)-1
                if Aope(j,2)==i
                    cbuf(1)=Aope(j,3);
                    break
                end
            end
            for j=Icount(co(a,2)):Icount(co(a,2)+1)-1
                if Aint(j,2)==i
                    cbuf(2)=Aint(j,3);
                    break
                end
            end   
            if Eins(i)==1
                cs=[co(a,1),cbuf(2)];
                for j=1:size(co,1)
                    if cs==co(j,:)
                        Aco=[Aco;a,i*100,j];
                        b=1;
                        break
                    end
                end
                if b==1
                    b=0;
                else
                    co=[co;cs];
                    Aco=[Aco;a,i*100,size(co,1)];
                end
            end    
            if cbuf(1)==0
                continue
            end     
            for j=1:size(co,1)
                if cbuf==co(j,:)
                    Aco=[Aco;a,i,j];
                    b=1;
                    break
                end
            end
            if b==1
                b=0;
            else
                co=[co;cbuf];
                Aco=[Aco;a,i,size(co,1)];
            end
            if Eera(i)==1
                cs=[cbuf(1),co(a,2)];
                for j=1:size(co,1)
                    if cs==co(j,:)
                        Aco=[Aco;a,i*10,j];
                        b=1;
                        break
                    end
                end
                if b==1
                    b=0;
                else
                    co=[co;cs];
                    Aco=[Aco;a,i*10,size(co,1)];
                end
            end
        end
    end
    a=a+1;
    Ccount=[Ccount;size(Aco,1)+1];
end
Cmat=-ones(size(co,1),enum*100);
for a=1:size(Aco,1)
    Cmat(Aco(a,1),Aco(a,2))=Aco(a,3)-1;
end
Cmat1=[];
for a=1:length(eope)
    Cmat1=[Cmat1,Cmat(:,a)];
end
for a=1:length(eera)
    Cmat1=[Cmat1,Cmat(:,eera(a)*10)];
end
for a=1:length(eins)
    Cmat1=[Cmat1,Cmat(:,eins(a)*100)];
end
disp('the joint observer is:')
for a=1:size(co,1)+1
    for i=1:1+enum+length(eera)+length(eins)
        if a==1
            if i==1
                fprintf('s/e');
                for j=1:len-3
                    fprintf(' ');
                end
            elseif i>1 && i<=1+enum
                fprintf(e((i-1)));
                for j=1:len-1
                    fprintf(' ');
                end
            elseif i>1+enum && i<=1+enum+length(eera)
                fprintf(e(eera(i-1-enum)));
                fprintf('-');
                for j=1:len-2
                    fprintf(' ');
                end
            else
                fprintf(e(eins(i-1-enum-length(eera))));
                fprintf('+');
                for j=1:len-2
                    fprintf(' ');
                end
            end
        else
            if i==1
                p=num2str(a-2);
                fprintf(p);
                for j=1:len-length(p)
                    fprintf(' ');
                end
            else
                p=num2str(Cmat1(a-1,i-1));
                fprintf(p);
                for j=1:len-length(p)
                    fprintf(' ');
                end
            end
        end
    end
    if a==1
        fprintf('state information');
    else
        fprintf('Cope={');
        for i=1:snum
            if ope(co(a-1,1),i)==1
                p=sta(i,:);
                fprintf(p);
                if i==snum
                    break
                elseif ope(co(a-1,1),i+1:snum)==0
                    break
                else
                    fprintf(',');
                end
            end
        end
        fprintf('},');
        if int(co(a-1,2),:)==0
            fprintf('the secret is leaked');
            disp(' ');
            continue
        end
        fprintf('Cint={');
        for i=1:snum
            if int(co(a-1,2),i)==1
                p=sta(i,:);
                fprintf(p);
                if i==snum
                    break
                elseif int(co(a-1,2),i+1:snum)==0
                    break
                else
                    fprintf(',');
                end
            end
        end
        fprintf('},');
        if int(co(a-1,2),:)-S>=0
            if ope(co(a-1,1),:)*S'==0
                fprintf('an intruder is confused');
            else
                fprintf('the secret may be leaked');
            end
        else
            fprintf('a regular state');
        end
    end
    disp(' ');
end
disp([' '])

% trimmed
Atc=Aco;
il=zeros(1,size(co,1));
conf=zeros(1,size(co,1));
for a=1:size(co,1)
    if int(co(a,2),:)==0
        il(a)=1;
        continue
    end
    if ope(co(a,1),:)*S'~=0
        if S-int(co(a,2),:)>=0
            il(a)=1;
        end
    end
end
while ~isempty(Atc)
    b=1;
    a=1;
    while a<=size(Atc,1)
        if il(Atc(a,1))==1
            Atc(a,:)=[];
            b=0;
            continue
        end
        if il(Atc(a,3))==1 && Atc(a,2)<=enum
            if Eera(Atc(a,2))==0
                cbuf=Atc(a,1);
                while Atc(a,1)==cbuf
                    a=a-1;
                    if a==0
                        break
                    end
                end
                a=a+1;
                while Atc(a,1)==cbuf
                    if Atc(a,2)>=100
                        a=a+1;
                    else
                        Atc(a,:)=[];
                        b=0;
                    end
                    if a>size(Atc,1)
                        break
                    end
                end
                if Atc(a-1,1)~=cbuf
                    il(cbuf)=1;
                end
            else
                Atc(a,:)=[];
                b=0;
            end
        elseif il(Atc(a,3))==1
            Atc(a,:)=[];
            b=0;
        end
        a=a+1;
    end
    if b==1
        b=0;
        break
    end
end
reach=[1,zeros(1,size(co,1))];
while 1
    b=1;
    for a=1:size(Atc,1)
        if reach(Atc(a,1))==1 && reach(Atc(a,3))==0
            b=0;
            reach(Atc(a,3))=1;
        end
    end
    if b==1
        b=0;
        break
    end
end
a=1;
while a<=size(Atc,1)
    if reach(Atc(a,1))==0 || reach(Atc(a,3))==0
        Atc(a,:)=[];
    else
        a=a+1;
    end
end
Tcount=[];
for a=1:size(co,1)
    b=1;
    for i=1:size(Atc,1)
        if Atc(i,1)==a && b==1
            Tcount=[Tcount,i];
            b=0;
        elseif Atc(i,1)>a && b==1
            Tcount=[Tcount,i];
            b=0;
        elseif Atc(i,1)>a && b==0
            break
        end
    end
end
Tcount=[Tcount,size(Atc,1)+1];
Tmat=-ones(size(co,1),enum*100);
for a=1:size(Atc,1)
    Tmat(Atc(a,1),Atc(a,2))=Atc(a,3)-1;
end
a=1;
while a<=size(Tmat,2)
    if a>size(Tmat,2)
        break
    end
    if Tmat(:,a)==-1
        Tmat(:,a)=[];
    else
        a=a+1;
    end
end

% relabel determinisim
% rtc=[1,zeros(1,size(co,1)-1)];
% Artc=[];
% Rcount=1;
% while 1
%     for a=1:length(rtc)
%         if rtc(a)==1
%             rtc(a)=2;
%             for i=Tcount(a):Tcount(a+1)-1
%                 if Atc(i,2)>=100 && rtc(Atc(i,3))==0
%                     rtc(Atc(i,3))=1;
%                 end
%             end
%         end
%     end
%     if rtc~=1
%         rtc=rtc/2;
%         break
%     end
% end
% a=1;
% while a<=size(rtc,1)
%     for i=1:enum
%         if Eope(i)==0
%             continue
%         end
%         cbuf=zeros(1,size(co,1));
%         for j=1:length(cbuf)
%             if rtc(a,j)==1
%                 for k=Tcount(j):Tcount(j+1)-1
%                     if Atc(k,2)==i || Atc(k,2)/10==i
%                         cbuf(Atc(k,3))=1;
%                     end
%                 end
%             end
%         end
%         while 1
%             for j=1:length(cbuf)
%                 if cbuf(j)==1
%                     cbuf(j)=2;
%                     for k=Tcount(j):Tcount(j+1)-1
%                         if Atc(j,2)>=100 && cbuf(Atc(j,3))==0
%                             cbuf(Atc(j,3))=1;
%                         end
%                     end
%                 end
%             end
%             if cbuf~=1
%                 cbuf=cbuf/2;
%                 break
%             end
%         end
%         if cbuf==0
%             continue
%         end
%         for j=1:size(rtc,1)
%             if cbuf==rtc(j,:)
%                 Artc=[Artc;a,i,j];
%                 b=1;
%                 break
%             end
%         end
%         if b==1
%             b=0;
%         else
%             rtc=[rtc;cbuf];
%             Artc=[Artc;a,i,size(rtc,1)];
%         end
%     end
%     a=a+1;
%     Rcount=[Rcount,size(Artc,1)+1];
% end
% Rmat=zeros(size(rtc,1),length(eope));
% for a=1:size(Artc,1)
%     Rmat(Artc(a,1),Artc(a,2))=Artc(a,3);
% end



% disp('the trimmed joint observer is:')
% for a=1:1+length(reach)
%     if a>1
%         if reach(a-1)==0
%             continue
%         end
%     end
%     for i=1:1+enum+length(eera)+length(eins)
%         if a==1
%             if i==1
%                 fprintf('s/e');
%                 for j=1:len-3
%                     fprintf(' ');
%                 end
%             elseif i>1 && i<=1+enum
%                 fprintf(e(i-1));
%                 for j=1:len-1
%                     fprintf(' ');
%                 end
%             elseif i>1+enum && i<=1+enum+length(eera)
%                 fprintf(e(eera(i-1-enum)));
%                 fprintf('-');
%                 for j=1:len-2
%                     fprintf(' ');
%                 end
%             else
%                 fprintf(e(eins(i-1-enum-length(eera))));
%                 fprintf('+');
%                 for j=1:len-2
%                     fprintf(' ');
%                 end
%             end
%         else
%             if reach(a-1)==1
%                 if i==1
%                     p=num2str(a-2);
%                     fprintf(p);
%                     for j=1:len-length(p)
%                         fprintf(' ');
%                     end
%                 else
%                     p=num2str(Tmat(a-1,i-1));
%                     fprintf(p);
%                     for j=1:len-length(p)
%                         fprintf(' ');
%                     end
%                 end
%             end
%         end
%     end
%     if a==1
%         fprintf('state information');
%     else
%         fprintf('Cope={');
%         for i=1:snum
%             if ope(co(a-1,1),i)==1
%                 p=sta(i,:);
%                 fprintf(p);
%                 if i==snum
%                     break
%                 elseif ope(co(a-1,1),i+1:snum)==0
%                     break
%                 else
%                     fprintf(',');
%                 end
%             end
%         end
%         fprintf('},Cint={');
%         for i=1:snum
%             if int(co(a-1,2),i)==1
%                 p=sta(i,:);
%                 fprintf(p);
%                 if i==snum
%                     break
%                 elseif int(co(a-1,2),i+1:snum)==0
%                     break
%                 else
%                     fprintf(',');
%                 end
%             end
%         end
%         fprintf('},');
%         if int(co(a-1,2),:)-S>=0
%             fprintf('an intruder is confused');
%         else
%             fprintf('a regular state');
%         end
%     end
%     disp(' ');
% end