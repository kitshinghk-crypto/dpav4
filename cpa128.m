function best_key_guess=cpa128(aes_param, traces, predicted_offset, poi)
    %corr_max_pt=[99012 ;98989 ;141789 ;10293 ;103963 ;108525 ;142058 ;20065 ;113220 ;26365 ;151312 ;27656 ;113488 ;117540 ;151581 ;38836 ;118254 ;43743 ;160835 ;48072 ;123011 ;52414 ;165596 ;53707 ;132266 ;131825 ;170359 ;170340 ;132533 ;136586 ;338553 ;171593; 343310; 343044; 350309; 348926; 356191; 354808; 360956; 360691; 366579; 366572; 372720; 372301; 379719; 378336; 384479; 384220; 389947; 391482; 396247; 395983; 401713; 401866; 408009; 407748; 415010; 413627; 420893; 420891; 426775; 425391; 432376; 432372];
    %corr_max_pt = [99012; 98989; 137300; 10291; 103965; 108016; 142061; 19789; 113218; 26364; 146823; 30153; 113491; 117540; 151585; 152850; 118254; 43743; 156346; 48072; 123015; 52414; 161108; 53709; 127777; 132247; 170357; 170340; 132538; 136586; 170631; 171593];
    aes_param(:,4) = predicted_offset;  
    best_key_guess="";
    for byte_num=1:32
        trace_corr=zeros(16, 1);
        for key_guess=0:15
            key_string="00000000000000000000000000000000";
            key_string=replaceBetween(key_string, byte_num, byte_num,dec2hex(key_guess));
            keys=strings(size(aes_param,1),1)+key_string;
            aes_param(:,1) = keys;
            initAddRoundKey=retrieveInitAddRoundKey(aes_param);
            iARK_1byte_hw=zeros(size(traces,1),1);
            for i=1:size(traces,1)
                iARK_1byte_hw(i,1) = hamming_weight(hex2dec(extractBetween(initAddRoundKey(i), byte_num, byte_num)));
            end
            c=corrcoef(iARK_1byte_hw(:,1), traces(:,poi(byte_num)));
            trace_corr(key_guess+1,1)=c(1,2);
        end
        corr_key_guess=trace_corr(:,1);
        best_guess=find(corr_key_guess==max(corr_key_guess))-1;
        best_key_guess = best_key_guess + string(string(dec2hex(best_guess)));
        fprintf("%x",best_guess);
    end
    fprintf("\n");
end