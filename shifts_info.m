function ret= shifts_info(op, a1)
% Manage shifts info

% March 2022, J. Gaspar

global SSS
% global SSS; SSS=[];
% ^ do a reset by hand

load_pkg_io(); % needed by octave

switch op
    case 'load_if_empty'
        if isempty(SSS)
            shifts_info('load_xls');
        end
    case 'get'
        ret= SSS;
        
    case 'load_xls'
        %fname= '../lab/inscr_220307.xlsx';
        %fname= 'shifts_info.xlsx';
        fname= def_fname( 'xlsx' );
        SSS= {};
        for i='1':'4'
            sname= ['Sheet' i];
            [~,~,raw]= xlsread(fname, sname);
            SSS{end+1}= raw;
        end
        ret= SSS;
        myflags('ini', SSS);
        
    case 'save_mat'
        %ofname= 'shifts_info.mat';
        ofname= def_fname( 'mat' );
        overwriteflag= 1;
        if exist(ofname, 'file')
            s= input(['mat file "' ofname '" exists, overwrite y/N? '], 's');
            if ~strcmp(s,'y') && ~strcmp(s,'Y')
                % block overwrite
                overwriteflag= 0;
            end
        end
        if overwriteflag
            if nargin>1
                SSS= a1;
            end
            save( ofname, 'SSS' );
            fprintf(1, 'Wrote "%s"\n', ofname);
        else
            fprintf(1, 'NOT overwritten "%s"\n', ofname);
        end

    case 'load_mat'
        %ifname= 'shifts_info.mat';
        ifname= def_fname( 'mat' );
        if ~exist(ifname, 'file')
            error('mat file "%s" does NOT exist', ifname);
        end
        load( ifname, 'SSS');
        ret= SSS;
        
    case 'find_num'
        % ret= shifts_info( 'find_num', 12345 );
        ret= find_num( SSS, a1 );
    case 'find_num_alt'
        ret= find_num_alt( SSS, a1 );

    case 'set_flags', myflags('set', a1);
    case 'get_flags', ret= myflags('get');
    case 'ini_flags', myflags('ini', SSS);

    case 'count_flags'
        % shifts_info('count_flags')
        ret= myflags('count');
    case 'del_flags_by_num'
        ret= myflags('del_by_num', a1);
        
end

return


function fname= def_fname( fileType )
fname= 'data1/shifts_info.';

% switch fileType
%     case 'mat', fname= [fname fileType];
%     case 'xlsx', fname= [fname fileType];
% end
fname= [fname fileType];


% -----------------------------------------------------------------
function retval = is_octave
persistent cacheval;  % speeds up repeated calls
if isempty(cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
end
retval = cacheval;


function load_pkg_io
persistent loaded_pkg_io;
if ~is_octave
    % no work to do
    return
end
if isempty(loaded_pkg_io)
    pkg load io
    loaded_pkg_io= 1;
end


% -----------------------------------------------------------------
function ret= find_num( SSS, num, SSflags )
if nargin<3
    %SSflags= flags_all_num_true( SSS );
    SSflags= myflags('get');
end
foundFlag= 0;
ij= [];
for i=1:length(SSS)
    tbl= SSS{i};
    flag= SSflags{i};
    for j=2:size(tbl,1)
        %fprintf(1, 'shift:%d num:%d\n', i, x{j,2});
        if tbl{j,2}==num
            ij= [i j];
            foundFlag=1;
            if ~flag(j)
                foundFlag= 0;
            end
            break;
        end
    end
    if foundFlag, break; end
end
ret= struct('num',num, 'foundFlag',foundFlag, 'ij',ij);
return


function ret= find_num_alt( SSS, num, SSflags )
if nargin<3
    %SSflags= flags_all_num_true( SSS );
    SSflags= myflags('get');
end

ret= find_num( SSS, num, SSflags );
if ~ret.foundFlag
    % do not know the shift, just quit
    return
end

% return all, except num and taken out flags
shiftId= ret.ij(1);
flags= SSflags{shiftId};
flags(1)= 0;
flags(ret.ij(2))= 0;
ret.num_alt_ind= find(flags);

return


% -----------------------------------------------------------------
function SSflags= flags_all_num_true( SSS )
SSflags= {};
for i=1:length(SSS)
    flags= ones(size(SSS{i},1), 1);
    flags(1)= 0; % first line is not a number
    SSflags{end+1}= flags;
end


function ret= myflags( op, a1 )
global SSflags

switch op
    case 'ini'
        SSS= a1;
        SSflags= flags_all_num_true( SSS );
    case 'set'
        SSflags= a1;
    case 'get'
        ret= SSflags;

    case 'count'
        ret= [];
        for i=1:length(SSflags)
            ret(end+1)= sum( SSflags{i} );
        end
    case 'del_by_num'
        ret2= [];
        for num= a1
            ret= shifts_info('find_num', num);
            if ret.foundFlag
                x= SSflags{ret.ij(1)};
                x(ret.ij(2))= 0;
                SSflags{ret.ij(1)}= x;
                ret2(end+1)= 1;
            else
                ret2(end+1)= 0;
            end
        end
        ret= ret2;
        
    otherwise
        error('inv op')
end
