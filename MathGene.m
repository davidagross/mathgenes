classdef MathGene
    %MATHGENE is a class used for travelling through the AMS Math Geneology
    
    properties
        mirrorIdx = 3; % which mirror we'll be using to download from
        tab = '';      % how far over we will tab when printing the gene
        url = '';      % the web location of the gene
        name = '';     % the name of the person in the tree
        degree = '';   % what degrees they received
        institution = '';  % the institution from which they received it
        year = [];     % the year in which they received it
        nationality = '';  % the nationality of the person
        dissertation = ''; % the title of their dissertation
        advisor = [];  % the person's advisors
        student = [];  % the person's students
    end
    
    properties (SetAccess = private)
        mirror = { ... % various mirrors of the AMS Math Geneology Project
            'http://www.genealogy.math.ndsu.nodak.edu/'; ...   % NDSU
            'http://www.genealogy.ams.org/'; ...               % AMS
            'http://www.math.uni-bielefeld.de/genealogy/'; ... % Bielefeld
            'http://genealogy.impa.br/'};                      % IMPA
    end
    
    methods
        function obj = MathGene(varargin)
            %MATHGENE(ID) will create a node from an id:
            %    http://www.genealogy.ams.org/id.php?id=ID
            
            %% Handle input
            if nargin >= 1
                ID = varargin{1};
                if ~isnumeric(ID)
                    error([upper(mfilename) ':InvalidInput'], ...
                        'Only numeric inputs are supported');
                end
            else
                error([upper(mfilename) ':InvalidInput'], ...
                        'Only 1 input supported.');
            end
            
            %% Download the gene
            obj = download_gene(obj,obj.urlFromId(ID));
        end
        
        function val = getMirror(obj)
            %GETMIRROR retrieves one of the mirrors hosting the Math Genes
            val = obj.mirror{obj.mirrorIdx};
        end
        
        function val = urlFromId(obj,ID)
            %URLFROMID creates a person URL from a node ID
            val = sprintf([obj.getMirror() 'id.php?id=%i'],ID);
        end
        
        function obj = download_gene(obj,url)
            %DOWNLOAD_GENE grabs gene information for future crawling
            
            % grab the web data
            obj.url = url;
            str = urlread(obj.url);
            
            % exract the padding wrapper
            [s,e] = regexpi(str,...
                '<div id="paddingWrapper">(.*?)<!-- end #paddingWrapper -->');
            if numel(s) == 1 && numel(s) == numel(e)
                paddingWrapper = str(s:e);
            else
                error([upper(mfilename) ':download_gene:HtmlParsing'], ...
                    'Trouble finding paddingWrapper')
            end
            
            % extract the relevant person information
            ret = regexpi(paddingWrapper,[...
                '<h2[^>]*>\s+(?<name>.*)\s+</h2>.*'...
                '<div[^>]*>\s+<span[^>]*>(?<degree>[^<]*)\s+<span[^>]*>' ...
                '(?<institution>[^<]*)</span>\s*(?<year>[^<]*)</span>.*' ...
                '<div[^>]*><span[^>]*>Dissertation:</span> <span[^>]*' ...
                'id="thesisTitle">\s+(?<dissertation>[^<]*)</span></div>.*' ...
                ],'names');
            
            % parse error checking
            if isempty(ret)
                error([upper(mfilename) ':download_gene:HtmlParsing'], ...
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
            obj.advisor = regexpi(paddingWrapper,[ ...
                'Advisor[^<]*<a href="id.php\?id=(?<ID>[^"]*)">' ...
                '(?<name>[^<]*)</a>', ...
                ],'names');
            for a = 1:numel(obj.advisor)
                obj.advisor(a).url = obj.urlFromId(obj.advisor(a).ID);
            end
            
            % extract student information
            obj.student = regexpi(paddingWrapper,[ ...
                '<tr[^>]*><td>' ...
                '<a href="id.php\?id=(?<ID>[^"]*)">' ...
                '(?<name>[^<]*)</a></td><td>'...
                '(?<institution>[^<]*)</td>' ...
                '<td[^>]*>(?<year>[^<]*)</td>' ...
                '<td[^>]*>(?<descendents>[^<]*)</td></tr>'],'names');
            for s = 1:numel(obj.student)
                obj.student(s).url = obj.urlFromId(obj.student(s).ID);
            end
            
        end
        
        function disp(obj)
            %DISP just prints a gene to the screen
            fprintf(1,'%s%s, %s %s in %s\n', ...
                obj.tab,obj.name,obj.institution,obj.degree,obj.year);
        end
        
    end
    
end


