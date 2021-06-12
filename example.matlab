%%%%%%%%%%%%Import traces  %%%%%%%%%%%%
traces = importTraces("./DPA_contestv4_rsm/10000", 10000, 12000);
%%%%%%%%%%%%Read index file%%%%%%%%%%%%
index_file = "dpav4_rsm_index.txt";
opts=delimitedTextImportOptions();
opts.Delimiter=" ";
opts.VariableNames=["key","plain_text","cipher_text","offset","dir_name","file_name"];
opts.VariableTypes=["string","string","string","string","string","string"];
opts.DataLines=[10001 12001];
aes_param = readmatrix(index_file, opts);

%%%%%%%%%%%%Use first 1000 traces to tain. attack on the rest 1000 traces%%%%%%%%%%%%
trIdx=1:1000;
teIdx=1001:2000;
[offset_mean_trace, cov_mat, poi] = trainOffsetClassifier(aes_param(trIdx, :), traces(trIdx, :));
result=offsetClassifier(offset_mean_trace, cov_mat, poi, traces(teIdx, :));
poi = trainCpa(aes_param(trIdx, :), traces(trIdx, :));
key_cand=cpa128(aes_param(teIdx, :), traces(teIdx, :), result, poi);

actual_key="6CECC67F287D083DEB8766F0738B36CF";
err = pdist2(actual_key, key_cand, "hamming")*128/4;