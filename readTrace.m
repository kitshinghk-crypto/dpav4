function trace=readTrace(filepath)
    fileId=fopen(filepath);
    fprintf(filepath+"\n");
    trace=fread(fileId, 435359, '*int8');
    trace(1:357)=[];
    fclose(fileId);
end