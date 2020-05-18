function postProcess
% This function calls extractMeasuredFromCSV, MeasuredAndSimulated, 
% and measVsim for stats and plots

extractMeasuredFromCSV;
MeasuredAndSimulated;
measVsim;
lowFlowAnalysis;

