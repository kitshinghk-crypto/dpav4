# dpav4
This repository contains the MATLAB scirpts, which perform power analysis attacks on the AES-256 RSM (v4) in [DPA contest v4](http://www.dpacontest.org/v4/index.php)

# The attacks
The cryptographic operation under attack is the implementation of AES-256 RSM. The details of the implementation is described in [this paper](http://www.dpacontest.org/v4/data/rsm/aes-rsm.pdf)

The AES-256 RSM uses masks, which is publicly known information, to blur the information of the key used. The sequence of the mask used in each AES execution is different based on a random variable. This variable is descirbed as **offset**, which has a range from 0 to 15. 

The attack is divied into two phases: 
1. Perform a template attack to recover the value of the offset used.
2. Perform a correlation power analysis(CPA) attacks to recover the value of the secret key based on the value of the offset found in phase 1.

## Phase 1: Template attacks 
The implementation of the template attacks the basic template attack, which is based on [this paper](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.126.6474&rep=rep1&type=pdf). The goal of the template attacks is to recover the value of the offset. In the profiling phase of the template attacks, 16 templates (for value 0-15) are constructed. Suppose now a power trace with a unknown offset is given. The value of the offset is recovered by computing the probability density function using the unknown trace and the templates. The value of the offset is then determined by the template which give the highest probability.

## Phase 2: Correlation power analysis(CPA) attacks
The CPA attack implemented is based on [this paper](https://link.springer.com/content/pdf/10.1007/978-3-540-28632-5_2.pdf). The implemented CPA attacks exploits the first add round key of the AES implementaion. In basic AES, the first round key is the secret key. In AES-256 RSM, the first round key equals **Mask XOR key**. The  attack computes the correlation between the hamming weight of each possible choice of key and the power consumption. The value of the secret key used is determined by the key candidate whose hamming weight produces the highest corrleation with the power consumption.

## Example 
```matlab
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

%%%%%%%%%%%%Use first 1000 traces to train. attack on the rest 1000 traces%%%%%%%%%%%%
trIdx=1:1000;
teIdx=1001:2000;
[offset_mean_trace, cov_mat, poi] = trainOffsetClassifier(aes_param(trIdx, :), traces(trIdx, :));
result=offsetClassifier(offset_mean_trace, cov_mat, poi, traces(teIdx, :));
poi = trainCpa(aes_param(trIdx, :), traces(trIdx, :));
key_cand=cpa128(aes_param(teIdx, :), traces(teIdx, :), result, poi);
```

## Attack result
Perform 5 2-fold validation on 2000 traces i.e. 1000 traces for training and 1000 traces for test
```matlab
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
%%%%%%%%%%%%Perform k-fold to classify offset%%%%%%%%%%%%
actual_key="6CECC67F287D083DEB8766F0738B36CF";
fold = 2;
foldtest_num = 5;
foldtest_err = zeros(foldtest_num, 1);
for count=1:foldtest_num
    c = cvpartition(zeros(2000,1), 'KFold', fold);
    err = zeros(c.NumTestSets,1);
    for i = 1:c.NumTestSets
        trIdx = c.training(i);
        teIdx = c.test(i);
        fprintf("Round=%d start training template on offset\n", i);
        [offset_mean_trace, cov_mat, poi] = trainOffsetClassifier(aes_param(trIdx, :), traces(trIdx, :));
        fprintf("Round=%d start classifer offset\n", i);
        result=offsetClassifier(offset_mean_trace, cov_mat, poi, traces(teIdx, :));
        fprintf("Round=%d start train cpa\n", i);
        poi = trainCpa(aes_param(trIdx, :), traces(trIdx, :));
        fprintf("Round=%d start cpa on key\n", i);
        key_cand=cpa128(aes_param(teIdx, :), traces(teIdx, :), result, poi);
        err(i) = pdist2(actual_key, key_cand, "hamming")*128/4;
    end
    foldtest_err(count) = mean(err);
end
foldtest_err
```
**Result**
```
Round=1 start training template on offset
Round=1 start classifer offset
Round=1 start train cpa
Round=1 start cpa on key
6cecc67f287d083deb8362f0728b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=2 start training template on offset
Round=2 start classifer offset
Round=2 start train cpa
Round=2 start cpa on key
6cecc67f287d0a35eb8362f0728b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=1 start training template on offset
Round=1 start classifer offset
Round=1 start train cpa
Round=1 start cpa on key
6cecc67f287d0835eb8362f0728b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=2 start training template on offset
Round=2 start classifer offset
Round=2 start train cpa
Round=2 start cpa on key
6cecc67f287d083deba366f0728b34cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=1 start training template on offset
Round=1 start classifer offset
Round=1 start train cpa
Round=1 start cpa on key
6cecc67f287d0835eb8366f0738b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=2 start training template on offset
Round=2 start classifer offset
Round=2 start train cpa
Round=2 start cpa on key
6cecc67b287d083deb8362f0728b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=1 start training template on offset
Round=1 start classifer offset
Round=1 start train cpa
Round=1 start cpa on key
6cecc67f287d0a35eb8362f0738b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=2 start training template on offset
Round=2 start classifer offset
Round=2 start train cpa
Round=2 start cpa on key
6cecc67f287d083d6b8366f0728b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=1 start training template on offset
Round=1 start classifer offset
Round=1 start train cpa
Round=1 start cpa on key
6cecc67f2875083deb8362f0728b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 
Round=2 start training template on offset
Round=2 start classifer offset
Round=2 start train cpa
Round=2 start cpa on key
6cecc67f287d0835eb8366f0738b36cf
Warning: Converting input data to double. 
> In pdist2 (line 253) 

foldtest_err =

    4.0000
    4.0000
    3.0000
    3.5000
    3.0000
```
The attack on average can recover 89% of the secret key.
