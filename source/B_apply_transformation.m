function []=B_apply_transformation(output_folder, image_or_path, transformation, enable_normalization, batch_size)
    % output_folder = where to save the transformed descriptors
    % image_or_path = path to a folder or to a single image descriptor, the transformation will be applied to all files in the folder, or to the indicated image descriptor
    % transformation = full path to the transformation file, generated in the step A; it should be a .mat file
    % enable_normalization = normalize features after applying the transformation (optional)

    if ~exist('output_folder', 'var')
        throw(MException('B_apply_transformation:output_folder', 'ERROR: Parameter output_folder is empty.'));
    end
    if ~exist('image_or_path', 'var')
        throw(MException('B_apply_transformation:image_or_path', 'ERROR: Parameter image_or_path is empty.'));
    end
    if ~exist('transformation', 'var') || isempty(transformation)
        if ~exist('enable_normalization', 'var') || ~enable_normalization
            throw(MException('B_apply_transformation:transformation', 'ERROR: Parameter transformation is empty.'));
        else
            expname = 'N';
        end
    end
    if ~exist('enable_normalization', 'var')
        enable_normalization = false;
    end
    if ~exist('batch_size', 'var')
        batch_size = 500;
    end

    fcommon = BaseFunctions.getInstance;
    fprintf('Loading image list...\n');
    [folder_path, image_list] = fcommon.get_image_list(image_or_path);
    nimages = numel(image_list);
    nbatches = ceil(nimages / batch_size);
    
    fprintf('Loading transformation...\n');
    if exist('transformation', 'var') && ~isempty(transformation)
        transformation_info = load(transformation);
    end

    function save_feature_vector(feature_vector, file_name, image_or_path, output_folder, fcommon, enable_normalization)
        if enable_normalization
            no = norm(feature_vector);
            feature_vector = feature_vector ./ no;
        end
        fcommon.save_feature_vector(feature_vector, sprintf('%s/%s', output_folder, file_name));
    end

    for nbatch = 1:nbatches
        position = (nbatch - 1) * batch_size;
        this_batch_size = min(batch_size, nimages - position);
        [feature_matrix] = fcommon.load_image_batch(folder_path, image_list(position+1:position+this_batch_size), position, nimages);
        switch transformation_info.expname
            case 'DR'
                switch transformation_info.exptype
                    case 1
                        chosen = randperm(size(feature_matrix, 2));
                        feature_matrix = feature_matrix(:,chosen(1:transformation_info.dimension_list));
                    case 2
                        feature_matrix = feature_matrix * transformation_info.pca_matrix;
                    otherwise
                        throw(MException('apply_transformation:exptype', sprintf('ERROR: Unknown exptype (%d) for %d in %s.', exptype, transformation_info.expname, char(varargin(i)))));
                end
            case 'Q'
                switch transformation_info.exptype
                    case 1
                        feature_matrix = interp1(transformation_info.dictionary, transformation_info.dictionary, feature_matrix, 'nearest', 'extrap');
                    case 2
                        for index = 1:size(transformation_info.dictionary,2)
                            unique_dictionary = unique(transformation_info.dictionary(:,index));
                            if numel(unique_dictionary) == 1
                                feature_matrix(:,index) = unique_dictionary(1);
                            else
                                feature_matrix(:,index) = interp1(unique_dictionary, unique_dictionary, feature_matrix(:,index), 'nearest', 'extrap');
                            end
                        end
                    otherwise
                        throw(MException('apply_transformation:exptype', sprintf('ERROR: Unknown exptype (%d) for %d in %s.', transformation_info.exptype, transformation_info.expname, char(varargin(i)))));
                end
            case 'N'
                % nothing to do
            otherwise
                throw(MException('apply_transformation:expname', sprintf('ERROR: Unknown expname (%s) in %s.', transformation_info.expname, char(varargin(i)))));
        end

        fprintf('Saving %d processed files...\n', this_batch_size);
        for nfile = 1:this_batch_size
            [ign, file_name, ign] = fileparts(char(image_list(position+nfile)));
            save_feature_vector(feature_matrix(nfile,:), file_name, image_or_path, output_folder, fcommon, enable_normalization);
        end
    end
    fprintf('Done.\n\n');
end
