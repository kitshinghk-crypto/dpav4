function traces=importTraces(folder, start_trace_num, end_trace_num)
    traces = zeros(end_trace_num-start_trace_num+1, 435002);
    file_prefix = folder+"/Z1Trace";
    for i=start_trace_num:end_trace_num-1
           file = file_prefix + sprintf("%05d",i)+".trc";
           traces(i-start_trace_num+1,:)=reshape(readTrace(file), [1 435002]);
    end
end