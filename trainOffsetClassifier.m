function [offset_mean_trace, cov_mat, poi] = trainOffsetClassifier(aes_param, traces)
	offset = hex2dec(aes_param(:,4));
	%%%%%%%%%%%%Count number of trace per each offset%%%%%%%%%%%%
	offset_trace_count=zeros(16,1);
	for i=1:length(offset)
		ind=offset(i)+1;
		offset_trace_count(ind)=offset_trace_count(ind)+1;
	end
	%%%%%%%%%%%%Compute mean trace for each offset%%%%%%%%%%%%
	offset_mean_trace=zeros(16, 435002);
	for i=1:16
		cur_offset = i-1;
		index = find(offset == cur_offset);
		offset_mean_trace(i,:) = mean(traces(index,:));
	end
	%%%%%%%%%%%%Find POI%%%%%%%%%%%%
	offset_mean_trace_diff=zeros(1,435002);
	for i=1:16
		for j=1:16
			offset_mean_trace_diff(1,:) = offset_mean_trace_diff(1,:) + offset_mean_trace(i,:) - offset_mean_trace(j,:);
		end
	end
	%plot([1:length(offset_mean_trace_diff)], offset_mean_trace_diff);
	[pks,locs]=findpeaks(offset_mean_trace_diff, 'MinPeakHeight', 1.15*10^-12);
    poi = locs;
	%plot([1:length(offset_mean_trace_diff)], offset_mean_trace_diff, locs, pks);
	%%%%%%%%%%%%Compute noise vector%%%%%%%%%%%%
	noise_traces=zeros(size(traces,1),length(locs));
	for i=1:16
		cur_offset = i-1;
		index = find(offset == cur_offset);
		noise_traces(index,:) = traces(index,locs) - offset_mean_trace(i,locs);
	end
	%%%%%%%%%%%%Compute covariance matrix%%%%%%%%%%%%
	cov_mat = zeros(length(locs),length(locs),16);
	for o=1:16
		cur_offset = o-1;
		index = find(offset == cur_offset);
		cov_mat(:,:,o)=cov(noise_traces(index,:));
	end
end