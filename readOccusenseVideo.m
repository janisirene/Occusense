function v = readOccusenseVideo(filename)
fid = fopen(filename);
tline = fgetl(fid);
v = [];
vidx = 1;
while ischar(tline)
    if strcmp(tline, '0')
        tmp = nan(4, 16);
        for i = 1:4
            ln = fgetl(fid);
            if ln == -1
                break;
            end
            tmp(i, :) = str2num(ln);
        end
        if ln ~= -1
            v(:, :, vidx) = tmp;
            vidx = vidx + 1;
        end
    end
    tline = fgetl(fid);
end
fclose(fid);
end