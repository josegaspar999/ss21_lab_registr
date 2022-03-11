function ret= groups_manage( op, a1 )

% March 2022, J. Gaspar

global Glst

% if isempty(Glst)
%     % ERR this makes infinite loop
%     groups_manage('load');
% end

switch op
    case 'ini'
        shifts_info('load_if_empty');
        shifts_info('ini_flags');
        Glst= []; % force empty
        groups_manage('load');
        Glst2= Glst; Glst= [];
        for i= 1:length(Glst2)
            groups_manage('add', Glst2{i} );
        end
        
    case 'load'
        fname= groups_manage_datafile;
        if exist(fname, 'file')
            load( fname, 'Glst' );
        end
        
    case 'save'
        % groups_manage('save')
        fname= groups_manage_datafile;
        save( fname, '-6', 'Glst' );

    case 'add'
        nums= a1;
        if ~nums_repeated( Glst, length(Glst), nums )
            % add only if not repeated
            Glst{end+1}= nums; % a1= [shiftId num1 num2 num3]
        end
        ret= shifts_info( 'del_flags_by_num', nums );

    case 'add_clean'
        Glst= nums_delete_repeated( Glst );

    case 'needs_cleanup'
        Glst2= nums_delete_repeated( Glst );
        if length(Glst2)~=length(Glst)
            fprintf(1, '** list of groups NEEDS cleanup (%d vs %d)\n', ...
                length(Glst), length(Glst2));
        else
            fprintf(1, '** list of groups is OK\n');
        end
        
    case 'make'
        % usage: groups_manage('make')
        if nargin<2
            mk_group([])
        else
            mk_group(a1)
        end

    case 'show'
        % usage: groups_manage('show')
        % emtpy data, try a 'ini'?
        if isempty(Glst)
            %s= input('List of groups empty, try "ini" to load it y/n? ', 's');
            if 1 %strcmpi(s, 'y')
                groups_manage('ini');
            end
        end
        show_groups()

    case {'show_fenix', 'show_nums_names'}
        % specific usage
        show_nums_names()
        
    case 'show_num_name'
        % groups_manage( 'show_num_name', 1 )
        show_num_name( [], a1, [] );
        
    case 'mygroup'
        % usage: groups_manage('mygroup')
        groups_manage('ini')
        groups_manage('make')
        groups_manage('save')
        
    otherwise
        error('inv op "%s"', op)
end
return % end of main function


% -------------------------------------------------------------------------
function fname= groups_manage_datafile
%fname= './groups_manage.mat';
fname= './data2/groups_manage.mat';


% -------------------------------------------------------------------------
function Glst2= nums_delete_repeated( Glst )
Glst2= {};
for i=1:length(Glst)
    repeatedFlag= nums_repeated( Glst, i );
    if repeatedFlag, continue, end
    Glst2{end+1}= Glst{i};
end


function repeatedFlag= nums_repeated( Glst, GlstInd, nums )
if isempty(GlstInd)
    GlstInd= length(Glst);
end
if nargin<3
    nums= Glst{GlstInd};
end
repeatedFlag= 0;
for j=1:GlstInd-1
    if nums_compare( nums, Glst{j} )
        repeatedFlag= 1;
        break
    end
end


function flag= nums_compare( n1, n2 )
flag= 0;
if max(size(n2)~=size(n1))
    % different sizes, can return false
    return
end
if max(n2~=n1)
    % different values, can return false
    return
end
flag= 1; % equal nums, return true


% -------------------------------------------------------------------------
function show_groups( options )
if nargin<1
    options= [];
end

global Glst
%fprintf(1, '** Glst len = %d\n', length(Glst)); pause
SSS= shifts_info('get');
fprintf(1, '** Glst len = %d\n', length(Glst));

indLst= sort_groups( SSS, Glst, options );
fprintf(1, '\n\n----------------------\n');
fprintf(1,     'Current list of groups\n');
fprintf(1,     '----------------------\n\n');
for i= 1:length(indLst)
    fprintf(1, '-- group %d:\n', i);
    show_group( SSS, Glst{indLst(i)}, options);
end
fprintf(1, '\n\n');
fprintf(1, '** Glst len = %d\n', length(Glst));
return


function indLst= sort_groups( SSS, Glst, options )
if isfield(options, 'no_sort')
    indLst= 1:length(Glst);
    return
end

sLst= [];
for i= 1:length(Glst);
    num= Glst{i};
    num= num(1);
    ret= shifts_info( 'find_num', num );
    sLst(end+1)= ret.ij(1);
end

indLst= [];
for i= unique(sLst)
    ind= find(sLst == i);
    indLst= [indLst ind];
end

return


function show_group( SSS, nums, options )
for n= nums
    show_num_name( SSS, n, options )
end


% -------------------------------------------------------------------------
function show_nums_names( SSS, shiftId, linesLst, options )
if nargin<1
    SSS= shifts_info('get');
    for i= 1:length(SSS)
        x= SSS{i};
        show_nums_names( SSS, i, 2:size(x,1) );
    end
    return
end

if nargin<4
    options= [];
end

x= SSS{shiftId};
for i= linesLst(:)'
    num= x{i,2};
    show_num_name( SSS, num, options );
end

return % end of function


function show_num_name( SSS, num, options )
if isempty(SSS)
    SSS= shifts_info('get');
end

shShiftFlag= 1; %0;
if isfield(options, 'shShiftFlag')
    shShiftFlag= options.shShiftFlag;
end

ret= shifts_info( 'find_num', num );
if isempty(ret.ij) %~ret.foundFlag
    %warning('Number %d not found or already used.', num)
    warning('Number %d not found.', num)
    return
end

shiftId= ret.ij(1);
lineId= ret.ij(2);
x= SSS{shiftId};
if shShiftFlag
    doneFlag= '+';
    if ~ret.foundFlag
        % not found means registered
        doneFlag= '.';
    end
    fprintf(1, '[shift %d]%c ', shiftId, doneFlag );
end
fprintf(1, '%d\t%s\n', x{lineId,2}, x{lineId,3} );

return


% -------------------------------------------------------------------------
function ret= check_num( num, shiftId )
if nargin<2
    shiftId= [];
end

ret= shifts_info( 'find_num', num );
if ~ret.foundFlag
    %error('Number %d not found or already registered in a group.', num);
    ret.err= sprintf('Number %d not found or already registered in a group.', num);
    return
end

if ~isempty(shiftId) && ret.ij(1)~=shiftId
    %error('Mismatch of the shift id. Cannot form groups from different shifts.');
    ret.err= 'Mismatch of the shift id. Cannot form groups from different shifts.';
    return
end

show_num_name( [], num, [] );


function [ret, num]= input_num( str, nums, numsInd, shiftId )
if isempty(nums)
    s= input(str, 's');
    num= str2num(s);
else
    num= nums(numsInd);
end
% can get error message but does not break the run
ret= check_num( num, shiftId );


function [ret, num]= input_num2( str, nums, numsInd, shiftId, nRetries )
ret= [];
num= [];
while nRetries>0
    [ret, num]= input_num( str, nums, numsInd, shiftId );
    if ~isfield(ret, 'err')
        break
    end
    fprintf(1, 'ERR: %s\n', ret.err);
    nRetries= nRetries-1;
end
if isfield(ret, 'err')
    % fail with error message
    error(ret.err)
end


function nums2= input_nums3( str, nums, shiftId, nRetries )
if ~isempty(nums)
    nums2= nums(2:end);
    return
end

error('under construction')
nums2= [];
% Enter 3 student numbers separated by commas, e.g. 99999, 88888, 77777
x= input( str, 's' );

while nRetries>0
    [ret, num]= input_num( str, nums, numsInd, shiftId );
    if ~isfield(ret, 'err')
        break
    end
    fprintf(1, 'ERR: %s\n', ret.err);
    nRetries= nRetries-1;
end
if isfield(ret, 'err')
    % fail with error message
    error(ret.err)
end


% -------------------------------------------------------------------------
function sh_turned_off_message()
fprintf(1, 'Hello all, this site is closed, does not accept more submissions\n');


% -------------------------------------------------------------------------
function mk_group( nums )
% CLI to define groups

% groups_manage( {'ini', 'make', 'save'} )
% groups_manage( 'mygroup' )

% Enter your student number
[~, num]= input_num2( 'Enter your student number e.g. 123456: ', nums, 1, [], 3 );

% find all colleagues
ret= shifts_info( 'find_num_alt', num );
SSS= shifts_info( 'get' );

fprintf(1, '\n--- Shift elements to select from:\n');
show_nums_names( SSS, ret.ij(1), ret.num_alt_ind )
fprintf(1,   '--- End of list.\n\n');

% Choose two colleagues from the list shown above
[~, num2]= input_num2( 'Enter student number of your colleague #1: ', ...
    nums,2, ret.ij(1), 3 );
[~, num3]= input_num2( 'Enter student number of your colleague #2: ', ...
    nums,3, ret.ij(1), 3 );

% Confirm group?
fprintf(1, '\n*** Group to form:\n');
show_group( SSS, [num num2 num3], [] )
if isempty(nums)
    while 1
        s= input('    Do you want to form this group y/n? ', 's');
        if length(s)>0, break; end
    end
else
    s= 'y';
end
if strcmpi(s,'y')
    groups_manage('add', [num num2 num3] );
    fprintf(1, '    Group added.\n\n');
else
    fprintf(1, '    ** Group NOT added to the list. **\n\n');
end
