%% Documentation   
% Example script to create a Campbell diagram with OpenFAST
%
% NOTE: this script is only an example.
% Adapt this scripts to your need, by calling the different subfunctions presented.
%
%% Initialization
clear all; close all; clc; 
restoredefaultpath;
addpath(genpath('C:/Work/FAST/matlab-toolbox'));

%% Parameters

% Main Flags
writeFASTfilesAndRun = true; % write FAST input files and Run OpenFAST
postproLin           = true;
outputFormat='xls';

FASTexe = '..\..\_ExampleData\5MW_Land_Lin\openfast2.3_x64s.exe'; % Adapt


templateFstFile     = '../../_ExampleData/5MW_Land_Lin_Templates/Main_5MW_Land_Lin.fst'; 
%       Template file used to create linearization files. 
%       This template file should point to a valid ElastoDyn file, and,
%       depending on the linearization type, valid AeroDyn, InflowWind and Servodyn files.

simulationFolder    = '../../_ExampleData/5MW_Land_Lin/';
%      Folder where OpenFAST simulation are run for the linearization.
%      OpenFAST Input files will be created there.
%      Should contain all the necessary files for a OpenFAST simulation
%      Will be created if does not exists

operatingPointsFile = 'LinearizationPoints.csv'; 
%      Optional, define a file with operating conditions where linearization is to occur.
%      Alternatively, you can define this data into a matlab structure. See Step 1
%      
%      


%% --- Step 1: Create a structure or file with operating points where linearization is to occur
% NOTE: 
%       The file written is a CSV file with one line of header.  
%       The file should at the minimum contain `WindSpeed` or `RotorSpeed`
%       The file can contain a column `Filename` with a list of "fst" files, for custom filenames.
%       Comment this section if the file is already generated by another script
OP=struct();
OP.WindSpeed        = [3     ,  5      , 7       , 9      , 11     , 13     , 15     , 17     , 19     , 21     , 23     , 25   ]; %(m/sec)
OP.RotorSpeed       = [6.972 ,  7.506  , 8.469   , 10.296 , 11.89  , 12.1   , 12.1   , 12.1   , 12.1   , 12.1   , 12.1   , 12.1 ]; %(rpm)
OP.BladePitch       = [0     ,  0      , 0       , 0      , 0      , 6.602  , 10.45  , 13.536 , 16.226 , 18.699 , 21.177 , 23.469]; % (deg)
OP.GeneratorTorque  = [0.606 ,  5.611  , 14.62   , 25.51  , 40.014 , 43.094 , 43.094 , 43.094 , 43.094 , 43.094 , 43.094 , 43.094]*1000; %(N-m)

writeOperatingPoints(operatingPointsFile, OP);
%OP = readOperatingPoints(operatingPointsFile);

%% --- Step 2: Write OpenFAST inputs files for each operating points and run OpenFAST
% NOTE: 
%      The function can take an operatingPointsFile or the structure OP above.
%      Comment this section if the inputs files were already generated
%      See writeLinearizationFiles for key/value arguments available.
%      Consider writing your own batch file and parallize the computations of runFAST.
if writeFASTfilesAndRun
    FASTfilenames = writeLinearizationFiles(templateFstFile,simulationFolder,operatingPointsFile);
end
%      Comment this section if the simulations were already run
if writeFASTfilesAndRun
    [FASTfilenames] = getFullFilenamesOP(simulationFolder, operatingPointsFile);
    runFAST(FASTfilenames, FASTexe);
end

%% --- Step 3: Run MBC, identify modes and generate XLS or CSV file
% NOTE:  
%       Select csv output format if XLS not available
%       For now, csv outputs cannot be used for Campbell diagram plot
if postproLin
    [ModesData, outputFiles] = postproLinearization(simulationFolder, operatingPointsFile, outputFormat);
end


%% --- Step 4: Campbell diagram plot
%Plot_CampbellData(outputFiles);
