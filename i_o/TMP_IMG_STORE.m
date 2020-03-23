classdef TMP_IMG_STORE
    % TMP_IMG_STORE class description here
    % properties
    properties
        tmp_img_arr = {};
        tmp_img = [];
        src_pointer
        ref_pointer
    end
    
    % methods
    methods
        
        % CONSTRUCTOR
        function obj = TMP_IMG_STORE(TMP_IMG)
            obj.tmp_img_arr{1} = TMP_IMG;
            obj.tmp_img = obj.tmp_img_arr{1};
            obj.src_pointer = 1;
            obj.ref_pointer = 0;
        end
        
        % TMP_IMG_STORE.addImage
        function obj = addImage(obj, TMP_IMG)
            obj.tmp_img_arr = cat(1,obj.tmp_img_arr,{TMP_IMG});
            obj.src_pointer = cat(1,obj.src_pointer,0);
            obj.ref_pointer = cat(1,obj.ref_pointer,1);
        end
        
    end
end