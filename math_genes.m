function varargout = math_genes(startGene,doFollowTime)
% MATH_GENES crawls the AMS Math Genealogy Project into the past
%
%USAGE
%
%   math_genes() will crawl into the past from a given node or person and
%   create a list of the history starting from that node or person.
%
%   math_genes(NODENUMBER) will crawl from a node id like:
%   http://www.genealogy.ams.org/id.php?id=NODENUMBER
%
%   math_genes(PERSON_NAME) will crawl from the first match of a person's
%   name in their search results.
%
%   math_genes(START_GENE,DOFOLLOWTIME) will crawl in the direction specified.
%   DOFOLLOWTIME defaults to false, meaning the default behavior is to
%   travel into the past.
%
%AUTHORSHIP
%   Created By  : David Gross
%   Created On  : 2012 Jun 15, 17:46
%
%See Also
%   urlread, regexp, regexpi

%% Set up the base URLs for the AMS Geneology
mirror{1} = 'http://www.genealogy.math.ndsu.nodak.edu/'; % NDSU
mirror{2} = 'http://www.genealogy.ams.org/'; % AMS
mirror{3}  ='http://www.math.uni-bielefeld.de/genealogy/'; % Bielefeld
mirror{4} = 'http://genealogy.impa.br/'; % IMPA

%% Set up the shared variables
baseUrl = mirror{1};
tab = '';

%% Handle Inputs
if nargin < 1
    error([upper(mfilename) ':InvalidInput'], ...
        'Only one input is supported');
end

if nargin < 2, doFollowTime = false; end

%% Construct start URL based on user input
if isnumeric(startGene)
    url = sprintf([baseUrl 'id.php?id=%i'],startGene);
elseif ischar(startGene)
    error([upper(mfilename) ':InvalidInput'], ...
        'Actually we don''t support string names yet.');
else
    error([upper(mfilename) ':InvalidInput'], ...
        'Only char and numeric inputs are supported');
end

%% Old code to potentially be awesome
%     url = [baseUrl randomTag];
%     % fprintf(1,'Finding retreival info...\n')
%     str = urlread(url);
%     current = regexpi(str, ...
%         'Retrieved from "<a href="(?<link>[^"]+)"','names');
%     if numel(current) ~= 1
%         warning('Did not find random site name')
%         keyboard
%     else
%         noamp = regexp(current(1).link,'(?<link>[^&]+)&','names');
%         history{1} = noamp(1).link;
%     end

%% Iterate
history = crawl_history(url);

%% Handle Outputs
if nargout <= 1
    varargout{1} = history;
else
    error([upper(mfilename) ':InvalidOutput'], ...
        'No more than one output is supported');
end

%% FUNCTION CRAWL_HISTORY downloads a gene and recurses
    function history = crawl_history(url)
        history = download_gene(url);
        if isempty(history.advisor)
            % we return ...
        else
            tab = cat(2,tab,'  ');
            oldTab = tab;
            % depth first search
            for a = 1:numel(history.advisor)
                tab = oldTab;
                history.advisor(a) = ...
                    crawl_history(history.advisor(a).url);
            end
        end
    end

%% FUNCTION DOWNLOAD_GENE grabs gene information for future crawling
    function gene = download_gene(url)
        % let us know what is going on while downloading data
        % fprintf(1,'%s\n',url)
        str = urlread(url);
        
        % grab the padding wrapper
        [s,e] = regexpi(str,...
            '<div id="paddingWrapper">(.*?)<!-- end #paddingWrapper -->');
        if numel(s) == 1 && numel(s) == numel(e)
            paddingWrapper = str(s:e);
        else
            error([upper(mfilename) ':download_gene:HtmlParsing'], ...
                'Trouble finding paddingWrapper')
        end
        
        gene = regexpi(paddingWrapper,[...
            '<h2[^>]*>\s+(?<name>.*)\s+</h2>.*'...
            '<div[^>]*>\s+<span[^>]*>(?<degree>[^<]*)\s+<span[^>]*>' ...
            '(?<institution>[^<]*)</span>\s*(?<year>[^<]*)</span>.*' ...
            '<img src="img/flags/[^>]* title="(?<nationality>[^>]*)">.*' ...
            '<div[^>]*><span[^>]*>Dissertation:</span> <span[^>]*' ...
            'id="thesisTitle">\s+(?<dissertation>[^<]*)</span></div>.*' ...
            ],'names');
        
        gene = regexpi(paddingWrapper,[...
            '<h2[^>]*>\s+(?<name>.*)\s+</h2>.*'...
            '<div[^>]*>\s+<span[^>]*>(?<degree>[^<]*)\s+<span[^>]*>' ...
            '(?<institution>[^<]*)</span>\s*(?<year>[^<]*)</span>.*' ...
            '<div[^>]*><span[^>]*>Dissertation:</span> <span[^>]*' ...
            'id="thesisTitle">\s+(?<dissertation>[^<]*)</span></div>.*' ...
            ],'names');
        
        if isempty(gene)
            error([upper(mfilename) ':download_gene:HtmlParsing'], ...
                'Gene was empty after parsing.')
        end
        
        flag = regexpi(paddingWrapper,[ ...
            '<img src="img/flags/[^>]*' ...
            'title="(?<nationality>[^>]*)">.*' ...
            ],'names');
        if ~isempty(flag)
            gene.nationality = [flag.nationality];
        else
            gene.nationality = '';
        end
        
        gene.advisor = regexpi(paddingWrapper,[ ...
            'Advisor[^<]*<a href="(?<url>[^"]*)">' ...
            '(?<name>[^<]*)</a>', ...
            ],'names');
        
        fNames = {'url','name','degree', ...
            'institution','year','nationality','dissertation', ...
            'advisor'};
        
        gene.url = url;
        for a = 1:numel(gene.advisor)
            gene.advisor(a).url = [baseUrl gene.advisor(a).url];
            for f = 2:numel(fNames)
                gene.advisor(a).(fNames{f}) = '';
            end
            gene.advisor(a) = orderfields(gene.advisor(a),fNames);
        end
        
        gene = orderfields(gene,fNames);
        
        print_gene(gene);
        
    end

%% FUNCTION PRINT_GENE just prints a gene to the screen
    function print_gene(gene)
        fprintf(1,'%s%s, %s %s in %s\n', ...
            tab,gene.name,gene.institution,gene.degree,gene.year);
    end

end