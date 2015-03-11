function emd = calculateEMD(P,Q,D)


extra_mass_penalty= 0;
% flowType= int32(3);
emd = emd_hat_gd_metric_mex(P,Q,D,extra_mass_penalty);
end