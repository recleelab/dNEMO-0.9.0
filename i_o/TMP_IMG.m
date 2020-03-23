classdef TMP_IMG
    %TMP_IMG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        img_bfreader
        img_filename
        img_filepath
        T
        Z
        C = 1;
        Width
        Height
        Type
        CurrFrameNo
        CurrFrame
        CurrChannel
        Extension
    end
    
    methods
        
        % TMP_IMG constructor
        function obj = TMP_IMG(image_filename, image_filepath)
            
            if ~contains(image_filepath,image_filename)
                image_filepath = fullfile(image_filepath,image_filename);
            end
            
            % assign bioformats reader object
            new_reader = bfGetReader(image_filepath);
            obj.img_bfreader = new_reader;
            obj.img_filename = image_filename;
            obj.img_filepath = image_filepath;
            
            % assign properties derived from bioformats reader object
            obj.T = new_reader.getSizeT();
            obj.Z = new_reader.getSizeZ();
            obj.C = new_reader.getSizeC();
            obj.Width = new_reader.getSizeX();
            obj.Height = new_reader.getSizeY();
            
            % testing out other assignments
            obj.Type = '16bit';
            
            image_str_data = strsplit(image_filename,'.');
            obj.Extension = image_str_data{end};
            
            obj.CurrFrameNo = 0;
            
            if contains(lower(obj.Extension),'tif')
                
                dim_choice = questdlg('Is movie 2D or 3D?',...
                    'Movie dimensions','2D','3D','2D');
                switch dim_choice
                    case '2D'
                        [C] = obj.guessNumChannels();
                        obj.C = C;
                        obj.T = max([obj.Z obj.T]);
                        obj.Z = 1;
                    case '3D'
                        [Z, C, T] = obj.guessZSlices();
                        obj.C = C;
                        obj.Z = Z;
                        obj.T = T;
                end
            end
            
            obj.CurrChannel = min(1:1:obj.C);
            
            obj = obj.setCurrFrame(1);
            
        end
        
        % TMP_IMG.getT
        function [T] = getT(obj)
            T = obj.T;
        end
        
        % TMP_IMG.getZ
        function [Z] = getZ(obj)
            Z = obj.Z;
        end
        
        % TMP_IMG.getC
        function [C] = getC(obj)
            C = obj.C;
        end
        
        % TMP_IMG.getImageDims
        function [x, y, z] = getImageDims(obj)
            x = obj.Width;
            y = obj.Height;
            z = obj.Z;
        end
        
        % TMP_IMG.setCurrFrame
        function obj = setCurrFrame(obj, frame_no)
            
            if obj.CurrFrameNo ~= frame_no
                
                obj.CurrFrameNo = frame_no;
                frameArray = uint16(zeros(obj.Height, obj.Width, obj.Z));
                
                if obj.C == 1
                    for zz=1:obj.Z
                        curr_ind = ((frame_no-1)*obj.Z)+zz;
                        switch obj.Extension
                            case 'tif'
                                frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader,curr_ind);
                            case 'dv'
                                frameArray(:,:,zz) = flip(bfGetPlane(obj.img_bfreader,curr_ind));
                        end
                    end
                    obj.CurrFrame = frameArray;
                else
                    tmp_indexing_arr = obj.CurrChannel:obj.C:obj.Z*obj.C;
                    for zz=1:1:length(tmp_indexing_arr)
                        curr_ind = ((frame_no-1)*(obj.Z*obj.C))+tmp_indexing_arr(zz);
                        assignin('base','curr_ind',curr_ind);
                        switch obj.Extension
                            case 'tif'
                                frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader,curr_ind);
                            case 'dv'
                                frameArray(:,:,zz) = flip(bfGetPlane(obj.img_bfreader,curr_ind));
                        end
                    end
                    obj.CurrFrame = frameArray;
                end
            end
        end
        
        % TMP_IMG.getCurrFrame
        function frameArray = getCurrFrame(obj)
            
            frameArray = obj.CurrFrame;
            
            %{
            curr_frame_no = obj.CurrFrameNo;
            
            frameArray = uint16(zeros(obj.Width, obj.Height, obj.Z));
            
            for zz=1:obj.Z
                curr_ind = ((curr_frame_no-1)*obj.Z)+zz;
                switch obj.Extension
                    case 'tif'
                        frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader,curr_ind);
                    case 'dv'
                        frameArray(:,:,zz) = flip(bfGetPlane(obj.img_bfreader,curr_ind));
                end
            end
            %}
            
        end
        
        % TMP_IMG.getZProject
        function max_proj = getZProject(obj)
            frameArray = obj.getCurrFrame();
            max_proj = max(frameArray,[],3);
        end
        
        % TMP_IMG.getZSlice
        function image_slice = getZSlice(obj, slice)
            frameArray = obj.getCurrFrame();
            image_slice = frameArray(:,:,slice);
        end
        
        % TMP_IMG.guessZSlices
        function [Z, C, T] = guessZSlices(obj)
            
            % num_frames = max([obj.Z obj.T]);
            num_frames = obj.Z * obj.T;
            
            arb_num = 45;
            
            if num_frames < arb_num
                frameArray = uint16(zeros(obj.Height, obj.Width, num_frames));
                for zz=1:num_frames
                    frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader,zz);
                end
            else
                frameArray = uint16(zeros(obj.Height, obj.Width, arb_num));
                for zz=1:arb_num
                    frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader,zz);
                end
            end
            
            hi_lo_arr = zeros(size(frameArray,3),2);
            for m=1:size(frameArray,3)
                hi_lo_arr(m,:) = stretchlim(frameArray(:,:,m));
            end
            
            [~,locs_c] = findpeaks(hi_lo_arr(:,2));
            
            if size(locs_c,1) > 1
                locs_dist = zeros(size(locs_c,1)-1,1);
                locs_dist(1,1) = locs_c(1,1)-1;
                for n=2:size(locs_c,1)
                    locs_dist(n,1) = locs_c(n,1)-locs_c(n-1,1);
                end
                tmp_C = mode(locs_dist);
            else
                tmp_C = 1;
            end
            
            if tmp_C > 1
                [~,locs] = findpeaks(hi_lo_arr(1:tmp_C:length(hi_lo_arr),1));
            else
                [~,locs] = findpeaks(hi_lo_arr(:,1));
            end
            
            if size(locs,1) > 1
                locs_dist = zeros(size(locs,1)-1,1);
                locs_dist(1,1) = locs(1,1)-1;
                for n=2:size(locs,1)
                    locs_dist(n,1) = locs(n,1)-locs(n-1,1);
                end
                tmp_Z = mode(locs_dist);
            else
                tmp_Z = num_frames;
            end
            
            prompt = {'Confirm number of channels:','Confirm number of z-slices:'};
            dlg_title = 'Image info';
            num_lines = 1;
            default_ans = {num2str(tmp_C), num2str(tmp_Z)};
            answer = inputdlg(prompt, dlg_title, num_lines, default_ans);
            
            C = str2double(answer{1});
            Z = str2double(answer{2});
            T = round(num_frames/(Z*C));
            
        end
        
        % TMP_IMG.guessNumChannels
        function [C] = guessNumChannels(obj)
            
            num_frames = obj.Z * obj.T;
            
            if num_frames < 30
                frameArray = uint16(zeros(obj.Height, obj.Width, num_frames));
                for zz=1:num_frames
                    frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader,zz);
                end
            else
                frameArray = uint16(zeros(obj.Height, obj.Width, 30));
                for zz=1:30
                    frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader,zz);
                end
            end
            
            hi_lo_arr = zeros(size(frameArray,3),2);
            for m=1:size(frameArray,3)
                hi_lo_arr(m,:) = stretchlim(frameArray(:,:,m));
            end
            
            % looking at -relative- differences between top 10 percent of
            % pixels
            [~,locs] = findpeaks(hi_lo_arr(:,2));
            if size(locs,1) > 1
                locs_dist = zeros(size(locs,1)-1,1);
                locs_dist(1,1) = locs(1,1)-1;
                for n=2:size(locs,1)
                    locs_dist(n,1) = locs(n,1)-locs(n-1,1);
                end
                C = mode(locs_dist);
            else
                C = 1;
            end
            
        end
        
    end
end

