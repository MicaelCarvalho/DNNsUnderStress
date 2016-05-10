function []=A_generate_quantization(save_path, experiment_name, train_folder, quantization_type, nvalues)
    % save_path = path to save the transformation files, necessary for applying the transformation later
    % experiment_name = name of the experiment
    % train_folder = path to the train folder, the transformation will be calculated based on it
    % quantization_type = single-dictionary (1) or multiple-dictionaries (2)
    % nvalues = number of desired values in the dictionary
    
    if ~exist('save_path', 'var')
        throw(MException('A_generate_quantization:save_path', 'ERROR: Parameter save_path is empty.'));
    end
    if ~exist('experiment_name', 'var')
        throw(MException('A_generate_quantization:experiment_name', 'ERROR: Parameter experiment_name is empty.'));
    end
    if ~exist('train_folder', 'var')
        throw(MException('A_generate_quantization:train_folder', 'ERROR: Parameter train_folder is empty.'));
    end
    if ~exist('quantization_type', 'var')
        throw(MException('A_generate_quantization:quantization_type', 'ERROR: Parameter quantization_type is empty.'));
    end
    if ~exist('nvalues', 'var')
        throw(MException('A_generate_quantization:nvalues', 'ERROR: Parameter nvalues is empty.'));
    end

    fprintf('Initiating %s.\n', experiment_name);
    if quantization_type == 1
        fprintf('- Single-dictionary quantization enabled;\n\n');
    elseif quantization_type == 2
        fprintf('- Multiple-dictionaries quantization enabled;\n\n');
    else
        throw(MException('quantization:quantization_type', sprintf('ERROR: Invalid quantization_type value (%d).\quantization_type should be 1 (single-dictionary) or 2 (multiple-dictionaries).', reduction_type)));
    end

    fcommon = BaseFunctions.getInstance;
    [feature_matrix, files] = fcommon.load_folder(train_folder);
    expname = 'Q';
    exptype = quantization_type;

    if quantization_type == 1
        fprintf('Calculating dictionary...\n');

        maxval = max(max(feature_matrix));
        minval = min(min(feature_matrix));
        step = (maxval-minval) / nvalues;
        val = minval + step / 2;
        dictionary = [];
        while val < maxval
            dictionary = [dictionary val];
            val = val + step;
        end

        save(sprintf('%s/%s', save_path, experiment_name), 'dictionary', 'expname', 'exptype');
        fprintf('Done.\n\n');
    elseif quantization_type == 2
        fprintf('Calculating dictionaries...\n');
        total_dimensions = size(feature_matrix, 2);
        
        maxval = max(feature_matrix,[],1);
        minval = min(feature_matrix,[],1);
        step = (maxval-minval) / nvalues;
        val = minval + step / 2;
        dictionary = val;
        for index = 2:nvalues
            val = val + step;
            dictionary = vertcat(dictionary, val);
        end
        if size(dictionary,2) ~= total_dimensions
            throw(MException('quantization:total_dimensions', sprintf('Internal ERROR: Number of dimensions mismatch (%d vs %d).', size(dictionary,2), total_dimensions)));
        end

        save(sprintf('%s/%s', save_path, experiment_name), 'dictionary', 'expname', 'exptype');
        fprintf('Done.\n\n');
    end
end
