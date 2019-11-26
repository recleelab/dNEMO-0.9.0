%  Detecting NEMO (dNEMO) v 1.0
%  
%  wavelet-based detection application for near-diffraction-limited objects
%  Copyright (c) 2019 Gabriel J Kowalczyk
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <https://www.gnu.org/licenses/>.
%  
%  manuscript: dNEMO: a tool for quantification of punctate structures in
%              time-lapse images of single cells
% 
%  authors: Gabriel J Kowalczyk, J Agustin Cruz, Yue Guo, 
%           Qiuhong Zhang, Natalie Sauerwald, & Robin E.C. Lee
%  
%  INPUT
%  		<tif> or <dv> image file
% 
%  OUTPUT
%  		<filename>_full_results.mat
%  		Basic output which can reconstitute results in dNEMO.
% 	 	<filename>_ALL_SPOTS.mat
% 		Detailed output which contains all KEYFRAME data (all detected 
%       objects for a given KEYFRAME).
%       <filename>_ALL_CELLS.mat
%       Detailed output which contains all CELL data (spots, features
%       associated to individual cells).
% 		<filename>_detected_spots.avi
% 		[description]

% %%%%%%%%% %% %%%%%%%%% %% %%%%%%%%% %% %%%%%%%%% %% %%%%%%%%% %
%%% %%%%% %%%%%% %%%%% %%%%%% %%%%% %%%%%% %%%%% %%%%%% %%%%% %%%
%%%%% % %%%%%%%%%% % %%%%%%%%%% % %%%%%%%%%% % %%%%%%%%%% % %%%%%
%%% %%%%% %%%%%% %%%%% %%%%%% %%%%% %%%%%% %%%%% %%%%%% %%%%% %%%
% %%%%%%%%% %% %%%%%%%%% %% %%%%%%%%% %% %%%%%%%%% %% %%%%%%%%% %  

[APP] = create_figure();