function ham_weight = hamming_weight(vector)     % Return the variable ham_weight 

ham_weight = sum(dec2bin(vector) == '1', 2).';   % Don't transpose if 
                                                 % you want a column vector
end                                              % endfunction is not a MATLAB command.