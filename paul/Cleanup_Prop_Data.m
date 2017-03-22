function [TLE,distance] = Cleanup_Prop_Data(TLE,distance)

% chauvenet's criterion
% https://www.google.nl/search?num=50&safe=active&q=chauvenet%27s+criterion&oq=chauvenet&gs_l=serp.1.2.0i67k1j0j0i67k1j0l7.3258.3258.0.5388.1.1.0.0.0.0.167.167.0j1.1.0....0...1.1.64.serp..0.1.167.MZHl6pbf75A

tsince_all = zeros(length(TLE.epoch_jd),1);

for index = 2:1:length(TLE.epoch_jd)
    tsince_all(index) = (TLE.epoch_jd(index)-TLE.epoch_jd(index-1))*1440;
end

sigma_tsince = std(tsince_all);
sigma_dist = std(distance(:,3));

avg_tsince = mean(tsince_all);
avg_dist = mean(distance(:,3));

data_prob = 1/(2*length(TLE.epoch_jd));
data_ptest = 1-data_prob/2;

zc = norminv(data_ptest,0,1);

tsince_zscore = (tsince_all-avg_tsince)/sigma_tsince;
dist_zscore = (distance(:,3)-avg_dist)/sigma_dist;

tsince_max = avg_tsince+zc*sigma_tsince;
dist_max = avg_dist+zc*sigma_dist;

% logical vector for rows to delete
deleterow = false(length(TLE.epoch_jd),1);

% loop over all lines
for index = 1:length(TLE.epoch_jd)
    if ((tsince_all(index) > tsince_max) || (distance(index,3) > dist_max))
        deleterow(index) = true;
    end
end

distance(deleterow,:) = [];

TLE.catnum(deleterow) = [];
TLE.epoch(deleterow) = [];
TLE.epoch_jd(deleterow) = [];
TLE.xndt2o(deleterow) = [];
TLE.xndd6o(deleterow) = [];
TLE.iexp(deleterow) = [];
TLE.bstar(deleterow) = [];
TLE.ibexp(deleterow) = [];
TLE.xincl(deleterow) = [];
TLE.xnodeo(deleterow) = [];
TLE.eo(deleterow) = [];
TLE.omegao(deleterow) = [];
TLE.xmo(deleterow) = [];
TLE.xno(deleterow) = [];


end