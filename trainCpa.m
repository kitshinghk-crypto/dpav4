function poi=trainCpa(aes_param, traces)
    initAddRoundKey=retrieveInitAddRoundKey(aes_param);
    total_byte_num=32;
    trace_corr=zeros(total_byte_num, size(traces,2));
    iARK_1byte_hw=zeros(size(traces,1),total_byte_num);
    for byte_num=1:total_byte_num
        for i=1:size(traces,1)
            iARK_1byte_hw(i,byte_num) = hamming_weight(hex2dec(extractBetween(initAddRoundKey(i), byte_num, byte_num)));
        end
    end
    for byte_num=1:total_byte_num
        for i=1:size(traces,2)
            c=corrcoef(iARK_1byte_hw(:,byte_num), traces(:,i));
            trace_corr(byte_num,i)=c(1,2);
        end
    end
    poi=zeros(32,1);
    for i = 1:32
        ind=find(trace_corr(i,:)==max(trace_corr(i,:)));
        poi(i,1) = ind;
    end
end