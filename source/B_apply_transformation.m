function []=B_apply_transformation(output_folder, image_or_path, transformation, enable_normalization)
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
    if ~exist('transformation', 'var') || isnan(transformation)
        if ~exist('enable_normalization', 'var') || ~enable_normalization
            throw(MException('B_apply_transformation:transformation', 'ERROR: Parameter transformation is empty.'));
        else
            expname = 'N';
        end
    end
    if ~exist('enable_normalization', 'var')
        enable_normalization = false;
    end

    fcommon = BaseFunctions.getInstance;
    if isdir(image_or_path)
        [feature_matrix, files] = fcommon.load_folder(image_or_path);
    else
        feature_matrix = fcommon.load_file(image_or_path);
    end
    
    fprintf('Applying transformation...\n');
    if exist('transformation', 'var') && ~isnan(transformation)
        load(transformation);
    end
    switch expname
        case 'DR'
            switch exptype
                case 1
                    chosen = randperm(size(feature_matrix, 2));
                    feature_matrix = feature_matrix(:,chosen(1:dimension_list));
                case 2
                    feature_matrix = feature_matrix * pca_matrix;
                otherwise
                    throw(MException('apply_transformation:exptype', sprintf('ERROR: Unknown exptype (%d) for %d in %s.', exptype, expname, char(varargin(i)))));
            end
        case 'Q'
            switch exptype
                case 1
                    feature_matrix = interp1(dictionary, dictionary, feature_matrix, 'nearest', 'extrap');
                case 2
                    for index = 1:size(dictionary,2)
                        unique_dictionary = unique(dictionary(:,index));
                        if numel(unique_dictionary) == 1
                            feature_matrix(:,index) = unique_dictionary(1);
                        else
                            feature_matrix(:,index) = interp1(unique_dictionary, unique_dictionary, feature_matrix(:,index), 'nearest', 'extrap');
                        end
                    end
                otherwise
                    throw(MException('apply_transformation:exptype', sprintf('ERROR: Unknown exptype (%d) for %d in %s.', exptype, expname, char(varargin(i)))));
            end
        case 'N'
            % nothing to do
        otherwise
            throw(MException('apply_transformation:expname', sprintf('ERROR: Unknown expname (%s) in %s.', expname, char(varargin(i)))));
    end
    fprintf('Done.\n\n');

    function save_feature_vector(feature_vector, file_name, image_or_path, output_folder, fcommon, enable_normalization)
        if enable_normalization
            no = norm(feature_vector);
            feature_vector = feature_vector ./ no;
        end
        fcommon.save_feature_vector(feature_vector, sprintf('%s/%s', output_folder, file_name));
    end

    if isdir(image_or_path)
        for nfile = 1:numel(files)
            [ign, file_name, ign] = fileparts(char(files(nfile)));
            save_feature_vector(feature_matrix(nfile,:), file_name, image_or_path, output_folder, fcommon, enable_normalization);
        end
    else
        [ign, file_name, ign] = fileparts(image_or_path);
        save_feature_vector(feature_matrix, file_name, image_or_path, output_folder, fcommon, enable_normalization);
    end
end
