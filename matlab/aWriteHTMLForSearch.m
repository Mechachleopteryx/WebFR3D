function [] = aWriteHTMLForSearch(filename)

% read in configuration file
get_config;

results = fullfile(config.results, filename);

MAXPDB = 40;

if exist([results filesep filename '.mat'],'file')
    load([results filesep filename '.mat']);
else
    ShowMessage(results,config.webroot,'Some error occured while processing your request. Please try again later.');
    return;
end

if isempty(Search.Candidates)
    ShowMessage(results,config.webroot,'There were no candidates found in the desired discrepancy range.',Search,filename);
    return;
end

aWriteToPDB_neigh(Search, filename);
command=sprintf('cd %s/%s; zip %s.zip *.pdb', config.pdbdatabase, filename, filename);
unix(command);
aProduceMDGraph(Search, filename);
close(gcf);
Text = aListCandidates(Search,Inf,filename);

fid = fopen([results filesep 'results.php'],'w');
fprintf(fid,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/html4/loose.dtd">');
fprintf(fid,'<html lang = "en"><head><meta http-equiv="Content-Type" content="text/html;charset=utf-8" >');
fprintf(fid,'<title>WebFR3D results</title>');
fprintf(fid,'<link rel="stylesheet" type="text/css" href="%s/Library.css" >',config.css);
fprintf(fid,'<link rel="stylesheet" media="all" type="text/css" href="%s/menu_style.css" />',config.css);
fprintf(fid,'	<!--greybox-->');
fprintf(fid,'	<script type="text/javascript">');
fprintf(fid,'	    var GB_ROOT_DIR = "%s/greybox/";', config.js);
fprintf(fid,'	</script>');
fprintf(fid,'	<script type="text/javascript" src="%s/greybox/AJS.js"></script>', config.js);
fprintf(fid,'	<script type="text/javascript" src="%s/greybox/AJS_fx.js"></script>', config.js);
fprintf(fid,'	<script type="text/javascript" src="%s/greybox/gb_scripts.js"></script>', config.js);
fprintf(fid,'	<link href="%s/greybox/gb_styles.css" rel="stylesheet" type="text/css" />', config.js);
fprintf(fid,'	<!--greybox-->');


fprintf(fid,'<script src="%s/results.js" type="text/javascript"></script>',config.js);

fprintf(fid,'<script src="../../../jmol/Jmol.js" type="text/javascript"></script></head>');
fprintf(fid,'<body onload="setUp();tablecloth();">');

fprintf(fid,'<div class="menu">');
fprintf(fid,'	<ul>');
fprintf(fid,'	<li><a href="%s">WebFR3D</a></li>', config.webroot);
fprintf(fid,'	<li><a href="%s/geometric.php">Geometric Search</a></li>', config.webroot);
fprintf(fid,'	<li><a>Switch to</a>');
fprintf(fid,'		<ul>');
fprintf(fid,'			<li><a href="%s/symbolic.php">Symbolic search</a></li>', config.webroot);
fprintf(fid,'		</ul>');
fprintf(fid,'	</li>');
fprintf(fid,'	</ul>');
fprintf(fid,'</div><br>');


fprintf(fid,'<noscript>Your browser does not support JavaScript. Please turn it on or update your browser</noscript>\n');
fprintf(fid,'<div class="container">');
% fprintf(fid,'<h2 class="center">%s</h2>',filename);

fprintf(fid, '<div class="annotations" id="annotations">');

fprintf(fid,'<div id="root" class="rootdiv" style="left:600px; top:80px;">');
fprintf(fid,'<div id="handle" class="handle">PDB Info<img src="%s/greybox/w_close.gif" alt="Close" id="closewin" onClick="HidePDBDiv()"/></div>',config.js);
fprintf(fid,'<div id="pdbhint"></div>');
fprintf(fid,'</div>');


for c = 1:length(Text),
    fprintf(fid, '%s',Text{c});
end
fprintf(fid,'</div><br>\n');

% fprintf(fid,'<div style="margin-left:auto;margin-right:auto;text-align:center;width:100%%;">');
% if length(Search.Candidates(:,1)) > 1,
%     fprintf(fid,'<a href="%s/%s/%s.png">View Mutual Discrepancy Graph</a>', config.web_pictures,filename,filename);
% end
% fprintf(fid,'</div><br>');

fprintf(fid,'<table class="results"><tr>');
% fprintf(fid,'<td nowrap>');
fprintf(fid,'<td id="jmtd"><div class="jmolwindow">');
fprintf(fid,'<script type="text/javascript">');
fprintf(fid,'jmolInitialize("../../../jmol");');
fprintf(fid,'jmolSetAppletColor("white");');

 if length(Search.Candidates(:,1)) ~= 1,
     fprintf(fid,'jmolApplet(400, ''load files ');
 else
     fprintf(fid,'jmolApplet(400, ''load ');
 end
 for c = 1:min(length(Search.Candidates(:,1)),MAXPDB)
     fprintf(fid, '"%s/%s/%s_%i.pdb" ', config.web_pdbdatabase, filename, filename, c);
 end
 fprintf(fid, ';hide all;spacefill off;frame all;select [U]; color navy; select [C]; color gold;select [G]; color chartreuse; select [A]; color red;select all;display 1.1'');');

% fprintf(fid,'// a radio group');
% fprintf(fid,'jmolHtml("atoms ");');
% fprintf(fid,'jmolRadioGroup([');
% fprintf(fid,'   ["spacefill off",  "off", "checked"],');
% fprintf(fid,'   ["spacefill 20%%",  "20%%"],');
% fprintf(fid,'   ["spacefill 100%%", "100%%"]');
% fprintf(fid,'   ]);');
% fprintf(fid,'jmolBr();');
%fprintf(fid,'// a button');
%fprintf(fid,'jmolButton("reset", "Reset to original orientation");');
% fprintf(fid,'jmolButton("select [U]; color navy; select [C]; color gold;select [G]; color chartreuse; select [A]; color red;select all", "Color by nucleotide");');
fprintf(fid,'</script></div>');
fprintf(fid,'<script>');
fprintf(fid,'jmolBr();');
fprintf(fid,'jmolCheckbox("stereo on", "stereo off","Stereo on/off");');
fprintf(fid,'jmolHtml("&nbsp;&nbsp;");');
fprintf(fid,'jmolCheckbox(''select *.C5;label "%%n%%R";color labels black;'', "labels off", "nucleotide numbers on/off", false);');
% fprintf(fid,'jmolBr();');
fprintf(fid,'</script>');
fprintf(fid,'&nbsp;&nbsp;<input type="checkbox" onclick="SwitchModelLayer();" id="layer"/><label for="layer">16A neighborhood</label><br>');
% fprintf(fid,'Learn more about basepairs at the ');
% fprintf(fid,'<a href="%s">Online Basepair Catalog</a><br><br><br>','http://rna.bgsu.edu/FR3D/basepairs/');

fprintf(fid,'</td>\n');

fprintf(fid,'<td id="cbtd"><br>');
fprintf(fid,'<a href="javascript:previous()" title="keyboard shortcut: j" class="pdblink">Previous</a>&nbsp;|&nbsp;');
fprintf(fid,'<a href="javascript:next()" title="keyboard shortcut: k" class="pdblink">Next</a><br><br>');
fprintf(fid, '<div class="checkboxwrapper">');
fprintf(fid, '<div class="checkboxes" id="layer1">');
fprintf(fid, '<script type = "text/javascript">');
c = 1;
checkboxlist1 = '';
hideall = 'hide all;';
while (c <= min(length(Search.Candidates(:,1)),MAXPDB)),
    thisid =  sprintf('"structure%i"',c);
    if c == 1,
        fprintf(fid,'jmolHtml("<table class=''checklock''><tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i","checked",%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<span><img class=''lock'' id=''lock%i'' src=''%s/images/Lock.png'' onclick=''Lock(%i);''></span>");',c,config.webroot,c);
        fprintf(fid,'jmolHtml("</td></tr>");');
    else
        fprintf(fid,'jmolHtml("<tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i",false,%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<span><img class=''lock'' id=''lock%i'' src=''%s/images/Lock.png'' onclick=''Lock(%i);''></span>");',c,config.webroot,c);
        fprintf(fid,'jmolHtml("</td></tr>");');

%         fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i",false,%s);',c,c,filename,c,thisid);
    end
    checkboxlist1 = strcat(checkboxlist1,thisid,',');
    hideall = sprintf('%sdisplay displayed or %i.1;',hideall,c);
%     fprintf(fid,'jmolBr();');
    c = c+1;
end
checkboxlist1 = checkboxlist1(1:end-1); % remove the last comma
fprintf(fid, '</script></table></div>');

fprintf(fid, '<div class="checkboxes" id="layer0" style="z-index:-1;">');
fprintf(fid, '<script type = "text/javascript">');
c = 1;
checkboxlist0 = '';
while (c <= min(length(Search.Candidates(:,1)),MAXPDB)),
    thisid =  sprintf('"neighbors%i"',c);
    if c == 1,
        fprintf(fid,'jmolHtml("<table class=''checklock''><tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.0","frame all;display displayed and not %i.0","%s %i","checked",%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<img class=''lock'' id=''lock%i'' src=''%s/images/Lock.png'' onclick=''Lock(%i);''>");',c,config.webroot,c);
        fprintf(fid,'jmolHtml("</td></tr>");');
    else
        fprintf(fid,'jmolHtml("<tr><td>");');
        fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.0","frame all;display displayed and not %i.0","%s %i",false,%s);',c,c,filename,c,thisid);
        fprintf(fid,'jmolHtml("</td><td>");');
        fprintf(fid,'jmolHtml("<img class=''lock'' id=''lock%i'' src=''%s/images/Lock.png'' onclick=''Lock(%i);''>");',c,config.webroot,c);
        fprintf(fid,'jmolHtml("</td></tr>");');

%         fprintf(fid,'jmolCheckbox("frame all;display displayed or %i.1","frame all;display displayed and not %i.1","%s %i",false,%s);',c,c,filename,c,thisid);
    end
    checkboxlist0 = strcat(checkboxlist0,thisid,',');
%     fprintf(fid,'jmolBr();');
    c = c+1;
end
checkboxlist0 = checkboxlist0(1:end-1); % remove the last comma
fprintf(fid, '</script></table></div>');

fprintf(fid,'<div class="mastercheckbox" id="master1"><script type = "text/javascript">');
fprintf(fid,'jmolBr();');
fprintf(fid,'jmolCheckbox("%s","frame all; hide all","Show/hide all",false,"mastercheck1");',hideall);
fprintf(fid,'jmolSetCheckboxGroup("mastercheck1",%s);',checkboxlist1);
fprintf(fid,'</script></div>');

hideall = strrep(hideall,'.1','.0');
fprintf(fid,'<div class="mastercheckbox" id="master0"><script type = "text/javascript">');
fprintf(fid,'jmolBr();');
fprintf(fid,'jmolCheckbox("%s","frame all; hide all","Show/hide all",false,"mastercheck0");',hideall);
fprintf(fid,'jmolSetCheckboxGroup("mastercheck0",%s);',checkboxlist0);
fprintf(fid,'</script></div></div>');






fprintf(fid, '</div>');


fprintf(fid,'</td>\n');

% fprintf(fid,'<td class="locks"><br><br><br>');
% c = 1;
% while (c <= min(length(Search.Candidates(:,1)),MAXPDB)),
%     fprintf(fid,'<span><img class="lock" id="lock%i" src="%s/images/Lock.png" onclick="Lock(%i);"></span><br>',c,config.webroot,c);
%     c = c+1;
% end
% fprintf(fid,'</td>\n');


fprintf(fid,'<td><br>');
if length(Search.Candidates(:,1)) > 1,
    fprintf(fid,'<b><a href="%s/%s/%s.png" rel="gb_image[]">Mutual Discrepancy Graph</a></b><br>',config.web_pictures,filename,filename);
    fprintf(fid,'<a href="%s/%s/%s.png"><img src="%s/%s/%s.png" class="mutdisc"></a><br>',config.web_pictures,filename,filename,config.web_pictures,filename,filename);
end
fprintf(fid,'<div class="share">');
fprintf(fid,'<div class="addthis_toolbox addthis_default_style ">')
fprintf(fid,'<a href="http://www.addthis.com/bookmark.php?v=250&amp;username=xa-4d002299773bf696" class="addthis_button_compact">Share</a>')
fprintf(fid,'</div>')
fprintf(fid,'<script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#username=xa-4d002299773bf696"></script>')
fprintf(fid,'</div><br>');
fprintf(fid,'<a href="%s/%s/%s.zip">Download all candidates (.zip)</a><br><br>',config.web_pdbdatabase, filename, filename);
fprintf(fid, '</td></tr></table><br>');
fprintf(fid,'</div></body></html>');
fclose(fid);
disp('File processed');

SendEmail(Search, filename);


end

function [] = ShowMessage(resultsdir,webroot,message,Search,filename)

    if nargin < 5
        filename = '';
    end

    fid = fopen([resultsdir filesep 'results.php'],'w');
    fprintf(fid, '<html><head><link rel="stylesheet" type="text/css" href="../../css/Library.css"><title>WebFR3D results</title></head><body>');
    fprintf(fid, '<div class="message">');
    fprintf(fid, '<h2>Thank you for using WebFR3D</h2><br>');
    fprintf(fid, '<p>%s</p><br><br>',message);
    fprintf(fid, '</div></body></html>');
    fclose(fid);

    if nargin == 5
        SendEmail(Search, filename);
    end

end

function [] = SendEmail(Search, filename)

    get_config();
    if isfield(Search.Query, 'Email')
        link = sprintf('%s/Results/%s', config.webroot, filename);
        message = sprintf('Please visit this webpage to see your WebFR3D results: %s  This is an automated message. For support, email %s.', link, config.email);
        command = sprintf('echo "%s" | tee email.txt | mail -s "WebFR3D results %s" %s; rm email.txt;', message, filename, Search.Query.Email);
        unix(command);
    end

end

