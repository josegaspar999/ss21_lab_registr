function groups_manage_tst( tstId )
if nargin<1
    tstId= 25; %24; %23; %22; %21; %20; %11; %10; %3; %2; %1;
end

switch tstId
    case 1, SSS= shifts_info('load_xls');
    case 2, shifts_info('save_mat', shifts_info('load_xls') );
    case 3, SSS= shifts_info('load_mat');
        
    case 10, tst10
    case 11, tst11

    case 20, tst20
    case 21, tst21
    case 22, tst22
    case 23, tst23
    case 24, tst24
    case 25, tst25
        
    otherwise
        error('inv tstId')
end
return


function tst10
% check every number can be found

shifts_info('load_if_empty');
SSS= shifts_info('get');

for i=1:length(SSS)
    x= SSS{i};
    for j=2:size(x,1)
        num= x{j,2};
        ret= shifts_info( 'find_num', num );
        ind= 0;
        if ret.foundFlag
            ind= ret.ij(1);
        end
        fprintf(1, 'shift:%d(%d) num:%d\n', i,ind, num);
        % number in (.) must be equal
    end
end
return


function tst11
% make random groups

shifts_info('load_if_empty');
SSS= shifts_info('get');

if 0
    % find colleagues of number y
    i= 2; % shiftId
    n= 11; % student 10 (line 1 has headers)
    x= SSS{i};
    y= x{n,2}; %10,2}; %3,2};
    ret= shifts_info('find_num_alt', y);
    ret
end

if 0
    % delete flags one by one
    for i= 1:length(SSS)
        x= SSS{i};
        for j= 2:size(x,1)
            num= x{j,2};
            ret= shifts_info( 'del_flags_by_num', num );
            if sum(ret)>0
                disp( shifts_info( 'count_flags' ) )
            end
        end
    end
end

if 1
    make_random_groups(SSS, 0);
end

return


function data_reset
global SSS; SSS=[];


function Glst= make_random_groups( SSS, resetBeforeAndAfter )
%  given your number, select two other numbers, and remove that group
Glst= {};
if resetBeforeAndAfter
    data_reset
    shifts_info('load_if_empty');
    SSS= shifts_info('get');
end

while 1
    % find one true flag
    num= get_num( SSS, shifts_info('get_flags') );
    if isempty(num)
        break;
    end
    if 0 %1 % delete that num
        ret= shifts_info( 'del_flags_by_num', num );
        if sum(ret)>0
            disp( shifts_info( 'count_flags' ) )
        end
    end
    
    % find all colleagues
    ret= shifts_info( 'find_num_alt', num );
    % choose two colleagues
    nums= choose_two( SSS, ret );
    % delete all three
    ret= shifts_info( 'del_flags_by_num', nums );
    if sum(ret)>0
        disp( shifts_info( 'count_flags' ) )
    end
    
    Glst{end+1}= nums;
end

if resetBeforeAndAfter
    data_reset
    shifts_info('load_if_empty');
end
return


function num= get_num( SSS, SSflags )
tries= [];
while 1
    i1= randi(length(SSflags));
    i2= find( SSflags{i1} );
    if length(i2)>0, break; end
    tries= unique( [tries i1] );
    if length(tries)==length(SSflags)
        num= [];
        return
    end
end
i3= randi(length(i2));
x= SSS{i1};
num= x{i2(i3),2};
return


function nums= choose_two( SSS, numInfo )
num= numInfo.num;
indLst= numInfo.num_alt_ind;
shiftId= numInfo.ij(1);

i1= randi( length(indLst) );
while 1
    i2= randi( length(indLst) );
    if i2~=i1
        break
    end
end
ind= indLst([i1 i2]);

n2= SSS{shiftId}; n2= n2{ind(1),2};
n3= SSS{shiftId}; n3= n3{ind(2),2};
nums= [num n2 n3];


function tst20
groups_manage('ini')
Glst= make_random_groups([], 1); % just within shifts
for i=1:length(Glst)
    groups_manage('add', Glst{i} );
end
groups_manage('show')
return


function tst21
groups_manage('ini')
groups_manage('show_nums_names')


function tst22
groups_manage('ini')
groups_manage('make', [99137 99142 99144])
%groups_manage('make', [99137 99142 99144])  % uncomment to force error
groups_manage('make', [99147 99151 99159])
groups_manage('make', [98929 98930 98934])


function tst23
s= input('-- delete "groups_manage.mat" y/n ? ', 's');
if strcmpi(s,'y')
    delete('data2/groups_manage.mat')
end
groups_manage('ini')
groups_manage('make', [99137 99142 99144])
% groups_manage('make', [99137 99142 99144])  % uncomment to force error
groups_manage('make', [99147 99151 99159])
groups_manage('make', [98929 98930 98934])
groups_manage('save')

groups_manage('ini')
% groups_manage('make', [99137 99142 99144]) % force error
groups_manage('make', [98956 98963 98965])
groups_manage('save')

groups_manage('show')


function tst24
% interactive tst
groups_manage('mygroup')


function tst25
% interactive tst
groups_manage('show')
