function result=offsetClassifier(offset_mean_trace, cov_mat, poi, test_traces)
    num_test = size(test_traces,1);
    result = zeros(num_test, 1);
    for j=1:num_test
        prob=zeros(16,1);
        for i=1:16
            test_noise_trace=offset_mean_trace(i,poi) - double(test_traces(j,poi));
            cov_matrix=cov_mat(:,:,i);
            p1=1/sqrt(det(cov_matrix)*(2*pi)^length(poi));
            p2=exp(-0.5*test_noise_trace*inv(cov_matrix)*test_noise_trace.');
            prob(i) = p1 * p2;
        end
        classify_result = find(prob == max(prob)) -1;
        if (length(classify_result)>1)
            fprintf("%g ", classify_result);
            fprintf("\n");
            classify_result = classify_result(1);
        end
        result(j,1) = classify_result;
    end
end
    