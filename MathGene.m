classdef MathGene < handle
    %MATHGENE is a class used for travelling through the AMS Math Geneology
    
    properties
        mirrorIdx = 3; % which mirror we'll be using to download from
        ID = '';       % the node identifier in the tree
        url = '';      % the web location of the gene
        name = '';     % the name of the person in the tree
        degree = 'not downloaded';   % what degrees they received
        institution = '';  % the institution from which they received it
        year = [];     % the year in which they received it
        nationality = '';  % the nationality of the person
        dissertation = 'not downloaded'; % the title of their dissertation
        advisor = [];  % the person's advisors
        student = [];  % the person's students
    end
    
    properties (Dependent = true)
        descendents = [];  % the number of students
    end
    
    properties (Access = private)
        mirror = { ... % various mirrors of the AMS Math Geneology Project
            'http://www.genealogy.math.ndsu.nodak.edu/'; ...   % NDSU
            'http://www.genealogy.ams.org/'; ...               % AMS
            'http://www.math.uni-bielefeld.de/genealogy/'; ... % Bielefeld
            'http://genealogy.impa.br/'};                      % IMPA
    end
    
    methods
        function obj = MathGene(varargin)
            %MATHGENE(ID) will create a node from an id
            %    http://www.genealogy.ams.org/id.php?id=ID
            %MATHGENE() will create an empty math gene
            
            %% Handle input and construct
            if nargin == 0
                obj.name = 'nobody';
                obj.degree = 'nothing';
                obj.institution = 'nowhere';
                obj.year = 'never';
                obj.dissertation = 'none';
            elseif nargin >= 1
                if isnumeric(varargin{1}) || ischar(varargin{1})
                    % set the ID
                    obj.ID = varargin{1};
                    % Download the gene
                    obj = downloadGene(obj);
                elseif isstruct(varargin{1})
                    props = properties(obj);
                    fields = fieldnames(varargin{1});
                    valid = intersect(props,fields);
                    for v = 1:numel(valid)
                        obj.(valid{v}) = varargin{1}.(valid{v});
                    end
                else
                    error([upper(mfilename) ':InvalidInput'],[ ...
                        'Only numeric, string, and struct inputs ' ...
                        'are supported']);
                end
                
            else
                error([upper(mfilename) ':InvalidInput'], ...
                    'Only up to 1 input supported.');
            end
        end
        
        function set.ID(obj,val)
            %SET.ID sets the ID to be a number, always
            if isnumeric(val)
                obj.ID = val;
            elseif ischar(val)
                obj.ID = str2double(val);
            else
                error([upper(mfilename) ':set:ID'], ...
                    'Only numeric and string IDs are supported');
            end
        end
        
        function val = get.descendents(obj)
            %GET.DESCENDENTS returns the number of students
            S = numel(obj.student);
            if S ~= 0, val = num2str(S); else val = ''; end
        end
        
        function set.descendents(obj,val)
            %SET.DESCENDENTS sets the number of students in absence of data
            val = str2double(val);
            if ~isfinite(val), val = 0; end
            obj.student = repmat(MathGene(),1,val);
        end
        
        function val = getMirror(obj)
            %GETMIRROR retrieves one of the mirrors hosting the Math Genes
            val = obj.mirror{obj.mirrorIdx};
        end
        
        function val = urlFromId(obj,varargin)
            %URLFROMID creates a person URL from a node ID
            if isa(obj,'MathGene')
                val = sprintf([obj.getMirror() ...
                    'id.php?id=%i'],obj.ID);
            else
                val = sprintf([obj.getMirror() ...
                    'id.php?id=%i'],varargin{1});
            end
        end
        
        function obj = downloadStudents(obj)
            %DOWNLOADSTUDENTS grabs the gene information for the students
            S = numel(obj.student);
            for s = 1:S
                fprintf('Downloading Student %i of %i\n',s,S);
                obj.student(s) = obj.student(s).downloadGene();
            end
        end
        
        function obj = downloadAllDescendents(obj,tab)
            %DOWNLOADALLDESCENDENTS grabs all of the descendent's genes
            if nargin < 2, tab = ''; end
            S = numel(obj.student);
            for s = 1:S
                fprintf('%sDownloading Student %i of %i\n',tab,s,S);
                obj.student(s) = obj.student(s).downloadGene();
                obj.student(s).downloadAllDescendents([tab '  ']);
            end
        end
        
        function obj = downloadAdvisors(obj)
            %DOWNLOADADVISORS grabs the gene information for the advisors
            A = numel(obj.advisor);
            for a = 1:A
                fprintf('Downloading Advisor %i of %i\n',a,A);
                obj.advisor(a) = obj.advisor(a).downloadGene();
            end
        end
        
        function obj = downloadGene(obj)
            %DOWNLOADGENE grabs gene information for future crawling
            
            % grab the web data
            str = urlread(obj.urlFromId());
            
            % exract the padding wrapper
            [s,e] = regexpi(str,[...
                '<div id="paddingWrapper">(.*?)' ...
                '<!-- end #paddingWrapper -->']);
            if numel(s) == 1 && numel(s) == numel(e)
                paddingWrapper = str(s:e);
            else
                error([upper(mfilename) ':downloadGene:HtmlParsing'], ...
                    'Trouble finding paddingWrapper')
            end
            
            % extract the relevant person information
            ret = regexpi(paddingWrapper,[...
                '<h2[^>]*>\s+(?<name>.*)\s+</h2>.*'...
                '<div[^>]*>\s+<span[^>]*>' ...
                '(?<degree>[^<]*)\s+<span[^>]*>' ...
                '(?<institution>[^<]*)' ...
                '</span>\s*(?<year>[^<]*)</span>.*' ...
                '<div[^>]*><span[^>]*>' ...
                'Dissertation:</span> <span[^>]*' ...
                'id="thesisTitle">\s+' ...
                '(?<dissertation>[^<]*)</span></div>.*' ...
                ],'names');
            
            % parse error checking
            if isempty(ret)
                error([upper(mfilename) ':downloadGene:HtmlParsing'], ...
                    'Gene was empty after parsing.')
            end
            
            % assign the information
            fNames = {'name','degree','institution','year','dissertation'};
            for f = 1:numel(fNames)
                obj.(fNames{f}) = ret.(fNames{f});
            end
            
            % extract nationality information.
            flag = regexpi(paddingWrapper,[ ...
                '<img src="img/flags/[^>]*' ...
                'title="(?<nationality>[^>]*)">.*' ...
                ],'names');
            if ~isempty(flag)
                obj.nationality = [flag.nationality];
            else
                obj.nationality = '';
            end
            
            % extract advisor information
            advisorarray = regexpi(paddingWrapper,[ ...
                'Advisor[^<]*<a href="id.php\?id=(?<ID>[^"]*)">' ...
                '(?<name>[^<]*)</a>', ...
                ],'names');
            obj.advisor = MathGene();
            for a = 1:numel(advisorarray)
                advisorarray(a).url = obj.urlFromId(advisorarray(a).ID);
                obj.advisor(a) = MathGene(advisorarray(a));
            end
            
            % extract student information
            studentarray = regexpi(paddingWrapper,[ ...
                '<tr[^>]*><td>' ...
                '<a href="id.php\?id=(?<ID>[^"]*)">' ...
                '(?<name>[^<]*)</a></td><td>'...
                '(?<institution>[^<]*)</td>' ...
                '<td[^>]*>(?<year>[^<]*)</td>' ...
                '<td[^>]*>(?<descendents>[^<]*)</td></tr>'],'names');
            S = numel(studentarray);
            if S > 1
                obj.student = MathGene();
                for s = 1:S
                    studentarray(s).url = obj.urlFromId(studentarray(s).ID);
                    obj.student(s) = MathGene(studentarray(s));
                end
            else
                obj.student = repmat(MathGene(),0);
            end
        end
        
        function disp(obj)
            %DISP just prints a gene to the screen
            O = numel(obj);
            for o = 1:O
                fprintf(1,'   MathGene of %s:\n\n',obj(o).name);
                fprintf(1,'     %s %s %s %s\n', ...
                    obj(o).degree,obj(o).institution, ...
                    obj(o).year,obj(o).nationality);
                fprintf(1,'     Dissertation: %s\n\n',obj(o).dissertation);
                if strncmp(get(0,'Format'),'long',4)
                    % print long-hand advisors
                    A = numel(obj(o).advisor);
                    if A > 1
                        for a = 1:A
                            fprintf(1,'     Advisor %i: %s\n',...
                                a,obj(o).advisor(a).name);
                        end
                    elseif A == 1
                        fprintf(1,'     Advisor: %s\n', ...
                            obj(o).advisor.name);
                    else
                        fprintf(1,'     0 Advisors\n');
                    end
                    
                    % print long-hand students
                    S = numel(obj(o).student);
                    if S == 1, plural = ''; else plural = 's'; end;
                    if S ~= 0, plural = cat(2,plural,':'); end
                    fprintf(1,['\n     %i Student' plural '\n\n'],S);
                    if S > 0
                        f = cellfun(@(s)['%' num2str(s) 's'],num2cell( ...
                            cellfun(@(c)max(cellfun(@numel,c)),{ ...
                            [{obj(o).student.name} 'name'], ...
                            [{obj(o).student.institution} 'institution'], ...
                            [{obj(o).student.year} 'year'], ...
                            {obj(o).student.descendents}})), ...
                            'UniformOutput',0);
                        d = ' | ';
                        fprintf( ...
                            [f{1} d f{2} d f{3} d f{4} '\n'], ...
                            'Name','Institution','Year','Descendents');
                        for s = 1:S
                            fprintf([f{1} d f{2} d f{3} d f{4} '\n'], ...
                                obj(o).student(s).name, ...
                                obj(o).student(s).institution, ...
                                obj(o).student(s).year, ...
                                obj(o).student(s).descendents)
                        end
                    end
                else
                    % print short-hand advisors
                    A = numel(obj(o).advisor);
                    if A == 1, plural = ''; else plural = 's'; end;
                    fprintf(1,['     %i Advisor' plural ', '],A);
                    
                    % print short-hand students
                    S = numel(obj(o).student);
                    if S == 1, plural = ''; else plural = 's'; end;
                    fprintf(1,['%i Student' plural '\n'],S);
                end
                fprintf('\n');
            end
        end
        
    end
    
end


