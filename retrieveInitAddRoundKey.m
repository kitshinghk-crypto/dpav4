function initAddRoundKey=retrieveInitAddRoundKey(aes_param)
    mask=["00"; "0f"; "36"; "39"; "53"; "5c"; "65"; "6a"; "95"; "9a"; "a3"; "ac"; "c6"; "c9"; "f0"; "ff"];
    offset=hex2dec(aes_param(:,4));
    plaintext= aes_param(:,2);
    key= aes_param(:,1);
    firstRoundKey_mask=strings(size(aes_param,1),1);
    initAddRoundKey = strings(size(aes_param,1),1);
    for i=0:15
        firstRoundKey_mask(:) = firstRoundKey_mask(:) + mask(mod(offset+i, length(mask))+1);
    end
    for i=1:32
        mask_byte=extractBetween(firstRoundKey_mask, i, i);
        plaintext_byte=extractBetween(plaintext, i, i);
        key_byte=extractBetween(key, i, i);
        roundKey_byte=dec2hex(bitxor(bitxor(hex2dec(mask_byte), hex2dec(plaintext_byte)), hex2dec(key_byte)));
        initAddRoundKey(:) = initAddRoundKey(:) + roundKey_byte;
    end
end