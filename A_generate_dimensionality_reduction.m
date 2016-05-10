function []=A_generate_dimensionality_reduction(save_path, experiment_name, train_folder, reduction_type, ndesired_dimensions, base_reduction_file)
    % save_path = path to save the transformation files, necessary for applying the transformation later
    % experiment_name = name of the experiment
    % train_folder = path to the train folder, the transformation will be calculated based on it
    % reduction_type = random (1) or PCA-based (2)
    % ndesired_dimensions = number of desired dimensions to preserve
    % base_reduction = descriptor of the previous reduction, in order to ensure the new reduction is contained in the previous (optional).
    
    if ~exist('save_path', 'var')
        throw(MException('A_generate_dimensionality_reduction:save_path', 'ERROR: Parameter save_path is empty.'));
    end
    if ~exist('experiment_name', 'var')
        throw(MException('A_generate_dimensionality_reduction:experiment_name', 'ERROR: Parameter experiment_name is empty.'));
    end
    if ~exist('train_folder', 'var')
        throw(MException('A_generate_dimensionality_reduction:train_folder', 'ERROR: Parameter train_folder is empty.'));
    end
    if ~exist('reduction_type', 'var')
        throw(MException('A_generate_dimensionality_reduction:reduction_type', 'ERROR: Parameter reduction_type is empty.'));
    end
    if ~exist('ndesired_dimensions', 'var')
        throw(MException('A_generate_dimensionality_reduction:ndesired_dimensions', 'ERROR: Parameter ndesired_dimensions is empty.'));
    end
    
    fprintf('Initiating %s.\n', experiment_name);
    if reduction_type == 1
        fprintf('- Random dimensionality reduction enabled;\n\n');
    elseif reduction_type == 2
        fprintf('- PCA dimensionality reduction enabled;\n\n');
    else
        throw(MException('dimensionality_reduction:reduction_type', sprintf('ERROR: Invalid reduction_type value (%d).\nreduction_type should be 1 (random) or 2 (PCA).', reduction_type)));
    end

    fcommon = BaseFunctions.getInstance;
    if exist('base_reduction_file', 'var')
        load(base_reduction_file);
        if ~(exist('pca_matrix', 'var') && exist('dimension_list', 'var'))
            throw(MException('dimensionality_reduction:base_reduction_file', sprintf('ERROR: The base reduction file provided doesn''t contain the necessary variables pca_matrix and dictionary (%s).', base_reduction_file)));
        end
        base_dimensions = dimension_list;
        if ndesired_dimensions > size(pca_matrix, 2)
            throw(MException('dimensionality_reduction:ndesired_dimensions', sprintf('ERROR: You can''t increase the number of dimensions (%d > %d).', ndesired_dimensions, size(pca_matrix, 2))));
        end
        if ndesired_dimensions == size(pca_matrix, 2)
            fprintf('The base_reduction_file has the number of dimensions desired. Nothing do to.\n\n');
            return;
        end
    else
        [feature_matrix, files] = fcommon.load_folder(train_folder);
        total_dimensions = size(feature_matrix, 2);
        base_dimensions = 1:total_dimensions;
    end
    base_ndimensions = numel(base_dimensions);

    expname = 'DR';
    exptype = reduction_type;

    if reduction_type == 1
        fprintf('Reducing the number of dimensions...\n');
        chosen = randperm(base_ndimensions);
        dimension_list = base_dimensions(chosen(1:ndesired_dimensions));
        save(sprintf('%s/%s', save_path, experiment_name), 'dimension_list', 'expname', 'exptype');
        fprintf('Done.\n\n');
    elseif reduction_type == 2
        dimension_list = base_dimensions(1:ndesired_dimensions);
        if ~exist('pca_matrix', 'var')
            fprintf('Calculating PCA...\n');
            covariance_matrix = cov(feature_matrix);
            [eigenvector, eigenvalue] = eig(covariance_matrix);
            eigenvalue = diag(eigenvalue);
            eigenvalue = flipud(eigenvalue);
            eigenvector = fliplr(eigenvector);
            pca_matrix = eigenvector(:, 1:ndesired_dimensions);
        else
            fprintf('PCA already calculated. Reducing the number of dimensions...\n');
            pca_matrix = pca_matrix(:, 1:ndesired_dimensions);
        end
        save(sprintf('%s/%s', save_path, experiment_name), 'pca_matrix', 'dimension_list', 'expname', 'exptype');
        fprintf('Done.\n\n');
    end
end
