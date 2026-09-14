function BinairoWriteText(file, text)
% BINAIROWRITETEXT Write UTF-8 bytes without platform newline conversion.
% Status callers provide exact ASCII OK/UNSOLVABLE/ERROR followed by one LF.
% AI-assisted team implementation, 2026. Human attribution: project report.
temporary = [tempname(fileparts(file)) '.txt'];
fid = -1;
try
    [fid, message] = fopen(temporary, 'wb');
    if fid < 0
        error('Binairo:TextWrite', 'Cannot create text output: %s', message);
    end
    bytes = unicode2native(char(text), 'UTF-8');
    count = fwrite(fid, bytes, 'uint8');
    closeStatus = fclose(fid);
    fid = -1;
    if count ~= numel(bytes) || closeStatus ~= 0
        error('Binairo:TextWrite', 'Incomplete text write or close failure.');
    end
    [ok, message] = movefile(temporary, file, 'f');
    if ~ok
        error('Binairo:TextWrite', 'Cannot replace text output: %s', message);
    end
catch exception
    if fid >= 0
        fclose(fid);
    end
    if exist(temporary, 'file') == 2
        delete(temporary);
    end
    rethrow(exception);
end
end
