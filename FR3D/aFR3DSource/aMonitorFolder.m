function [] = aMonitorFolder

mydir = '/Servers/rna.bgsu.edu/WebFR3D/InputScript/Input';
result = '/Servers/rna.bgsu.edu/WebFR3D/Results';
failed = '/Servers/rna.bgsu.edu/WebFR3D/InputScript/Failed';

if ~exist(mydir,'dir')
    mkdir(mydir);
end
if ~exist(result,'dir')
    mkdir(result);
end    
pause on;

disp('Standby');
while 1 
    query = dir([mydir filesep '*.m']);
    if ~isequal(length(query),0),
        id = query(1).name(7:end-2);
        destination = [result filesep id];
        if ~exist(destination,'dir')
            mkdir(destination);
        end
        fidi = fopen([mydir filesep query(1).name],'r');

        if strfind(query(1).name,'rnao')
            Query = [];
            try
                Query = xReadRNAOQuery([mydir filesep query(1).name]);   
            catch
                message = 'Parsing failed. Check your syntax.';
                reportMistake(result,id,message,Query);
                movefile([mydir filesep query(1).name], [failed filesep query(1).name]);                     
                continue;
            end
            try
                aWebFR3DSearch;
            catch
                message = 'Problem during FR3D search.';                    
                reportMistake(result,id,message,Query);
                movefile([mydir filesep query(1).name], [failed filesep query(1).name]);                     
                continue;
            end               
            if isfield(Search,'Candidates') && ~isempty(Search.Candidates)
                try 
                    if length(Search.Candidates(:,1)) < 300
                        aWriteHTMLForSearch(id);
                    else
                        message = 'Too many candidates';                    
                        reportMistake(result,id,message,Query);
                        movefile([mydir filesep query(1).name], [result filesep id filesep query(1).name]);                     
                        continue;                            
                    end
                catch
                    message = 'Problem creating the webpage';                    
                    reportMistake(result,id,message,Query);
                    movefile([mydir filesep query(1).name], [failed filesep query(1).name]);                     
                    continue;
                end                        
            else
                message = 'No candidates found';
                reportMistake(result,id,message,Query);
                movefile([mydir filesep query(1).name], [result filesep id filesep query(1).name]);                     
            end               
        else        
            while 1
                tline = fgetl(fidi);
                if ~ischar(tline),   break,   end
                disp(tline); 
                try 
                    eval(tline);
                catch 
                    fprintf('Problem with line: %s\n',tline);
                    message = 'Critical error. Execution aborted.';
                    reportMistake(result,id,message,Query);                    
                    try
                        movefile([mydir filesep query(1).name], [failed filesep query(1).name]);                
                    catch
                        
                    end
                    break;
                end
            end
            fclose(fidi); 
        end
        try
            movefile([mydir filesep query(1).name], [result filesep id filesep query(1).name]);
        catch

        end

        clear Query;    
        disp('Query processed'); 
        disp('Standby');        
    end
    pause(2);
end    


end


function reportMistake(result,id,message,Query)

    webroot = 'http://rna.bgsu.edu/WebFR3D';
    disp(message);                
    fid = fopen([result filesep id filesep 'results.php'],'w');      
    fprintf(fid, '<html><head><title>FR3D results</title></head><body>\n');
    fprintf(fid, '<div style="margin:auto;width:550px;vertical-align:middle;border-style:groove;text-align:center;position:absolute;top:20%%;">\n');
    fprintf(fid, '<h2>Thank you for using FR3D</h2><br>\n');
    fprintf(fid, '<p>%s</p><br><br>\n',message);      
    fprintf(fid, '</div></body></html>');        
    fclose(fid);
    if isfield(Query, 'Email')
        link = sprintf('%s/Results/%s/results.php', webroot, id);
        message = sprintf('Please visit this webpage to see your FR3D results: %s  This is an automated message. For support email apetrov@bgsu.edu', link);
        command = sprintf('echo "%s" | tee foo | mail -s "FR3D results %s" %s', message, id, Query.Email);
        unix(command);
        clear Query.Email;
    end            
    disp('Standby');        
    
end
